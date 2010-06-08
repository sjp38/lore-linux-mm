Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB1006B01AD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 01:40:15 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o585WQmt013791
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 23:32:26 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o585eDYb172688
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 23:40:13 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o585eDXB009993
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 23:40:13 -0600
Date: Tue, 8 Jun 2010 11:10:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages
Message-ID: <20100608054003.GY4603@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-08 12:19:01]:

> Now, I think pre_destroy->force_empty() works very well and we can get rid of
> css_put/get per pages. This has very big effect in some special case.
> 
> This is a test result with a multi-thread page fault program
> (I used at rwsem discussion.)
> 
> [Before patch]
>    25.72%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
>      8.18%  multi-fault-all  [kernel.kallsyms]      [k] try_get_mem_cgroup_from_mm
>      8.17%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
>      8.03%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
>      5.46%  multi-fault-all  [kernel.kallsyms]      [k] __css_put
>      5.45%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
>      4.36%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
>      4.35%  multi-fault-all  [kernel.kallsyms]      [k] up_read
>      3.59%  multi-fault-all  [kernel.kallsyms]      [k] css_put
>      2.37%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
>      1.80%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
>      1.78%  multi-fault-all  [kernel.kallsyms]      [k] __rmqueue
>      1.65%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
> 
> try_get_mem_cgroup_from_mm() is a one of heavy ops because of false-sharing in
> css's counter for css_get/put.
> 
> I removed that.
> 
> [After]
>    26.16%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
>     11.73%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
>      9.23%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
>      9.07%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
>      6.09%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
>      5.57%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
>      4.86%  multi-fault-all  [kernel.kallsyms]      [k] up_read
>      2.54%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge
>      2.29%  multi-fault-all  [kernel.kallsyms]      [k] _cond_resched
>      2.04%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
>      1.82%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
> 
> Hmm. seems nice. But I don't convince my patch has no race.
> I'll continue test but your help is welcome.
>

Looks nice, Kamezawa-San could you please confirm the source of
raw_spin_lock_irqsave and trylock from /proc/lock_stat?
 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, memory cgroup increments css(cgroup subsys state)'s reference
> count per a charged page. And the reference count is kept until
> the page is uncharged. But this has 2 bad effect. 
> 
>  1. Because css_get/put calls atoimic_inc()/dec, heavy call of them
>     on large smp will not scale well.
>  2. Because css's refcnt cannot be in a state as "ready-to-release",
>     cgroup's notify_on_release handler can't work with memcg.
> 
> This is a trial to remove css's refcnt per a page. Even if we remove
                                             ^^ (per page)
> refcnt, pre_destroy() does enough synchronization.

Could you also document what the rules for css_get/put now become? I
like the idea, but I am not sure if I understand the new rules
correctly by looking at the code.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
