Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 109616B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:26:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so393799517pfb.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:26:07 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id on7si26227187pac.140.2016.06.27.04.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 04:26:05 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id hf6so15128058pac.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:26:05 -0700 (PDT)
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <57710D39.4060109@gmail.com>
Date: Mon, 27 Jun 2016 21:25:45 +1000
MIME-Version: 1.0
In-Reply-To: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 26/05/16 16:22, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hello,
> 
> Changes from v2
> o Rebase on next-20160525
> o No other changes except following description
> 
> There was a discussion with Mel [1] after LSF/MM 2016. I could summarise
> it to help merge decision but it's better to read by yourself since
> if I summarise it, it would be biased for me. But, if anyone hope
> the summary, I will do it. :)
> 
> Anyway, Mel's position on this patchset seems to be neutral. He said:
> "I'm not going to outright NAK your series but I won't ACK it either"
> 
> We can fix the problems with any approach but I hope to go a new zone
> approach because it is less error-prone. It reduces some corner case
> handling for now and remove need for potential corner case handling to fix
> problems.
> 
> Note that our company is already using ZONE_CMA for a years and
> there is no problem.
> 
> If anyone has a different opinion, please let me know and let's discuss
> together.
> 
> Andrew, if there is something to do for merge, please let me know.
> 
> [1] https://lkml.kernel.org/r/20160425053653.GA25662@js1304-P5Q-DELUXE
> 
> Changes from v1
> o Separate some patches which deserve to submit independently
> o Modify description to reflect current kernel state
> (e.g. high-order watermark problem disappeared by Mel's work)
> o Don't increase SECTION_SIZE_BITS to make a room in page flags
> (detailed reason is on the patch that adds ZONE_CMA)
> o Adjust ZONE_CMA population code
> 
> This series try to solve problems of current CMA implementation.
> 
> CMA is introduced to provide physically contiguous pages at runtime
> without exclusive reserved memory area. But, current implementation
> works like as previous reserved memory approach, because freepages
> on CMA region are used only if there is no movable freepage. In other
> words, freepages on CMA region are only used as fallback. In that
> situation where freepages on CMA region are used as fallback, kswapd
> would be woken up easily since there is no unmovable and reclaimable
> freepage, too. If kswapd starts to reclaim memory, fallback allocation
> to MIGRATE_CMA doesn't occur any more since movable freepages are
> already refilled by kswapd and then most of freepage on CMA are left
> to be in free. This situation looks like exclusive reserved memory case.

I am afraid I don't understand the problem statement completely understand.
Is this the ALLOC_CMA case or the !ALLOC_CMA one? I also think one other
problem is that in my experience and observation all CMA allocations seem
to come from one node-- the highest node on the system

> 
> In my experiment, I found that if system memory has 1024 MB memory and
> 512 MB is reserved for CMA, kswapd is mostly woken up when roughly 512 MB
> free memory is left. Detailed reason is that for keeping enough free
> memory for unmovable and reclaimable allocation, kswapd uses below
> equation when calculating free memory and it easily go under the watermark.
> 
> Free memory for unmovable and reclaimable = Free total - Free CMA pages
> 
> This is derivated from the property of CMA freepage that CMA freepage
> can't be used for unmovable and reclaimable allocation.
> 
> Anyway, in this case, kswapd are woken up when (FreeTotal - FreeCMA)
> is lower than low watermark and tries to make free memory until
> (FreeTotal - FreeCMA) is higher than high watermark. That results
> in that FreeTotal is moving around 512MB boundary consistently. It
> then means that we can't utilize full memory capacity.
> 

OK.. so you are suggesting that we are under-utilizing the memory in the
CMA region?

> To fix this problem, I submitted some patches [1] about 10 months ago,
> but, found some more problems to be fixed before solving this problem.
> It requires many hooks in allocator hotpath so some developers doesn't
> like it. Instead, some of them suggest different approach [2] to fix
> all the problems related to CMA, that is, introducing a new zone to deal
> with free CMA pages. I agree that it is the best way to go so implement
> here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar, I
> decide to add a new zone rather than piggyback on ZONE_MOVABLE since
> they have some differences. First, reserved CMA pages should not be
> offlined.

Why? Why are they special? Even if they are offlined by user action,
one would expect the following to occur

1. User would mark/release the cma region associated with them
2. User would then hotplug the memory

> If freepage for CMA is managed by ZONE_MOVABLE, we need to keep
> MIGRATE_CMA migratetype and insert many hooks on memory hotplug code
> to distiguish hotpluggable memory and reserved memory for CMA in the same
> zone. It would make memory hotplug code which is already complicated
> more complicated.

Again why treat it special, one could potentially deny the hotplug based
on the knowledge of where the CMA region is allocated from

> Second, cma_alloc() can be called more frequently
> than memory hotplug operation and possibly we need to control
> allocation rate of ZONE_CMA to optimize latency in the future.
> In this case, separate zone approach is easy to modify. Third, I'd
> like to see statistics for CMA, separately. Sometimes, we need to debug
> why cma_alloc() is failed and separate statistics would be more helpful
> in this situtaion.
> 
> Anyway, this patchset solves four problems related to CMA implementation.
>

Balbir 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
