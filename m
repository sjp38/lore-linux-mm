Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 716446B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 01:32:43 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so6654650pad.8
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 22:32:43 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ss1si667933pab.184.2015.01.22.22.32.40
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 22:32:42 -0800 (PST)
Date: Fri, 23 Jan 2015 15:33:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
Message-ID: <20150123063342.GA809@js1304-P5Q-DELUXE>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <20141229023639.GC27095@bbox>
 <54A1B11A.6020307@codeaurora.org>
 <20141230044726.GA22342@bbox>
 <54A3207B.3000601@codeaurora.org>
 <20141231002502.GB22342@bbox>
 <54BFAF24.5020202@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54BFAF24.5020202@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, rostedt@goodmis.org, namhyung@kernel.org, stefan.strogin@gmail.com

On Wed, Jan 21, 2015 at 04:52:36PM +0300, Stefan Strogin wrote:
> Sorry for such a long delay. Now I'll try to answer all the questions
> and make a second version.
> 
> The original reason of why we need a new debugging tool for CMA is
> written by Minchan (http://www.spinics.net/lists/linux-mm/msg81519.html):
> > 3. CMA allocation latency -> Broken
> > 4. CMA allocation success guarantee -> Broken.
> 
> We have no acceptable solution for these problems yet. We use CMA in our
> devices. But currently for lack of allocation guarantee there are some
> memory buffers that are always allocated at boot time even if they're
> not used. However we'd like to allocate contiguous buffers in runtime as
> much as it's possible.
> 
> First we want an interface like /proc/vmallocinfo to see that all needed
> contiguous buffers are allocated correctly, used/free memory in CMA
> regions (like in /proc/meminfo) and also CMA region's fragmentation.

Hello,

I agree that we need some information to debug or improve CMA.

But, why these complicate data structure in your code are needed for
information like as vmallocinfo? Just printing bitmap of struct cma seems
sufficient to me to check alignment and fragmentation problem.

> Stacktrace is used to see who and whence allocated each buffer. Since
> vmallocinfo and meminfo are located in /proc I thought that cmainfo
> should be in /proc too. Maybe latency is really unnecessary here (see
> hereinafter).

I guess that adding some tracepoints on alloc/free functions could
accomplish your purpose. They can print vairous information you want
and can also print stacktrace.

Thanks.

> 
> Second (not implemented yet) we want to debug 3) and 4) (especially in
> case of allocating in runtime). One of the main reasons of failed and
> slow allocations is pinning <<movable>> pages for a long time, so they
> can't be moved (SeongJae Park described it:
> http://lwn.net/Articles/619865/).
> To debug such cases we want to know for each allocation (for failed ones
> as well) its latency and some information about page migration, e.g. the
> number of pages that couldn't be migrated, why and page_owner's
> information for pages that failed to be migrated.
> 
> To my mind this might help us to identify subsystems that pin pages for
> too long in order to make such subsystems allocate only unmovable pages
> or fix the long-time page pinning.
> 
> The last thing should be done in debugfs of course. Maybe something like
> this, I'm not sure:
> # cd /sys/kernel/debug/cma/<N>/
> # ls
> allocated failed migration_stat released (...)
> # cat failed
> 0x32400000 - 0x32406000 (24 kB), allocated by pid 63 (systemd-udevd),
> time spent 9000 us
> pages migrations required: 4
> succeeded [by the last try in __alloc_contig_migrate_range()]: 2
> failed/given up [on the last try in __alloc_contig_migrate_range()]: 2,
> page_owner's information for pages that couldn't be migrated.
> 
> # cat migration_stat
> Total pages migration requests: 1000
> Pages migrated successfully: 900
> Pages migration give-ups: 80
> Pages migration failures: 20
> Average tries per successful migration: 1.89
> (some other useful information)
> 
> 
> On 12/31/2014 03:25 AM, Minchan Kim wrote:
> > On Tue, Dec 30, 2014 at 02:00:27PM -0800, Laura Abbott wrote:
> >> On 12/29/2014 8:47 PM, Minchan Kim wrote:
> >>>> I've been meaning to write something like this for a while so I'm
> >>>> happy to see an attempt made to fix this. I can't speak for the
> >>>> author's reasons for wanting this information but there are
> >>>> several reasons why I was thinking of something similar.
> >>>>
> >>>> The most common bug reports seen internally on CMA are 1) CMA is
> >>>> too slow and 2) CMA failed to allocate memory. For #1, not all
> >>>> allocations may be slow so it's useful to be able to keep track
> >>>> of which allocations are taking too long. For #2, migration
> >>> Then, I don't think we could keep all of allocations. What we need
> >>> is only slow allocations. I hope we can do that with ftrace.
> >>>
> >>> ex)
> >>>
> >>> # cd /sys/kernel/debug/tracing
> >>> # echo 1 > options/stacktrace
> >>> # echo cam_alloc > set_ftrace_filter
> >>> # echo your_threshold > tracing_thresh
> >>>
> >>> I know it doesn't work now but I think it's more flexible
> >>> and general way to handle such issues(ie, latency of some functions).
> >>> So, I hope we could enhance ftrace rather than new wheel.
> >>> Ccing ftrace people.
> >>>
> >>> Futhermore, if we really need to have such information, we need more data
> >>> (ex, how many of pages were migrated out, how many pages were dropped
> >>> without migrated, how many pages were written back, how many pages were
> >>> retried with the page lock and so on).
> >>> In this case, event trace would be better.
> >>>
> >>>
> >> I agree ftrace is significantly more flexible in many respects but
> >> for the type of information we're actually trying to collect here
> >> ftrace may not be the right tool. Often times it won't be obvious there
> >> will be a problem when starting a test so all debugging information
> >> needs to be enabled. If the debugging information needs to be on
> >> almost all the time anyway it seems silly to allow it be configurable
> >> via ftrace.
> > There is a trade off. Instead, ftrace will collect the information
> > with small overhead in runtime, even alomost zero-overhead when
> > we turns off so we could investigate the problem in live machine
> > without rebooting/rebuiling.
> >
> > If the problem you are trying to solve is latency, I think ftrace
> > with more data(ie, # of migrated page, # of stall by dirty or
> > locking and so on) would be better. As current interface, something
> > did cma_alloc which was really slow but it just cma_release right before
> > we looked at the /proc/cmainfo. In that case, we will miss the
> > information. It means someone should poll cmainfo continuously to
> > avoid the missing so we should make reading part of cmainfo fast
> > or make notification mechanism or keep only top 10 entries.
> >
> > Let's think as different view. If we know via cmainfo some function
> > was slow, it's always true? Slowness of cma_alloc depends migration
> > latency as well as cma region fragmentation so the function which
> > was really slow would be fast in future if we are luck while
> > fast function in old could be slower in future if there are lots of
> > dirty pages or small small contiguous space in CMA region.
> > I mean some funcion itself is slow or fast is not a important parameter
> > to pinpoint cma's problem if we should take care of CMA's slowness or
> > failing.
> >
> > Anyway, I'm not saying I don't want to add any debug facility
> > to CMA. My point is this patchset doesn't say why author need it
> > so it's hard to review the code. Depending on the problem author
> > is looking, we should review what kinds of data, what kinds of
> > interface, what kinds of implementation need.
> > So please say more specific rather than just having better.
> >
> >>>> failure is fairly common but it's still important to rule out
> >>>> a memory leak from a dma client. Seeing all the allocations is
> >>>> also very useful for memory tuning (e.g. how big does the CMA
> >>>> region need to be, which clients are actually allocating memory).
> >>> Memory leak is really general problem and could we handle it with
> >>> page_owner?
> >>>
> >> True, but it gets difficult to narrow down which are CMA pages allocated
> >> via the contiguous code path. page owner also can't differentiate between
> > I don't get it. The page_owner provides backtrace so why is it hard
> > to parse contiguous code path?
> >
> >> different CMA regions, this needs to be done separately. This may
> > Page owner just report PFN and we know which pfn range is any CMA regions
> > so can't we do postprocessing?
> >
> >> be a sign page owner needs some extensions independent of any CMA
> >> work.
> >>>> ftrace is certainly usable for tracing CMA allocation callers and
> >>>> latency. ftrace is still only a fixed size buffer though so it's
> >>>> possible for information to be lost if other logging is enabled.
> >>> Sorry, I don't get with only above reasons why we need this. :(
> >>>
> >> I guess from my perspective the problem that is being solved here
> >> is a fairly fixed static problem. We know the information we always
> >> want to collect and have available so the ability to turn it off
> >> and on via ftrace doesn't seem necessary. The ftrace maintainers
> >> will probably disagree here but doing 'cat foo' on a file is
> >> easier than finding the particular events, setting thresholds,
> >> collecting the trace and possibly post processing. It seems like
> >> this is conflating tracing which ftrace does very well with getting
> >> a snapshot of the system at a fixed point in time which is what
> >> debugfs files are designed for. We really just want a snapshot of
> >> allocation history with some information about those allocations.
> >> There should be more ftrace events in the CMA path but I think those
> >> should be in supplement to the debugfs interface and not a replacement.
> > Again say, please more specific what kinds of problem you want to solve.
> > If it includes several problems(you said latency, leak), please
> > divide the patchset to solve each problem. Without it, there is no worth
> > to dive into code.
> >
> >> Thanks,
> >> Laura
> >>
> >> -- 
> >> Qualcomm Innovation Center, Inc.
> >> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> >> a Linux Foundation Collaborative Project
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
