Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4295F6B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:19:20 -0500 (EST)
Received: by lfcy184 with SMTP id y184so49096919lfc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:19:19 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bc6si46458657wjc.161.2015.12.14.07.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:19:19 -0800 (PST)
Date: Mon, 14 Dec 2015 10:19:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: fix possible memcg leak due to
 interrupted reclaim
Message-ID: <20151214151901.GA13289@cmpxchg.org>
References: <1449927242-9608-1-git-send-email-vdavydov@virtuozzo.com>
 <20151212164540.GA7107@cmpxchg.org>
 <20151212191855.GE28521@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151212191855.GE28521@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 12, 2015 at 10:18:55PM +0300, Vladimir Davydov wrote:
> On Sat, Dec 12, 2015 at 11:45:40AM -0500, Johannes Weiner wrote:
> > @@ -2425,21 +2425,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> >  				   sc->nr_scanned - scanned,
> >  				   sc->nr_reclaimed - reclaimed);
> >  
> > -			/*
> > -			 * Direct reclaim and kswapd have to scan all memory
> > -			 * cgroups to fulfill the overall scan target for the
> > -			 * zone.
> > -			 *
> > -			 * Limit reclaim, on the other hand, only cares about
> > -			 * nr_to_reclaim pages to be reclaimed and it will
> > -			 * retry with decreasing priority if one round over the
> > -			 * whole hierarchy is not sufficient.
> > -			 */
> > -			if (!global_reclaim(sc) &&
> > -					sc->nr_reclaimed >= sc->nr_to_reclaim) {
> > -				mem_cgroup_iter_break(root, memcg);
> > -				break;
> > -			}
> 
> Dunno. I like it, because it's simple and clean, but I'm unsure: can't
> it result in lags when performing memcg reclaim for deep hierarchies?
> For global reclaim we have kswapd, which tries to keep the system within
> bounds so as to avoid direct reclaim at all. Memcg lacks such thing, and
> interleave walks looks like a good compensation for it.
> 
> Alternatively, we could avoid taking reference to iter->position and
> make use of css_released cgroup callback to invalidate reclaim
> iterators. With this approach, upper level cgroups shouldn't receive
> unfairly high pressure in comparison to their children. Something like
> this, maybe?

This is surprisingly simple, to the point where I'm asking myself if I
miss something in this patch or if I missed something when I did weak
references the last time. But I think the last time we didn't want to
go through all iterator positions like we do here. It doesn't really
matter, though, that's even performed from a work item.

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 87af26a24491..fcc5133210a0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -859,14 +859,12 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  		if (prev && reclaim->generation != iter->generation)
>  			goto out_unlock;
>  
> -		do {
> +		while (1) {
>  			pos = READ_ONCE(iter->position);
> -			/*
> -			 * A racing update may change the position and
> -			 * put the last reference, hence css_tryget(),
> -			 * or retry to see the updated position.
> -			 */
> -		} while (pos && !css_tryget(&pos->css));
> +			if (!pos || css_tryget(&pos->css))
> +				break;
> +			cmpxchg(&iter->position, pos, NULL);
> +		}

This cmpxchg() looks a little strange. Once tryget fails, the iterator
should be clear soon enough, no? If not, a comment would be good here.

> @@ -912,12 +910,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  	}
>  
>  	if (reclaim) {
> -		if (cmpxchg(&iter->position, pos, memcg) == pos) {
> -			if (memcg)
> -				css_get(&memcg->css);
> -			if (pos)
> -				css_put(&pos->css);
> -		}
> +		cmpxchg(&iter->position, pos, memcg);

This looks correct. The next iteration or break will put the memcg,
potentially free it, which will clear it from the iterator and then
rcu-free the css. Anybody who sees a pointer set under the RCU lock
can safely run css_tryget() against it. Awesome!

Care to resend this with changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
