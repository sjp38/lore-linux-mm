Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 13E238D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:16:40 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 1/20]  1: mm: Move replace_page() to
 mm/memory.c
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110314133413.27435.67467.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133413.27435.67467.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 14 Mar 2011 10:16:35 -0400
Message-ID: <1300112195.9910.92.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 2011-03-14 at 19:04 +0530, Srikar Dronamraju wrote:
> User bkpt will use background page replacement approach to insert/delete
> breakpoints. Background page replacement approach is based on
> replace_page. Hence replace_page() loses its static attribute.
> 

Just a nitpick, but since replace_page() is being moved, could you
specify that in the change log. Something like:

"Hence, replace_page() is moved from ksm.c into memory.c and its static
attribute is removed."

I like to see in the change log "move x to y" when that is actually
done, because it is hard to see if anything actually changed when code
is moved. Ideally it is best to move code in one patch and make the
change in another. If you do cut another version of this patch set,
could you do that. This alone is not enough to require a new release.

Thanks,

-- Steve

> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> Signed-off-by: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> ---
>  include/linux/mm.h |    2 ++
>  mm/ksm.c           |   62 ----------------------------------------------------
>  mm/memory.c        |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 64 insertions(+), 62 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 679300c..01a0740 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -984,6 +984,8 @@ void account_page_writeback(struct page *page);
>  int set_page_dirty(struct page *page);
>  int set_page_dirty_lock(struct page *page);
>  int clear_page_dirty_for_io(struct page *page);
> +int replace_page(struct vm_area_struct *vma, struct page *page,
> +					struct page *kpage, pte_t orig_pte);
>  
>  /* Is the vma a continuation of the stack vma above it? */
>  static inline int vma_stack_continue(struct vm_area_struct *vma, unsigned long addr)
> diff --git a/mm/ksm.c b/mm/ksm.c
> index c2b2a94..f46e20d 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -765,68 +765,6 @@ out:
>  	return err;
>  }
>  
> -/**
> - * replace_page - replace page in vma by new ksm page
> - * @vma:      vma that holds the pte pointing to page
> - * @page:     the page we are replacing by kpage
> - * @kpage:    the ksm page we replace page by
> - * @orig_pte: the original value of the pte
> - *
> - * Returns 0 on success, -EFAULT on failure.
> - */
> -static int replace_page(struct vm_area_struct *vma, struct page *page,
> -			struct page *kpage, pte_t orig_pte)
> -{
> -	struct mm_struct *mm = vma->vm_mm;
> -	pgd_t *pgd;
> -	pud_t *pud;
> -	pmd_t *pmd;
> -	pte_t *ptep;
> -	spinlock_t *ptl;
> -	unsigned long addr;
> -	int err = -EFAULT;
> -
> -	addr = page_address_in_vma(page, vma);
> -	if (addr == -EFAULT)
> -		goto out;
> -
> -	pgd = pgd_offset(mm, addr);
> -	if (!pgd_present(*pgd))
> -		goto out;
> -
> -	pud = pud_offset(pgd, addr);
> -	if (!pud_present(*pud))
> -		goto out;
> -
> -	pmd = pmd_offset(pud, addr);
> -	BUG_ON(pmd_trans_huge(*pmd));
> -	if (!pmd_present(*pmd))
> -		goto out;
> -
> -	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
> -	if (!pte_same(*ptep, orig_pte)) {
> -		pte_unmap_unlock(ptep, ptl);
> -		goto out;
> -	}
> -
> -	get_page(kpage);
> -	page_add_anon_rmap(kpage, vma, addr);
> -
> -	flush_cache_page(vma, addr, pte_pfn(*ptep));
> -	ptep_clear_flush(vma, addr, ptep);
> -	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> -
> -	page_remove_rmap(page);
> -	if (!page_mapped(page))
> -		try_to_free_swap(page);
> -	put_page(page);
> -
> -	pte_unmap_unlock(ptep, ptl);
> -	err = 0;
> -out:
> -	return err;
> -}
> -
>  static int page_trans_compound_anon_split(struct page *page)
>  {
>  	int ret = 0;
> diff --git a/mm/memory.c b/mm/memory.c
> index 5823698..2a3021c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2669,6 +2669,68 @@ void unmap_mapping_range(struct address_space *mapping,
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
>  
> +/**
> + * replace_page - replace page in vma by new ksm page
> + * @vma:      vma that holds the pte pointing to page
> + * @page:     the page we are replacing by kpage
> + * @kpage:    the ksm page we replace page by
> + * @orig_pte: the original value of the pte
> + *
> + * Returns 0 on success, -EFAULT on failure.
> + */
> +int replace_page(struct vm_area_struct *vma, struct page *page,
> +			struct page *kpage, pte_t orig_pte)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *ptep;
> +	spinlock_t *ptl;
> +	unsigned long addr;
> +	int err = -EFAULT;
> +
> +	addr = page_address_in_vma(page, vma);
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
> +	BUG_ON(pmd_trans_huge(*pmd));
> +	if (!pmd_present(*pmd))
> +		goto out;
> +
> +	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	if (!pte_same(*ptep, orig_pte)) {
> +		pte_unmap_unlock(ptep, ptl);
> +		goto out;
> +	}
> +
> +	get_page(kpage);
> +	page_add_anon_rmap(kpage, vma, addr);
> +
> +	flush_cache_page(vma, addr, pte_pfn(*ptep));
> +	ptep_clear_flush(vma, addr, ptep);
> +	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> +
> +	page_remove_rmap(page);
> +	if (!page_mapped(page))
> +		try_to_free_swap(page);
> +	put_page(page);
> +
> +	pte_unmap_unlock(ptep, ptl);
> +	err = 0;
> +out:
> +	return err;
> +}
> +
>  int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
>  {
>  	struct address_space *mapping = inode->i_mapping;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
