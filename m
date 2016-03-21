Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A9AA96B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 11:36:40 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l68so156542751wml.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:36:40 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 8si15134115wmq.96.2016.03.21.08.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 08:36:39 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r129so10889092wmr.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:36:39 -0700 (PDT)
Date: Mon, 21 Mar 2016 16:36:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Message-ID: <20160321153637.GE21248@dhcp22.suse.cz>
References: <1458497259-12753-1-git-send-email-ebru.akagunduz@gmail.com>
 <1458497259-12753-3-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458497259-12753-3-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

[I am sorry I haven't responded sooner but I was busy with other stuff]

On Sun 20-03-16 20:07:39, Ebru Akagunduz wrote:
> Currently khugepaged makes swapin readahead to improve
> THP collapse rate. This patch checks vm statistics
> to avoid workload of swapin, if unnecessary. So that
> when system under pressure, khugepaged won't consume
> resources to swapin.

OK, so you want to disable the optimization when under the memory
pressure. That sounds like a good idea in general.
 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. The system
> was forced to swap out all. Afterwards, the test program
> touches the area by writing, it skips a page in each
> 20 pages of the area. When waiting to swapin readahead
> left part of the test, the memory forced to be busy
> doing page reclaim. There was enough free memory during
> test, khugepaged did not swapin readahead due to business.
> 
> Test results:
> 
>                         After swapped out
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 217888 kB |  217088 kB    | 582112 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 351308 kB | 350208 kB     | 448692 kB |    %99    |
> -------------------------------------------------------------------
> 
>                         After swapped in (waiting 10 minutes)
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 604440 kB | 348160 kB     | 195560 kB |    %57    |
> -------------------------------------------------------------------
> Without patch | 586816 kB | 464896 kB     | 213184 kB |    %79    |
> -------------------------------------------------------------------

I am not really sure I understand these results. The system indeed
swapped in much less but how come the Fraction is much higher when
__collapse_huge_page_swapin was called less?

> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Fixes: 363cd76e5b11c ("mm: make swapin readahead to improve thp collapse rate")

This doesn't exist in the Linus tree. So I guess this is a reference to
linux-next. If that is the case then just drop the Fixes part as the sha
is not stable and this will become confusing later on.

[...]

> @@ -2438,7 +2439,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	struct page *new_page;
>  	spinlock_t *pmd_ptl, *pte_ptl;
>  	int isolated = 0, result = 0;
> -	unsigned long hstart, hend;
> +	unsigned long hstart, hend, swap, curr_allocstall;
>  	struct mem_cgroup *memcg;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> @@ -2493,7 +2494,14 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		goto out;
>  	}
>  
> -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> +	swap = get_mm_counter(mm, MM_SWAPENTS);
> +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> +	/*
> +	 * When system under pressure, don't swapin readahead.
> +	 * So that avoid unnecessary resource consuming.
> +	 */
> +	if (allocstall == curr_allocstall && swap != 0)
> +		__collapse_huge_page_swapin(mm, vma, address, pmd);

this criteria doesn't really make much sense to me. So we are checking
whether there was the direct reclaim invoked since some point in time
(more on that below) and we take that as a signal of a strong memory
pressure, right? What if that was quite some time ago? What if we didn't
have a single direct reclaim but the kswapd was busy the whole time. Or
what if the allocstall was from a different numa node?

>  
>  	anon_vma_lock_write(vma->anon_vma);
>  
> @@ -2905,6 +2913,7 @@ static int khugepaged(void *none)
>  	set_user_nice(current, MAX_NICE);
>  
>  	while (!kthread_should_stop()) {
> +		allocstall = sum_vm_event(ALLOCSTALL);
>  		khugepaged_do_scan();

And this sounds even buggy AFAIU. I guess you want to snapshot before
goint to sleep no? Otherwise you are comparing allocstall diff from a
very short time period. Or was this an intention and you really want to
watch for events while khugepaged is running? If yes a comment would be
due here.

>  		khugepaged_wait_work();
>  	}

That being said, is this actually useful in the real life? Basing your
decision on something as volatile as the direct reclaim would lead to
rather volatile results. E.g. how stable are the numbers during your
test?

Wouldn't it be better to rather do an optimistic swapin and back out
if the direct reclaim is really required. I realize this will be a much
bigger change but it would make more sense I guess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
