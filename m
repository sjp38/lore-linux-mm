Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id F34436B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 14:56:35 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id q17so27770042lbn.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 11:56:35 -0700 (PDT)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id w8si2377554wjz.220.2016.06.02.11.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 11:56:34 -0700 (PDT)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 2 Jun 2016 19:56:33 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3168B1B0804B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 19:57:33 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u52IuTbE65536050
	for <linux-mm@kvack.org>; Thu, 2 Jun 2016 18:56:29 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u52IuTH8030128
	for <linux-mm@kvack.org>; Thu, 2 Jun 2016 12:56:29 -0600
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
References: <20160602172141.75c006a9@thinkpad>
 <20160602155149.GB8493@node.shutemov.name>
 <20160602114031.64b178c823901c171ec82745@linux-foundation.org>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <5750815B.1090302@de.ibm.com>
Date: Thu, 2 Jun 2016 20:56:27 +0200
MIME-Version: 1.0
In-Reply-To: <20160602114031.64b178c823901c171ec82745@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 06/02/2016 08:40 PM, Andrew Morton wrote:
> On Thu, 2 Jun 2016 18:51:50 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
>> On Thu, Jun 02, 2016 at 05:21:41PM +0200, Gerald Schaefer wrote:
>>> Christian Borntraeger reported a kernel panic after corrupt page counts,
>>> and it turned out to be a regression introduced with commit aa88b68c
>>> "thp: keep huge zero page pinned until tlb flush", at least on s390.
>>>
>>> put_huge_zero_page() was moved over from zap_huge_pmd() to release_pages(),
>>> and it was replaced by tlb_remove_page(). However, release_pages() might
>>> not always be triggered by (the arch-specific) tlb_remove_page().
>>>
>>> On s390 we call free_page_and_swap_cache() from tlb_remove_page(), and not
>>> tlb_flush_mmu() -> free_pages_and_swap_cache() like the generic version,
>>> because we don't use the MMU-gather logic. Although both functions have very
>>> similar names, they are doing very unsimilar things, in particular
>>> free_page_xxx is just doing a put_page(), while free_pages_xxx calls
>>> release_pages().
>>>
>>> This of course results in very harmful put_page()s on the huge zero page,
>>> on architectures where tlb_remove_page() is implemented in this way. It
>>> seems to affect only s390 and sh, but sh doesn't have THP support, so
>>> the problem (currently) probably only exists on s390.
>>>
>>> The following quick hack fixed the issue:
>>>
>>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>>> index 0d457e7..c99463a 100644
>>> --- a/mm/swap_state.c
>>> +++ b/mm/swap_state.c
>>> @@ -252,7 +252,10 @@ static inline void free_swap_cache(struct page *page)
>>>  void free_page_and_swap_cache(struct page *page)
>>>  {
>>>  	free_swap_cache(page);
>>> -	put_page(page);
>>> +	if (is_huge_zero_page(page))
>>> +		put_huge_zero_page();
>>> +	else
>>> +		put_page(page);
>>>  }
>>>  
>>>  /*
>>
>> The fix looks good to me.
> 
> Yes.  A bit regrettable, but that's what release_pages() does.
> 
> Can we have a signed-off-by please?

Please also add CC: stable for 4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
