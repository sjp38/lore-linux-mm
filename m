Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DAA5C9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 10:08:38 -0400 (EDT)
Date: Tue, 20 Sep 2011 16:08:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 05/11] mm: move memcg hierarchy reclaim to generic
 reclaim code
Message-ID: <20110920140832.GA3571@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-6-git-send-email-jweiner@redhat.com>
 <20110920130915.GE27675@tiehlicka.suse.cz>
 <20110920132928.GA16338@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920132928.GA16338@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 20-09-11 15:29:28, Johannes Weiner wrote:
> On Tue, Sep 20, 2011 at 03:09:15PM +0200, Michal Hocko wrote:
> > On Mon 12-09-11 12:57:22, Johannes Weiner wrote:
> > > Memory cgroup limit reclaim and traditional global pressure reclaim
> > > will soon share the same code to reclaim from a hierarchical tree of
> > > memory cgroups.
> > > 
> > > In preparation of this, move the two right next to each other in
> > > shrink_zone().
> > 
> > I like the way how you've split mem_cgroup_hierarchical_reclaim into
> > mem_cgroup_reclaim and mem_cgroup_soft_reclaim and I guess this deserves
> > a note in the patch description. Especially that mem_cgroup_reclaim is
> > hierarchical even though it doesn't use mem_cgroup_iter directly but
> > rather via do_try_to_free_pages and shrink_zone.
> > 
> > I am not sure I see how shrink_mem_cgroup_zone works. See comments and
> > questions bellow:
> > 
> > > 
> > > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > > ---
> > >  include/linux/memcontrol.h |   25 ++++++-
> > >  mm/memcontrol.c            |  167 ++++++++++++++++++++++----------------------
> > >  mm/vmscan.c                |   43 ++++++++++-
> > >  3 files changed, 147 insertions(+), 88 deletions(-)
> > > 
> > [...]
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index f4b404e..413e1f8 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > [...]
> > > @@ -783,19 +781,33 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> > >  	return memcg;
> > >  }
> > >  
> > > -struct mem_cgroup_iter {
> > > -	struct zone *zone;
> > > -	int priority;
> > > -	unsigned int generation;
> > > -};
> > > -
> > > -static struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> > > -					  struct mem_cgroup *prev,
> > > -					  struct mem_cgroup_iter *iter)
> > > +/**
> > > + * mem_cgroup_iter - iterate over memory cgroup hierarchy
> > > + * @root: hierarchy root
> > > + * @prev: previously returned memcg, NULL on first invocation
> > > + * @iter: token for partial walks, NULL for full walks
> > > + *
> > > + * Returns references to children of the hierarchy starting at @root,
> > 
> > I guess you meant "starting at @prev"
> 
> Nope, although it is a bit ambiguous, both the hierarchy as well as
> the iteration start at @root.  Unless @iter is specified, but then the
> hierarchy still starts at @root.

OK I guess I see where my misundestanding comes from. You are describing
the function in the way how is it supposed to be used (with prev=NULL
and then reusing the return value). I was thinking about general
description where someone wants to provide a prev and expects that the
function would return a next group under the hierarchy. In that case we
would have to go into ids so this is probably better.

> 
> I attached a patch below that fixes the phrasing.

Makes more sense.

[...]
> > > @@ -2104,12 +2104,43 @@ restart:
> > >  static void shrink_zone(int priority, struct zone *zone,
> > >  			struct scan_control *sc)
> > >  {
> > > -	struct mem_cgroup_zone mz = {
> > > -		.mem_cgroup = sc->target_mem_cgroup,
> > > +	struct mem_cgroup *root = sc->target_mem_cgroup;
> > > +	struct mem_cgroup_iter iter = {
> > >  		.zone = zone,
> > > +		.priority = priority,
> > >  	};
> > > +	struct mem_cgroup *mem;
> > > +
> > > +	if (global_reclaim(sc)) {
> > > +		struct mem_cgroup_zone mz = {
> > > +			.mem_cgroup = NULL,
> > > +			.zone = zone,
> > > +		};
> > > +
> > > +		shrink_mem_cgroup_zone(priority, &mz, sc);
> > > +		return;
> > > +	}
> > > +
> > > +	mem = mem_cgroup_iter(root, NULL, &iter);
> > > +	do {
> > > +		struct mem_cgroup_zone mz = {
> > > +			.mem_cgroup = mem,
> > > +			.zone = zone,
> > > +		};
> > >  
> > > -	shrink_mem_cgroup_zone(priority, &mz, sc);
> > > +		shrink_mem_cgroup_zone(priority, &mz, sc);
> > > +		/*
> > > +		 * Limit reclaim has historically picked one memcg and
> > > +		 * scanned it with decreasing priority levels until
> > > +		 * nr_to_reclaim had been reclaimed.  This priority
> > > +		 * cycle is thus over after a single memcg.
> > > +		 */
> > > +		if (!global_reclaim(sc)) {
> > 
> > How can we have global_reclaim(sc) == true here?
> 
> We can't yet, but will when global reclaim and limit reclaim use that
> same loop a patch or two later.  

OK, I see. Still a bit tricky for review, though.

> I added it early to have an anchor for the comment above it, so that
> it's obvious how limit reclaim behaves, and that I don't have to
> change limit reclaim-specific conditions when changing how global
> reclaim works.
> 
> > Shouldn't we just check how much have we reclaimed from that group and
> > iterate only if it wasn't sufficient (at least SWAP_CLUSTER_MAX)?
> 
> I played with various exit conditions and in the end just left the
> behaviour exactly like we had it before this patch, just that the
> algorithm is now inside out.  If you want to make such a fundamental
> change, you have to prove it works :-)

OK, I see.

> 
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

For the whole patch.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a7d14a5..349620c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -784,8 +784,8 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>   * @prev: previously returned memcg, NULL on first invocation
>   * @iter: token for partial walks, NULL for full walks
>   *
> - * Returns references to children of the hierarchy starting at @root,
> - * or @root itself, or %NULL after a full round-trip.
> + * Returns references to children of the hierarchy below @root, or
> + * @root itself, or %NULL after a full round-trip.
>   *
>   * Caller must pass the return value in @prev on subsequent
>   * invocations for reference counting, or use mem_cgroup_iter_break()
> @@ -1493,7 +1493,8 @@ static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
>  		total += try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap);
>  		/*
>  		 * Avoid freeing too much when shrinking to resize the
> -		 * limit.  XXX: Shouldn't the margin check be enough?
> +		 * limit, and bail easily so that signals have a
> +		 * chance to kill the resizing task.
>  		 */
>  		if (total && (flags & MEM_CGROUP_RECLAIM_SHRINK))
>  			break;
> 
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
