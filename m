Date: Wed, 23 Jan 2008 23:24:33 -0800
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [kvm-devel] [RFC][PATCH 3/5] ksm source code
Message-ID: <20080124072432.GQ3627@sequoia.sous-sol.org>
References: <4794C477.3090708@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4794C477.3090708@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

* Izik Eidus (izike@qumranet.com) wrote:

Just a bunch of nitpicks.

> struct ksm *ksm;

static

> static int page_hash_size = 0;

no need to initialize to zero

> module_param(page_hash_size, int, 0);
> MODULE_PARM_DESC(page_hash_size, "Hash table size for the pages checksum");
> 
> static int rmap_hash_size = 0;

no need to initialize to zero

> module_param(rmap_hash_size, int, 0);
> MODULE_PARM_DESC(rmap_hash_size, "Hash table size for the reverse mapping");
> 
> int ksm_slab_init(void)

static

> {
> 	int ret = 1;
> 
> 	ksm->page_item_cache = kmem_cache_create("ksm_page_item",
> 						 sizeof(struct page_item), 0,
> 						 0, NULL);
> 	if (!ksm->page_item_cache)
> 		goto out;
> 
> 	ksm->rmap_item_cache = kmem_cache_create("ksm_rmap_item",
> 						 sizeof(struct rmap_item), 0,
> 						 0, NULL);
> 	if (!ksm->rmap_item_cache)
> 		goto out_free;
> 	return 0;
> 
> out_free:
> 	kmem_cache_destroy(ksm->page_item_cache);
> out:
> 	return ret;
> }
> 
> void ksm_slab_free(void)
> {
> 	kmem_cache_destroy(ksm->rmap_item_cache);
> 	kmem_cache_destroy(ksm->page_item_cache);
> }
> 
> static struct page_item *alloc_page_item(void)
> {
> 	void *obj;
> 
> 	obj = kmem_cache_zalloc(ksm->page_item_cache, GFP_KERNEL);
> 	return (struct page_item *)obj;
> }
> 
> static void free_page_item(struct page_item *page_item)
> {
> 	kfree(page_item);

kmem_cache_free

> }
> 
> static struct rmap_item *alloc_rmap_item(void)
> {
> 	void *obj;
> 
> 	obj = kmem_cache_zalloc(ksm->rmap_item_cache, GFP_KERNEL);
> 	return (struct rmap_item *)obj;
> }
> 
> static void free_rmap_item(struct rmap_item *rmap_item)
> {
> 	kfree(rmap_item);

kmem_cache_free

> }
> 
> static int inline PageKsm(struct page *page)
> {
> 	return !PageAnon(page);
> }
> 
> static int page_hash_init(void)
> {
> 	if (!page_hash_size) {
> 		struct sysinfo sinfo;
> 
> 		si_meminfo(&sinfo);
> 		page_hash_size = sinfo.totalram;
> 	}
> 	ksm->npages_hash = page_hash_size;
> 	ksm->page_hash = vmalloc(ksm->npages_hash *
> 				 sizeof(struct hlist_head *));
> 	if (IS_ERR(ksm->page_hash))

allocator returns NULL on failure (btw, this mistake is pervasive in the
patch)

> 		return PTR_ERR(ksm->page_hash);
> 	memset(ksm->page_hash, 0,
> 	       ksm->npages_hash  * sizeof(struct hlist_head *));
> 	return 0;
> }
> 
> static void page_hash_free(void)
> {
> 	int i;
> 	struct hlist_head *bucket;
> 	struct hlist_node *node, *n;
> 	struct page_item *page_item;
> 
> 	for (i = 0; i < ksm->npages_hash; ++i) {
> 		bucket = &ksm->page_hash[i];
> 		hlist_for_each_entry_safe(page_item, node, n, bucket, link) {
> 			hlist_del(&page_item->link);
> 			free_page_item(page_item);
> 		}
> 	}
> 	vfree(ksm->page_hash);
> }
> 
> static int rmap_hash_init(void)
> {
> 	if (!rmap_hash_size) {
> 		struct sysinfo sinfo;
> 
> 		si_meminfo(&sinfo);
> 		rmap_hash_size = sinfo.totalram;
> 	}
> 	ksm->nrmaps_hash = rmap_hash_size;
> 	ksm->rmap_hash = vmalloc(ksm->nrmaps_hash *
> 				 sizeof(struct hlist_head *));

failure == NULL

> 	if (IS_ERR(ksm->rmap_hash))
> 		return PTR_ERR(ksm->rmap_hash);
> 	memset(ksm->rmap_hash, 0,
> 	       ksm->nrmaps_hash * sizeof(struct hlist_head *));
> 	return 0;
> }
> 
> static void rmap_hash_free(void)
> {
> 	int i;
> 	struct hlist_head *bucket;
> 	struct hlist_node *node, *n;
> 	struct rmap_item *rmap_item;
> 
> 	for (i = 0; i < ksm->nrmaps_hash; ++i) {
> 		bucket = &ksm->rmap_hash[i];
> 		hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
> 			hlist_del(&rmap_item->link);
> 			free_rmap_item(rmap_item);
> 		}
> 	}
> 	vfree(ksm->rmap_hash);
> }
> 
> static inline u32 calc_hash_index(void *addr)
> {
> 	return jhash(addr, PAGE_SIZE, 17) % ksm->npages_hash;
> }
> 
> static void remove_page_from_hash(struct mm_struct *mm, unsigned long addr)
> {
> 	struct rmap_item *rmap_item;
> 	struct hlist_head *bucket;
> 	struct hlist_node *node, *n;
> 
> 	bucket = &ksm->rmap_hash[addr % ksm->nrmaps_hash];
> 	hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
> 		if (mm == rmap_item->page_item->mm &&
> 		    rmap_item->page_item->addr == addr) {
> 			hlist_del(&rmap_item->page_item->link);
> 			free_page_item(rmap_item->page_item);
> 			hlist_del(&rmap_item->link);
> 			free_rmap_item(rmap_item);
> 			return;
> 		}
> 	}
> }
> 
> static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
> 						struct ksm_memory_region *mem)
> {
> 	struct ksm_mem_slot *slot;
> 	int ret = 1;

ret = 1 doesn't make sense as a failure

> 	if (!current->mm)
> 		goto out;
> 
> 	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
> 	if (IS_ERR(slot)) {

failure == NULL

> 		ret = PTR_ERR(slot);
> 		goto out;
> 	}
> 
> 	slot->mm = get_task_mm(current);
> 	slot->addr = mem->addr;
> 	slot->npages = mem->npages;
> 	list_add_tail(&slot->link, &ksm->slots);

slots_lock?

> 	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);

