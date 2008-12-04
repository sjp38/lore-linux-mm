Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB47FfD5017036
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 16:15:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 167A145DD76
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 16:15:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF2C345DD74
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 16:15:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EFBDC1DB803C
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 16:15:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B33EF1DB8041
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 16:15:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 08/11] memcg: make zone_reclaim_stat
In-Reply-To: <20081203140655.GG17701@balbir.in.ibm.com>
References: <20081201211646.1CE2.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081203140655.GG17701@balbir.in.ibm.com>
Message-Id: <20081204151647.1D78.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 16:15:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


> > +struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
> > +						      struct zone *zone)
> > +{
> > +	int nid = zone->zone_pgdat->node_id;
> > +	int zid = zone_idx(zone);
> > +	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> > +
> > +	return &mz->reclaim_stat;
> > +}
> > +
> > +struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat_by_page(struct page *page)
> > +{
> 
> I would prefer to use stat_from_page instead of stat_by_page, by page
> is confusing.

ok.
will fix.


> > @@ -172,6 +173,12 @@ void activate_page(struct page *page)
> > 
> >  		reclaim_stat->recent_rotated[!!file]++;
> >  		reclaim_stat->recent_scanned[!!file]++;
> > +
> > +		memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
> > +		if (memcg_reclaim_stat) {
> > +			memcg_reclaim_stat->recent_rotated[!!file]++;
> > +			memcg_reclaim_stat->recent_scanned[!!file]++;
> > +		}
> 
> Does it make sense to write two inline routines like
> 
> update_recent_rotated(page)
> {
>         zone = page_zone(page);
> 
>         zone->reclaim_stat->recent_rotated[!!file]++;
>         mem_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
>         if (mem_reclaim_stat)
>                 mem_cg_reclaim_stat->recent_rotated[!!file]++;
>         ...
> 
> }
> 
> and similarly update_recent_reclaimed(page)

makes sense. good cleanup.

will fix.



> > Index: b/mm/vmscan.c
> > ===================================================================
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -134,6 +134,9 @@ static DECLARE_RWSEM(shrinker_rwsem);
> >  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> >  						  struct scan_control *sc)
> >  {
> > +	if (!scan_global_lru(sc))
> > +		mem_cgroup_get_reclaim_stat(sc->mem_cgroup, zone);
> 
> What do we gain by just calling mem_cgroup_get_reclaim_stat? Where do
> we return/use this value?

Agghh.
My last cleanup is _not_ cleanup..

thanks! will fix.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
