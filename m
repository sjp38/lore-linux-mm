Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2570E6B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 02:26:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o686QmK2013179
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jul 2010 15:26:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A450445DE51
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:26:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 70CEC45DE52
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:26:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B473E08003
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:26:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A32781DB8045
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:26:47 +0900 (JST)
Date: Thu, 8 Jul 2010 15:21:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH -mm] memcg: avoid css_get
Message-Id: <20100708152159.daa858a8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a patch on the top of stacks of memory cgroup patches in -mm series.
Tested on mmotm-2010-07-01 and works well.
But requires enough tests.

Even if performance improvement is not very attractive, this patch makes
release_agent for memcg work fine. So, cgroup library for memcg can make use of
release_agent for handling memcg, after this patch.

Sorry for delayed work of mine, its a month since the last version.

Thanks,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memory cgroup increments css(cgroup subsys state)'s reference
count per a charged page. And the reference count is kept until
the page is uncharged. But this has 2 bad effect. 

 1. Because css_get/put calls atomic_inc()/dec, heavy call of them
    on large smp will not scale well.
 2. Because css's refcnt cannot be in a state as "ready-to-release",
    cgroup's notify_on_release handler can't work with memcg.
 3. css's refcnt is atomic_t, it means smaller than 32bit. Maybe too small.

This has been a problem since the 1st merge of memcg.

This is a trial to remove css's refcnt per a page. Even if we remove
refcnt, pre_destroy() does enough synchronization as
  - check res->usage == 0.
  - check no pages on LRU.

This patch removes css's refcnt per page. Even after this patch, at the
1st look, it seems css_get() is still called in try_charge().

But the logic is.

  - If a memcg of mm->owner is cached one, consume_stock() will work.
    At success, return immediately.
  - If consume_stock returns false, css_get() is called and go to
    slow path which may be blocked. At the end of slow path,
    css_put() is called and restart from the start if necessary.

So, in the fast path, we don't call css_get() and can avoid access to
shared counter. This patch can make the most possible case fast.

Here is a result of multi-threaded page fault benchmark.

[Before]
    25.32%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
     9.30%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     8.02%  multi-fault-all  [kernel.kallsyms]      [k] try_get_mem_cgroup_from_mm <=====(*)
     7.83%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     5.38%  multi-fault-all  [kernel.kallsyms]      [k] __css_put
     5.29%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     4.92%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     4.24%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     3.53%  multi-fault-all  [kernel.kallsyms]      [k] css_put
     2.11%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
     1.76%  multi-fault-all  [kernel.kallsyms]      [k] __rmqueue
     1.64%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge

[After]
    28.41%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
    10.08%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     9.58%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     9.38%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     5.86%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     5.65%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     2.82%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
     2.64%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
     2.48%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge

Then, 8.02% of try_get_mem_cgroup_from_mm() disappears because this patch
removes css_tryget() in it. (But yes, this is an extreme case.)

Tested on mmotm-2010-07-01, release_agent is triggered as expected.

Changelog 20100708:
 - applied swap accounting fix by Nishimura (added his sign.)
 - fixed typos.
Changelog 20100609:
 - clean up try_charge().
 - fixed mem_cgroup_clear_mc
 - removed unnecessary warnings.
 - removed task_lock, added more comments.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  119 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 76 insertions(+), 43 deletions(-)

Index: mmotm-2.6.35-0701/mm/memcontrol.c
===================================================================
--- mmotm-2.6.35-0701.orig/mm/memcontrol.c
+++ mmotm-2.6.35-0701/mm/memcontrol.c
@@ -1721,28 +1721,66 @@ static int __mem_cgroup_try_charge(struc
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (*memcg) {
+	if (!*memcg && !mm)
+		goto bypass;
+again:
+	if (*memcg) { /* css should be a valid one */
 		mem = *memcg;
+		VM_BUG_ON(css_is_removed(&mem->css));
+		if (mem_cgroup_is_root(mem))
+			goto done;
+		if (consume_stock(mem))
+			goto done;
 		css_get(&mem->css);
 	} else {
-		mem = try_get_mem_cgroup_from_mm(mm);
-		if (unlikely(!mem))
-			return 0;
-		*memcg = mem;
-	}
+		struct task_struct *p;
 
-	VM_BUG_ON(css_is_removed(&mem->css));
-	if (mem_cgroup_is_root(mem))
-		goto done;
+		rcu_read_lock();
+		p = rcu_dereference(mm->owner);
+		VM_BUG_ON(!p);
+		/*
+		 * because we don't have task_lock(), "p" can exit while
+		 * we're here. In that case, "mem" can point to root
+		 * cgroup but never be NULL. (and task_struct itself is freed
+		 * by RCU, cgroup itself is RCU safe.) Then, we have small
+		 * risk here to get wrong cgroup. But such kind of mis-account
+		 * by race always happens because we don't have cgroup_mutex().
+		 * It's overkill and we allow that small race, here.
+		 */
+		mem = mem_cgroup_from_task(p);
+		VM_BUG_ON(!mem);
+		if (mem_cgroup_is_root(mem)) {
+			rcu_read_unlock();
+			goto done;
+		}
+		if (consume_stock(mem)) {
+			/*
+			 * It seems dagerous to access memcg without css_get().
+			 * But considering how consume_stok works, it's not
+			 * necessary. If consume_stock success, some charges
+			 * from this memcg are cached on this cpu. So, we
+			 * don't need to call css_get()/css_tryget() before
+			 * calling consume_stock().
+			 */
+			rcu_read_unlock();
+			goto done;
+		}
+		/* after here, we may be blocked. we need to get refcnt */
+		if (!css_tryget(&mem->css)) {
+			rcu_read_unlock();
+			goto again;
+		}
+		rcu_read_unlock();
+	}
 
 	do {
 		bool oom_check;
 
-		if (consume_stock(mem))
-			goto done; /* don't need to fill stock */
 		/* If killed, bypass charge */
-		if (fatal_signal_pending(current))
+		if (fatal_signal_pending(current)) {
+			css_put(&mem->css);
 			goto bypass;
+		}
 
 		oom_check = false;
 		if (oom && !nr_oom_retries) {
@@ -1757,30 +1795,36 @@ static int __mem_cgroup_try_charge(struc
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
 			csize = PAGE_SIZE;
-			break;
+			css_put(&mem->css);
+			mem = NULL;
+			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
+			css_put(&mem->css);
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
-			if (!oom)
+			if (!oom) {
+				css_put(&mem->css);
 				goto nomem;
+			}
 			/* If oom, we never return -ENOMEM */
 			nr_oom_retries--;
 			break;
 		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
+			css_put(&mem->css);
 			goto bypass;
 		}
 	} while (ret != CHARGE_OK);
 
 	if (csize > PAGE_SIZE)
 		refill_stock(mem, csize - PAGE_SIZE);
+	css_put(&mem->css);
 done:
+	*memcg = mem;
 	return 0;
 nomem:
-	css_put(&mem->css);
+	*memcg = NULL;
 	return -ENOMEM;
 bypass:
-	if (mem)
-		css_put(&mem->css);
 	*memcg = NULL;
 	return 0;
 }
@@ -1797,11 +1841,7 @@ static void __mem_cgroup_cancel_charge(s
 		res_counter_uncharge(&mem->res, PAGE_SIZE * count);
 		if (do_swap_account)
 			res_counter_uncharge(&mem->memsw, PAGE_SIZE * count);
-		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
-		WARN_ON_ONCE(count > INT_MAX);
-		__css_put(&mem->css, (int)count);
 	}
-	/* we don't need css_put for root */
 }
 
 static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
