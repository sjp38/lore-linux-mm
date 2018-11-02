Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 01F456B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 19:27:23 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d6-v6so2541560ywa.7
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 16:27:22 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y15-v6si5837090ybg.194.2018.11.02.16.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 16:27:21 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com> <20181012105612.GK8537@350D>
 <b115b2ce-8fe8-db03-da9c-452511c8ed27@nvidia.com>
 <20181024110031.GM8537@350D>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8a9d3a4e-a5d6-3d2d-008f-dc2d6cfd94ed@nvidia.com>
Date: Fri, 2 Nov 2018 16:27:19 -0700
MIME-Version: 1.0
In-Reply-To: <20181024110031.GM8537@350D>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 10/24/18 4:00 AM, Balbir Singh wrote:
> On Fri, Oct 12, 2018 at 05:15:51PM -0700, John Hubbard wrote:
>> On 10/12/18 3:56 AM, Balbir Singh wrote:
>>> On Thu, Oct 11, 2018 at 11:00:12PM -0700, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>> [...]
>>>> + * Because page->dma_pinned_flags is unioned with page->lru, any page that
>>>> + * uses these flags must NOT be on an LRU. That's partly enforced by
>>>> + * ClearPageDmaPinned, which gives the page back to LRU.
>>>> + *
>>>> + * PageDmaPinned also corresponds to PageTail (the 0th bit in the first union
>>>> + * of struct page), and this flag is checked without knowing whether it is a
>>>> + * tail page or a PageDmaPinned page. Therefore, start the flags at bit 1 (0x2),
>>>> + * rather than bit 0.
>>>> + */
>>>> +#define PAGE_DMA_PINNED		0x2
>>>> +#define PAGE_DMA_PINNED_FLAGS	(PAGE_DMA_PINNED)
>>>> +
>>>
>>> This is really subtle, additional changes to compound_head will need to coordinate
>>> with these flags? Also doesn't this bit need to be unique across all structs in
>>> the union? I guess that is guaranteed by the fact that page == compound_head(page)
>>> as per your assertion, but I've forgotten why that is true. Could you please
>>> add some commentary on that
>>>
>>
>> Yes, agreed. I've rewritten and augmented that comment block, plus removed the 
>> PAGE_DMA_PINNED_FLAGS (there are no more bits available, so it's just misleading 
>> to even have it). So now it looks like this:
>>
>> /*
>>  * Because page->dma_pinned_flags is unioned with page->lru, any page that
>>  * uses these flags must NOT be on an LRU. That's partly enforced by
>>  * ClearPageDmaPinned, which gives the page back to LRU.
>>  *
>>  * PageDmaPinned is checked without knowing whether it is a tail page or a
>>  * PageDmaPinned page. For that reason, PageDmaPinned avoids PageTail (the 0th
>>  * bit in the first union of struct page), and instead uses bit 1 (0x2),
>>  * rather than bit 0.
>>  *
>>  * PageDmaPinned can only be used if no other systems are using the same bit
>>  * across the first struct page union. In this regard, it is similar to
>>  * PageTail, and in fact, because of PageTail's constraint that bit 0 be left
>>  * alone, bit 1 is also left alone so far: other union elements (ignoring tail
>>  * pages) put pointers there, and pointer alignment leaves the lower two bits
>>  * available.
>>  *
>>  * So, constraints include:
>>  *
>>  *     -- Only use PageDmaPinned on non-tail pages.
>>  *     -- Remove the page from any LRU list first.
>>  */
>> #define PAGE_DMA_PINNED		0x2
>>
>> /*
>>  * Because these flags are read outside of a lock, ensure visibility between
>>  * different threads, by using READ|WRITE_ONCE.
>>  */
>> static __always_inline int PageDmaPinned(struct page *page)
>> {
>> 	VM_BUG_ON(page != compound_head(page));
>> 	return (READ_ONCE(page->dma_pinned_flags) & PAGE_DMA_PINNED) != 0;
>> }
>>
>> [...]
>>>> +static __always_inline void SetPageDmaPinned(struct page *page)
>>>> +{
>>>> +	VM_BUG_ON(page != compound_head(page));
>>>
>>> VM_BUG_ON(!list_empty(&page->lru))
>>
>>
>> There is only one place where we set this flag, and that is when (in patch 6/6)
>> transitioning from a page that might (or might not) have been
>> on an LRU. In that case, the calling code has already corrupted page->lru, by
>> writing to page->dma_pinned_count, which is unions with page->lru:
>>
>> 		atomic_set(&page->dma_pinned_count, 1);
>> 		SetPageDmaPinned(page);
>>
>> ...so it would be inappropriate to call a list function, such as 
>> list_empty(), on that field.  Let's just leave it as-is.
>>
>>
>>>
>>>> +	WRITE_ONCE(page->dma_pinned_flags, PAGE_DMA_PINNED);
>>>> +}
>>>> +
>>>> +static __always_inline void ClearPageDmaPinned(struct page *page)
>>>> +{
>>>> +	VM_BUG_ON(page != compound_head(page));
>>>> +	VM_BUG_ON_PAGE(!PageDmaPinnedFlags(page), page);
>>>> +
>>>> +	/* This does a WRITE_ONCE to the lru.next, which is also the
>>>> +	 * page->dma_pinned_flags field. So in addition to restoring page->lru,
>>>> +	 * this provides visibility to other threads.
>>>> +	 */
>>>> +	INIT_LIST_HEAD(&page->lru);
>>>
>>> This assumes certain things about list_head, why not use the correct
>>> initialization bits.
>>>
>>
>> Yes, OK, changed to:
>>
>> static __always_inline void ClearPageDmaPinned(struct page *page)
>> {
>> 	VM_BUG_ON(page != compound_head(page));
>> 	VM_BUG_ON_PAGE(!PageDmaPinned(page), page);
>>
>> 	/* Provide visibility to other threads: */
>> 	WRITE_ONCE(page->dma_pinned_flags, 0);
>>
>> 	/*
>> 	 * Safety precaution: restore the list head, before possibly returning
>> 	 * the page to other subsystems.
>> 	 */
>> 	INIT_LIST_HEAD(&page->lru);
>> }
>>
>>
> 
> Sorry, I've been distracted with other things
> 
> This looks better, do we still need the INIT_LIST_HEAD?
> 

Good point. I guess not. I was getting a little too fancy, and it's better 
for ClearPageDmaPinned to be true to its name, and just only do that.

(Sorry for the delayed response.)

thanks,
-- 
John Hubbard
NVIDIA
