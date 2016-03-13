Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id A8ADB6B0005
	for <linux-mm@kvack.org>; Sun, 13 Mar 2016 19:33:04 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l68so81768235wml.1
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 16:33:04 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id t62si15389090wmf.12.2016.03.13.16.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Mar 2016 16:33:03 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id n186so12444061wmn.0
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 16:33:03 -0700 (PDT)
Date: Mon, 14 Mar 2016 02:33:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Message-ID: <20160313233301.GB10438@node.shutemov.name>
References: <1457861335-23297-1-git-send-email-ebru.akagunduz@gmail.com>
 <1457861335-23297-3-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457861335-23297-3-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Sun, Mar 13, 2016 at 11:28:55AM +0200, Ebru Akagunduz wrote:
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
>                         After swapped out
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 325784 kB |  325632 kB    | 474216 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 351308 kB | 350208 kB     | 448692 kB |    %99    |
> -------------------------------------------------------------------
> 
>                         After swapped in (waiting 10 minutes)
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 714164 kB | 489472 kB      | 85836 kB |    %68    |
> -------------------------------------------------------------------
> Without patch | 586816 kB | 464896 kB     | 213184 kB |    %79    |
> -------------------------------------------------------------------
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Fixes: 363cd76e5b11c ("mm: make swapin readahead to improve thp collapse rate")
> ---
> Changes in v2:
>  - Add reference to specify which patch fixed (Ebru Akagunduz)
>  - Fix commit subject line (Ebru Akagunduz)
> 
>  mm/huge_memory.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 86e9666..4a60035 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -102,6 +102,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>   */
>  static unsigned int khugepaged_max_ptes_none __read_mostly;
>  static unsigned int khugepaged_max_ptes_swap __read_mostly;
> +static unsigned long int allocstall = 0;

No need to zero it out. The variable is in .bss.


>  static int khugepaged(void *none);
>  static int khugepaged_slab_init(void);
> @@ -2438,7 +2439,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	struct page *new_page;
>  	spinlock_t *pmd_ptl, *pte_ptl;
>  	int isolated = 0, result = 0;
> -	unsigned long hstart, hend;
> +	unsigned long hstart, hend, swap = 0, curr_allocstall = 0;

No need to zero out too, because you always will initialize it anyway.

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

So, between these too points, where new ALLOCSTALL events comes from?

I would guess that in most cases they would come from allocation of huge
page itself (if khugepaged defrag is enabled). So we are willing to pay
for allocation new huge page, but not for swapping in.

I wounder, if it was wise to allocate the huge page in first place?

Or shouldn't we at least have consistent behaviour on swap-in vs.
allocation wrt khugepaged defragmentation option?

Or am I wrong and ALLOCSTALLs aren't caused by khugepagd?

>  	anon_vma_lock_write(vma->anon_vma);
>  
> @@ -2790,6 +2798,7 @@ skip:
>  			VM_BUG_ON(khugepaged_scan.address < hstart ||
>  				  khugepaged_scan.address + HPAGE_PMD_SIZE >
>  				  hend);
> +			allocstall = sum_vm_event(ALLOCSTALL);
>  			ret = khugepaged_scan_pmd(mm, vma,
>  						  khugepaged_scan.address,
>  						  hpage);
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
