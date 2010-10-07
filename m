Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8116F6B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 04:09:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9789XaQ010863
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 17:09:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2476C45DE58
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 17:09:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 970D245DE53
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 17:09:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47D10E18002
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 17:09:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD9DA1DB803B
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 17:09:26 +0900 (JST)
Date: Thu, 7 Oct 2010 17:04:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v2] memcg: reduce lock time at move charge (Was Re: [PATCH
 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-Id: <20101007170405.27ed964c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101007164204.83b207c6.kamezawa.hiroyu@jp.fujitsu.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007162811.c3a35be9.nishimura@mxp.nes.nec.co.jp>
	<20101007164204.83b207c6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Oct 2010 16:42:04 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > If so, how about adding a new member(struct mc_target *targe) to move_charge_struct,
> > and allocate/free it at mem_cgroup_move_charge() ?
> > 
> Hmm, sounds nice.
> 

Here.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, at task migration among cgroup, memory cgroup scans page table and moving
account if flags are properly set.

The core code, mem_cgroup_move_charge_pte_range() does

 	pte_offset_map_lock();
	for all ptes in a page table:
		1. look into page table, find_and_get a page
		2. remove it from LRU.
		3. move charge.
		4. putback to LRU. put_page()
	pte_offset_map_unlock();

for pte entries on a 3rd level? page table.

This pte_offset_map_lock seems a bit long. This patch modifies a rountine as

	for 32 pages: pte_offset_map_lock()
		      find_and_get a page
		      record it
		      pte_offset_map_unlock()
	for all recorded pages
		      isolate it from LRU.
		      move charge
		      putback to LRU
	for all recorded pages
		      put_page()

Changelog: v1->v2
 - removed kzalloc() of mc_target. preallocate it on "mc"

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   95 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 59 insertions(+), 36 deletions(-)

Index: mmotm-0928/mm/memcontrol.c
===================================================================
--- mmotm-0928.orig/mm/memcontrol.c
+++ mmotm-0928/mm/memcontrol.c
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
+		swp_entry_t	ent;
+	} val;
+};
+#define MC_MOVE_ONCE	(32)
+
 /* "mc" and its members are protected by cgroup_mutex */
 static struct move_charge_struct {
 	spinlock_t	  lock; /* for from, to, moving_task */
@@ -284,6 +299,7 @@ static struct move_charge_struct {
 	unsigned long precharge;
 	unsigned long moved_charge;
 	unsigned long moved_swap;
+	struct mc_target target[MC_MOVE_ONCE];
 	struct task_struct *moving_task;	/* a task moving charges */
 	wait_queue_head_t waitq;		/* a waitq for other context */
 } mc = {
@@ -291,6 +307,7 @@ static struct move_charge_struct {
 	.waitq = __WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq),
 };
 
+
 static bool move_anon(void)
 {
 	return test_bit(MOVE_CHARGE_TYPE_ANON,
@@ -4475,16 +4492,7 @@ one_by_one:
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
@@ -4561,7 +4569,7 @@ static struct page *mc_handle_file_pte(s
 }
 
 static int is_target_pte_for_mc(struct vm_area_struct *vma,
-		unsigned long addr, pte_t ptent, union mc_target *target)
+		unsigned long addr, pte_t ptent, struct mc_target *target)
 {
 	struct page *page = NULL;
 	struct page_cgroup *pc;
@@ -4587,7 +4595,7 @@ static int is_target_pte_for_mc(struct v
 		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
 			if (target)
-				target->page = page;
+				target->val.page = page;
 		}
 		if (!ret || !target)
 			put_page(page);
@@ -4597,8 +4605,10 @@ static int is_target_pte_for_mc(struct v
 			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
-			target->ent = ent;
+			target->val.ent = ent;
 	}
+	if (target)
+		target->type = ret;
 	return ret;
 }
 
@@ -4759,26 +4769,42 @@ static int mem_cgroup_move_charge_pte_ra
 	struct vm_area_struct *vma = walk->private;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int index, num;
 
 retry:
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; addr += PAGE_SIZE) {
+	for (num = 0; num < MC_MOVE_ONCE && addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);
-		union mc_target target;
-		int type;
+		ret = is_target_pte_for_mc(vma, addr, ptent, &mc.target[num]);
+		if (!ret)
+			continue;
+		mc.target[num++].type = ret;
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
+	ret = 0;
+	index = 0;
+	do {
+		struct mc_target *mt;
 		struct page *page;
 		struct page_cgroup *pc;
 		swp_entry_t ent;
 
-		if (!mc.precharge)
-			break;
+		if (!mc.precharge) {
+			ret = mem_cgroup_do_precharge(1);
+			if (ret)
+				goto out;
+			continue;
+		}
+
+		mt = &mc.target[index++];
 
-		type = is_target_pte_for_mc(vma, addr, ptent, &target);
-		switch (type) {
+		switch (mt->type) {
 		case MC_TARGET_PAGE:
-			page = target.page;
+			page = mt->val.page;
 			if (isolate_lru_page(page))
-				goto put;
+				break;
 			pc = lookup_page_cgroup(page);
 			if (!mem_cgroup_move_account(pc,
 						mc.from, mc.to, false)) {
@@ -4787,11 +4813,9 @@ retry:
 				mc.moved_charge++;
 			}
 			putback_lru_page(page);
-put:			/* is_target_pte_for_mc() gets the page */
-			put_page(page);
 			break;
 		case MC_TARGET_SWAP:
-			ent = target.ent;
+			ent = mt->val.ent;
 			if (!mem_cgroup_move_swap_account(ent,
 						mc.from, mc.to, false)) {
 				mc.precharge--;
@@ -4802,21 +4826,20 @@ put:			/* is_target_pte_for_mc() gets th
 		default:
 			break;
 		}
+	} while (index < num);
+out:
+	for (index = 0; index < num; index++) {
+		if (mc.target[index].type == MC_TARGET_PAGE)
+			put_page(mc.target[index].val.page);
+		mc.target[index].type = MC_TARGET_NONE;
 	}
-	pte_unmap_unlock(pte - 1, ptl);
+
+	if (ret)
+		return ret;
 	cond_resched();
 
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
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
