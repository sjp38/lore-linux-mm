Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A55C06B01FB
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 01:48:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U5mgKP010878
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Mar 2010 14:48:42 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EFE0D45DE52
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:48:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B213E45DE4E
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:48:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B259E18004
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:48:41 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F89DE18001
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:48:41 +0900 (JST)
Date: Tue, 30 Mar 2010 14:44:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-Id: <20100330144458.403b429c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100330143038.422459da.nishimura@mxp.nes.nec.co.jp>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
	<20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330103301.b0d20f7e.nishimura@mxp.nes.nec.co.jp>
	<20100330112301.f5bb49d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
	<20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330130648.ad559645.nishimura@mxp.nes.nec.co.jp>
	<20100330135159.025b9366.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330050050.GA3308@balbir.in.ibm.com>
	<20100330143038.422459da.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 14:30:38 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 30 Mar 2010 10:30:50 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-30 13:51:59]:
> > Yep, I tend to agree, but I need to take a closer look again at the
> > patches. 
> > 
> I agree it would be more simple. I selected the current policy because
> I was not sure whether we should move file caches(!tmpfs) with mapcount > 1,
> and, IMHO, shared memory and file caches are different for users.
> But it's O.K. for me to change current policy.
> 

To explain what I think of, I wrote a patch onto yours. (Maybe overkill for explaination ;)

Summary.

 + adding move_anon, move_file, move_shmem information to move_charge_struct.
 + adding hanlders for each pte types.
 + checking # of referer should be divided to each type.
   It's complicated to catch all cases in one "if" sentense.
 + FILE pages will be moved if it's charged against "from". no mapcount check.
   i.e. FILE pages should be moved even if it's not page-faulted.
 + ANON pages will be moved if it's really private.

For widely shared FILE, "if it's charged against "from"" is enough good limitation.



---
 mm/memcontrol.c |  265 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 170 insertions(+), 95 deletions(-)

Index: mmotm-2.6.34-Mar24/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Mar24.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Mar24/mm/memcontrol.c
@@ -263,6 +263,10 @@ static struct move_charge_struct {
 	unsigned long moved_charge;
 	unsigned long moved_swap;
 	struct task_struct *moving_task;	/* a task moving charges */
+	/* move type attributes */
+	unsigned move_anon:1;
+	unsigned move_file:1;
+	unsigned move_shmem:1;
 	wait_queue_head_t waitq;		/* a waitq for other context */
 } mc = {
 	.waitq = __WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq),
@@ -4184,6 +4188,112 @@ enum mc_target_type {
 	MC_TARGET_SWAP,
 };
 
