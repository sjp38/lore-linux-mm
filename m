Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 2CAFA6B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 03:12:45 -0400 (EDT)
Date: Fri, 17 May 2013 09:12:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130517071240.GC25158@dhcp22.suse.cz>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
 <1368431172-6844-2-git-send-email-mhocko@suse.cz>
 <20130516221200.GF7171@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130516221200.GF7171@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 16-05-13 15:12:00, Tejun Heo wrote:
> Sorry about the delay.  Just getting back to memcg.
> 
> On Mon, May 13, 2013 at 09:46:10AM +0200, Michal Hocko wrote:
> ...
> > during the first pass. Only groups which are over their soft limit or
> > any of their parents up the hierarchy is over the limit are considered
> 
> ancestors?

Well, ancestors might or might not be part of the hierarchy, so while it
is much shorter I consider the original more precise.

> > +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > +{
> > +	bool do_soft_reclaim = mem_cgroup_should_soft_reclaim(sc);
> > +	unsigned long nr_scanned = sc->nr_scanned;
> > +
> > +	__shrink_zone(zone, sc, do_soft_reclaim);
> > +
> > +	/*
> > +	 * No group is over the soft limit or those that are do not have
> > +	 * pages in the zone we are reclaiming so we have to reclaim everybody
> > +	 */
> > +	if (do_soft_reclaim && (sc->nr_scanned == nr_scanned)) {
> > +		__shrink_zone(zone, sc, false);
> > +		return;
> > +	}
> > +}
> 
> Maybe the following is easier to follow?
> 
> 	if (mem_cgroup_should_soft_reclaim(sc)) {
> 		__shrink_zone(zone, sc, true);
> 		if (sc->nr_scanned == nr_scanned)
> 			__shrink_zone(zone, sc, false);
> 	} else {
> 		__shrink_zone(zone, sc, false);
> 	}
> 
> But it's a minor point, please feel free to ignore.

I will stick with the original code as I have some plans to build on top
of that.

>   Reviewed-by: Tejun Heo <tj@kernel.org>

Thank you!

> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
