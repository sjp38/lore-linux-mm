Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 53F4C6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 03:47:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R7ltWk032018
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Oct 2009 16:47:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BF7245DE50
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:47:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2159C45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:47:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 089561DB8037
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:47:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C1231DB803E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 16:47:54 +0900 (JST)
Date: Tue, 27 Oct 2009 16:45:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
Message-Id: <20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
References: <hav57c$rso$1@ger.gmane.org>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
	<20091027153429.b36866c4.minchan.kim@barrios-desktop>
	<20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 15:55:26 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> >> Hmm.
> >> I wonder why we consider VM size for OOM kiling.
> >> How about RSS size?
> >>
> >
> > Maybe the current code assumes "Tons of swap have been generated, already" if
> > oom-kill is invoked. Then, just using mm->anon_rss will not be correct.
> >
> > Hm, should we count # of swap entries reference from mm ?....
> 
> In Vedran case, he didn't use swap. So, Only considering vm is the problem.
> I think it would be better to consider both RSS + # of swap entries as
> Kosaki mentioned.
> 
Then, maybe this kind of patch is necessary.
This is on 2.6.31...then I may have to rebase this to mmotom.
Added more CCs.

Vedran, I'm glad if you can test this patch.


==
Now, oom-killer's score uses mm->total_vm as its base value.
But, in these days, applications like GUI program tend to use
much shared libraries and total_vm grows too high even when
pages are not fully mapped.

For example, running a program "mmap" which allocates 1 GBbytes of
anonymous memory, oom_score top 10 on system will be..

 score  PID     name
 89924	3938	mixer_applet2
 90210	3942	tomboy
 94753	3936	clock-applet
 101994	3919	pulseaudio
 113525	4028	gnome-terminal
 127340	1	init
 128177	3871	nautilus
 151003	11515	bash
 256944	11653	mmap <-----------------use 1G of anon
 425561	3829	gnome-session

No one believes gnome-session is more guilty than "mmap".

Instead of total_vm, we should use anon/file/swap usage of a process, I think.
This patch adds mm->swap_usage and calculate oom_score based on
  anon_rss + file_rss + swap_usage.
Considering usual applications, this will be much better information than
total_vm. After this patch, the score on my desktop is

score   PID     name
4033	3176	gnome-panel
4077	3113	xinit
4526	3190	python
4820	3161	gnome-settings-
4989	3289	gnome-terminal
7105	3271	tomboy
8427	3177	nautilus
17549	3140	gnome-session
128501	3299	bash
256106	3383	mmap

This order is not bad, I think.

Note: This adss new counter...then new cost is added.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm_types.h |    1 +
 mm/memory.c              |   29 +++++++++++++++++++++--------
 mm/oom_kill.c            |   12 +++++++++---
 mm/rmap.c                |    1 +
 mm/swapfile.c            |    1 +
 5 files changed, 33 insertions(+), 11 deletions(-)

Index: linux-2.6.31/include/linux/mm_types.h
===================================================================
--- linux-2.6.31.orig/include/linux/mm_types.h
+++ linux-2.6.31/include/linux/mm_types.h
@@ -228,6 +228,7 @@ struct mm_struct {
 	 */
 	mm_counter_t _file_rss;
 	mm_counter_t _anon_rss;
+	mm_counter_t _swap_usage;
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
Index: linux-2.6.31/mm/memory.c
===================================================================
--- linux-2.6.31.orig/mm/memory.c
+++ linux-2.6.31/mm/memory.c
@@ -361,12 +361,15 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	return 0;
 }
 
