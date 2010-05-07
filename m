Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 47A026200AA
	for <linux-mm@kvack.org>; Thu,  6 May 2010 21:01:04 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o47111Gt005080
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 10:01:02 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AA4CE45DE4F
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:01:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A5BD45DE53
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:01:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EE181DB803F
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:01:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E4AC1DB8043
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:00:56 +0900 (JST)
Date: Fri, 7 May 2010 09:56:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100507095654.a8097967.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1273188053-26029-2-git-send-email-mel@csn.ul.ie>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
	<1273188053-26029-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri,  7 May 2010 00:20:52 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> vma_adjust() is updating anon VMA information without locks being taken.
> In contrast, file-backed mappings use the i_mmap_lock and this lack of
> locking can result in races with users of rmap_walk such as page migration.
> vma_address() can return -EFAULT for an address that will soon be valid.
> For migration, this potentially leaves a dangling migration PTE behind
> which can later cause a BUG_ON to trigger when the page is faulted in.
> 
> With the recent anon_vma changes, there can be more than one anon_vma->lock
> to take when walking a list of anon_vma_chains but as the order of anon_vmas
> cannot be guaranteed, rmap_walk cannot take multiple locks without
> potentially deadlocking.
> 
> To resolve this problem, this patch has rmap_walk walk the anon_vma_chain
> list but always starting from the "root" anon_vma which is the oldest
> anon_vma in the list. It starts by locking the anon_vma lock associated
> with a page. It then finds the "root" anon_vma using the anon_vma_chains
> "same_vma" list as it is strictly ordered. The root anon_vma lock is taken
> and rmap_walk traverses the list. This allows multiple locks to be taken
> as the list is always traversed in the same direction.
> 
> As spotted by Rik, to avoid any deadlocks versus mmu_notify, the order that
> anon_vmas is locked in by mm_take_all_locks is reversed by this patch so that
> both rmap_walk and mm_take_all_locks lock anon_vmas in the order of old->new.
> 
> For vma_adjust(), the locking behaviour prior to the anon_vma is restored
> so that rmap_walk() can be sure of the integrity of the VMA information and
> lists when the anon_vma lock is held. With this patch, the vma->anon_vma->lock
> is taken if
> 
> 	a) If there is any overlap with the next VMA due to the adjustment
> 	b) If there is a new VMA is being inserted into the address space
> 	c) If the start of the VMA is being changed so that the
> 	   relationship between vm_start and vm_pgoff is preserved
> 	   for vma_address()
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/rmap.h |    4 ++
>  mm/ksm.c             |   13 ++++++-
>  mm/mmap.c            |   14 ++++++-
>  mm/rmap.c            |   97 ++++++++++++++++++++++++++++++++++++++++++++++----
>  4 files changed, 118 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 7721674..1dc949f 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -121,6 +121,10 @@ int  anon_vma_prepare(struct vm_area_struct *);
>  void unlink_anon_vmas(struct vm_area_struct *);
>  int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
>  int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
> +struct anon_vma *anon_vma_lock_nested(struct anon_vma *prev,
> +			struct anon_vma *next, struct anon_vma *root);
> +struct anon_vma *anon_vma_lock_root(struct anon_vma *anon_vma);
> +struct anon_vma *page_anon_vma_lock_root(struct page *page);
>  void __anon_vma_link(struct vm_area_struct *);
>  void anon_vma_free(struct anon_vma *);
>  
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 3666d43..1db8656 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1655,6 +1655,7 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
>  {
>  	struct stable_node *stable_node;
>  	struct hlist_node *hlist;
> +	struct anon_vma *nested_anon_vma = NULL;
>  	struct rmap_item *rmap_item;
>  	int ret = SWAP_AGAIN;
>  	int search_new_forks = 0;
> @@ -1671,9 +1672,16 @@ again:
>  		struct anon_vma_chain *vmac;
>  		struct vm_area_struct *vma;
>  
> -		spin_lock(&anon_vma->lock);
> +		anon_vma = anon_vma_lock_root(anon_vma);
> +		if (nested_anon_vma) {
> +			spin_unlock(&nested_anon_vma->lock);
> +			nested_anon_vma = NULL;
> +		}
>  		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
>  			vma = vmac->vma;
> +			nested_anon_vma = anon_vma_lock_nested(nested_anon_vma,
> +						vma->anon_vma, anon_vma);
> +
>  			if (rmap_item->address < vma->vm_start ||
>  			    rmap_item->address >= vma->vm_end)
>  				continue;
> @@ -1697,6 +1705,9 @@ again:
>  	if (!search_new_forks++)
>  		goto again;
>  out:
> +	if (nested_anon_vma)
> +		spin_unlock(&nested_anon_vma->lock);
> +
>  	return ret;
>  }
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f90ea92..b447d5b 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -505,6 +505,7 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	struct vm_area_struct *next = vma->vm_next;
>  	struct vm_area_struct *importer = NULL;
>  	struct address_space *mapping = NULL;
> +	struct anon_vma *anon_vma = NULL;
>  	struct prio_tree_root *root = NULL;
>  	struct file *file = vma->vm_file;
>  	long adjust_next = 0;
> @@ -578,6 +579,11 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		}
>  	}
>  
> +	if (vma->anon_vma && (insert || importer || start != vma->vm_start)) {
> +		anon_vma = vma->anon_vma;
> +		spin_lock(&anon_vma->lock);
> +	}
> +
>  	if (root) {
>  		flush_dcache_mmap_lock(mapping);
>  		vma_prio_tree_remove(vma, root);
> @@ -620,6 +626,9 @@ again:			remove_next = 1 + (end > next->vm_end);
>  	if (mapping)
>  		spin_unlock(&mapping->i_mmap_lock);
>  
> +	if (anon_vma)
> +		spin_unlock(&anon_vma->lock);
> +
>  	if (remove_next) {
>  		if (file) {
>  			fput(file);
> @@ -2556,8 +2565,9 @@ int mm_take_all_locks(struct mm_struct *mm)
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		if (signal_pending(current))
>  			goto out_unlock;
> +		/* Lock the anon_vmas in the same order rmap_walk would */
>  		if (vma->anon_vma)
> -			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
> +			list_for_each_entry_reverse(avc, &vma->anon_vma_chain, same_vma)
>  				vm_lock_anon_vma(mm, avc->anon_vma);
>  	}
>  
> @@ -2620,7 +2630,7 @@ void mm_drop_all_locks(struct mm_struct *mm)
>  
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		if (vma->anon_vma)
> -			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
> +			list_for_each_entry_reverse(avc, &vma->anon_vma_chain, same_vma)
>  				vm_unlock_anon_vma(avc->anon_vma);
>  		if (vma->vm_file && vma->vm_file->f_mapping)
>  			vm_unlock_mapping(vma->vm_file->f_mapping);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 85f203e..2e65a75 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -236,6 +236,81 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>  	return -ENOMEM;
>  }
>  
> +/*
> + * When walking an anon_vma_chain and locking each anon_vma encountered,
> + * this function is responsible for checking if the next VMA is the
> + * same as the root, locking it if not and released the previous lock
> + * if necessary.
> + *
> + * It is assumed the caller has locked the root anon_vma
> + */
> +struct anon_vma *anon_vma_lock_nested(struct anon_vma *prev,
> +			struct anon_vma *next, struct anon_vma *root)
> +{
> +	if (prev)
> +		spin_unlock(&prev->lock);
> +	if (next == root)
> +		return NULL;
> +	spin_lock_nested(&next->lock, SINGLE_DEPTH_NESTING);
> +	return next;
> +}
> +
> +/*
> + * Given an anon_vma, find the root of the chain, lock it and return the
> + * root. This must be called with the rcu_read_lock held
> + */
> +struct anon_vma *anon_vma_lock_root(struct anon_vma *anon_vma)
> +{
> +	struct anon_vma *root_anon_vma;
> +	struct anon_vma_chain *avc, *root_avc;
> +	struct vm_area_struct *vma;
> +
> +	/* Lock the same_anon_vma list and make sure we are on a chain */
> +	spin_lock(&anon_vma->lock);
> +	if (list_empty(&anon_vma->head)) {
> +		spin_unlock(&anon_vma->lock);
> +		return NULL;
> +	}
> +
> +	/*
> +	 * Get the root anon_vma on the list by depending on the ordering
> +	 * of the same_vma list setup by __page_set_anon_rmap. Basically
> +	 * we are doing
> +	 *
> +	 * local anon_vma -> local vma -> root vma -> root anon_vma
> +	 */
> +	avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> +	vma = avc->vma;
> +	root_avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
> +	root_anon_vma = root_avc->anon_vma;
> +
> +	/* Get the lock of the root anon_vma */
> +	if (anon_vma != root_anon_vma) {
> +		VM_BUG_ON(!rcu_read_lock_held());
> +		spin_unlock(&anon_vma->lock);
> +		spin_lock(&root_anon_vma->lock);
> +	}

I'm sorry but I don't think I understand this. Could you help me ?

IIUC, anon_vma_chain is linked as 2D-mesh

            anon_vma1    anon_vma2    anon_vma3
                |            |            |
    vma1 -----  1  --------  2  --------- 3 -----
                |            |            |
    vma2 -----  4  --------  5 ---------- 6 -----
                |            |            |
    vma3 -----  7  --------  8 ---------- 9 -----


Here,
  * vertical link is anon_vma->head, avc->same_anon_vma link.
  * horizontal link is vma->anon_vma_chain, avc->same_vma link.
  * 1-9 are avcs.

When scanning pages, we may see a page whose anon_vma is anon_vma1
or anon_vma2 or anon_vma3. 

When we see anon_vma3 in page->mapping, we lock anon_vma1 and chase
avc1->avc4->avc7. Then, start from vma1. Next, we visit vma2, we lock anon_vma2.
At the last, we visit vma3 and lock anon_vma3.....And all are done under
anon_vma1->lock. Right ?

Hmm, one concern is 
	anon_vma3 -> avc3 -> vma1 -> avc1 -> anon_vma1 chasing.

What will prevent vma1 disappear right after releasling anon_vma3->lock ?

ex)
a1) At we chase, anon_vma3 -> avc3 -> vma1 -> anon_vma1, link was following.

            anon_vma1    anon_vma2    anon_vma3
                |            |            |
    vma1 -----  1  --------  2  --------- 3 -----
                |            |            |
    vma2 -----  4  --------  5 ---------- 6 -----
                |            |            |
    vma3 -----  7  --------  8 ---------- 9 -----
 
   We hold lock on anon_vma3.

