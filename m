Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 3C6A56B13F6
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:20:33 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4C63B3EE0BC
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:20:31 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2863945DE69
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:20:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 02F8F45DE67
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:20:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9C291DB802C
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:20:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8369A1DB8048
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:20:30 +0900 (JST)
Date: Tue, 7 Feb 2012 09:19:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/6] memcg: simplify move_account() check.
Message-Id: <20120207091906.1fd6eb40.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120206143853.4cd732c4.akpm@linux-foundation.org>
References: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
	<20120206190759.76df4784.kamezawa.hiroyu@jp.fujitsu.com>
	<20120206143853.4cd732c4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, 6 Feb 2012 14:38:53 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 6 Feb 2012 19:07:59 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > >From c75cc843ca0cb36de97ab814e59fb4ab7b1ffbd1 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 2 Feb 2012 10:02:39 +0900
> > Subject: [PATCH 1/6] memcg: simplify move_account() check.
> > 
> > In memcg, for avoiding take-lock-irq-off at accessing page_cgroup,
> > a logic, flag + rcu_read_lock(), is used. This works as following
> > 
> >      CPU-A                     CPU-B
> >                              rcu_read_lock()
> >     set flag
> >                              if(flag is set)
> >                                    take heavy lock
> >                              do job.
> >     synchronize_rcu()        rcu_read_unlock()
> > 
> > In recent discussion, it's argued that using per-cpu value for this
> > flag just complicates the code because 'set flag' is very rare.
> > 
> > This patch changes 'flag' implementation from percpu to atomic_t.
> > This will be much simpler.
> > 
> 
> To me, "RFC" says "might not be ready for merging yet".  You're up to
> v3 - why is it still RFC?  You're still expecting to make significant
> changes?
> 

Yes, I made changes discussed in v2. and need to show how it looks.
I'm sorry that changelog wasn't enough.

> >
> >  }
> > +/*
> > + * memcg->moving_account is used for checking possibility that some thread is
> > + * calling move_account(). When a thread on CPU-A starts moving pages under
> > + * a memcg, other threads sholud check memcg->moving_account under
> 
> "should"
> 

Sure..

> > + * rcu_read_lock(), like this:
> > + *
> > + *         CPU-A                                    CPU-B
> > + *                                              rcu_read_lock()
> > + *         memcg->moving_account+1              if (memcg->mocing_account)
> > + *                                                   take havier locks.
> > + *         syncronize_rcu()                     update something.
> > + *                                              rcu_read_unlock()
> > + *         start move here.
> > + */
> >  
> >  static void mem_cgroup_start_move(struct mem_cgroup *memcg)
> >  {
> > -	int cpu;
> > -
> > -	get_online_cpus();
> > -	spin_lock(&memcg->pcp_counter_lock);
> > -	for_each_online_cpu(cpu)
> > -		per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> > -	memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] += 1;
> > -	spin_unlock(&memcg->pcp_counter_lock);
> > -	put_online_cpus();
> > -
> > +	atomic_inc(&memcg->moving_account);
> >  	synchronize_rcu();
> >  }
> >  
> >  static void mem_cgroup_end_move(struct mem_cgroup *memcg)
> >  {
> > -	int cpu;
> > -
> > -	if (!memcg)
> > -		return;
> > -	get_online_cpus();
> > -	spin_lock(&memcg->pcp_counter_lock);
> > -	for_each_online_cpu(cpu)
> > -		per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
> > -	memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] -= 1;
> > -	spin_unlock(&memcg->pcp_counter_lock);
> > -	put_online_cpus();
> > +	if (memcg)
> > +		atomic_dec(&memcg->moving_account);
> >  }
> 
> It's strange that end_move handles a NULL memcg but start_move does not.
> 

Ah, the reason was that mem_cgroup_end_move() can called in mem_cgroup_clear_mc().
This mem_cgroup_clear_mc() can call mem_cgroup_end_move(NULL)...
Then, this function has NULL check in callee side.
I'll add comments.


> >  /*
> >   * 2 routines for checking "mem" is under move_account() or not.
> > @@ -1298,7 +1297,7 @@ static void mem_cgroup_end_move(struct mem_cgroup *memcg)
> >  static bool mem_cgroup_stealed(struct mem_cgroup *memcg)
> >  {
> >  	VM_BUG_ON(!rcu_read_lock_held());
> > -	return this_cpu_read(memcg->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
> > +	return atomic_read(&memcg->moving_account);
> >  }
> 
> So a bool-returning function can return something > 1?
> 
> I don't know what the compiler would make of that.  Presumably "if (b)"
> will work OK, but will "if (b1 == b2)"?
> 

        if (!mem_cgroup_stealed(memcg))
ffffffff8116e278:       85 c0                   test   %eax,%eax
ffffffff8116e27a:       74 1f                   je     ffffffff8116e29b <__mem_cgroup_begin_update_page_stat+0x7b>
                return;
ffffffff8116e29b:       5b                      pop    %rbx
ffffffff8116e29c:       41 5c                   pop    %r12
ffffffff8116e29e:       41 5d                   pop    %r13
ffffffff8116e2a0:       41 5e                   pop    %r14
ffffffff8116e2a2:       c9                      leaveq
ffffffff8116e2a3:       c3                      retq

Maybe works as expected but... I'll rewrite..how about this ?.
