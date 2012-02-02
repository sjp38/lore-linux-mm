Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 630166B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 03:05:03 -0500 (EST)
Date: Thu, 2 Feb 2012 15:54:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [LSF/MM TOPIC] memcg topics.
Message-ID: <20120202075446.GA6837@localhost>
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
 <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com>
 <20120202063345.GA15124@localhost>
 <CAHH2K0a+srs7A78SdneNG01bbS_Nyq0eCSOA8mrujuE=F2juSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHH2K0a+srs7A78SdneNG01bbS_Nyq0eCSOA8mrujuE=F2juSg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>

On Wed, Feb 01, 2012 at 11:34:36PM -0800, Greg Thelen wrote:
> On Wed, Feb 1, 2012 at 10:33 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Hi Greg,
> >
> > On Wed, Feb 01, 2012 at 12:24:25PM -0800, Greg Thelen wrote:
> >> 1. how to compute per-container pause based on bdi bandwidth, cgroup
> >> dirty page usage.
> >> 2. how to ensure that writeback will engage even if system and bdi are
> >> below respective background dirty ratios, yet a memcg is above its bg
> >> dirty limit.
> >
> > The solution to (1,2) would be something like this:
> >
> > --- linux-next.orig/mm/page-writeback.c 2012-02-02 14:13:45.000000000 +0800
> > +++ linux-next/mm/page-writeback.c A  A  A 2012-02-02 14:24:11.000000000 +0800
> > @@ -654,6 +654,17 @@ static unsigned long bdi_position_ratio(
> > A  A  A  A pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> > A  A  A  A pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
> >
> > + A  A  A  if (memcg) {
> > + A  A  A  A  A  A  A  long long f;
> > + A  A  A  A  A  A  A  x = div_s64((memcg_setpoint - memcg_dirty) << RATELIMIT_CALC_SHIFT,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  memcg_limit - memcg_setpoint + 1);
> > + A  A  A  A  A  A  A  f = x;
> > + A  A  A  A  A  A  A  f = f * x >> RATELIMIT_CALC_SHIFT;
> > + A  A  A  A  A  A  A  f = f * x >> RATELIMIT_CALC_SHIFT;
> > + A  A  A  A  A  A  A  f += 1 << RATELIMIT_CALC_SHIFT;
> > + A  A  A  A  A  A  A  pos_ratio = pos_ratio * f >> RATELIMIT_CALC_SHIFT;
> > + A  A  A  }
> > +
> > A  A  A  A /*
> > A  A  A  A  * We have computed basic pos_ratio above based on global situation. If
> > A  A  A  A  * the bdi is over/under its share of dirty pages, we want to scale
> > @@ -1202,6 +1213,8 @@ static void balance_dirty_pages(struct a
> > A  A  A  A  A  A  A  A freerun = dirty_freerun_ceiling(dirty_thresh,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A background_thresh);
> > A  A  A  A  A  A  A  A if (nr_dirty <= freerun) {
> > + A  A  A  A  A  A  A  A  A  A  A  if (memcg && memcg_dirty > memcg_freerun)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  goto start_writeback;
> > A  A  A  A  A  A  A  A  A  A  A  A current->dirty_paused_when = now;
> > A  A  A  A  A  A  A  A  A  A  A  A current->nr_dirtied = 0;
> > A  A  A  A  A  A  A  A  A  A  A  A current->nr_dirtied_pause =
> > @@ -1209,6 +1222,7 @@ static void balance_dirty_pages(struct a
> > A  A  A  A  A  A  A  A  A  A  A  A break;
> > A  A  A  A  A  A  A  A }
> >
> > +start_writeback:
> > A  A  A  A  A  A  A  A if (unlikely(!writeback_in_progress(bdi)))
> > A  A  A  A  A  A  A  A  A  A  A  A bdi_start_background_writeback(bdi);
> >
> >
> > That makes the minimal change to enforce per-memcg dirty ratio.
> > It could result in a less stable control system, but should still
> > be able to balance things out.
> >
> > Thanks,
> > Fengguang
> 
> Thank you for the quick patch.  It looks promising.  I can imagine how
> this would wake up background writeback.  But I am unsure how
> background writeback will do anything.  It seems like
> over_bground_thresh() would not necessarily see system or bdi dirty
> usage over respective limits.  In previously posted memcg writeback
> patches this involved an fs-writeback.c call to
> mem_cgroups_over_bground_dirty_thresh() to check for memcg dirty limit
> compliance.  Do you think we still need such a call out to memcg from
> writeback?

Yeah I forgot over_bground_thresh().. Obviously it needs to be memcg
aware, too.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
