Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id BA5D56B025F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:09:25 -0400 (EDT)
Received: by lagj9 with SMTP id j9so109931019lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:25 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com. [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id br8si13870083lbb.117.2015.09.15.07.09.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:09:24 -0700 (PDT)
Received: by lagj9 with SMTP id j9so109930426lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:23 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 08/10] mm/vmalloc: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:08:29 +0600
Message-Id: <1442326109-7548-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The <linux/mm.h> provides offset_in_page() macro. Let's use already
predefined macro instead of (addr & ~PAGE_MASK).

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/vmalloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2faaa29..b51b733 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -358,7 +358,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	struct vmap_area *first;
 
 	BUG_ON(!size);
-	BUG_ON(size & ~PAGE_MASK);
+	BUG_ON(offset_in_page(size));
 	BUG_ON(!is_power_of_2(align));
 
 	va = kmalloc_node(sizeof(struct vmap_area),
@@ -936,7 +936,7 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 	void *vaddr = NULL;
 	unsigned int order;
 
-	BUG_ON(size & ~PAGE_MASK);
+	BUG_ON(offset_in_page(size));
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
 	if (WARN_ON(size == 0)) {
 		/*
@@ -989,7 +989,7 @@ static void vb_free(const void *addr, unsigned long size)
 	unsigned int order;
 	struct vmap_block *vb;
 
-	BUG_ON(size & ~PAGE_MASK);
+	BUG_ON(offset_in_page(size));
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
 
 	flush_cache_vunmap((unsigned long)addr, (unsigned long)addr + size);
@@ -1902,7 +1902,7 @@ static int aligned_vread(char *buf, char *addr, unsigned long count)
 	while (count) {
 		unsigned long offset, length;
 
-		offset = (unsigned long)addr & ~PAGE_MASK;
+		offset = offset_in_page(addr);
 		length = PAGE_SIZE - offset;
 		if (length > count)
 			length = count;
@@ -1941,7 +1941,7 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
 	while (count) {
 		unsigned long offset, length;
 
-		offset = (unsigned long)addr & ~PAGE_MASK;
+		offset = offset_in_page(addr);
 		length = PAGE_SIZE - offset;
 		if (length > count)
 			length = count;
@@ -2392,7 +2392,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	bool purged = false;
 
 	/* verify parameters and allocate data structures */
-	BUG_ON(align & ~PAGE_MASK || !is_power_of_2(align));
+	BUG_ON(offset_in_page(align) || !is_power_of_2(align));
 	for (last_area = 0, area = 0; area < nr_vms; area++) {
 		start = offsets[area];
 		end = start + sizes[area];
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
