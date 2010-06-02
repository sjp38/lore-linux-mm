Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 554E16B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 14:17:02 -0400 (EDT)
Date: Wed, 2 Jun 2010 11:16:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/8] hugetlb, rmap: add reverse mapping for hugepage
Message-Id: <20100602111617.0c292178.akpm@linux-foundation.org>
In-Reply-To: <1275006562-18946-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1275006562-18946-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010 09:29:16 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> +#ifdef CONFIG_HUGETLBFS
> +/*
> + * The following three functions are for anonymous (private mapped) hugepages.
> + * Unlike common anonymous pages, anonymous hugepages have no accounting code
> + * and no lru code, because we handle hugepages differently from common pages.
> + */
> +static void __hugepage_set_anon_rmap(struct page *page,
> +	struct vm_area_struct *vma, unsigned long address, int exclusive)
> +{
> +	struct anon_vma *anon_vma = vma->anon_vma;
> +	BUG_ON(!anon_vma);
> +	if (!exclusive) {
> +		struct anon_vma_chain *avc;
> +		avc = list_entry(vma->anon_vma_chain.prev,
> +				 struct anon_vma_chain, same_vma);
> +		anon_vma = avc->anon_vma;
> +	}
> +	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> +	page->mapping = (struct address_space *) anon_vma;
> +	page->index = linear_page_index(vma, address);
> +}
> +
> +void hugepage_add_anon_rmap(struct page *page,
> +			    struct vm_area_struct *vma, unsigned long address)
> +{
> +	struct anon_vma *anon_vma = vma->anon_vma;
> +	int first;
> +	BUG_ON(!anon_vma);
> +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +	first = atomic_inc_and_test(&page->_mapcount);
> +	if (first)
> +		__hugepage_set_anon_rmap(page, vma, address, 0);
> +}
> +
> +void hugepage_add_new_anon_rmap(struct page *page,
> +			struct vm_area_struct *vma, unsigned long address)
> +{
> +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +	atomic_set(&page->_mapcount, 0);
> +	__hugepage_set_anon_rmap(page, vma, address, 1);
> +}
> +#endif /* CONFIG_HUGETLBFS */

This code still make sense if CONFIG_HUGETLBFS=n, I think?  Should it
instead depend on CONFIG_HUGETLB_PAGE?

I have a feeling that we make that confusion relatively often.  Perhaps
CONFIG_HUGETLB_PAGE=y && CONFIG_HUGETLBFS=n makes no sense and we
should unify them...  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
