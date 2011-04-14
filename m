Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF037900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:37:27 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2FEBB3EE0AE
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:37:25 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 15D6945DE54
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:37:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EEDC445DE4F
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:37:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E31591DB8040
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:37:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A41051DB803E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:37:24 +0900 (JST)
Date: Thu, 14 Apr 2011 09:30:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3 6/7] Enable per-memcg background reclaim.
Message-Id: <20110414093051.504eade4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikdF+xjSBAk-5zptYH5mUpG2f=5Kw@mail.gmail.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-7-git-send-email-yinghan@google.com>
	<20110413180520.dc7ce1d4.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikdF+xjSBAk-5zptYH5mUpG2f=5Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 13 Apr 2011 14:20:22 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 13, 2011 at 2:05 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 13 Apr 2011 00:03:06 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > By default the per-memcg background reclaim is disabled when the
> > limit_in_bytes
> > > is set the maximum or the wmark_ratio is 0. The kswapd_run() is called
> > when the
> > > memcg is being resized, and kswapd_stop() is called when the memcg is
> > being
> > > deleted.
> > >
> > > The per-memcg kswapd is waked up based on the usage and low_wmark, which
> > is
> > > checked once per 1024 increments per cpu. The memcg's kswapd is waked up
> > if the
> > > usage is larger than the low_wmark.
> > >
> > > changelog v3..v2:
> > > 1. some clean-ups
> > >
> > > changelog v2..v1:
> > > 1. start/stop the per-cgroup kswapd at create/delete cgroup stage.
> > > 2. remove checking the wmark from per-page charging. now it checks the
> > wmark
> > > periodically based on the event counter.
> > >
> > > Signed-off-by: Ying Han <yinghan@google.com>
> >
> > This event logic seems to make sense.
> >
> > > ---
> > >  mm/memcontrol.c |   37 +++++++++++++++++++++++++++++++++++++
> > >  1 files changed, 37 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index efeade3..bfa8646 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -105,10 +105,12 @@ enum mem_cgroup_events_index {
> > >  enum mem_cgroup_events_target {
> > >       MEM_CGROUP_TARGET_THRESH,
> > >       MEM_CGROUP_TARGET_SOFTLIMIT,
> > > +     MEM_CGROUP_WMARK_EVENTS_THRESH,
> > >       MEM_CGROUP_NTARGETS,
> > >  };
> > >  #define THRESHOLDS_EVENTS_TARGET (128)
> > >  #define SOFTLIMIT_EVENTS_TARGET (1024)
> > > +#define WMARK_EVENTS_TARGET (1024)
> > >
> > >  struct mem_cgroup_stat_cpu {
> > >       long count[MEM_CGROUP_STAT_NSTATS];
> > > @@ -366,6 +368,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
> > >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> > >  static void drain_all_stock_async(void);
> > >  static unsigned long get_wmark_ratio(struct mem_cgroup *mem);
> > > +static void wake_memcg_kswapd(struct mem_cgroup *mem);
> > >
> > >  static struct mem_cgroup_per_zone *
> > >  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > > @@ -545,6 +548,12 @@ mem_cgroup_largest_soft_limit_node(struct
> > mem_cgroup_tree_per_zone *mctz)
> > >       return mz;
> > >  }
> > >
> > > +static void mem_cgroup_check_wmark(struct mem_cgroup *mem)
> > > +{
> > > +     if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))
> > > +             wake_memcg_kswapd(mem);
> > > +}
> > > +
> > >  /*
> > >   * Implementation Note: reading percpu statistics for memcg.
> > >   *
> > > @@ -675,6 +684,9 @@ static void __mem_cgroup_target_update(struct
> > mem_cgroup *mem, int target)
> > >       case MEM_CGROUP_TARGET_SOFTLIMIT:
> > >               next = val + SOFTLIMIT_EVENTS_TARGET;
> > >               break;
> > > +     case MEM_CGROUP_WMARK_EVENTS_THRESH:
> > > +             next = val + WMARK_EVENTS_TARGET;
> > > +             break;
> > >       default:
> > >               return;
> > >       }
> > > @@ -698,6 +710,10 @@ static void memcg_check_events(struct mem_cgroup
> > *mem, struct page *page)
> > >                       __mem_cgroup_target_update(mem,
> > >                               MEM_CGROUP_TARGET_SOFTLIMIT);
> > >               }
> > > +             if (unlikely(__memcg_event_check(mem,
> > > +                     MEM_CGROUP_WMARK_EVENTS_THRESH))){
> > > +                     mem_cgroup_check_wmark(mem);
> > > +             }
> > >       }
> > >  }
> > >
> > > @@ -3384,6 +3400,10 @@ static int mem_cgroup_resize_limit(struct
> > mem_cgroup *memcg,
> > >       if (!ret && enlarge)
> > >               memcg_oom_recover(memcg);
> > >
> > > +     if (!mem_cgroup_is_root(memcg) && !memcg->kswapd_wait &&
> > > +                     memcg->wmark_ratio)
> > > +             kswapd_run(0, memcg);
> > > +
> >
> > Isn't it enough to have trigger in charge() path ?
> >
> 
> why? kswapd_run() is to create the kswapd thread for the memcg. If the
> memcg's limit doesn't change from the initial value, we don't want to create
> a kswapd thread for it. Only if the limit_in_byte is being changed. Adding
> the hook in the charge path sounds too much overhead to the hotpath.
> 

Ah, sorry. I misunderstood.


> However, I might need to add checks here, where if the limit_in_byte is set
> to RESOURCE_MAX.
> 
> >
> > rather than here, I think we should check _move_task(). It changes res
> > usage
> > dramatically without updating events.
> >
> 
> I see both the mem_cgroup_charge_statistics() and memcg_check_events()  are
> being called in mem_cgroup_move_account(). Am i missing anything here?
> 

My fault.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
