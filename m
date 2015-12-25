Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 53F8382FCB
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:10:05 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id l9so123278982oia.2
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:10:05 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id t63si39644209oie.59.2015.12.25.14.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:10:04 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 02/16] resource: make resource flags handled properly
Date: Fri, 25 Dec 2015 15:09:11 -0700
Message-Id: <1451081365-15190-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Toshi Kani <toshi.kani@hpe.com>

I/O resource flags consist of I/O resource types and modifier
bits.  Therefore, checking an I/O resource type in 'flags' must
be performed with a bitwise operation.

Fix find_next_iomem_res() and region_intersects() that simply
compare 'flags' against a given value.

Also change __request_region() to set 'res->flags' from
resource_type() and resource_ext_type() of the parent, so that
children nodes will inherit the extended I/O resource type.

Link: http://lkml.kernel.org/r/<CA+55aFy4WQrWexC4u2LxX9Mw2NVoznw7p3Yh=iF4Xtf7zKWnRw@mail.gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 kernel/resource.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index f150dbb..d30a175 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -358,7 +358,7 @@ static int find_next_iomem_res(struct resource *res, char *name,
 	read_lock(&resource_lock);
 
 	for (p = iomem_resource.child; p; p = next_resource(p, sibling_only)) {
-		if (p->flags != res->flags)
+		if ((p->flags & res->flags) != res->flags)
 			continue;
 		if (name && strcmp(p->name, name))
 			continue;
@@ -519,7 +519,8 @@ int region_intersects(resource_size_t start, size_t size, const char *name)
 
 	read_lock(&resource_lock);
 	for (p = iomem_resource.child; p ; p = p->sibling) {
-		bool is_type = strcmp(p->name, name) == 0 && p->flags == flags;
+		bool is_type = strcmp(p->name, name) == 0 &&
+				((p->flags & flags) == flags);
 
 		if (start >= p->start && start <= p->end)
 			is_type ? type++ : other++;
@@ -1071,7 +1072,7 @@ struct resource * __request_region(struct resource *parent,
 	res->name = name;
 	res->start = start;
 	res->end = start + n - 1;
-	res->flags = resource_type(parent);
+	res->flags = resource_type(parent) | resource_ext_type(parent);
 	res->flags |= IORESOURCE_BUSY | flags;
 
 	write_lock(&resource_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
