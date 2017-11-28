Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48FEF6B02CB
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:12:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n8so28508wmg.4
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:12:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si1951197edr.56.2017.11.28.01.12.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 01:12:36 -0800 (PST)
Date: Tue, 28 Nov 2017 10:12:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: make faultaround produce old ptes
Message-ID: <20171128091234.GH5977@quack2.suse.cz>
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org

On Tue 28-11-17 10:37:49, Vinayak Menon wrote:
> Based on Kirill's patch [1].
> 
> Currently, faultaround code produces young pte.  This can screw up
> vmscan behaviour[2], as it makes vmscan think that these pages are hot
> and not push them out on first round.
> 
> During sparse file access faultaround gets more pages mapped and all of
> them are young.  Under memory pressure, this makes vmscan swap out anon
> pages instead, or to drop other page cache pages which otherwise stay
> resident.
> 
> Modify faultaround to produce old ptes, so they can easily be reclaimed
> under memory pressure.
> 
> This can to some extend defeat the purpose of faultaround on machines
> without hardware accessed bit as it will not help us with reducing the
> number of minor page faults.
> 
> Making the faultaround ptes old results in a unixbench regression for some
> architectures [3][4]. But on some architectures it is not found to cause
> any regression. So by default produce young ptes and provide an option for
> architectures to make the ptes old.
> 
> [1] http://lkml.kernel.org/r/1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com
> [2] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
> [3] https://marc.info/?l=linux-kernel&m=146582237922378&w=2
> [4] https://marc.info/?l=linux-mm&m=146589376909424&w=2
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>  include/linux/mm-arch-hooks.h | 7 +++++++
>  include/linux/mm.h            | 2 ++
>  mm/filemap.c                  | 4 ++++
>  mm/memory.c                   | 5 +++++
>  4 files changed, 18 insertions(+)
> 
> diff --git a/include/linux/mm-arch-hooks.h b/include/linux/mm-arch-hooks.h
> index 4efc3f56..0322b98 100644
> --- a/include/linux/mm-arch-hooks.h
> +++ b/include/linux/mm-arch-hooks.h
> @@ -22,4 +22,11 @@ static inline void arch_remap(struct mm_struct *mm,
>  #define arch_remap arch_remap
>  #endif
>  
> +#ifndef arch_faultaround_pte_mkold
> +static inline void arch_faultaround_pte_mkold(struct vm_fault *vmf)
> +{
> +}
> +#define arch_faultaround_pte_mkold arch_faultaround_pte_mkold
> +#endif
> +
>  #endif /* _LINUX_MM_ARCH_HOOKS_H */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7661156..be689a0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -302,6 +302,7 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
>  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> +#define FAULT_FLAG_MKOLD	0x200	/* Make faultaround ptes old */

Nit: Can we make this FAULT_FLAG_PREFAULT_OLD or something like that so
that it is clear from the flag name that this is about prefaulting of
pages?

>  #define FAULT_FLAG_TRACE \
>  	{ FAULT_FLAG_WRITE,		"WRITE" }, \
> @@ -330,6 +331,7 @@ struct vm_fault {
>  	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
>  	pgoff_t pgoff;			/* Logical page offset based on vma */
>  	unsigned long address;		/* Faulting virtual address */
> +	unsigned long fault_address;    /* Saved faulting virtual address */

Ugh, so I dislike how you hide the decision about whether the *particular*
PTE should be old or young in the arch code. Sure the arch wants to decide
whether the prefaulted PTEs should be old or young and that it has to tell
us but the arch code has no business in checking whether this is prefault
or a normal fault - that decision belongs to filemap_map_pages(). So I'd do
in filemap_map_pages() something like:

	if (iter.index > start_pgoff && arch_wants_old_faultaround_pte())
		vmf->flags |= FAULT_FLAG_PREFAULT_OLD;

And then there's no need for new fault_address in vm_fault or messing with
addresses and fault flags in arch specific code.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
