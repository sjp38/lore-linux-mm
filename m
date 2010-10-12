Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7B9306B00B1
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 01:53:34 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C5rS3U027009
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Oct 2010 14:53:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BBD8745DE4E
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:53:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9755E45DD70
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:53:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F0CC1DB801A
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:53:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 093C41DB8016
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 14:53:24 +0900 (JST)
Date: Tue, 12 Oct 2010 14:48:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v4] memcg: reduce lock time at move charge
Message-Id: <20101012144801.51d15a02.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101012125613.1accc1bd.nishimura@mxp.nes.nec.co.jp>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007162811.c3a35be9.nishimura@mxp.nes.nec.co.jp>
	<20101007164204.83b207c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007170405.27ed964c.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007161454.84570cf9.akpm@linux-foundation.org>
	<20101008133712.2a836331.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007215556.21412ae6.akpm@linux-foundation.org>
	<20101008141201.c1e3a4e2.kamezawa.hiroyu@jp.fujitsu.com>
	<20101008194131.20b44a9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20101012125613.1accc1bd.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2010 12:56:13 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > +err_out:
> > +	for (; mt < info + num; mt++)
> > +		if (mt->type == MC_TARGET_PAGE) {
> > +			putback_lru_page(mt->val.page);
> Is this putback_lru_page() necessary ?
> is_target_pte_for_mc() doesn't isolate the page.
> 
Ok, v4 here. tested failure path and success path.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Presently, at task migration among cgroups, memory cgroup scans page tables and
moves accounting if flags are properly set.


The core code, mem_cgroup_move_charge_pte_range() does

 	pte_offset_map_lock();
	for all ptes in a page table:
		1. look into page table, find_and_get a page
		2. remove it from LRU.
		3. move charge.
		4. putback to LRU. put_page()
	pte_offset_map_unlock();

for pte entries on a 3rd level? page table.

As a planned updates, we'll support dirty-page accounting. Because move_charge()
is highly race, we need to add more check in move_charge.
For example, lock_page();-> wait_on_page_writeback();-> unlock_page();
is an candidate for new check.


This patch modifies a rountine as

	for 32 pages: pte_offset_map_lock()
		      find_and_get a page
		      record it
		      pte_offset_map_unlock()
	for all recorded pages
		      isolate it from LRU.
		      move charge
		      putback to LRU
		      put_page()
Code size change is:
(Before)
[kamezawa@bluextal mmotm-1008]$ size mm/memcontrol.o
   text    data     bss     dec     hex filename
  28247    7685    4100   40032    9c60 mm/memcontrol.o
(After)
[kamezawa@bluextal mmotm-1008]$ size mm/memcontrol.o
   text    data     bss     dec     hex filename
  28591    7685    4100   40376    9db8 mm/memcontrol.o

Easy Bencmark score.

Moving 2Gbytes anonymous memory task between cgroup/A and cgroup/B.
 <===== shows a function under pte_lock.
Before Patch.

real    0m42.346s
user    0m0.002s
sys     0m39.668s

    13.88%  swap_task.sh  [kernel.kallsyms]  [k] put_page	     <=====
    10.37%  swap_task.sh  [kernel.kallsyms]  [k] isolate_lru_page    <===== 
    10.25%  swap_task.sh  [kernel.kallsyms]  [k] is_target_pte_for_mc  <=====
     7.85%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_move_account <=====
     7.63%  swap_task.sh  [kernel.kallsyms]  [k] lookup_page_cgroup      <=====
     6.96%  swap_task.sh  [kernel.kallsyms]  [k] ____pagevec_lru_add
     6.43%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_del_lru_list
     6.31%  swap_task.sh  [kernel.kallsyms]  [k] putback_lru_page
     5.28%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_add_lru_list
     3.58%  swap_task.sh  [kernel.kallsyms]  [k] __lru_cache_add
     3.57%  swap_task.sh  [kernel.kallsyms]  [k] _raw_spin_lock_irq
     3.06%  swap_task.sh  [kernel.kallsyms]  [k] release_pages
     2.35%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_get_reclaim_stat_from_page
     2.31%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_move_charge_pte_range
     1.80%  swap_task.sh  [kernel.kallsyms]  [k] memcg_check_events
     1.59%  swap_task.sh  [kernel.kallsyms]  [k] page_evictable
     1.55%  swap_task.sh  [kernel.kallsyms]  [k] vm_normal_page
     1.53%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_charge_statistics

After patch:

real    0m43.440s
user    0m0.000s
sys     0m40.704s
    13.68%  swap_task.sh  [kernel.kallsyms]  [k] is_target_pte_for_mc <====
    13.29%  swap_task.sh  [kernel.kallsyms]  [k] put_page
    10.34%  swap_task.sh  [kernel.kallsyms]  [k] isolate_lru_page
     7.48%  swap_task.sh  [kernel.kallsyms]  [k] lookup_page_cgroup
     7.42%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_move_account
     6.98%  swap_task.sh  [kernel.kallsyms]  [k] ____pagevec_lru_add
     6.15%  swap_task.sh  [kernel.kallsyms]  [k] putback_lru_page
     5.46%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_add_lru_list
     5.00%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_del_lru_list
     3.38%  swap_task.sh  [kernel.kallsyms]  [k] _raw_spin_lock_irq
     3.31%  swap_task.sh  [kernel.kallsyms]  [k] __lru_cache_add
     3.02%  swap_task.sh  [kernel.kallsyms]  [k] release_pages
     2.24%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_get_reclaim_stat_from_page
     2.04%  swap_task.sh  [kernel.kallsyms]  [k] mem_cgroup_move_charge_pte_range
     1.84%  swap_task.sh  [kernel.kallsyms]  [k] memcg_check_events

I think this is not very bad. 

Changelog: v3->v4
 - fixed bug in error path (at resource shortage, putback is not necessary)

Changelog: v2->v3
 - rebased onto mmotm 1008
 - redecued the number of loops.
 - clean ups. reduced unnecessary switch, break, continue, goto.
 - added kzalloc again.

Changelog: v1->v2
 - removed kzalloc() of mc_target. preallocate it on "mc"

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  127 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 74 insertions(+), 53 deletions(-)

Index: mmotm-1008/mm/memcontrol.c
===================================================================
--- mmotm-1008.orig/mm/memcontrol.c
+++ mmotm-1008/mm/memcontrol.c
@@ -276,6 +276,21 @@ enum move_type {
 	NR_MOVE_TYPE,
 };
 
+enum mc_target_type {
+	MC_TARGET_NONE, /* used as failure code(0) */
+	MC_TARGET_PAGE,
+	MC_TARGET_SWAP,
+};
+
+struct mc_target {
+	enum mc_target_type type;
+	union {
+		struct page *page;
+		swp_entry_t ent;
+	} val;
+};
+#define MC_MOVE_ONCE	(16)
+
 /* "mc" and its members are protected by cgroup_mutex */
 static struct move_charge_struct {
 	spinlock_t	  lock; /* for from, to, moving_task */
@@ -4479,16 +4494,7 @@ one_by_one:
  *
  * Called with pte lock held.
  */
-union mc_target {
-	struct page	*page;
-	swp_entry_t	ent;
-};
 
-enum mc_target_type {
-	MC_TARGET_NONE,	/* not used */
-	MC_TARGET_PAGE,
-	MC_TARGET_SWAP,
-};
 
 static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
 						unsigned long addr, pte_t ptent)
@@ -4565,7 +4571,7 @@ static struct page *mc_handle_file_pte(s
 }
 
 static int is_target_pte_for_mc(struct vm_area_struct *vma,
-		unsigned long addr, pte_t ptent, union mc_target *target)
+		unsigned long addr, pte_t ptent, struct mc_target *target)
 {
 	struct page *page = NULL;
 	struct page_cgroup *pc;
@@ -4590,8 +4596,10 @@ static int is_target_pte_for_mc(struct v
 		 */
 		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
-			if (target)
-				target->page = page;
+			if (target) {
+				target->val.page = page;
+				target->type = ret;
+			}
 		}
 		if (!ret || !target)
 			put_page(page);
@@ -4600,8 +4608,10 @@ static int is_target_pte_for_mc(struct v
 	if (ent.val && !ret &&
 			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
 		ret = MC_TARGET_SWAP;
-		if (target)
-			target->ent = ent;
+		if (target) {
+			target->val.ent = ent;
+			target->type = ret;
+		}
 	}
 	return ret;
 }
@@ -4761,68 +4771,79 @@ static int mem_cgroup_move_charge_pte_ra
 {
 	int ret = 0;
 	struct vm_area_struct *vma = walk->private;
+	struct mc_target *info, *mt;
+	struct page_cgroup *pc;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int num;
+
+	info = kzalloc(sizeof(struct mc_target) *MC_MOVE_ONCE, GFP_KERNEL);
+	if (!info)
+		return -ENOMEM;
 
 retry:
+	/*
+	 * We want to move account without taking pte_offset_map_lock() because
+	 * "move" may need to wait for some event completion.(in future)
+	 * At 1st half, scan page table and grab pages.  At 2nd half, remove it
+	 * from LRU and overwrite page_cgroup's information.
+	 */
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; addr += PAGE_SIZE) {
+	for (num = 0; num < MC_MOVE_ONCE && addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);
-		union mc_target target;
-		int type;
-		struct page *page;
-		struct page_cgroup *pc;
-		swp_entry_t ent;
+		ret = is_target_pte_for_mc(vma, addr, ptent, info + num);
+		if (!ret)
+			continue;
+		num++;
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
 
-		if (!mc.precharge)
-			break;
+	mt = info;
 
-		type = is_target_pte_for_mc(vma, addr, ptent, &target);
-		switch (type) {
+	while (mc.precharge < num) {
+		ret = mem_cgroup_do_precharge(1);
+		if (ret)
+			goto err_out;
+	}
+
+	for (ret = 0; mt < info + num; mt++) {
+		switch (mt->type) {
 		case MC_TARGET_PAGE:
-			page = target.page;
-			if (isolate_lru_page(page))
-				goto put;
-			pc = lookup_page_cgroup(page);
-			if (!mem_cgroup_move_account(pc,
+			if (!isolate_lru_page(mt->val.page)) {
+				pc = lookup_page_cgroup(mt->val.page);
+				if (!mem_cgroup_move_account(pc,
 						mc.from, mc.to, false)) {
-				mc.precharge--;
-				/* we uncharge from mc.from later. */
-				mc.moved_charge++;
+					mc.precharge--;
+					/* we uncharge from mc.from later. */
+					mc.moved_charge++;
+				}
+				putback_lru_page(mt->val.page);
 			}
-			putback_lru_page(page);
-put:			/* is_target_pte_for_mc() gets the page */
-			put_page(page);
+			put_page(mt->val.page);
 			break;
 		case MC_TARGET_SWAP:
-			ent = target.ent;
-			if (!mem_cgroup_move_swap_account(ent,
+			if (!mem_cgroup_move_swap_account(mt->val.ent,
 						mc.from, mc.to, false)) {
-				mc.precharge--;
 				/* we fixup refcnts and charges later. */
+				mc.precharge--;
 				mc.moved_swap++;
 			}
-			break;
 		default:
 			break;
 		}
 	}
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
-
-	if (addr != end) {
-		/*
-		 * We have consumed all precharges we got in can_attach().
-		 * We try charge one by one, but don't do any additional
-		 * charges to mc.to if we have failed in charge once in attach()
-		 * phase.
-		 */
-		ret = mem_cgroup_do_precharge(1);
-		if (!ret)
-			goto retry;
-	}
 
+	if (addr != end)
+		goto retry;
+out:
+	kfree(info);
 	return ret;
+err_out:
+	for (; mt < info + num; mt++)
+		if (mt->type == MC_TARGET_PAGE)
+			put_page(mt->val.page);
+	goto out;
 }
 
 static void mem_cgroup_move_charge(struct mm_struct *mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
