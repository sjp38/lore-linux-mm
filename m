Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 341DC6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 09:53:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 6so41837wra.23
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 06:53:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d22si12192132wmd.70.2017.04.10.06.53.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 06:53:44 -0700 (PDT)
Date: Mon, 10 Apr 2017 15:53:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Message-ID: <20170410135342.GD4618@dhcp22.suse.cz>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 10-04-17 10:48:25, Mel Gorman wrote:
> A user reported a bug against a distribution kernel while running
> a proprietary workload described as "memory intensive that is not
> swapping" that is expected to apply to mainline kernels. The workload
> is read/write/modifying ranges of memory and checking the contents. They
> reported that within a few hours that a bad PMD would be reported followed
> by a memory corruption where expected data was all zeros.  A partial report
> of the bad PMD looked like
> 
> [ 5195.338482] ../mm/pgtable-generic.c:33: bad pmd ffff8888157ba008(000002e0396009e2)
> [ 5195.341184] ------------[ cut here ]------------
> [ 5195.356880] kernel BUG at ../mm/pgtable-generic.c:35!
> ....
> [ 5195.410033] Call Trace:
> [ 5195.410471]  [<ffffffff811bc75d>] change_protection_range+0x7dd/0x930
> [ 5195.410716]  [<ffffffff811d4be8>] change_prot_numa+0x18/0x30
> [ 5195.410918]  [<ffffffff810adefe>] task_numa_work+0x1fe/0x310
> [ 5195.411200]  [<ffffffff81098322>] task_work_run+0x72/0x90
> [ 5195.411246]  [<ffffffff81077139>] exit_to_usermode_loop+0x91/0xc2
> [ 5195.411494]  [<ffffffff81003a51>] prepare_exit_to_usermode+0x31/0x40
> [ 5195.411739]  [<ffffffff815e56af>] retint_user+0x8/0x10
> 
> Decoding revealed that the PMD was a valid prot_numa PMD and the bad PMD
> was a false detection. The bug does not trigger if automatic NUMA balancing
> or transparent huge pages is disabled.
> 
> The bug is due a race in change_pmd_range between a pmd_trans_huge and
> pmd_nond_or_clear_bad check without any locks held. During the pmd_trans_huge
> check, a parallel protection update under lock can have cleared the PMD
> and filled it with a prot_numa entry between the transhuge check and the
> pmd_none_or_clear_bad check.
> 
> While this could be fixed with heavy locking, it's only necessary to
> make a copy of the PMD on the stack during change_pmd_range and avoid
> races. A new helper is created for this as the check if quite subtle and the
> existing similar helpful is not suitable. This passed 154 hours of testing

s@helpful@helper@ I suspect

> (usually triggers between 20 minutes and 24 hours) without detecting bad
> PMDs or corruption. A basic test of an autonuma-intensive workload showed
> no significant change in behaviour.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Cc: stable@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>

you will probably win the_longest_function_name_contest but I do not
have much better suggestion.

> ---
>  include/asm-generic/pgtable.h | 25 +++++++++++++++++++++++++
>  mm/mprotect.c                 | 12 ++++++++++--
>  2 files changed, 35 insertions(+), 2 deletions(-)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 1fad160f35de..597fa482cd4a 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -819,6 +819,31 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
>  }
>  
>  /*
> + * Used when setting automatic NUMA hinting protection where it is
> + * critical that a numa hinting PMD is not confused with a bad PMD.
> + */
> +static inline int pmd_none_or_clear_bad_unless_trans_huge(pmd_t *pmd)
> +{
> +	pmd_t pmdval = pmd_read_atomic(pmd);
> +
> +	/* See pmd_none_or_trans_huge_or_clear_bad for info on barrier */
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	barrier();
> +#endif
> +
> +	if (pmd_none(pmdval))
> +		return 1;
> +	if (pmd_trans_huge(pmdval))
> +		return 0;
> +	if (unlikely(pmd_bad(pmdval))) {
> +		pmd_clear_bad(pmd);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +
> +/*
>   * This is a noop if Transparent Hugepage Support is not built into
>   * the kernel. Otherwise it is equivalent to
>   * pmd_none_or_trans_huge_or_clear_bad(), and shall only be called in
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 8edd0d576254..821ff2904cdb 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -150,8 +150,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		unsigned long this_pages;
>  
>  		next = pmd_addr_end(addr, end);
> -		if (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
> -				&& pmd_none_or_clear_bad(pmd))
> +
> +		/*
> +		 * Automatic NUMA balancing walks the tables with mmap_sem
> +		 * held for read. It's possible a parallel update
> +		 * to occur between pmd_trans_huge and a pmd_none_or_clear_bad
> +		 * check leading to a false positive and clearing. Hence, it's
> +		 * necessary to atomically read the PMD value for all the
> +		 * checks.
> +		 */
> +		if (!pmd_devmap(*pmd) && pmd_none_or_clear_bad_unless_trans_huge(pmd))
>  			continue;
>  
>  		/* invoke the mmu notifier if the pmd is populated */

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
