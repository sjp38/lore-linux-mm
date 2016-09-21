Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7476B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 05:11:25 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y6so5079554lff.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 02:11:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l199si25896275wmg.142.2016.09.21.02.11.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 02:11:23 -0700 (PDT)
Subject: Re: [PATCH v5 2/6] mm/cma: introduce new zone, ZONE_CMA
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1472447255-10584-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9cc6cb83-c198-7977-772b-bd7bf173fbb0@suse.cz>
Date: Wed, 21 Sep 2016 11:11:22 +0200
MIME-Version: 1.0
In-Reply-To: <1472447255-10584-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/29/2016 07:07 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Attached cover-letter:
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
>
> 2) Reclaim problem
> Currently, there is no logic to distinguish CMA pages in reclaim path.
> If reclaim is initiated for unmovable and reclaimable allocation,
> reclaiming CMA pages doesn't help to satisfy the request and reclaiming
> CMA page is just waste. By managing CMA pages in the new zone, we can
> skip to reclaim ZONE_CMA completely if it is unnecessary.
>
> 3) Atomic allocation failure problem
> Kswapd isn't started to reclaim pages when allocation request is movable
> type and there is enough free page in the CMA region. After bunch of
> consecutive movable allocation requests, free pages in ordinary region
> (not CMA region) would be exhausted without waking up kswapd. At that time,
> if atomic unmovable allocation comes, it can't be successful since there
> is not enough page in ordinary region. This problem is reported
> by Aneesh [4] and can be solved by this patchset.
>
> 4) Inefficiently work of compaction
> Usual high-order allocation request is unmovable type and it cannot
> be serviced from CMA area. In compaction, migration scanner doesn't
> distinguish migratable pages on the CMA area and do migration.
> In this case, even if we make high-order page on that region, it
> cannot be used due to type mismatch. This patch will solve this problem
> by separating CMA pages from ordinary zones.
>
> [1] https://lkml.org/lkml/2014/5/28/64
> [2] https://lkml.org/lkml/2014/11/4/55
> [3] https://lkml.org/lkml/2014/10/15/623
> [4] http://www.spinics.net/lists/linux-mm/msg100562.html
> [5] https://lkml.org/lkml/2014/5/30/320
>
> For this patch:
>
> Currently, reserved pages for CMA are managed together with normal pages.
> To distinguish them, we used migratetype, MIGRATE_CMA, and
> do special handlings for this migratetype. But, it turns out that
> there are too many problems with this approach and to fix all of them
> needs many more hooks to page allocation and reclaim path so
> some developers express their discomfort and problems on CMA aren't fixed
> for a long time.
>
> To terminate this situation and fix CMA problems, this patch implements
> ZONE_CMA. Reserved pages for CMA will be managed in this new zone. This
> approach will remove all exisiting hooks for MIGRATE_CMA and many
> problems related to CMA implementation will be solved.
>
> This patch only add basic infrastructure of ZONE_CMA. In the following
> patch, ZONE_CMA is actually populated and used.
>
> Adding a new zone could cause two possible problems. One is the overflow
> of page flags and the other is GFP_ZONES_TABLE issue.
>
> Following is page-flags layout described in page-flags-layout.h.
>
> 1. No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |             ... | FLAGS |
> 2.      " plus space for last_cpupid: |       NODE     | ZONE | LAST_CPUPID ... | FLAGS |
> 3. classic sparse with space for node:| SECTION | NODE | ZONE |             ... | FLAGS |
> 4.      " plus space for last_cpupid: | SECTION | NODE | ZONE | LAST_CPUPID ... | FLAGS |
> 5. classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
>
> There is no problem in #1, #2 configurations for 64-bit system. There are
> enough room even for extremiely large x86_64 system. 32-bit system would
> not have many nodes so it would have no problem, too.
> System with #3, #4, #5 configurations could be affected by this zone
> addition, but, thanks to recent THP rework which reduce one page flag,
> problem surface would be small. In some configurations, problem is
> still possible, but, it highly depends on individual configuration
> so impact cannot be easily estimated. I guess that usual system
> with CONFIG_CMA would not be affected. If there is a problem,
> we can adjust section width or node width for that architecture.
>
> Currently, GFP_ZONES_TABLE is 32-bit value for 32-bit bit operation
> in the 32-bit system. If we add one more zone, it will be 48-bit and
> 32-bit bit operation cannot be possible. Although it will cause slight
> overhead, there is no other way so this patch relax GFP_ZONES_TABLE's
> 32-bit limitation. 32-bit System with CONFIG_CMA will be affected by
> this change but it would be marginal.
>
> Note that there are many checkpatch warnings but I think that current
> code is better for readability than fixing them up.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

The special hooks in all the initialization/hotplug functions are tricky 
and I wouldn't be surprised if we find some subtle bugs. But better than 
the current hooks in the alloc fastpaths...

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
