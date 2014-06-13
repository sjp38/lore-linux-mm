Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1226B0070
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 00:24:19 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so905494pbc.31
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:24:19 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ey3si712180pbc.244.2014.06.12.21.24.18
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 21:24:18 -0700 (PDT)
Date: Fri, 13 Jun 2014 12:23:50 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 80/178] mm/memcontrol.c:6847:184: warning: value
 computed is not used
Message-ID: <539a7cd6.ZRstAxZfZ55n3DRv%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
commit: 5e2db44974d6ea928e257ac99031b5c5bf2ddaa4 [80/178] memcg: separate mem_cgroup_move_charge_pte_range()
config: make ARCH=i386 allmodconfig

All warnings:

   mm/memcontrol.c: In function 'mem_cgroup_count_precharge_pmd':
   mm/memcontrol.c:6674:3: error: 'skip' undeclared (first use in this function)
      skip->control = PTWALK_DOWN;
      ^
   mm/memcontrol.c:6674:3: note: each undeclared identifier is reported only once for each function it appears in
   mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte':
>> mm/memcontrol.c:6847:184: warning: value computed is not used [-Wunused-value]
      pte_offset_map(walk->pmd, addr & PMD_MASK);
                                                                                                                                                                                           ^
   mm/memcontrol.c: In function 'mem_cgroup_move_charge_pmd':
   mm/memcontrol.c:6905:37: error: 'ptl' undeclared (first use in this function)
     if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
                                        ^

vim +6847 mm/memcontrol.c

  6668	
  6669		if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
  6670			if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
  6671				mc.precharge += HPAGE_PMD_NR;
  6672			spin_unlock(ptl);
  6673		} else
