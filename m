Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F142D6B004D
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 23:02:36 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2442YrA015158
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Mar 2010 13:02:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B42B45DE4F
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:02:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 14F8245DE4C
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:02:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E7C901DB8016
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:02:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 988CC1DB8013
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:02:33 +0900 (JST)
Date: Thu, 4 Mar 2010 12:59:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom kill behavior v3
Message-Id: <20100304125900.ad457cd2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100303151257.f45ceffe.akpm@linux-foundation.org>
References: <20100302115834.c0045175.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302135524.afe2f7ab.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302143738.5cd42026.nishimura@mxp.nes.nec.co.jp>
	<20100302145644.0f8fbcca.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302151544.59c23678.nishimura@mxp.nes.nec.co.jp>
	<20100303092606.2e2152fc.nishimura@mxp.nes.nec.co.jp>
	<20100303093844.cf768ea4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303162304.eaf49099.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303151257.f45ceffe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 15:12:57 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 3 Mar 2010 16:23:04 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > In current page-fault code,
> > 
> > 	handle_mm_fault()
> > 		-> ...
> > 		-> mem_cgroup_charge()
> > 		-> map page or handle error.
> > 	-> check return code.
> > 
> > If page fault's return code is VM_FAULT_OOM, page_fault_out_of_memory()
> > is called. But if it's caused by memcg, OOM should have been already
> > invoked.
> > Then, I added a patch: a636b327f731143ccc544b966cfd8de6cb6d72c6
> > 
> > That patch records last_oom_jiffies for memcg's sub-hierarchy and
> > prevents page_fault_out_of_memory from being invoked in near future.
> > 
> > But Nishimura-san reported that check by jiffies is not enough
> > when the system is terribly heavy. 
> > 
> > This patch changes memcg's oom logic as.
> >  * If memcg causes OOM-kill, continue to retry.
> >  * remove jiffies check which is used now.
> >  * add memcg-oom-lock which works like perzone oom lock.
> >  * If current is killed(as a process), bypass charge.
> > 
> > Something more sophisticated can be added but this pactch does
> > fundamental things.
> > TODO:
> >  - add oom notifier
> >  - add permemcg disable-oom-kill flag and freezer at oom.
> >  - more chances for wake up oom waiter (when changing memory limit etc..)
> > 
> > ...
> >
> > +static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> > +{
> > +	int lock_count = 0;
> > +
> > +	mem_cgroup_walk_tree(mem, &lock_count, mem_cgroup_oom_lock_cb);
> >  
> > -static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
> > +	if (lock_count == 1)
> > +		return true;
> > +	return false;
> > +}
> 
> mem_cgroup_walk_tree() will visit all items, but it could have returned
> when it found the first "locked" item.  I minor inefficiency, I guess.
> 
Perhaps. but considering unlock, this walk-all seems simpler because we don't
have to remember what we locked. Hmm...but create/remove cgroup while
we do oom-lock can cause bug. I'll add a check or re-design this lock.


> > +static int mem_cgroup_oom_unlock_cb(struct mem_cgroup *mem, void *data)
> >  {
> > -	mem->last_oom_jiffies = jiffies;
> > +	atomic_dec(&mem->oom_lock);
> >  	return 0;
> >  }
> >  
> > -static void record_last_oom(struct mem_cgroup *mem)
> > +static void mem_cgroup_oom_unlock(struct mem_cgroup *mem)
> >  {
> > -	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
> > +	mem_cgroup_walk_tree(mem, NULL,	mem_cgroup_oom_unlock_cb);
> > +}
> > +
> > +static DEFINE_MUTEX(memcg_oom_mutex);
> > +static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
> > +
> > +/*
> > + * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> > + */
> > +bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> > +{
> > +	DEFINE_WAIT(wait);
> > +	bool locked;
> > +
> > +	/* At first, try to OOM lock hierarchy under mem.*/
> > +	mutex_lock(&memcg_oom_mutex);
> > +	locked = mem_cgroup_oom_lock(mem);
> > +	if (!locked)
> > +		prepare_to_wait(&memcg_oom_waitq, &wait, TASK_INTERRUPTIBLE);
> > +	mutex_unlock(&memcg_oom_mutex);
> > +
> > +	if (locked)
> > +		mem_cgroup_out_of_memory(mem, mask);
> > +	else {
> > +		schedule();
> 
> If the calling process has signal_pending() then the schedule() will
> immediately return.  A bug, I suspect.  Fixable by using
> TASK_UNINTERRUPTIBLE.
> 
Hmm..If it doen't sleep, it continue to reclaim memory. But we have no
return path to the caller in memcg's charge function even if signal_pending,
allowing continue reclaim just wastes cpu.

Sure, I'll update this to be TASK_UNINTERRUPTIBLE.
But I'll revisit this when we implement oom-notifier and oom-kill-disable.

Thank you for review. I'll post v4.

Regards,
-Kame







> > +		finish_wait(&memcg_oom_waitq, &wait);
> > +	}
> > +	mutex_lock(&memcg_oom_mutex);
> > +	mem_cgroup_oom_unlock(mem);
> > +	/*
> > + 	 * Here, we use global waitq .....more fine grained waitq ?
> > + 	 * Assume following hierarchy.
> > + 	 * A/
> > + 	 *   01
> > + 	 *   02
> > + 	 * assume OOM happens both in A and 01 at the same time. Tthey are
> > + 	 * mutually exclusive by lock. (kill in 01 helps A.)
> > + 	 * When we use per memcg waitq, we have to wake up waiters on A and 02
> > + 	 * in addtion to waiters on 01. We use global waitq for avoiding mess.
> > + 	 * It will not be a big problem.
> > + 	 */
> > +	wake_up_all(&memcg_oom_waitq);
> > +	mutex_unlock(&memcg_oom_mutex);
> > +
> > +	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> > +		return false;
> > +	/* Give chance to dying process */
> > +	schedule_timeout(1);
> > +	return true;
> >  }
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
