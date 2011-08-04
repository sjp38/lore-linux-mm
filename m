Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D30EA900139
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 17:07:47 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p74L7hp2015205
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:44 -0700
Received: from iyf40 (iyf40.prod.google.com [10.241.50.104])
	by wpaz9.hot.corp.google.com with ESMTP id p74L5YUS014038
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:42 -0700
Received: by iyf40 with SMTP id 40so1975504iyf.19
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 14:07:39 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 1/3] mm: Replace naked page->_count accesses with accessor functions
Date: Thu,  4 Aug 2011 14:07:20 -0700
Message-Id: <1312492042-13184-2-git-send-email-walken@google.com>
In-Reply-To: <1312492042-13184-1-git-send-email-walken@google.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

This change replaces all naked page->count accesses with accessor functions,
with few exceptions:
- assertions checking for equality with zero
- debug messages displaying the page count value

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/powerpc/mm/gup.c                        |    4 +-
 arch/powerpc/platforms/512x/mpc512x_shared.c |    5 ++-
 arch/x86/mm/gup.c                            |    6 ++--
 drivers/net/niu.c                            |    4 +-
 include/linux/mm.h                           |   27 ++++++++++++++++++++-----
 include/linux/pagemap.h                      |    4 +-
 mm/huge_memory.c                             |    9 ++++---
 mm/internal.h                                |   10 +++++++++
 mm/memory_hotplug.c                          |    4 +-
 mm/swap.c                                    |    6 ++--
 10 files changed, 53 insertions(+), 26 deletions(-)

diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
index fec1320..7b7f846 100644
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -22,8 +22,8 @@ static inline void get_huge_page_tail(struct page *page)
 	 * __split_huge_page_refcount() cannot run
 	 * from under us.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < 0);
-	atomic_inc(&page->_count);
+	VM_BUG_ON(__page_count(page) < 0);
+	__get_page(page);
 }
 
 /*
diff --git a/arch/powerpc/platforms/512x/mpc512x_shared.c b/arch/powerpc/platforms/512x/mpc512x_shared.c
index e41ebbd..7c5a58a 100644
--- a/arch/powerpc/platforms/512x/mpc512x_shared.c
+++ b/arch/powerpc/platforms/512x/mpc512x_shared.c
@@ -18,6 +18,7 @@
 #include <linux/of_platform.h>
 #include <linux/fsl-diu-fb.h>
 #include <linux/bootmem.h>
+#include <linux/mm.h>
 #include <sysdev/fsl_soc.h>
 
 #include <asm/cacheflush.h>
@@ -200,8 +201,8 @@ static inline void mpc512x_free_bootmem(struct page *page)
 {
 	__ClearPageReserved(page);
 	BUG_ON(PageTail(page));
-	BUG_ON(atomic_read(&page->_count) > 1);
-	atomic_set(&page->_count, 1);
+	BUG_ON(page_count(page) > 1);
+	init_page_count(page);
 	__free_page(page);
 	totalram_pages++;
 }
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index dbe34b9..30ea122 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -104,7 +104,7 @@ static inline void get_head_page_multiple(struct page *page, int nr)
 {
 	VM_BUG_ON(page != compound_head(page));
 	VM_BUG_ON(page_count(page) == 0);
-	atomic_add(nr, &page->_count);
+	__add_page_count(nr, page);
 	SetPageReferenced(page);
 }
 
@@ -114,8 +114,8 @@ static inline void get_huge_page_tail(struct page *page)
 	 * __split_huge_page_refcount() cannot run
 	 * from under us.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < 0);
-	atomic_inc(&page->_count);
+	VM_BUG_ON(__page_count(page) < 0);
+	__get_page(page);
 }
 
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index cc25bff..9057ab1 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3354,8 +3354,8 @@ static int niu_rbr_add_page(struct niu *np, struct rx_ring_info *rp,
 
 	niu_hash_page(rp, page, addr);
 	if (rp->rbr_blocks_per_page > 1)
-		atomic_add(rp->rbr_blocks_per_page - 1,
-			   &compound_head(page)->_count);
+		__add_page_count(rp->rbr_blocks_per_page - 1,
+				 compound_head(page));
 
 	for (i = 0; i < rp->rbr_blocks_per_page; i++) {
 		__le32 *rbr = &rp->rbr[start_index + i];
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9670f71..7984f90 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -266,12 +266,17 @@ struct inode;
  * routine so they can be sure the page doesn't go away from under them.
  */
 
+static inline int __page_count(struct page *page)
+{
+	return atomic_read(&page->_count);
+}
+
 /*
  * Drop a ref, return true if the refcount fell to zero (the page has no users)
  */
 static inline int put_page_testzero(struct page *page)
 {
-	VM_BUG_ON(atomic_read(&page->_count) == 0);
+	VM_BUG_ON(__page_count(page) <= 0);
 	return atomic_dec_and_test(&page->_count);
 }
 
