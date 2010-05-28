Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 29AFC6B01BD
	for <linux-mm@kvack.org>; Fri, 28 May 2010 12:40:43 -0400 (EDT)
Message-ID: <4BFFF1DF.3020501@cray.com>
Date: Fri, 28 May 2010 09:39:59 -0700
From: Doug Doan <dougd@cray.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb: call mmu notifiers on hugepage cow
References: <4BFED954.8060807@cray.com> <20100528095946.GB9774@csn.ul.ie>
In-Reply-To: <20100528095946.GB9774@csn.ul.ie>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "rientjes@google.com" <rientjes@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 05/28/2010 02:59 AM, Mel Gorman wrote:
> On Thu, May 27, 2010 at 01:43:00PM -0700, Doug Doan wrote:
>> From: Doug Doan<dougd@cray.com>
>>
>> When a copy-on-write occurs, we take one of two paths in handle_mm_fault:
>> through handle_pte_fault for normal pages, or through hugetlb_fault for
>> huge pages.
>>
>> In the normal page case, we eventually get to do_wp_page and call mmu
>> notifiers via ptep_clear_flush_notify. There is no callout to the mmmu
>> notifiers in the huge page case. This patch fixes that.
>>
>> Signed-off-by: Doug Doan<dougd@cray.com>
>> ---
>
>> --- mm/hugetlb.c.orig	2010-05-27 13:07:58.569546314 -0700
>> +++ mm/hugetlb.c	2010-05-26 14:41:06.449296524 -0700
>> @@ -2345,11 +2345,17 @@ retry_avoidcopy:
>>   	ptep = huge_pte_offset(mm, address&  huge_page_mask(h));
>>   	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
>>   		/* Break COW */
>> +		mmu_notifier_invalidate_range_start(mm,
>> +			address&  huge_page_mask(h),
>> +			(address&  huge_page_mask(h)) + huge_page_size(h));
>
> Should the address not already be aligned?

I'm not seeing where the address was aligned before this point. The code just 
above aligns it:

    	ptep = huge_pte_offset(mm, address&  huge_page_mask(h));
    	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
    		/* Break COW */

> Otherwise, I don't see any problem.
>
>>   		huge_ptep_clear_flush(vma, address, ptep);
>>   		set_huge_pte_at(mm, address, ptep,
>>   				make_huge_pte(vma, new_page, 1));
>>   		/* Make the old page be freed below */
>>   		new_page = old_page;
>> +		mmu_notifier_invalidate_range_end(mm,
>> +			address&  huge_page_mask(h),
>> +			(address&  huge_page_mask(h)) + huge_page_size(h));
>>   	}
>>   	page_cache_release(new_page);
>>   	page_cache_release(old_page);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
