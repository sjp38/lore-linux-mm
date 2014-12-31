Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C37C06B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 19:22:59 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so20447572pad.29
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 16:22:59 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id rc8si51884936pdb.83.2014.12.30.16.22.56
        for <linux-mm@kvack.org>;
        Tue, 30 Dec 2014 16:22:58 -0800 (PST)
Date: Wed, 31 Dec 2014 09:25:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
Message-ID: <20141231002502.GB22342@bbox>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <20141229023639.GC27095@bbox>
 <54A1B11A.6020307@codeaurora.org>
 <20141230044726.GA22342@bbox>
 <54A3207B.3000601@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <54A3207B.3000601@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, rostedt@goodmis.org, namhyung@kernel.org

On Tue, Dec 30, 2014 at 02:00:27PM -0800, Laura Abbott wrote:
> On 12/29/2014 8:47 PM, Minchan Kim wrote:
> >>
> >>
> >>I've been meaning to write something like this for a while so I'm
> >>happy to see an attempt made to fix this. I can't speak for the
> >>author's reasons for wanting this information but there are
> >>several reasons why I was thinking of something similar.
> >>
> >>The most common bug reports seen internally on CMA are 1) CMA is
> >>too slow and 2) CMA failed to allocate memory. For #1, not all
> >>allocations may be slow so it's useful to be able to keep track
> >>of which allocations are taking too long. For #2, migration
> >
> >Then, I don't think we could keep all of allocations. What we need
> >is only slow allocations. I hope we can do that with ftrace.
> >
> >ex)
> >
> ># cd /sys/kernel/debug/tracing
> ># echo 1 > options/stacktrace
> ># echo cam_alloc > set_ftrace_filter
> ># echo your_threshold > tracing_thresh
> >
> >I know it doesn't work now but I think it's more flexible
> >and general way to handle such issues(ie, latency of some functions).
> >So, I hope we could enhance ftrace rather than new wheel.
> >Ccing ftrace people.
> >
> >Futhermore, if we really need to have such information, we need more data
> >(ex, how many of pages were migrated out, how many pages were dropped
> >without migrated, how many pages were written back, how many pages were
> >retried with the page lock and so on).
> >In this case, event trace would be better.
> >
> >
> 
> I agree ftrace is significantly more flexible in many respects but
> for the type of information we're actually trying to collect here
> ftrace may not be the right tool. Often times it won't be obvious there
> will be a problem when starting a test so all debugging information
> needs to be enabled. If the debugging information needs to be on
> almost all the time anyway it seems silly to allow it be configurable
> via ftrace.

There is a trade off. Instead, ftrace will collect the information
with small overhead in runtime, even alomost zero-overhead when
we turns off so we could investigate the problem in live machine
without rebooting/rebuiling.

If the problem you are trying to solve is latency, I think ftrace
with more data(ie, # of migrated page, # of stall by dirty or
locking and so on) would be better. As current interface, something
did cma_alloc which was really slow but it just cma_release right before
we looked at the /proc/cmainfo. In that case, we will miss the
information. It means someone should poll cmainfo continuously to
avoid the missing so we should make reading part of cmainfo fast
or make notification mechanism or keep only top 10 entries.

Let's think as different view. If we know via cmainfo some function
was slow, it's always true? Slowness of cma_alloc depends migration
latency as well as cma region fragmentation so the function which
was really slow would be fast in future if we are luck while
fast function in old could be slower in future if there are lots of
dirty pages or small small contiguous space in CMA region.
I mean some funcion itself is slow or fast is not a important parameter
to pinpoint cma's problem if we should take care of CMA's slowness or
failing.

Anyway, I'm not saying I don't want to add any debug facility
to CMA. My point is this patchset doesn't say why author need it
so it's hard to review the code. Depending on the problem author
is looking, we should review what kinds of data, what kinds of
interface, what kinds of implementation need.
So please say more specific rather than just having better.

> 
> >>failure is fairly common but it's still important to rule out
> >>a memory leak from a dma client. Seeing all the allocations is
> >>also very useful for memory tuning (e.g. how big does the CMA
> >>region need to be, which clients are actually allocating memory).
> >
> >Memory leak is really general problem and could we handle it with
> >page_owner?
> >
> 
> True, but it gets difficult to narrow down which are CMA pages allocated
> via the contiguous code path. page owner also can't differentiate between

I don't get it. The page_owner provides backtrace so why is it hard
to parse contiguous code path?

> different CMA regions, this needs to be done separately. This may

Page owner just report PFN and we know which pfn range is any CMA regions
so can't we do postprocessing?

> be a sign page owner needs some extensions independent of any CMA
> work.
> >>
> >>ftrace is certainly usable for tracing CMA allocation callers and
> >>latency. ftrace is still only a fixed size buffer though so it's
> >>possible for information to be lost if other logging is enabled.
> >
> >Sorry, I don't get with only above reasons why we need this. :(
> >
> 
> I guess from my perspective the problem that is being solved here
> is a fairly fixed static problem. We know the information we always
> want to collect and have available so the ability to turn it off
> and on via ftrace doesn't seem necessary. The ftrace maintainers
> will probably disagree here but doing 'cat foo' on a file is
> easier than finding the particular events, setting thresholds,
> collecting the trace and possibly post processing. It seems like
> this is conflating tracing which ftrace does very well with getting
> a snapshot of the system at a fixed point in time which is what
> debugfs files are designed for. We really just want a snapshot of
> allocation history with some information about those allocations.
> There should be more ftrace events in the CMA path but I think those
> should be in supplement to the debugfs interface and not a replacement.

Again say, please more specific what kinds of problem you want to solve.
If it includes several problems(you said latency, leak), please
divide the patchset to solve each problem. Without it, there is no worth
to dive into code.

> 
> Thanks,
> Laura
> 
> -- 
> Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> a Linux Foundation Collaborative Project
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