theoretical, but if threaded, registering program could do this
concurrently

> 	ret = 0;
> out:
> 	return ret;
> }
> 
> static void remove_mm_from_hash(struct mm_struct *mm)
> {
> 	struct ksm_mem_slot *slot;
> 	int pages_count = 0;
> 
> 	list_for_each_entry(slot, &ksm->slots, link)
> 		if (slot->mm == mm)
> 			break;
> 	if (!slot)
> 		BUG();
> 
> 	spin_lock(&ksm->hash_lock);
> 	while (pages_count < slot->npages)
> 	{
> 		remove_page_from_hash(mm, slot->addr + pages_count * PAGE_SIZE);
> 		pages_count++;
> 	}
> 	spin_unlock(&ksm->hash_lock);
> 	list_del(&slot->link);
> }
> 
> static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma)
> {
> 	struct ksm_mem_slot *slot, *node;
> 
> 	down_write(&ksm->slots_lock);
> 	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
> 		remove_mm_from_hash(slot->mm);
> 		mmput(slot->mm);
> 		list_del(&slot->sma_link);
> 		kfree(slot);
> 	}
> 	up_write(&ksm->slots_lock);
> 	return 0;
> }
> 
> static int ksm_sma_release(struct inode *inode, struct file *filp)
> {
> 	struct ksm_sma *ksm_sma = filp->private_data;
> 	int r;
> 
> 	r = ksm_sma_ioctl_remove_memory_region(ksm_sma);
> 	return r;

leaked ksm_sma?

> }
> 
> static long ksm_sma_ioctl(struct file *filp,
> 			  unsigned int ioctl, unsigned long arg)
> {
> 	struct ksm_sma *sma = filp->private_data;
> 	void __user *argp = (void __user *)arg;
> 	int r = EINVAL;
> 
> 	switch (ioctl) {
> 	case KSM_REGISTER_MEMORY_REGION: {
> 		struct ksm_memory_region ksm_memory_region;
> 
> 		r = -EFAULT;
> 		if (copy_from_user(&ksm_memory_region, argp,
> 				   sizeof ksm_memory_region))

this doesn't look compat safe:

 struct ksm_memory_region {
 	__u32 npages; /* number of pages to share */
 	__u64 addr; /* the begining of the virtual address */
 };

> 			goto out;
> 		r = ksm_sma_ioctl_register_memory_region(sma,
> 							 &ksm_memory_region);
> 		break;
> 	}
> 	case KSM_REMOVE_MEMORY_REGION:
> 		r = ksm_sma_ioctl_remove_memory_region(sma);
> 		break;
> 	}
> 
> out:
> 	return r;
> }
> 
> static int insert_page_to_hash(struct ksm_scan *ksm_scan,
> 			       unsigned long hash_index,
> 			       struct page_item *page_item,
> 			       struct rmap_item *rmap_item)
> {
> 	struct ksm_mem_slot *slot;
> 	struct hlist_head *bucket;
> 
> 	slot = ksm_scan->slot_index;
> 	page_item->addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
> 	page_item->mm = slot->mm;
> 	bucket = &ksm->page_hash[hash_index];
> 	hlist_add_head(&page_item->link, bucket);
> 
> 	rmap_item->page_item = page_item;
> 	rmap_item->oldindex = hash_index;
> 	bucket = &ksm->rmap_hash[page_item->addr % ksm->nrmaps_hash];
> 	hlist_add_head(&rmap_item->link, bucket);
> 	return 0;
> }
> 
> static void update_hash(struct ksm_scan *ksm_scan,
> 		       unsigned long hash_index)
> {
> 	struct rmap_item *rmap_item;
> 	struct ksm_mem_slot *slot;
> 	struct hlist_head *bucket;
> 	struct hlist_node *node, *n;
> 	unsigned long addr;
> 
> 	slot = ksm_scan->slot_index;;
> 	addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
> 	bucket = &ksm->rmap_hash[addr % ksm->nrmaps_hash];
> 	hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
> 		if (slot->mm == rmap_item->page_item->mm &&
> 		    rmap_item->page_item->addr == addr) {
> 			if (hash_index != rmap_item->oldindex) {
> 				hlist_del(&rmap_item->page_item->link);
> 				free_page_item(rmap_item->page_item);
> 				hlist_del(&rmap_item->link);
> 				free_rmap_item(rmap_item);
> 			}
> 			return;
> 		}
> 	}
> }
> 
> static void lock_two_pages(struct page *page1, struct page *page2)
> {
> 	if (page1 < page2) {
> 		lock_page(page1);
> 		lock_page(page2);
> 	}
> 	else {
> 		lock_page(page2);
> 		lock_page(page1);
> 	}
> }
> 
> static void unlock_two_pages(struct page *page1, struct page *page2)
> {
> 	unlock_page(page1);
> 	unlock_page(page2);
> }
> 
> static unsigned long addr_in_vma(struct vm_area_struct *vma, struct page *page)
> {
> 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> 	unsigned long addr;
> 
> 	addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> 	if (unlikely(addr < vma->vm_start || addr >= vma->vm_end))
> 		return -EFAULT;
> 	return addr;
> }
> 
> static int is_present_pte(struct mm_struct *mm, unsigned long addr)
> {
> 	pgd_t *pgd;
> 	pud_t *pud;
> 	pmd_t *pmd;
> 	pte_t *ptep;
> 	spinlock_t *ptl;
> 	int ret = 0;
> 
> 	pgd = pgd_offset(mm, addr);
> 	if (!pgd_present(*pgd))
> 		goto out;
> 
> 	pud = pud_offset(pgd, addr);
> 	if (!pud_present(*pud))
> 		goto out;
> 
> 	pmd = pmd_offset(pud, addr);
> 	if (!pmd_present(*pmd))
> 		goto out;
> 
> 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
> 	if (!ptep)
> 		goto out;
> 
> 	if (pte_present(*ptep))
> 		ret = 1;
> 
> 	pte_unmap_unlock(ptep, ptl);
> out:
> 	return ret;
> }

