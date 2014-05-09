Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5519C6B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 08:39:11 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so3118897pad.27
        for <linux-mm@kvack.org>; Fri, 09 May 2014 05:39:11 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id gi2si1724142pac.159.2014.05.09.05.39.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 09 May 2014 05:39:10 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N5B0077M4H3V970@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 May 2014 13:39:03 +0100 (BST)
Message-id: <536CCC78.6050806@samsung.com>
Date: Fri, 09 May 2014 14:39:20 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC PATCH 0/3] Aggressively allocate the pages on cma reserved
 memory
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
In-reply-to: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>

Hello,

On 2014-05-08 02:32, Joonsoo Kim wrote:
> This series tries to improve CMA.
>
> CMA is introduced to provide physically contiguous pages at runtime
> without reserving memory area. But, current implementation works like as
> reserving memory approach, because allocation on cma reserved region only
> occurs as fallback of migrate_movable allocation. We can allocate from it
> when there is no movable page. In that situation, kswapd would be invoked
> easily since unmovable and reclaimable allocation consider
> (free pages - free CMA pages) as free memory on the system and free memory
> may be lower than high watermark in that case. If kswapd start to reclaim
> memory, then fallback allocation doesn't occur much.
>
> In my experiment, I found that if system memory has 1024 MB memory and
> has 512 MB reserved memory for CMA, kswapd is mostly invoked around
> the 512MB free memory boundary. And invoked kswapd tries to make free
> memory until (free pages - free CMA pages) is higher than high watermark,
> so free memory on meminfo is moving around 512MB boundary consistently.
>
> To fix this problem, we should allocate the pages on cma reserved memory
> more aggressively and intelligenetly. Patch 2 implements the solution.
> Patch 1 is the simple optimization which remove useless re-trial and patch 3
> is for removing useless alloc flag, so these are not important.
> See patch 2 for more detailed description.
>
> This patchset is based on v3.15-rc4.

Thanks for posting those patches. It basically reminds me the following 
discussion:
http://thread.gmane.org/gmane.linux.kernel/1391989/focus=1399524

Your approach is basically the same. I hope that your patches can be 
improved
in such a way that they will be accepted by mm maintainers. I only 
wonder if the
third patch is really necessary. Without it kswapd wakeup might be still 
avoided
in some cases.

> Thanks.
> Joonsoo Kim (3):
>    CMA: remove redundant retrying code in __alloc_contig_migrate_range
>    CMA: aggressively allocate the pages on cma reserved memory when not
>      used
>    CMA: always treat free cma pages as non-free on watermark checking
>
>   include/linux/mmzone.h |    6 +++
>   mm/compaction.c        |    4 --
>   mm/internal.h          |    3 +-
>   mm/page_alloc.c        |  117 +++++++++++++++++++++++++++++++++++++++---------
>   4 files changed, 102 insertions(+), 28 deletions(-)
>

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