+/*
+ * Hanlder for 4 pte types (present, nont, pte_file, swap_entry).
+ */
+static struct page *__mc_handle_present_pte(struct vm_area_struct *vma,
+					unsigned long addr, pte_t ptent)
+{
+	struct page *page = vm_normal_page(vma, addr, ptent);
+
+	if (PageAnon(page)) {
+		/* we don't move shared anon */
+		if (!mc.move_anon || page_mapcount(page) > 2)
+			return NULL;
+	} else if (page_is_file_cache(page)) {
+		if (!mc.move_file)
+			return NULL;
+	} else if (!mc.move_shmem)
+		return NULL;
+
+	if (!get_page_unless_zero(page))
+		return NULL;
+
+	return page;
+}
+
+static struct page *__mc_handle_pte_none(struct vm_area_struct *vma,
+				unsigned long addr, swp_entry_t *ent)
+{
+	struct page *page;
+	pgoff_t pgoff;
+	struct inode *inode;
+	struct address_space *mapping;
+
+	if (!vma->vm_file) /* Fully anonymous vma. */
+		return NULL;
+	inode = vma->vm_file->f_path.dentry->d_inode;
+	mapping = inode->i_mapping;
+
+	pgoff = linear_page_index(vma, addr);
+
+	if (!mapping_cap_swap_backed(mapping)) { /* usual file */
+		if (!mc.move_file)
+			return NULL;
+		page = find_get_page(mapping, pgoff);
+		/* page is moved even if it's not mapped (page-faulted) */
+	} else {
+		/* For shmem and tmpfs. We do swap accounting then... */
+		if (!mc.move_shmem)
+			return NULL;
+		mem_cgroup_get_shmem_target(inode, pgoff, &page, ent);
+	}
+	return page;
+}
+
+static struct page *__mc_handle_pte_file(struct vm_area_struct *vma,
+			unsigned long addr, pte_t ptent, swp_entry_t *ent)
+{
+	struct page *page;
+	pgoff_t pgoff;
+	struct inode *inode;
+	struct address_space *mapping;
+
+	if (!vma->vm_file) /* Fully anonymous vma. */
+		return NULL;
+	inode = vma->vm_file->f_path.dentry->d_inode;
+	mapping = inode->i_mapping;
+
+	pgoff = pte_to_pgoff(ptent);
+
+	if (!mapping_cap_swap_backed(mapping)) { /* usual file */
+		if (!mc.move_file)
+			return NULL;
+		page = find_get_page(mapping, pgoff);
+		/* page is moved even if it's not mapped (page-faulted) */
+	} else {
+		/* shmem, tmpfs file. We do swap accounting then... */
+		if (!mc.move_shmem)
+			return NULL;
+		mem_cgroup_get_shmem_target(inode, pgoff, &page, ent);
+		if (!page && !do_swap_account) {
+			ent->val = 0;
+			return NULL;
+		}
+	}
+	return page;
+}
+
+static struct page *__mc_handle_pte_swap(struct vm_area_struct *vma,
+			unsigned long addr, pte_t ptent, swp_entry_t *ent)
+{
+	int count;
+	struct page *page;
+
+	*ent = pte_to_swp_entry(ptent);
+	if (!do_swap_account || non_swap_entry(*ent))
+		return NULL;
+	count = mem_cgroup_count_swap_user(*ent, &page);
+	if (count > 1) { /* We don't move shared anon */
+		if (page)
+			put_page(page);
+		ent->val = 0;
+		return NULL;
+	}
+	return page;
+}
+
+
 static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		unsigned long addr, pte_t ptent, union mc_target *target)
 {
@@ -4191,70 +4301,27 @@ static int is_target_pte_for_mc(struct v
 	struct page_cgroup *pc;
 	int ret = 0;
 	swp_entry_t ent = { .val = 0 };
-	int usage_count = 0;
-	bool move_anon = test_bit(MOVE_CHARGE_TYPE_ANON,
-					&mc.to->move_charge_at_immigrate);
-	bool move_file = test_bit(MOVE_CHARGE_TYPE_FILE,
-					&mc.to->move_charge_at_immigrate);
-	bool move_shmem = test_bit(MOVE_CHARGE_TYPE_SHMEM,
-					&mc.to->move_charge_at_immigrate);
-	bool is_shmem = false;
 
-	if (!pte_present(ptent)) {
-		if (pte_none(ptent) || pte_file(ptent)) {
-			struct inode *inode;
-			struct address_space *mapping;
-			pgoff_t pgoff = 0;
-
-			if (!vma->vm_file)
-				return 0;
-			mapping = vma->vm_file->f_mapping;
-			if (!move_shmem || !mapping_cap_swap_backed(mapping))
-				return 0;
-
-			if (pte_none(ptent))
-				pgoff = linear_page_index(vma, addr);
-			if (pte_file(ptent))
-				pgoff = pte_to_pgoff(ptent);
-			inode = vma->vm_file->f_path.dentry->d_inode;
-			mem_cgroup_get_shmem_target(inode, pgoff, &page, &ent);
-			is_shmem = true;
-		} else if (is_swap_pte(ptent)) {
-			ent = pte_to_swp_entry(ptent);
-			if (!move_anon || non_swap_entry(ent))
-				return 0;
-			usage_count = mem_cgroup_count_swap_user(ent, &page);
-		}
-	} else {
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page || !page_mapped(page))
-			return 0;
-		if (PageAnon(page)) {
-			if (!move_anon)
-				return 0;
-		} else if (page_is_file_cache(page)) {
-			if (!move_file)
-				return 0;
-		} else {
-			if (!move_shmem)
-				return 0;
-			is_shmem = true;
-		}
-		if (!get_page_unless_zero(page))
-			return 0;
-		usage_count = page_mapcount(page);
-	}
-	if (usage_count > 1 && !is_shmem) {
-		if (page)
-			put_page(page);
+	if (pte_present(ptent))
+		page = __mc_handle_present_pte(vma, addr, ptent);
+	else if (pte_none(ptent) && (mc.move_file || mc.move_shmem))
+		page = __mc_handle_pte_none(vma, addr, &ent);
+	else if (pte_file(ptent) && (mc.move_file || mc.move_shmem))
+		page = __mc_handle_pte_file(vma, addr, ptent, &ent);
+	else if (is_swap_pte(ptent) && mc.move_anon)
+		page = __mc_handle_pte_swap(vma, addr, ptent, &ent);
+	else
 		return 0;
-	}
+
+	if (!page && !ent.val)
+		return 0;
+
 	if (page) {
 		pc = lookup_page_cgroup(page);
 		/*
 		 * Do only loose check w/o page_cgroup lock.
-		 * mem_cgroup_move_account() checks the pc is valid or not under
-		 * the lock.
+		 * mem_cgroup_move_account() checks the pc is valid or
+		 * not under the lock.
 		 */
 		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
@@ -4264,12 +4331,13 @@ static int is_target_pte_for_mc(struct v
 		if (!ret || !target)
 			put_page(page);
 	}
-	/* throught */
-	if (ent.val && do_swap_account && !ret &&
-			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
-		ret = MC_TARGET_SWAP;
-		if (target)
-			target->ent = ent;
+	/* Threre is a swap entry and a page doesn't exist or isn't charged */
+	if (!ret && ent.val) {
+		if (css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
+			ret = MC_TARGET_SWAP;
+			if (target)
+				target->ent = ent;
+		}
 	}
 	return ret;
 }
@@ -4370,6 +4438,9 @@ static void mem_cgroup_clear_mc(void)
 	mc.from = NULL;
 	mc.to = NULL;
 	mc.moving_task = NULL;
+	mc.move_anon = 0;
+	mc.move_file = 0;
+	mc.move_shmem = 0;
 	wake_up_all(&mc.waitq);
 }
 
@@ -4380,37 +4451,44 @@ static int mem_cgroup_can_attach(struct 
 {
 	int ret = 0;
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
+	struct mm_struct *mm;
+	struct mem_cgroup *from = mem_cgroup_from_task(p);
 
-	if (mem->move_charge_at_immigrate) {
-		struct mm_struct *mm;
-		struct mem_cgroup *from = mem_cgroup_from_task(p);
+	if (!mem->move_charge_at_immigrate)
+		return 0;
 
-		VM_BUG_ON(from == mem);
+	VM_BUG_ON(from == mem);
 
-		mm = get_task_mm(p);
-		if (!mm)
-			return 0;
-		/* We move charges only when we move a owner of the mm */
-		if (mm->owner == p) {
-			VM_BUG_ON(mc.from);
-			VM_BUG_ON(mc.to);
-			VM_BUG_ON(mc.precharge);
-			VM_BUG_ON(mc.moved_charge);
-			VM_BUG_ON(mc.moved_swap);
-			VM_BUG_ON(mc.moving_task);
-			mc.from = from;
-			mc.to = mem;
-			mc.precharge = 0;
-			mc.moved_charge = 0;
-			mc.moved_swap = 0;
-			mc.moving_task = current;
+	mm = get_task_mm(p);
+	if (!mm)
+		return 0;
+	if (mm->owner != p)
+		goto out;
+	/* We move charges only when we move a owner of the mm */
+	VM_BUG_ON(mc.from);
+	VM_BUG_ON(mc.to);
+	VM_BUG_ON(mc.precharge);
+	VM_BUG_ON(mc.moved_charge);
+	VM_BUG_ON(mc.moved_swap);
+	VM_BUG_ON(mc.moving_task);
+	mc.from = from;
+	mc.to = mem;
+	mc.precharge = 0;
+	mc.moved_charge = 0;
+	mc.moved_swap = 0;
+	mc.moving_task = current;
+	if (test_bit(MOVE_CHARGE_TYPE_ANON, &mem->move_charge_at_immigrate))
+		mc.move_anon = 1;
+	if (test_bit(MOVE_CHARGE_TYPE_FILE, &mem->move_charge_at_immigrate))
+		mc.move_file = 1;
+	if (test_bit(MOVE_CHARGE_TYPE_SHMEM, &mem->move_charge_at_immigrate))
+		mc.move_shmem = 1;
 
-			ret = mem_cgroup_precharge_mc(mm);
-			if (ret)
-				mem_cgroup_clear_mc();
-		}
-		mmput(mm);
-	}
+	ret = mem_cgroup_precharge_mc(mm);
+	if (ret)
+		mem_cgroup_clear_mc();
+out:
+	mmput(mm);
 	return ret;
 }
 
@@ -4500,8 +4578,6 @@ static void mem_cgroup_move_charge(struc
 	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		int ret;
-		bool move_shmem = test_bit(MOVE_CHARGE_TYPE_SHMEM,
-					&mc.to->move_charge_at_immigrate);
 		struct mm_walk mem_cgroup_move_charge_walk = {
 			.pmd_entry = mem_cgroup_move_charge_pte_range,
 			.mm = mm,
@@ -4509,8 +4585,7 @@ static void mem_cgroup_move_charge(struc
 		};
 		if (is_vm_hugetlb_page(vma))
 			continue;
-		if ((vma->vm_flags & VM_SHARED) && !move_shmem)
-			continue;
+
 		ret = walk_page_range(vma->vm_start, vma->vm_end,
 						&mem_cgroup_move_charge_walk);
 		if (ret)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
