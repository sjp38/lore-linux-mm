Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29D5F6B0396
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:09:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y51so23354740wry.6
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:09:30 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id j191si12073994wmd.134.2017.03.19.13.09.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 13:09:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 8BD9298D08
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:09:28 +0000 (UTC)
Date: Sun, 19 Mar 2017 20:09:22 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 09/16] mm/hmm: heterogeneous memory management (HMM for
 short)
Message-ID: <20170319200922.GG2774@techsingularity.net>
References: <1489680335-6594-10-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489680335-6594-10-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, Mar 16, 2017 at 12:05:28PM -0400, J?r?me Glisse wrote:
> HMM provides 3 separate types of functionality:
>     - Mirroring: synchronize CPU page table and device page table
>     - Device memory: allocating struct page for device memory
>     - Migration: migrating regular memory to device memory
> 
> This patch introduces some common helpers and definitions to all of
> those 3 functionality.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> ---
> <SNIP>
> + * Mirroring:
> + *
> + * HMM provides helpers to mirror a process address space on a device. For this,
> + * it provides several helpers to order device page table updates with respect
> + * to CPU page table updates. The requirement is that for any given virtual
> + * address the CPU and device page table cannot point to different physical
> + * pages. It uses the mmu_notifier API behind the scenes.
> + *
> + * Device memory:
> + *
> + * HMM provides helpers to help leverage device memory. Device memory is, at any
> + * given time, either CPU-addressable like regular memory, or completely
> + * unaddressable. In both cases the device memory is associated with dedicated
> + * struct pages (which are allocated as if for hotplugged memory). Device memory
> + * management is under the responsibility of the device driver. HMM only
> + * allocates and initializes the struct pages associated with the device memory,
> + * by hotplugging a ZONE_DEVICE memory range.
> + *
> + * Allocating struct pages for device memory allows us to use device memory
> + * almost like regular CPU memory. Unlike regular memory, however, it cannot be
> + * added to the lru, nor can any memory allocation can use device memory
> + * directly. Device memory will only end up in use by a process if the device
> + * driver migrates some of the process memory from regular memory to device
> + * memory.
> + *
> + * Migration:
> + *
> + * The existing memory migration mechanism (mm/migrate.c) does not allow using
> + * anything other than the CPU to copy from source to destination memory.
> + * Moreover, existing code does not provide a way to migrate based on a virtual
> + * address range. Existing code only supports struct-page-based migration. Also,
> + * the migration flow does not allow for graceful failure at intermediate stages
> + * of the migration process.
> + *
> + * HMM solves all of the above, by providing a simple API:
> + *
> + *      hmm_vma_migrate(ops, vma, src_pfns, dst_pfns, start, end, private);
> + *
> + * finalize_and_map(). The first,  alloc_and_copy(), allocates the destination

Somethinig is missing from that sentence. It doesn't parse as it is. The
previous helper was migrate_vma from two patches ago so something has
gone side-ways. I think you meant to explain the ops parameter here but
it got munged.

If so, it would best to put the explanation of the API and ops with
their declarations and reference them from here. Someone looking to
understand migrate_vma() will not necessarily be inspired to check hmm.h
for the information.

> <SNIP>

Various helpers looked ok

> +/* Below are for HMM internal use only! Not to be used by device driver! */
> +void hmm_mm_destroy(struct mm_struct *mm);
> +

This will be ignored at least once :) . Not that it matters as assuming
the driver is a module, it'll not resolve the symbol,

> @@ -495,6 +496,10 @@ struct mm_struct {
>  	atomic_long_t hugetlb_usage;
>  #endif
>  	struct work_struct async_put_work;
> +#if IS_ENABLED(CONFIG_HMM)
> +	/* HMM need to track few things per mm */
> +	struct hmm *hmm;
> +#endif
>  };
>  

Inevitable really but not too bad in comparison to putting pfn_to_page
unnecessarily in the fault path or updating every migration user.

> @@ -289,6 +289,10 @@ config MIGRATION
>  config ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	bool
>  
> +config HMM
> +	bool
> +	depends on MMU
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
>  

That's a bit sparse in terms of documentation and information
distribution maintainers if they want to enable this.

> <SNIP>
>
> +void hmm_mm_destroy(struct mm_struct *mm)
> +{
> +	struct hmm *hmm;
> +
> +	/*
> +	 * We should not need to lock here as no one should be able to register
> +	 * a new HMM while an mm is being destroy. But just to be safe ...
> +	 */
> +	spin_lock(&mm->page_table_lock);
> +	hmm = mm->hmm;
> +	mm->hmm = NULL;
> +	spin_unlock(&mm->page_table_lock);
> +	kfree(hmm);
> +}

Eh? 

I actually reacted very badly to the locking before I read the comment
to the extent I searched the patch again looking for the locking
documentation that said this was needed.

Ditch that lock, it's called from mmdrop context and the register
handler doesn't have the same locking. It's also expanding the scope of
what that lock is for into an area it does not belong.

Everything else looked fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
