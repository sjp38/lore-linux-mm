Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0FB66B007E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 11:34:34 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w143so275976206oiw.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 08:34:34 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id 101si39218877iok.146.2016.05.30.08.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 08:34:34 -0700 (PDT)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 May 2016 09:34:32 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/4] mm: Change the interface for __tlb_remove_page
In-Reply-To: <001901d1ba4a$514eccc0$f3ec6640$@alibaba-inc.com>
References: <001701d1ba44$b9c0d560$2d428020$@alibaba-inc.com> <001901d1ba4a$514eccc0$f3ec6640$@alibaba-inc.com>
Date: Mon, 30 May 2016 21:04:27 +0530
Message-ID: <87mvn71rwc.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hillf Danton <hillf.zj@alibaba-inc.com> writes:

>> diff --git a/mm/memory.c b/mm/memory.c
>> index 15322b73636b..a01db5bc756b 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -292,23 +292,24 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
>>   *	handling the additional races in SMP caused by other CPUs caching valid
>>   *	mappings in their TLBs. Returns the number of free page slots left.
>>   *	When out of page slots we must call tlb_flush_mmu().
>> + *returns true if the caller should flush.
>>   */
>> -int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>> +bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>>  {
>>  	struct mmu_gather_batch *batch;
>> 
>>  	VM_BUG_ON(!tlb->end);
>> 
>>  	batch = tlb->active;
>> -	batch->pages[batch->nr++] = page;
>>  	if (batch->nr == batch->max) {
>>  		if (!tlb_next_batch(tlb))
>> -			return 0;
>> +			return true;
>>  		batch = tlb->active;
>>  	}
>>  	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
>
> Still needed?

yes, we need to make sure the batch we picked doesn't have a wrong
batch->nr value.

>> 
>> -	return batch->max - batch->nr;
>> +	batch->pages[batch->nr++] = page;
>> +	return false;
>>  }
>> 
>>  #endif /* HAVE_GENERIC_MMU_GATHER */
>> @@ -1109,6 +1110,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>>  	pte_t *start_pte;
>>  	pte_t *pte;
>>  	swp_entry_t entry;
>> +	struct page *pending_page = NULL;
>> 
>>  again:
>>  	init_rss_vec(rss);
>> @@ -1160,8 +1162,9 @@ again:
>>  			page_remove_rmap(page, false);
>>  			if (unlikely(page_mapcount(page) < 0))
>>  				print_bad_pte(vma, addr, ptent, page);
>> -			if (unlikely(!__tlb_remove_page(tlb, page))) {
>> +			if (unlikely(__tlb_remove_page(tlb, page))) {
>>  				force_flush = 1;
>> +				pending_page = page;
>>  				addr += PAGE_SIZE;
>>  				break;
>>  			}
>> @@ -1202,7 +1205,12 @@ again:
>>  	if (force_flush) {
>>  		force_flush = 0;
>>  		tlb_flush_mmu_free(tlb);
>> -
>> +		if (pending_page) {
>> +			/* remove the page with new size */
>> +			__tlb_adjust_range(tlb, tlb->addr);
>
> Would you please specify why tlb->addr is used here?
>

That is needed because tlb_flush_mmu_tlbonly() does a __tlb_reset_range().


>> +			__tlb_remove_page(tlb, pending_page);
>> +			pending_page = NULL;
>> +		}
>>  		if (addr != end)
>>  			goto again;
>>  	}
>> --
>> 2.7.4

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
