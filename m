Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id BDC1E6B13F1
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 04:41:28 -0500 (EST)
Date: Wed, 8 Feb 2012 17:31:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
Message-ID: <20120208093120.GA18993@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Feb 07, 2012 at 11:55:05PM -0800, Greg Thelen wrote:
> On Fri, Feb 3, 2012 at 1:40 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > If moving dirty pages out of the memcg to the 20% global dirty pages
> > pool on page reclaim, the above OOM can be avoided. It does change the
> > meaning of memory.limit_in_bytes in that the memcg tasks can now
> > actually consume more pages (up to the shared global 20% dirty limit).
> 
> This seems like an easy change, but unfortunately the global 20% pool
> has some shortcomings for my needs:
> 
> 1. the global 20% pool is not moderated.  One cgroup can dominate it
>     and deny service to other cgroups.

It is moderated by balance_dirty_pages() -- in terms of dirty ratelimit.
And you have the freedom to control the bandwidth allocation with some
async write I/O controller.

Even though there is no direct control of dirty pages, we can roughly
get it as the side effect of rate control. Given

        ratelimit_cgroup_A = 2 * ratelimit_cgroup_B

There will naturally be more dirty pages for cgroup A to be worked by
the flusher. And the dirty pages will be roughly balanced around

        nr_dirty_cgroup_A = 2 * nr_dirty_cgroup_B

when writeout bandwidths for their dirty pages are equal.

> 2. the global 20% pool is free, unaccounted memory.  Ideally cgroups only
>     use the amount of memory specified in their memory.limit_in_bytes.  The
>     goal is to sell portions of a system.  Global resource like the 20% are an
>     undesirable system-wide tax that's shared by jobs that may not even
>     perform buffered writes.

Right, it is the shortcoming.

> 3. Setting aside 20% extra memory for system wide dirty buffers is a lot of
>     memory.  This becomes a larger issue when the global dirty_ratio is
>     higher than 20%.

Yeah the global pool scheme does mean that you'd better allocate at
most 80% memory to individual memory cgroups, otherwise it's possible
for a tiny memcg doing dd writes to push dirty pages to global LRU and
*squeeze* the size of other memcgs.

However I guess it should be mitigated by the fact that

- we typically already reserve some space for the root memcg

- 20% dirty ratio is mostly an overkill for large memory systems.
  It's often enough to hold 10-30s worth of dirty data for them, which
  is 1-3GB for one 100MB/s disk. This is the reason vm.dirty_bytes is
  introduced: someone wants to do some <1% dirty ratio.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