This is generic helper.

> /*
>  * try_to_merge_one_page - take two pages and merge them into one
>  * note:
>  * oldpage should be anon page while newpage should be file mapped page
>  */
> static int try_to_merge_one_page(struct mm_struct *mm,
> 				 struct vm_area_struct *vma,
> 				 struct page *oldpage,
> 				 struct page *newpage,
> 				 pgprot_t newprot)
> {
> 	int ret = 0;
> 	unsigned long page_addr_in_vma;
> 	void *oldaddr, *newaddr;
> 
> 	get_page(newpage);
> 	get_page(oldpage);
> 
> 	down_write(&mm->mmap_sem);
> 
> 	lock_two_pages(oldpage, newpage);
> 
> 	page_addr_in_vma = addr_in_vma(vma, oldpage);
> 	if (page_addr_in_vma == -EFAULT)
> 		goto out_unlock;
> 
> 	/*
> 	 * if the page is swapped or in swap cache, we cannot replace its pte
> 	 * we might want to run here swap_free in the future (it isnt exported)
> 	 */
> 	if (!is_present_pte(mm, page_addr_in_vma))
> 		goto out_unlock;
> 
> 	if (!page_wrprotect(oldpage))
> 		goto out_unlock;
> 
> 	oldaddr = kmap_atomic(oldpage, KM_USER0);
> 	newaddr = kmap_atomic(newpage, KM_USER1);
> 
> 	ret = 1;
> 	if (!memcmp(oldaddr, newaddr, PAGE_SIZE))
> 		ret = replace_page(vma, oldpage, newpage, newprot);

Does it make sense to leave oldpage r/o if replace_page fails?

> 	kunmap_atomic(oldaddr, KM_USER0);
> 	kunmap_atomic(newaddr, KM_USER1);
> 
> 	if (!ret)
> 		ret = 1;
> 	else
> 		ret = 0;
> 
> out_unlock:
> 	unlock_two_pages(oldpage, newpage);
> 	up_write(&mm->mmap_sem);
> 	put_page(oldpage);
> 	put_page(newpage);
> 	return ret;
> }
> 
> static int try_to_merge_two_pages(struct mm_struct *mm1, struct page *page1,
> 				  struct mm_struct *mm2, struct page *page2,
> 				  unsigned long addr1, unsigned long addr2)
> {
> 	struct vm_area_struct *vma;
> 	pgprot_t prot;
> 	int ret = 0;
> 
> 	/*
> 	 * in case page2 isnt shared (it isnt PageKsm we have to allocate a new
> 	 * file mapped page and make the two ptes of mm1(page1) and mm2(page2)
> 	 * point to it, in case page is shared page, we can just make the pte of
> 	 * mm1(page1) point to page2
> 	 */
> 	if (PageKsm(page2)) {
> 		vma = find_vma(mm1, addr1);
> 		if (!vma)
> 			return ret;
> 		prot = vma->vm_page_prot;
> 		pgprot_val(prot) &= ~VM_WRITE;
> 		ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
> 	}
> 	else {
> 		struct page *kpage;
> 
> 		kpage = alloc_page(GFP_KERNEL |  __GFP_HIGHMEM);
> 		if (!kpage)
> 			return ret;
> 
> 		vma = find_vma(mm1, addr1);
> 		if (!vma)
> 			return ret;
> 		prot = vma->vm_page_prot;
> 		pgprot_val(prot) &= ~VM_WRITE;
> 
> 		copy_highpage(kpage, page1);
> 		ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot);
> 		page_cache_release(kpage);
> 
> 		if (ret) {
> 			vma = find_vma(mm2, addr2);
> 			if (!vma)
> 				return ret;
> 
> 			prot = vma->vm_page_prot;
> 			pgprot_val(prot) &= ~VM_WRITE;
> 
> 			ret += try_to_merge_one_page(mm2, vma, page2, kpage,
> 						     prot);
> 		}
> 	}
> 	return ret;
> }
> 
> static int cmp_and_merge_page(struct ksm_scan *ksm_scan, struct page *page)
> {
> 	struct hlist_head *bucket;
> 	struct hlist_node *node, *n;
> 	struct page_item *page_item;
> 	struct ksm_mem_slot *slot;
> 	unsigned long hash_index;
> 	unsigned long addr;
> 	void *page_addr;
> 	int ret = 0;
> 	int used = 0;
> 
> 	page_addr = kmap(page);
> 	hash_index = calc_hash_index(page_addr);
> 	bucket = &ksm->page_hash[hash_index];
> 
> 	slot = ksm_scan->slot_index;
> 	addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
> 
> 	spin_lock(&ksm->hash_lock);
> 	/*
> 	 * update_hash must to be called everytime that there is a chance
> 	 * that the data inside the page was changed since the last time it
> 	 * was inserted into our hash table, (to avoid cases where the page
> 	 * will be inserted more than once to the hash table)
> 	 */ 
> 	update_hash(ksm_scan, hash_index);
> 	spin_unlock(&ksm->hash_lock);
> 
> 	hlist_for_each_entry_safe(page_item, node, n, bucket, link) {
> 		int npages;
> 		struct page *hash_page[1];
> 		void *hash_page_addr;
> 
> 		if (slot->mm == page_item->mm && addr == page_item->addr) {
> 			used = 1;
> 			continue;
> 		}
> 
> 		down_read(&page_item->mm->mmap_sem);
> 		/* if the page is swapped out or in the swap cache we dont want
> 		 * to scan it (it is just for performence)
> 		 */
> 		if (!is_present_pte(page_item->mm, page_item->addr)) {
> 			up_read(&page_item->mm->mmap_sem);
> 			continue;
> 		}
> 		npages = get_user_pages(current, page_item->mm, page_item->addr,
> 					1, 0, 0, hash_page, NULL);
> 		up_read(&page_item->mm->mmap_sem);
> 		if (npages != 1)
> 			break;
> 
> 		hash_page_addr = kmap_atomic(hash_page[0], KM_USER1);
> 		/*
>  		 * we check if the pages are equal 2 times, one time when they
>  		 * arent write protected and again after we write protect them
>  		 */
> 		if (!memcmp(page_addr, hash_page_addr, PAGE_SIZE)) {
> 			kunmap_atomic(hash_page_addr, KM_USER0);

kmap slot mismatch

> 			kunmap(page_addr);
> 
> 			ret = try_to_merge_two_pages(slot->mm, page,
> 						     page_item->mm,
> 						     hash_page[0], addr,
> 						     page_item->addr);
> 			page_cache_release(hash_page[0]);
> 			return ret;
> 		}
> 		kunmap_atomic(hash_page_addr, KM_USER0);

kmap slot mismatch

> 		page_cache_release(hash_page[0]);
> 	}
> 	kunmap(page_addr);
> 	/* if node is NULL and used=0, the page is not inside the hash table */
> 	if (!node && !used) {
> 		struct page_item *page_item;
> 		struct rmap_item *rmap_item;
> 
> 		page_item = alloc_page_item();
> 		if (!page_item)
> 			return 1;
> 
> 		rmap_item = alloc_rmap_item();
> 		if (!rmap_item) {
> 			kfree(page_item);
> 			return ret;
> 		}
> 
> 		spin_lock(&ksm->hash_lock);
> 		update_hash(ksm_scan, hash_index);
> 		insert_page_to_hash(ksm_scan, hash_index, page_item, rmap_item);
> 		spin_unlock(&ksm->hash_lock);
> 	}
> 
> 	return ret;
> }
> 
> /* return 1 - no slots registered, nothing to be done */
> static int scan_get_next_index(struct ksm_scan *ksm_scan, int nscan)
> {
> 	struct ksm_mem_slot *slot;
> 
> 	if (list_empty(&ksm->slots))
> 		/* no slot avaible!, return 1 */
> 		return 1;
> 
> 	slot = ksm_scan->slot_index;
> 	/*
> 	 * first lets see if in this memory slot there are more pages that we
> 	 * can use as our scan bluck pages
> 	 */
> 	if ((slot->npages - ksm_scan->page_index - nscan) > 0) {
> 		ksm_scan->page_index += nscan;
> 		return 0;
> 	}
> 
> 	list_for_each_entry_from(slot, &ksm->slots, link) {
> 		if (slot == ksm_scan->slot_index)
> 			continue;
> 		ksm_scan->page_index = 0;
> 		ksm_scan->slot_index = slot;
> 		return 0;
> 	}
> 
> 	/* look like we finished scanning the whole memory, starting again */
> 	ksm_scan->page_index = 0;
>  	ksm_scan->slot_index = list_first_entry(&ksm->slots,
> 						struct ksm_mem_slot, link);
> 	return 0;
> }
> 
> /*
>  * update slot_index so it point to vaild data, it is possible that by
>  * the time we are here the data that ksm_scan was pointed to was released
>  * so we have to call this function every time after taking the slots_lock
>  */
> static void scan_update_old_index(struct ksm_scan *ksm_scan)
> {
> 	struct ksm_mem_slot *slot;
> 
> 	if (list_empty(&ksm->slots))
> 		return;
> 
> 	list_for_each_entry(slot, &ksm->slots, link) {
> 		if (ksm_scan->slot_index == slot)
> 			return;
> 	}
> 
> 	ksm_scan->slot_index = list_first_entry(&ksm->slots,
> 						struct ksm_mem_slot, link);
> }
> 
> static int ksm_scan_start(struct ksm_scan *ksm_scan, int scan_npages)
> {
> 	struct ksm_mem_slot *slot;
> 	struct page *page[1];

just struct page *page and pass &page to get_user_pages 
since it's just one page

> 	int val;
> 	int ret = 0;
> 
> 	down_read(&ksm->slots_lock);
> 
> 	scan_update_old_index(ksm_scan);
> 
> 	while (scan_npages > 0) {
> 		if (scan_get_next_index(ksm_scan, 1)) {
> 			/* we have no slots, another ret value should be used */
> 			goto out;
> 		}
> 
> 		slot = ksm_scan->slot_index;
> 		down_read(&slot->mm->mmap_sem);
> 		/* if the page is swappd out or in swap cache, we dont want to
> 		 * scan it (it is just for performence)
> 		 */
> 		if (is_present_pte(slot->mm, slot->addr +
> 				   ksm_scan->page_index * PAGE_SIZE)) {
> 			val = get_user_pages(current, slot->mm, slot->addr +
> 					     ksm_scan->page_index * PAGE_SIZE ,
> 					      1, 0, 0, page, NULL);
> 			up_read(&slot->mm->mmap_sem);
> 			if (val == 1) {
> 				if (!PageKsm(page[0]))
> 					cmp_and_merge_page(ksm_scan, page[0]);
> 				page_cache_release(page[0]);
> 			}
> 		} else
> 			up_read(&slot->mm->mmap_sem);
> 		scan_npages--;
> 	}
> 
> 	scan_get_next_index(ksm_scan, 1);
> out:
> 	up_read(&ksm->slots_lock);
> 	return ret;
> }
> 
> static int ksm_scan_ioctl_start(struct ksm_scan *ksm_scan, int scan_npages)
> {
> 	return ksm_scan_start(ksm_scan, scan_npages);
> }