@@ -357,7 +362,17 @@ static inline struct page *compound_head(struct page *page)
 
 static inline int page_count(struct page *page)
 {
-	return atomic_read(&compound_head(page)->_count);
+	return __page_count(compound_head(page));
+}
+
+static inline void __add_page_count(int nr, struct page *page)
+{
+	atomic_add(nr, &page->_count);
+}
+
+static inline void __get_page(struct page *page)
+{
+	atomic_inc(&page->_count);
 }
 
 static inline void get_page(struct page *page)
@@ -370,8 +385,8 @@ static inline void get_page(struct page *page)
 	 * bugcheck only verifies that the page->_count isn't
 	 * negative.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
-	atomic_inc(&page->_count);
+	VM_BUG_ON(__page_count(page) < !PageTail(page));
+	__get_page(page);
 	/*
 	 * Getting a tail page will elevate both the head and tail
 	 * page->_count(s).
@@ -382,8 +397,8 @@ static inline void get_page(struct page *page)
 		 * __split_huge_page_refcount can't run under
 		 * get_page().
 		 */
-		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
-		atomic_inc(&page->first_page->_count);
+		VM_BUG_ON(__page_count(page->first_page) <= 0);
+		__get_page(page->first_page);
 	}
 }
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 716875e..3dc3334 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -147,7 +147,7 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * SMP requires.
 	 */
 	VM_BUG_ON(page_count(page) == 0);
-	atomic_inc(&page->_count);
+	__get_page(page);
 
 #else
 	if (unlikely(!get_page_unless_zero(page))) {
@@ -176,7 +176,7 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 	VM_BUG_ON(!in_atomic());
 # endif
 	VM_BUG_ON(page_count(page) == 0);
-	atomic_add(count, &page->_count);
+	__add_page_count(count, page);
 
 #else
 	if (unlikely(!atomic_add_unless(&page->_count, count, 0)))
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 81532f2..2d45af2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1156,6 +1156,7 @@ static void __split_huge_page_refcount(struct page *page)
 	unsigned long head_index = page->index;
 	struct zone *zone = page_zone(page);
 	int zonestat;
+	int tail_counts = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -1165,10 +1166,9 @@ static void __split_huge_page_refcount(struct page *page)
 		struct page *page_tail = page + i;
 
 		/* tail_page->_count cannot change */
-		atomic_sub(atomic_read(&page_tail->_count), &page->_count);
-		BUG_ON(page_count(page) <= 0);
-		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
-		BUG_ON(atomic_read(&page_tail->_count) <= 0);
+		tail_counts += __page_count(page_tail);
+		__add_page_count(page_mapcount(page) + 1, page_tail);
+		BUG_ON(__page_count(page_tail) <= 0);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();
@@ -1253,6 +1253,7 @@ static void __split_huge_page_refcount(struct page *page)
 		put_page(page_tail);
 	}
 
+	__sub_page_count(tail_counts, page);
 	/*
 	 * Only the head page (now become a regular page) is required
 	 * to be pinned by the caller.
diff --git a/mm/internal.h b/mm/internal.h
index d071d38..93d8da4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -32,11 +32,21 @@ static inline void set_page_refcounted(struct page *page)
 	set_page_count(page, 1);
 }
 
+static inline void __sub_page_count(int nr, struct page *page)
+{
+	atomic_sub(nr, &page->_count);
+}
+
 static inline void __put_page(struct page *page)
 {
 	atomic_dec(&page->_count);
 }
 
+static inline int __put_page_return(struct page *page)
+{
+	return atomic_dec_return(&page->_count) >> 1;
+}
+
 extern unsigned long highest_memmap_pfn;
 
 /*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c46887b..06d0575 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -88,7 +88,7 @@ static void get_page_bootmem(unsigned long info,  struct page *page,
 	page->lru.next = (struct list_head *) type;
 	SetPagePrivate(page);
 	set_page_private(page, info);
-	atomic_inc(&page->_count);
+	__get_page(page);
 }
 
 /* reference to __meminit __free_pages_bootmem is valid
@@ -101,7 +101,7 @@ void __ref put_page_bootmem(struct page *page)
 	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
 	       type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE);
 
-	if (atomic_dec_return(&page->_count) == 1) {
+	if (__put_page_return(page) == 1) {
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
 		INIT_LIST_HEAD(&page->lru);
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..46ae089 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -128,9 +128,9 @@ static void put_compound_page(struct page *page)
 			if (put_page_testzero(page_head))
 				VM_BUG_ON(1);
 			/* __split_huge_page_refcount will wait now */
-			VM_BUG_ON(atomic_read(&page->_count) <= 0);
-			atomic_dec(&page->_count);
-			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
+			VM_BUG_ON(__page_count(page) <= 0);
+			__put_page(page);
+			VM_BUG_ON(__page_count(page_head) <= 0);
 			compound_unlock_irqrestore(page_head, flags);
 			if (put_page_testzero(page_head)) {
 				if (PageHead(page_head))
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
