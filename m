Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id ECD176B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 03:33:54 -0500 (EST)
Date: Tue, 24 Jan 2012 09:33:47 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
Message-ID: <20120124083347.GC1660@cmpxchg.org>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
 <20120123104731.GA1707@cmpxchg.org>
 <CAJd=RBDUK=LQVhQm_P3DO-bgWka=gK9cKUkm8esOaZs261EexA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJd=RBDUK=LQVhQm_P3DO-bgWka=gK9cKUkm8esOaZs261EexA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 23, 2012 at 08:30:42PM +0800, Hillf Danton wrote:
> On Mon, Jan 23, 2012 at 6:47 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Mon, Jan 23, 2012 at 09:55:07AM +0800, Hillf Danton wrote:
> >> To avoid reduction in performance of reclaimee, checking overreclaim is added
> >> after shrinking lru list, when pages are reclaimed from mem cgroup.
> >>
> >> If over reclaim occurs, shrinking remaining lru lists is skipped, and no more
> >> reclaim for reclaim/compaction.
> >>
> >> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> >> ---
> >>
> >> --- a/mm/vmscan.c     Mon Jan 23 00:23:10 2012
> >> +++ b/mm/vmscan.c     Mon Jan 23 09:57:20 2012
> >> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
> >>       unsigned long nr_reclaimed, nr_scanned;
> >>       unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> >>       struct blk_plug plug;
> >> +     bool memcg_over_reclaimed = false;
> >>
> >>  restart:
> >>       nr_reclaimed = 0;
> >> @@ -2103,6 +2104,11 @@ restart:
> >>
> >>                               nr_reclaimed += shrink_list(lru, nr_to_scan,
> >>                                                           mz, sc, priority);
> >> +
> >> +                             memcg_over_reclaimed = !scanning_global_lru(mz)
> >> +                                     && (nr_reclaimed >= nr_to_reclaim);
> >> +                             if (memcg_over_reclaimed)
> >> +                                     goto out;
> >
> > Since this merge window, scanning_global_lru() is always false when
> > the memory controller is enabled, i.e. most common configurations and
> > distribution kernels.
> >
> > This will with quite likely have bad effects on zone balancing,
> > pressure balancing between anon/file lru etc, while you haven't shown
> > that any workloads actually benefit from this.
> >
> Hi Johannes
> 
> Thanks for your comment, first.
> 
> Impact on zone balance and lru-list balance is introduced actually, but I
> dont think the patch is totally responsible for the balance mentioned,
> because soft limit, embedded in mem cgroup, is setup by users according to
> whatever tastes they have.
> 
> Though there is room for the patch to be fine tuned in this direction or that,
> over reclaim should not be neglected entirely, but be avoided as much as we
> could, or users are enforced to set up soft limit with much care not to mess
> up zone balance.

Overreclaim is absolutely horrible with soft limits, but I think there
are more direct reasons than checking nr_to_reclaim only after a full
zone scan, for example, soft limit reclaim is invoked on zones that
are totally fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
