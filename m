Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3CCD75F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 18:37:49 -0400 (EDT)
Message-ID: <49E661A5.8050305@redhat.com>
Date: Thu, 16 Apr 2009 01:37:25 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com>	<1239249521-5013-2-git-send-email-ieidus@redhat.com>	<1239249521-5013-3-git-send-email-ieidus@redhat.com>	<1239249521-5013-4-git-send-email-ieidus@redhat.com>	<1239249521-5013-5-git-send-email-ieidus@redhat.com> <20090414150929.174a9b25.akpm@linux-foundation.org>
In-Reply-To: <20090414150929.174a9b25.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu,  9 Apr 2009 06:58:41 +0300
> Izik Eidus <ieidus@redhat.com> wrote:
>
>   
>
> Confused.  In the covering email you indicated that v2 of the patchset
> had abandoned ioctls and had moved the interface to sysfs.
>   
We have abandoned the ioctls that control the ksm behavior (how much cpu 
it take, how much kernel pages it may allocate and so on...)
But we still use ioctls to register the application memory to be used 
with ksm.

> It would be good to completely (and briefly) describe KSM's proposed
> userspace intefaces in the changelog or somewhere.  I'm a bit confused.
>   

I will post new clean description for the ksm api with V4.

>
>
>   
>>
>> +static pte_t *get_pte(struct mm_struct *mm, unsigned long addr)
>> +{
>> +	pgd_t *pgd;
>> +	pud_t *pud;
>> +	pmd_t *pmd;
>> +	pte_t *ptep = NULL;
>> +
>> +	pgd = pgd_offset(mm, addr);
>> +	if (!pgd_present(*pgd))
>> +		goto out;
>> +
>> +	pud = pud_offset(pgd, addr);
>> +	if (!pud_present(*pud))
>> +		goto out;
>> +
>> +	pmd = pmd_offset(pud, addr);
>> +	if (!pmd_present(*pmd))
>> +		goto out;
>> +
>> +	ptep = pte_offset_map(pmd, addr);
>> +out:
>> +	return ptep;
>> +}
>>     
>
> hm, this looks very generic.  Does it duplicate anything which core
> kernel already provides? 

I dont think so.

>  If not, perhaps core kernel should provide
> this (perhaps after some reorganisation).
>   

Quick grep on the code show me at least 2 places that can use this function
one is:
remove_migration_pte() inside migrate.c
and the other is:
page_check_address() inside rmap.c

I will post with V4 an inline get_ptep() function, worst case i will get 
nacked.

>   
>> ...
>>
>> +static int rmap_hash_init(void)
>> +{
>> +	if (!rmap_hash_size) {
>> +		struct sysinfo sinfo;
>> +
>> +		si_meminfo(&sinfo);
>> +		rmap_hash_size = sinfo.totalram / 10;
>>     
>
> One slot per ten pages of physical memory?  Is this too large, too
> small or just right?
>   

Highly depend on the number of processes / memory regions that will be 
registered inside ksm
It is a module parameter and so user can change it to how much it want.

>   
>> +	}
>> +	nrmaps_hash = rmap_hash_size;
>> +	rmap_hash = vmalloc(nrmaps_hash * sizeof(struct hlist_head));
>> +	if (!rmap_hash)
>> +		return -ENOMEM;
>> +	memset(rmap_hash, 0, nrmaps_hash * sizeof(struct hlist_head));
>> +	return 0;
>> +}
>> +
>>
>> ...
>>
>> +static void break_cow(struct mm_struct *mm, unsigned long addr)
>> +{
>> +	struct page *page[1];
>> +
>> +	down_read(&mm->mmap_sem);
>> +	if (get_user_pages(current, mm, addr, 1, 1, 0, page, NULL)) {
>> +			put_page(page[0]);
>> +	}
>> +	up_read(&mm->mmap_sem);
>> +}
>>     
>
> - unneeded brakes around single statement
>
> - that single statement is over-indented.
>
> - and it seems wrong.  If get_user_pages() returned, say, -ENOMEM, we
>   end up doing put_page(random-uninitialised-address-from-stack-go-oops)?
>   

Good catch.

