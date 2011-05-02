Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2B946B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 18:48:50 -0400 (EDT)
Date: Tue, 3 May 2011 00:48:38 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Message-ID: <20110502224838.GB10278@cmpxchg.org>
References: <1304366849.15370.27.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304366849.15370.27.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Balbir Singh <balbir@linux.vnet.ibm.com>

Hi,

On Mon, May 02, 2011 at 03:07:29PM -0500, James Bottomley wrote:
> The fatal livelock in kswapd, reported in this thread:
> 
> http://marc.info/?t=130392066000001
> 
> Is mitigateable if we prevent the cgroups code being so aggressive in
> its zone shrinking (by reducing it's default shrink from 0 [everything]
> to DEF_PRIORITY [some things]).  This will have an obvious knock on
> effect to cgroup accounting, but it's better than hanging systems.

Actually, it's not that obvious.  At least not to me.  I added Balbir,
who added said comment and code in the first place, to CC: Here is the
comment in full quote:

	/*
	 * NOTE: Although we can get the priority field, using it
	 * here is not a good idea, since it limits the pages we can scan.
	 * if we don't reclaim here, the shrink_zone from balance_pgdat
	 * will pick up pages from other mem cgroup's as well. We hack
	 * the priority and make it zero.
	 */

The idea is that if one memcg is above its softlimit, we prefer
reducing pages from this memcg over reclaiming random other pages,
including those of other memcgs.

But the code flow looks like this:

	balance_pgdat
	  mem_cgroup_soft_limit_reclaim
	    mem_cgroup_shrink_node_zone
	      shrink_zone(0, zone, &sc)
	  shrink_zone(prio, zone, &sc)

so the success of the inner memcg shrink_zone does at least not
explicitely result in the outer, global shrink_zone steering clear of
other memcgs' pages.  It just tries to move the pressure of balancing
the zones to the memcg with the biggest soft limit excess.  That can
only really work if the memcg is a large enough contributor to the
zone's total number of lru pages, though, and looks very likely to hit
the exceeding memcg too hard in other cases.

I am very much for removing this hack.  There is still more scan
pressure applied to memcgs in excess of their soft limit even if the
extra scan is happening at a sane priority level.  And the fact that
global reclaim operates completely unaware of memcgs is a different
story.

However, this code came into place with v2.6.31-8387-g4e41695.  Why is
it only now showing up?

You also wrote in that thread that this happens on a standard F15
installation.  On the F15 I am running here, systemd does not
configure memcgs, however.  Did you manually configure memcgs and set
soft limits?  Because I wonder how it ended up in soft limit reclaim
in the first place.

	Hannes

> Signed-off-by: James Bottomley <James.Bottomley@suse.de>
> 
> ---
> 
> >From 74b62fc417f07e1411d98181631e4e097c8e3e68 Mon Sep 17 00:00:00 2001
> From: James Bottomley <James.Bottomley@HansenPartnership.com>
> Date: Mon, 2 May 2011 14:56:29 -0500
> Subject: [PATCH] vmscan: move containers scan back to default priority
> 
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b435c..46cde92 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2173,8 +2173,12 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  	 * if we don't reclaim here, the shrink_zone from balance_pgdat
>  	 * will pick up pages from other mem cgroup's as well. We hack
>  	 * the priority and make it zero.
> +	 *
> +	 * FIXME: jejb: zero here was causing a livelock in the
> +	 * shrinker so changed to DEF_PRIORITY to fix this. Now need to
> +	 * sort out cgroup accounting.
>  	 */
> -	shrink_zone(0, zone, &sc);
> +	shrink_zone(DEF_PRIORITY, zone, &sc);
>  
>  	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
