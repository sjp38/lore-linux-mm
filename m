Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1663E6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:22:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so220121530pfa.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 23:22:29 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a74si4821966pfa.164.2016.06.23.23.22.27
        for <linux-mm@kvack.org>;
        Thu, 23 Jun 2016 23:22:27 -0700 (PDT)
Date: Fri, 24 Jun 2016 15:22:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160624062236.GA2493@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-11-hannes@cmpxchg.org>
 <20160610021935.GF29779@bbox>
 <20160613155231.GB30642@cmpxchg.org>
 <20160615022341.GF17127@bbox>
 <20160616151207.GB17692@cmpxchg.org>
 <20160617074945.GE2374@bbox>
 <20160617170128.GB10485@cmpxchg.org>
 <20160620074208.GA28207@bbox>
 <20160622215652.GB24150@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622215652.GB24150@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Wed, Jun 22, 2016 at 05:56:52PM -0400, Johannes Weiner wrote:
> On Mon, Jun 20, 2016 at 04:42:08PM +0900, Minchan Kim wrote:
> > On Fri, Jun 17, 2016 at 01:01:29PM -0400, Johannes Weiner wrote:
> > > On Fri, Jun 17, 2016 at 04:49:45PM +0900, Minchan Kim wrote:
> > > > On Thu, Jun 16, 2016 at 11:12:07AM -0400, Johannes Weiner wrote:
> > > > > On Wed, Jun 15, 2016 at 11:23:41AM +0900, Minchan Kim wrote:
> > > > > > Do we want to retain [1]?
> > > > > > 
> > > > > > This patch motivates from swap IO could be much faster than file IO
> > > > > > so that it would be natural if we rely on refaulting feedback rather
> > > > > > than forcing evicting file cache?
> > > > > > 
> > > > > > [1] e9868505987a, mm,vmscan: only evict file pages when we have plenty?
> > > > > 
> > > > > Yes! We don't want to go after the workingset, whether it be cache or
> > > > > anonymous, while there is single-use page cache lying around that we
> > > > > can reclaim for free, with no IO and little risk of future IO. Anon
> > > > > memory doesn't have this equivalent. Only cache is lazy-reclaimed.
> > > > > 
> > > > > Once the cache refaults, we activate it to reflect the fact that it's
> > > > > workingset. Only when we run out of single-use cache do we want to
> > > > > reclaim multi-use pages, and *then* we balance workingsets based on
> > > > > cost of refetching each side from secondary storage.
> > > > 
> > > > If pages in inactive file LRU are really single-use page cache, I agree.
> > > > 
> > > > However, how does the logic can work like that?
> > > > If reclaimed file pages were part of workingset(i.e., refault happens),
> > > > we give the pressure to anonymous LRU but get_scan_count still force to
> > > > reclaim file lru until inactive file LRU list size is enough low.
> > > > 
> > > > With that, too many file workingset could be evicted although anon swap
> > > > is cheaper on fast swap storage?
> > > > 
> > > > IOW, refault mechanisme works once inactive file LRU list size is enough
> > > > small but small inactive file LRU doesn't guarantee it has only multiple
> > > > -use pages. Hm, Isn't it a problem?
> > > 
> > > It's a trade-off between the cost of detecting a new workingset from a
> > > stream of use-once pages, and the cost of use-once pages impose on the
> > > established workingset.
> > > 
> > > That's a pretty easy choice, if you ask me. I'd rather ask cache pages
> > > to prove they are multi-use than have use-once pages put pressure on
> > > the workingset.
> > 
> > Make sense.
> > 
> > > 
> > > Sure, a spike like you describe is certainly possible, where a good
> > > portion of the inactive file pages will be re-used in the near future,
> > > yet we evict all of them in a burst of memory pressure when we should
> > > have swapped. That's a worst case scenario for the use-once policy in
> > > a workingset transition.
> > 
> > So, the point is how such case it happens frequently. A scenario I can
> > think of is that if we use one-cgroup-per-app, many file pages would be
> > inactive LRU while active LRU is almost empty until reclaim kicks in.
> > Because normally, parallel reclaim work during launching new app makes
> > app's startup time really slow. That's why mobile platform uses notifiers
> > to get free memory in advance via kiling/reclaiming. Anyway, once we get
> > amount of free memory and lauching new app in a new cgroup, pages would
> > live his born LRU list(ie, anon: active file: inactive) without aging.
> > 
> > Then, activity manager can set memory.high of less important app-cgroup
> > to reclaim it with high value swappiness because swap device is much
> > faster on that system and much bigger anonymous pages compared to file-
> > backed pages. Surely, activity manager will expect lots of anonymous
> > pages be able to swap out but unlike expectation, he will see such spike
> > easily with reclaiming file-backed pages a lot and refault until inactive
> > file LRU is enough small.
> > 
> > I think it's enough possible scenario in small system one-cgroup-per-
> > app.
> 
> That's the workingset transition I was talking about. The algorithm is
> designed to settle towards stable memory patterns. We can't possibly
> remove one of the key components of this - the use-once policy - to
> speed up a few seconds of workingset transition when it comes at the
> risk of potentially thrashing the workingset for *hours*.
> 
> The fact that swap IO can be faster than filesystem IO doesn't change
> this at all. The point is that the reclaim and refetch IO cost of
> use-once cache is ZERO. Causing swap IO to make room for more and more
> unused cache pages doesn't make any sense, no matter the swap speed.

I agree your overall point about use-once first reclaim and as I said
previos mail, I didn't want to remove e9868505987a entirely.

My concern was unconditionally scanning of only file lru until inactive
list is enough low by magic value(3:1 or 1:1) is too heuristic to reclaim
use-once pages first so that it could evict non used-once file backed
pages too much.

Even, let's think about MADV_FREEed page in anonymous LRU list.
They might be more attractive candidate for reclaim.
Even, Userspace already paid for the madvise syscall to prefer
but VM unconditionally keeps them until inactive file lru is enough
small under assumption that we should sweep used-once file pages
firstly and unfortune multi-use page reclaim is trade-off to detect
workingset transitions so user should take care of it although he
wanted to prefer anonymous via vm_swappiness.

I don't think it makes sense. The vm_swappiness is user preference
knob. He can know his system workload better than kernel. For example,
a user might want to degrade overall system performance by swapping
out anonymous more but want to keep file pages to reduce latency spike
to access those file pages when some event happens suddenly.
But kernel ignores it until inactive lru is enough small.

pages. And please think over MADV_FREEed pages. They might be more
attractive candidate for reclaim point of view.
use-once file pages

A idea in my mind is as follows.
You nicely abstract cost model in this patchset so if scanning cost
of either LRU is too higher than paging-in/out(e.g., 32 * 2 *
SWAP_CLUSTER_MAX) in other LRU, we can break unconditional scanning
and turn into other LRU to prove it's valuable workingset temporally.
And repeated above cycle rather than sweeping inactive file LRU only.
I think it can mitigate the workload tranistion spike with hanlding
cold/freeable pages fairly in anonymous LRU list.

> 
> I really don't see the relevance of this discussion to this patch set.

Hm, yes, the thing I had a concern is *not* new introduced by your patch
but it has been there for a long time but your patch's goal is to avoid
balancing code mostly going for page cache favor and exploit the
potential of fast swap device as you described in cover-letter.
However, e9868505987a might be one of conflict with that approach.
That was why I raise an issue.

If you think it's separate issue, I don't want to make your nice job
stucked and waste your time. It could be revisited afterward.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
