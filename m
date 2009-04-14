Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AAF5F5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:14:55 -0400 (EDT)
Date: Tue, 14 Apr 2009 15:09:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-Id: <20090414150929.174a9b25.akpm@linux-foundation.org>
In-Reply-To: <1239249521-5013-5-git-send-email-ieidus@redhat.com>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
	<1239249521-5013-2-git-send-email-ieidus@redhat.com>
	<1239249521-5013-3-git-send-email-ieidus@redhat.com>
	<1239249521-5013-4-git-send-email-ieidus@redhat.com>
	<1239249521-5013-5-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu,  9 Apr 2009 06:58:41 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> Ksm is driver that allow merging identical pages between one or more
> applications in way unvisible to the application that use it.
> Pages that are merged are marked as readonly and are COWed when any
> application try to change them.
> 
> Ksm is used for cases where using fork() is not suitable,
> one of this cases is where the pages of the application keep changing
> dynamicly and the application cannot know in advance what pages are
> going to be identical.
> 
> Ksm works by walking over the memory pages of the applications it
> scan in order to find identical pages.
> It uses a two sorted data strctures called stable and unstable trees
> to find in effective way the identical pages.
> 
> When ksm finds two identical pages, it marks them as readonly and merges
> them into single one page,
> after the pages are marked as readonly and merged into one page, linux
> will treat this pages as normal copy_on_write pages and will fork them
> when write access will happen to them.
> 
> Ksm scan just memory areas that were registred to be scanned by it.
> 
> Ksm api:
> 
> KSM_GET_API_VERSION:
> Give the userspace the api version of the module.
> 
> KSM_CREATE_SHARED_MEMORY_AREA:
> Create shared memory reagion fd, that latter allow the user to register
> the memory region to scan by using:
> KSM_REGISTER_MEMORY_REGION and KSM_REMOVE_MEMORY_REGION
> 
> KSM_REGISTER_MEMORY_REGION:
> Register userspace virtual address range to be scanned by ksm.
> This ioctl is using the ksm_memory_region structure:
> ksm_memory_region:
> __u32 npages;
>          number of pages to share inside this memory region.
> __u32 pad;
> __u64 addr:
>         the begining of the virtual address of this region.
> __u64 reserved_bits;
>         reserved bits for future usage.
> 
> KSM_REMOVE_MEMORY_REGION:
> Remove memory region from ksm.
> 
>
> ...
>
> +/* ioctls for /dev/ksm */

Confused.  In the covering email you indicated that v2 of the patchset
had abandoned ioctls and had moved the interface to sysfs.

It would be good to completely (and briefly) describe KSM's proposed
userspace intefaces in the changelog or somewhere.  I'm a bit confused.

>
> ...
>
> +/*
> + * slots_lock protect against removing and adding memory regions while a scanner
> + * is in the middle of scanning.
> + */

"protects"

> +static DECLARE_RWSEM(slots_lock);
> +
> +/* The stable and unstable trees heads. */
> +struct rb_root root_stable_tree = RB_ROOT;
> +struct rb_root root_unstable_tree = RB_ROOT;
> +
> +
> +/* The number of linked list members inside the hash table */
> +static int nrmaps_hash;

A signed type doesn't seem appropriate.

> +/* rmap_hash hash table */
> +static struct hlist_head *rmap_hash;
> +
> +static struct kmem_cache *tree_item_cache;
> +static struct kmem_cache *rmap_item_cache;
> +
> +/* the number of nodes inside the stable tree */
> +static unsigned long nnodes_stable_tree;
> +
> +/* the number of kernel allocated pages outside the stable tree */
> +static unsigned long nkpage_out_tree;
> +
> +static int kthread_sleep; /* sleep time of the kernel thread */
> +static int kthread_pages_to_scan; /* npages to scan for the kernel thread */
> +static int kthread_max_kernel_pages; /* number of unswappable pages allowed */

