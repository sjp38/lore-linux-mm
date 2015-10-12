Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 47A9D6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:15:10 -0400 (EDT)
Received: by wieq12 with SMTP id q12so25172539wie.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:15:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq2si16537259wib.56.2015.10.12.08.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 08:15:09 -0700 (PDT)
Subject: Re: [PATCH] thp: use is_zero_pfn after pte_present check
References: <1444614856-18543-1-git-send-email-minchan@kernel.org>
 <20151012101320.GB2544@node> <20151012145746.GA11396@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561BCE7A.1080403@suse.cz>
Date: Mon, 12 Oct 2015 17:15:06 +0200
MIME-Version: 1.0
In-Reply-To: <20151012145746.GA11396@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/12/2015 04:57 PM, Minchan Kim wrote:
> Hello,
>
> On Mon, Oct 12, 2015 at 01:13:20PM +0300, Kirill A. Shutemov wrote:
>> On Mon, Oct 12, 2015 at 10:54:16AM +0900, Minchan Kim wrote:
>>> Use is_zero_pfn on pteval only after pte_present check on pteval
>>> (It might be better idea to introduce is_zero_pte where checks
>>> pte_present first). Otherwise, it could work with swap or
>>> migration entry and if pte_pfn's result is equal to zero_pfn
>>> by chance, we lose user's data in __collapse_huge_page_copy.
>>> So if you're luck, the application is segfaulted and finally you
>>> could see below message when the application is exit.
>>>
>>> BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3
>>
>> Did you acctually steped on the bug?
>> If yes it's subject for stable@, I think.
>
> Yes, I did with my testing program which made heavy swap-in/out/
> swapoff with MADV_DONTNEED in a memcg.
> Actually, I marked this patch as -stable but removed it right before
> sending because my test program is artificial and didn't see any
> report about rss bad counting with MM_SWAPENTS in linux-mm(Of course,
> I might miss it).
> In addition, sometime I saw someone insists on "It's not a stable
> material if it's not a bug with real workload". I don't want to
> involve such non-technical stuff so waited someone nudges me to
> mark it as -stable and finally, you did. ;-)

I'd also think this should go -stable, and I haven't heard the "real 
workload" argument before.

> If other reviewers are not against, I will Cc -stable in next spin.
>
>>
>>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>>> ---
>>>
>>> I found this bug with MADV_FREE hard test. Sometime, I saw
>>> "Bad rss-counter" message with MM_SWAPENTS but it's really
>>> rare, once a day if I was luck or once in five days if I was
>>> unlucky so I am doing test still and just pass a few days but
>>> I hope it will fix the issue.
>>>
>>>   mm/huge_memory.c | 12 +++++++++++-
>>>   1 file changed, 11 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index 4b06b8db9df2..349590aa4533 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -2665,15 +2665,25 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>>>   	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
>>>   	     _pte++, _address += PAGE_SIZE) {
>>>   		pte_t pteval = *_pte;
>>> -		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
>>> +		if (pte_none(pteval)) {
>>
>> In -mm tree we have is_swap_pte() check before this point in
>> khugepaged_scan_pmd()
>
> Actually, I tested this patch with v4.2 kernel so it doesn't have
> the check.
> Now, I look through optimistic check for swapin readahead patch
> in current mmotm.
> It seems the check couldn't prevent this problem because it releases
> pte lock and anon_vma lock before being isolated the page in
> __collapse_huge_page_isolate so the page could be swapped out again.
>
>>
>> Also, what about similar pattern in __collapse_huge_page_isolate() and
>> __collapse_huge_page_copy()? Shouldn't they be fixed as well?
>
> I see what's wrong here.
> /me slaps self.
> The line I was about to change was in __collapse_huge_page_isolate
> but I changed khugepaged_scan_pmd by mistake at last modification
> since that part is almost same. :(
> Fortunately my testing kernel is doing right version.
> Here it goes.
>
>  From 2a2e4b247e132d823af30655dbc0b57738e9d6ee Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 12 Oct 2015 09:52:46 +0900
> Subject: [PATCH] thp: use is_zero_pfn only after pte_present check
>
> Use is_zero_pfn on pteval only after pte_present check on pteval
> (It might be better idea to introduce is_zero_pte where checks
> pte_present first). Otherwise, it could work with swap or
> migration entry and if pte_pfn's result is equal to zero_pfn
> by chance, we lose user's data in __collapse_huge_page_copy.
> So if you're luck, the application is segfaulted and finally you
> could see below message when the application is exit.
>
> BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

So this patch should be stable 4.1+. Does it apply both in -next and 
4.3-rcX?

> ---
>   mm/huge_memory.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4b06b8db9df2..bbac913f96bc 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2206,7 +2206,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
>   	     _pte++, address += PAGE_SIZE) {
>   		pte_t pteval = *_pte;
> -		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
> +		if (pte_none(pteval) || (pte_present(pteval) &&
> +				is_zero_pfn(pte_pfn(pteval)))) {
>   			if (!userfaultfd_armed(vma) &&
>   			    ++none_or_zero <= khugepaged_max_ptes_none)
>   				continue;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
