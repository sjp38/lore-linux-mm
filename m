Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 911476B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 23:23:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o583NXQk021747
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 8 Jun 2010 12:23:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BC0145DE6F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 12:23:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E1E4F45DE60
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 12:23:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5D8EE38001
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 12:23:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7447BE38002
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 12:23:32 +0900 (JST)
Date: Tue, 8 Jun 2010 12:19:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] memcg remove css_get/put per pages
Message-Id: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Now, I think pre_destroy->force_empty() works very well and we can get rid of
css_put/get per pages. This has very big effect in some special case.

This is a test result with a multi-thread page fault program
(I used at rwsem discussion.)

[Before patch]
   25.72%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
     8.18%  multi-fault-all  [kernel.kallsyms]      [k] try_get_mem_cgroup_from_mm
     8.17%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     8.03%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     5.46%  multi-fault-all  [kernel.kallsyms]      [k] __css_put
     5.45%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     4.36%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     4.35%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     3.59%  multi-fault-all  [kernel.kallsyms]      [k] css_put
     2.37%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
     1.80%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
     1.78%  multi-fault-all  [kernel.kallsyms]      [k] __rmqueue
     1.65%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault

try_get_mem_cgroup_from_mm() is a one of heavy ops because of false-sharing in
css's counter for css_get/put.

I removed that.

[After]
   26.16%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
    11.73%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
     9.23%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
     9.07%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
     6.09%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
     5.57%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
     4.86%  multi-fault-all  [kernel.kallsyms]      [k] up_read
     2.54%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge
     2.29%  multi-fault-all  [kernel.kallsyms]      [k] _cond_resched
     2.04%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
     1.82%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault

Hmm. seems nice. But I don't convince my patch has no race.
I'll continue test but your help is welcome.

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

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   66 +++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 46 insertions(+), 20 deletions(-)

Index: mmotm-2.6.34-Jun6/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Jun6.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Jun6/mm/memcontrol.c
@@ -1717,25 +1717,49 @@ static int __mem_cgroup_try_charge(struc
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (*memcg) {
+	if (!*memcg && !mm)
+		goto bypass;
+again:
+	if (*memcg) { /* css should be a valid one */
 		mem = *memcg;
+		VM_BUG_ON(css_is_removed(mem));
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
+ 		 * while task_lock, this task cannot be disconnected with
+ 		 * the cgroup we see.
+ 		 */
+		task_lock(p);
+		mem = mem_cgroup_from_task(p);
+		VM_BUG_ON(!mem);
+		if (mem_cgroup_is_root(mem)) {
+			task_unlock(p);
+			rcu_read_unlock();
+			goto done;
+		}
+		if (consume_stock(mem)) {
+			*memcg = mem;
+			task_unlock(p);
+			rcu_read_unlock();
+			goto done;
+		}
+		css_get(&mem->css);
+		task_unlock(p);
+		rcu_read_unlock();
+	}
 
 	do {
 		bool oom_check;
 
-		if (consume_stock(mem))
-			goto done; /* don't need to fill stock */
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current))
 			goto bypass;
@@ -1750,10 +1774,13 @@ static int __mem_cgroup_try_charge(struc
 
 		switch (ret) {
 		case CHARGE_OK:
+			*memcg = mem;
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
 			csize = PAGE_SIZE;
-			break;
+			css_put(&mem->css);
+			mem = NULL;
+			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
@@ -1769,6 +1796,7 @@ static int __mem_cgroup_try_charge(struc
 
 	if (csize > PAGE_SIZE)
 		refill_stock(mem, csize - PAGE_SIZE);
+	css_put(&mem->css);
 done:
 	return 0;
 nomem:
@@ -1795,7 +1823,6 @@ static void __mem_cgroup_cancel_charge(s
 			res_counter_uncharge(&mem->memsw, PAGE_SIZE * count);
 		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
 		WARN_ON_ONCE(count > INT_MAX);
-		__css_put(&mem->css, (int)count);
 	}
 	/* we don't need css_put for root */
 }
@@ -2158,7 +2185,6 @@ int mem_cgroup_try_charge_swapin(struct 
 		goto charge_cur_mm;
 	*ptr = mem;
 	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
-	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
@@ -2345,9 +2371,6 @@ __mem_cgroup_uncharge_common(struct page
 	unlock_page_cgroup(pc);
 
 	memcg_check_events(mem, page);
-	/* at swapout, this memcg will be accessed to record to swap */
-	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		css_put(&mem->css);
 
 	return mem;
 
@@ -2432,14 +2455,18 @@ mem_cgroup_uncharge_swapcache(struct pag
 	if (!swapout) /* this was a swap cache but the swap is unused ! */
 		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
 
-	memcg = __mem_cgroup_uncharge_common(page, ctype);
+	memcg = try_get_mem_cgroup_from_page(page);
+	if (!memcg)
+		return;
+
+	__mem_cgroup_uncharge_common(page, ctype);
 
 	/* record memcg information */
 	if (do_swap_account && swapout && memcg) {
 		swap_cgroup_record(ent, css_id(&memcg->css));
 		mem_cgroup_get(memcg);
 	}
-	if (swapout && memcg)
+	if (memcg)
 		css_put(&memcg->css);
 }
 #endif
@@ -4219,7 +4246,6 @@ static int mem_cgroup_do_precharge(unsig
 		mc.precharge += count;
 		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
 		WARN_ON_ONCE(count > INT_MAX);
-		__css_get(&mem->css, (int)count);
 		return ret;
 	}
 one_by_one:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
