Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B55D46B0038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 10:44:04 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so16722629pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 07:44:04 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id gr9si11682pac.239.2015.06.09.07.44.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 07:44:03 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so15271318pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 07:44:03 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: show proportional swap share of the mapping
Date: Tue,  9 Jun 2015 23:43:51 +0900
Message-Id: <1433861031-13233-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bongkyu Kim <bongkyu.kim@lge.com>, Minchan Kim <minchan@kernel.org>

For system uses swap heavily and has lots of shared anonymous page,
it's very trouble to find swap set size per process because currently
smaps doesn't report proportional set size of swap.
It ends up that sum of the number of swap for all processes is greater
than swap device size.

This patch introduces SwapPss field on /proc/<pid>/smaps.

Bongkyu tested it. Result is below.

1. 50M used swap
SwapTotal: 461976 kB
SwapFree: 411192 kB

$ adb shell cat /proc/*/smaps | grep "SwapPss:" | \
	awk '{sum += $2} END {print sum}';
48236
$ adb shell cat /proc/*/smaps | grep "Swap:" | \
	awk '{sum += $2} END {print sum}';
141184

2. 240M used swap
SwapTotal: 461976 kB
SwapFree: 216808 kB

$ adb shell cat /proc/*/smaps | grep "SwapPss:" | \
	awk '{sum += $2} END {print sum}';
230315
$ adb shell cat /proc/*/smaps | grep "Swap:" | \
awk '{sum += $2} END {print sum}';
1387744

Reported-by: Bongkyu Kim <bongkyu.kim@lge.com>
Tested-by: Bongkyu Kim <bongkyu.kim@lge.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/proc.txt |  3 ++-
 fs/proc/task_mmu.c                 | 18 ++++++++++++++--
 include/linux/swap.h               |  1 +
 mm/swapfile.c                      | 42 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 6f7fafd..b16683f 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -424,6 +424,7 @@ Private_Dirty:         0 kB
 Referenced:          892 kB
 Anonymous:             0 kB
 Swap:                  0 kB
+SwapPss:               0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:              374 kB
@@ -441,7 +442,7 @@ indicates the amount of memory currently marked as referenced or accessed.
 a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
 "Swap" shows how much would-be-anonymous memory is also used, but out on
-swap.
+swap. "SwapPss" shows process' proportional swap share of this mapping.
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 58be92e..79e5518 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -446,6 +446,7 @@ struct mem_size_stats {
 	unsigned long anonymous_thp;
 	unsigned long swap;
 	u64 pss;
+	u64 swap_pss;
 };
 
 static void smaps_account(struct mem_size_stats *mss, struct page *page,
@@ -492,9 +493,20 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 	} else if (is_swap_pte(*pte)) {
 		swp_entry_t swpent = pte_to_swp_entry(*pte);
 
-		if (!non_swap_entry(swpent))
+		if (!non_swap_entry(swpent)) {
+			int mapcount;
+
 			mss->swap += PAGE_SIZE;
-		else if (is_migration_entry(swpent))
+			mapcount = swp_swapcount(swpent);
+			if (mapcount >= 2) {
+				u64 pss_delta = (u64)PAGE_SIZE << PSS_SHIFT;
+
+				do_div(pss_delta, mapcount);
+				mss->swap_pss += pss_delta;
+			} else {
+				mss->swap_pss += (u64)PAGE_SIZE << PSS_SHIFT;
+			}
+		} else if (is_migration_entry(swpent))
 			page = migration_entry_to_page(swpent);
 	}
 
@@ -640,6 +652,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "Anonymous:      %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
 		   "Swap:           %8lu kB\n"
+		   "SwapPss:        %8lu kB\n"
 		   "KernelPageSize: %8lu kB\n"
 		   "MMUPageSize:    %8lu kB\n"
 		   "Locked:         %8lu kB\n",
@@ -654,6 +667,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.anonymous >> 10,
 		   mss.anonymous_thp >> 10,
 		   mss.swap >> 10,
+		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
 		   vma_kernel_pagesize(vma) >> 10,
 		   vma_mmu_pagesize(vma) >> 10,
 		   (vma->vm_flags & VM_LOCKED) ?
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 9a7adfb..402a24b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -432,6 +432,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
+extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index a7e7210..7a6bd1e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -875,6 +875,48 @@ int page_swapcount(struct page *page)
 }
 
 /*
+ * How many references to @entry are currently swapped out?
+ * This considers COUNT_CONTINUED so it returns exact answer.
+ */
+int swp_swapcount(swp_entry_t entry)
+{
+	int count, tmp_count, n;
+	struct swap_info_struct *p;
+	struct page *page;
+	pgoff_t offset;
+	unsigned char *map;
+
+	p = swap_info_get(entry);
+	if (!p)
+		return 0;
+
+	count = swap_count(p->swap_map[swp_offset(entry)]);
+	if (!(count & COUNT_CONTINUED))
+		goto out;
+
+	count &= ~COUNT_CONTINUED;
+	n = SWAP_MAP_MAX + 1;
+
+	offset = swp_offset(entry);
+	page = vmalloc_to_page(p->swap_map + offset);
+	offset &= ~PAGE_MASK;
+	VM_BUG_ON(page_private(page) != SWP_CONTINUED);
+
+	do {
+		page = list_entry(page->lru.next, struct page, lru);
+		map = kmap_atomic(page) + offset;
+		tmp_count = *map;
+		kunmap_atomic(map);
+
+		count += (tmp_count & ~COUNT_CONTINUED) * n;
+		n *= (SWAP_CONT_MAX + 1);
+	} while (tmp_count & COUNT_CONTINUED);
+out:
+	spin_unlock(&p->lock);
+	return count;
+}
+
+/*
  * We can write to an anon page without COW if there are no other references
  * to it.  And as a side-effect, free up its swap: because the old content
  * on disk will never be read, and seeking back there to write new content
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
