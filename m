Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E56B06B01D2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:51:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o590ptre014612
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Jun 2010 09:51:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E6EF3A62C4
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 09:51:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 31F3F1EF086
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 09:51:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 171DF1DB801A
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 09:51:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7510D1DB8017
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 09:51:52 +0900 (JST)
Date: Wed, 9 Jun 2010 09:47:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages
Message-Id: <20100609094734.cbb744aa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100608054003.GY4603@balbir.in.ibm.com>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100608054003.GY4603@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010 11:10:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-08 12:19:01]:
> 
> > Now, I think pre_destroy->force_empty() works very well and we can get rid of
> > css_put/get per pages. This has very big effect in some special case.
> > 
> > This is a test result with a multi-thread page fault program
> > (I used at rwsem discussion.)
> > 
> > [Before patch]
> >    25.72%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
> >      8.18%  multi-fault-all  [kernel.kallsyms]      [k] try_get_mem_cgroup_from_mm
> >      8.17%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
> >      8.03%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
> >      5.46%  multi-fault-all  [kernel.kallsyms]      [k] __css_put
> >      5.45%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
> >      4.36%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
> >      4.35%  multi-fault-all  [kernel.kallsyms]      [k] up_read
> >      3.59%  multi-fault-all  [kernel.kallsyms]      [k] css_put
> >      2.37%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
> >      1.80%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
> >      1.78%  multi-fault-all  [kernel.kallsyms]      [k] __rmqueue
> >      1.65%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
> > 
> > try_get_mem_cgroup_from_mm() is a one of heavy ops because of false-sharing in
> > css's counter for css_get/put.
> > 
> > I removed that.
> > 
> > [After]
> >    26.16%  multi-fault-all  [kernel.kallsyms]      [k] clear_page_c
> >     11.73%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock
> >      9.23%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irqsave
> >      9.07%  multi-fault-all  [kernel.kallsyms]      [k] down_read_trylock
> >      6.09%  multi-fault-all  [kernel.kallsyms]      [k] _raw_spin_lock_irq
> >      5.57%  multi-fault-all  [kernel.kallsyms]      [k] __alloc_pages_nodemask
> >      4.86%  multi-fault-all  [kernel.kallsyms]      [k] up_read
> >      2.54%  multi-fault-all  [kernel.kallsyms]      [k] __mem_cgroup_commit_charge
> >      2.29%  multi-fault-all  [kernel.kallsyms]      [k] _cond_resched
> >      2.04%  multi-fault-all  [kernel.kallsyms]      [k] mem_cgroup_add_lru_list
> >      1.82%  multi-fault-all  [kernel.kallsyms]      [k] handle_mm_fault
> > 
> > Hmm. seems nice. But I don't convince my patch has no race.
> > I'll continue test but your help is welcome.
> >
> 
> Looks nice, Kamezawa-San could you please confirm the source of
> raw_spin_lock_irqsave and trylock from /proc/lock_stat?
>  
Sure. But above result can be got when lockdep etc..are off.
(it increase lock overhead)

But yes, new _raw_spin_lock seems strange.


> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, memory cgroup increments css(cgroup subsys state)'s reference
> > count per a charged page. And the reference count is kept until
> > the page is uncharged. But this has 2 bad effect. 
> > 
> >  1. Because css_get/put calls atoimic_inc()/dec, heavy call of them
> >     on large smp will not scale well.
> >  2. Because css's refcnt cannot be in a state as "ready-to-release",
> >     cgroup's notify_on_release handler can't work with memcg.
> > 
> > This is a trial to remove css's refcnt per a page. Even if we remove
>                                              ^^ (per page)
> > refcnt, pre_destroy() does enough synchronization.
> 
> Could you also document what the rules for css_get/put now become? I
> like the idea, but I am not sure if I understand the new rules
> correctly by looking at the code.

Hm. I'll try....but this just removes css_get/put per pages..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
