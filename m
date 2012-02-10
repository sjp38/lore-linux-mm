Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B41BB6B13F4
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 06:57:15 -0500 (EST)
Date: Fri, 10 Feb 2012 19:47:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
Message-ID: <20120210114706.GA4704@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Feb 09, 2012 at 09:51:31PM -0800, Greg Thelen wrote:
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
> >
> > - 20% dirty ratio is mostly an overkill for large memory systems.
> > A It's often enough to hold 10-30s worth of dirty data for them, which
> > A is 1-3GB for one 100MB/s disk. This is the reason vm.dirty_bytes is
> > A introduced: someone wants to do some <1% dirty ratio.
> 
> Have you encountered situations where it's desirable to have more than
> 20% dirty ratio?  I imagine that if the dirty working set is larger
> than 20% increasing dirty ratio would prevent rewrites.

Not encountered in person, but there will sure be such situations.

One may need to dirty some 40% sized in-memory data set and don't want
to be throttled and trigger lots of I/O. In this case increasing the
dirty ratio to 40% will do the job.

The less obvious condition for this to work is, the workload should
avoid much page allocations when working on the large fixed data set.
Otherwise page reclaim will keep running into dirty pages and act badly.

So it looks still pretty compatible with the "reparent to root memcg
on page reclaim" scheme if that job is put into some memcg. There will
be almost no dirty pages encountered during page reclaim, hence no
move and no any side effects.

But if there is another job doing heavy dirtying, that job will eat up
the global 40% dirty limit and heavily impact the above job. This is
one case the memcg dirty ratio can help a lot.

> Leaking dirty memory to a root global dirty pool is concerning.  I
> suspect that under some conditions such pages may remain remain in
> root after writeback indefinitely as clean pages.  I admit this may
> not be the common case, but having such leaks into root can allow low
> priority jobs access entire machine denying service to higher priority
> jobs.

You are right. DoS can be achieved by

        loop {
                dirty one more page
                access all previously dirtied pages
        }

Assuming only !PG_reference pages are moved to the global dirty pool,
it requires someone to access the page in order for it to stay in the
global LRU for one more cycle, and to access it frequently for keeping
it in global LRU indefinitely.

So yes, it's possible for some evil job to DoS the whole box.  It will
be an issue when hosting jobs from untrusted sources (ie. Amazon style
cloud service), which I guess should be running inside KVM?

It should hardly happen in real workloads. If some job does manage to
do so, it probably means some kind of mis-configuration: the memcg is
configured way too small to hold the job's working set.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
