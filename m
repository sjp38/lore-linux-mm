Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id B09806B0035
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 04:37:14 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up7so2484475pbc.26
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 01:37:14 -0700 (PDT)
Received: from psmtp.com ([74.125.245.126])
        by mx.google.com with SMTP id ei3si1148467pbc.230.2013.10.31.01.37.12
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 01:37:12 -0700 (PDT)
Date: Thu, 31 Oct 2013 09:37:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-memcg-use-proper-memcg-in-limit-bypass.patch added to -mm
 tree
Message-ID: <20131031083707.GA13144@dhcp22.suse.cz>
References: <5271845f.Z9YgMQjBJAhXMdBZ%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5271845f.Z9YgMQjBJAhXMdBZ%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 30-10-13 15:12:47, Andrew Morton wrote:
> Subject: + mm-memcg-use-proper-memcg-in-limit-bypass.patch added to -mm tree
> To: hannes@cmpxchg.org,mhocko@suse.cz
> From: akpm@linux-foundation.org
> Date: Wed, 30 Oct 2013 15:12:47 -0700
> 
> 
> The patch titled
>      Subject: mm: memcg: use proper memcg in limit bypass
> has been added to the -mm tree.  Its filename is
>      mm-memcg-use-proper-memcg-in-limit-bypass.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-use-proper-memcg-in-limit-bypass.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/mm-memcg-use-proper-memcg-in-limit-bypass.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm: memcg: use proper memcg in limit bypass
> 
> 84235de ("fs: buffer: move allocation failure loop into the allocator")
> allowed __GFP_NOFAIL allocations to bypass the limit if they fail to
> reclaim enough memory for the charge.  Because the main test case was on a
> 3.2-based system, this patch missed the fact that on newer kernels the
> charge function needs to return root_mem_cgroup when bypassing the limit,
> and not NULL.  This will corrupt whatever memory is at NULL + percpu
> pointer offset.  Fix this quickly before problems are reported.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

I guess this should be marked for stable as 84235de has been marked so.
It would be also nice to mention that bypass with root_mem_cgroup
happened at 3.3 times (it was done by 38c5d72f3ebe5 AFAICS).

> ---
> 
>  mm/memcontrol.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff -puN mm/memcontrol.c~mm-memcg-use-proper-memcg-in-limit-bypass mm/memcontrol.c
> --- a/mm/memcontrol.c~mm-memcg-use-proper-memcg-in-limit-bypass
> +++ a/mm/memcontrol.c
> @@ -2765,10 +2765,10 @@ done:
>  	*ptr = memcg;
>  	return 0;
>  nomem:
> -	*ptr = NULL;
> -	if (gfp_mask & __GFP_NOFAIL)
> -		return 0;
> -	return -ENOMEM;
> +	if (!(gfp_mask & __GFP_NOFAIL)) {
> +		*ptr = NULL;
> +		return -ENOMEM;
> +	}
>  bypass:
>  	*ptr = root_mem_cgroup;
>  	return -EINTR;
> _
> 
> Patches currently in -mm which might be from hannes@cmpxchg.org are
> 
> percpu-fix-this_cpu_sub-subtrahend-casting-for-unsigneds.patch
> memcg-use-__this_cpu_sub-to-dec-stats-to-avoid-incorrect-subtrahend-casting.patch
> mm-memcg-use-proper-memcg-in-limit-bypass.patch
> mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> mm-memcg-fix-test-for-child-groups.patch
> mm-nobootmemc-have-__free_pages_memory-free-in-larger-chunks.patch
> memcg-refactor-mem_control_numa_stat_show.patch
> memcg-support-hierarchical-memorynuma_stats.patch
> memblock-factor-out-of-top-down-allocation.patch
> memblock-introduce-bottom-up-allocation-mode.patch
> x86-mm-factor-out-of-top-down-direct-mapping-setup.patch
> x86-mem-hotplug-support-initialize-page-tables-in-bottom-up.patch
> x86-acpi-crash-kdump-do-reserve_crashkernel-after-srat-is-parsed.patch
> mem-hotplug-introduce-movable_node-boot-option.patch
> swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
> percpu-add-test-module-for-various-percpu-operations.patch
> linux-next.patch
> mm-avoid-increase-sizeofstruct-page-due-to-split-page-table-lock.patch
> mm-rename-use_split_ptlocks-to-use_split_pte_ptlocks.patch
> mm-convert-mm-nr_ptes-to-atomic_long_t.patch
> mm-introduce-api-for-split-page-table-lock-for-pmd-level.patch
> mm-thp-change-pmd_trans_huge_lock-to-return-taken-lock.patch
> mm-thp-move-ptl-taking-inside-page_check_address_pmd.patch
> mm-thp-do-not-access-mm-pmd_huge_pte-directly.patch
> mm-hugetlb-convert-hugetlbfs-to-use-split-pmd-lock.patch
> mm-convert-the-rest-to-new-page-table-lock-api.patch
> mm-implement-split-page-table-lock-for-pmd-level.patch
> x86-mm-enable-split-page-table-lock-for-pmd-level.patch
> debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
