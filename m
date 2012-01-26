Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id AE1F66B009A
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 04:17:53 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C141D3EE0B6
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 18:17:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1A9645DE51
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 18:17:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B0D945DE4F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 18:17:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F5061DB802F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 18:17:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27C8B1DB803F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 18:17:51 +0900 (JST)
Date: Thu, 26 Jan 2012 18:16:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
Message-Id: <20120126181631.94c3c685.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4iy-oxPwtSHUQ-gKie+_6Of=QOnYdiQwcqYtXmfxSy=MQA@mail.gmail.com>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
	<20120123104731.GA1707@cmpxchg.org>
	<CAJd=RBDUK=LQVhQm_P3DO-bgWka=gK9cKUkm8esOaZs261EexA@mail.gmail.com>
	<20120124083347.GC1660@cmpxchg.org>
	<20120124180821.b499f75a.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4iy-oxPwtSHUQ-gKie+_6Of=QOnYdiQwcqYtXmfxSy=MQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 24 Jan 2012 15:33:11 -0800
Ying Han <yinghan@google.com> wrote:

> On Tue, Jan 24, 2012 at 1:08 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 24 Jan 2012 09:33:47 +0100
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> >> On Mon, Jan 23, 2012 at 08:30:42PM +0800, Hillf Danton wrote:
> >> > On Mon, Jan 23, 2012 at 6:47 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> > > On Mon, Jan 23, 2012 at 09:55:07AM +0800, Hillf Danton wrote:
> >> > >> To avoid reduction in performance of reclaimee, checking overreclaim is added
> >> > >> after shrinking lru list, when pages are reclaimed from mem cgroup.
> >> > >>
> >> > >> If over reclaim occurs, shrinking remaining lru lists is skipped, and no more
> >> > >> reclaim for reclaim/compaction.
> >> > >>
> >> > >> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> >> > >> ---
> >> > >>
> >> > >> --- a/mm/vmscan.c A  A  Mon Jan 23 00:23:10 2012
> >> > >> +++ b/mm/vmscan.c A  A  Mon Jan 23 09:57:20 2012
> >> > >> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
> >> > >> A  A  A  unsigned long nr_reclaimed, nr_scanned;
> >> > >> A  A  A  unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> >> > >> A  A  A  struct blk_plug plug;
> >> > >> + A  A  bool memcg_over_reclaimed = false;
> >> > >>
> >> > >> A restart:
> >> > >> A  A  A  nr_reclaimed = 0;
> >> > >> @@ -2103,6 +2104,11 @@ restart:
> >> > >>
> >> > >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  nr_reclaimed += shrink_list(lru, nr_to_scan,
> >> > >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  mz, sc, priority);
> >> > >> +
> >> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  memcg_over_reclaimed = !scanning_global_lru(mz)
> >> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  && (nr_reclaimed >= nr_to_reclaim);
> >> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (memcg_over_reclaimed)
> >> > >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  goto out;
> >> > >
> >> > > Since this merge window, scanning_global_lru() is always false when
> >> > > the memory controller is enabled, i.e. most common configurations and
> >> > > distribution kernels.
> >> > >
> >> > > This will with quite likely have bad effects on zone balancing,
> >> > > pressure balancing between anon/file lru etc, while you haven't shown
> >> > > that any workloads actually benefit from this.
> >> > >
> >> > Hi Johannes
> >> >
> >> > Thanks for your comment, first.
> >> >
> >> > Impact on zone balance and lru-list balance is introduced actually, but I
> >> > dont think the patch is totally responsible for the balance mentioned,
> >> > because soft limit, embedded in mem cgroup, is setup by users according to
> >> > whatever tastes they have.
> >> >
> >> > Though there is room for the patch to be fine tuned in this direction or that,
> >> > over reclaim should not be neglected entirely, but be avoided as much as we
> >> > could, or users are enforced to set up soft limit with much care not to mess
> >> > up zone balance.
> >>
> >> Overreclaim is absolutely horrible with soft limits, but I think there
> >> are more direct reasons than checking nr_to_reclaim only after a full
> >> zone scan, for example, soft limit reclaim is invoked on zones that
> >> are totally fine.
> >>
> >
> >
> > IIUC..
> > A - Because zonelist is all visited by alloc_pages(), _all_ zones in zonelist
> > A  are in memory shortage.
> > A - taking care of zone/node balancing.
> >
> > I know this 'full zone scan' affects latency of alloc_pages() if the number
> > of node is big.
> 
> >
> > IMHO, in case of direct-reclaim caused by memcg's limit, we should avoid
> > full zone scan because the reclaim is not caused by any memory shortage in zonelist.
> >

