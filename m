Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id ACD6A6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:07:48 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id l124so80509256wmf.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:07:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e129si36328224wmd.1.2016.03.17.04.07.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 04:07:47 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] mm, thp: avoid unnecessary swapin in khugepaged
References: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
 <1457991611-6211-3-git-send-email-ebru.akagunduz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56EA9000.1070108@suse.cz>
Date: Thu, 17 Mar 2016 12:07:44 +0100
MIME-Version: 1.0
In-Reply-To: <1457991611-6211-3-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On 03/14/2016 10:40 PM, Ebru Akagunduz wrote:
> Currently khugepaged makes swapin readahead to improve
> THP collapse rate. This patch checks vm statistics
> to avoid workload of swapin, if unnecessary. So that
> when system under pressure, khugepaged won't consume
> resources to swapin.
>
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
>                          After swapped out
> -------------------------------------------------------------------
>                | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 206608 kB |  204800 kB    | 593392 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 351308 kB | 350208 kB     | 448692 kB |    %99    |
> -------------------------------------------------------------------
>
>                          After swapped in (waiting 10 minutes)
> -------------------------------------------------------------------
>                | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 551992 kB | 368640 kB     | 248008 kB |    %66    |
> -------------------------------------------------------------------
> Without patch | 586816 kB | 464896 kB     | 213184 kB |    %79    |
> -------------------------------------------------------------------
>
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Looks like a step in a good direction. Still might be worthwile to also 
wait for the swapin to complete, and actually collapse immediately, no?

> ---
> Changes in v2:
>   - Add reference to specify which patch fixed (Ebru Akagunduz)

The reference is again missing in v3.

>   - Fix commit subject line (Ebru Akagunduz)
>
> Changes in v3:
>   - Remove default values of allocstall (Kirill A. Shutemov)
>
>   mm/huge_memory.c | 13 +++++++++++--
>   1 file changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 86e9666..67a398c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -102,6 +102,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>    */
>   static unsigned int khugepaged_max_ptes_none __read_mostly;
>   static unsigned int khugepaged_max_ptes_swap __read_mostly;
> +static unsigned long int allocstall;

"int" here is unnecessary

>
>   static int khugepaged(void *none);
>   static int khugepaged_slab_init(void);
> @@ -2438,7 +2439,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>   	struct page *new_page;
>   	spinlock_t *pmd_ptl, *pte_ptl;
>   	int isolated = 0, result = 0;
> -	unsigned long hstart, hend;
> +	unsigned long hstart, hend, swap, curr_allocstall;
>   	struct mem_cgroup *memcg;
>   	unsigned long mmun_start;	/* For mmu_notifiers */
>   	unsigned long mmun_end;		/* For mmu_notifiers */
> @@ -2493,7 +2494,14 @@ static void collapse_huge_page(struct mm_struct *mm,
>   		goto out;
>   	}
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
>
>   	anon_vma_lock_write(vma->anon_vma);
>
> @@ -2790,6 +2798,7 @@ skip:
>   			VM_BUG_ON(khugepaged_scan.address < hstart ||
>   				  khugepaged_scan.address + HPAGE_PMD_SIZE >
>   				  hend);
> +			allocstall = sum_vm_event(ALLOCSTALL);

Why here? Rik said in v2:

> Khugepaged stores the allocstall value when it goes to sleep,
> and checks it before calling (or not) __collapse_huge_page_swapin.

But that's not true, this is not "when it goes to sleep".
So AFAICS it only observes the allocstalls between starting to scan a 
single pmd, and trying to collapse the pmd. So the window is quite tiny 
especially compared to I/O speeds, and this will IMHO catch only really 
frequent stalls. Placing it really at "when it goes to sleep" sounds better.

>   			ret = khugepaged_scan_pmd(mm, vma,
>   						  khugepaged_scan.address,
>   						  hpage);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
