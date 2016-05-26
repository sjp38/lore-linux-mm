Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBC36B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 04:03:42 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so99568359pad.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 01:03:42 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ab1si5512012pad.101.2016.05.26.01.03.40
        for <linux-mm@kvack.org>;
        Thu, 26 May 2016 01:03:40 -0700 (PDT)
Date: Thu, 26 May 2016 16:04:54 +0800
From: Feng Tang <feng.tang@intel.com>
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
Message-ID: <20160526080454.GA11823@shbuild888>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "js1304@gmail.com" <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, May 26, 2016 at 02:22:22PM +0800, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi Joonsoo,

Nice work!

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
> To fix this problem, I submitted some patches [1] about 10 months ago,
> but, found some more problems to be fixed before solving this problem.
> It requires many hooks in allocator hotpath so some developers doesn't
> like it. Instead, some of them suggest different approach [2] to fix
> all the problems related to CMA, that is, introducing a new zone to deal
> with free CMA pages. I agree that it is the best way to go so implement
> here. Although properties of ZONE_MOVABLE and ZONE_CMA is similar, I
> decide to add a new zone rather than piggyback on ZONE_MOVABLE since
> they have some differences. First, reserved CMA pages should not be
> offlined. If freepage for CMA is managed by ZONE_MOVABLE, we need to keep
> MIGRATE_CMA migratetype and insert many hooks on memory hotplug code
> to distiguish hotpluggable memory and reserved memory for CMA in the same
> zone. It would make memory hotplug code which is already complicated
> more complicated. Second, cma_alloc() can be called more frequently
> than memory hotplug operation and possibly we need to control
> allocation rate of ZONE_CMA to optimize latency in the future.
> In this case, separate zone approach is easy to modify. Third, I'd
> like to see statistics for CMA, separately. Sometimes, we need to debug
> why cma_alloc() is failed and separate statistics would be more helpful
> in this situtaion.
> 
> Anyway, this patchset solves four problems related to CMA implementation.
> 
> 1) Utilization problem
> As mentioned above, we can't utilize full memory capacity due to the
> limitation of CMA freepage and fallback policy. This patchset implements
> a new zone for CMA and uses it for GFP_HIGHUSER_MOVABLE request. This
> typed allocation is used for page cache and anonymous pages which
> occupies most of memory usage in normal case so we can utilize full
> memory capacity. Below is the experiment result about this problem.
> 
> 8 CPUs, 1024 MB, VIRTUAL MACHINE
> make -j16
> 
> <Before this series>
> CMA reserve:            0 MB            512 MB
> Elapsed-time:           92.4		186.5
> pswpin:                 82		18647
> pswpout:                160		69839
> 
> <After this series>
> CMA reserve:            0 MB            512 MB
> Elapsed-time:           93.1		93.4
> pswpin:                 84		46
> pswpout:                183		92
> 
> FYI, there is another attempt [3] trying to solve this problem in lkml.
> And, as far as I know, Qualcomm also has out-of-tree solution for this
> problem.

This may be a little off-topic :) Actually, we have used another way in
our products, that we disable the fallback from MIGRATETYE_MOVABLE to
MIGRATETYPE_CMA completely, and only allow free CMA memory to be used
by file page cache (which is easy to be reclaimed by its nature). 
We did it by adding a GFP_PAGE_CACHE to every allocation request for
page cache, and the MM will try to pick up an available free CMA page
first, and goes to normal path when fail. 

It works fine on our products, though we still see some cases that
some page can't be reclaimed. 

Our product has a special user case of CMA, that sometimes it will
need to use the whole CMA memory (say 256MB on a phone), then all
share out CMA pages need to be reclaimed all at once. Don't know if
this new ZONE_CMA approach could meet this request? (our page cache
solution can't ganrantee to meet this request all the time).

Thanks,
Feng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
