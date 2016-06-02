From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
Date: Thu, 2 Jun 2016 20:56:27 +0200
Message-ID: <201606021856.u52Ik7dd033233@mx0a-001b2d01.pphosted.com>
References: <20160602172141.75c006a9@thinkpad>
 <20160602155149.GB8493@node.shutemov.name>
 <20160602114031.64b178c823901c171ec82745@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160602114031.64b178c823901c171ec82745@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-Id: linux-mm.kvack.org

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
