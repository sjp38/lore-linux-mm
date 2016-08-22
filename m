Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40F246B0253
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:27:54 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e63so199234310ith.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:27:54 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id b14si5036251ioa.160.2016.08.22.01.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 01:27:53 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 2/4] Add non-swap page flag to mark a page will not swap
Date: Mon, 22 Aug 2016 16:25:07 +0800
Message-ID: <1471854309-30414-3-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, zhuhui@xiaomi.com, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

After a page marked non-swap flag in swap driver, it will add to
unevictable lru list.
This page will be kept in this status before its data changed.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 fs/proc/meminfo.c              |  6 ++++++
 include/linux/mm_inline.h      | 20 ++++++++++++++++++--
 include/linux/mmzone.h         |  3 +++
 include/linux/page-flags.h     |  8 ++++++++
 include/trace/events/mmflags.h |  9 ++++++++-
 kernel/events/uprobes.c        | 16 +++++++++++++++-
 mm/Kconfig                     |  5 +++++
 mm/memory.c                    | 34 ++++++++++++++++++++++++++++++++++
 mm/migrate.c                   |  4 ++++
 mm/mprotect.c                  |  8 ++++++++
 mm/vmscan.c                    | 41 ++++++++++++++++++++++++++++++++++++++++-
 11 files changed, 149 insertions(+), 5 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index b9a8c81..5c79b2e 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -79,6 +79,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 		"SwapTotal:      %8lu kB\n"
 		"SwapFree:       %8lu kB\n"
+#ifdef CONFIG_NON_SWAP
+		"NonSwap:        %8lu kB\n"
+#endif
 		"Dirty:          %8lu kB\n"
 		"Writeback:      %8lu kB\n"
 		"AnonPages:      %8lu kB\n"
@@ -138,6 +141,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 		K(i.totalswap),
 		K(i.freeswap),
+#ifdef CONFIG_NON_SWAP
+		K(global_page_state(NR_NON_SWAP)),
+#endif
 		K(global_node_page_state(NR_FILE_DIRTY)),
 		K(global_node_page_state(NR_WRITEBACK)),
 		K(global_node_page_state(NR_ANON_MAPPED)),
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 71613e8..92298ce 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -46,15 +46,31 @@ static __always_inline void update_lru_size(struct lruvec *lruvec,
 static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
+	int nr_pages = hpage_nr_pages(page);
+	enum zone_type zid = page_zonenum(page);
+#ifdef CONFIG_NON_SWAP
+	if (PageNonSwap(page)) {
+		lru = LRU_UNEVICTABLE;
+		update_lru_size(lruvec, NR_NON_SWAP, zid, nr_pages);
+	}
+#endif
+	update_lru_size(lruvec, lru, zid, nr_pages);
 	list_add(&page->lru, &lruvec->lists[lru]);
 }
 
 static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
+	int nr_pages = hpage_nr_pages(page);
+	enum zone_type zid = page_zonenum(page);
+#ifdef CONFIG_NON_SWAP
+	if (PageNonSwap(page)) {
+		lru = LRU_UNEVICTABLE;
+		update_lru_size(lruvec, NR_NON_SWAP, zid, -nr_pages);
+	}
+#endif
 	list_del(&page->lru);
-	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
+	update_lru_size(lruvec, lru, zid, -nr_pages);
 }
 
 /**
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78..da08d20 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -138,6 +138,9 @@ enum zone_stat_item {
 	NUMA_OTHER,		/* allocation from other node */
 #endif
 	NR_FREE_CMA_PAGES,
