Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 1F8E86B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 10:22:17 -0400 (EDT)
Date: Tue, 9 Apr 2013 16:22:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130409142213.GK29860@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
 <51641E62.2070704@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51641E62.2070704@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On Tue 09-04-13 17:57:54, Glauber Costa wrote:
> On 04/09/2013 04:13 PM, Michal Hocko wrote:
[...]
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
> > +		__shrink_zone(zone, sc, false);
> > +		return;
> > +	}
> >  }
> 
> If I read this correctly, you stop shrinking when you reach a group in
> which you manage to shrink some pages. Is it really what we want?

Well, this is what we do during standard reclaim __shrink_zone either
walks all children of the target_memcg or reclaim enough pages.

> We have no guarantee that we're now under the soft limit, so shouldn't
> we keep shrinking downwards until every parent of ours is within limits ?

I do not think we should reclaim until we are under soft limit because
our primary target is different - balance zones resp. get under hard
limit. Soft limit just helps us to point at victims (and newly also to
protect high class citizens).

So the second round is just a way to reclaim at least something if
the is nobody eligible for the soft game part. I can see some harder
conditions for the fallback (e.g. only fallback after certain priority
but let's keep this simple for now and do additional parts on top).

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