a2) After releasing anon_vma3 lock. vma1 can be unlinked.

            anon_vma1    anon_vma2    anon_vma3
                |            |            |
 vma1 removed.
                |            |            |
    vma2 -----  4  --------  5 ---------- 6 -----
                |            |            |
    vma3 -----  7  --------  8 ---------- 9 -----

But we know anon_vma1->head is not empty, and it's accessable.
Then, no problem for our purpose. Right ?

b1) Another thinking.

At we chase, anon_vma3 -> avc3 -> vma1 -> anon_vma1, link was following.

            anon_vma1    anon_vma2    anon_vma3
                |            |            |
    vma1 -----  1  --------  2  --------- 3 -----
                |            |            |
    vma2 -----  4  --------  5 ---------- 6 -----
                |            |            |
    vma3 -----  7  --------  8 ---------- 9 -----
 
   We hold lock on anon_vma3. So, 

            anon_vma1    anon_vma2    anon_vma3
                |            |            |
    vma1 ----removed -----removed  ------ 3 -----
                |            |            |
    vma2 -----  4  --------  5 ---------- 6 -----
                |            |            |
    vma3 -----  7  --------  8 ---------- 9 -----

we may see half-broken link while we take anon_vma3->lock. In this case,
anon_vma1 can be caugt.

Don't we need this ?


 void unlink_anon_vmas(struct vm_area_struct *vma)
 {
        struct anon_vma_chain *avc, *next;

        /* Unlink each anon_vma chained to the VMA. */
-        list_for_each_entry_safe_reverse(avc, next, &vma->anon_vma_chain, same_vma) {
+        list_for_each_entry_safe_reverse(avc, next, &vma->anon_vma_chain, same_vma) {
                anon_vma_unlink(avc);
                list_del(&avc->same_vma);
                anon_vma_chain_free(avc);
         }
 }

head avc should be removed last...  Hmm ? I'm sorry if all are
in correct order already.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