@@ -2162,7 +2202,6 @@ int mem_cgroup_try_charge_swapin(struct 
 		goto charge_cur_mm;
 	*ptr = mem;
 	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
-	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
@@ -2332,10 +2371,6 @@ __mem_cgroup_uncharge_common(struct page
 		break;
 	}
 
-	if (!mem_cgroup_is_root(mem))
-		__do_uncharge(mem, ctype);
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		mem_cgroup_swap_statistics(mem, true);
 	mem_cgroup_charge_statistics(mem, pc, false);
 
 	ClearPageCgroupUsed(pc);
@@ -2347,11 +2382,17 @@ __mem_cgroup_uncharge_common(struct page
 	 */
 
 	unlock_page_cgroup(pc);
-
+	/*
+	 * even after unlock, we have mem->res.usage here and this memcg
+	 * will never be freed.
+	 */
 	memcg_check_events(mem, page);
-	/* at swapout, this memcg will be accessed to record to swap */
-	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		css_put(&mem->css);
+	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
+		mem_cgroup_swap_statistics(mem, true);
+		mem_cgroup_get(mem);
+	}
+	if (!mem_cgroup_is_root(mem))
+		__do_uncharge(mem, ctype);
 
 	return mem;
 
@@ -2438,13 +2479,12 @@ mem_cgroup_uncharge_swapcache(struct pag
 
 	memcg = __mem_cgroup_uncharge_common(page, ctype);
 
-	/* record memcg information */
-	if (do_swap_account && swapout && memcg) {
+	/*
+	 * record memcg information,  if swapout && memcg != NULL,
+	 * mem_cgroup_get() was called in uncharge().
+	 */
+	if (do_swap_account && swapout && memcg)
 		swap_cgroup_record(ent, css_id(&memcg->css));
-		mem_cgroup_get(memcg);
-	}
-	if (swapout && memcg)
-		css_put(&memcg->css);
 }
 #endif
 
@@ -2522,7 +2562,6 @@ static int mem_cgroup_move_swap_account(
 			 */
 			if (!mem_cgroup_is_root(to))
 				res_counter_uncharge(&to->res, PAGE_SIZE);
-			css_put(&to->css);
 		}
 		return 0;
 	}
@@ -4221,9 +4260,6 @@ static int mem_cgroup_do_precharge(unsig
 			goto one_by_one;
 		}
 		mc.precharge += count;
-		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
-		WARN_ON_ONCE(count > INT_MAX);
-		__css_get(&mem->css, (int)count);
 		return ret;
 	}
 one_by_one:
@@ -4459,7 +4495,6 @@ static void mem_cgroup_clear_mc(void)
 	}
 	/* we must fixup refcnts and charges */
 	if (mc.moved_swap) {
-		WARN_ON_ONCE(mc.moved_swap > INT_MAX);
 		/* uncharge swap account from the old cgroup */
 		if (!mem_cgroup_is_root(mc.from))
 			res_counter_uncharge(&mc.from->memsw,
@@ -4473,8 +4508,6 @@ static void mem_cgroup_clear_mc(void)
 			 */
 			res_counter_uncharge(&mc.to->res,
 						PAGE_SIZE * mc.moved_swap);
-			VM_BUG_ON(test_bit(CSS_ROOT, &mc.to->css.flags));
-			__css_put(&mc.to->css, mc.moved_swap);
 		}
 		/* we've already done mem_cgroup_get(mc.to) */
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
