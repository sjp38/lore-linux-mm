Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id BE2F76B0034
	for <linux-mm@kvack.org>; Sun, 11 Aug 2013 13:51:56 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 12 Aug 2013 03:40:57 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 874EC2CE8052
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 03:51:51 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7BHpeqH66584766
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 03:51:40 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7BHpoir030433
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 03:51:51 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 8/9] migrate: check movability of hugepage in unmap_and_move_huge_page()
In-Reply-To: <1376025702-14818-9-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1376025702-14818-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Sun, 11 Aug 2013 23:21:46 +0530
Message-ID: <87y588qfnx.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Currently hugepage migration works well only for pmd-based hugepages
> (mainly due to lack of testing,) so we had better not enable migration
> of other levels of hugepages until we are ready for it.
>
> Some users of hugepage migration (mbind, move_pages, and migrate_pages)
> do page table walk and check pud/pmd_huge() there, so they are safe.
> But the other users (softoffline and memory hotremove) don't do this,
> so without this patch they can try to migrate unexpected types of hugepages.
>
> To prevent this, we introduce hugepage_migration_support() as an architecture
> dependent check of whether hugepage are implemented on a pmd basis or not.
> And on some architecture multiple sizes of hugepages are available, so
> hugepage_migration_support() also checks hugepage size.
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  arch/arm/mm/hugetlbpage.c     |  5 +++++
>  arch/arm64/mm/hugetlbpage.c   |  5 +++++
>  arch/ia64/mm/hugetlbpage.c    |  5 +++++
>  arch/metag/mm/hugetlbpage.c   |  5 +++++
>  arch/mips/mm/hugetlbpage.c    |  5 +++++
>  arch/powerpc/mm/hugetlbpage.c | 10 ++++++++++
>  arch/s390/mm/hugetlbpage.c    |  5 +++++
>  arch/sh/mm/hugetlbpage.c      |  5 +++++
>  arch/sparc/mm/hugetlbpage.c   |  5 +++++
>  arch/tile/mm/hugetlbpage.c    |  5 +++++
>  arch/x86/mm/hugetlbpage.c     |  8 ++++++++
>  include/linux/hugetlb.h       | 12 ++++++++++++
>  mm/migrate.c                  | 10 ++++++++++
>  13 files changed, 85 insertions(+)
>
> diff --git v3.11-rc3.orig/arch/arm/mm/hugetlbpage.c v3.11-rc3/arch/arm/mm/hugetlbpage.c
> index 3d1e4a2..3f3b6a7 100644
> --- v3.11-rc3.orig/arch/arm/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/arm/mm/hugetlbpage.c
> @@ -99,3 +99,8 @@ int pmd_huge(pmd_t pmd)
>  {
>  	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
>  }
> +
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
> diff --git v3.11-rc3.orig/arch/arm64/mm/hugetlbpage.c v3.11-rc3/arch/arm64/mm/hugetlbpage.c
> index 2fc8258..5e9aec3 100644
> --- v3.11-rc3.orig/arch/arm64/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/arm64/mm/hugetlbpage.c
> @@ -54,6 +54,11 @@ int pud_huge(pud_t pud)
>  	return !(pud_val(pud) & PUD_TABLE_BIT);
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
> +
>  static __init int setup_hugepagesz(char *opt)
>  {
>  	unsigned long ps = memparse(opt, &opt);
> diff --git v3.11-rc3.orig/arch/ia64/mm/hugetlbpage.c v3.11-rc3/arch/ia64/mm/hugetlbpage.c
> index 76069c1..68232db 100644
> --- v3.11-rc3.orig/arch/ia64/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/ia64/mm/hugetlbpage.c
> @@ -114,6 +114,11 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 0;
> +}
> +
>  struct page *
>  follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
>  {
> diff --git v3.11-rc3.orig/arch/metag/mm/hugetlbpage.c v3.11-rc3/arch/metag/mm/hugetlbpage.c
> index 3c52fa6..0424315 100644
> --- v3.11-rc3.orig/arch/metag/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/metag/mm/hugetlbpage.c
> @@ -110,6 +110,11 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
> +
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.11-rc3.orig/arch/mips/mm/hugetlbpage.c v3.11-rc3/arch/mips/mm/hugetlbpage.c
> index a7fee0d..01fda44 100644
> --- v3.11-rc3.orig/arch/mips/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/mips/mm/hugetlbpage.c
> @@ -85,6 +85,11 @@ int pud_huge(pud_t pud)
>  	return (pud_val(pud) & _PAGE_HUGE) != 0;
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
> +
>  struct page *
>  follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  		pmd_t *pmd, int write)
> diff --git v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
> index 834ca8e..d67db4b 100644
> --- v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
> @@ -86,6 +86,11 @@ int pgd_huge(pgd_t pgd)
>  	 */
>  	return ((pgd_val(pgd) & 0x3) != 0x0);
>  }
> +
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
>  #else
>  int pmd_huge(pmd_t pmd)
>  {
> @@ -101,6 +106,11 @@ int pgd_huge(pgd_t pgd)
>  {
>  	return 0;
>  }
> +
> +int pmd_huge_support(void)
> +{
> +	return 0;
> +}
>  #endif
>
>  pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
> diff --git v3.11-rc3.orig/arch/s390/mm/hugetlbpage.c v3.11-rc3/arch/s390/mm/hugetlbpage.c
> index 121089d..951ee25 100644
> --- v3.11-rc3.orig/arch/s390/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/s390/mm/hugetlbpage.c
> @@ -117,6 +117,11 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
> +
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmdp, int write)
>  {
> diff --git v3.11-rc3.orig/arch/sh/mm/hugetlbpage.c v3.11-rc3/arch/sh/mm/hugetlbpage.c
> index d776234..0d676a4 100644
> --- v3.11-rc3.orig/arch/sh/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/sh/mm/hugetlbpage.c
> @@ -83,6 +83,11 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 0;
> +}
> +
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.11-rc3.orig/arch/sparc/mm/hugetlbpage.c v3.11-rc3/arch/sparc/mm/hugetlbpage.c
> index d2b5944..9639964 100644
> --- v3.11-rc3.orig/arch/sparc/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/sparc/mm/hugetlbpage.c
> @@ -234,6 +234,11 @@ int pud_huge(pud_t pud)
>  	return 0;
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 0;
> +}
> +
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.11-rc3.orig/arch/tile/mm/hugetlbpage.c v3.11-rc3/arch/tile/mm/hugetlbpage.c
> index 650ccff..0ac3599 100644
> --- v3.11-rc3.orig/arch/tile/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/tile/mm/hugetlbpage.c
> @@ -198,6 +198,11 @@ int pud_huge(pud_t pud)
>  	return !!(pud_val(pud) & _PAGE_HUGE_PAGE);
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
> +
>  struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  			     pmd_t *pmd, int write)
>  {
> diff --git v3.11-rc3.orig/arch/x86/mm/hugetlbpage.c v3.11-rc3/arch/x86/mm/hugetlbpage.c
> index 7e73e8c..9d980d8 100644
> --- v3.11-rc3.orig/arch/x86/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/x86/mm/hugetlbpage.c
> @@ -59,6 +59,10 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  	return NULL;
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 0;
> +}
>  #else
>
>  struct page *
> @@ -77,6 +81,10 @@ int pud_huge(pud_t pud)
>  	return !!(pud_val(pud) & _PAGE_PSE);
>  }
>
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}
>  #endif
>
>  /* x86_64 also uses this file */
> diff --git v3.11-rc3.orig/include/linux/hugetlb.h v3.11-rc3/include/linux/hugetlb.h
> index 2e02c4e..0393270 100644
> --- v3.11-rc3.orig/include/linux/hugetlb.h
> +++ v3.11-rc3/include/linux/hugetlb.h
> @@ -381,6 +381,16 @@ static inline pgoff_t basepage_index(struct page *page)
>
>  extern void dissolve_free_huge_pages(unsigned long start_pfn,
>  				     unsigned long end_pfn);
> +int pmd_huge_support(void);
> +/*
> + * Currently hugepage migration is enabled only for pmd-based hugepage.
> + * This function will be updated when hugepage migration is more widely
> + * supported.
> + */
> +static inline int hugepage_migration_support(struct hstate *h)
> +{
> +	return pmd_huge_support() && (huge_page_shift(h) == PMD_SHIFT);
> +}
>

For pmd_huge_support to be true, it needs huge_page_shift == PMD-SHIFT
right ? So why check again ?  Also are we only supporting hugepage migration
for hugepages at PMD level ? Why not at other levels ? Also isn't it
better to use zone movable allocation for larger size hugepags ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