-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
+static inline
+void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss, int swaps)
 {
 	if (file_rss)
 		add_mm_counter(mm, file_rss, file_rss);
 	if (anon_rss)
 		add_mm_counter(mm, anon_rss, anon_rss);
+	if (swaps)
+		add_mm_counter(mm, swap_usage, swaps);
 }
 
 /*
@@ -562,6 +565,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 						 &src_mm->mmlist);
 				spin_unlock(&mmlist_lock);
 			}
+			if (!is_migration_entry(entry))
+				rss[2]++;
 			if (is_write_migration_entry(entry) &&
 					is_cow_mapping(vm_flags)) {
 				/*
@@ -611,10 +616,10 @@ static int copy_pte_range(struct mm_stru
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
-	int rss[2];
+	int rss[3];
 
 again:
-	rss[1] = rss[0] = 0;
+	rss[2] = rss[1] = rss[0] = 0;
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
 		return -ENOMEM;
@@ -645,7 +650,7 @@ again:
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(src_pte - 1);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
+	add_mm_rss(dst_mm, rss[0], rss[1], rss[2]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
 	cond_resched();
 	if (addr != end)
@@ -769,6 +774,7 @@ static unsigned long zap_pte_range(struc
 	spinlock_t *ptl;
 	int file_rss = 0;
 	int anon_rss = 0;
+	int swaps = 0;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -838,13 +844,19 @@ static unsigned long zap_pte_range(struc
 		if (pte_file(ptent)) {
 			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
 				print_bad_pte(vma, addr, ptent, NULL);
-		} else if
-		  (unlikely(!free_swap_and_cache(pte_to_swp_entry(ptent))))
-			print_bad_pte(vma, addr, ptent, NULL);
+		} else {
+			swp_entry_t entry = pte_to_swp_entry(ptent);
+
+			if (!is_migration_entry(entry))
+				swaps++;
+
+			if (unlikely(!free_swap_and_cache(entry)))
+				print_bad_pte(vma, addr, ptent, NULL);
+		}
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
-	add_mm_rss(mm, file_rss, anon_rss);
+	add_mm_rss(mm, file_rss, anon_rss, swaps);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
@@ -2573,6 +2585,7 @@ static int do_swap_page(struct mm_struct
 	 */
 
 	inc_mm_counter(mm, anon_rss);
+	dec_mm_counter(mm, swap_usage);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
Index: linux-2.6.31/mm/rmap.c
===================================================================
--- linux-2.6.31.orig/mm/rmap.c
+++ linux-2.6.31/mm/rmap.c
@@ -834,6 +834,7 @@ static int try_to_unmap_one(struct page 
 				spin_unlock(&mmlist_lock);
 			}
 			dec_mm_counter(mm, anon_rss);
+			inc_mm_counter(mm, swap_usage);
 		} else if (PAGE_MIGRATION) {
 			/*
 			 * Store the pfn of the page in a special migration
Index: linux-2.6.31/mm/swapfile.c
===================================================================
--- linux-2.6.31.orig/mm/swapfile.c
+++ linux-2.6.31/mm/swapfile.c
@@ -830,6 +830,7 @@ static int unuse_pte(struct vm_area_stru
 	}
 
 	inc_mm_counter(vma->vm_mm, anon_rss);
+	dec_mm_counter(vma->vm_mm, swap_usage);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
Index: linux-2.6.31/mm/oom_kill.c
===================================================================
--- linux-2.6.31.orig/mm/oom_kill.c
+++ linux-2.6.31/mm/oom_kill.c
@@ -69,7 +69,8 @@ unsigned long badness(struct task_struct
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = mm->total_vm;
+	points = get_mm_counter(mm, anon_rss) + get_mm_counter(mm, file_rss)
+		 + get_mm_counter(mm, swap_usage);
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -92,8 +93,13 @@ unsigned long badness(struct task_struct
 	 */
 	list_for_each_entry(child, &p->children, sibling) {
 		task_lock(child);
-		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
+		if (child->mm != mm && child->mm) {
+			unsigned long cpoint;
+			/* At considering child, we don't count swap */
+			cpoint = get_mm_counter(child->mm, anon_rss) +
+				 get_mm_counter(child->mm, file_rss);
+			points += cpoint/2 + 1;
+		}
 		task_unlock(child);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
