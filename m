Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 34A316B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 00:42:35 -0400 (EDT)
Received: by mail-io0-f182.google.com with SMTP id c63so16144030iof.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 21:42:35 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 64si1533028ioz.0.2016.03.22.21.42.33
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 21:42:34 -0700 (PDT)
Date: Wed, 23 Mar 2016 13:44:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Suspicious error for CMA stress test
Message-ID: <20160323044407.GB4624@js1304-P5Q-DELUXE>
References: <56E2FB5C.1040602@suse.cz>
 <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz>
 <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com>
 <20160317065426.GA10315@js1304-P5Q-DELUXE>
 <56EA77BC.2090702@huawei.com>
 <56EAD0B4.2060807@suse.cz>
 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
 <56EC0C41.70503@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56EC0C41.70503@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hanjun Guo <guohanjun@huawei.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lucas Stach <l.stach@pengutronix.de>

On Fri, Mar 18, 2016 at 03:10:09PM +0100, Vlastimil Babka wrote:
> On 03/17/2016 04:52 PM, Joonsoo Kim wrote:
> > 2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> >>>>>>
> >>>>>> Okay. I used following slightly optimized version and I need to
> >>>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
> >>>>>> to yours. Please consider it, too.
> >>>>>
> >>>>> Hmm, this one is not work, I still can see the bug is there after
> >>>>> applying
> >>>>> this patch, did I miss something?
> >>>>
> >>>> I may find that there is a bug which was introduced by me some time
> >>>> ago. Could you test following change in __free_one_page() on top of
> >>>> Vlastimil's patch?
> >>>>
> >>>> -page_idx = pfn & ((1 << max_order) - 1);
> >>>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
> >>>
> >>>
> >>> I tested Vlastimil's patch + your change with stress for more than half
> >>> hour, the bug
> >>> I reported is gone :)
> >>
> >>
> >> Oh, ok, will try to send proper patch, once I figure out what to write in
> >> the changelog :)
> > 
> > Thanks in advance!
> > 
> 
> OK, here it is. Hanjun can you please retest this, as I'm not sure if you had
> the same code due to the followup one-liner patches in the thread. Lucas, see if
> it helps with your issue as well. Laura and Joonsoo, please also test and review
> and check changelog if my perception of the problem is accurate :)
> 
> Thanks
> 
> ----8<----
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 18 Mar 2016 14:22:31 +0100
> Subject: [PATCH] mm/page_alloc: prevent merging between isolated and other
>  pageblocks
> 
> Hanjun Guo has reported that a CMA stress test causes broken accounting of
> CMA and free pages:
> 
> > Before the test, I got:
> > -bash-4.3# cat /proc/meminfo | grep Cma
> > CmaTotal:         204800 kB
> > CmaFree:          195044 kB
> >
> >
> > After running the test:
> > -bash-4.3# cat /proc/meminfo | grep Cma
> > CmaTotal:         204800 kB
> > CmaFree:         6602584 kB
> >
> > So the freed CMA memory is more than total..
> >
> > Also the the MemFree is more than mem total:
> >
> > -bash-4.3# cat /proc/meminfo
> > MemTotal:       16342016 kB
> > MemFree:        22367268 kB
> > MemAvailable:   22370528 kB
> 
> Laura Abbott has confirmed the issue and suspected the freepage accounting
> rewrite around 3.18/4.0 by Joonsoo Kim. Joonsoo had a theory that this is
> caused by unexpected merging between MIGRATE_ISOLATE and MIGRATE_CMA
> pageblocks:
> 
> > CMA isolates MAX_ORDER aligned blocks, but, during the process,
> > partialy isolated block exists. If MAX_ORDER is 11 and
> > pageblock_order is 9, two pageblocks make up MAX_ORDER
> > aligned block and I can think following scenario because pageblock
> > (un)isolation would be done one by one.
> >
> > (each character means one pageblock. 'C', 'I' means MIGRATE_CMA,
> > MIGRATE_ISOLATE, respectively.
> >
> > CC -> IC -> II (Isolation)
> > II -> CI -> CC (Un-isolation)
> >
> > If some pages are freed at this intermediate state such as IC or CI,
> > that page could be merged to the other page that is resident on
> > different type of pageblock and it will cause wrong freepage count.
> 
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
> Debugged-by: Laura Abbott <labbott@redhat.com>
> Debugged-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: <stable@vger.kernel.org> # 3.18+
> ---
>  mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++-------------
>  1 file changed, 33 insertions(+), 13 deletions(-)

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks for taking care of this issue!.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
