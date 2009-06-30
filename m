Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D10F36B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 05:48:28 -0400 (EDT)
Message-ID: <4A49E051.1080400@redhat.com>
Date: Tue, 30 Jun 2009 12:52:17 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: KSM: current madvise rollup
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Hi Izik,
>   
Hello

> Thanks a lot for giving me some space.  As I proposed in private mail
> last week, here is my current rollup of the madvise version of KSM.
>
> The patch is against 2.6.31-rc1, but the work is based upon your
> "RFC - ksm api change into madvise" from 14 May: omitting for now
> your 4/4 to apply KSM to other processes, but including Andrea's
> two rmap_item fixes from 3 June.
>
> This is not a patch to go into any tree yet: it needs to be split
> up and reviewed and argued over and parts reverted etc.  But it is
> good for some testing, and it is good for you to take a look at,
> diff against what you have and say, perhaps: right, please split
> this up into this and this and this kind of change, so we can
> examine it more closely; or, perhaps, you won't like my direction
> at all and want a fresh start.
>
> The changes outside of mm/ksm.c shouldn't cause much controversy.
> Perhaps we'll want to send in the arch mman.h additions, and the
> madvise interface, and your mmu_notifier mods, along with a dummy
> mm/ksm.c, quite early; while we continue to discuss what's in ksm.c.
>
> It'll be hard for you not to get irritated by all my trivial cleanups
> there, sorry.  

Oh, for that I am very happy, nothing that I am proud of was found there :)

> I find it best when I'm working to let myself do such
> tidying up, then only at the end go back over to decide whether it's
> justified or not.  And my correction of typos in comments etc. is
> fairly random: sometimes I've just corrected one word, sometimes
> I've rewritten a comment, but lots I've not read through yet.
>
> A lot of the change came about because I couldn't run the loads
> I wanted, they'd OOM because of the way KSM had a hold on any mm it
> was advised of (so the mm couldn't exit and free up its pages until
> KSM got there).  I know you were dissatisfied with that too, but
> perhaps you've solved it differently by now.
>   

I wanted to switch to mm_count instead of mm_users + some safety checks,
But your way is for sure much better not to take any reference counter 
for the mm!

> I've plenty more to do: still haven't really focussed in on mremap
> move, and races when the vma we expect to be VM_MERGEABLE is actually
> something else by the time we get mmap_sem for get_user_pages. 

Considering the fact that the madvise run with mmap_sem(write) isn't it 
enough just to check the VM_MERGEABLE flag?

>  But I
> don't think there's any show-stopper there, just a little tightening
> needed.  The rollup below is a good staging post, I think, and much
> better than the /dev/ksm version that used to be in mmotm.
>   

I agree, the Interface now look much better i got to admit, moreover the 
fact that it tied up with the vmas allowed the code to be somewhat more 
simple
(Such as the rmap_items handling)

> Though I haven't even begun to worry about how KSM interacts with
> page migration and mem cgroups and Andi & Wu's HWPOISONous pages.
>   

About page migration - right now it should fail when trying to migrate 
ksmpage:

/* Establish migration ptes or remove ptes */
try_to_unmap(page, 1);

if (!page_mapped(page))
rc = move_to_new_page(newpage, page);


So as I see it, the soultion for this case is the same soultion as for 
the swapping problem of the ksm pages...:
We need something such as extrnal rmap callbacks to make the rmap code 
be aware of the ksm virtual mappings of the pages - (we can use our data 
structures information inside ksm such as the stable_tree to track the 
virtual addresses that point into this page)

So about the page migration i think we need to add support to it, when 
we add support of swapping, probably one release after we first get ksm 
merged...

And about cgroups, again, i think swapping is main issue for this, for 
now we only have max_kernel_page_alloc to control the number of 
unswappable pages allocated by ksm.



About your patch:
Excellent changes!, the direction you took it, is much better than the 
previous interface with madvise.
Moreover all your code style changes, and "clean ups" you made to my 
code are all 100% justified and are very welcomed!
Thanks alot for your work on that area, i am very pleased from the 
results...
just few comments below (And there are really just few comments, as I 
really like everything)


> Hugh
> ---
>   

--snip--

>
> +		 struct page *newpage, pte_t orig_pte, pgprot_t prot)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *ptep;
> +	spinlock_t *ptl;
> +	unsigned long addr;
> +	int ret = -EFAULT;
> +
> +	BUG_ON(PageAnon(newpage));
> +
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
> +	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, prot));
> +
> +	page_remove_rmap(oldpage);
> +	if (PageAnon(oldpage)) {
> +		dec_mm_counter(mm, anon_rss);
> +		inc_mm_counter(mm, file_rss);
> +	}
>   

So now that replace_page is embedded inside ksm.c, i guess we dont need 
the if (PageAnon() check...) ?

