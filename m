Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE2D6B003C
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 19:56:16 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz1so1262573pad.31
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 16:56:15 -0800 (PST)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id v7si864021pbi.98.2013.11.13.16.56.13
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 16:56:14 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1270550pab.14
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 16:56:11 -0800 (PST)
Date: Wed, 13 Nov 2013 16:56:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add memory.oom_control notification for system
 oom
In-Reply-To: <20131113233419.GJ707@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com> <20131031054942.GA26301@cmpxchg.org> <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com> <20131113233419.GJ707@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 13 Nov 2013, Johannes Weiner wrote:

> > > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > > --- a/include/linux/memcontrol.h
> > > > +++ b/include/linux/memcontrol.h
> > > > @@ -155,6 +155,7 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
> > > >  }
> > > >  
> > > >  bool mem_cgroup_oom_synchronize(bool wait);
> > > > +void mem_cgroup_root_oom_notify(void);
> > > >  
> > > >  #ifdef CONFIG_MEMCG_SWAP
> > > >  extern int do_swap_account;
> > > > @@ -397,6 +398,10 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
> > > >  	return false;
> > > >  }
> > > >  
> > > > +static inline void mem_cgroup_root_oom_notify(void)
> > > > +{
> > > > +}
> > > > +
> > > >  static inline void mem_cgroup_inc_page_stat(struct page *page,
> > > >  					    enum mem_cgroup_stat_index idx)
> > > >  {
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -5641,6 +5641,15 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg)
> > > >  		mem_cgroup_oom_notify_cb(iter);
> > > >  }
> > > >  
> > > > +/*
> > > > + * Notify any process waiting on the root memcg's memory.oom_control, but do not
> > > > + * notify any child memcgs to avoid triggering their per-memcg oom handlers.
> > > > + */
> > > > +void mem_cgroup_root_oom_notify(void)
> > > > +{
> > > > +	mem_cgroup_oom_notify_cb(root_mem_cgroup);
> > > > +}
> > > > +
> > > >  static int mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
> > > >  	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
> > > >  {
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -632,6 +632,10 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> > > >  		return;
> > > >  	}
> > > >  
> > > > +	/* Avoid waking up processes for oom kills triggered by sysrq */
> > > > +	if (!force_kill)
> > > > +		mem_cgroup_root_oom_notify();
> > > 
> > > We have an API for global OOM notifications, please just use
> > > register_oom_notifier() instead.
> > > 
> > 
> > We can't use register_oom_notifier() because we don't want to notify the 
> > root memcg for a system oom handler if existing oom notifiers free memory 
> > (powerpc or s390).  We also don't want to notify the root memcg when 
> > current is exiting or has a pending SIGKILL, we just want to silently give 
> > it access to memory reserves and exit.  The mem_cgroup_root_oom_notify() 
> > here is placed correctly.
> 
> This is all handwaving.

I'm defining the semantics of the system oom notification for the root 
memcg.  Userspace oom handlers are not going to want to wakeup when a 
kernel oom notifier is capable of freeing memory to prevent the oom killer 
from doing anything at all or if current simply needs access to memory 
reserves to make forward progress.  Userspace oom handlers want a wakeup 
when a process must be killed to free memory, and thus this is correctly 
placed.

> Somebody called out_of_memory() after they
> failed reclaim, the machine is OOM.

While momentarily oom, the oom notifiers in powerpc and s390 have the 
ability to free memory without requiring a kill.

> The fact that current is exiting
> without requiring a kill is coincidental and irrelevant.  You want an
> OOM notification, use the OOM notifiers, that's what they're for.
> 

I think you're misunderstanding the kernel oom notifiers, they exist 
solely to free memory so that the oom killer actually doesn't have to kill 
anything.  The fact that they use kernel notifiers is irrelevant and 
userspace oom notification is separate.  Userspace is only going to want a 
notification when the oom killer has to kill something, the EXACT same 
semantics as the non-root-memcg memory.oom_control.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
