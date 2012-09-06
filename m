Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 91CF86B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 07:08:45 -0400 (EDT)
Received: by lbon3 with SMTP id n3so1329891lbo.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 04:08:43 -0700 (PDT)
Subject: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 06 Sep 2012 15:08:36 +0400
Message-ID: <20120906110836.22423.17638.stgit@zurg>
In-Reply-To: <50460CED.6060006@redhat.com>
References: <50460CED.6060006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch adds simple tracker for swapin readahread effectiveness, and tunes
readahead cluster depending on it. It manage internal state [0..1024] and scales
readahead order between 0 and value from sysctl vm.page-cluster (3 by default).
Swapout and readahead misses decreases state, swapin and ra hits increases it:

 Swapin          +1		[page fault, shmem, etc... ]
 Swapout         -10
 Readahead hit   +10
 Readahead miss  -1		[removing from swapcache unused readahead page]

If system is under serious memory pressure swapin readahead is useless, because
pages in swap are highly fragmented and cache hit is mostly impossible. In this
case swapin only leads to unnecessary memory allocations. But readahead helps to
read all swapped pages back to memory if system recovers from memory pressure.

This patch inspired by patch from Shaohua Li
http://www.spinics.net/lists/linux-mm/msg41128.html
mine version uses system wide state rather than per-VMA counters.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 include/linux/page-flags.h |    1 +
 mm/swap_state.c            |   42 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index b5d1384..3657cdc 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -231,6 +231,7 @@ PAGEFLAG(MappedToDisk, mappedtodisk)
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
 PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
 PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
+TESTCLEARFLAG(Readahead, reclaim)
 
 #ifdef CONFIG_HIGHMEM
 /*
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 0cb36fb..d6c7a88 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -53,12 +53,31 @@ static struct {
 	unsigned long find_total;
 } swap_cache_info;
 
+#define SWAP_RA_BITS	10
+
+static atomic_t swap_ra_state = ATOMIC_INIT((1 << SWAP_RA_BITS) - 1);
+static int swap_ra_cluster = 1;
+
+static void swap_ra_update(int delta)
+{
+	int old_state, new_state;
+
+	old_state = atomic_read(&swap_ra_state);
+	new_state = clamp(old_state + delta, 0, 1 << SWAP_RA_BITS);
+	if (old_state != new_state) {
+		atomic_set(&swap_ra_state, new_state);
+		swap_ra_cluster = (page_cluster * new_state) >> SWAP_RA_BITS;
+	}
+}
+
 void show_swap_cache_info(void)
 {
 	printk("%lu pages in swap cache\n", total_swapcache_pages);
-	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu\n",
+	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu,"
+		" readahead %d/%d\n",
 		swap_cache_info.add_total, swap_cache_info.del_total,
-		swap_cache_info.find_success, swap_cache_info.find_total);
+		swap_cache_info.find_success, swap_cache_info.find_total,
+		1 << swap_ra_cluster, atomic_read(&swap_ra_state));
 	printk("Free swap  = %ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
 	printk("Total swap = %lukB\n", total_swap_pages << (PAGE_SHIFT - 10));
 }
@@ -112,6 +131,8 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
 	if (!error) {
 		error = __add_to_swap_cache(page, entry);
 		radix_tree_preload_end();
+		/* FIXME weird place */
+		swap_ra_update(-10); /* swapout, decrease readahead */
 	}
 	return error;
 }
@@ -132,6 +153,8 @@ void __delete_from_swap_cache(struct page *page)
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
+	if (TestClearPageReadahead(page))
+		swap_ra_update(-1); /* readahead miss */
 }
 
 /**
@@ -265,8 +288,11 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 
 	page = find_get_page(&swapper_space, entry.val);
 
-	if (page)
+	if (page) {
 		INC_CACHE_INFO(find_success);
+		if (TestClearPageReadahead(page))
+			swap_ra_update(+10); /* readahead hit */
+	}
 
 	INC_CACHE_INFO(find_total);
 	return page;
@@ -374,11 +400,14 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *page;
-	unsigned long offset = swp_offset(entry);
+	unsigned long entry_offset = swp_offset(entry);
+	unsigned long offset = entry_offset;
 	unsigned long start_offset, end_offset;
-	unsigned long mask = (1UL << page_cluster) - 1;
+	unsigned long mask = (1UL << swap_ra_cluster) - 1;
 	struct blk_plug plug;
 
+	swap_ra_update(+1); /* swapin, increase readahead */
+
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
 	end_offset = offset | mask;
@@ -392,6 +421,9 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 						gfp_mask, vma, addr);
 		if (!page)
 			continue;
+		/* FIXME these pages aren't readahead sometimes */
+		if (offset != entry_offset)
+			SetPageReadahead(page);
 		page_cache_release(page);
 	}
 	blk_finish_plug(&plug);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
