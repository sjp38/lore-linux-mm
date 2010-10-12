Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E357E6B00CB
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 08:37:07 -0400 (EDT)
Message-ID: <4CB45672.7020206@linux.intel.com>
Date: Tue, 12 Oct 2010 14:37:06 +0200
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] HWPOISON: Implement hwpoison-on-free for soft offlining
References: <1286402951-1881-1-git-send-email-andi@firstfloor.org> <1286402951-1881-2-git-send-email-andi@firstfloor.org> <20101012122647.GA14208@localhost>
In-Reply-To: <20101012122647.GA14208@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  On 10/12/2010 2:26 PM, Wu Fengguang wrote:
>
>>
>> +#if defined(CONFIG_MEMORY_FAILURE)&&  BITS_PER_LONG == 64
> We have the simpler CONFIG_HWPOISON_ON_FREE :)
>

Leftover from when I didn't have that. Fixed.

>> +PAGEFLAG(HWPoisonOnFree, hwpoison_on_free)
>> +TESTSCFLAG(HWPoisonOnFree, hwpoison_on_free)
>> +#define __PG_HWPOISON_ON_FREE (1UL<<  PG_hwpoison_on_free)
>> +#else
>> +PAGEFLAG_FALSE(HWPoisonOnFree)
> Could define SETPAGEFLAG_NOOP(HWPoisonOnFree) too, for eliminating an
> #ifdef in the .c file.

Ok.

>
>>   	}
>> +
>> +	if (PageHWPoisonOnFree(page)) {
>> +		pr_info("soft_offline: %#lx: Delaying poision of unknown page %lx to free\n",
>> +			pfn, page->flags);
>> +		return -EIO; /* or 0? */
> -EIO looks safer because HWPoisonOnFree does not guarantee success.
>
Ok.

>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a8cfa9c..519c24c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -564,6 +564,8 @@ static inline int free_pages_check(struct page *page)
>>   		(page->mapping != NULL)  |
>>   		(atomic_read(&page->_count) != 0) |
>>   		(page->flags&  PAGE_FLAGS_CHECK_AT_FREE))) {
>> +		if (PageHWPoisonOnFree(page))
>> +			hwpoison_page_on_free(page);
> hwpoison_page_on_free() seems to be undefined when
> CONFIG_HWPOISON_ON_FREE is not defined.

Yes, but I rely on the compiler never generating the call in this case 
because
the test is zero.

It would fail on a unoptimized build, but the kernel doesn't support 
that anyways.

Thanks for the review.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
