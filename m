Message-ID: <46D66E31.9030202@yahoo.com.au>
Date: Thu, 30 Aug 2007 17:13:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Selective swap out of processes
References: <1188320070.11543.85.camel@bastion-laptop>	 <46D4DBF7.7060102@yahoo.com.au>  <1188383827.11270.36.camel@bastion-laptop> <1188410818.9682.2.camel@bastion-laptop>
In-Reply-To: <1188410818.9682.2.camel@bastion-laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?UTF-8?B?SmF2aWVyIENhYmV6YXMg77+9?= <jcabezas@ac.upc.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Javier Cabezas RodrA-guez wrote:
>>My code calls the following function for each VMA of the process.  Are
>>there errors in the function?:
> 
> 
> Sorry. I forgot some lines:
> 
> int my_free_pages(struct vm_area_struct * vma, struct mm_struct * mm)
> {
> 	LIST_HEAD(page_list);
> 	unsigned long nr_taken;
> 	struct zone * zone = NULL;
> 	int ret;
> 	pte_t *pte_k;
> 	pud_t *pud;
> 	pmd_t *pmd;
> 	unsigned long addr;
> 	struct page * p;
> 	struct scan_control sc;
> 
> 	sc.gfp_mask = __GFP_FS;
> 	sc.may_swap = 1;
> 	sc.may_writepage = 1;
> 
> 	for (addr = vma->vm_start, nr_taken = 0; addr < vma->vm_end; addr +=
> PAGE_SIZE, nr_taken++) {
> 		pgd_t *pgd = pgd_offset(mm, addr);
> 		if (pgd_none(*pgd))
> 			return;
> 		pud = pud_offset(pgd, addr);
> 		if (pud_none(*pud))
> 			return;
> 		pmd = pmd_offset(pud, addr);
> 		if (pmd_none(*pmd))
> 			return;
> 		if (pmd_large(*pmd))
> 			pte_k = (pte_t *)pmd;
> 		else
> 			pte_k = pte_offset_kernel(pmd, addr);
> 
> 		if (pte_k && pte_present(*pte_k)) {
> 			p = pte_page(*pte_k);
> 			if (!zone)
> 				zone = page_zone(p);
> 
> 			ptep_clear_flush_young(vma, addr, pte_k);
> 			del_page_from_lru(zone, p);
> 			list_add(&p->lru, &page_list);
> 		}
> 	}
> 
> 	spin_lock_irq(&zone->lru_lock);
> 	__mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
> 	zone->pages_scanned += nr_taken;
> 	spin_unlock_irq(&zone->lru_lock);
> 
> 	printk("VMC: %lu pages set to be freed\n", nr_taken);
> 	printk("VMC: %d pages freed\n", ret =
> shrink_page_list_vmswap(&page_list, &sc, PAGEOUT_IO_SYNC));
> }

I don't know if that's right or not really, without more context,
but it doesn't look like you have the right page table walking
locking or page refcounting (and you probably don't want to simply
be returning when you encounter the first empty page table entry).

Anyway. I'd be inclined to not do your own page table walking at
this stage and begin by using get_user_pages() to do it for you.
Then if you get to the stage of wanting to optimise it, you could
copy the get_user_pages code, and use that as a starting point.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
