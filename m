Date: Thu, 24 Jan 2008 09:51:32 -0800
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [kvm-devel] [RFC][PATCH 3/5] ksm source code
Message-ID: <20080124175132.GR3627@sequoia.sous-sol.org>
References: <4794C477.3090708@qumranet.com> <20080124072432.GQ3627@sequoia.sous-sol.org> <4798554D.1010300@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4798554D.1010300@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: Chris Wright <chrisw@sous-sol.org>, kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

* Izik Eidus (izike@qumranet.com) wrote:
> Chris Wright wrote:
>>> 	list_add_tail(&slot->link, &ksm->slots);
>>
>> slots_lock?
>
> good catch, i forgat to put it here
>
>>> 	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
>>>     
>>
>> theoretical, but if threaded, registering program could do this
>> concurrently
>
> you talk here about the miss slots_lock?, i agree that it needed here

Yeah, I missed that slots_lock protects both.

>>> 	case KSM_REGISTER_MEMORY_REGION: {
>>> 		struct ksm_memory_region ksm_memory_region;
>>>
>>> 		r = -EFAULT;
>>> 		if (copy_from_user(&ksm_memory_region, argp,
>>> 				   sizeof ksm_memory_region))
>>
>> this doesn't look compat safe:
>>
>>  struct ksm_memory_region {
>>  	__u32 npages; /* number of pages to share */
>>  	__u64 addr; /* the begining of the virtual address */
>>  };
>
> why isnt it compat safe?

32-bit has more relaxed alignment requirement for __u64 (4 bytes)
than 64-bit (8 bytes).  choices are reverse the order or add padding
(can test by compiling structure in 32 and 64 bit).

>>> static int is_present_pte(struct mm_struct *mm, unsigned long addr)
>>> {
>>> 	pgd_t *pgd;
>>> 	pud_t *pud;
>>> 	pmd_t *pmd;
>>> 	pte_t *ptep;
>>> 	spinlock_t *ptl;
>>> 	int ret = 0;
>>>
>>> 	pgd = pgd_offset(mm, addr);
>>> 	if (!pgd_present(*pgd))
>>> 		goto out;
>>>
>>> 	pud = pud_offset(pgd, addr);
>>> 	if (!pud_present(*pud))
>>> 		goto out;
>>>
>>> 	pmd = pmd_offset(pud, addr);
>>> 	if (!pmd_present(*pmd))
>>> 		goto out;
>>>
>>> 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
>>> 	if (!ptep)
>>> 		goto out;
>>>
>>> 	if (pte_present(*ptep))
>>> 		ret = 1;
>>>
>>> 	pte_unmap_unlock(ptep, ptl);
>>> out:
>>> 	return ret;
>>> }
>>
>> This is generic helper.
>
> you recommended insert it to memory.c?

I think so, would help to convert another user.  But, as is typical in
this area, each have slightly different requirements.

>>> /*
>>>  * try_to_merge_one_page - take two pages and merge them into one
>>>  * note:
>>>  * oldpage should be anon page while newpage should be file mapped page
>>>  */
>>> static int try_to_merge_one_page(struct mm_struct *mm,
>>> 				 struct vm_area_struct *vma,
>>> 				 struct page *oldpage,
>>> 				 struct page *newpage,
>>> 				 pgprot_t newprot)
>>> {
>>> 	int ret = 0;
>>> 	unsigned long page_addr_in_vma;
>>> 	void *oldaddr, *newaddr;
>>>
>>> 	get_page(newpage);
>>> 	get_page(oldpage);
>>>
>>> 	down_write(&mm->mmap_sem);
>>>
>>> 	lock_two_pages(oldpage, newpage);
>>>
>>> 	page_addr_in_vma = addr_in_vma(vma, oldpage);
>>> 	if (page_addr_in_vma == -EFAULT)
>>> 		goto out_unlock;
>>>
>>> 	/*
>>> 	 * if the page is swapped or in swap cache, we cannot replace its pte
>>> 	 * we might want to run here swap_free in the future (it isnt exported)
>>> 	 */
>>> 	if (!is_present_pte(mm, page_addr_in_vma))
>>> 		goto out_unlock;
>>>
>>> 	if (!page_wrprotect(oldpage))
>>> 		goto out_unlock;
>>>
>>> 	oldaddr = kmap_atomic(oldpage, KM_USER0);
>>> 	newaddr = kmap_atomic(newpage, KM_USER1);
>>>
>>> 	ret = 1;
>>> 	if (!memcmp(oldaddr, newaddr, PAGE_SIZE))
>>> 		ret = replace_page(vma, oldpage, newpage, newprot);
>>>     
>>
>> Does it make sense to leave oldpage r/o if replace_page fails?
>
> the chance here that it wont be the same is very very low,
> but it could happen, and in this case we will have vmexit and pagefault + 
> copying of a page data for nothing

right

> it can be solved by adding to the rmap something like:
> page_writeble() tha will work the same as page_wrprotect() but will mark 
> the pte as write instead of readonly,
> the question is: if it wanted to the rmap code?

maybe it's overkill

>>> 	case KSM_CREATE_SCAN:
>>> 		r = ksm_dev_ioctl_create_scan();
>>>     
>> What's the value of having multiple scanners?
>> And how expensive is scanning?

> right now there is no real value in having multiple scanners, but the cost 
> for this design is nothing

yes, only cost is runtime, and if each guest launch would get stuck
behind a bunch of scanners.  since they need write access to add sma.
at least /dev/ksm being 0600 would keep it from DoS threat.

> in the future we might want to make each scanner to scan some limited areas 
> at a given speed...
>
> while(1) {
> r = ioctl(fd_scan, KSM_SCAN, 100);
> usleep(1000);
> }
>
> this scanner take 0-1% (more to 0...) of the memory in case it doesnt merge 
> anything (just to scan)
> it really take no cpu as far as it doesnt find any pages to merge,
> it should be noted that scanning should be slower than the above example,
> when a page to be merged is found the cpu usage grow a little bit beacuse 
> it now copy the data of the merged pages
>
> i will run few workload tests and report to you as soon as i will have 
> better information about this.

ok, thanks.
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
