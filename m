Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 129206B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 11:31:34 -0400 (EDT)
Date: Mon, 26 Mar 2012 17:31:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6 1/7] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
Message-ID: <20120326153131.GA22715@tiehlicka.suse.cz>
References: <20120322214944.27814.42039.stgit@zurg>
 <20120322215616.27814.40563.stgit@zurg>
 <20120326150429.GA22754@tiehlicka.suse.cz>
 <20120326151815.GA1820@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120326151815.GA1820@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@parallels.com>

On Mon 26-03-12 17:18:15, Johannes Weiner wrote:
> On Mon, Mar 26, 2012 at 05:04:29PM +0200, Michal Hocko wrote:
> > [Adding Johannes to CC]
> > 
> > On Fri 23-03-12 01:56:16, Konstantin Khlebnikov wrote:
> > > From: Hugh Dickins <hughd@google.com>
> > > 
> > > Although one has to admire the skill with which it has been concealed,
> > > scanning_global_lru(mz) is actually just an interesting way to test
> > > mem_cgroup_disabled().  Too many developer hours have been wasted on
> > > confusing it with global_reclaim(): just use mem_cgroup_disabled().
> > 
> > Is this really correct?
> 
> Yes, if the memory controller is enabled, we never have a global LRU
> and always scan the per-memcg lists.
> 
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> > > Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> > > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Acked-by: Glauber Costa <glommer@parallels.com>
> > > ---
> > >  mm/vmscan.c |   18 ++++--------------
> > >  1 files changed, 4 insertions(+), 14 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 49f15ef..c684f44 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > [...]
> > > @@ -1806,7 +1796,7 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
> > >  	if (!total_swap_pages)
> > >  		return 0;
> > >  
> > > -	if (!scanning_global_lru(mz))
> > > +	if (!mem_cgroup_disabled())
> > >  		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
> > >  						       mz->zone);
> > 
> > mem_cgroup_inactive_anon_is_low calculation is slightly different than
> > what we have for cgroup_disabled case. calculate_zone_inactive_ratio
> > considers _all_ present pages in the zone while memcg variant only
> > active+inactive.
> 
> The memcg has nothing to go by but actual number of LRU pages; there
> is no 'present pages' equivalent.

Yes

> I don't think that it matters much in reality given the sqrt scale,
> but the difference is still unfortunate.  

OK you are probably right that the scale is too small to be a problem.
I guess that a note about changed ratio calculation should be added to
the changelog.

> Konstantin was meaning to unify all this, though.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
