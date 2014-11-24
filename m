Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id DF8FA800CA
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 03:12:47 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id z10so9347148pdj.40
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 00:12:47 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id 2si6672739pdu.25.2014.11.24.00.12.41
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 00:12:43 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 4/8] mm/nommu: use alloc_pages_exact() rather than it's own implementation
Date: Mon, 24 Nov 2014 17:15:22 +0900
Message-Id: <1416816926-7756-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

do_mmap_private() in nommu.c try to allocate physically contiguous pages
with arbitrary size in some cases and we now have good abstract function
to do exactly same thing, alloc_pages_exact(). So, change to use it.

There is no functional change.
This is the preparation step for support page owner feature accurately.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/nommu.c |   33 +++++++++++----------------------
 1 file changed, 11 insertions(+), 22 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 2266a34..1b87c17 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1149,8 +1149,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 			   unsigned long len,
 			   unsigned long capabilities)
 {
-	struct page *pages;
-	unsigned long total, point, n;
+	unsigned long total, point;
 	void *base;
 	int ret, order;
 
@@ -1182,33 +1181,23 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	order = get_order(len);
 	kdebug("alloc order %d for %lx", order, len);
 
-	pages = alloc_pages(GFP_KERNEL, order);
-	if (!pages)
-		goto enomem;
-
 	total = 1 << order;
-	atomic_long_add(total, &mmap_pages_allocated);
-
 	point = len >> PAGE_SHIFT;
 
-	/* we allocated a power-of-2 sized page set, so we may want to trim off
-	 * the excess */
+	/* we don't want to allocate a power-of-2 sized page set */
 	if (sysctl_nr_trim_pages && total - point >= sysctl_nr_trim_pages) {
-		while (total > point) {
-			order = ilog2(total - point);
-			n = 1 << order;
-			kdebug("shave %lu/%lu @%lu", n, total - point, total);
-			atomic_long_sub(n, &mmap_pages_allocated);
-			total -= n;
-			set_page_refcounted(pages + total);
-			__free_pages(pages + total, order);
-		}
+		total = point;
+		kdebug("try to alloc exact %lu pages", total);
+		base = alloc_pages_exact(len, GFP_KERNEL);
+	} else {
+		base = __get_free_pages(GFP_KERNEL, order);
 	}
 
-	for (point = 1; point < total; point++)
-		set_page_refcounted(&pages[point]);
+	if (!base)
+		goto enomem;
+
+	atomic_long_add(total, &mmap_pages_allocated);
 
-	base = page_address(pages);
 	region->vm_flags = vma->vm_flags |= VM_MAPPED_COPY;
 	region->vm_start = (unsigned long) base;
 	region->vm_end   = region->vm_start + len;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
