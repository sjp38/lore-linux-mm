Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0B7FD6B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 04:09:44 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 15FEC3EE0BB
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 18:09:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EFF2D45DE6C
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 18:09:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D50EE45DE67
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 18:09:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C24A2E08003
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 18:09:42 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68895E08004
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 18:09:42 +0900 (JST)
Date: Tue, 24 Jan 2012 18:08:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
Message-Id: <20120124180821.b499f75a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120124083347.GC1660@cmpxchg.org>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
	<20120123104731.GA1707@cmpxchg.org>
	<CAJd=RBDUK=LQVhQm_P3DO-bgWka=gK9cKUkm8esOaZs261EexA@mail.gmail.com>
	<20120124083347.GC1660@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 24 Jan 2012 09:33:47 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, Jan 23, 2012 at 08:30:42PM +0800, Hillf Danton wrote:
> > On Mon, Jan 23, 2012 at 6:47 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > On Mon, Jan 23, 2012 at 09:55:07AM +0800, Hillf Danton wrote:
> > >> To avoid reduction in performance of reclaimee, checking overreclaim is added
> > >> after shrinking lru list, when pages are reclaimed from mem cgroup.
> > >>
> > >> If over reclaim occurs, shrinking remaining lru lists is skipped, and no more
> > >> reclaim for reclaim/compaction.
> > >>
> > >> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> > >> ---
> > >>
> > >> --- a/mm/vmscan.c A  A  Mon Jan 23 00:23:10 2012
> > >> +++ b/mm/vmscan.c A  A  Mon Jan 23 09:57:20 2012
> > >> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
> > >> A  A  A  unsigned long nr_reclaimed, nr_scanned;
> > >> A  A  A  unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> > >> A  A  A  struct blk_plug plug;
> > >> + A  A  bool memcg_over_reclaimed = false;
> > >>
> > >> A restart:
> > >> A  A  A  nr_reclaimed = 0;
> > >> @@ -2103,6 +2104,11 @@ restart:
> > >>
> > >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  nr_reclaimed += shrink_list(lru, nr_to_scan,
> > >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  mz, sc, priority);
> > >> +
> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  memcg_over_reclaimed = !scanning_global_lru(mz)
> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  && (nr_reclaimed >= nr_to_reclaim);
> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (memcg_over_reclaimed)
> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  goto out;
> > >
> > > Since this merge window, scanning_global_lru() is always false when
> > > the memory controller is enabled, i.e. most common configurations and
> > > distribution kernels.
> > >
> > > This will with quite likely have bad effects on zone balancing,
> > > pressure balancing between anon/file lru etc, while you haven't shown
> > > that any workloads actually benefit from this.
> > >
> > Hi Johannes
> > 
> > Thanks for your comment, first.
> > 
> > Impact on zone balance and lru-list balance is introduced actually, but I
> > dont think the patch is totally responsible for the balance mentioned,
> > because soft limit, embedded in mem cgroup, is setup by users according to
> > whatever tastes they have.
> > 
> > Though there is room for the patch to be fine tuned in this direction or that,
> > over reclaim should not be neglected entirely, but be avoided as much as we
> > could, or users are enforced to set up soft limit with much care not to mess
> > up zone balance.
> 
> Overreclaim is absolutely horrible with soft limits, but I think there
> are more direct reasons than checking nr_to_reclaim only after a full
> zone scan, for example, soft limit reclaim is invoked on zones that
> are totally fine.
> 


IIUC..
 - Because zonelist is all visited by alloc_pages(), _all_ zones in zonelist
   are in memory shortage.
 - taking care of zone/node balancing. 

I know this 'full zone scan' affects latency of alloc_pages() if the number
of node is big.

IMHO, in case of direct-reclaim caused by memcg's limit, we should avoid
full zone scan because the reclaim is not caused by any memory shortage in zonelist.

In case of global memory reclaim, kswapd doesn't use zonelist.

So, only global-direct-reclaim is a problem here.
I think do-full-zone-scan will reduce the calls of try_to_free_pages() 
in future and may reduce lock contention but adds a thread too much
penalty.

In typical case, considering 4-node x86/64 NUMA, GFP_HIGHUSER_MOVABLE
allocation failure will reclaim 4*ZONE_NORMAL+ZONE_DMA32 = 160pages per scan.

If 16-node, it will be 16*ZONE_NORMAL+ZONE_DMA32 = 544? pages per scan.

32pages may be too small but don't we need to have some threshold to quit
full-zone-scan ?

Here, the topic is about softlimit reclaim. I think...

1. follow up for following comment(*) is required.
==
                        nr_soft_scanned = 0;
                        nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
                                                sc->order, sc->gfp_mask,
                                                &nr_soft_scanned);
                        sc->nr_reclaimed += nr_soft_reclaimed;
                        sc->nr_scanned += nr_soft_scanned;
                        /* need some check for avoid more shrink_zone() */ <----(*)
==

2. some threshold for avoinding full zone scan may be good.
   (But this may need deep discussion...)

3. About the patch, I think it will not break zone-balancing if (*) is
   handled in a good way.

   This check is not good.

+				memcg_over_reclaimed = !scanning_global_lru(mz)
+					&& (nr_reclaimed >= nr_to_reclaim);

   
  I like following 

  If (we-are-doing-softlimit-reclaim-for-global-direct-reclaim &&
      res_counter_soft_limit_excess(memcg->res))
       memcg_over_reclaimed = true;

Then another memcg will be picked up and soft-limit-reclaim() will continue.

Thanks,
-Kame











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
