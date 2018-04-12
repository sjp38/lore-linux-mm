Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 458516B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:16:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17so2853734pfn.10
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 06:16:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 70-v6si3327491ple.372.2018.04.12.06.16.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 06:16:37 -0700 (PDT)
Date: Thu, 12 Apr 2018 15:16:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
Message-ID: <20180412131634.GF23400@dhcp22.suse.cz>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
 <EB9E8FC6-8B02-4D7C-AA50-2B5B6BD2AF40@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EB9E8FC6-8B02-4D7C-AA50-2B5B6BD2AF40@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org

On Tue 03-04-18 12:41:56, Buddy Lumpkin wrote:
> 
> > On Apr 3, 2018, at 6:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Mon 02-04-18 09:24:22, Buddy Lumpkin wrote:
> >> Page replacement is handled in the Linux Kernel in one of two ways:
> >> 
> >> 1) Asynchronously via kswapd
> >> 2) Synchronously, via direct reclaim
> >> 
> >> At page allocation time the allocating task is immediately given a page
> >> from the zone free list allowing it to go right back to work doing
> >> whatever it was doing; Probably directly or indirectly executing business
> >> logic.
> >> 
> >> Just prior to satisfying the allocation, free pages is checked to see if
> >> it has reached the zone low watermark and if so, kswapd is awakened.
> >> Kswapd will start scanning pages looking for inactive pages to evict to
> >> make room for new page allocations. The work of kswapd allows tasks to
> >> continue allocating memory from their respective zone free list without
> >> incurring any delay.
> >> 
> >> When the demand for free pages exceeds the rate that kswapd tasks can
> >> supply them, page allocation works differently. Once the allocating task
> >> finds that the number of free pages is at or below the zone min watermark,
> >> the task will no longer pull pages from the free list. Instead, the task
> >> will run the same CPU-bound routines as kswapd to satisfy its own
> >> allocation by scanning and evicting pages. This is called a direct reclaim.
> >> 
> >> The time spent performing a direct reclaim can be substantial, often
> >> taking tens to hundreds of milliseconds for small order0 allocations to
> >> half a second or more for order9 huge-page allocations. In fact, kswapd is
> >> not actually required on a linux system. It exists for the sole purpose of
> >> optimizing performance by preventing direct reclaims.
> >> 
> >> When memory shortfall is sufficient to trigger direct reclaims, they can
> >> occur in any task that is running on the system. A single aggressive
> >> memory allocating task can set the stage for collateral damage to occur in
> >> small tasks that rarely allocate additional memory. Consider the impact of
> >> injecting an additional 100ms of latency when nscd allocates memory to
> >> facilitate caching of a DNS query.
> >> 
> >> The presence of direct reclaims 10 years ago was a fairly reliable
> >> indicator that too much was being asked of a Linux system. Kswapd was
> >> likely wasting time scanning pages that were ineligible for eviction.
> >> Adding RAM or reducing the working set size would usually make the problem
> >> go away. Since then hardware has evolved to bring a new struggle for
> >> kswapd. Storage speeds have increased by orders of magnitude while CPU
> >> clock speeds stayed the same or even slowed down in exchange for more
> >> cores per package. This presents a throughput problem for a single
> >> threaded kswapd that will get worse with each generation of new hardware.
> > 
> > AFAIR we used to scale the number of kswapd workers many years ago. It
> > just turned out to be not all that great. We have a kswapd reclaim
> > window for quite some time and that can allow to tune how much proactive
> > kswapd should be.
> 
> Are you referring to vm.watermark_scale_factor?

Yes along with min_free_kbytes

> This helps quite a bit. Previously
> I had to increase min_free_kbytes in order to get a larger gap between the low
> and min watemarks. I was very excited when saw that this had been added
> upstream. 
> 
> > 
> > Also please note that the direct reclaim is a way to throttle overly
> > aggressive memory consumers.
> 
> I totally agree, in fact I think this should be the primary role of direct reclaims
> because they have a substantial impact on performance. Direct reclaims are
> the emergency brakes for page allocation, and the case I am making here is 
> that they used to only occur when kswapd had to skip over a lot of pages. 

Or when it is busy reclaiming which can be the case quite easily if you
do not have the inactive file LRU full of clean page cache. And that is
another problem. If you have a trivial reclaim situation then a single
kswapd thread can reclaim quickly enough. But once you hit a wall with
hard-to-reclaim pages then I would expect multiple threads will simply
contend more (e.g. on fs locks in shrinkers etc...). Or how do you want
to prevent that?

Or more specifically. How is the admin supposed to know how many
background threads are still improving the situation?

> This changed over time as the rate a system can allocate pages increased. 
> Direct reclaims slowly became a normal part of page replacement. 
> 
> > The more we do in the background context
> > the easier for them it will be to allocate faster. So I am not really
> > sure that more background threads will solve the underlying problem. It
> > is just a matter of memory hogs tunning to end in the very same
> > situtation AFAICS. Moreover the more they are going to allocate the more
> > less CPU time will _other_ (non-allocating) task get.
> 
> The important thing to realize here is that kswapd and direct reclaims run the
> same code paths. There is very little that they do differently.

Their target is however completely different. Kswapd want to keep nodes
balanced while direct reclaim aims to reclaim _some_ memory. That is
quite some difference. Especially for the throttle by reclaiming memory
part.

> If you compare
> my test results with one kswapd vs four, your an see that direct reclaims
> increase the kernel mode CPU consumption considerably. By dedicating
> more threads to proactive page replacement, you eliminate direct reclaims
> which reduces the total number of parallel threads that are spinning on the
> CPU.

I still haven't looked at your test results in detail because they seem
quite artificial. Clean pagecache reclaim is not all that interesting
IMHO

[...]
> > I would be also very interested
> > to see how to scale the number of threads based on how CPUs are utilized
> > by other workloads.
> 
> I think we have reached the point where it makes sense for page replacement to have more
> than one mode. Enterprise class servers with lots of memory and a large number of CPU
> cores would benefit heavily if more threads could be devoted toward proactive page
> replacement. The polar opposite case is my Raspberry PI which I want to run as efficiently
> as possible. This problem is only going to get worse. I think it makes sense to be able to 
> choose between efficiency and performance (throughput and latency reduction).

The thing is that as long as this would require admin to guess then this
is not all that useful. People will simply not know what to set and we
are going to end up with stupid admin guides claiming that you should
use 1/N of per node cpus for kswapd and that will not work. Not to
mention that the reclaim logic is full of heuristics which change over
time and a subtle implementation detail that would work for a particular
scaling might break without anybody noticing. Really, if we are not able
to come up with some auto tuning then I think that this is not really
worth it.

-- 
Michal Hocko
SUSE Labs
