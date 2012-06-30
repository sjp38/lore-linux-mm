Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 96D296B0099
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 05:10:04 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH] mm: setup pageblock_order before it's used by sparse
Date: Sat, 30 Jun 2012 17:07:54 +0800
Message-ID: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tony Luck <tony.luck@intel.com>, Yinghai Lu <yinghai@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

From: Xishi Qiu <qiuxishi@huawei.com>

On architectures with CONFIG_HUGETLB_PAGE_SIZE_VARIABLE set, such as Itanium,
pageblock_order is a variable with default value of 0. It's set to the right
value by set_pageblock_order() in function free_area_init_core().

But pageblock_order may be used by sparse_init() before free_area_init_core()
is called along path:
sparse_init()
    ->sparse_early_usemaps_alloc_node()
	->usemap_size()
	    ->SECTION_BLOCKFLAGS_BITS
		->((1UL << (PFN_SECTION_SHIFT - pageblock_order)) *
NR_PAGEBLOCK_BITS)

The uninitialized pageblock_size will cause memory wasting because usemap_size()
returns a much bigger value then it's really needed.

For example, on an Itanium platform,
sparse_init() pageblock_order=0 usemap_size=24576
free_area_init_core() before pageblock_order=0, usemap_size=24576
free_area_init_core() after pageblock_order=12, usemap_size=8

That means 24K memory has been wasted for each section, so fix it by calling
set_pageblock_order() from sparse_init().

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 mm/internal.h   |    2 ++
 mm/page_alloc.c |    4 ++--
 mm/sparse.c     |    3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 2ba87fb..8052379 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -347,3 +347,5 @@ extern u32 hwpoison_filter_enable;
 extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long,
         unsigned long, unsigned long);
+
+extern void set_pageblock_order(void);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..f38509b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4301,7 +4301,7 @@ static inline void setup_usemap(struct pglist_data *pgdat,
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 
 /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
-static inline void __init set_pageblock_order(void)
+void __init set_pageblock_order(void)
 {
 	unsigned int order;
 
@@ -4329,7 +4329,7 @@ static inline void __init set_pageblock_order(void)
  * include/linux/pageblock-flags.h for the values of pageblock_order based on
  * the kernel config
  */
-static inline void set_pageblock_order(void)
+void __init set_pageblock_order(void)
 {
 }
 
diff --git a/mm/sparse.c b/mm/sparse.c
index fca2ab5..3a3af73 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -485,6 +485,9 @@ void __init sparse_init(void)
 	struct page **map_map;
 #endif
 
+	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
+	set_pageblock_order();
+
 	/*
 	 * map is using big page (aka 2M in x86 64 bit)
 	 * usemap is less one page (aka 24 bytes)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
