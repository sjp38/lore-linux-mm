Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E5FC9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 04:58:23 -0400 (EDT)
Date: Tue, 20 Sep 2011 10:58:11 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 03/11] mm: vmscan: distinguish between memcg triggering
 reclaim and memcg being scanned
Message-ID: <20110920085811.GC11489@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-4-git-send-email-jweiner@redhat.com>
 <20110919142955.GG21847@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110919142955.GG21847@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 19, 2011 at 04:29:55PM +0200, Michal Hocko wrote:
> On Mon 12-09-11 12:57:20, Johannes Weiner wrote:
> > Memory cgroup hierarchies are currently handled completely outside of
> > the traditional reclaim code, which is invoked with a single memory
> > cgroup as an argument for the whole call stack.
> > 
> > Subsequent patches will switch this code to do hierarchical reclaim,
> > so there needs to be a distinction between a) the memory cgroup that
> > is triggering reclaim due to hitting its limit and b) the memory
> > cgroup that is being scanned as a child of a).
> > 
> > This patch introduces a struct mem_cgroup_zone that contains the
> > combination of the memory cgroup and the zone being scanned, which is
> > then passed down the stack instead of the zone argument.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> Looks good to me. Some minor comments bellow
> Anyways:
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> > @@ -1853,13 +1865,13 @@ static int vmscan_swappiness(struct scan_control *sc)
> >   *
> >   * nr[0] = anon pages to scan; nr[1] = file pages to scan
> >   */
> > -static void get_scan_count(struct zone *zone, struct scan_control *sc,
> > -					unsigned long *nr, int priority)
> > +static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
> > +			   unsigned long *nr, int priority)
> >  {
> >  	unsigned long anon, file, free;
> >  	unsigned long anon_prio, file_prio;
> >  	unsigned long ap, fp;
> > -	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> > +	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
> >  	u64 fraction[2], denominator;
> >  	enum lru_list l;
> >  	int noswap = 0;
> 
> You can save some patch lines by:
> 	struct zone *zone = mz->zone;
> and not doing zone => mz->zone changes that follow.

Actually, I really hate that I had to do that local zone variable in
other places.  I only did it where it's used so often that it would
have changed every other line.  If you insist, I'll change it, but I
would prefer to avoid it when possible.

> > @@ -2390,6 +2413,18 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> >  }
> >  #endif
> >  
> > +static void age_active_anon(struct zone *zone, struct scan_control *sc,
> > +			    int priority)
> > +{
> > +	struct mem_cgroup_zone mz = {
> > +		.mem_cgroup = NULL,
> > +		.zone = zone,
> > +	};
> > +
> > +	if (inactive_anon_is_low(&mz))
> > +		shrink_active_list(SWAP_CLUSTER_MAX, &mz, sc, priority, 0);
> > +}
> > +
> 
> I do not like this very much because we are using a similar construct in
> shrink_mem_cgroup_zone so we are duplicating that code. 
> What about adding age_mem_cgroup_active_anon (something like shrink_zone).

I am not sure I follow and I don't see what could be shared between
the zone shrinking and this as there are different exit conditions to
the hierarchy walk.  Can you elaborate?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
