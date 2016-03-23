Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f170.google.com (mail-yw0-f170.google.com [209.85.161.170])
	by kanga.kvack.org (Postfix) with ESMTP id EB3776B025E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:42:38 -0400 (EDT)
Received: by mail-yw0-f170.google.com with SMTP id g3so14851333ywa.3
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:42:38 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id ga4si3820783igd.34.2016.03.23.04.42.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 04:42:38 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: prevent merging between isolated and other
 pageblocks
References: <1458726023-27005-1-git-send-email-vbabka@suse.cz>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56F2803E.70100@huawei.com>
Date: Wed, 23 Mar 2016 19:38:38 +0800
MIME-Version: 1.0
In-Reply-To: <1458726023-27005-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leizhen <thunder.leizhen@huawei.com>, Sasha Levin <sasha.levin@oracle.com>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, Lucas Stach <l.stach@pengutronix.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Laura Abbott <labbott@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal
 Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, stable@vger.kernel.org, Yasuaki
 Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 2016/3/23 17:40, Vlastimil Babka wrote:
> Hanjun Guo has reported that a CMA stress test causes broken accounting of
> CMA and free pages:
>
>> Before the test, I got:
>> -bash-4.3# cat /proc/meminfo | grep Cma
>> CmaTotal:         204800 kB
>> CmaFree:          195044 kB
>>
>>
>> After running the test:
>> -bash-4.3# cat /proc/meminfo | grep Cma
>> CmaTotal:         204800 kB
>> CmaFree:         6602584 kB
>>
>> So the freed CMA memory is more than total..
>>
>> Also the the MemFree is more than mem total:
>>
>> -bash-4.3# cat /proc/meminfo
>> MemTotal:       16342016 kB
>> MemFree:        22367268 kB
>> MemAvailable:   22370528 kB
> Laura Abbott has confirmed the issue and suspected the freepage accounting
> rewrite around 3.18/4.0 by Joonsoo Kim. Joonsoo had a theory that this is
> caused by unexpected merging between MIGRATE_ISOLATE and MIGRATE_CMA
> pageblocks:
>
>> CMA isolates MAX_ORDER aligned blocks, but, during the process,
>> partialy isolated block exists. If MAX_ORDER is 11 and
>> pageblock_order is 9, two pageblocks make up MAX_ORDER
>> aligned block and I can think following scenario because pageblock
>> (un)isolation would be done one by one.
>>
>> (each character means one pageblock. 'C', 'I' means MIGRATE_CMA,
>> MIGRATE_ISOLATE, respectively.
>>
>> CC -> IC -> II (Isolation)
>> II -> CI -> CC (Un-isolation)
>>
>> If some pages are freed at this intermediate state such as IC or CI,
>> that page could be merged to the other page that is resident on
>> different type of pageblock and it will cause wrong freepage count.
> This was supposed to be prevented by CMA operating on MAX_ORDER blocks, but
> since it doesn't hold the zone->lock between pageblocks, a race window does
> exist.
>
> It's also likely that unexpected merging can occur between MIGRATE_ISOLATE
> and non-CMA pageblocks. This should be prevented in __free_one_page() since
> commit 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated
> pageblock"). However, we only check the migratetype of the pageblock where
> buddy merging has been initiated, not the migratetype of the buddy pageblock
> (or group of pageblocks) which can be MIGRATE_ISOLATE.
>
> Joonsoo has suggested checking for buddy migratetype as part of
> page_is_buddy(), but that would add extra checks in allocator hotpath and
> bloat-o-meter has shown significant code bloat (the function is inline).
>
> This patch reduces the bloat at some expense of more complicated code. The
> buddy-merging while-loop in __free_one_page() is initially bounded to
> pageblock_border and without any migratetype checks. The checks are placed
> outside, bumping the max_order if merging is allowed, and returning to the
> while-loop with a statement which can't be possibly considered harmful.
>
> This fixes the accounting bug and also removes the arguably weird state in the
> original commit 3c605096d315 where buddies could be left unmerged.
>
> Fixes: 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated pageblock")
> Link: https://lkml.org/lkml/2016/3/2/280
> Reported-by: Hanjun Guo <guohanjun@huawei.com>

With the same stress test case (alloc/free cma) running for more than
one hour, the bug I reported is gone.

Tested-by: Hanjun Guo <guohanjun@huawei.com>

Thanks for debugging!
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
