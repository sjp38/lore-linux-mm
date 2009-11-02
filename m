Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 803766B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:28:56 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA27SsGT003946
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Nov 2009 16:28:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CF91345DE5D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:28:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9398345DE53
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:28:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62996E1800A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:28:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E4D8F1DB805F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:28:52 +0900 (JST)
Date: Mon, 2 Nov 2009 16:26:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm][PATCH 3/6] oom-killer: count lowmem rss
Message-Id: <20091102162617.9d07e05f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Count lowmem rss per mm_struct. Lowmem here means...

   for NUMA, pages in a zone < policy_zone.
   for HIGHMEM x86, pages in NORMAL zone.
   for others, all pages are lowmem.

Now, lower_zone_protection[] works very well for protecting lowmem but
possiblity of lowmem-oom is not 0 even if under good protection in the kernel.
(As fact, it's can be configured by sysctl. When we keep it high, there
 will be tons of not-for-use memory but system will be protected against
 rare event of lowmem-oom.)
Considering a x86 system with 2G of memory, NORMAL is 856MB and HIGHMEM is 1.1GB
...we can't keep lower_zone_protection too high.

This patch counts num of lowmem used for user process's page-cache memory.
Later patch will use this vaule for OOM calculation.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mempolicy.h |   21 +++++++++++++++++++++
 include/linux/mm_types.h  |    1 +
 mm/memory.c               |   32 ++++++++++++++++++++++++++------
 mm/rmap.c                 |    2 ++
 mm/swapfile.c             |    2 ++
 5 files changed, 52 insertions(+), 6 deletions(-)

Index: mmotm-2.6.32-Nov2/include/linux/mempolicy.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mempolicy.h
+++ mmotm-2.6.32-Nov2/include/linux/mempolicy.h
@@ -240,6 +240,13 @@ static inline int vma_migratable(struct 
 	return 1;
 }
 
+static inline int is_lowmem_page(struct page *page)
+{
+	if (unlikely(page_zonenum(page) < policy_zone))
+		return 1;
+	return 0;
+}
+
 #else
 
 struct mempolicy {};
@@ -356,6 +363,20 @@ static inline int mpol_to_str(char *buff
 }
 #endif
 
+#ifdef CONFIG_HIGHMEM
+static inline int is_lowmem_page(struct page *page)
+{
+	if (page_zonenum(page) == ZONE_HIGHMEM)
+		return 0;
+	return 1;
+}
+#else
+static inline int is_lowmem_page(struct page *page)
+{
+	return 1;
+}
+#endif
+
 #endif /* CONFIG_NUMA */
 #endif /* __KERNEL__ */
 
Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
@@ -229,6 +229,7 @@ struct mm_struct {
 	mm_counter_t _file_rss;
 	mm_counter_t _anon_rss;
 	mm_counter_t _swap_usage;
+	mm_counter_t _low_rss;
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
Index: mmotm-2.6.32-Nov2/mm/memory.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/memory.c
+++ mmotm-2.6.32-Nov2/mm/memory.c
@@ -376,8 +376,9 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	return 0;
 }
 
-static inline void
-add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss, int swap_usage)
+
+static inline void add_mm_rss(struct mm_struct *mm,
+	int file_rss, int anon_rss, int swap_usage, int low_rss)
 {
 	if (file_rss)
 		add_mm_counter(mm, file_rss, file_rss);
@@ -385,6 +386,8 @@ add_mm_rss(struct mm_struct *mm, int fil
 		add_mm_counter(mm, anon_rss, anon_rss);
 	if (swap_usage)
 		add_mm_counter(mm, swap_usage, swap_usage);
+	if (low_rss)
+		add_mm_counter(mm, low_rss, low_rss);
 }
 
 /*
@@ -638,6 +641,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		get_page(page);
 		page_dup_rmap(page);
 		rss[PageAnon(page)]++;
+		if (is_lowmem_page(page))
+			rss[3]++;
 	}
 
 out_set_pte:
@@ -653,11 +658,11 @@ static int copy_pte_range(struct mm_stru
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
-	int rss[3];
+	int rss[4];
 	swp_entry_t entry = (swp_entry_t){0};
 
 again:
-	rss[2] = rss[1] = rss[0] = 0;
+	rss[3] = rss[2] = rss[1] = rss[0] = 0;
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
 		return -ENOMEM;
@@ -693,7 +698,7 @@ again:
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(orig_src_pte);
-	add_mm_rss(dst_mm, rss[0], rss[1], rss[2]);
+	add_mm_rss(dst_mm, rss[0], rss[1], rss[2], rss[3]);
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
@@ -824,6 +829,7 @@ static unsigned long zap_pte_range(struc
 	int file_rss = 0;
 	int anon_rss = 0;
 	int swap_usage = 0;
+	int low_rss = 0;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -878,6 +884,8 @@ static unsigned long zap_pte_range(struc
 					mark_page_accessed(page);
 				file_rss--;
 			}
+			if (is_lowmem_page(page))
+				low_rss--;
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
@@ -904,7 +912,7 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
-	add_mm_rss(mm, file_rss, anon_rss, swap_usage);
+	add_mm_rss(mm, file_rss, anon_rss, swap_usage, low_rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
@@ -1539,6 +1547,8 @@ static int insert_page(struct vm_area_st
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
 	inc_mm_counter(mm, file_rss);
+	if (is_lowmem_page(page))
+		inc_mm_counter(mm, low_rss);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2179,6 +2189,10 @@ gotten:
 			}
 		} else
 			inc_mm_counter(mm, anon_rss);
+		if (old_page && is_lowmem_page(old_page))
+			dec_mm_counter(mm, low_rss);
+		if (is_lowmem_page(new_page))
+			inc_mm_counter(mm, low_rss);
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2607,6 +2621,8 @@ static int do_swap_page(struct mm_struct
 
 	inc_mm_counter(mm, anon_rss);
 	dec_mm_counter(mm, swap_usage);
+	if (is_lowmem_page(page))
+		inc_mm_counter(mm, low_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2691,6 +2707,8 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 
 	inc_mm_counter(mm, anon_rss);
+	if (is_lowmem_page(page))
+		inc_mm_counter(mm, low_rss);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2854,6 +2872,8 @@ static int __do_fault(struct mm_struct *
 				get_page(dirty_page);
 			}
 		}
+		if (is_lowmem_page(page))
+			inc_mm_counter(mm, low_rss);
 		set_pte_at(mm, address, page_table, entry);
 
 		/* no need to invalidate: a not-present page won't be cached */
Index: mmotm-2.6.32-Nov2/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/rmap.c
+++ mmotm-2.6.32-Nov2/mm/rmap.c
@@ -854,6 +854,8 @@ static int try_to_unmap_one(struct page 
 	} else
 		dec_mm_counter(mm, file_rss);
 
+	if (is_lowmem_page(page))
+		dec_mm_counter(mm, low_rss);
 
 	page_remove_rmap(page);
 	page_cache_release(page);
Index: mmotm-2.6.32-Nov2/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/swapfile.c
+++ mmotm-2.6.32-Nov2/mm/swapfile.c
@@ -838,6 +838,8 @@ static int unuse_pte(struct vm_area_stru
 
 	inc_mm_counter(vma->vm_mm, anon_rss);
 	dec_mm_counter(vma->vm_mm, swap_usage);
+	if (is_lowmem_page(page))
+		inc_mm_counter(vma->vm_mm, low_rss);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
