Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id AB5166B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 11:00:53 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l126so71405320wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 08:00:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id iy10si26479076wjb.155.2015.12.18.08.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 08:00:52 -0800 (PST)
Date: Fri, 18 Dec 2015 11:00:41 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: memcontrol: fix possible memcg leak due to
 interrupted reclaim
Message-ID: <20151218160041.GA4201@cmpxchg.org>
References: <1450182697-11049-1-git-send-email-vdavydov@virtuozzo.com>
 <20151217150217.a02c264ce9b5335b02bae888@linux-foundation.org>
 <20151218153202.GS28521@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151218153202.GS28521@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 18, 2015 at 06:32:02PM +0300, Vladimir Davydov wrote:
> On Thu, Dec 17, 2015 at 03:02:17PM -0800, Andrew Morton wrote:
> > On Tue, 15 Dec 2015 15:31:37 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> > > @@ -859,14 +859,20 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> > >  		if (prev && reclaim->generation != iter->generation)
> > >  			goto out_unlock;
> > >  
> > > -		do {
> > > +		while (1) {
> > >  			pos = READ_ONCE(iter->position);
> > > +			if (!pos || css_tryget(&pos->css))
> > > +				break;
> > >  			/*
> > > -			 * A racing update may change the position and
> > > -			 * put the last reference, hence css_tryget(),
> > > -			 * or retry to see the updated position.
> > > +			 * css reference reached zero, so iter->position will
> > > +			 * be cleared by ->css_released. However, we should not
> > > +			 * rely on this happening soon, because ->css_released
> > > +			 * is called from a work queue, and by busy-waiting we
> > > +			 * might block it. So we clear iter->position right
> > > +			 * away.
> > >  			 */
> > > -		} while (pos && !css_tryget(&pos->css));
> > > +			cmpxchg(&iter->position, pos, NULL);
> > > +		}
> > 
> > It's peculiar to use cmpxchg() without actually checking that it did
> > anything.  Should we use xchg() here?  And why aren't we using plain
> > old "=", come to that?
> 
> Well, it's obvious why we need the 'compare' part - the iter could have
> been already advanced by a competing process, in which case we shouldn't
> touch it, otherwise we would reclaim some cgroup twice during the same
> reclaim generation. However, it's not that clear why it must be atomic.
> Before this patch, atomicity was necessary to guarantee that we adjust
> the reference counters correctly, but now we don't do it anymore. If a
> competing process happens to update iter->position between the compare
> and set steps, we might reclaim from the same cgroup twice at worst, and
> this extremely unlikely to happen.
> 
> So I think we can replace the atomic operation with a non-atomic one,
> like the patch below does. Any objections?

I don't think the race window is actually that small and reclaiming a
group twice could cause sporadic latency issues in the victim group.
Think about the group not just trimming caches but already swapping.

The cmpxchg()s without checking the return values look odd without a
comment, but that doesn't mean that they're wrong in this situation:
advance the iterator from what we think is the current position, and
don't if somebody beat us to that. That's what cmpxchg() does. So I'd
rather we kept them here.

> @@ -902,7 +903,15 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  	}
>  
>  	if (reclaim) {
> -		cmpxchg(&iter->position, pos, memcg);
> +		/*
> +		 * The position could have already been updated by a competing
> +		 * thread, so check that the value hasn't changed since we read
> +		 * it. This operation doesn't need to be atomic, because a race
> +		 * is extremely unlikely and in the worst case can only result
> +		 * in the same cgroup reclaimed twice.

But it would be good to add the first half of that comment to the
cmpxchg to explain why we don't have to check the return value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
