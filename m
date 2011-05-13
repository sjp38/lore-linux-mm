Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3BFB46B0024
	for <linux-mm@kvack.org>; Fri, 13 May 2011 02:59:12 -0400 (EDT)
Date: Fri, 13 May 2011 08:58:54 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 2/6] vmscan: make distinction between memcg reclaim
 and LRU list selection
Message-ID: <20110513065854.GB18610@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
 <20110513085027.25b25a47.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110513085027.25b25a47.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 13, 2011 at 08:50:27AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 12 May 2011 16:53:54 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > The reclaim code has a single predicate for whether it currently
> > reclaims on behalf of a memory cgroup, as well as whether it is
> > reclaiming from the global LRU list or a memory cgroup LRU list.
> > 
> > Up to now, both cases always coincide, but subsequent patches will
> > change things such that global reclaim will scan memory cgroup lists.
> > 
> > This patch adds a new predicate that tells global reclaim from memory
> > cgroup reclaim, and then changes all callsites that are actually about
> > global reclaim heuristics rather than strict LRU list selection.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> 
> Hmm, isn't it better to merge this to patches where the meaning of
> new variable gets clearer ?

I apologize for the confusing order.  I am going to merge them.

> >  mm/vmscan.c |   96 ++++++++++++++++++++++++++++++++++------------------------
> >  1 files changed, 56 insertions(+), 40 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index f6b435c..ceeb2a5 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -104,8 +104,12 @@ struct scan_control {
> >  	 */
> >  	reclaim_mode_t reclaim_mode;
> >  
> > -	/* Which cgroup do we reclaim from */
> > -	struct mem_cgroup *mem_cgroup;
> > +	/*
> > +	 * The memory cgroup we reclaim on behalf of, and the one we
> > +	 * are currently reclaiming from.
> > +	 */
> > +	struct mem_cgroup *memcg;
> > +	struct mem_cgroup *current_memcg;
> >  
> 
> I wonder if you avoid renaming exisiting one, the patch will
> be clearer...

I renamed it mostly because I thought current_mem_cgroup too long.
It's probably best if both get more descriptive names.

> > @@ -154,16 +158,24 @@ static LIST_HEAD(shrinker_list);
> >  static DECLARE_RWSEM(shrinker_rwsem);
> >  
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > -#define scanning_global_lru(sc)	(!(sc)->mem_cgroup)
> > +static bool global_reclaim(struct scan_control *sc)
> > +{
> > +	return !sc->memcg;
> > +}
> > +static bool scanning_global_lru(struct scan_control *sc)
> > +{
> > +	return !sc->current_memcg;
> > +}
> 
> 
> Could you add comments ?

Yes, I will.

Thanks for your input!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
