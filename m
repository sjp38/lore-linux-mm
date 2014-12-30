Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id C1EFD6B006E
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 17:00:31 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so14198250iec.10
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 14:00:31 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id k185si25812226iok.8.2014.12.30.14.00.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Dec 2014 14:00:30 -0800 (PST)
Message-ID: <54A3207B.3000601@codeaurora.org>
Date: Tue, 30 Dec 2014 14:00:27 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <20141229023639.GC27095@bbox> <54A1B11A.6020307@codeaurora.org> <20141230044726.GA22342@bbox>
In-Reply-To: <20141230044726.GA22342@bbox>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, rostedt@goodmis.org, namhyung@kernel.org

On 12/29/2014 8:47 PM, Minchan Kim wrote:
>>
>>
>> I've been meaning to write something like this for a while so I'm
>> happy to see an attempt made to fix this. I can't speak for the
>> author's reasons for wanting this information but there are
>> several reasons why I was thinking of something similar.
>>
>> The most common bug reports seen internally on CMA are 1) CMA is
>> too slow and 2) CMA failed to allocate memory. For #1, not all
>> allocations may be slow so it's useful to be able to keep track
>> of which allocations are taking too long. For #2, migration
>
> Then, I don't think we could keep all of allocations. What we need
> is only slow allocations. I hope we can do that with ftrace.
>
> ex)
>
> # cd /sys/kernel/debug/tracing
> # echo 1 > options/stacktrace
> # echo cam_alloc > set_ftrace_filter
> # echo your_threshold > tracing_thresh
>
> I know it doesn't work now but I think it's more flexible
> and general way to handle such issues(ie, latency of some functions).
> So, I hope we could enhance ftrace rather than new wheel.
> Ccing ftrace people.
>
> Futhermore, if we really need to have such information, we need more data
> (ex, how many of pages were migrated out, how many pages were dropped
> without migrated, how many pages were written back, how many pages were
> retried with the page lock and so on).
> In this case, event trace would be better.
>
>

I agree ftrace is significantly more flexible in many respects but
for the type of information we're actually trying to collect here
ftrace may not be the right tool. Often times it won't be obvious there
will be a problem when starting a test so all debugging information
needs to be enabled. If the debugging information needs to be on
almost all the time anyway it seems silly to allow it be configurable
via ftrace.

>> failure is fairly common but it's still important to rule out
>> a memory leak from a dma client. Seeing all the allocations is
>> also very useful for memory tuning (e.g. how big does the CMA
>> region need to be, which clients are actually allocating memory).
>
> Memory leak is really general problem and could we handle it with
> page_owner?
>

True, but it gets difficult to narrow down which are CMA pages allocated
via the contiguous code path. page owner also can't differentiate between
different CMA regions, this needs to be done separately. This may
be a sign page owner needs some extensions independent of any CMA
work.
  
>>
>> ftrace is certainly usable for tracing CMA allocation callers and
>> latency. ftrace is still only a fixed size buffer though so it's
>> possible for information to be lost if other logging is enabled.
>
> Sorry, I don't get with only above reasons why we need this. :(
>

I guess from my perspective the problem that is being solved here
is a fairly fixed static problem. We know the information we always
want to collect and have available so the ability to turn it off
and on via ftrace doesn't seem necessary. The ftrace maintainers
will probably disagree here but doing 'cat foo' on a file is
easier than finding the particular events, setting thresholds,
collecting the trace and possibly post processing. It seems like
this is conflating tracing which ftrace does very well with getting
a snapshot of the system at a fixed point in time which is what
debugfs files are designed for. We really just want a snapshot of
allocation history with some information about those allocations.
There should be more ftrace events in the CMA path but I think those
should be in supplement to the debugfs interface and not a replacement.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