The kthread_max_kernel_pages isn't very illuminating.

The use of "kthread" in the identifier makes is look like part of the
kthread subsystem.

> +static unsigned long ksm_pages_shared;
> +static struct ksm_scan kthread_ksm_scan;
> +static int ksmd_flags;
> +static struct task_struct *kthread;
> +static DECLARE_WAIT_QUEUE_HEAD(kthread_wait);
> +static DECLARE_RWSEM(kthread_lock);
> +
> +
>
> ...
>
> +static pte_t *get_pte(struct mm_struct *mm, unsigned long addr)
> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *ptep = NULL;
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
> +	ptep = pte_offset_map(pmd, addr);
> +out:
> +	return ptep;
> +}

hm, this looks very generic.  Does it duplicate anything which core
kernel already provides?  If not, perhaps core kernel should provide
this (perhaps after some reorganisation).

>
> ...
>
> +static int rmap_hash_init(void)
> +{
> +	if (!rmap_hash_size) {
> +		struct sysinfo sinfo;
> +
> +		si_meminfo(&sinfo);
> +		rmap_hash_size = sinfo.totalram / 10;

One slot per ten pages of physical memory?  Is this too large, too
small or just right?

> +	}
> +	nrmaps_hash = rmap_hash_size;
> +	rmap_hash = vmalloc(nrmaps_hash * sizeof(struct hlist_head));
> +	if (!rmap_hash)
> +		return -ENOMEM;
> +	memset(rmap_hash, 0, nrmaps_hash * sizeof(struct hlist_head));
> +	return 0;
> +}
> +
>
> ...
>
> +static void break_cow(struct mm_struct *mm, unsigned long addr)
> +{
> +	struct page *page[1];
> +
> +	down_read(&mm->mmap_sem);
> +	if (get_user_pages(current, mm, addr, 1, 1, 0, page, NULL)) {
> +			put_page(page[0]);
> +	}
> +	up_read(&mm->mmap_sem);
> +}

- unneeded brakes around single statement

- that single statement is over-indented.

- and it seems wrong.  If get_user_pages() returned, say, -ENOMEM, we
  end up doing put_page(random-uninitialised-address-from-stack-go-oops)?

>
> ...
>
> +static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
> +						struct ksm_memory_region *mem)
> +{
> +	struct ksm_mem_slot *slot;
> +	int ret = -EPERM;
> +
> +	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
> +	if (!slot) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	slot->mm = get_task_mm(current);
> +	if (!slot->mm)
> +		goto out_free;
> +	slot->addr = mem->addr;
> +	slot->npages = mem->npages;
> +
> +	down_write(&slots_lock);
> +
> +	list_add_tail(&slot->link, &slots);
> +	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
> +
> +	up_write(&slots_lock);
> +	return 0;
> +
> +out_free:
> +	kfree(slot);
> +out:
> +	return ret;
> +}

So this function pins the mm_struct.  I wonder what the implications of
this are.  Not much, I guess.  Some comments in the code which explain
the object lifecycles would be nice.

> +static void remove_mm_from_hash_and_tree(struct mm_struct *mm)
> +{
> +	struct ksm_mem_slot *slot;
> +	int pages_count;
> +
> +	list_for_each_entry(slot, &slots, link)
> +		if (slot->mm == mm)
> +			break;
> +	BUG_ON(!slot);
> +
> +	root_unstable_tree = RB_ROOT;
> +	for (pages_count = 0; pages_count < slot->npages; ++pages_count)
> +		remove_page_from_tree(mm, slot->addr +
> +				      pages_count * PAGE_SIZE);
> +	list_del(&slot->link);
> +}

/* Called under slots_lock */