> +	put_page(oldpage);
> +
> +	pte_unmap_unlock(ptep, ptl);
> +out:
> +	return ret;
> +}
> +
> +/*
>
>   


-- snip --


> +static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
> +{
> +	struct page *page2[1];
> +	struct rmap_item *tree_rmap_item;
> +	unsigned int checksum;
> +	int ret;
> +
> +	if (rmap_item->stable_tree)
> +		remove_rmap_item_from_tree(rmap_item);
> +
> +	/* We first start with searching the page inside the stable tree */
> +	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
> +	if (tree_rmap_item) {
> +		BUG_ON(!tree_rmap_item->tree_item);
> +
> +		if (page == page2[0]) {		/* forked */
> +			ksm_pages_shared++;
> +			ret = 0;
>   

So here we increase the ksm_pages_shared, but how would we decrease it?
Shouldnt we map the rmap_item to be stable_tree item?, and add this 
virtual address into the linked list of the stable tree node?
(so when remove_rmap_item() will run we will be able to decrease the 
number...)


> +		} else
> +			ret = try_to_merge_two_pages_noalloc(rmap_item->mm,
> +							    page, page2[0],
> +							    rmap_item->address);
> +		put_page(page2[0]);
> +
> +		if (!ret) {
> +			/*
> +			 * The page was successfully merged, let's insert its
> +			 * rmap_item into the stable tree.
> +			 */
> +			insert_to_stable_tree_list(rmap_item, tree_rmap_item);
> +		}
> +		return;
> +	}
> +
> +	/*
> +	 * A ksm page might have got here by fork or by mremap move, but
> +	 * its other references have already been removed from the tree.
> +	 */
> +	if (PageKsm(page))
> +		break_cow(rmap_item->mm, rmap_item->address);
> +
> +	/*
> +	 * In case the hash value of the page was changed from the last time we
> +	 * have calculated it, this page to be changed frequely, therefore we
> +	 * don't want to insert it to the unstable tree, and we don't want to
> +	 * waste our time to search if there is something identical to it there.
> +	 */
> +	checksum = calc_checksum(page);
> +	if (rmap_item->oldchecksum != checksum) {
> +		rmap_item->oldchecksum = checksum;
> +		return;
> +	}
> +
> +	tree_rmap_item = unstable_tree_search_insert(page, page2, rmap_item);
> +	if (tree_rmap_item) {
> +		struct tree_item *tree_item;
> +		struct mm_struct *tree_mm;
> +		unsigned long tree_addr;
> +
> +		tree_item = tree_rmap_item->tree_item;
> +		tree_mm = tree_rmap_item->mm;
> +		tree_addr = tree_rmap_item->address;
> +
> +		ret = try_to_merge_two_pages_alloc(rmap_item->mm, page, tree_mm,
> +						   page2[0], rmap_item->address,
> +						   tree_addr);
> +		/*
> +		 * As soon as we successfully merge this page, we want to remove
> +		 * the rmap_item object of the page that we have merged with
> +		 * from the unstable_tree and instead insert it as a new stable
> +		 * tree node.
> +		 */
> +		if (!ret) {
> +			rb_erase(&tree_item->node, &root_unstable_tree);
> +			/*
> +			 * If we fail to insert the page into the stable tree,
> +			 * we will have 2 virtual addresses that are pointing
> +			 * to a KsmPage left outside the stable tree,
> +			 * in which case we need to break_cow on both.
> +			 */
> +			if (stable_tree_insert(page2[0], tree_item,
> +					       tree_rmap_item) == 0) {
> +				insert_to_stable_tree_list(rmap_item,
> +							   tree_rmap_item);
> +			} else {
> +				free_tree_item(tree_item);
> +				tree_rmap_item->tree_item = NULL;
> +				break_cow(tree_mm, tree_addr);
> +				break_cow(rmap_item->mm, rmap_item->address);
> +				ksm_pages_shared -= 2;
>   

Much better handling than my kpage_outside_tree !


> +			}
> +		}
> +
> +		put_page(page2[0]);
> +	}
> +}
> +
> +static struct mm_slot *get_mm_slot(struct mm_struct *mm)
> +{
> +	struct mm_slot *mm_slot;
> +	struct hlist_head *bucket;
> +	struct hlist_node *node;
> +
> +	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
> +				% nmm_slots_hash];
> +	hlist_for_each_entry(mm_slot, node, bucket, link) {
> +		if (mm == mm_slot->mm)
> +			return mm_slot;
> +	}
> +	return NULL;
> +}
> +
> +s

Great / Excllent work Hugh!, I really like the result, no need from you 
to split it, i just have walked the code again, and i like it.
 From the perspective of features, i dont think i want to change 
anything for the merge release, about the migration/cgroup and all friends,
I think the swapping work that will be need to be taken for ksm will 
solve their problems as well, at least from infrastructure point of view.

I will run it on my server and will try to heavy load it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
