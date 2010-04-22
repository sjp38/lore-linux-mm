Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D009D6B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:24:12 -0400 (EDT)
Received: by wwe15 with SMTP id 15so88859wwe.14
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 07:24:09 -0700 (PDT)
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
 PageSwapCache  pages
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	 <alpine.DEB.2.00.1004210927550.4959@router.home>
	 <20100421150037.GJ30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211004360.4959@router.home>
	 <20100421151417.GK30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211027120.4959@router.home>
	 <20100421153421.GM30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211038020.4959@router.home>
	 <20100422092819.GR30306@csn.ul.ie>
	 <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
	 <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Apr 2010 23:23:46 +0900
Message-ID: <1271946226.2100.211.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-04-22 at 19:51 +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 22 Apr 2010 19:31:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 22 Apr 2010 19:13:12 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > On Thu, Apr 22, 2010 at 6:46 PM, KAMEZAWA Hiroyuki
> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > > Hmm..in my test, the case was.
> > > >
> > > > Before try_to_unmap:
> > > >        mapcount=1, SwapCache, remap_swapcache=1
> > > > After remap
> > > >        mapcount=0, SwapCache, rc=0.
> > > >
> > > > So, I think there may be some race in rmap_walk() and vma handling or
> > > > anon_vma handling. migration_entry isn't found by rmap_walk.
> > > >
> > > > Hmm..it seems this kind patch will be required for debug.
> > > 
> 
> Ok, here is my patch for _fix_. But still testing...
> Running well at least for 30 minutes, where I can see bug in 10minutes.
> But this patch is too naive. please think about something better fix.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> At adjust_vma(), vma's start address and pgoff is updated under
> write lock of mmap_sem. This means the vma's rmap information
> update is atoimic only under read lock of mmap_sem.
> 
> 
> Even if it's not atomic, in usual case, try_to_ummap() etc...
> just fails to decrease mapcount to be 0. no problem.
> 
> But at page migration's rmap_walk(), it requires to know all
> migration_entry in page tables and recover mapcount.
> 
> So, this race in vma's address is critical. When rmap_walk meet
> the race, rmap_walk will mistakenly get -EFAULT and don't call
> rmap_one(). This patch adds a lock for vma's rmap information. 
> But, this is _very slow_.
> We need something sophisitcated, light-weight update for this..
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/mm_types.h |    1 +
>  kernel/fork.c            |    1 +
>  mm/mmap.c                |   11 ++++++++++-
>  mm/rmap.c                |    3 +++
>  4 files changed, 15 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.34-rc4-mm1/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.34-rc4-mm1.orig/include/linux/mm_types.h
> +++ linux-2.6.34-rc4-mm1/include/linux/mm_types.h
> @@ -183,6 +183,7 @@ struct vm_area_struct {
>  #ifdef CONFIG_NUMA
>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>  #endif
> +	spinlock_t adjust_lock;
>  };
>  
>  struct core_thread {
> Index: linux-2.6.34-rc4-mm1/mm/mmap.c
> ===================================================================
> --- linux-2.6.34-rc4-mm1.orig/mm/mmap.c
> +++ linux-2.6.34-rc4-mm1/mm/mmap.c
> @@ -584,13 +584,20 @@ again:			remove_next = 1 + (end > next->
>  		if (adjust_next)
>  			vma_prio_tree_remove(next, root);
>  	}
> -
> +	/*
> +	 * changing all params in atomic. If not, vma_address in rmap.c
> + 	 * can see wrong result.
> + 	 */
> +	spin_lock(&vma->adjust_lock);
>  	vma->vm_start = start;
>  	vma->vm_end = end;
>  	vma->vm_pgoff = pgoff;
> +	spin_unlock(&vma->adjust_lock);
>  	if (adjust_next) {
> +		spin_lock(&next->adjust_lock);
>  		next->vm_start += adjust_next << PAGE_SHIFT;
>  		next->vm_pgoff += adjust_next;
> +		spin_unlock(&next->adjust_lock);
>  	}
>  
>  	if (root) {
> @@ -1939,6 +1946,7 @@ static int __split_vma(struct mm_struct 
>  	*new = *vma;
>  
>  	INIT_LIST_HEAD(&new->anon_vma_chain);
> +	spin_lock_init(&new->adjust_lock);
>  
>  	if (new_below)
>  		new->vm_end = addr;
> @@ -2338,6 +2346,7 @@ struct vm_area_struct *copy_vma(struct v
>  			if (IS_ERR(pol))
>  				goto out_free_vma;
>  			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
> +			spin_lock_init(&new_vma->adjust_lock);
>  			if (anon_vma_clone(new_vma, vma))
>  				goto out_free_mempol;
>  			vma_set_policy(new_vma, pol);
> Index: linux-2.6.34-rc4-mm1/kernel/fork.c
> ===================================================================
> --- linux-2.6.34-rc4-mm1.orig/kernel/fork.c
> +++ linux-2.6.34-rc4-mm1/kernel/fork.c
> @@ -350,6 +350,7 @@ static int dup_mmap(struct mm_struct *mm
>  			goto fail_nomem;
>  		*tmp = *mpnt;
>  		INIT_LIST_HEAD(&tmp->anon_vma_chain);
> +		spin_lock_init(&tmp->adjust_lock);
>  		pol = mpol_dup(vma_policy(mpnt));
>  		retval = PTR_ERR(pol);
>  		if (IS_ERR(pol))
> Index: linux-2.6.34-rc4-mm1/mm/rmap.c
> ===================================================================
> --- linux-2.6.34-rc4-mm1.orig/mm/rmap.c
> +++ linux-2.6.34-rc4-mm1/mm/rmap.c
> @@ -332,11 +332,14 @@ vma_address(struct page *page, struct vm
>  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>  	unsigned long address;
>  
> +	spin_lock(&vma->adjust_lock);
>  	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>  	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
> +		spin_unlock(&vma->adjust_lock);
>  		/* page should be within @vma mapping range */
>  		return -EFAULT;
>  	}
> +	spin_unlock(&vma->adjust_lock);
>  	return address;
>  }
>  

Nice Catch, Kame. :)

For further optimization, we can hold vma->adjust_lock if vma_address
returns -EFAULT. But I hope we redesigns it without new locking. 
But I don't have good idea, now. :(

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