>   
>> ...
>>
>> +static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
>> +						struct ksm_memory_region *mem)
>> +{
>> +	struct ksm_mem_slot *slot;
>> +	int ret = -EPERM;
>> +
>> +	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
>> +	if (!slot) {
>> +		ret = -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	slot->mm = get_task_mm(current);
>> +	if (!slot->mm)
>> +		goto out_free;
>> +	slot->addr = mem->addr;
>> +	slot->npages = mem->npages;
>> +
>> +	down_write(&slots_lock);
>> +
>> +	list_add_tail(&slot->link, &slots);
>> +	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
>> +
>> +	up_write(&slots_lock);
>> +	return 0;
>> +
>> +out_free:
>> +	kfree(slot);
>> +out:
>> +	return ret;
>> +}
>>     
>
> So this function pins the mm_struct.  I wonder what the implications of
> this are. 

The mm struct wont go away until the file will be closed... (Application 
close the file descriptor, or the Application die)

>  Not much, I guess.  Some comments in the code which explain
> the object lifecycles would be nice.
>
>   
>
>> ...
>>
>> +static int memcmp_pages(struct page *page1, struct page *page2)
>> +{
>> +	char *addr1, *addr2;
>> +	int r;
>> +
>> +	addr1 = kmap_atomic(page1, KM_USER0);
>> +	addr2 = kmap_atomic(page2, KM_USER1);
>> +	r = memcmp(addr1, addr2, PAGE_SIZE);
>> +	kunmap_atomic(addr1, KM_USER0);
>> +	kunmap_atomic(addr2, KM_USER1);
>> +	return r;
>> +}
>>     
>
> I wonder if this code all does enough cpu cache flushing to be able to
> guarantee that it's looking at valid data.  Not my area, and presumably
> not an issue on x86.
>   

Andrea pointed in previous reply that due to the fact that we are 
running page_wrprotect() on this pages memcmp_pages should be stable.

>   
>> ...
>>
>> +static int try_to_merge_one_page(struct mm_struct *mm,
>> +				 struct vm_area_struct *vma,
>> +				 struct page *oldpage,
>> +				 struct page *newpage,
>> +				 pgprot_t newprot)
>> +{
>> +	int ret = 1;
>> +	int odirect_sync;
>> +	unsigned long page_addr_in_vma;
>> +	pte_t orig_pte, *orig_ptep;
>> +
>> +	if (!PageAnon(oldpage))
>> +		goto out;
>> +
>> +	get_page(newpage);
>> +	get_page(oldpage);
>> +
>> +	down_read(&mm->mmap_sem);
>> +
>> +	page_addr_in_vma = addr_in_vma(vma, oldpage);
>> +	if (page_addr_in_vma == -EFAULT)
>> +		goto out_unlock;
>> +
>> +	orig_ptep = get_pte(mm, page_addr_in_vma);
>> +	if (!orig_ptep)
>> +		goto out_unlock;
>> +	orig_pte = *orig_ptep;
>> +	pte_unmap(orig_ptep);
>> +	if (!pte_present(orig_pte))
>> +		goto out_unlock;
>> +	if (page_to_pfn(oldpage) != pte_pfn(orig_pte))
>> +		goto out_unlock;
>> +	/*
>> +	 * we need the page lock to read a stable PageSwapCache in
>> +	 * page_wrprotect()
>> +	 */
>> +	if (!trylock_page(oldpage))
>> +		goto out_unlock;
>>     
>
> We need a comment here explaining why we can't use the much preferable
> lock_page().
>
> Why can't we use the much preferable lock_page()?
>   

We can, but i am not sure if we want, why block on I/O when we can just 
move into the next page?
(We will come to this page latter...)

>   
>> +	/*
>> +	 * page_wrprotect check if the page is swapped or in swap cache,
>> +	 * in the future we might want to run here if_present_pte and then
>> +	 * swap_free
>> +	 */
>> +	if (!page_wrprotect(oldpage, &odirect_sync, 2)) {
>> +		unlock_page(oldpage);
>> +		goto out_unlock;
>> +	}
>> +	unlock_page(oldpage);
>> +	if (!odirect_sync)
>> +		goto out_unlock;
>> +
>> +	orig_pte = pte_wrprotect(orig_pte);
>> +
>> +	if (pages_identical(oldpage, newpage))
>> +		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);
>> +
>> +out_unlock:
>> +	up_read(&mm->mmap_sem);
>> +	put_page(oldpage);
>> +	put_page(newpage);
>> +out:
>> +	return ret;
>> +}
>>
>> ...
>>
>> +static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
>> +					struct page *page1,
>> +					struct mm_struct *mm2,
>> +					struct page *page2,
>> +					unsigned long addr1,
>> +					unsigned long addr2)
>> +{
>> +	struct vm_area_struct *vma;
>> +	pgprot_t prot;
>> +	int ret = 1;
>> +	struct page *kpage;
>> +
>> +	/*
>> +	 * The number of the nodes inside the stable tree +
>> +	 * nkpage_out_tree is the same as the number kernel pages that
>> +	 * we hold.
>> +	 */
>> +	if (kthread_max_kernel_pages &&
>> +	    (nnodes_stable_tree + nkpage_out_tree) >=
>> +	    kthread_max_kernel_pages)
>> +		return ret;
>> +
>> +	kpage = alloc_page(GFP_HIGHUSER);
>> +	if (!kpage)
>> +		return ret;
>> +	down_read(&mm1->mmap_sem);
>> +	vma = find_vma(mm1, addr1);
>> +	up_read(&mm1->mmap_sem);
>> +	if (!vma) {
>> +		put_page(kpage);
>> +		return ret;
>> +	}
>> +	prot = vma->vm_page_prot;
>>     
>
> What locking protects *vma here?
>   

Good catch.

>   
>
>   
>> +	pgprot_val(prot) &= ~_PAGE_RW;
>> +	ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
>> +	if (!ret)
>> +		ksm_pages_shared++;
>> +
>> +	return ret;
>> +}
>> +
>> +/*
>> + * is_zapped_item - check if the page belong to the rmap_item was zapped.
>> + *
>> + * This function would check if the page that the virtual address inside
>> + * rmap_item is poiting to is still KsmPage, and therefore we can trust the
>> + * content of this page.
>> + * Since that this function call already to get_user_pages it return the
>> + * pointer to the page as an optimization.
>> + */
>> +static int is_zapped_item(struct rmap_item *rmap_item,
>> +			  struct page **page)
>> +{
>> +	int ret = 0;
>> +	struct vm_area_struct *vma;
>> +
>> +	cond_resched();
>> +	if (is_present_pte(rmap_item->mm, rmap_item->address)) {
>> +		down_read(&rmap_item->mm->mmap_sem);
>> +		vma = find_vma(rmap_item->mm, rmap_item->address);
>> +		if (vma && !vma->vm_file) {
>> +			BUG_ON(vma->vm_flags & VM_SHARED);
>> +			ret = get_user_pages(current, rmap_item->mm,
>> +					     rmap_item->address,
>> +					     1, 0, 0, page, NULL);
>> +		}
>> +		up_read(&rmap_item->mm->mmap_sem);
>> +	}
>> +
>> +	if (!ret)
>> +		return 1;
>>     
>
> Failed to check for get_user_pages() -ve return code?
>   
Right.

>   
>> +	if (unlikely(!PageKsm(page[0]))) { 
>> +		put_page(page[0]);
>> +		return 1;
>> +	}
>> +	return 0;
>> +}
>> +
>>
>> ...
>>
>> +static struct tree_item *unstable_tree_search_insert(struct page *page,
>> +					struct page **page2,
>> +					struct rmap_item *page_rmap_item)
>> +{
>> +	struct rb_node **new = &(root_unstable_tree.rb_node);
>> +	struct rb_node *parent = NULL;
>> +	struct tree_item *tree_item;
>> +	struct tree_item *new_tree_item;
>> +	struct rmap_item *rmap_item;
>> +
>> +	while (*new) {
>> +		int ret;
>> +
>> +		tree_item = rb_entry(*new, struct tree_item, node);
>> +		BUG_ON(!tree_item);
>> +		rmap_item = tree_item->rmap_item;
>> +		BUG_ON(!rmap_item);
>> +
>> +		/*
>> +		 * We dont want to swap in pages
>> +		 */
>> +		if (!is_present_pte(rmap_item->mm, rmap_item->address))
>> +			return NULL;
>> +
>> +		down_read(&rmap_item->mm->mmap_sem);
>> +		ret = get_user_pages(current, rmap_item->mm, rmap_item->address,
>> +				     1, 0, 0, page2, NULL);
>> +		up_read(&rmap_item->mm->mmap_sem);
>> +		if (!ret)
>> +			return NULL;
>>     
>
> get_user_pages() return code..
>
>   
>> +		ret = memcmp_pages(page, page2[0]);
>> +
>> +		parent = *new;
>> +		if (ret < 0) {
>> +			put_page(page2[0]);
>> +			new = &((*new)->rb_left);
>> +		} else if (ret > 0) {
>> +			put_page(page2[0]);
>> +			new = &((*new)->rb_right);
>> +		} else {
>> +			return tree_item;
>> +		}
>> +	}
>> +
>> +	if (!page_rmap_item)
>> +		return NULL;
>> +
>> +	new_tree_item = alloc_tree_item();
>> +	if (!new_tree_item)
>> +		return NULL;
>> +
>> +	page_rmap_item->tree_item = new_tree_item;
>> +	page_rmap_item->stable_tree = 0;
>> +	new_tree_item->rmap_item = page_rmap_item;
>> +	rb_link_node(&new_tree_item->node, parent, new);
>> +	rb_insert_color(&new_tree_item->node, &root_unstable_tree);
>> +
>> +	return NULL;
>> +}
>> +
>>
>> ...
>>
>> +static struct file_operations ksm_sma_fops = {
>>     
> 	
> const, please.
> 	
>   
>> +	.release        = ksm_sma_release,
>> +	.unlocked_ioctl = ksm_sma_ioctl,
>> +	.compat_ioctl   = ksm_sma_ioctl,
>> +};
>> +
>> +static int ksm_dev_ioctl_create_shared_memory_area(void)
>> +{
>> +	int fd = -1;
>> +	struct ksm_sma *ksm_sma;
>> +
>> +	ksm_sma = kmalloc(sizeof(struct ksm_sma), GFP_KERNEL);
>> +	if (!ksm_sma)
>> +		goto out;
>>     
>
> This will cause a return of -1.  Returniing -ENOMEM would be better.
>   
Right.



Thanks for the review i will cock V4 will test it and send it.


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
