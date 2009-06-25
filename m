Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E50B56B006A
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 00:37:55 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5P4d3ge011870
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Jun 2009 13:39:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 05A8E45DE7C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:39:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA52045DE6E
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:39:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A62D4E08007
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:39:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 591BFE08004
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:39:02 +0900 (JST)
Date: Thu, 25 Jun 2009 13:37:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-Id: <20090625133725.c5af0998.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090625032717.GX8642@balbir.in.ibm.com>
References: <20090624170516.GT8642@balbir.in.ibm.com>
	<20090624161028.b165a61a.akpm@linux-foundation.org>
	<20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090625032717.GX8642@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 2009 08:57:17 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > What kind of workload can be much improved ?
> > IIUC, in general, using seq_lock to frequently modified counter just makes
> > it slow.
> 
> Why do you think so? I've been looking primarily at do_gettimeofday().
IIUC, modification to xtime is _not_ frequent.

> Yes, frequent updates can hurt readers in the worst case. 
You don't understand my point. write-side of seqlock itself is
heavy. I have no interests in read-side.

What need to be faster is here.
==
 929         while (1) {
 930                 int ret;
 931                 bool noswap = false;
 932 
 933                 ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
 934                 if (likely(!ret)) {
 935                         if (!do_swap_account)
 936                                 break;
 937                         ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
 938                                                         &fail_res);
 939                         if (likely(!ret))
 940                                 break;
 941                         /* mem+swap counter fails */
 942                         res_counter_uncharge(&mem->res, PAGE_SIZE);
 943                         noswap = true;
 944                         mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 945                                                                         memsw);
 946                 } else
 947                         /* mem counter fails */
 948                         mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 949                                              
==
And using seq_lock will add more overheads to here.

> I've been
> meaning to experiment with percpu counters as well, but we'll need to
> decide what is the tolerance limit, since we can have a batch value
> fuzziness, before all CPUs see that the limit is exceeded, but it
> might be worth experimenting.
> 

per-cpu counter is a choice. but "batch" value is very difficult if
we never allow "exceeds". And if # of bactch is too small, percpu
counter is slower than current one.
And if hierarchy is used, jitter by batch will be very big in parent nodes.



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
