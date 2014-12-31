Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5ABEE6B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 21:45:51 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so20179225pdj.14
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 18:45:51 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id x4si42928115pda.9.2014.12.30.18.45.48
        for <linux-mm@kvack.org>;
        Tue, 30 Dec 2014 18:45:49 -0800 (PST)
Message-ID: <54A36359.7030701@lge.com>
Date: Wed, 31 Dec 2014 11:45:45 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <20141229023639.GC27095@bbox> <54A1B11A.6020307@codeaurora.org> <20141230044726.GA22342@bbox> <54A34A1C.90603@lge.com> <20141231021831.GD22342@bbox>
In-Reply-To: <20141231021831.GD22342@bbox>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, rostedt@goodmis.org, namhyung@kernel.org



2014-12-31 i??i ? 11:18i?? Minchan Kim i?'(e??) i?' e,?:
> Hey, Gioh
>
> On Wed, Dec 31, 2014 at 09:58:04AM +0900, Gioh Kim wrote:
>>
>>
>> 2014-12-30 i??i?? 1:47i?? Minchan Kim i?'(e??) i?' e,?:
>>> On Mon, Dec 29, 2014 at 11:52:58AM -0800, Laura Abbott wrote:
>>>> On 12/28/2014 6:36 PM, Minchan Kim wrote:
>>>>> Hello,
>>>>>
>>>>> On Fri, Dec 26, 2014 at 05:39:01PM +0300, Stefan I. Strogin wrote:
>>>>>> Hello all,
>>>>>>
>>>>>> Here is a patch set that adds /proc/cmainfo.
>>>>>>
>>>>>> When compiled with CONFIG_CMA_DEBUG /proc/cmainfo will contain information
>>>>>> about about total, used, maximum free contiguous chunk and all currently
>>>>>> allocated contiguous buffers in CMA regions. The information about allocated
>>>>>> CMA buffers includes pid, comm, allocation latency and stacktrace at the
>>>>>> moment of allocation.
>>>>>
>>>>> It just says what you are doing but you didn't say why we need it.
>>>>> I can guess but clear description(ie, the problem what you want to
>>>>> solve with this patchset) would help others to review, for instance,
>>>>> why we need latency, why we need callstack, why we need new wheel
>>>>> rather than ftrace and so on.
>>>>>
>>>>> Thanks.
>>>>>
>>>>
>>>>
>>>> I've been meaning to write something like this for a while so I'm
>>>> happy to see an attempt made to fix this. I can't speak for the
>>>> author's reasons for wanting this information but there are
>>>> several reasons why I was thinking of something similar.
>>>>
>>>> The most common bug reports seen internally on CMA are 1) CMA is
>>>> too slow and 2) CMA failed to allocate memory. For #1, not all
>>>> allocations may be slow so it's useful to be able to keep track
>>>> of which allocations are taking too long. For #2, migration
>>>
>>> Then, I don't think we could keep all of allocations. What we need
>>> is only slow allocations. I hope we can do that with ftrace.
>>>
>>> ex)
>>>
>>> # cd /sys/kernel/debug/tracing
>>> # echo 1 > options/stacktrace
>>> # echo cam_alloc > set_ftrace_filter
>>> # echo your_threshold > tracing_thresh
>>>
>>> I know it doesn't work now but I think it's more flexible
>>> and general way to handle such issues(ie, latency of some functions).
>>> So, I hope we could enhance ftrace rather than new wheel.
>>> Ccing ftrace people.
>>
>> For CMA performance test or code flow check, ftrace is better.
>>
>> ex)
>> echo cma_alloc > /sys/kernel/debug/tracing/set_graph_function
>> echo function_graph > /sys/kernel/debug/tracing/current_tracer
>> echo funcgraph-proc > /sys/kernel/debug/tracing/trace_options
>> echo nosleep-time > /sys/kernel/debug/tracing/trace_options
>> echo funcgraph-tail > /sys/kernel/debug/tracing/trace_options
>> echo 1 > /sys/kernel/debug/tracing/tracing_on
>
> I didn't know such detail. Thanks for the tip, Gioh.
>
>>
>> This can trace every cam_alloc and allocation time.
>> I think ftrace is better to debug latency.
>> If a buffer had allocated and had peak latency and freed,
>> we can check it.
>
> Agree.
>
>>
>> But ftrace doesn't provide current status how many buffers we have and what address it is.
>> So I think debugging information is useful.
>
> I didn't say debug information is useless.
> If we need to know snapshot of cma at the moment,
> describe why we need it and send a patch to implement the idea
> rather than dumping lots of information is always better.

Yes, you're right.
I mean this patch is useful to me.
I sometimes need to check each drivers has buffers that are correctly located and aligned.


>
>>
>>
>>
>>>
>>> Futhermore, if we really need to have such information, we need more data
>>> (ex, how many of pages were migrated out, how many pages were dropped
>>> without migrated, how many pages were written back, how many pages were
>>> retried with the page lock and so on).
>>> In this case, event trace would be better.
>>>
>>>
>>>> failure is fairly common but it's still important to rule out
>>>> a memory leak from a dma client. Seeing all the allocations is
>>>> also very useful for memory tuning (e.g. how big does the CMA
>>>> region need to be, which clients are actually allocating memory).
>>>
>>> Memory leak is really general problem and could we handle it with
>>> page_owner?
>>>
>>>>
>>>> ftrace is certainly usable for tracing CMA allocation callers and
>>>> latency. ftrace is still only a fixed size buffer though so it's
>>>> possible for information to be lost if other logging is enabled.
>>>
>>> Sorry, I don't get with only above reasons why we need this. :(
>>>
>>>> For most of the CMA use cases, there is a very high cost if the
>>>> proper debugging information is not available so the more that
>>>> can be guaranteed the better.
>>>>
>>>> It's also worth noting that the SLUB allocator has a sysfs
>>>> interface for showing allocation callers when CONFIG_SLUB_DEBUG
>>>> is enabled.
>>>>
>>>> Thanks,
>>>> Laura
>>>>
>>>> --
>>>> Qualcomm Innovation Center, Inc.
>>>> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
>>>> a Linux Foundation Collaborative Project
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
