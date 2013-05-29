Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id A84066B0114
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:09:13 -0400 (EDT)
Message-ID: <51A60BE5.7010905@synopsys.com>
Date: Wed, 29 May 2013 19:38:37 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix the TLB range flushed when __tlb_remove_page()
 runs out of slots
References: <1369832173-15088-1-git-send-email-vgupta@synopsys.com> <20130529140319.GK17767@MacBook-Pro.local>
In-Reply-To: <20130529140319.GK17767@MacBook-Pro.local>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Max Filippov <jcmvbkbc@gmail.com>

On 05/29/2013 07:33 PM, Catalin Marinas wrote:
> On Wed, May 29, 2013 at 01:56:13PM +0100, Vineet Gupta wrote:
>> zap_pte_range loops from @addr to @end. In the middle, if it runs out of
>> batching slots, TLB entries needs to be flushed for @start to @interim,
>> NOT @interim to @end.
>>
>> Since ARC port doesn't use page free batching I can't test it myself but
>> this seems like the right thing to do.
>> Observed this when working on a fix for the issue at thread:
>> 	http://www.spinics.net/lists/linux-arch/msg21736.html
>>
>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: linux-mm@kvack.org
>> Cc: linux-arch@vger.kernel.org <linux-arch@vger.kernel.org>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Max Filippov <jcmvbkbc@gmail.com>
>> ---
>>  mm/memory.c |    9 ++++++---
>>  1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 6dc1882..d9d5fd9 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1110,6 +1110,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>>  	spinlock_t *ptl;
>>  	pte_t *start_pte;
>>  	pte_t *pte;
>> +	unsigned long range_start = addr;
>>  
>>  again:
>>  	init_rss_vec(rss);
>> @@ -1215,12 +1216,14 @@ again:
>>  		force_flush = 0;
>>  
>>  #ifdef HAVE_GENERIC_MMU_GATHER
>> -		tlb->start = addr;
>> -		tlb->end = end;
>> +		tlb->start = range_start;
>> +		tlb->end = addr;
>>  #endif
>>  		tlb_flush_mmu(tlb);
>> -		if (addr != end)
>> +		if (addr != end) {
>> +			range_start = addr;
>>  			goto again;
>> +		}
>>  	}
> Isn't this code only run if force_flush != 0? force_flush is set to
> !__tlb_remove_page() and this function always returns 1 on (generic TLB)
> UP since tlb_fast_mode() is 1. There is no batching on UP with the
> generic TLB code.

Correct ! That's why the changelog says I couldn't test it on ARC port itself :-)

However based on the other discussion (Max's TLB/PTE inconsistency), as I started
writing code to reuse this block to flush the TLB even for non forced case, I
realized that what this is doing is incorrect and won't work for the general flushing.

Ignoring all other threads, do we agree that the exiting code - if used in any
situations is incorrect semantically ?

-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
