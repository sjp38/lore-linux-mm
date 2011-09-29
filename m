Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E810F9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 03:56:12 -0400 (EDT)
Date: Thu, 29 Sep 2011 09:55:54 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 03/11] mm: vmscan: distinguish between memcg triggering
 reclaim and memcg being scanned
Message-ID: <20110929075554.GA6050@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-4-git-send-email-jweiner@redhat.com>
 <20110919142955.GG21847@tiehlicka.suse.cz>
 <20110920085811.GC11489@redhat.com>
 <20110920091738.GD27675@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920091738.GD27675@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 20, 2011 at 11:17:38AM +0200, Michal Hocko wrote:
> On Tue 20-09-11 10:58:11, Johannes Weiner wrote:
> > On Mon, Sep 19, 2011 at 04:29:55PM +0200, Michal Hocko wrote:
> > > On Mon 12-09-11 12:57:20, Johannes Weiner wrote:
> > > > @@ -2390,6 +2413,18 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> > > >  }
> > > >  #endif
> > > >  
> > > > +static void age_active_anon(struct zone *zone, struct scan_control *sc,
> > > > +			    int priority)
> > > > +{
> > > > +	struct mem_cgroup_zone mz = {
> > > > +		.mem_cgroup = NULL,
> > > > +		.zone = zone,
> > > > +	};
> > > > +
> > > > +	if (inactive_anon_is_low(&mz))
> > > > +		shrink_active_list(SWAP_CLUSTER_MAX, &mz, sc, priority, 0);
> > > > +}
> > > > +
> > > 
> > > I do not like this very much because we are using a similar construct in
> > > shrink_mem_cgroup_zone so we are duplicating that code. 
> > > What about adding age_mem_cgroup_active_anon (something like shrink_zone).
> > 
> > I am not sure I follow and I don't see what could be shared between
> > the zone shrinking and this as there are different exit conditions to
> > the hierarchy walk.  Can you elaborate?
> 
> Sorry for not being clear enough. Maybe it is not very much important
> but what about something like:
> 
> Index: linus_tree/mm/vmscan.c
> ===================================================================
> --- linus_tree.orig/mm/vmscan.c	2011-09-20 11:07:57.000000000 +0200
> +++ linus_tree/mm/vmscan.c	2011-09-20 11:12:53.000000000 +0200
> @@ -2041,6 +2041,13 @@ static inline bool should_continue_recla
>  	}
>  }
>  
> +static void age_mem_cgroup_active_anon(struct mem_cgroup_zone *mz,
> +		struct scan_control *sc, int priority)
> +{
> +	if (inactive_anon_is_low(mz))
> +		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
> +}
> +
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> @@ -2090,8 +2097,7 @@ restart:
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
> -	if (inactive_anon_is_low(mz))
> -		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
> +	age_mem_cgroup_active_anon(mz, sc, priority);
>  
>  	/* reclaim/compaction might need reclaim to continue */
>  	if (should_continue_reclaim(mz, nr_reclaimed,
> @@ -2421,8 +2427,7 @@ static void age_active_anon(struct zone
>  		.zone = zone,
>  	};
>  
> -	if (inactive_anon_is_low(&mz))
> -		shrink_active_list(SWAP_CLUSTER_MAX, &mz, sc, priority, 0);
> +	age_mem_cgroup_active_anon(&mz, sc, priority);
>  }

Ahh, understood.

I think it would be an unrelated change, though.  There already are
two of those constructs, I just move one of them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
