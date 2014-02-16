Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EA9FF6B003B
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 21:53:05 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so13476277pdj.17
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 18:53:05 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id bf5si10494644pad.233.2014.02.15.18.53.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 18:53:04 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so13836791pbb.6
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 18:53:04 -0800 (PST)
Date: Sat, 15 Feb 2014 18:52:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] memcg: barriers to see memcgs as fully initialized
In-Reply-To: <20140213145314.GC11986@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1402151752530.9356@eggly.anvils>
References: <alpine.LSU.2.11.1402121717420.5917@eggly.anvils> <alpine.LSU.2.11.1402121727050.5917@eggly.anvils> <20140213145314.GC11986@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 13 Feb 2014, Michal Hocko wrote:
> On Wed 12-02-14 17:29:09, Hugh Dickins wrote:
> > Commit d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully
> > initialized") is not bad, but Greg Thelen asks "Are barriers needed?"
> > 
> > Yes, I'm afraid so: this makes it a little heavier than the original,
> > but there's no point in guaranteeing that mem_cgroup_iter() returns only
> > fully initialized memcgs, if we don't guarantee that the initialization
> > is visible.
> > 
> > If we move online_css()'s setting CSS_ONLINE after rcu_assign_pointer()
> > (I don't see why not), we can reasonably rely on the smp_wmb() in that.
> > But I can't find a pre-existing barrier at the mem_cgroup_iter() end,
> > so add an smp_rmb() where __mem_cgroup_iter_next() returns non-NULL.
> > 
> > Fixes: d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully initialized")
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Cc: stable@vger.kernel.org # 3.12+
> > ---
> > I'd have been happier not to have to add this patch: maybe you can see
> > a better placement, or a way we can avoid this altogether.
> 
> I don't know. I have thought about this again and I really do not see
> why we have to provide such a guarantee, to be honest.
> 
> Such a half initialized memcg wouldn't see its hierarchical parent
> properly (including inheritted attributes) and it wouldn't have kmem
> fully initialized. But it also wouldn't have any tasks in it IIRC so it
> shouldn't matter much.
> 
> So I really don't know whether this all is worth all the troubles. 
> I am not saying your patch is wrong (although I am not sure whether
> css->flags vs. subsystem css association ordering is relevant and
> ae7f164a09408 changelog didn't help me much) and it made sense when
> you proposed it back then but the additional ordering requirements
> complicates the thing.

Your feelings match mine exactly: nice enough when it was just a matter
of testing a flag, but rather a bore to have to go adding barriers.
And Tejun didn't like it either, would prefer the barriers to be
internal to memcg, if we really need them.

No surprise: it's why I made it an easily skippable 2/2.
Let's forget this patch - but I still don't want to remove the
CSS_ONLINE check, not yet anyway.

At the time I added that check, I only had out-of-tree changes
and lockdep weirdness in support of it.  I did spend a little time
yesterday looking to see if there's a stronger case, thought I'd
found one, but looking again don't see it - I think I was muddling
stats with RES_USAGE.

The kind of case I was looking for was stats gathering doing a
res_counter_read_u64() inside a for_each_mem_cgroup() loop.  On
a 32-bit kernel, res_counter_read_u64() has to use the spinlock
which is not initialized until mem_cgroup_css_online().  Which
it should manage with unadorned ticket lock, but then the unlock
might race with its initialization (I'm not sure how that will
then behave).  But actually I don't think stats gathering ever
does iterative res_counter_reads (and there may be good design
reasons why that would never make sense).

Now I do see the existing mem_cgroup_soft_reclaim() doing a 
res_counter_soft_limit_excess() in a mem_cgroup_iter() loop:
I guess that is vulnerable, even on 64-bit, and a lot safer
with the CSS_ONLINE check, even lacking barriers.

I'm thinking that we'd be safer if those res_counters
initialized in mem_cgroup_css_online() could be initialized in
mem_cgroup_css_alloc(), then updated in mem_cgroup_css_online();
but I don't think res_counter.c offers that option today,
not to change parent (or could parent be set from the start?
maybe that gets into races with setting use_hierarchy).

I haven't looked into what memcg_init_kmem() gets up to,
and whether that's safe before it's initialized.

Not something urgent I'm intending to rush into, and please don't
feel you need rush to respond, these are just thoughts for later:
let's move away from the CSS_ONLINE check and barriers, and
towards having the struct mem_cgroup sensibly initialized earlier.

Hugh

> 
> I will keep thinking about that.
> 
> >  kernel/cgroup.c |    8 +++++++-
> >  mm/memcontrol.c |   11 +++++++++--
> >  2 files changed, 16 insertions(+), 3 deletions(-)
> > 
> > --- 3.14-rc2+/kernel/cgroup.c	2014-02-02 18:49:07.737302111 -0800
> > +++ linux/kernel/cgroup.c	2014-02-12 11:59:52.804041895 -0800
> > @@ -4063,9 +4063,15 @@ static int online_css(struct cgroup_subs
> >  	if (ss->css_online)
> >  		ret = ss->css_online(css);
> >  	if (!ret) {
> > -		css->flags |= CSS_ONLINE;
> >  		css->cgroup->nr_css++;
> >  		rcu_assign_pointer(css->cgroup->subsys[ss->subsys_id], css);
> > +		/*
> > +		 * Set CSS_ONLINE after rcu_assign_pointer(), so that its
> > +		 * smp_wmb() will guarantee that those seeing CSS_ONLINE
> > +		 * can see the initialization done in ss->css_online() - if
> > +		 * they provide an smp_rmb(), as in __mem_cgroup_iter_next().
> > +		 */
> > +		css->flags |= CSS_ONLINE;
> >  	}
> >  	return ret;
> >  }
> > --- 3.14-rc2+/mm/memcontrol.c	2014-02-12 11:55:02.836035004 -0800
> > +++ linux/mm/memcontrol.c	2014-02-12 11:59:52.804041895 -0800
> > @@ -1128,9 +1128,16 @@ skip_node:
> >  	 */
> >  	if (next_css) {
> >  		if ((next_css == &root->css) ||
> > -		    ((next_css->flags & CSS_ONLINE) && css_tryget(next_css)))
> > +		    ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))) {
> > +			/*
> > +			 * Ensure that all memcg initialization, done before
> > +			 * CSS_ONLINE was set, will be visible to our caller.
> > +			 * This matches the smp_wmb() in online_css()'s
> > +			 * rcu_assign_pointer(), before it set CSS_ONLINE.
> > +			 */
> > +			smp_rmb();
> >  			return mem_cgroup_from_css(next_css);
> > -
> > +		}
> >  		prev_css = next_css;
> >  		goto skip_node;
> >  	}
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
