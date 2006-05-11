Date: Thu, 11 May 2006 08:02:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
Message-Id: <20060511080220.48688b40.akpm@osdl.org>
In-Reply-To: <1147207458.27680.19.camel@lappy>
References: <1146861313.3561.13.camel@lappy>
	<445CA22B.8030807@cyberone.com.au>
	<1146922446.3561.20.camel@lappy>
	<445CA907.9060002@cyberone.com.au>
	<1146929357.3561.28.camel@lappy>
	<Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
	<1147116034.16600.2.camel@lappy>
	<Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
	<1147207458.27680.19.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: clameter@sgi.com, piggin@cyberone.com.au, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> 
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> People expressed the need to track dirty pages in shared mappings.
> 
> Linus outlined the general idea of doing that through making clean
> writable pages write-protected and taking the write fault.
> 
> This patch does exactly that, it makes pages in a shared writable
> mapping write-protected. On write-fault the pages are marked dirty and
> made writable. When the pages get synced with their backing store, the
> write-protection is re-instated.
> 
> It survives a simple test and shows the dirty pages in /proc/vmstat.

It'd be nice to have more that a "simple test" done.  Bugs in this area
will be subtle and will manifest in unpleasant ways.  That goes for both
correctness and performance bugs.

> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c	2006-05-08 18:49:39.000000000 +0200
> +++ linux-2.6/mm/memory.c	2006-05-09 09:15:11.000000000 +0200
> @@ -49,6 +49,7 @@
>  #include <linux/module.h>
>  #include <linux/init.h>
>  #include <linux/mm_page_replace.h>
> +#include <linux/backing-dev.h>
>  
>  #include <asm/pgalloc.h>
>  #include <asm/uaccess.h>
> @@ -2077,6 +2078,7 @@ static int do_no_page(struct mm_struct *
>  	unsigned int sequence = 0;
>  	int ret = VM_FAULT_MINOR;
>  	int anon = 0;
> +	struct page *dirty_page = NULL;
>  
>  	pte_unmap(page_table);
>  	BUG_ON(vma->vm_flags & VM_PFNMAP);
> @@ -2150,6 +2152,11 @@ retry:
>  		entry = mk_pte(new_page, vma->vm_page_prot);
>  		if (write_access)
>  			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		else if (VM_SharedWritable(vma)) {
> +			struct address_space *mapping = page_mapping(new_page);
> +			if (mapping && mapping_cap_account_dirty(mapping))
> +				entry = pte_wrprotect(entry);
> +		}
>  		set_pte_at(mm, address, page_table, entry);
>  		if (anon) {
>  			inc_mm_counter(mm, anon_rss);
> @@ -2159,6 +2166,10 @@ retry:
>  		} else {
>  			inc_mm_counter(mm, file_rss);
>  			page_add_file_rmap(new_page);
> +			if (write_access) {
> +				dirty_page = new_page;
> +				get_page(dirty_page);
> +			}

So let's see.  We take a write fault, we mark the page dirty then we return
to userspace which will proceed with the write and will mark the pte dirty.

Later, the VM will write the page out.

Later still, the pte will get cleaned by reclaim or by munmap or whatever
and the page will be marked dirty and the page will again be written out. 
Potentially needlessly.

How much extra IO will we be doing because of this change?

>  		return 0;
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c	2006-05-08 18:49:39.000000000 +0200
> +++ linux-2.6/mm/rmap.c	2006-05-08 18:53:34.000000000 +0200
> @@ -478,6 +478,72 @@ int page_referenced(struct page *page, i
>  	return referenced;
>  }
>  
> +static int page_wrprotect_one(struct page *page, struct vm_area_struct *vma)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	unsigned long address;
> +	pte_t *pte, entry;
> +	spinlock_t *ptl;
> +	int ret = 0;
> +
> +	address = vma_address(page, vma);
> +	if (address == -EFAULT)
> +		goto out;
> +
> +	pte = page_check_address(page, mm, address, &ptl);
> +	if (!pte)
> +		goto out;
> +
> +	if (!pte_write(*pte))
> +		goto unlock;
> +
> +	entry = pte_mkclean(pte_wrprotect(*pte));
> +	ptep_establish(vma, address, pte, entry);
> +	update_mmu_cache(vma, address, entry);
> +	lazy_mmu_prot_update(entry);
> +	ret = 1;
> +
> +unlock:
> +	pte_unmap_unlock(pte, ptl);
> +out:
> +	return ret;
> +}
> +
> +static int page_wrprotect_file(struct page *page)
> +{
> +	struct address_space *mapping = page->mapping;
> +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	struct vm_area_struct *vma;
> +	struct prio_tree_iter iter;
> +	int ret = 0;
> +
> +	BUG_ON(PageAnon(page));
> +
> +	spin_lock(&mapping->i_mmap_lock);
> +
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> +		if (VM_SharedWritable(vma))
> +			ret += page_wrprotect_one(page, vma);
> +	}
> +
> +	spin_unlock(&mapping->i_mmap_lock);
> +	return ret;
> +}
> +
> +int page_wrprotect(struct page *page)
> +{
> +	int ret = 0;
> +
> +	BUG_ON(!PageLocked(page));

hm.  So clear_page_dirty() and clear_page_dirty_for_io() are only ever
called against a locked page?  I guess that makes sense, but it's not a
guarantee which we had in the past.  It really _has_ to be true, because
lock_page() is the only thing which can protect the address_space from
memory reclaim in those two functions.

Oh well.  We'll find out if people's machines start to go BUG.

> +	if (page_mapped(page) && page->mapping) {

umm, afaict this function can be called for swapcache pages and Bad Things
will happen.  I think we need page_mapping(page) here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