Unnecessary wrapper

> static int ksm_scan_release(struct inode *inode, struct file *filp)
> {
> 	struct ksm_scan *ksm_scan = filp->private_data;
> 
> 	kfree(ksm_scan);
> 	return 0;
> }
> 
> static long ksm_scan_ioctl(struct file *filp,
> 			   unsigned int ioctl, unsigned long arg)
> {
> 	struct ksm_scan *ksm_scan = filp->private_data;
> 	int r = EINVAL;
> 
> 	switch (ioctl) {
> 	case KSM_SCAN:
> 		r = ksm_scan_ioctl_start(ksm_scan, arg);
> 	}
> 	return r;
> }
> 
> static struct file_operations ksm_sma_fops = {
> 	.release        = ksm_sma_release,
> 	.unlocked_ioctl = ksm_sma_ioctl,
> 	.compat_ioctl   = ksm_sma_ioctl,
> };
> 
> static int ksm_dev_ioctl_create_shared_memory_area(void)
> {
> 	int fd, r;
> 	struct ksm_sma *ksm_sma;
> 	struct inode *inode;
> 	struct file *file;
> 
> 	ksm_sma = kmalloc(sizeof(struct ksm_sma), GFP_KERNEL);
> 	if (IS_ERR(ksm_sma)) {

failure == NULL

> 		r = PTR_ERR(ksm_sma);
> 		goto out;
> 	}
> 
> 	INIT_LIST_HEAD(&ksm_sma->sma_slots);
> 
> 	r = anon_inode_getfd(&fd, &inode, &file, "ksm-sma", &ksm_sma_fops,
> 			     ksm_sma);
> 	if (r)
> 		goto out_free;
> 
> 	return fd;
> out_free:
> 	kfree(ksm_sma);
> out:
> 	return -1;

return r to propagate meaningful error

> }
> 
> static struct file_operations ksm_scan_fops = {
> 	.release        = ksm_scan_release,
> 	.unlocked_ioctl = ksm_scan_ioctl,
> 	.compat_ioctl   = ksm_scan_ioctl,
> };
> 
> static struct ksm_scan *ksm_scan_create(void)
> {
> 	struct ksm_scan *ksm_scan;
> 
> 	ksm_scan = kzalloc(sizeof(struct ksm_scan), GFP_KERNEL);
> 	return ksm_scan;
> }

