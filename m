Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0E4536B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 09:01:18 -0500 (EST)
Date: Thu, 9 Feb 2012 21:50:43 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
Message-ID: <20120209135043.GA7620@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CALWz4izTS_E3uHLLfq3c9=LCuEh_yykmfrRAv4G1gUHumzGDzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4izTS_E3uHLLfq3c9=LCuEh_yykmfrRAv4G1gUHumzGDzQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Feb 08, 2012 at 12:54:33PM -0800, Ying Han wrote:
> On Wed, Feb 8, 2012 at 1:31 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Tue, Feb 07, 2012 at 11:55:05PM -0800, Greg Thelen wrote:
> >> On Fri, Feb 3, 2012 at 1:40 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> > If moving dirty pages out of the memcg to the 20% global dirty pages
> >> > pool on page reclaim, the above OOM can be avoided. It does change the
> >> > meaning of memory.limit_in_bytes in that the memcg tasks can now
> >> > actually consume more pages (up to the shared global 20% dirty limit).
> >>
> >> This seems like an easy change, but unfortunately the global 20% pool
> >> has some shortcomings for my needs:
> >>
> >> 1. the global 20% pool is not moderated. A One cgroup can dominate it
> >> A  A  and deny service to other cgroups.
> >
> > It is moderated by balance_dirty_pages() -- in terms of dirty ratelimit.
> > And you have the freedom to control the bandwidth allocation with some
> > async write I/O controller.
> >
> > Even though there is no direct control of dirty pages, we can roughly
> > get it as the side effect of rate control. Given
> >
> > A  A  A  A ratelimit_cgroup_A = 2 * ratelimit_cgroup_B
> >
> > There will naturally be more dirty pages for cgroup A to be worked by
> > the flusher. And the dirty pages will be roughly balanced around
> >
> > A  A  A  A nr_dirty_cgroup_A = 2 * nr_dirty_cgroup_B
> >
> > when writeout bandwidths for their dirty pages are equal.
> >
> >> 2. the global 20% pool is free, unaccounted memory. A Ideally cgroups only
> >> A  A  use the amount of memory specified in their memory.limit_in_bytes. A The
> >> A  A  goal is to sell portions of a system. A Global resource like the 20% are an
> >> A  A  undesirable system-wide tax that's shared by jobs that may not even
> >> A  A  perform buffered writes.
> >
> > Right, it is the shortcoming.
> >
> >> 3. Setting aside 20% extra memory for system wide dirty buffers is a lot of
> >> A  A  memory. A This becomes a larger issue when the global dirty_ratio is
> >> A  A  higher than 20%.
> >
> > Yeah the global pool scheme does mean that you'd better allocate at
> > most 80% memory to individual memory cgroups, otherwise it's possible
> > for a tiny memcg doing dd writes to push dirty pages to global LRU and
> > *squeeze* the size of other memcgs.
> >
> > However I guess it should be mitigated by the fact that
> >
> > - we typically already reserve some space for the root memcg
> 
> Can you give more details on that? AFAIK, we don't treat root cgroup
> differently than other sub-cgroups, except root cgroup doesn't have
> limit.

OK. I'd imagine this to be the typical usage for desktop and quite a
few servers: a few cgroups are employed to limit the resource usage
for selected tasks (such as backups, background GUI tasks, cron tasks,
etc.). These systems are still running mainly in the global context.

> In general, I don't like the idea of shared pool in root for all the
> dirty pages.
> 
> Imagining a system which has nothing running under root and every
> application runs within sub-cgroup. It is easy to track and limit each
> cgroup's memory usage, but not the pages being moved to root. We have
> been experiencing difficulties of tracking pages being re-parented to
> root, and this will make it even harder.

So you want to push memcg allocations to the hardware limits. This is
a worthwhile target for cloud servers that run a number of well
contained jobs.

I guess it can be achieved reasonably well with the global shared
dirty pool.  Let's discuss the two major cases.

1) no change of behavior

For example, when the system memory is divided equally to 10 cgroups
each running 1 dd. In this case, the dirty pages will be contained
within the memcg LRUs. Page reclaim rarely encounters any dirty pages.
There is no moving to the global LRU, so no side effect at all.

2) small memcg squeezing other memcg(s)

When system memory is divided to 1 small memcg A and 1 large memcg B,
each running a dd task. In this case the dirty pages from A will be
moved to the global LRU, and global page reclaims will be triggered.

In the end it will be balanced around

- global LRU: 10% memory (which are A's dirty pages)
- memcg B: 90% memory
- memcg A: a tiny ignorable fraction of memory

Now job B uses 10% less memory than w/o the global dirty pool scheme.
I guess this is bad for some type of jobs.

However my question is, will the typical demand be more flexible?
Something like the "minimal" and "recommended" setup: "this job
requires at least XXX memory and better at YYY memory", rather than
some fixed size memory allocation.

The minimal requirement should be trivially satisfied by adding a
memcg watermark that protects the memcg LRU from being reclaimed
when dropped under it.

Then the cloud server could be configured to

        sum(memcg.limit_in_bytes) / memtotal = 100%
        sum(memcg.minimal_size)   / memtotal < 100% - dirty_ratio

Which makes a simple and flexibly partitioned system.

Thanks,
Fengguang

> > - 20% dirty ratio is mostly an overkill for large memory systems.
> > A It's often enough to hold 10-30s worth of dirty data for them, which
> > A is 1-3GB for one 100MB/s disk. This is the reason vm.dirty_bytes is
> > A introduced: someone wants to do some <1% dirty ratio.
> >
> > Thanks,
> > Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
