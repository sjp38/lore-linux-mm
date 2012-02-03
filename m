Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id A1EE56B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 20:36:46 -0500 (EST)
Date: Fri, 3 Feb 2012 09:26:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.
Message-ID: <20120203012637.GA7438@localhost>
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
 <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com>
 <20120202063345.GA15124@localhost>
 <20120202075234.GA3039@localhost>
 <20120202103953.GE31730@quack.suse.cz>
 <20120202110433.GA24419@localhost>
 <20120202154209.GG31730@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120202154209.GG31730@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Feb 02, 2012 at 04:42:09PM +0100, Jan Kara wrote:
> On Thu 02-02-12 19:04:34, Wu Fengguang wrote:
> > On Thu, Feb 02, 2012 at 11:39:53AM +0100, Jan Kara wrote:
> > > On Thu 02-02-12 15:52:34, Wu Fengguang wrote:
> > > > On Thu, Feb 02, 2012 at 02:33:45PM +0800, Wu Fengguang wrote:
> > > > > Hi Greg,
> > > > > 
> > > > > On Wed, Feb 01, 2012 at 12:24:25PM -0800, Greg Thelen wrote:
> > > > > > On Tue, Jan 31, 2012 at 4:55 PM, KAMEZAWA Hiroyuki
> > > > > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > > > 4. dirty ratio
> > > > > > > A  In the last year, patches were posted but not merged. I'd like to hear
> > > > > > > A  works on this area.
> > > > > > 
> > > > > > I would like to attend to discuss this topic.  I have not had much time to work
> > > > > > on this recently, but should be able to focus more on this soon.  The
> > > > > > IO less writeback changes require some redesign and may allow for a
> > > > > > simpler implementation of mem_cgroup_balance_dirty_pages().
> > > > > > Maintaining a per container dirty page counts, ratios, and limits is
> > > > > > fairly easy, but integration with writeback is the challenge.  My big
> > > > > > questions are for writeback people:
> > > > > > 1. how to compute per-container pause based on bdi bandwidth, cgroup
> > > > > > dirty page usage.
> > > > > > 2. how to ensure that writeback will engage even if system and bdi are
> > > > > > below respective background dirty ratios, yet a memcg is above its bg
> > > > > > dirty limit.
> > > > > 
> > > > > The solution to (1,2) would be something like this:
> > > > > 
> > > > > --- linux-next.orig/mm/page-writeback.c	2012-02-02 14:13:45.000000000 +0800
> > > > > +++ linux-next/mm/page-writeback.c	2012-02-02 14:24:11.000000000 +0800
> > > > > @@ -654,6 +654,17 @@ static unsigned long bdi_position_ratio(
> > > > >  	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> > > > >  	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
> > > > >  
> > > > > +	if (memcg) {
> > > > > +		long long f;
> > > > > +		x = div_s64((memcg_setpoint - memcg_dirty) << RATELIMIT_CALC_SHIFT,
> > > > > +			    memcg_limit - memcg_setpoint + 1);
> > > > > +		f = x;
> > > > > +		f = f * x >> RATELIMIT_CALC_SHIFT;
> > > > > +		f = f * x >> RATELIMIT_CALC_SHIFT;
> > > > > +		f += 1 << RATELIMIT_CALC_SHIFT;
> > > > > +		pos_ratio = pos_ratio * f >> RATELIMIT_CALC_SHIFT;
> > > > > +	}
> > > > > +
> > > > >  	/*
> > > > >  	 * We have computed basic pos_ratio above based on global situation. If
> > > > >  	 * the bdi is over/under its share of dirty pages, we want to scale
> > > > > @@ -1202,6 +1213,8 @@ static void balance_dirty_pages(struct a
> > > > >  		freerun = dirty_freerun_ceiling(dirty_thresh,
> > > > >  						background_thresh);
> > > > >  		if (nr_dirty <= freerun) {
> > > > > +			if (memcg && memcg_dirty > memcg_freerun)
> > > > > +				goto start_writeback;
> > > > >  			current->dirty_paused_when = now;
> > > > >  			current->nr_dirtied = 0;
> > > > >  			current->nr_dirtied_pause =
> > > > > @@ -1209,6 +1222,7 @@ static void balance_dirty_pages(struct a
> > > > >  			break;
> > > > >  		}
> > > > >  
> > > > > +start_writeback:
> > > > >  		if (unlikely(!writeback_in_progress(bdi)))
> > > > >  			bdi_start_background_writeback(bdi);
> > > > >  
> > > > > 
> > > > > That makes the minimal change to enforce per-memcg dirty ratio.
> > > > > It could result in a less stable control system, but should still
> > > > > be able to balance things out.
> > > > 
> > > > Unfortunately the memcg partitioning could fundamentally make the
> > > > dirty throttling more bumpy.
> > > > 
> > > > Imagine 10 memcgs each with
> > > > 
> > > > - memcg_dirty_limit=50MB
> > > > - 1 dd dirty task
> > > > 
> > > > The flusher thread will be working on 10 inodes in turn, each time
> > > > grabbing the next inode and taking ~0.5s to write ~50MB of its dirty
> > > > pages to the disk. So each inode will be flushed on every ~5s.
> > > > 
> > > > Without memcg dirty ratio, the dd tasks will be throttled quite
> > > > smoothly.  However with memcg, each memcg will be limited to 50MB
> > > > dirty pages, and the dirty number will be dropping quickly from 50MB
> > > > to 0 on every 5 seconds.
> > > >
> > > > As a result, the small partitions of dirty pages will transmit the
> > > > flusher's bumpy writeout (which is necessary for performance) to the
> > > > dd tasks' bumpy progress. The dd tasks will be blocked for seconds
> > > > from time to time.
> > > > 
> > > > So I cannot help thinking: can the problem be canceled in the root?
> > > > The basic scheme could be: when reclaiming from a memcg zone, if any
> > > > PG_writeback/PG_dirty pages are encountered, mark PG_reclaim on it and
> > > > move it to the global zone and de-account it from the memcg.
> > > > 
> > > > In this way, we can avoid dirty/writeback pages hurting the (possibly
> > > > small) memcg zones. The aggressive dirtier tasks will be throttled by
> > > > the global 20% limit and the memcg page reclaims can go on smoothly.
> > >   If I remember Google's usecase right, their ultimate goal is to partition
> > > the machine so that processes in memcg A get say 1/4 of the available
> > > disk bandwidth, processes in memcg B get 1/2 of the disk bandwidth.
> > > 
> > > Now you can do the bandwidth limitting in CFQ but it doesn't really work
> > > for buffered writes because these are done by flusher thread ignoring any
> > > memcg boundaries. So they introduce knowledge of memcgs into flusher thread
> > > so that writeback done by flusher thread reflects the configured
> > > proportions.
> > 
> > Actually the dirty rate can be controlled independent from the dirty pages:
> > 
> > blk-cgroup: async write IO controller 
> > https://github.com/fengguang/linux/commit/99b1ca4549a79af736ab03247805f6a9fc31ca2d
> > 
> > > But then the result is that processes in memcg A will simply accumulate
> > > more dirty pages because writeback is slower for them. So that's why you
> > > want to stop dirtying processes in that memcg when they reach their
> > 
> > The bandwidth control alone will be pretty smooth, not suffering from
> > the partition problem. And it don't need to alter the flusher behavior
> > (like make it focusing on some inodes) and hence won't impact performance.
> > 
> > If memcg A's dirty rate is throttled, its dirty pages will naturally
> > shrink. The flusher will automatically work less on A's dirty pages.
>   I'm not sure about details of requirements Google guys have. So this may
> or may not be good enough for them. I'd suspect they still wouldn't want
> one cgroup to fill up available page cache with dirty pages so just
> limitting bandwidth won't be enough for them. Also limitting dirty
> bandwidth has a problem that it's not coupled with how much reading the
> particular cgroup does. Anyway, until we are sure about their exact
> requirements, this is mostly philosophical talking ;).

Yeah, I'm not sure what exactly Google needs and how big problem the
partition will be for them. Basically,

- when there are N memcg each dirtying 1 file, each file will be
  flushed on every (N * 0.5) seconds, where 0.5s is the typical time

- if (memcg_dirty_limit > 10 * bdi_bandwidth), the dd tasks should be
  able to progress reasonably smoothly

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
