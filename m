Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E44286B01E3
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 03:04:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o597415H005310
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Jun 2010 16:04:01 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5D2045DE51
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 16:04:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD8CA45DE50
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 16:04:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 92513E18004
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 16:04:00 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 31F43E08002
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 16:04:00 +0900 (JST)
Date: Wed, 9 Jun 2010 15:59:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] memcg remove css_get/put per pages v2
Message-Id: <20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Still RFC, added lkml to CC: list.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memory cgroup increments css(cgroup subsys state)'s reference
count per a charged page. And the reference count is kept until
the page is uncharged. But this has 2 bad effect. 

 1. Because css_get/put calls atoimic_inc()/dec, heavy call of them
    on large smp will not scale well.
 2. Because css's refcnt cannot be in a state as "ready-to-release",
    cgroup's notify_on_release handler can't work with memcg.

This is a trial to remove css's refcnt per a page. Even if we remove
refcnt, pre_destroy() does enough synchronization.

After this patch, it seems css_get() is still called in try_charge().
But the logic is.

  1. task_lock(mm->owner)
  2. If a memcg of mm->owner is cached one, consume_stock() will work.
     If it returns true, task_unlock and return immediately.
  3. If a memcg doesn't hit cached one, css_get() and access res_counter
     and do charge.
So, in the fast path, we don't call css_get() and can avoid access to
shared counter.
The point is that while there are used resource, memcg can't be freed.
So, if it's cached, we don't have to take css_get().

Brief test result on mmotm-2.6.32-Jul-06 + Nishimura-san's cleanup.
test with multi-threaded page fault program on 8cpu system.
(Each threads touch 2M of pages and release them by madvice().)

[Before]

           39522457  page-faults
          549387860  cache-misses   (cache-miss/page-fault 13.90)

       60.003715887  seconds time elapsed

    25.75%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
     8.59%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     8.22%  multi-fault-all  [kernel.kallsyms]      [k] try_get_mem_cgroup_from_mm
     8.01%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     5.41%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     5.41%  multi-fault-all  [kernel.kallsyms]      [k] __css_put
     4.48%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     4.41%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     3.60%  multi-fault-all  [kernel.kallsyms]      [k] css_put
     1.93%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
     1.91%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
     1.89%  multi-fault-all  [kernel.kallsyms]      [k] _cond_resched
     1.78%  multi-fault-all  [kernel.kallsyms]      [k] __rmqueue
     1.69%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
     1.63%  multi-fault-all  [kernel.kallsyms]      [k] page_fault
     1.45%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge
     1.34%  multi-fault-all  [kernel.kallsyms]      [k] find_vma

[After]

           43253862  page-faults
          505750203  cache-misses   (cache-miss/page-fault 11.69)

       60.004123555  seconds time elapsed

    27.98%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
     9.89%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     9.88%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     9.37%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     5.91%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     5.69%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     2.94%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
     2.70%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
     2.66%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
     2.25%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge
     1.90%  multi-fault-all  [kernel.kallsyms]      [k] __rmqueue
     1.74%  multi-fault-all  [kernel.kallsyms]      [k] page_fault
     1.52%  multi-fault-all  [kernel.kallsyms]      [k] find_vma

Then, overhead is reduced.

Note: Because this is an extreme, not-realistic, test, I'm not sure how
this change will be benefits for usual applications.
 

Changelog 20100609:
 - clean up try_charge().
 - fixed mem_cgroup_clear_mc
 - removed unnecessary warnings.
 - removed task_lock, added more comments.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   96 ++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 63 insertions(+), 33 deletions(-)

Index: mmotm-2.6.34-Jun6/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Jun6.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Jun6/mm/memcontrol.c
@@ -1717,28 +1717,61 @@ static int __mem_cgroup_try_charge(struc
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
+		 * It seems there are some races when 'p' exits. But, at exit(),
+		 * p->cgroups will be reset to init_css_set. So, we'll just
+		 * find the root cgroup even if 'p' gets to be obsolete.
+ 		 */
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
@@ -1753,30 +1786,36 @@ static int __mem_cgroup_try_charge(struc
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
@@ -1793,11 +1832,7 @@ static void __mem_cgroup_cancel_charge(s
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
@@ -2158,7 +2193,6 @@ int mem_cgroup_try_charge_swapin(struct 
 		goto charge_cur_mm;
 	*ptr = mem;
 	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
-	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
@@ -2345,9 +2379,6 @@ __mem_cgroup_uncharge_common(struct page
 	unlock_page_cgroup(pc);
 
 	memcg_check_events(mem, page);
-	/* at swapout, this memcg will be accessed to record to swap */
-	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		css_put(&mem->css);
 
 	return mem;
 
@@ -2432,15 +2463,18 @@ mem_cgroup_uncharge_swapcache(struct pag
 	if (!swapout) /* this was a swap cache but the swap is unused ! */
 		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
 
-	memcg = __mem_cgroup_uncharge_common(page, ctype);
+	memcg = try_get_mem_cgroup_from_page(page);
+	if (!memcg)
+		return;
+
+	__mem_cgroup_uncharge_common(page, ctype);
 
 	/* record memcg information */
-	if (do_swap_account && swapout && memcg) {
+	if (do_swap_account && swapout) {
 		swap_cgroup_record(ent, css_id(&memcg->css));
 		mem_cgroup_get(memcg);
 	}
-	if (swapout && memcg)
-		css_put(&memcg->css);
+	css_put(&memcg->css);
 }
 #endif
 
@@ -2518,7 +2552,6 @@ static int mem_cgroup_move_swap_account(
 			 */
 			if (!mem_cgroup_is_root(to))
 				res_counter_uncharge(&to->res, PAGE_SIZE);
-			css_put(&to->css);
 		}
 		return 0;
 	}
@@ -4219,7 +4252,6 @@ static int mem_cgroup_do_precharge(unsig
 		mc.precharge += count;
 		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
 		WARN_ON_ONCE(count > INT_MAX);
-		__css_get(&mem->css, (int)count);
 		return ret;
 	}
 one_by_one:
@@ -4469,8 +4501,6 @@ static void mem_cgroup_clear_mc(void)
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