This text is talking about memcg's direct reclaim scanning caused by 'limit'.


> > In case of global memory reclaim, kswapd doesn't use zonelist.
> >
> > So, only global-direct-reclaim is a problem here.
> > I think do-full-zone-scan will reduce the calls of try_to_free_pages()
> > in future and may reduce lock contention but adds a thread too much
> > penalty.
> 
> > In typical case, considering 4-node x86/64 NUMA, GFP_HIGHUSER_MOVABLE
> > allocation failure will reclaim 4*ZONE_NORMAL+ZONE_DMA32 = 160pages per scan.
> >
> > If 16-node, it will be 16*ZONE_NORMAL+ZONE_DMA32 = 544? pages per scan.
> >
> > 32pages may be too small but don't we need to have some threshold to quit
> > full-zone-scan ?
> 
> Sorry I am confused. Are we talking about doing full zonelist scanning
> within a memcg or doing anon/file lru balance within a zone? AFAIU, it
> is the later one.
> 
I'm sorry for confusing.

Above test is talking about global lru scanning, not memcg related.



> In this patch, we do early breakout (memcg_over_reclaimed) without
> finish scanning other lrus per-memcg-per-zone. I think the concern is
> what is the side effect of that ?
> 
> > Here, the topic is about softlimit reclaim. I think...
> >
> > 1. follow up for following comment(*) is required.
> > ==
> > A  A  A  A  A  A  A  A  A  A  A  A nr_soft_scanned = 0;
> > A  A  A  A  A  A  A  A  A  A  A  A nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A sc->order, sc->gfp_mask,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A &nr_soft_scanned);
> > A  A  A  A  A  A  A  A  A  A  A  A sc->nr_reclaimed += nr_soft_reclaimed;
> > A  A  A  A  A  A  A  A  A  A  A  A sc->nr_scanned += nr_soft_scanned;
> > A  A  A  A  A  A  A  A  A  A  A  A /* need some check for avoid more shrink_zone() */ <----(*)
> > ==
> >
> > 2. some threshold for avoinding full zone scan may be good.
> > A  (But this may need deep discussion...)
> >
> > 3. About the patch, I think it will not break zone-balancing if (*) is
> > A  handled in a good way.
> >
> > A  This check is not good.
> >
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  memcg_over_reclaimed = !scanning_global_lru(mz)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  && (nr_reclaimed >= nr_to_reclaim);
> >
> >
> > A I like following
> >
> > A If (we-are-doing-softlimit-reclaim-for-global-direct-reclaim &&
> > A  A  A res_counter_soft_limit_excess(memcg->res))
> > A  A  A  memcg_over_reclaimed = true;
> 
> This condition looks quite similar to what we've discussed on another
> thread, except that we do allow over-reclaim under softlimit after
> certain priority loop. (assume we have hard-to-reclaim memory on other
> cgroups above their softlimit)
> 

yes. I've cut this from that thread.


> There are some works needed to be done ( like reverting the rb-tree )
> on current soft limit implementation before we can even further to
> optimize it. It would be nice to settle the first part before
> everything else.
> 
Agreed.

I personally think Johannes' clean up should go first and removing
rb-tree before optimization is better.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
