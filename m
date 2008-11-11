Date: Tue, 11 Nov 2008 11:39:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] rmap: add page_wrprotect() function,
Message-Id: <20081111113948.f38b9e95.akpm@linux-foundation.org>
In-Reply-To: <1226409701-14831-2-git-send-email-ieidus@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<1226409701-14831-2-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008 15:21:38 +0200
Izik Eidus <ieidus@redhat.com> wrote:

> From: Izik Eidus <izike@qumranet.com>
> 
> this function is useful for cases you want to compare page and know
> that its value wont change during you compare it.
> 
> this function is working by walking over the whole rmap of a page
> and mark every pte related to the page as write_protect.
> 
> the odirect_sync paramter is used to notify the caller of
> page_wrprotect() if one pte or more was not marked readonly
> in order to avoid race with odirect.

The grammar is a bit mangled.  Missing apostrophes.  Sentences start
with capital letters.

Yeah, it's a nit, but we don't actually gain anything from deliberately
mangling the language.

>
> ...
>
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -576,6 +576,103 @@ int page_mkclean(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(page_mkclean);
>  
> +static int page_wrprotect_one(struct page *page, struct vm_area_struct *vma,
> +			      int *odirect_sync)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	unsigned long address;
> +	pte_t *pte;
> +	spinlock_t *ptl;
> +	int ret = 0;
> +
> +	address = vma_address(page, vma);
> +	if (address == -EFAULT)
> +		goto out;
> +
> +	pte = page_check_address(page, mm, address, &ptl, 0);
> +	if (!pte)
> +		goto out;
> +
> +	if (pte_write(*pte)) {
> +		pte_t entry;
> +
> +		if (page_mapcount(page) != page_count(page)) {
> +			*odirect_sync = 0;
> +			goto out_unlock;
> +		}
> +		flush_cache_page(vma, address, pte_pfn(*pte));
> +		entry = ptep_clear_flush_notify(vma, address, pte);
> +		entry = pte_wrprotect(entry);
> +		set_pte_at(mm, address, pte, entry);
> +	}
> +	ret = 1;
> +
> +out_unlock:
> +	pte_unmap_unlock(pte, ptl);
> +out:
> +	return ret;
> +}

OK.  I think.  We need to find a way of provoking Hugh to look at it.

> +static int page_wrprotect_file(struct page *page, int *odirect_sync)
> +{
> +	struct address_space *mapping;
> +	struct prio_tree_iter iter;
> +	struct vm_area_struct *vma;
> +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	int ret = 0;
> +
> +	mapping = page_mapping(page);

What pins *mapping in memory?  Usually this is done by requiring that
the caller has locked the page.  But no such precondition is documented
here.

> +	if (!mapping)
> +		return ret;
> +
> +	spin_lock(&mapping->i_mmap_lock);
> +
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
> +		ret += page_wrprotect_one(page, vma, odirect_sync);
> +
> +	spin_unlock(&mapping->i_mmap_lock);
> +
> +	return ret;
> +}
> +
> +static int page_wrprotect_anon(struct page *page, int *odirect_sync)
> +{
> +	struct vm_area_struct *vma;
> +	struct anon_vma *anon_vma;
> +	int ret = 0;
> +
> +	anon_vma = page_lock_anon_vma(page);
> +	if (!anon_vma)
> +		return ret;
> +
> +	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
> +		ret += page_wrprotect_one(page, vma, odirect_sync);
> +
> +	page_unlock_anon_vma(anon_vma);
> +
> +	return ret;
> +}
> +
> +/**

This token means "this is a kerneldoc comment".

> + * set all the ptes pointed to a page as read only,
> + * odirect_sync is set to 0 in case we cannot protect against race with odirect
> + * return the number of ptes that were set as read only
> + * (ptes that were read only before this function was called are couned as well)
> + */

But it isn't.

I don't understand this odirect_sync thing.  What race?  Please expand
this comment to make the function of odirect_sync more understandable.

> +int page_wrprotect(struct page *page, int *odirect_sync)
> +{
> +	int ret =0;
> +
> +	*odirect_sync = 1;
> +	if (PageAnon(page))
> +		ret = page_wrprotect_anon(page, odirect_sync);
> +	else
> +		ret = page_wrprotect_file(page, odirect_sync);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(page_wrprotect);

What do you think about making all this new code dependent upon some
CONFIG_ switch which CONFIG_KVM can select?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
