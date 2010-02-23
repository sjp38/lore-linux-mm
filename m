Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE6606B0078
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 01:10:27 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id o1N6AOIw032248
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:10:24 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1N6AMiE1261804
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:10:23 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1N6AMG3031805
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:10:22 +1100
Date: Tue, 23 Feb 2010 11:40:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement
Message-ID: <20100223061020.GH3063@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, rientjes@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-02-23 12:03:15]:

> Nishimura-san, could you review and test your extreme test case with this ?
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, because of page_fault_oom_kill, returning VM_FAULT_OOM means
> random oom-killer should be called. Considering memcg, it handles
> OOM-kill in its own logic, there was a problem as "oom-killer called
> twice" problem.
> 
> By commit a636b327f731143ccc544b966cfd8de6cb6d72c6, I added a check
> in pagefault_oom_killer shouldn't kill some (random) task if
> memcg's oom-killer already killed anyone.
> That was done by comapring current jiffies and last oom jiffies of memcg.
> 
> I thought that easy fix was enough, but Nishimura could write a test case
> where checking jiffies is not enough. So, my fix was not enough.
> This is a fix of above commit.
> 
> This new one does this.
>  * memcg's try_charge() never returns -ENOMEM if oom-killer is allowed.
>  * If someone is calling oom-killer, wait for it in try_charge().
>  * If TIF_MEMDIE is set as a result of try_charge(), return 0 and
>    allow process to make progress (and die.) 
>  * removed hook in pagefault_out_of_memory.
> 
> By this, pagefult_out_of_memory will be never called if memcg's oom-killer
> is called and scattered codes are now in memcg's charge logic again.
> 
> TODO:
>  If __GFP_WAIT is not specified in gfp_mask flag, VM_FAULT_OOM will return
>  anyway. We need to investigate it whether there is a case.
> 
> Cc: David Rientjes <rientjes@google.com>
> Cc: Balbir Singh <balbir@in.ibm.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I've not reviewed David's latest OOM killer changes. Are these changes based on top of
what is going to come in with David's proposal?
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
