Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0CB6B026F
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:55:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h24-v6so7421533eda.10
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:55:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g56-v6si1352182edg.369.2018.10.12.09.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 09:55:53 -0700 (PDT)
Date: Fri, 12 Oct 2018 18:55:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/thp: fix call to mmu_notifier in
 set_pmd_migration_entry()
Message-ID: <20181012165548.GZ5873@dhcp22.suse.cz>
References: <20181012160953.5841-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181012160953.5841-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, David Nellans <dnellans@nvidia.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Fri 12-10-18 12:09:53, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Inside set_pmd_migration_entry() we are holding page table locks and
> thus we can not sleep so we can not call invalidate_range_start/end()
> 
> So remove call to mmu_notifier_invalidate_range_start/end() and add
> call to mmu_notifier_invalidate_range(). Note that we are already
> calling mmu_notifier_invalidate_range_start/end() inside the function
> calling set_pmd_migration_entry() (see try_to_unmap_one()).
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Reported-by: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: David Nellans <dnellans@nvidia.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>

Is this worth backporting to stable trees?

The patch looks good to me
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/huge_memory.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 533f9b00147d..93cb80fe12cb 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2885,9 +2885,6 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
>  	if (!(pvmw->pmd && !pvmw->pte))
>  		return;
>  
> -	mmu_notifier_invalidate_range_start(mm, address,
> -			address + HPAGE_PMD_SIZE);
> -
>  	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
>  	pmdval = *pvmw->pmd;
>  	pmdp_invalidate(vma, address, pvmw->pmd);
> @@ -2898,11 +2895,9 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
>  	if (pmd_soft_dirty(pmdval))
>  		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
>  	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
> +	mmu_notifier_invalidate_range(mm, address, address + HPAGE_PMD_SIZE);
>  	page_remove_rmap(page, true);
>  	put_page(page);
> -
> -	mmu_notifier_invalidate_range_end(mm, address,
> -			address + HPAGE_PMD_SIZE);
>  }
>  
>  void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
> -- 
> 2.17.2

-- 
Michal Hocko
SUSE Labs
