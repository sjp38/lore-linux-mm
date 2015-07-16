Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 68379280312
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 19:24:26 -0400 (EDT)
Received: by obnw1 with SMTP id w1so56529329obn.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:24:26 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id tv10si7688805oeb.47.2015.07.16.16.24.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 16:24:24 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH RESEND 3/3] mm: Fix bugs in region_is_ram()
Date: Thu, 16 Jul 2015 17:23:16 -0600
Message-Id: <1437088996-28511-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
References: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org
Cc: travis@sgi.com, roland@purestorage.com, dan.j.williams@intel.com, mcgrof@suse.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Toshi Kani <toshi.kani@hp.com>

region_is_ram() looks up the iomem_resource table to check if
a target range is in RAM.  However, it always returns with -1
due to invalid range checks.  It always breaks the loop at the
first entry of the table.

Another issue is that it compares p->flags and flags, but it
always fails.  The flags is declared as int, which makes it as
a negative value with IORESOURCE_BUSY (0x80000000) set while
p->flags is unsigned long.

Fix the range check and flags so that region_is_ram() works as
advertised.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Mike Travis <travis@sgi.com>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 kernel/resource.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 90552aa..fed052a 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -504,13 +504,13 @@ int region_is_ram(resource_size_t start, unsigned long size)
 {
 	struct resource *p;
 	resource_size_t end = start + size - 1;
-	int flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	unsigned long flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	const char *name = "System RAM";
 	int ret = -1;
 
 	read_lock(&resource_lock);
 	for (p = iomem_resource.child; p ; p = p->sibling) {
-		if (end < p->start)
+		if (p->end < start)
 			continue;
 
 		if (p->start <= start && end <= p->end) {
@@ -521,7 +521,7 @@ int region_is_ram(resource_size_t start, unsigned long size)
 				ret = 1;
 			break;
 		}
-		if (p->end < start)
+		if (end < p->start)
 			break;	/* not found */
 	}
 	read_unlock(&resource_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
