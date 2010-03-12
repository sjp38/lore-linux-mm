Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 196266B007D
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 21:42:18 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C2gFX8003911
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 11:42:15 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 563A445DE6F
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:42:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 127A145DE4D
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:42:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6607E1800D
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:42:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0FC9E18006
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:42:13 +0900 (JST)
Date: Fri, 12 Mar 2010 11:38:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] memcg: wake up filter in oom waitqueue
Message-Id: <20100312113838.d6072ae4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100312113028.1449915f.nishimura@mxp.nes.nec.co.jp>
References: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165559.3f9166b2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312113028.1449915f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 11:30:28 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 11 Mar 2010 16:55:59 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > +	/* check hierarchy */
> > +	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
> > +	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
> > +		return 0;
> > +
> I think these conditions are wrong.
> This can wake up tasks in oom_wait_info->mem when:
> 
>   00/ <- wake_mem: use_hierarchy == false
>     aa/ <- oom_wait_info->mem: use_hierarchy == true;
> 
Hmm. I think this line bails out above case.

> +	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
> +		return 0;

No ?

Thanks,
-Kame

> It should be:
> 
> 	if((oom_wait_info->mem->use_hierarchy &&
> 		css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css)) ||
> 	   (wake_mem->use_hierarchy &&
> 		css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css)))
> 		goto wakeup;
> 
> 	return 0;
> 
> But I like the goal of this patch.
> 
> Thanks,
> Daisuke Nishimura.
> 
> > +wakeup:
> > +	return autoremove_wake_function(wait, mode, sync, arg);
> > +}
> > +
> > +static void memcg_wakeup_oom(struct mem_cgroup *mem)
> > +{
> > +	/* for filtering, pass "mem" as argument. */
> > +	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, mem);
> > +}
> > +
> >  /*
> >   * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> >   */
> >  bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> >  {
> > -	DEFINE_WAIT(wait);
> > +	struct oom_wait_info owait;
> >  	bool locked;
> >  
> > +	owait.mem = mem;
> > +	owait.wait.flags = 0;
> > +	owait.wait.func = memcg_oom_wake_function;
> > +	owait.wait.private = current;
> > +	INIT_LIST_HEAD(&owait.wait.task_list);
> > +
> >  	/* At first, try to OOM lock hierarchy under mem.*/
> >  	mutex_lock(&memcg_oom_mutex);
> >  	locked = mem_cgroup_oom_lock(mem);
> > @@ -1310,31 +1350,18 @@ bool mem_cgroup_handle_oom(struct mem_cg
> >  	 * under OOM is always welcomed, use TASK_KILLABLE here.
> >  	 */
> >  	if (!locked)
> > -		prepare_to_wait(&memcg_oom_waitq, &wait, TASK_KILLABLE);
> > +		prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> >  	mutex_unlock(&memcg_oom_mutex);
> >  
> >  	if (locked)
> >  		mem_cgroup_out_of_memory(mem, mask);
> >  	else {
> >  		schedule();
> > -		finish_wait(&memcg_oom_waitq, &wait);
> > +		finish_wait(&memcg_oom_waitq, &owait.wait);
> >  	}
> >  	mutex_lock(&memcg_oom_mutex);
> >  	mem_cgroup_oom_unlock(mem);
> > -	/*
> > -	 * Here, we use global waitq .....more fine grained waitq ?
> > -	 * Assume following hierarchy.
> > -	 * A/
> > -	 *   01
> > -	 *   02
> > -	 * assume OOM happens both in A and 01 at the same time. Tthey are
> > -	 * mutually exclusive by lock. (kill in 01 helps A.)
> > -	 * When we use per memcg waitq, we have to wake up waiters on A and 02
> > -	 * in addtion to waiters on 01. We use global waitq for avoiding mess.
> > -	 * It will not be a big problem.
> > -	 * (And a task may be moved to other groups while it's waiting for OOM.)
> > -	 */
> > -	wake_up_all(&memcg_oom_waitq);
> > +	memcg_wakeup_oom(mem);
> >  	mutex_unlock(&memcg_oom_mutex);
> >  
> >  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
