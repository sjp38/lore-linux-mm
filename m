Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 410226B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 03:54:15 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so18782793pdj.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:54:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qn16si13282313pab.235.2015.07.10.00.54.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 00:54:14 -0700 (PDT)
Date: Fri, 10 Jul 2015 10:54:00 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150710075400.GN2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150708173251.GG2436@esperanza>
 <20150709140941.GG13872@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150709140941.GG13872@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 09, 2015 at 04:09:41PM +0200, Michal Hocko wrote:
> On Wed 08-07-15 20:32:51, Vladimir Davydov wrote:
> > On Wed, Jul 08, 2015 at 02:27:51PM +0200, Michal Hocko wrote:
[...]
> > > @@ -474,7 +519,7 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> > >  		return;
> > >  
> > >  	rcu_read_lock();
> > > -	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > > +	memcg = rcu_dereference(mm->memcg);
> > >  	if (unlikely(!memcg))
> > >  		goto out;
> > >  
> > 
> > If I'm not mistaken, mm->memcg equals NULL for any task in the root
> > memory cgroup
> 
> right
> 
> > (BTW, it it's true, it's worth mentioning in the comment
> > to mm->memcg definition IMO). As a result, we won't account the stats
> > for such tasks, will we?
> 
> well spotted! This is certainly a bug. There are more places which are
> checking for mm->memcg being NULL and falling back to root_mem_cgroup. I
> think it would be better to simply use root_mem_cgroup right away. We
> can setup init_mm.memcg = root_mem_cgroup during initialization and be
> done with it. What do you think? The diff is in the very end of the
> email (completely untested yet).

I'd prefer initializing init_mm.memcg to root_mem_cgroup. This way we
wouldn't have to check whether mm->memcg is NULL or not here and there,
which would make the code cleaner IMO.

[...]
> > > @@ -4932,14 +4943,26 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
> > >  {
> > >  	struct task_struct *p = cgroup_taskset_first(tset);
> > >  	struct mm_struct *mm = get_task_mm(p);
> > > +	struct mem_cgroup *old_memcg = NULL;
> > >  
> > >  	if (mm) {
> > > +		old_memcg = READ_ONCE(mm->memcg);
> > > +		__mm_set_memcg(mm, mem_cgroup_from_css(css));
> > > +
> > >  		if (mc.to)
> > >  			mem_cgroup_move_charge(mm);
> > >  		mmput(mm);
> > >  	}
> > >  	if (mc.to)
> > >  		mem_cgroup_clear_mc();
> > > +
> > > +	/*
> > > +	 * Be careful and drop the reference only after we are done because
> > > +	 * p's task_css memcg might be different from p->memcg and nothing else
> > > +	 * might be pinning the old memcg.
> > > +	 */
> > > +	if (old_memcg)
> > > +		css_put(&old_memcg->css);
> > 
> > Please explain why the following race is impossible:
> > 
> > CPU0					CPU1
> > ----					----
> > [current = T]
> > dup_mm or exec_mmap
> >  mm_inherit_memcg
> >   memcg = current->mm->memcg;
> > 					mem_cgroup_move_task
> > 					 p = T;
> > 					 mm = get_task_mm(p);
> > 					 old_memcg = mm->memcg;
> > 					 css_put(&old_memcg->css);
> > 					 /* old_memcg can be freed now */
> >   css_get(memcg); /*  BUG */
> 
> I guess you are right. The window seem to be very small but CPU0 simly
> might get preempted by the moving task and so even cgroup pinning
> wouldn't help here.
> 
> I guess we need
> ---
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b3e7e30b5a74..6fbd33273b6d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -300,9 +300,17 @@ void __mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
>  static inline
>  void mm_inherit_memcg(struct mm_struct *newmm, struct mm_struct *oldmm)
>  {
> -	struct mem_cgroup *memcg = oldmm->memcg;
> +	struct mem_cgroup *memcg;
>  
> +	/*
> +	 * oldmm might be under move and just replacing its memcg (see
> +	 * mem_cgroup_move_task) so we have to protect from its memcg
> +	 * going away between we dereference and take a reference.
> +	 */
> +	rcu_read_lock();
> +	memcg = rcu_dereference(oldmm->memcg);
>  	__mm_set_memcg(newmm, memcg);

If it's safe to call css_get under rcu_read_lock, then it's OK,
otherwise we probably need to use a do {} while (!css_tryget(memcg))
loop in __mm_set_memcg.

> +	rcu_read_unlock();
>  }
>  
>  /**
> 
> 
> Make sure that all tasks have non NULL memcg.
[...]

That looks better to me.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