Unnecessary wrapper

> static int ksm_dev_ioctl_create_scan(void)
> {
> 	int fd, r;
> 	struct inode *inode;
> 	struct file *file;
> 	struct ksm_scan *ksm_scan;
> 
> 	ksm_scan = ksm_scan_create();
> 	if (IS_ERR(ksm_scan)) {

failure == NULL

> 		r = PTR_ERR(ksm_scan);
> 		goto out;
> 	}
> 
> 	r = anon_inode_getfd(&fd, &inode, &file, "ksm-scan", &ksm_scan_fops,
> 			     ksm_scan);
> 	if (r)
> 		goto out_free;
> 	return fd;
> 
> out_free:
> 	kfree(ksm_scan);
> out:
> 	return -1;

return r to propagate error

> }
> 
> static long ksm_dev_ioctl(struct file *filp,
> 			  unsigned int ioctl, unsigned long arg)
> {
> 	long r = -EINVAL;
> 
> 	switch(ioctl) {
> 	case KSM_GET_API_VERSION:
> 		r = KSM_API_VERSION;
> 		break;
> 	case KSM_CREATE_SHARED_MEMORY_AREA:
> 		r = ksm_dev_ioctl_create_shared_memory_area();
> 		break;
> 	case KSM_CREATE_SCAN:
> 		r = ksm_dev_ioctl_create_scan();

What's the value of having multiple scanners?
And how expensive is scanning?

> 	default:
> 		return r;
> 	}
> 	return r;
> }
> 
> static int ksm_dev_open(struct inode *inode, struct file *filp)
> {
> 	try_module_get(THIS_MODULE);
> 	return 0;
> }
> 
> static int ksm_dev_release(struct inode *inode, struct file *filp)
> {
> 	module_put(THIS_MODULE);
> 	return 0;
> }
> 
> static struct file_operations ksm_chardev_ops = {
> 	.open           = ksm_dev_open,
> 	.release        = ksm_dev_release,
> 	.unlocked_ioctl = ksm_dev_ioctl,
> 	.compat_ioctl   = ksm_dev_ioctl,
> };
> 
> static struct miscdevice ksm_dev = {
> 	KSM_MINOR,
> 	"ksm",
> 	&ksm_chardev_ops,
> };
> 
> static int __init ksm_init(void)
> {
> 	int r;
> 
> 	ksm = kzalloc(sizeof(struct ksm), GFP_KERNEL);
> 	if (IS_ERR(ksm)) {

failure == NULL

> 		r = PTR_ERR(ksm);
> 		goto out;
> 	}
> 
> 	r = ksm_slab_init();
> 	if (r)
> 		goto out_free;
> 
> 	r = page_hash_init();
> 	if (r)
> 		goto out_free1;
> 
> 	r = rmap_hash_init();
> 	if (r)
> 		goto out_free2;
> 
> 	INIT_LIST_HEAD(&ksm->slots);
> 	init_rwsem(&ksm->slots_lock);
> 	spin_lock_init(&ksm->hash_lock);
> 
> 	r = misc_register(&ksm_dev);
> 	if (r) {
> 		printk(KERN_ERR "ksm: misc device register failed\n");
> 		goto out_free3;
> 	}
> 	printk(KERN_WARNING "ksm loaded\n");
> 	return 0;
> 
> out_free3:
> 	rmap_hash_free();
> out_free2:
> 	page_hash_free();
> out_free1:
> 	ksm_slab_free();
> out_free:
> 	kfree(ksm);
> out:
> 	return r;
> }
> 
> static void __exit ksm_exit(void)
> {
> 	misc_deregister(&ksm_dev);
> 	rmap_hash_free();
> 	page_hash_free();
> 	ksm_slab_free();
> 	kfree(ksm);
> }
> 
> module_init(ksm_init)
> module_exit(ksm_exit)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
