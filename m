Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lASGsKYq004003
	for <linux-mm@kvack.org>; Wed, 28 Nov 2007 11:54:20 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lASGsKx4454754
	for <linux-mm@kvack.org>; Wed, 28 Nov 2007 11:54:20 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lASGsJmk016931
	for <linux-mm@kvack.org>; Wed, 28 Nov 2007 11:54:20 -0500
Subject: Re: [RFC PATCH] LTTng instrumentation mm (using page_to_pfn)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071128140953.GA8018@Krystal>
References: <20071113193349.214098508@polymtl.ca>
	 <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost>
	 <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost>
	 <20071116143019.GA16082@Krystal> <1195495485.27759.115.camel@localhost>
	 <20071128140953.GA8018@Krystal>
Content-Type: text/plain
Date: Wed, 28 Nov 2007 08:54:16 -0800
Message-Id: <1196268856.18851.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-11-28 at 09:09 -0500, Mathieu Desnoyers wrote:
> ===================================================================
> --- linux-2.6-lttng.orig/mm/filemap.c	2007-11-28 08:38:46.000000000 -0500
> +++ linux-2.6-lttng/mm/filemap.c	2007-11-28 08:59:05.000000000 -0500
> @@ -514,9 +514,13 @@ void fastcall wait_on_page_bit(struct pa
>  {
>  	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
> 
> +	trace_mark(mm_filemap_wait_start, "pfn %lu", page_to_pfn(page));
> +
>  	if (test_bit(bit_nr, &page->flags))
>  		__wait_on_bit(page_waitqueue(page), &wait, sync_page,
>  							TASK_UNINTERRUPTIBLE);
> +
> +	trace_mark(mm_filemap_wait_end, "pfn %lu", page_to_pfn(page));
>  }
>  EXPORT_SYMBOL(wait_on_page_bit);

I've got some small nits with this.  I guess I just wish that if we're
going to sprinkle hooks all over that we'd have those hooks be as useful
as possible for people who have to look at them on a daily basis.

Do you also want to put in the page bit which is being waited on?

> 
> Index: linux-2.6-lttng/mm/memory.c
> ===================================================================
> --- linux-2.6-lttng.orig/mm/memory.c	2007-11-28 08:42:09.000000000 -0500
> +++ linux-2.6-lttng/mm/memory.c	2007-11-28 09:02:57.000000000 -0500
> @@ -2072,6 +2072,7 @@ static int do_swap_page(struct mm_struct
>  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
>  	page = lookup_swap_cache(entry);
>  	if (!page) {
> +		trace_mark(mm_swap_in, "pfn %lu", page_to_pfn(page));
>  		grab_swap_token(); /* Contend for token _before_ read-in */
>   		swapin_readahead(entry, address, vma);
>   		page = read_swap_cache_async(entry, vma, address);

How about putting the swap file number and the offset as well?

> @@ -2526,30 +2527,45 @@ unlock:
>  int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, int write_access)
>  {
> +	int res;
>  	pgd_t *pgd;
>  	pud_t *pud;
>  	pmd_t *pmd;
>  	pte_t *pte;
> 
> +	trace_mark(mm_handle_fault_entry, "address %lu ip #p%ld",
> +		address, KSTK_EIP(current));

For knowing this one, the write access can be pretty important.  It can
help you find copy-on-write situations as well as some common bugs that
creep in here. 

>  	__set_current_state(TASK_RUNNING);
> 
>  	count_vm_event(PGFAULT);
> 
> -	if (unlikely(is_vm_hugetlb_page(vma)))
> -		return hugetlb_fault(mm, vma, address, write_access);
> +	if (unlikely(is_vm_hugetlb_page(vma))) {
> +		res = hugetlb_fault(mm, vma, address, write_access);
> +		goto end;
> +	}

I think you should also add tracing to the hugetlb code while you're at
it.  Those poor fellows seem to be always getting left out these
days. :)

>  	pgd = pgd_offset(mm, address);
>  	pud = pud_alloc(mm, pgd, address);
> -	if (!pud)
> -		return VM_FAULT_OOM;
> +	if (!pud) {
> +		res = VM_FAULT_OOM;
> +		goto end;
> +	}
>  	pmd = pmd_alloc(mm, pud, address);
> -	if (!pmd)
> -		return VM_FAULT_OOM;
> +	if (!pmd) {
> +		res = VM_FAULT_OOM;
> +		goto end;
> +	}
>  	pte = pte_alloc_map(mm, pmd, address);
> -	if (!pte)
> -		return VM_FAULT_OOM;
> +	if (!pte) {
> +		res = VM_FAULT_OOM;
> +		goto end;
> +	}
> 
> -	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> +	res = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> +end:
> +	trace_mark(mm_handle_fault_exit, MARK_NOARGS);
> +	return res;
>  }
> 
>  #ifndef __PAGETABLE_PUD_FOLDED
> Index: linux-2.6-lttng/mm/page_alloc.c
> ===================================================================
> --- linux-2.6-lttng.orig/mm/page_alloc.c	2007-11-28 08:38:46.000000000 -0500
> +++ linux-2.6-lttng/mm/page_alloc.c	2007-11-28 09:05:36.000000000 -0500
> @@ -519,6 +519,9 @@ static void __free_pages_ok(struct page 
>  	int i;
>  	int reserved = 0;
> 
> +	trace_mark(mm_page_free, "order %u pfn %lu",
> +		order, page_to_pfn(page));
> +
>  	for (i = 0 ; i < (1 << order) ; ++i)
>  		reserved += free_pages_check(page + i);
>  	if (reserved)
> @@ -1639,6 +1642,8 @@ fastcall unsigned long __get_free_pages(
>  	page = alloc_pages(gfp_mask, order);
>  	if (!page)
>  		return 0;
> +	trace_mark(mm_page_alloc, "order %u pfn %lu",
> +		order, page_to_pfn(page));
>  	return (unsigned long) page_address(page);
>  }
> 
> Index: linux-2.6-lttng/mm/page_io.c
> ===================================================================
> --- linux-2.6-lttng.orig/mm/page_io.c	2007-11-28 08:38:47.000000000 -0500
> +++ linux-2.6-lttng/mm/page_io.c	2007-11-28 08:52:14.000000000 -0500
> @@ -114,6 +114,7 @@ int swap_writepage(struct page *page, st
>  		rw |= (1 << BIO_RW_SYNC);
>  	count_vm_event(PSWPOUT);
>  	set_page_writeback(page);
> +	trace_mark(mm_swap_out, "pfn %lu", page_to_pfn(page));
>  	unlock_page(page);
>  	submit_bio(rw, bio);

I'd also like to see the swap file number and the location in swap for
this one.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
