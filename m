Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC716B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 09:50:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so39482175wmw.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 06:50:34 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id o10si2212689lbp.203.2016.04.27.06.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 06:50:32 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id c126so57362155lfb.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 06:50:32 -0700 (PDT)
Date: Wed, 27 Apr 2016 16:50:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/1] mm: thp: kvm: fix memory corruption in KVM with THP
 enabled
Message-ID: <20160427135030.GB22035@node.shutemov.name>
References: <1461758686-27157-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461758686-27157-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, Amit Shah <amit.shah@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>

On Wed, Apr 27, 2016 at 02:04:46PM +0200, Andrea Arcangeli wrote:
> After the THP refcounting change, obtaining a compound pages from
> get_user_pages() no longer allows us to assume the entire compound
> page is immediately mappable from a secondary MMU.
> 
> A secondary MMU doesn't want to call get_user_pages() more than once
> for each compound page, in order to know if it can map the whole
> compound page. So a secondary MMU needs to know from a single
> get_user_pages() invocation when it can map immediately the entire
> compound page to avoid a flood of unnecessary secondary MMU faults and
> spurious atomic_inc()/atomic_dec() (pages don't have to be pinned by
> MMU notifier users).
> 
> Ideally instead of the page->_mapcount < 1 check, get_user_pages()
> should return the granularity of the "page" mapping in the "mm" passed
> to get_user_pages(). However it's non trivial change to pass the "pmd"
> status belonging to the "mm" walked by get_user_pages up the stack (up
> to the caller of get_user_pages). So the fix just checks if there is
> not a single pte mapping on the page returned by get_user_pages, and
> in turn if the caller can assume that the whole compound page is
> mapped in the current "mm" (in a pmd_trans_huge()). In such case the
> entire compound page is safe to map into the secondary MMU without
> additional get_user_pages() calls on the surrounding tail/head
> pages. In addition of being faster, not having to run other
> get_user_pages() calls also reduces the memory footprint of the
> secondary MMU fault in case the pmd split happened as result of memory
> pressure.
> 
> Without this fix after a MADV_DONTNEED (like invoked by QEMU during
> postcopy live migration or balloning) or after generic swapping (with
> a failure in split_huge_page() that would only result in pmd splitting
> and not a physical page split), KVM would map the whole compound page
> into the shadow pagetables, despite regular faults or userfaults (like
> UFFDIO_COPY) may map regular pages into the primary MMU as result of
> the pte faults, leading to the guest mode and userland mode going out
> of sync and not working on the same memory at all times.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  arch/arm/kvm/mmu.c         |  2 +-
>  arch/x86/kvm/mmu.c         |  4 ++--
>  include/linux/page-flags.h | 22 ++++++++++++++++++++++
>  3 files changed, 25 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm/kvm/mmu.c b/arch/arm/kvm/mmu.c
> index 58dbd5c..d6d4191 100644
> --- a/arch/arm/kvm/mmu.c
> +++ b/arch/arm/kvm/mmu.c
> @@ -1004,7 +1004,7 @@ static bool transparent_hugepage_adjust(kvm_pfn_t *pfnp, phys_addr_t *ipap)
>  	kvm_pfn_t pfn = *pfnp;
>  	gfn_t gfn = *ipap >> PAGE_SHIFT;
>  
> -	if (PageTransCompound(pfn_to_page(pfn))) {
> +	if (PageTransCompoundMap(pfn_to_page(pfn))) {
>  		unsigned long mask;
>  		/*
>  		 * The address we faulted on is backed by a transparent huge
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 1ff4dbb..b6f50e8 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -2823,7 +2823,7 @@ static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
>  	 */
>  	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn) &&
>  	    level == PT_PAGE_TABLE_LEVEL &&
> -	    PageTransCompound(pfn_to_page(pfn)) &&
> +	    PageTransCompoundMap(pfn_to_page(pfn)) &&
>  	    !mmu_gfn_lpage_is_disallowed(vcpu, gfn, PT_DIRECTORY_LEVEL)) {
>  		unsigned long mask;
>  		/*
> @@ -4785,7 +4785,7 @@ restart:
>  		 */
>  		if (sp->role.direct &&
>  			!kvm_is_reserved_pfn(pfn) &&
> -			PageTransCompound(pfn_to_page(pfn))) {
> +			PageTransCompoundMap(pfn_to_page(pfn))) {
>  			drop_spte(kvm, sptep);
>  			need_tlb_flush = 1;
>  			goto restart;
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index f4ed4f1b..6b052aa 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -517,6 +517,27 @@ static inline int PageTransCompound(struct page *page)
>  }
>  
>  /*
> + * PageTransCompoundMap is the same as PageTransCompound, but it also
> + * guarantees the primary MMU has the entire compound page mapped
> + * through pmd_trans_huge, which in turn guarantees the secondary MMUs
> + * can also map the entire compound page. This allows the secondary
> + * MMUs to call get_user_pages() only once for each compound page and
> + * to immediately map the entire compound page with a single secondary
> + * MMU fault. If there will be a pmd split later, the secondary MMUs
> + * will get an update through the MMU notifier invalidation through
> + * split_huge_pmd().
> + *
> + * Unlike PageTransCompound, this is safe to be called only while
> + * split_huge_pmd() cannot run from under us, like if protected by the
> + * MMU notifier, otherwise it may result in page->_mapcount < 0 false
> + * positives.
> + */

I know nothing about kvm. How do you protect against pmd splitting between
get_user_pages() and the check?

And the helper looks highly kvm-specific, doesn't it?

> +static inline int PageTransCompoundMap(struct page *page)
> +{
> +	return PageTransCompound(page) && atomic_read(&page->_mapcount) < 0;
> +}
> +
> +/*
>   * PageTransTail returns true for both transparent huge pages
>   * and hugetlbfs pages, so it should only be called when it's known
>   * that hugetlbfs pages aren't involved.
> @@ -559,6 +580,7 @@ static inline int TestClearPageDoubleMap(struct page *page)
>  #else
>  TESTPAGEFLAG_FALSE(TransHuge)
>  TESTPAGEFLAG_FALSE(TransCompound)
> +TESTPAGEFLAG_FALSE(TransCompoundMap)
>  TESTPAGEFLAG_FALSE(TransTail)
>  TESTPAGEFLAG_FALSE(DoubleMap)
>  	TESTSETFLAG_FALSE(DoubleMap)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
