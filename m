Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 663506B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 14:53:02 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id at20so12656216iec.33
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 11:53:02 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id qf10si26364624icb.72.2014.12.29.11.53.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Dec 2014 11:53:01 -0800 (PST)
Message-ID: <54A1B11A.6020307@codeaurora.org>
Date: Mon, 29 Dec 2014 11:52:58 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <20141229023639.GC27095@bbox>
In-Reply-To: <20141229023639.GC27095@bbox>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

On 12/28/2014 6:36 PM, Minchan Kim wrote:
> Hello,
>
> On Fri, Dec 26, 2014 at 05:39:01PM +0300, Stefan I. Strogin wrote:
>> Hello all,
>>
>> Here is a patch set that adds /proc/cmainfo.
>>
>> When compiled with CONFIG_CMA_DEBUG /proc/cmainfo will contain information
>> about about total, used, maximum free contiguous chunk and all currently
>> allocated contiguous buffers in CMA regions. The information about allocated
>> CMA buffers includes pid, comm, allocation latency and stacktrace at the
>> moment of allocation.
>
> It just says what you are doing but you didn't say why we need it.
> I can guess but clear description(ie, the problem what you want to
> solve with this patchset) would help others to review, for instance,
> why we need latency, why we need callstack, why we need new wheel
> rather than ftrace and so on.
>
> Thanks.
>


I've been meaning to write something like this for a while so I'm
happy to see an attempt made to fix this. I can't speak for the
author's reasons for wanting this information but there are
several reasons why I was thinking of something similar.

The most common bug reports seen internally on CMA are 1) CMA is
too slow and 2) CMA failed to allocate memory. For #1, not all
allocations may be slow so it's useful to be able to keep track
of which allocations are taking too long. For #2, migration
failure is fairly common but it's still important to rule out
a memory leak from a dma client. Seeing all the allocations is
also very useful for memory tuning (e.g. how big does the CMA
region need to be, which clients are actually allocating memory).

ftrace is certainly usable for tracing CMA allocation callers and
latency. ftrace is still only a fixed size buffer though so it's
possible for information to be lost if other logging is enabled.
For most of the CMA use cases, there is a very high cost if the
proper debugging information is not available so the more that
can be guaranteed the better.

It's also worth noting that the SLUB allocator has a sysfs
interface for showing allocation callers when CONFIG_SLUB_DEBUG
is enabled.

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
