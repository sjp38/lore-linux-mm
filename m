Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 74E95900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 10:43:44 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id n15so2587809lbi.31
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 07:43:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g7si7513868lab.66.2014.10.29.07.43.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 07:43:41 -0700 (PDT)
Message-ID: <5450FD15.4000708@suse.cz>
Date: Wed, 29 Oct 2014 15:43:33 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] (CMA_AGGRESSIVE) Make CMA memory be more aggressive
 about allocation
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com> <543F8812.2020002@codeaurora.org>
In-Reply-To: <543F8812.2020002@codeaurora.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, minchan@kernel.org, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com
Cc: linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 10/16/2014 10:55 AM, Laura Abbott wrote:
> On 10/15/2014 8:35 PM, Hui Zhu wrote:
>
> It's good to see another proposal to fix CMA utilization. Do you have
> any data about the success rate of CMA contiguous allocation after
> this patch series? I played around with a similar approach of using
> CMA for MIGRATE_MOVABLE allocations and found that although utilization
> did increase, contiguous allocations failed at a higher rate and were
> much slower. I see what this series is trying to do with avoiding
> allocation from CMA pages when a contiguous allocation is progress.
> My concern is that there would still be problems with contiguous
> allocation after all the MIGRATE_MOVABLE fallback has happened.

Hi,

did anyone try/suggest the following idea?

- keep CMA as fallback to MOVABLE as is is now, i.e. non-agressive
- when UNMOVABLE (RECLAIMABLE also?) allocation fails and CMA pageblocks 
have space, don't OOM immediately, but first try to migrate some MOVABLE 
pages to CMA pageblocks, to make space for the UNMOVABLE allocation in 
non-CMA pageblocks
- this should keep CMA pageblocks free as long as possible and useful 
for CMA allocations, but without restricting the non-MOVABLE allocations 
even though there is free memory (but in CMA pageblocks)
- the fact that a MOVABLE page could be successfully migrated to CMA 
pageblock, means it was not pinned or otherwise non-migratable, so 
there's a good chance it can be migrated back again if CMA pageblocks 
need to be used by CMA allocation
- it's more complex, but I guess we have most of the necessary 
infrastructure in compaction already :)

Thoughts?
Vlastimil

> Thanks,
> Laura
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
