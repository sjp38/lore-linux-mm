Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9366B0037
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 09:53:18 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id x48so1885448wes.18
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 06:53:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id du3si1621150wib.66.2014.02.13.06.53.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 06:53:15 -0800 (PST)
Date: Thu, 13 Feb 2014 15:53:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: barriers to see memcgs as fully initialized
Message-ID: <20140213145314.GC11986@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1402121717420.5917@eggly.anvils>
 <alpine.LSU.2.11.1402121727050.5917@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402121727050.5917@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 12-02-14 17:29:09, Hugh Dickins wrote:
> Commit d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully
> initialized") is not bad, but Greg Thelen asks "Are barriers needed?"
> 
> Yes, I'm afraid so: this makes it a little heavier than the original,
> but there's no point in guaranteeing that mem_cgroup_iter() returns only
> fully initialized memcgs, if we don't guarantee that the initialization
> is visible.
> 
> If we move online_css()'s setting CSS_ONLINE after rcu_assign_pointer()
> (I don't see why not), we can reasonably rely on the smp_wmb() in that.
> But I can't find a pre-existing barrier at the mem_cgroup_iter() end,
> so add an smp_rmb() where __mem_cgroup_iter_next() returns non-NULL.
> 
> Fixes: d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully initialized")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # 3.12+
> ---
> I'd have been happier not to have to add this patch: maybe you can see
> a better placement, or a way we can avoid this altogether.

I don't know. I have thought about this again and I really do not see
why we have to provide such a guarantee, to be honest.

Such a half initialized memcg wouldn't see its hierarchical parent
properly (including inheritted attributes) and it wouldn't have kmem
fully initialized. But it also wouldn't have any tasks in it IIRC so it
shouldn't matter much.

So I really don't know whether this all is worth all the troubles. 
I am not saying your patch is wrong (although I am not sure whether
css->flags vs. subsystem css association ordering is relevant and
ae7f164a09408 changelog didn't help me much) and it made sense when
you proposed it back then but the additional ordering requirements
complicates the thing.

I will keep thinking about that.

>  kernel/cgroup.c |    8 +++++++-
>  mm/memcontrol.c |   11 +++++++++--
>  2 files changed, 16 insertions(+), 3 deletions(-)
> 
> --- 3.14-rc2+/kernel/cgroup.c	2014-02-02 18:49:07.737302111 -0800
> +++ linux/kernel/cgroup.c	2014-02-12 11:59:52.804041895 -0800
> @@ -4063,9 +4063,15 @@ static int online_css(struct cgroup_subs
>  	if (ss->css_online)
>  		ret = ss->css_online(css);
>  	if (!ret) {
> -		css->flags |= CSS_ONLINE;
>  		css->cgroup->nr_css++;
>  		rcu_assign_pointer(css->cgroup->subsys[ss->subsys_id], css);
> +		/*
> +		 * Set CSS_ONLINE after rcu_assign_pointer(), so that its
> +		 * smp_wmb() will guarantee that those seeing CSS_ONLINE
> +		 * can see the initialization done in ss->css_online() - if
> +		 * they provide an smp_rmb(), as in __mem_cgroup_iter_next().
> +		 */
> +		css->flags |= CSS_ONLINE;
>  	}
>  	return ret;
>  }
> --- 3.14-rc2+/mm/memcontrol.c	2014-02-12 11:55:02.836035004 -0800
> +++ linux/mm/memcontrol.c	2014-02-12 11:59:52.804041895 -0800
> @@ -1128,9 +1128,16 @@ skip_node:
>  	 */
>  	if (next_css) {
>  		if ((next_css == &root->css) ||
> -		    ((next_css->flags & CSS_ONLINE) && css_tryget(next_css)))
> +		    ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))) {
> +			/*
> +			 * Ensure that all memcg initialization, done before
> +			 * CSS_ONLINE was set, will be visible to our caller.
> +			 * This matches the smp_wmb() in online_css()'s
> +			 * rcu_assign_pointer(), before it set CSS_ONLINE.
> +			 */
> +			smp_rmb();
>  			return mem_cgroup_from_css(next_css);
> -
> +		}
>  		prev_css = next_css;
>  		goto skip_node;
>  	}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
