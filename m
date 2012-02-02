Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 742306B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 01:43:52 -0500 (EST)
Date: Thu, 2 Feb 2012 14:33:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [LSF/MM TOPIC] memcg topics.
Message-ID: <20120202063345.GA15124@localhost>
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
 <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>

Hi Greg,

On Wed, Feb 01, 2012 at 12:24:25PM -0800, Greg Thelen wrote:
> On Tue, Jan 31, 2012 at 4:55 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 4. dirty ratio
> > A  In the last year, patches were posted but not merged. I'd like to hear
> > A  works on this area.
> 
> I would like to attend to discuss this topic.  I have not had much time to work
> on this recently, but should be able to focus more on this soon.  The
> IO less writeback changes require some redesign and may allow for a
> simpler implementation of mem_cgroup_balance_dirty_pages().
> Maintaining a per container dirty page counts, ratios, and limits is
> fairly easy, but integration with writeback is the challenge.  My big
> questions are for writeback people:
> 1. how to compute per-container pause based on bdi bandwidth, cgroup
> dirty page usage.
> 2. how to ensure that writeback will engage even if system and bdi are
> below respective background dirty ratios, yet a memcg is above its bg
> dirty limit.

The solution to (1,2) would be something like this:

--- linux-next.orig/mm/page-writeback.c	2012-02-02 14:13:45.000000000 +0800
+++ linux-next/mm/page-writeback.c	2012-02-02 14:24:11.000000000 +0800
@@ -654,6 +654,17 @@ static unsigned long bdi_position_ratio(
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
 	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
 
+	if (memcg) {
+		long long f;
+		x = div_s64((memcg_setpoint - memcg_dirty) << RATELIMIT_CALC_SHIFT,
+			    memcg_limit - memcg_setpoint + 1);
+		f = x;
+		f = f * x >> RATELIMIT_CALC_SHIFT;
+		f = f * x >> RATELIMIT_CALC_SHIFT;
+		f += 1 << RATELIMIT_CALC_SHIFT;
+		pos_ratio = pos_ratio * f >> RATELIMIT_CALC_SHIFT;
+	}
+
 	/*
 	 * We have computed basic pos_ratio above based on global situation. If
 	 * the bdi is over/under its share of dirty pages, we want to scale
@@ -1202,6 +1213,8 @@ static void balance_dirty_pages(struct a
 		freerun = dirty_freerun_ceiling(dirty_thresh,
 						background_thresh);
 		if (nr_dirty <= freerun) {
+			if (memcg && memcg_dirty > memcg_freerun)
+				goto start_writeback;
 			current->dirty_paused_when = now;
 			current->nr_dirtied = 0;
 			current->nr_dirtied_pause =
@@ -1209,6 +1222,7 @@ static void balance_dirty_pages(struct a
 			break;
 		}
 
+start_writeback:
 		if (unlikely(!writeback_in_progress(bdi)))
 			bdi_start_background_writeback(bdi);
 

That makes the minimal change to enforce per-memcg dirty ratio.
It could result in a less stable control system, but should still
be able to balance things out.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
