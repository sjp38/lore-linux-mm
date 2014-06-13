Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 896B16B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:02:30 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1573090pad.37
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 19:02:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wg10si431056pbc.23.2014.06.12.19.02.28
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 19:02:29 -0700 (PDT)
Date: Fri, 13 Jun 2014 10:02:03 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 148/178] mm/memcontrol.c:6961:21: error: call to
 '__compiletime_assert_6961' declared with attribute error: BUILD_BUG failed
Message-ID: <539a5b9b.KeRIMtUWy5rRR18V%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
commit: e6b81384e2275775b2ae090b97043077dea26c11 [148/178] memcg: deprecate memory.force_empty knob
config: make ARCH=ia64 allmodconfig

All error/warnings:

   mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte':
   mm/memcontrol.c:6913:3: warning: value computed is not used [-Wunused-value]
   mm/memcontrol.c:6902:10: warning: unused variable 'orig_pte' [-Wunused-variable]
   mm/memcontrol.c: In function 'mem_cgroup_move_charge_pmd':
>> mm/memcontrol.c:6961:21: error: call to '__compiletime_assert_6961' declared with attribute error: BUILD_BUG failed

vim +/__compiletime_assert_6961 +6961 mm/memcontrol.c

5e2db449 Naoya Horiguchi   2014-06-13  6907  		 * We have consumed all precharges we got in can_attach().
5e2db449 Naoya Horiguchi   2014-06-13  6908  		 * We try charge one by one, but don't do any additional
5e2db449 Naoya Horiguchi   2014-06-13  6909  		 * charges to mc.to if we have failed in charge once in attach()
5e2db449 Naoya Horiguchi   2014-06-13  6910  		 * phase.
5e2db449 Naoya Horiguchi   2014-06-13  6911  		 */
5e2db449 Naoya Horiguchi   2014-06-13  6912  		ret = mem_cgroup_do_precharge(1);
5e2db449 Naoya Horiguchi   2014-06-13 @6913  		pte_offset_map(walk->pmd, addr & PMD_MASK);
5e2db449 Naoya Horiguchi   2014-06-13  6914  		spin_lock(walk->ptl);
5e2db449 Naoya Horiguchi   2014-06-13  6915  		if (!ret)
5e2db449 Naoya Horiguchi   2014-06-13  6916  			goto retry;
5e2db449 Naoya Horiguchi   2014-06-13  6917  		return ret;
5e2db449 Naoya Horiguchi   2014-06-13  6918  	}
5e2db449 Naoya Horiguchi   2014-06-13  6919  
5e2db449 Naoya Horiguchi   2014-06-13  6920  	switch (get_mctgt_type(vma, addr, *pte, &target)) {
5e2db449 Naoya Horiguchi   2014-06-13  6921  	case MC_TARGET_PAGE:
5e2db449 Naoya Horiguchi   2014-06-13  6922  		page = target.page;
5e2db449 Naoya Horiguchi   2014-06-13  6923  		if (isolate_lru_page(page))
5e2db449 Naoya Horiguchi   2014-06-13  6924  			goto put;
5e2db449 Naoya Horiguchi   2014-06-13  6925  		pc = lookup_page_cgroup(page);
5e2db449 Naoya Horiguchi   2014-06-13  6926  		if (!mem_cgroup_move_account(page, 1, pc,
5e2db449 Naoya Horiguchi   2014-06-13  6927  					     mc.from, mc.to)) {
5e2db449 Naoya Horiguchi   2014-06-13  6928  			mc.precharge--;
5e2db449 Naoya Horiguchi   2014-06-13  6929  			/* we uncharge from mc.from later. */
5e2db449 Naoya Horiguchi   2014-06-13  6930  			mc.moved_charge++;
5e2db449 Naoya Horiguchi   2014-06-13  6931  		}
5e2db449 Naoya Horiguchi   2014-06-13  6932  		putback_lru_page(page);
5e2db449 Naoya Horiguchi   2014-06-13  6933  put:		/* get_mctgt_type() gets the page */
5e2db449 Naoya Horiguchi   2014-06-13  6934  		put_page(page);
5e2db449 Naoya Horiguchi   2014-06-13  6935  		break;
5e2db449 Naoya Horiguchi   2014-06-13  6936  	case MC_TARGET_SWAP:
5e2db449 Naoya Horiguchi   2014-06-13  6937  		ent = target.ent;
5e2db449 Naoya Horiguchi   2014-06-13  6938  		if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {
5e2db449 Naoya Horiguchi   2014-06-13  6939  			mc.precharge--;
5e2db449 Naoya Horiguchi   2014-06-13  6940  			/* we fixup refcnts and charges later. */
5e2db449 Naoya Horiguchi   2014-06-13  6941  			mc.moved_swap++;
5e2db449 Naoya Horiguchi   2014-06-13  6942  		}
5e2db449 Naoya Horiguchi   2014-06-13  6943  		break;
5e2db449 Naoya Horiguchi   2014-06-13  6944  	default:
5e2db449 Naoya Horiguchi   2014-06-13  6945  		break;
5e2db449 Naoya Horiguchi   2014-06-13  6946  	}
5e2db449 Naoya Horiguchi   2014-06-13  6947  
5e2db449 Naoya Horiguchi   2014-06-13  6948  	return 0;
5e2db449 Naoya Horiguchi   2014-06-13  6949  }
5e2db449 Naoya Horiguchi   2014-06-13  6950  
5e2db449 Naoya Horiguchi   2014-06-13  6951  static int mem_cgroup_move_charge_pmd(pmd_t *pmd,
5e2db449 Naoya Horiguchi   2014-06-13  6952  				unsigned long addr, unsigned long end,
5e2db449 Naoya Horiguchi   2014-06-13  6953  				struct mm_walk *walk)
5e2db449 Naoya Horiguchi   2014-06-13  6954  {
5e2db449 Naoya Horiguchi   2014-06-13  6955  	struct vm_area_struct *vma = walk->vma;
12724850 Naoya Horiguchi   2012-03-21  6956  	enum mc_target_type target_type;
12724850 Naoya Horiguchi   2012-03-21  6957  	union mc_target target;
12724850 Naoya Horiguchi   2012-03-21  6958  	struct page *page;
12724850 Naoya Horiguchi   2012-03-21  6959  	struct page_cgroup *pc;
4ffef5fe Daisuke Nishimura 2010-03-10  6960  
d6dc1086 Naoya Horiguchi   2014-06-13 @6961  	if (mc.precharge < HPAGE_PMD_NR)
d6dc1086 Naoya Horiguchi   2014-06-13  6962  		return 0;
d6dc1086 Naoya Horiguchi   2014-06-13  6963  	target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
d6dc1086 Naoya Horiguchi   2014-06-13  6964  	if (target_type == MC_TARGET_PAGE) {

:::::: The code at line 6961 was first introduced by commit
:::::: d6dc10868bc1439159231b2353dbbfc635a0c104 mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code

:::::: TO: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
