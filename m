Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 265AF6B0087
	for <linux-mm@kvack.org>; Tue, 26 May 2015 13:20:34 -0400 (EDT)
Received: by wgme6 with SMTP id e6so34892530wgm.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:20:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fq10si19226659wib.108.2015.05.26.10.20.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 10:20:32 -0700 (PDT)
Date: Tue, 26 May 2015 13:20:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150526172019.GA12926@cmpxchg.org>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150526151149.GJ14681@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526151149.GJ14681@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>

On Tue, May 26, 2015 at 05:11:49PM +0200, Michal Hocko wrote:
> On Tue 26-05-15 10:10:11, Johannes Weiner wrote:
> > On Tue, May 26, 2015 at 01:50:06PM +0200, Michal Hocko wrote:
> > > @@ -104,7 +105,12 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
> > >  	bool match = false;
> > >  
> > >  	rcu_read_lock();
> > > -	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > > +	/*
> > > +	 * rcu_dereference would be better but mem_cgroup is not a complete
> > > +	 * type here
> > > +	 */
> > > +	task_memcg = READ_ONCE(mm->memcg);
> > > +	smp_read_barrier_depends();
> > >  	if (task_memcg)
> > >  		match = mem_cgroup_is_descendant(task_memcg, memcg);
> > >  	rcu_read_unlock();
> > 
> > This function has only one user in rmap.  If you inline it there, you
> > can use rcu_dereference() and get rid of the specialness & comment.
> 
> I am not sure I understand. struct mem_cgroup is defined in
> mm/memcontrol.c so mm/rmap.c will not see it. Or do you suggest pulling
> struct mem_cgroup out into a header with all the dependencies?

Yes, I think that would be preferrable.  It's weird that we have such
a major data structure that is used all over the mm-code but only in
the shape of pointers to an incomplete type.  It forces a bad style of
code that uses uninlinable callbacks and accessors for even the most
basic things.  There are a few functions in memcontrol.c that could
instead be static inlines or should even be implemented as part of the
code that is using them, such as mem_cgroup_get_lru_size(),
mem_cgroup_is_descendant, mem_cgroup_inactive_anon_is_low(),
mem_cgroup_lruvec_online(), mem_cgroup_swappiness(),
mem_cgroup_select_victim_node(), mem_cgroup_update_page_stat(), and
mem_cgroup_events().  Your new functions fall into the same category.

> @@ -486,29 +486,13 @@ void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
>  void mm_drop_memcg(struct mm_struct *mm)
>  {
>  	/*
> -	 * This is the last reference to mm so nobody can see
> -	 * this memcg
> +	 * We could reset mm->memcg, but the mm goes away as this is the
> +	 * last reference.
>  	 */
>  	if (mm->memcg)
>  		css_put(&mm->memcg->css);
>  }

This function is supposed to be an API call to disassociate a mm from
its memcg, but it actually doesn't do that and will leave a dangling
pointer based on assumptions it makes about how and when the caller
invokes it.  That's bad.  It's a subtle optimization with dependencies
spread across two moving parts.  The result is very fragile code which
will break things in non-obvious ways when the caller changes later on.

And what's left standing is silly too: a memcg-specific API to call
css_put(), even though struct cgroup_subsys_state and css_put() are
public API already.

Both these things are a negative side effect of struct mem_cgroup
being semi-private.  Memcg pointers are everywhere, yet we need a
public interface indirection for every simple dereference.

> @@ -5252,10 +5236,15 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
>  
>  	if (mm) {
>  		/*
> -		 * Commit to a new memcg. mc.to points to the destination
> -		 * memcg even when the current charges are not moved.
> +		 * Commit to the target memcg even when we do not move
> +		 * charges.
>  		 */
> -		mm_move_memcg(mm, mc.to);
> +		struct mem_cgroup *old_memcg = READ_ONCE(mm->memcg);
> +		struct mem_cgroup *new_memcg = mem_cgroup_from_css(css);
> +
> +		mm_set_memcg(mm, new_memcg);
> +		if (old_memcg)
> +			css_put(&old_memcg->css);

"Commit" is a problematic choice of words because of its existing
meaning in memcg of associating a page with a pre-reserved charge.

I'm not sure a comment is actually necessary here.  Reassigning
mm->memcg when moving a process pretty straight forward IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
