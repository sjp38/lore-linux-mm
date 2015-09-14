Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 501896B025D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:31:12 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so142978042wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:31:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fz6si17128820wic.116.2015.09.14.06.31.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Sep 2015 06:31:10 -0700 (PDT)
Subject: Re: [PATCHv5 5/7] mm: make compound_head() robust
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441283758-92774-6-git-send-email-kirill.shutemov@linux.intel.com>
 <55F16150.502@suse.cz> <20150911133501.GA9129@node.dhcp.inet.fi>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F6CC1B.8020304@suse.cz>
Date: Mon, 14 Sep 2015 15:31:07 +0200
MIME-Version: 1.0
In-Reply-To: <20150911133501.GA9129@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 09/11/2015 03:35 PM, Kirill A. Shutemov wrote:
>>> index 097c7a4bfbd9..330377f83ac7 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -1686,8 +1686,7 @@ static void __split_huge_page_refcount(struct page *page,
>>>   				      (1L << PG_unevictable)));
>>>   		page_tail->flags |= (1L << PG_dirty);
>>>
>>> -		/* clear PageTail before overwriting first_page */
>>> -		smp_wmb();
>>> +		clear_compound_head(page_tail);
>>
>> I would sleep better if this was done before setting all the page->flags above,
>> previously, PageTail was cleared by the first operation which is
>> "page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;"
>> I do realize that it doesn't use WRITE_ONCE, so it might have been theoretically
>> broken already, if it does matter.
>
> Right. Nothing enforces particular order. If we really need to have some
> ordering on PageTail() vs. page->flags let's define it, but so far I
> don't see a reason to change this part.

OK.

>>> diff --git a/mm/internal.h b/mm/internal.h
>>> index 36b23f1e2ca6..89e21a07080a 100644
>>> --- a/mm/internal.h
>>> +++ b/mm/internal.h
>>> @@ -61,9 +61,9 @@ static inline void __get_page_tail_foll(struct page *page,
>>>   	 * speculative page access (like in
>>>   	 * page_cache_get_speculative()) on tail pages.
>>>   	 */
>>> -	VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <= 0, page);
>>> +	VM_BUG_ON_PAGE(atomic_read(&compound_head(page)->_count) <= 0, page);
>>>   	if (get_page_head)
>>> -		atomic_inc(&page->first_page->_count);
>>> +		atomic_inc(&compound_head(page)->_count);
>>
>> Doing another compound_head() seems like overkill when this code already assumes
>> PageTail.
>
> "Overkill"? It's too strong wording for re-read hot cache line.

Hm good point.

>> All callers do it after if (PageTail()) which means they already did
>> READ_ONCE(page->compound_head) and here they do another one. Potentially with
>> different result in bit 0, which would be a subtle bug, that could be
>> interesting to catch with some VM_BUG_ON. I don't know if a direct plain
>> page->compound_head access here instead of compound_head() would also result in
>> a re-read, since the previous access did use READ_ONCE(). Maybe it would be best
>> to reorganize the code here and in the 3 call sites so that the READ_ONCE() used
>> to determine PageTail also obtains the compound head pointer.
>
> All we would possbily win by the change is few bytes in code. Additional
> READ_ONCE() only affect code generation. It doesn't introduce any cpu
> barriers. The cache line with compound_head is in L1 anyway.
>
> I don't see justification to change this part too. If you think we can
> gain something by reworking this code, feel free to propose patch on top.

OK, it's probably not worth:

add/remove: 0/0 grow/shrink: 1/3 up/down: 7/-66 (-59)
function                                     old     new   delta
follow_trans_huge_pmd                        516     523      +7
follow_page_pte                              905     893     -12
follow_hugetlb_page                          943     919     -24
__get_page_tail                              440     410     -30


>>> diff --git a/mm/swap.c b/mm/swap.c
>>> index a3a0a2f1f7c3..faa9e1687dea 100644
>>> --- a/mm/swap.c
>>> +++ b/mm/swap.c
>>> @@ -200,7 +200,7 @@ out_put_single:
>>>   				__put_single_page(page);
>>>   			return;
>>>   		}
>>> -		VM_BUG_ON_PAGE(page_head != page->first_page, page);
>>> +		VM_BUG_ON_PAGE(page_head != compound_head(page), page);
>>>   		/*
>>>   		 * We can release the refcount taken by
>>>   		 * get_page_unless_zero() now that
>>> @@ -261,7 +261,7 @@ static void put_compound_page(struct page *page)
>>>   	 *  Case 3 is possible, as we may race with
>>>   	 *  __split_huge_page_refcount tearing down a THP page.
>>>   	 */
>>> -	page_head = compound_head_by_tail(page);
>>> +	page_head = compound_head(page);
>>
>> This is also in a path after PageTail() is true.
>
> We can only save one branch here: other PageTail() is most likely in other
> compilation unit and compiler would not be able to eliminate additional
> load.
> Why bother?

Hmm, right. Bah.

add/remove: 0/0 grow/shrink: 1/0 up/down: 8/0 (8)
function                                     old     new   delta
put_compound_page                            500     508      +8



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
