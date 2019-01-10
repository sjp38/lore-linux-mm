Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48F358E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 08:52:36 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so4460501ede.14
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:52:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c4si1509248edq.6.2019.01.10.05.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 05:52:34 -0800 (PST)
Subject: Re: [RFC 1/3] mm, thp: restore __GFP_NORETRY for madvised thp fault
 allocations
References: <20181211142941.20500-1-vbabka@suse.cz>
 <20181211142941.20500-2-vbabka@suse.cz>
 <20190108111630.GN31517@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cba804dd-5a07-0a40-b5ae-86795dc860d4@suse.cz>
Date: Thu, 10 Jan 2019 14:52:32 +0100
MIME-Version: 1.0
In-Reply-To: <20190108111630.GN31517@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 1/8/19 12:16 PM, Mel Gorman wrote:
> On Tue, Dec 11, 2018 at 03:29:39PM +0100, Vlastimil Babka wrote:
>> Commit 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
>> madvised allocations") intended to make THP faults in MADV_HUGEPAGE areas more
>> successful for processes that indicate that they are willing to pay a higher
>> initial setup cost for long-term THP benefits. In the current page allocator
>> implementation this means that the allocations will try to use reclaim and the
>> more costly sync compaction mode, in case the initial direct async compaction
>> fails.
>>
> 
> First off, I'm going to have trouble reasoning about this because there
> is also my own series that reduces compaction failure rates. If that
> series get approved, then it's far more likely that when compaction
> fails that we really mean it and retries from the page allocator context
> may be pointless unless the caller indicates it should really retry for
> a long time.

Understood.

> The corner case I have in mind is a compaction failure on a very small
> percentage of remaining pageblocks that are currently under writeback.
> 
> It also means that the merit of this series needs to account for whether
> it's before or after the compaction series as the impact will be
> different. FWIW, I had the same problem with evaluating the compaction
> series on the context of __GFP_THISNODE vs !__GFP_THISNODE

Right. In that case I think for mainline, making compaction better has
priority over trying to compensate for it. The question is if somebody
wants to fix stable/older distro kernels. Now that it wasn't possible to
remove the __GFP_THISNODE for THP's, I thought this might be an
alternative acceptable to anyone, provided that it works. Backporting
your compaction series would be much more difficult I guess. Of course
distro kernels can also divert from mainline and go with the
__GFP_THISNODE removal privately.

>> However, THP faults also include __GFP_THISNODE, which, combined with direct
>> reclaim, can result in a node-reclaim-like local node thrashing behavior, as
>> reported by Andrea [1].
>>
>> While this patch is not a full fix, the first step is to restore __GFP_NORETRY
>> for madvised THP faults. The expected downside are potentially worse THP
>> fault success rates for the madvised areas, which will have to then rely more
>> on khugepaged. For khugepaged, __GFP_NORETRY is not restored, as its activity
>> should be limited enough by sleeping to cause noticeable thrashing.
>>
>> Note that alloc_new_node_page() and new_page() is probably another candidate as
>> they handle the migrate_pages(2), resp. mbind(2) syscall, which can thus allow
>> unprivileged node-reclaim-like behavior.
>>
>> The patch also updates the comments in alloc_hugepage_direct_gfpmask() because
>> elsewhere compaction during page fault is called direct compaction, and
>> 'synchronous' refers to the migration mode, which is not used for THP faults.
>>
>> [1] https://lkml.kernel.org/m/20180820032204.9591-1-aarcange@redhat.com
>>
>> Reported-by: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> ---
>>  mm/huge_memory.c | 13 ++++++-------
>>  1 file changed, 6 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 5da55b38b1b7..c442b12b060c 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -633,24 +633,23 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
>>  {
>>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
>>  
>> -	/* Always do synchronous compaction */
>> +	/* Always try direct compaction */
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
>> -		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
>> +		return GFP_TRANSHUGE | __GFP_NORETRY;
>>  
> 
> While I get that you want to reduce thrashing, the configuration item
> really indicates the system (not just the caller, but everyone) is willing
> to take a hit to get a THP.

Yeah some hit in exchange for THP's, but probably not an overreclaim due
to __GFP_THISNODE implications.

>>  	/* Kick kcompactd and fail quickly */
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
>>  		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
>>  
>> -	/* Synchronous compaction if madvised, otherwise kick kcompactd */
>> +	/* Direct compaction if madvised, otherwise kick kcompactd */
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
>>  		return GFP_TRANSHUGE_LIGHT |
>> -			(vma_madvised ? __GFP_DIRECT_RECLAIM :
>> +			(vma_madvised ? (__GFP_DIRECT_RECLAIM | __GFP_NORETRY):
>>  					__GFP_KSWAPD_RECLAIM);
>>  
> 
> Similar note.
> 
>> -	/* Only do synchronous compaction if madvised */
>> +	/* Only do direct compaction if madvised */
>>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
>> -		return GFP_TRANSHUGE_LIGHT |
>> -		       (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
>> +		return vma_madvised ? (GFP_TRANSHUGE | __GFP_NORETRY) : GFP_TRANSHUGE_LIGHT;
>>  
> 
> Similar note.
> 
> That said, if this series went in before the compaction series then I
> would think it's ok and I would Ack it. However, *after* the compaction
> series, I think it would make more sense to rip out or severely reduce the
> complex should_compact_retry logic and move towards "if compaction returns,
> the page allocator should take its word for it except in extreme cases".

OK.

> Compaction previously was a bit too casual about partially scanning
> backblocks and the setting/clearing of pageblock bits. The retry logic
> sortof dealt with it by making reset/clear cycles very frequent but
> after the series, they are relatively rare[1].
> 
> [1] Says he bravely before proven otherwise
> 
