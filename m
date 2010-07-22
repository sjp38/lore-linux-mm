Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A49226B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 01:36:29 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6M5IRRk015438
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 01:18:27 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6M5aRJj1781830
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 01:36:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6M5aQpf031811
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 01:36:27 -0400
Date: Thu, 22 Jul 2010 11:06:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/7] memcg: nid and zid can be calculated from zone
Message-ID: <20100722053624.GN14369@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100716191418.7372.A69D9226@jp.fujitsu.com>
 <20100716105648.GG13117@csn.ul.ie>
 <20100721223349.870D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100721223349.870D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-07-21 22:33:56]:

> > > +static inline int zone_nid(struct zone *zone)
> > > +{
> > > +	return zone->zone_pgdat->node_id;
> > > +}
> > > +
> > 
> > hmm, adding a helper and not converting the existing users of
> > zone->zone_pgdat may be a little confusing particularly as both types of
> > usage would exist in the same file e.g. in mem_cgroup_zone_nr_pages.
> 
> I see. here is incrementa patch.
> 
> Thanks
> 
> From 62cf765251af257c98fc92a58215d101d200e7ef Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 20 Jul 2010 11:30:14 +0900
> Subject: [PATCH] memcg: convert to zone_nid() from bare zone->zone_pgdat->node_id
> 
> Now, we have zone_nid(). this patch convert all existing users of
> zone->zone_pgdat.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 82e191f..3d5b645 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -951,7 +951,7 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>  				       struct zone *zone,
>  				       enum lru_list lru)
>  {
> -	int nid = zone->zone_pgdat->node_id;
> +	int nid = zone_nid(zone);
>  	int zid = zone_idx(zone);
>  	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
>  
> @@ -961,7 +961,7 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
>  						      struct zone *zone)
>  {
> -	int nid = zone->zone_pgdat->node_id;
> +	int nid = zone_nid(zone);
>  	int zid = zone_idx(zone);
>  	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
>  
> @@ -1006,7 +1006,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  	LIST_HEAD(pc_list);
>  	struct list_head *src;
>  	struct page_cgroup *pc, *tmp;
> -	int nid = z->zone_pgdat->node_id;
> +	int nid = zone_nid(z);
>  	int zid = zone_idx(z);
>  	struct mem_cgroup_per_zone *mz;
>  	int lru = LRU_FILE * file + active;

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
