Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 603976B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:31:45 -0400 (EDT)
Date: Tue, 9 Apr 2013 15:31:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130409133142.GH29860@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
 <20130409130833.GP1953@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130409130833.GP1953@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Tue 09-04-13 09:08:33, Johannes Weiner wrote:
> On Tue, Apr 09, 2013 at 02:13:13PM +0200, Michal Hocko wrote:
[...]
> > TODO: remove mem_cgroup_tree_per_zone, mem_cgroup_shrink_node_zone and co.
> > but maybe it would be easier for review to remove that code in a separate
> > patch...
> 
> It should be in this series, though, for the diffstat :-)

Sure thing, I just wanted to prevent from pointless work during rebasing
when this changes its shape, like all such "bug changes"

> 
> > ---
> > [1] TODO: put size vmlinux before/after whole clean-up
> 
> Yes!
> 
> > @@ -1984,6 +2003,27 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >  		} while (memcg);
> >  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
> >  					 sc->nr_scanned - nr_scanned, sc));
> > +
> > +	return nr_shrunk;
> > +}
> > +
> > +
> > +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > +{
> > +	bool do_soft_reclaim = mem_cgroup_should_soft_reclaim(sc);
> > +	unsigned long nr_scanned = sc->nr_scanned;
> > +	unsigned nr_shrunk;
> > +
> > +	nr_shrunk = __shrink_zone(zone, sc, do_soft_reclaim);
> > +
> > +	/*
> > +	 * No group is over the soft limit or those that are do not have
> > +	 * pages in the zone we are reclaiming so we have to reclaim everybody
> > +	 */
> > +	if (do_soft_reclaim && (!nr_shrunk || sc->nr_scanned == nr_scanned)) {
> 
> If no pages were scanned you are doing a second pass regardless of
> nr_shrunk.  If pages were scanned, nr_shrunk must have been increased
> as well.  So I think you can remove all the nr_shrunk counting and
> just check for scanned pages, no?

Yes you are right. I have started with nr_shrunk part only and then
realized that no scaning could be a problem so I've just added it. I
didn't optimize it yet.
I will remove nr_shrunk part in later versions.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
