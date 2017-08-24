Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9669F440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:47:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y72so741218wrc.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:47:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f66si1558681wmd.163.2017.08.24.05.47.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 05:47:55 -0700 (PDT)
Subject: Re: [RESEND PATCH 0/3] mm: Add cache coloring mechanism
References: <20170823100205.17311-1-lukasz.daniluk@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f95eacd5-0a91-24a0-7722-b63f3c196552@suse.cz>
Date: Thu, 24 Aug 2017 14:47:53 +0200
MIME-Version: 1.0
In-Reply-To: <20170823100205.17311-1-lukasz.daniluk@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?=c5=81ukasz_Daniluk?= <lukasz.daniluk@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dave.hansen@intel.com, lukasz.anaczkowski@intel.com

On 08/23/2017 12:02 PM, A?ukasz Daniluk wrote:
> Patches resend with Linux Kernel Mailing List added correctly this time.
> 
> This patch series adds cache coloring mechanism that works along buddy
> allocator. The solution is opt-in, disabled by default minimally
> interferes with default allocation paths due to added if statements.
> 
> Why would such patches be needed? Big caches with low associativity
> (direct mapped caches, 2-way associative) will benefit from the solution
> the most - it allows for near constant performance through the lifetime
> of a system, despite the allocations and deallocations happening and
> reordering buddy lists.

So the obvious question, what about THPs? Their size should be enough to
contain all the colors with current caches, no? Even on KNL I didn't
find more than "32x 1 MB 16-way L2 caches". This is in addition to the
improved TLB performance, which you want to get as well for such workloads?

> On KNL system, the STREAM benchmark with problem size resulting in its
> internal arrays being of 16GB size will yield bandwidth performance of
> 336GB/s after fresh boot. With cache coloring patches applied and
> enabled, this performance stays near constant (most 1.5% drop observed),
> despite running benchmark multiple times with varying sizes over course
> of days.  Without these patches however, the bandwidth when using such
> allocations drops to 117GB/s - over 65% of irrecoverable performance
> penalty. Workloads that exceed set cache size suffer from decreased
> randomization of allocations with cache coloring enabled, but effect of
> cache usage disappears roughly at the same allocation size.

So was the test with THP's enabled or disabled? And what was the cache
configuration and the values of cache_color_size and
cache_color_min_order parameters?

I'm also confused about the "cache_color_min_order=" parameter. If this
wants to benefit non-THP userspace, then you would need to set it to 0,
right? Or does this mean that indeed you expect THP to not contain all
the colors, so you'd set it to the THP order (9)?

> Solution is divided into three patches. First patch is a preparatory one
> that provides interface for retrieving (information about) free lists
> contained by particular free_area structure.  Second one (parallel
> structure keeping separate list_heads for each cache color in a given
> context) shows general solution overview and is working as it is.
> However, it has serious performance implications with bigger caches due
> to linear search for next color to be used during allocations. Third
> patch (sorting list_heads using RB trees) aims to improve solution's
> performance by replacing linear search for next color with searching in
> RB tree. While improving computational performance, it imposes increased
> memory cost of the solution.
> 
> 
> A?ukasz Daniluk (3):
>   mm: move free_list selection to dedicated functions
>   mm: Add page colored allocation path
>   mm: Add helper rbtree to search for next cache color
> 
>  Documentation/admin-guide/kernel-parameters.txt |   8 +
>  include/linux/mmzone.h                          |  12 +-
>  mm/compaction.c                                 |   4 +-
>  mm/page_alloc.c                                 | 381 ++++++++++++++++++++++--
>  mm/vmstat.c                                     |  10 +-
>  5 files changed, 383 insertions(+), 32 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
