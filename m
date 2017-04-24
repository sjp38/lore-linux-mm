Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAFD26B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 00:09:28 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id v34so208973387iov.22
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 21:09:28 -0700 (PDT)
Received: from dggrg01-dlp.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id r138si17501090pfr.150.2017.04.23.21.09.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 23 Apr 2017 21:09:28 -0700 (PDT)
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <a99e21de-7234-ec46-eda7-e25757bfb993@huawei.com>
Date: Mon, 24 Apr 2017 12:08:03 +0800
MIME-Version: 1.0
In-Reply-To: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2017/4/11 11:17, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Changed from v6
> o Rebase on next-20170405
> o Add a fix for lowmem mapping on ARM (last patch)
> o Re-organize the cover letter
> 
> Changes from v5
> o Rebase on next-20161013
> o Cosmetic change on patch 1
> o Optimize span of ZONE_CMA on multiple node system
> 
> Changes from v4
> o Rebase on next-20160825
> o Add general fix patch for lowmem reserve
> o Fix lowmem reserve ratio
> o Fix zone span optimizaion per Vlastimil
> o Fix pageset initialization
> o Change invocation timing on cma_init_reserved_areas()
> 
> Changes from v3
> o Rebase on next-20160805
> o Split first patch per Vlastimil
> o Remove useless function parameter per Vlastimil
> o Add code comment per Vlastimil
> o Add following description on cover-letter
> 
> Changes from v2
> o Rebase on next-20160525
> o No other changes except following description
> 
> Changes from v1
> o Separate some patches which deserve to submit independently
> o Modify description to reflect current kernel state
> (e.g. high-order watermark problem disappeared by Mel's work)
> o Don't increase SECTION_SIZE_BITS to make a room in page flags
> (detailed reason is on the patch that adds ZONE_CMA)
> o Adjust ZONE_CMA population code
> 
> 
> Hello,
> 
> This is the 7th version of ZONE_CMA patchset. One patch is added
> to fix potential problem on ARM. Other changes are just due to rebase.
> 
> This patchset has long history and got some reviews before. This
> cover-letter has the summary and my opinion on those reviews. Content
> order is so confusing so I make a simple index. If anyone want to
> understand the history properly, please read them by reverse order.
> 
> PART 1. Strong points of the zone approach
> PART 2. Summary in LSF/MM 2016 discussion
> PART 3. Original motivation of this patchset
> 
> ***** PART 1 *****
> 
> CMA has many problems and I mentioned them on the bottom of the
> cover letter. These problems comes from limitation of CMA memory that
> should be always migratable for device usage. I think that introducing
> a new zone is the best approach to solve them. Here are the reasons.
> 
> Zone is introduced to solve some issues due to H/W addressing limitation.
> MM subsystem is implemented to work efficiently with these zones.
> Allocation/reclaim logic in MM consider this limitation very much.
> What I did in this patchset is introducing a new zone and extending zone's
> concept slightly. New concept is that zone can have not only H/W addressing
> limitation but also S/W limitation to guarantee page migration.
> This concept is originated from ZONE_MOVABLE and it works well
> for a long time. So, ZONE_CMA should not be special at this moment.
> 
> There is a major concern from Mel that ZONE_MOVABLE which has
> S/W limitation causes highmem/lowmem problem. Highmem/lowmem problem is
> that some of memory cannot be usable for kernel memory due to limitation
> of the zone. It causes to break LRU ordering and makes hard to find kernel
> usable memory when memory pressure.
> 
> However, important point is that this problem doesn't come from
> implementation detail (ZONE_MOVABLE/MIGRATETYPE). Even if we implement it
> by MIGRATETYPE instead of by ZONE_MOVABLE, we cannot use that type of
> memory for kernel allocation because it isn't migratable. So, it will cause
> to break LRU ordering, too. We cannot avoid the problem in any case.
> Therefore, we should focus on which solution is better for maintenance
> and not intrusive for MM subsystem.
> 
> In this viewpoint, I think that zone approach is better. As mentioned
> earlier, MM subsystem already have many infrastructures to deal with
> zone's H/W addressing limitation. Adding S/W limitation on zone concept
> and adding a new zone doesn't change anything. It will work by itself.
> My patchset can remove many hooks related to CMA area management in MM
> while solving the problems. More hooks are required to solve the problems
> if we choose MIGRATETYPE approach.
> 

Agree, there are already too many hooks and pain to maintain/bugfix.
It looks better if choose this ZONE_CMA approach.

--
Regards,
Bob Liu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