+#ifdef CONFIG_NON_SWAP
+	NR_NON_SWAP,
+#endif
 	NR_VM_ZONE_STAT_ITEMS };
 
 enum node_stat_item {
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda..0cd80db9 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -105,6 +105,9 @@ enum pageflags {
 	PG_young,
 	PG_idle,
 #endif
+#ifdef CONFIG_NON_SWAP
+	PG_non_swap,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -303,6 +306,11 @@ PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
 PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
 	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
 
+#ifdef CONFIG_NON_SWAP
+PAGEFLAG(NonSwap, non_swap, PF_NO_TAIL)
+	TESTSCFLAG(NonSwap, non_swap, PF_NO_TAIL)
+#endif
+
 #ifdef CONFIG_HIGHMEM
 /*
  * Must use a macro here due to header dependency issues. page_zone() is not
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 5a81ab4..1c0ccc9 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -79,6 +79,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_NON_SWAP
+#define IF_HAVE_PG_NON_SWAP(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_NON_SWAP(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_error,		"error"		},		\
@@ -104,7 +110,8 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_NON_SWAP(PG_non_swap,	"non_swap"	)
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index b7a525a..a7e4153 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -160,6 +160,10 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	const unsigned long mmun_start = addr;
 	const unsigned long mmun_end   = addr + PAGE_SIZE;
 	struct mem_cgroup *memcg;
+	pte_t pte;
+#ifdef CONFIG_NON_SWAP
+	bool non_swap;
+#endif
 
 	err = mem_cgroup_try_charge(kpage, vma->vm_mm, GFP_KERNEL, &memcg,
 			false);
@@ -176,6 +180,11 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 		goto unlock;
 
 	get_page(kpage);
+#ifdef CONFIG_NON_SWAP
+	non_swap = TestClearPageNonSwap(page);
+	if (non_swap)
+		SetPageNonSwap(kpage);
+#endif
 	page_add_new_anon_rmap(kpage, vma, addr, false);
 	mem_cgroup_commit_charge(kpage, memcg, false, false);
 	lru_cache_add_active_or_unevictable(kpage, vma);
@@ -187,7 +196,12 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush_notify(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	pte = mk_pte(kpage, vma->vm_page_prot);
+#ifdef CONFIG_NON_SWAP
+	if (non_swap)
+		pte = pte_wrprotect(pte);
+#endif
+	set_pte_at_notify(mm, addr, ptep, pte);
 
 	page_remove_rmap(page, false);
 	if (!page_mapped(page))
diff --git a/mm/Kconfig b/mm/Kconfig
index 57ecdb3..d8d4b41 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -708,3 +708,8 @@ config ARCH_HAS_PKEYS
 config LATE_UNMAP
 	bool
 	depends on SWAP
+
+config NON_SWAP
+	bool
+	depends on SWAP
+	select LATE_UNMAP
diff --git a/mm/memory.c b/mm/memory.c
index 83be99d..2448004 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -64,6 +64,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
+#include <linux/mm_inline.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -2338,6 +2339,26 @@ static int wp_page_shared(struct fault_env *fe, pte_t orig_pte,
 	return wp_page_reuse(fe, orig_pte, old_page, page_mkwrite, 1);
 }
 
+#ifdef CONFIG_NON_SWAP
+static void
+clear_page_non_swap(struct page *page)
+{
+	struct zone *zone;
+	struct lruvec *lruvec;
+
+	if (!PageLRU(page) || !page_evictable(page))
+		return;
+
+	zone = page_zone(page);
+	spin_lock_irq(zone_lru_lock(zone));
+	__dec_zone_page_state(page, NR_NON_SWAP);
+	lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
+	del_page_from_lru_list(page, lruvec, LRU_UNEVICTABLE);
+	add_page_to_lru_list(page, lruvec, page_lru(page));
+	spin_unlock_irq(zone_lru_lock(zone));
+}
+#endif
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -2400,6 +2421,10 @@ static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
 			put_page(old_page);
 		}
 		if (reuse_swap_page(old_page, &total_mapcount)) {
+#ifdef CONFIG_NON_SWAP
+			if (unlikely(TestClearPageNonSwap(old_page)))
+				clear_page_non_swap(old_page);
+#endif
 			if (total_mapcount == 1) {
 				/*
 				 * The page is all ours. Move it to
@@ -2581,6 +2606,11 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 		goto out_release;
 	}
 
+#ifdef CONFIG_NON_SWAP
+	if ((fe->flags & FAULT_FLAG_WRITE) && unlikely(TestClearPageNonSwap(page)))
+		clear_page_non_swap(page);
+#endif
+
 	/*
 	 * Make sure try_to_free_swap or reuse_swap_page or swapoff did not
 	 * release the swapcache from under us.  The page pin, and pte_same
@@ -2638,6 +2668,10 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
 		pte = pte_mksoft_dirty(pte);
+#ifdef CONFIG_NON_SWAP
+	if (!(fe->flags & FAULT_FLAG_WRITE) && PageNonSwap(page))
+		pte = pte_wrprotect(pte);
+#endif
 	set_pte_at(vma->vm_mm, fe->address, fe->pte, pte);
 	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, fe->address, exclusive);
diff --git a/mm/migrate.c b/mm/migrate.c
index f7ee04a..46ac926 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -640,6 +640,10 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
 		SetPageMappedToDisk(newpage);
+#ifdef CONFIG_NON_SWAP
+	if (TestClearPageNonSwap(page))
+		SetPageNonSwap(newpage);
+#endif
 
 	/* Move dirty on pages not done by migrate_page_move_mapping() */
 	if (PageDirty(page))
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a4830f0..6539c6e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -79,6 +79,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (pte_present(oldpte)) {
 			pte_t ptent;
 			bool preserve_write = prot_numa && pte_write(oldpte);
+#ifdef CONFIG_NON_SWAP
+			struct page *page;
+#endif
 
 			/*
 			 * Avoid trapping faults against the zero or KSM
@@ -107,6 +110,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					 !(vma->vm_flags & VM_SOFTDIRTY))) {
 				ptent = pte_mkwrite(ptent);
 			}
+#ifdef CONFIG_NON_SWAP
+			page = vm_normal_page(vma, addr, oldpte);
+			if (page && PageNonSwap(page))
+				ptent = pte_wrprotect(ptent);
+#endif
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
 			pages++;
 		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 32fef7d..14d49cd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -758,14 +758,38 @@ redo:
 	ClearPageUnevictable(page);
 
 	if (page_evictable(page)) {
+#ifdef CONFIG_NON_SWAP
+		bool added = false;
+
+		if (unlikely(PageNonSwap(page))) {
+			struct zone *zone = page_zone(page);
+
+			BUG_ON(irqs_disabled());
+
+			spin_lock_irq(zone_lru_lock(zone));
+			if (likely(PageNonSwap(page))) {
+				struct lruvec *lruvec;
+
+				lruvec = mem_cgroup_page_lruvec(page,
+							zone->zone_pgdat);
+				SetPageLRU(page);
+				add_page_to_lru_list(page, lruvec,
+						     LRU_UNEVICTABLE);
+				added = true;
+			}
+			spin_unlock_irq(zone_lru_lock(zone));
+		}
+
 		/*
 		 * For evictable pages, we can use the cache.
 		 * In event of a race, worst case is we end up with an
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
+		if (!added)
+#endif
+			lru_cache_add(page);
 		is_unevictable = false;
-		lru_cache_add(page);
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable
@@ -1199,6 +1223,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					if (PageDirty(page))
 						goto keep_locked;
 
+#ifdef CONFIG_NON_SWAP
+					if (PageNonSwap(page)) {
+						try_to_free_swap(page);
+						unlock_page(page);
+						goto non_swap_keep;
+					}
+#endif
+
 					if (page_mapped(page) && mapping)
 						TRY_TO_UNMAP(page, ttu_flags);
 				}
@@ -1281,6 +1313,9 @@ cull_mlocked:
 		if (PageSwapCache(page))
 			try_to_free_swap(page);
 		unlock_page(page);
+#ifdef CONFIG_NON_SWAP
+		ClearPageNonSwap(page);
+#endif
 		list_add(&page->lru, &ret_pages);
 		continue;
 
@@ -1294,6 +1329,10 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
+#ifdef CONFIG_NON_SWAP
+		ClearPageNonSwap(page);
+non_swap_keep:
+#endif
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
