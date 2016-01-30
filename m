Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8B96B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:29:18 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 65so55472629pfd.2
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:29:18 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id ca7si8243109pad.240.2016.01.30.01.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:29:17 -0800 (PST)
Date: Sat, 30 Jan 2016 01:28:23 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-a3650d53ba16ec412185abb98f231e9ba6bcdc65@git.kernel.org>
Reply-To: dvlasenk@redhat.com, bp@suse.de, peterz@infradead.org,
        luto@amacapital.net, mcgrof@suse.com, jiang.liu@linux.intel.com,
        brgerst@gmail.com, dan.j.williams@intel.com, toshi.kani@hp.com,
        linux-mm@kvack.org, rafael.j.wysocki@intel.com, jsitnicki@gmail.com,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hpa@zytor.com,
        toshi.kani@hpe.com, vinod.koul@intel.com,
        torvalds@linux-foundation.org, mingo@kernel.org, tglx@linutronix.de,
        bp@alien8.de
In-Reply-To: <1453841853-11383-3-git-send-email-bp@alien8.de>
References: <1453841853-11383-3-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] resource: Handle resource flags properly
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: dvlasenk@redhat.com, bp@suse.de, peterz@infradead.org, luto@amacapital.net, jiang.liu@linux.intel.com, mcgrof@suse.com, brgerst@gmail.com, dan.j.williams@intel.com, toshi.kani@hp.com, jsitnicki@gmail.com, linux-kernel@vger.kernel.org, rafael.j.wysocki@intel.com, linux-mm@kvack.org, vinod.koul@intel.com, akpm@linux-foundation.org, toshi.kani@hpe.com, hpa@zytor.com, torvalds@linux-foundation.org, tglx@linutronix.de, bp@alien8.de, mingo@kernel.org

Commit-ID:  a3650d53ba16ec412185abb98f231e9ba6bcdc65
Gitweb:     http://git.kernel.org/tip/a3650d53ba16ec412185abb98f231e9ba6bcdc65
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:18 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:56 +0100

resource: Handle resource flags properly

I/O resource flags consist of I/O resource types and modifier
bits. Therefore, checking an I/O resource type in 'flags' must
be performed with a bitwise operation.

Fix find_next_iomem_res() and region_intersects() that simply
compare 'flags' against a given value.

Also change __request_region() to set 'res->flags' from
resource_type() and resource_ext_type() of the parent, so that
children nodes will inherit the extended I/O resource type.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Vinod Koul <vinod.koul@intel.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-3-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/resource.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 09c0597..96afc80 100644
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
