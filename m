Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4416B0095
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 04:30:07 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id f15so12127625lbj.9
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 01:30:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si36573621lat.82.2014.11.04.01.30.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 01:30:05 -0800 (PST)
Message-ID: <54589C97.4060309@suse.cz>
Date: Tue, 04 Nov 2014 10:29:59 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] (CMA_AGGRESSIVE) Make CMA memory be more aggressive
 about allocation
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com> <543F8812.2020002@codeaurora.org> <5450FD15.4000708@suse.cz> <20141104075330.GB23102@bbox>
In-Reply-To: <20141104075330.GB23102@bbox>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 11/04/2014 08:53 AM, Minchan Kim wrote:
> Hello,
>
> On Wed, Oct 29, 2014 at 03:43:33PM +0100, Vlastimil Babka wrote:
>> On 10/16/2014 10:55 AM, Laura Abbott wrote:
>>
>> Hi,
>>
>> did anyone try/suggest the following idea?
>>
>> - keep CMA as fallback to MOVABLE as is is now, i.e. non-agressive
>> - when UNMOVABLE (RECLAIMABLE also?) allocation fails and CMA
>> pageblocks have space, don't OOM immediately, but first try to
>> migrate some MOVABLE pages to CMA pageblocks, to make space for the
>> UNMOVABLE allocation in non-CMA pageblocks
>> - this should keep CMA pageblocks free as long as possible and
>> useful for CMA allocations, but without restricting the non-MOVABLE
>> allocations even though there is free memory (but in CMA pageblocks)
>> - the fact that a MOVABLE page could be successfully migrated to CMA
>> pageblock, means it was not pinned or otherwise non-migratable, so
>> there's a good chance it can be migrated back again if CMA
>> pageblocks need to be used by CMA allocation
>
> I suggested exactly same idea long time ago.
>
>> - it's more complex, but I guess we have most of the necessary
>> infrastructure in compaction already :)
>
> I agree but still, it doesn't solve reclaim problem(ie, VM doesn't
> need to reclaim CMA pages when memory pressure of unmovable pages
> happens). Of course, we could make VM be aware of that via introducing
> new flag of __isolate_lru_page.

Well, if it relaims CMA pages, then it has to be followed by the 
migration. Is that better or worse than breaking LRU assumptions by 
reclaiming based on where the page is located? I thought this was 
basically what lumpy reclaim did, and it was removed.

> However, I'd like to think CMA design from the beginning.
> It made page allocation logic complicated, even very fragile as we
> had recently and now we need to add new logics to migrate like you said.
> As well, we need to fix reclaim path, too.
>
> It makes mm complicated day by day even though it doesn't do the role
> enough well(ie, big latency and frequent allocation failure) so I really
> want to stop making the mess bloated.

Yeah that would be great.

> Long time ago, when I saw Joonsoo's CMA agressive allocation patchset
> (ie, roundrobin allocation between CMA and normal movable pages)
> it was good to me at a first glance but it needs tweak of allocation
> path and doesn't solve reclaim path, either. Yes, reclaim path could
> be solved by another patch but I want to solve it altogether.
>
> At that time, I suggested big surgery to Joonsoo in offline that
> let's move CMA allocation with movable zone allocation. With it,
> we could make allocation/reclaim path simple but thing is we should

I'm not sure I understand enough from this. You want to introduce a 
movable zone instead of CMA pageblocks? But how to size it, resize it, 
would it be possible?

> make VM be aware of overlapping MOVABLE zone which means some of pages
> in the zone could be part of another zones but I think we already have
> logics to handle it when I read comment in isolate_freepages so I think
> the design should work.

Why would it overlap in the first place? Just because it wouldn't be 
sized on pageblock boundary? Or to make (re)sizing simpler? Yeah we 
could probably handle that, but it's not completely for free (you 
iterate over blocks/pages uselessly).

> A thing you guys might worry is bigger CMA latency because it makes
> CMA memory usage ratio higher than the approach you mentioned but
> anyone couldn't guarantee it once memory is fully utilized.
> In addition, we have used fair zone allocator policy so it makes
> round robin allocation automatically so I believe it should be way
> to go.

Yeah maybe it could be simpler in the end. Although a new zone type 
could be a disturbing change, with some overhead to per-cpu structures 
etc. The allocations in that zone would be somewhat at disadvantage wrt 
LRU, as CMA allocation would mostly reclaim them instead of migrating 
away (assuming there wouldn't be so much spare space for migration as 
when CMA pageblocks are part of a much larger zone). But I guess the 
same could be said about the DMA zone...

>>
>> Thoughts?
>> Vlastimil
>>
>>> Thanks,
>>> Laura
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