> 6674			skip->control = PTWALK_DOWN;
  6675		return 0;
  6676	}
  6677	
  6678	static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
  6679	{
  6680		unsigned long precharge;
  6681		struct vm_area_struct *vma;
  6682	
  6683		struct mm_walk mem_cgroup_count_precharge_walk = {
  6684			.pmd_entry = mem_cgroup_count_precharge_pmd,
  6685			.pte_entry = mem_cgroup_count_precharge_pte,
  6686			.mm = mm,
  6687		};
  6688		down_read(&mm->mmap_sem);
  6689		for (vma = mm->mmap; vma; vma = vma->vm_next)
  6690			walk_page_vma(vma, &mem_cgroup_count_precharge_walk);
  6691		up_read(&mm->mmap_sem);
  6692	
  6693		precharge = mc.precharge;
  6694		mc.precharge = 0;
  6695	
  6696		return precharge;
  6697	}
  6698	
  6699	static int mem_cgroup_precharge_mc(struct mm_struct *mm)
  6700	{
  6701		unsigned long precharge = mem_cgroup_count_precharge(mm);
  6702	
  6703		VM_BUG_ON(mc.moving_task);
  6704		mc.moving_task = current;
  6705		return mem_cgroup_do_precharge(precharge);
  6706	}
  6707	
  6708	/* cancels all extra charges on mc.from and mc.to, and wakes up all waiters. */
  6709	static void __mem_cgroup_clear_mc(void)
  6710	{
  6711		struct mem_cgroup *from = mc.from;
  6712		struct mem_cgroup *to = mc.to;
  6713		int i;
  6714	
  6715		/* we must uncharge all the leftover precharges from mc.to */
  6716		if (mc.precharge) {
  6717			__mem_cgroup_cancel_charge(mc.to, mc.precharge);
  6718			mc.precharge = 0;
  6719		}
  6720		/*
  6721		 * we didn't uncharge from mc.from at mem_cgroup_move_account(), so
  6722		 * we must uncharge here.
  6723		 */
  6724		if (mc.moved_charge) {
  6725			__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
  6726			mc.moved_charge = 0;
  6727		}
  6728		/* we must fixup refcnts and charges */
  6729		if (mc.moved_swap) {
  6730			/* uncharge swap account from the old cgroup */
  6731			if (!mem_cgroup_is_root(mc.from))
  6732				res_counter_uncharge(&mc.from->memsw,
  6733							PAGE_SIZE * mc.moved_swap);
  6734	
  6735			for (i = 0; i < mc.moved_swap; i++)
  6736				css_put(&mc.from->css);
  6737	
  6738			if (!mem_cgroup_is_root(mc.to)) {
  6739				/*
  6740				 * we charged both to->res and to->memsw, so we should
  6741				 * uncharge to->res.
  6742				 */
  6743				res_counter_uncharge(&mc.to->res,
  6744							PAGE_SIZE * mc.moved_swap);
  6745			}
  6746			/* we've already done css_get(mc.to) */
  6747			mc.moved_swap = 0;
  6748		}
  6749		memcg_oom_recover(from);
  6750		memcg_oom_recover(to);
  6751		wake_up_all(&mc.waitq);
  6752	}
  6753	
  6754	static void mem_cgroup_clear_mc(void)
  6755	{
  6756		struct mem_cgroup *from = mc.from;
  6757	
  6758		/*
  6759		 * we must clear moving_task before waking up waiters at the end of
  6760		 * task migration.
  6761		 */
  6762		mc.moving_task = NULL;
  6763		__mem_cgroup_clear_mc();
  6764		spin_lock(&mc.lock);
  6765		mc.from = NULL;
  6766		mc.to = NULL;
  6767		spin_unlock(&mc.lock);
  6768		mem_cgroup_end_move(from);
  6769	}
  6770	
  6771	static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
  6772					 struct cgroup_taskset *tset)
  6773	{
  6774		struct task_struct *p = cgroup_taskset_first(tset);
  6775		int ret = 0;
  6776		struct mem_cgroup *memcg = mem_cgroup_from_css(css);
  6777		unsigned long move_charge_at_immigrate;
  6778	
  6779		/*
  6780		 * We are now commited to this value whatever it is. Changes in this
  6781		 * tunable will only affect upcoming migrations, not the current one.
  6782		 * So we need to save it, and keep it going.
  6783		 */
  6784		move_charge_at_immigrate  = memcg->move_charge_at_immigrate;
  6785		if (move_charge_at_immigrate) {
  6786			struct mm_struct *mm;
  6787			struct mem_cgroup *from = mem_cgroup_from_task(p);
  6788	
  6789			VM_BUG_ON(from == memcg);
  6790	
  6791			mm = get_task_mm(p);
  6792			if (!mm)
  6793				return 0;
  6794			/* We move charges only when we move a owner of the mm */
  6795			if (mm->owner == p) {
  6796				VM_BUG_ON(mc.from);
  6797				VM_BUG_ON(mc.to);
  6798				VM_BUG_ON(mc.precharge);
  6799				VM_BUG_ON(mc.moved_charge);
  6800				VM_BUG_ON(mc.moved_swap);
  6801				mem_cgroup_start_move(from);
  6802				spin_lock(&mc.lock);
  6803				mc.from = from;
  6804				mc.to = memcg;
  6805				mc.immigrate_flags = move_charge_at_immigrate;
  6806				spin_unlock(&mc.lock);
  6807				/* We set mc.moving_task later */
  6808	
  6809				ret = mem_cgroup_precharge_mc(mm);
  6810				if (ret)
  6811					mem_cgroup_clear_mc();
  6812			}
  6813			mmput(mm);
  6814		}
  6815		return ret;
  6816	}
  6817	
  6818	static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
  6819					     struct cgroup_taskset *tset)
  6820	{
  6821		mem_cgroup_clear_mc();
  6822	}
  6823	
  6824	static int mem_cgroup_move_charge_pte(pte_t *pte,
  6825					unsigned long addr, unsigned long end,
  6826					struct mm_walk *walk)
  6827	{
  6828		int ret = 0;
  6829		struct vm_area_struct *vma = walk->vma;
  6830		union mc_target target;
  6831		struct page *page;
  6832		struct page_cgroup *pc;
  6833		swp_entry_t ent;
  6834	
  6835	retry:
  6836		if (!mc.precharge) {
  6837			pte_t *orig_pte = pte - ((addr & (PMD_SIZE - 1)) >> PAGE_SHIFT);
  6838			pte_unmap_unlock(orig_pte, walk->ptl);
  6839			cond_resched();
  6840			/*
  6841			 * We have consumed all precharges we got in can_attach().
  6842			 * We try charge one by one, but don't do any additional
  6843			 * charges to mc.to if we have failed in charge once in attach()
  6844			 * phase.
  6845			 */
  6846			ret = mem_cgroup_do_precharge(1);
> 6847			pte_offset_map(walk->pmd, addr & PMD_MASK);
  6848			spin_lock(walk->ptl);
  6849			if (!ret)
  6850				goto retry;

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
