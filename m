Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7614E6B0403
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:51:04 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u62so37751136lfg.6
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 07:51:04 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id u7si7750860ljd.273.2017.06.21.07.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 07:51:02 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l200so10208888lfg.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 07:51:02 -0700 (PDT)
Date: Wed, 21 Jun 2017 17:50:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v7 05/10] mm: thp: enable thp migration in generic path
Message-ID: <20170621145055.2ysop2gpjccrwp7l@node.shutemov.name>
References: <20170620230715.81590-1-zi.yan@sent.com>
 <20170620230715.81590-6-zi.yan@sent.com>
 <20170621112329.uc6ejsnicujchjrh@node.shutemov.name>
 <4A34E00E-C36A-437A-BEC1-05BAA9E99EA2@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A34E00E-C36A-437A-BEC1-05BAA9E99EA2@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

On Wed, Jun 21, 2017 at 10:37:30AM -0400, Zi Yan wrote:
> On 21 Jun 2017, at 7:23, Kirill A. Shutemov wrote:
> 
> > On Tue, Jun 20, 2017 at 07:07:10PM -0400, Zi Yan wrote:
> >> From: Zi Yan <zi.yan@cs.rutgers.edu>
> >>
> >> This patch adds thp migration's core code, including conversions
> >> between a PMD entry and a swap entry, setting PMD migration entry,
> >> removing PMD migration entry, and waiting on PMD migration entries.
> >>
> >> This patch makes it possible to support thp migration.
> >> If you fail to allocate a destination page as a thp, you just split
> >> the source thp as we do now, and then enter the normal page migration.
> >> If you succeed to allocate destination thp, you enter thp migration.
> >> Subsequent patches actually enable thp migration for each caller of
> >> page migration by allowing its get_new_page() callback to
> >> allocate thps.
> >>
> >> ChangeLog v1 -> v2:
> >> - support pte-mapped thp, doubly-mapped thp
> >>
> >> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>
> >> ChangeLog v2 -> v3:
> >> - use page_vma_mapped_walk()
> >> - use pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear() in
> >>   set_pmd_migration_entry()
> >>
> >> ChangeLog v3 -> v4:
> >> - factor out the code of removing pte pgtable page in zap_huge_pmd()
> >>
> >> ChangeLog v4 -> v5:
> >> - remove unnecessary PTE-mapped THP code in remove_migration_pmd()
> >>   and set_pmd_migration_entry()
> >> - restructure the code in zap_huge_pmd() to avoid factoring out
> >>   the pte pgtable page code
> >> - in zap_huge_pmd(), check that PMD swap entries are migration entries
> >> - change author information
> >>
> >> ChangeLog v5 -> v7
> >> - use macro to disable the code when thp migration is not enabled
> >>
> >> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> >> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> ---
> >>  arch/x86/include/asm/pgtable_64.h |  2 +
> >>  include/linux/swapops.h           | 69 +++++++++++++++++++++++++++++-
> >>  mm/huge_memory.c                  | 88 ++++++++++++++++++++++++++++++++++++---
> >>  mm/migrate.c                      | 32 +++++++++++++-
> >>  mm/page_vma_mapped.c              | 17 ++++++--
> >>  mm/pgtable-generic.c              |  3 +-
> >>  mm/rmap.c                         | 13 ++++++
> >>  7 files changed, 212 insertions(+), 12 deletions(-)
> >>
> >> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> >> index 45b7a4094de0..eac7f8cf4ae0 100644
> >> --- a/arch/x86/include/asm/pgtable_64.h
> >> +++ b/arch/x86/include/asm/pgtable_64.h
> >> @@ -208,7 +208,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
> >>  					 ((type) << (SWP_TYPE_FIRST_BIT)) \
> >>  					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
> >>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
> >> +#define __pmd_to_swp_entry(pmd)		((swp_entry_t) { pmd_val((pmd)) })
> >>  #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
> >> +#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd = (x).val })
> >>
> >>  extern int kern_addr_valid(unsigned long addr);
> >>  extern void cleanup_highmap(void);
> >> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> >> index c5ff7b217ee6..ae0c5fc18788 100644
> >> --- a/include/linux/swapops.h
> >> +++ b/include/linux/swapops.h
> >> @@ -103,7 +103,8 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
> >>  #ifdef CONFIG_MIGRATION
> >>  static inline swp_entry_t make_migration_entry(struct page *page, int write)
> >>  {
> >> -	BUG_ON(!PageLocked(page));
> >> +	BUG_ON(!PageLocked(compound_head(page)));
> >> +
> >>  	return swp_entry(write ? SWP_MIGRATION_WRITE : SWP_MIGRATION_READ,
> >>  			page_to_pfn(page));
> >>  }
> >> @@ -126,7 +127,7 @@ static inline struct page *migration_entry_to_page(swp_entry_t entry)
> >>  	 * Any use of migration entries may only occur while the
> >>  	 * corresponding page is locked
> >>  	 */
> >> -	BUG_ON(!PageLocked(p));
> >> +	BUG_ON(!PageLocked(compound_head(p)));
> >>  	return p;
> >>  }
> >>
> >> @@ -163,6 +164,70 @@ static inline int is_write_migration_entry(swp_entry_t entry)
> >>
> >>  #endif
> >>
> >> +struct page_vma_mapped_walk;
> >> +
> >> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> >> +extern void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
> >> +		struct page *page);
> >> +
> >> +extern void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
> >> +		struct page *new);
> >> +
> >> +extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd);
> >> +
> >> +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
> >> +{
> >> +	swp_entry_t arch_entry;
> >> +
> >> +	arch_entry = __pmd_to_swp_entry(pmd);
> >> +	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
> >> +}
> >> +
> >> +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> >> +{
> >> +	swp_entry_t arch_entry;
> >> +
> >> +	arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
> >> +	return __swp_entry_to_pmd(arch_entry);
> >> +}
> >> +
> >> +static inline int is_pmd_migration_entry(pmd_t pmd)
> >> +{
> >> +	return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd));
> >> +}
> >> +#else
> >> +static inline void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
> >> +		struct page *page)
> >> +{
> >> +	BUILD_BUG();
> >> +}
> >> +
> >> +static inline void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
> >> +		struct page *new)
> >> +{
> >> +	BUILD_BUG();
> >> +}
> >> +
> >> +static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t *p) { }
> >> +
> >> +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
> >> +{
> >> +	BUILD_BUG();
> >> +	return swp_entry(0, 0);
> >> +}
> >> +
> >> +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> >> +{
> >> +	BUILD_BUG();
> >> +	return (pmd_t){ 0 };
> >> +}
> >> +
> >> +static inline int is_pmd_migration_entry(pmd_t pmd)
> >> +{
> >> +	return 0;
> >> +}
> >> +#endif
> >> +
> >>  #ifdef CONFIG_MEMORY_FAILURE
> >>
> >>  extern atomic_long_t num_poisoned_pages __read_mostly;
> >> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >> index 421631ff3aeb..d9405ba628f6 100644
> >> --- a/mm/huge_memory.c
> >> +++ b/mm/huge_memory.c
> >> @@ -1641,10 +1641,27 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >>  		spin_unlock(ptl);
> >>  		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
> >>  	} else {
> >> -		struct page *page = pmd_page(orig_pmd);
> >> -		page_remove_rmap(page, true);
> >> -		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> >> -		VM_BUG_ON_PAGE(!PageHead(page), page);
> >> +		struct page *page = NULL;
> >> +		int migration = 0;
> >> +
> >> +		if (pmd_present(orig_pmd)) {
> >> +			page = pmd_page(orig_pmd);
> >> +			page_remove_rmap(page, true);
> >> +			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> >> +			VM_BUG_ON_PAGE(!PageHead(page), page);
> >> +		} else {
> >> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> >
> > Can we have IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION) instead here and below?
> >
> 
> No. Both chunks have pmd_to_swp_entry(), which triggers BUILD_BUG()
> when CONFIG_ARCH_ENABLE_THP_MIGRATION is not set. So we need this macro
> to disable the code when THP migration is not enabled.

I would rather downgrade pmd_to_swp_entry() to nop than have this ifdefs.
But up to you.

> >> +			swp_entry_t entry;
> >> +
> >> +			VM_BUG_ON(!is_pmd_migration_entry(orig_pmd));
> >> +			entry = pmd_to_swp_entry(orig_pmd);
> >> +			page = pfn_to_page(swp_offset(entry));
> >> +			migration = 1;
> >
> > I guess something like 'flush_needed' instead would be more descriptive.
> 
> Will change the name.

Don't forget to revert the logic :P


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
