Date: Tue, 11 Nov 2008 11:45:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
Message-Id: <20081111114555.eb808843.akpm@linux-foundation.org>
In-Reply-To: <1226409701-14831-3-git-send-email-ieidus@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<1226409701-14831-2-git-send-email-ieidus@redhat.com>
	<1226409701-14831-3-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008 15:21:39 +0200
Izik Eidus <ieidus@redhat.com> wrote:

> From: Izik Eidus <izike@qumranet.com>
> 
> this function is needed in cases you want to change the userspace
> virtual mapping into diffrent physical page,

Not sure that I understand that description.  We want to replace a live
page in an anonymous VMA with a different one?

It looks that way.

page migration already kinda does that.  Is there common ground?

> KSM need this for merging the identical pages.
> 
> this function is working by removing the oldpage from the rmap and
> calling put_page on it, and by setting the virtual address pte
> to point into the new page.
> (note that the new page (the page that we change the pte to map to)
> cannot be anonymous page)
> 

I don't understand the restrictions on anonymous pages.  Please expand
the changelog so that reviewers can understand the reasons for this
restriction.


> ---
>  include/linux/mm.h |    3 ++
>  mm/memory.c        |   68 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 71 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ffee2f7..4da7fa8 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1207,6 +1207,9 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>  			unsigned long pfn);
>  
> +int replace_page(struct vm_area_struct *vma, struct page *oldpage,
> +		 struct page *newpage, pte_t orig_pte, pgprot_t prot);
> +
>  struct page *follow_page(struct vm_area_struct *, unsigned long address,
>  			unsigned int foll_flags);
>  #define FOLL_WRITE	0x01	/* check pte is writable */
> diff --git a/mm/memory.c b/mm/memory.c
> index 164951c..b2c542c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1472,6 +1472,74 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_mixed);
>  
> +/**
> + * replace _page - replace the pte mapping related to vm area between two pages

s/replace _page/replace_page/

> + * (from oldpage to newpage)
> + * NOTE: you should take into consideration the impact on the VM when replacing
> + * anonymous pages with kernel non swappable pages.
> + */

This _is_ a kerneldoc comment, but kernedoc comments conventionally
document the arguments and the return value also.

> +int replace_page(struct vm_area_struct *vma, struct page *oldpage,
> +		 struct page *newpage, pte_t orig_pte, pgprot_t prot)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *ptep;
> +	spinlock_t *ptl;
> +	unsigned long addr;
> +	int ret;
> +
> +	BUG_ON(PageAnon(newpage));
> +
> +	ret = -EFAULT;
> +	addr = page_address_in_vma(oldpage, vma);
> +	if (addr == -EFAULT)
> +		goto out;
> +
> +	pgd = pgd_offset(mm, addr);
> +	if (!pgd_present(*pgd))
> +		goto out;
> +
> +	pud = pud_offset(pgd, addr);
> +	if (!pud_present(*pud))
> +		goto out;
> +
> +	pmd = pmd_offset(pud, addr);
> +	if (!pmd_present(*pmd))
> +		goto out;
> +
> +	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	if (!ptep)
> +		goto out;
> +
> +	if (!pte_same(*ptep, orig_pte)) {
> +		pte_unmap_unlock(ptep, ptl);
> +		goto out;
> +	}
> +
> +	ret = 0;
> +	get_page(newpage);
> +	page_add_file_rmap(newpage);
> +
> +	flush_cache_page(vma, addr, pte_pfn(*ptep));
> +	ptep_clear_flush(vma, addr, ptep);
> +	set_pte_at(mm, addr, ptep, mk_pte(newpage, prot));
> +
> +	page_remove_rmap(oldpage, vma);
> +	if (PageAnon(oldpage)) {
> +		dec_mm_counter(mm, anon_rss);
> +		inc_mm_counter(mm, file_rss);
> +	}
> +	put_page(oldpage);
> +
> +	pte_unmap_unlock(ptep, ptl);
> +
> +out:
> +	return ret;
> +}
> +EXPORT_SYMBOL(replace_page);

Again, we could make the presence of this code selectable by subsystems
which want it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