>
> ...
>
> +static int memcmp_pages(struct page *page1, struct page *page2)
> +{
> +	char *addr1, *addr2;
> +	int r;
> +
> +	addr1 = kmap_atomic(page1, KM_USER0);
> +	addr2 = kmap_atomic(page2, KM_USER1);
> +	r = memcmp(addr1, addr2, PAGE_SIZE);
> +	kunmap_atomic(addr1, KM_USER0);
> +	kunmap_atomic(addr2, KM_USER1);
> +	return r;
> +}

I wonder if this code all does enough cpu cache flushing to be able to
guarantee that it's looking at valid data.  Not my area, and presumably
not an issue on x86.

>
> ...
>
> +static int try_to_merge_one_page(struct mm_struct *mm,
> +				 struct vm_area_struct *vma,
> +				 struct page *oldpage,
> +				 struct page *newpage,
> +				 pgprot_t newprot)
> +{
> +	int ret = 1;
> +	int odirect_sync;
> +	unsigned long page_addr_in_vma;
> +	pte_t orig_pte, *orig_ptep;
> +
> +	if (!PageAnon(oldpage))
> +		goto out;
> +
> +	get_page(newpage);
> +	get_page(oldpage);
> +
> +	down_read(&mm->mmap_sem);
> +
> +	page_addr_in_vma = addr_in_vma(vma, oldpage);
> +	if (page_addr_in_vma == -EFAULT)
> +		goto out_unlock;
> +
> +	orig_ptep = get_pte(mm, page_addr_in_vma);
> +	if (!orig_ptep)
> +		goto out_unlock;
> +	orig_pte = *orig_ptep;
> +	pte_unmap(orig_ptep);
> +	if (!pte_present(orig_pte))
> +		goto out_unlock;
> +	if (page_to_pfn(oldpage) != pte_pfn(orig_pte))
> +		goto out_unlock;
> +	/*
> +	 * we need the page lock to read a stable PageSwapCache in
> +	 * page_wrprotect()
> +	 */
> +	if (!trylock_page(oldpage))
> +		goto out_unlock;

We need a comment here explaining why we can't use the much preferable
lock_page().

Why can't we use the much preferable lock_page()?

> +	/*
> +	 * page_wrprotect check if the page is swapped or in swap cache,
> +	 * in the future we might want to run here if_present_pte and then
> +	 * swap_free
> +	 */
> +	if (!page_wrprotect(oldpage, &odirect_sync, 2)) {
> +		unlock_page(oldpage);
> +		goto out_unlock;
> +	}
> +	unlock_page(oldpage);
> +	if (!odirect_sync)
> +		goto out_unlock;
> +
> +	orig_pte = pte_wrprotect(orig_pte);
> +
> +	if (pages_identical(oldpage, newpage))
> +		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);
> +
> +out_unlock:
> +	up_read(&mm->mmap_sem);
> +	put_page(oldpage);
> +	put_page(newpage);
> +out:
> +	return ret;
> +}
>
> ...
>
> +static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
> +					struct page *page1,
> +					struct mm_struct *mm2,
> +					struct page *page2,
> +					unsigned long addr1,
> +					unsigned long addr2)
> +{
> +	struct vm_area_struct *vma;
> +	pgprot_t prot;
> +	int ret = 1;
> +	struct page *kpage;
> +
> +	/*
> +	 * The number of the nodes inside the stable tree +
> +	 * nkpage_out_tree is the same as the number kernel pages that
> +	 * we hold.
> +	 */
> +	if (kthread_max_kernel_pages &&
> +	    (nnodes_stable_tree + nkpage_out_tree) >=
> +	    kthread_max_kernel_pages)
> +		return ret;
> +
> +	kpage = alloc_page(GFP_HIGHUSER);
> +	if (!kpage)
> +		return ret;
> +	down_read(&mm1->mmap_sem);
> +	vma = find_vma(mm1, addr1);
> +	up_read(&mm1->mmap_sem);
> +	if (!vma) {
> +		put_page(kpage);
> +		return ret;
> +	}
> +	prot = vma->vm_page_prot;

What locking protects *vma here?

> +	pgprot_val(prot) &= ~_PAGE_RW;
> +
> +	copy_user_highpage(kpage, page1, addr1, vma);
> +	ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot);
> +
> +	if (!ret) {
> +		down_read(&mm2->mmap_sem);
> +		vma = find_vma(mm2, addr2);
> +		up_read(&mm2->mmap_sem);
> +		if (!vma) {
> +			put_page(kpage);
> +			break_cow(mm1, addr1);
> +			ret = 1;
> +			return ret;
> +		}
> +
> +		prot = vma->vm_page_prot;

And here.

> +		pgprot_val(prot) &= ~_PAGE_RW;
> +
> +		ret = try_to_merge_one_page(mm2, vma, page2, kpage,
> +					    prot);
> +		/*
> +		 * If the secoend try_to_merge_one_page call was failed,
> +		 * we are in situation where we have Ksm page that have
> +		 * just one pte pointing to it, in this case we break
> +		 * it.
> +		 */
> +		if (ret) {
> +			break_cow(mm1, addr1);
> +		} else {
> +			ksm_pages_shared += 2;
> +		}
> +	}
> +
> +	put_page(kpage);
> +	return ret;
> +}
> +
> +/*
> + * try_to_merge_two_pages_noalloc - the same astry_to_merge_two_pages_alloc,
> + * but no new kernel page is allocated (page2 should be KsmPage)
> + */
> +static int try_to_merge_two_pages_noalloc(struct mm_struct *mm1,
> +					  struct page *page1,
> +					  struct page *page2,
> +					  unsigned long addr1)
> +{
> +	struct vm_area_struct *vma;
> +	pgprot_t prot;
> +	int ret = 1;
> +
> +	/*
> +	 * If page2 is shared, we can just make the pte of mm1(page1) point to
> +	 * page2.
> +	 */
> +	BUG_ON(!PageKsm(page2));
> +	down_read(&mm1->mmap_sem);
> +	vma = find_vma(mm1, addr1);
> +	up_read(&mm1->mmap_sem);
> +	if (!vma)
> +		return ret;
> +	prot = vma->vm_page_prot;

etc.

> +	pgprot_val(prot) &= ~_PAGE_RW;
> +	ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
> +	if (!ret)
> +		ksm_pages_shared++;
> +
> +	return ret;
> +}
> +
> +/*
> + * is_zapped_item - check if the page belong to the rmap_item was zapped.
> + *
> + * This function would check if the page that the virtual address inside
> + * rmap_item is poiting to is still KsmPage, and therefore we can trust the
> + * content of this page.
> + * Since that this function call already to get_user_pages it return the
> + * pointer to the page as an optimization.
> + */
> +static int is_zapped_item(struct rmap_item *rmap_item,
> +			  struct page **page)
> +{
> +	int ret = 0;
> +	struct vm_area_struct *vma;
> +
> +	cond_resched();
> +	if (is_present_pte(rmap_item->mm, rmap_item->address)) {
> +		down_read(&rmap_item->mm->mmap_sem);
> +		vma = find_vma(rmap_item->mm, rmap_item->address);
> +		if (vma && !vma->vm_file) {
> +			BUG_ON(vma->vm_flags & VM_SHARED);
> +			ret = get_user_pages(current, rmap_item->mm,
> +					     rmap_item->address,
> +					     1, 0, 0, page, NULL);
> +		}
> +		up_read(&rmap_item->mm->mmap_sem);
> +	}
> +
> +	if (!ret)
> +		return 1;

Failed to check for get_user_pages() -ve return code?

> +	if (unlikely(!PageKsm(page[0]))) { 
> +		put_page(page[0]);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
>
> ...
>
> +static struct tree_item *unstable_tree_search_insert(struct page *page,
> +					struct page **page2,
> +					struct rmap_item *page_rmap_item)
> +{
> +	struct rb_node **new = &(root_unstable_tree.rb_node);
> +	struct rb_node *parent = NULL;
> +	struct tree_item *tree_item;
> +	struct tree_item *new_tree_item;
> +	struct rmap_item *rmap_item;
> +
> +	while (*new) {
> +		int ret;
> +
> +		tree_item = rb_entry(*new, struct tree_item, node);
> +		BUG_ON(!tree_item);
> +		rmap_item = tree_item->rmap_item;
> +		BUG_ON(!rmap_item);
> +
> +		/*
> +		 * We dont want to swap in pages
> +		 */
> +		if (!is_present_pte(rmap_item->mm, rmap_item->address))
> +			return NULL;
> +
> +		down_read(&rmap_item->mm->mmap_sem);
> +		ret = get_user_pages(current, rmap_item->mm, rmap_item->address,
> +				     1, 0, 0, page2, NULL);
> +		up_read(&rmap_item->mm->mmap_sem);
> +		if (!ret)
> +			return NULL;

get_user_pages() return code..

> +		ret = memcmp_pages(page, page2[0]);
> +
> +		parent = *new;
> +		if (ret < 0) {
> +			put_page(page2[0]);
> +			new = &((*new)->rb_left);
> +		} else if (ret > 0) {
> +			put_page(page2[0]);
> +			new = &((*new)->rb_right);
> +		} else {
> +			return tree_item;
> +		}
> +	}
> +
> +	if (!page_rmap_item)
> +		return NULL;
> +
> +	new_tree_item = alloc_tree_item();
> +	if (!new_tree_item)
> +		return NULL;
> +
> +	page_rmap_item->tree_item = new_tree_item;
> +	page_rmap_item->stable_tree = 0;
> +	new_tree_item->rmap_item = page_rmap_item;
> +	rb_link_node(&new_tree_item->node, parent, new);
> +	rb_insert_color(&new_tree_item->node, &root_unstable_tree);
> +
> +	return NULL;
> +}
> +
>
> ...
>
> +static struct file_operations ksm_sma_fops = {
	
const, please.
	
> +	.release        = ksm_sma_release,
> +	.unlocked_ioctl = ksm_sma_ioctl,
> +	.compat_ioctl   = ksm_sma_ioctl,
> +};
> +
> +static int ksm_dev_ioctl_create_shared_memory_area(void)
> +{
> +	int fd = -1;
> +	struct ksm_sma *ksm_sma;
> +
> +	ksm_sma = kmalloc(sizeof(struct ksm_sma), GFP_KERNEL);
> +	if (!ksm_sma)
> +		goto out;

This will cause a return of -1.  Returniing -ENOMEM would be better.

> +
> +	INIT_LIST_HEAD(&ksm_sma->sma_slots);
> +
> +	fd = anon_inode_getfd("ksm-sma", &ksm_sma_fops, ksm_sma, 0);
> +	if (fd < 0)
> +		goto out_free;
> +
> +	return fd;
> +out_free:
> +	kfree(ksm_sma);
> +out:
> +	return fd;
> +}
> +
> +static long ksm_dev_ioctl(struct file *filp,
> +			  unsigned int ioctl, unsigned long arg)
> +{
> +	long r = -EINVAL;
> +
> +	switch (ioctl) {
> +	case KSM_GET_API_VERSION:
> +		r = KSM_API_VERSION;
> +		break;
> +	case KSM_CREATE_SHARED_MEMORY_AREA:
> +		r = ksm_dev_ioctl_create_shared_memory_area();
> +		break;
> +	default:
> +		break;
> +	}
> +	return r;
> +}
> +
> +static struct file_operations ksm_chardev_ops = {

const

> +	.unlocked_ioctl = ksm_dev_ioctl,
> +	.compat_ioctl   = ksm_dev_ioctl,
> +	.owner          = THIS_MODULE,
> +};
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
