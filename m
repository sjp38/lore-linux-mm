Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 499666B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 04:55:58 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id ey11so3009136pad.41
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 01:55:58 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id p6si18407973pdj.32.2014.10.16.01.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 01:55:57 -0700 (PDT)
Message-ID: <543F8812.2020002@codeaurora.org>
Date: Thu, 16 Oct 2014 01:55:46 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] (CMA_AGGRESSIVE) Make CMA memory be more aggressive
 about allocation
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>, rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, minchan@kernel.org, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, vbabka@suse.cz, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com
Cc: linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 10/15/2014 8:35 PM, Hui Zhu wrote:
> In fallbacks of page_alloc.c, MIGRATE_CMA is the fallback of
> MIGRATE_MOVABLE.
> MIGRATE_MOVABLE will use MIGRATE_CMA when it doesn't have a page in
> order that Linux kernel want.
>
> If a system that has a lot of user space program is running, for
> instance, an Android board, most of memory is in MIGRATE_MOVABLE and
> allocated.  Before function __rmqueue_fallback get memory from
> MIGRATE_CMA, the oom_killer will kill a task to release memory when
> kernel want get MIGRATE_UNMOVABLE memory because fallbacks of
> MIGRATE_UNMOVABLE are MIGRATE_RECLAIMABLE and MIGRATE_MOVABLE.
> This status is odd.  The MIGRATE_CMA has a lot free memory but Linux
> kernel kill some tasks to release memory.
>
> This patch series adds a new function CMA_AGGRESSIVE to make CMA memory
> be more aggressive about allocation.
> If function CMA_AGGRESSIVE is available, when Linux kernel call function
> __rmqueue try to get pages from MIGRATE_MOVABLE and conditions allow,
> MIGRATE_CMA will be allocated as MIGRATE_MOVABLE first.  If MIGRATE_CMA
> doesn't have enough pages for allocation, go back to allocate memory from
> MIGRATE_MOVABLE.
> Then the memory of MIGRATE_MOVABLE can be kept for MIGRATE_UNMOVABLE and
> MIGRATE_RECLAIMABLE which doesn't have fallback MIGRATE_CMA.
>

It's good to see another proposal to fix CMA utilization. Do you have
any data about the success rate of CMA contiguous allocation after
this patch series? I played around with a similar approach of using
CMA for MIGRATE_MOVABLE allocations and found that although utilization
did increase, contiguous allocations failed at a higher rate and were
much slower. I see what this series is trying to do with avoiding
allocation from CMA pages when a contiguous allocation is progress.
My concern is that there would still be problems with contiguous
allocation after all the MIGRATE_MOVABLE fallback has happened.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
