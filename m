Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 89BD36B01AC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjm0n003955
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:48 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E948B45DE4D
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A7FA845DE4F
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 689F71DB804F
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 122B11DB8046
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1006162028410.21446@chino.kir.corp.google.com>
References: <20100613180405.6178.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162028410.21446@chino.kir.corp.google.com>
Message-Id: <20100617150450.FBBC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > >   (3) oom_kill_task (when oom_kill_allocating_task==1 only)
> > > > 
> > > 
> > > Why would care about cpuset attachment in oom_kill_task()?  You mean 
> > > oom_kill_process() to filter the children list?
> > 
> > Ah, intersting question. OK, we have to discuss oom_kill_allocating_task
> > design at first.
> > 
> > First of All, oom_kill_process() to filter the children list and this issue
> > are independent and unrelated. My patch was not correct too.
> > 
> > Now, oom_kill_allocating_task basic logic is here. It mean, if oom_kill_process()
> > return 0, oom kill finished successfully. but if oom_kill_process() return 1,
> > fallback to normall __out_of_memory().
> > 
> 
> Right.
> 
> > 
> > 	===================================================
> > 	static void __out_of_memory(gfp_t gfp_mask, int order, nodemask_t *nodemask)
> > 	{
> > 	        struct task_struct *p;
> > 	        unsigned long points;
> > 	
> > 	        if (sysctl_oom_kill_allocating_task)
> > 	                if (!oom_kill_process(current, gfp_mask, order, 0, NULL, nodemask,
> > 	                                      "Out of memory (oom_kill_allocating_task)"))
> > 	                        return;
> > 	retry:
> > 
> > When oom_kill_process() return 1?
> > I think It should be
> > 	- current is OOM_DISABLE
> 
> In this case, oom_kill_task() returns 1, which causes oom_kill_process() 
> to return 1 if current (and not one of its children) is actually selected 
> to die.

Right.

> 
> > 	- current have no intersected CPUSET
> 
> current will always intersect its own cpuset's mems.

Oops, It was my mistake.


> 
> > 	- current is KTHREAD
> 
> find_lock_task_mm() should take care of that in oom_kill_task() just like 
> it does for OOM_DISABLE, although we can still race with use_mm(), in 
> which case this would be a good chance.

find_lock_task_mm() implementation is here. it only check ->mm.
other place are using both KTHREAD check and find_lock_task_mm().

----------------------------------------------------------------------
/*
 * The process p may have detached its own ->mm while exiting or through
 * use_mm(), but one or more of its subthreads may still have a valid
 * pointer.  Return p, or any of its subthreads with a valid ->mm, with
 * task_lock() held.
 */
static struct task_struct *find_lock_task_mm(struct task_struct *p)
{
        struct task_struct *t = p;

        do {
                task_lock(t);
                if (likely(t->mm))
                        return t;
                task_unlock(t);
        } while_each_thread(p, t);

        return NULL;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
