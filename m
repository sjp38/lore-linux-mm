Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 016596B005A
	for <linux-mm@kvack.org>; Wed,  8 May 2013 16:04:55 -0400 (EDT)
Date: Wed, 8 May 2013 13:04:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/THP: Use the right function when updating access
 flags
Message-Id: <20130508130454.8b0d87cfb9273227c9a9dabf@linux-foundation.org>
In-Reply-To: <1367873388-12338-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367873388-12338-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: aarcange@redhat.com, linux-mm@kvack.org

On Tue,  7 May 2013 02:19:48 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We should use pmdp_set_access_flags to update access flags. Archs like powerpc
> use extra checks(_PAGE_BUSY) when updating a hugepage PTE. A set_pmd_at doesn't
> do those checks. We should use set_pmd_at only when updating a none hugepage PTE.
> 
> ...
>
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1265,7 +1265,9 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  		 * young bit, instead of the current set_pmd_at.
>  		 */
>  		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
> -		set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmd, _pmd);
> +		if (pmdp_set_access_flags(vma, addr & HPAGE_PMD_MASK,
> +					  pmd, _pmd,  1))
> +			update_mmu_cache_pmd(vma, addr, pmd);
>  	}
>  	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
>  		if (page->mapping && trylock_page(page)) {

<canned message>
When writing a changelog, please describe the end-user-visible effects
of the bug, so that others can more easily decide which kernel
version(s) should be fixed, and so that downstream kernel maintainers
can more easily work out whether this patch will fix a problem which
they or their customers are observing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
