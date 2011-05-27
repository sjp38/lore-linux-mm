Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA9C6B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 04:32:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 160883EE0BC
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:13 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAF8D45DE69
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2EA845DE67
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C4E781DB803C
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 815AF1DB8038
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:12 +0900 (JST)
Date: Fri, 27 May 2011 17:25:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 3/10] memcg: a test whether zone is reclaimable
 or not
Message-Id: <20110527172522.776a9e26.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=Ado5+B2t02PLq10xhh4310F-S9Q@mail.gmail.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526141909.ec42113e.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=Ado5+B2t02PLq10xhh4310F-S9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Fri, 27 May 2011 00:21:31 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, May 25, 2011 at 10:19 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: Ying Han <yinghan@google.com>
> >
> > The number of reclaimable pages per zone is an useful information for
> > controling memory reclaim schedule. This patch exports it.
> >
> > Changelog v2->v3:
> > A - added comments.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A include/linux/memcontrol.h | A  A 2 ++
> > A mm/memcontrol.c A  A  A  A  A  A | A  24 ++++++++++++++++++++++++
> > A 2 files changed, 26 insertions(+)
> >
> > Index: memcg_async/mm/memcontrol.c
> > ===================================================================
> > --- memcg_async.orig/mm/memcontrol.c
> > +++ memcg_async/mm/memcontrol.c
> > @@ -1240,6 +1240,30 @@ static unsigned long mem_cgroup_nr_lru_p
> > A }
> > A #endif /* CONFIG_NUMA */
> >
> > +/**
> > + * mem_cgroup_zone_reclaimable_pages
> > + * @memcg: the memcg
> > + * @nid A : node index to be checked.
> > + * @zid A : zone index to be checked.
> > + *
> > + * This function returns the number reclaimable pages on a zone for given memcg.
> > + * Reclaimable page includes file caches and anonymous pages if swap is
> > + * avaliable and never includes unevictable pages.
> > + */
> > +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  int nid, int zid)
> > +{
> > + A  A  A  unsigned long nr;
> > + A  A  A  struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> > +
> > + A  A  A  nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> > + A  A  A  A  A  A  A  MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE);
> > + A  A  A  if (nr_swap_pages > 0)
> > + A  A  A  A  A  A  A  nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
> > + A  A  A  A  A  A  A  A  A  A  A  MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
> > + A  A  A  return nr;
> > +}
> > +
> > A struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A struct zone *zone)
> > A {
> > Index: memcg_async/include/linux/memcontrol.h
> > ===================================================================
> > --- memcg_async.orig/include/linux/memcontrol.h
> > +++ memcg_async/include/linux/memcontrol.h
> > @@ -109,6 +109,8 @@ extern void mem_cgroup_end_migration(str
> > A */
> > A int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> > A int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> > +unsigned long
> > +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zid);
> > A int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> > A unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A struct zone *zone,
> >
> >
> 
> Again, please apply the patch:
> 

Nice catch. thank you.

-Kame

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6a52699..0b88d71 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1217,7 +1217,7 @@ unsigned long
> mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
>        struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> 
>        nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> -               MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE);
> +               MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
>        if (nr_swap_pages > 0)
>                nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
>                        MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
> 
> 
> Also, you need to move this to up since patch 1/10 needs this.
> 
> --Ying
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
