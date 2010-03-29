Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 49F846B01B8
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 00:40:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2T4eZ0J026656
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Mar 2010 13:40:35 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BC6145DE52
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:40:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D490045DE50
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:40:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E080FEF8001
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:40:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 814801DB8040
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:40:30 +0900 (JST)
Date: Mon, 29 Mar 2010 13:36:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 2/2] memcg move charge of shmem at task migration
Message-Id: <20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010 12:03:59 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch adds support for moving charge of shmem and swap of it. It's enabled
> by setting bit 2 of <target cgroup>/memory.move_charge_at_immigrate.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  Documentation/cgroups/memory.txt |    7 +++-
>  include/linux/swap.h             |    5 +++
>  mm/memcontrol.c                  |   52 +++++++++++++++++++++++++------------
>  mm/shmem.c                       |   37 +++++++++++++++++++++++++++
>  4 files changed, 82 insertions(+), 19 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index f53d220..b197d60 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -464,13 +464,16 @@ charges should be moved.
>   -----+------------------------------------------------------------------------
>     1  | A charge of file cache mmap'ed by the target task. Those pages must be
>        | mmap'ed only by the target task.
> + -----+------------------------------------------------------------------------
> +   2  | A charge of a tmpfs page(or swap of it) mmap'ed by the target task. A
> +      | typical use case of it is ipc shared memory. It must be mmap'ed by the
> +      | target task, but unlike above 2 cases, the task may not be the only one.
> +      | You must enable Swap Extension(see 2.4) to enable move of swap charges.
>  
>  Note: Those pages and swaps must be charged to the old cgroup.
> -Note: More type of pages(e.g. shmem) will be supported by other bits in future.
>  
>  8.3 TODO
>  
> -- Add support for other types of pages(e.g. file cache, shmem, etc.).
>  - Implement madvise(2) to let users decide the vma to be moved or not to be
>    moved.
>  - All of moving charge operations are done under cgroup_mutex. It's not good
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 1f59d93..94ec325 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -285,6 +285,11 @@ extern void kswapd_stop(int nid);
>  extern int shmem_unuse(swp_entry_t entry, struct page *page);
>  #endif /* CONFIG_MMU */
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +extern void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> +					struct page **pagep, swp_entry_t *ent);
> +#endif
> +
>  extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
>  
>  #ifdef CONFIG_SWAP
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 66d2704..99a496c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -251,6 +251,7 @@ struct mem_cgroup {
>  enum move_type {
>  	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
>  	MOVE_CHARGE_TYPE_FILE,	/* private file caches */
> +	MOVE_CHARGE_TYPE_SHMEM,	/* shared memory and swap of it */
>  	NR_MOVE_TYPE,
>  };
>  
> @@ -4195,12 +4196,30 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  					&mc.to->move_charge_at_immigrate);
>  	bool move_file = test_bit(MOVE_CHARGE_TYPE_FILE,
>  					&mc.to->move_charge_at_immigrate);
> +	bool move_shmem = test_bit(MOVE_CHARGE_TYPE_SHMEM,
> +					&mc.to->move_charge_at_immigrate);
> +	bool is_shmem = false;
>  
>  	if (!pte_present(ptent)) {
> -		/* TODO: handle swap of shmes/tmpfs */
> -		if (pte_none(ptent) || pte_file(ptent))
> -			return 0;
> -		else if (is_swap_pte(ptent)) {
> +		if (pte_none(ptent) || pte_file(ptent)) {
> +			struct inode *inode;
> +			struct address_space *mapping;
> +			pgoff_t pgoff = 0;
> +
> +			if (!vma->vm_file)
> +				return 0;
> +			mapping = vma->vm_file->f_mapping;
> +			if (!move_shmem || !mapping_cap_swap_backed(mapping))
> +				return 0;
> +
> +			if (pte_none(ptent))
> +				pgoff = linear_page_index(vma, addr);
> +			if (pte_file(ptent))
> +				pgoff = pte_to_pgoff(ptent);

Hmm...then, a shmem page is moved even if the task doesn't do page-fault.
Could you clarify
	"All pages in the range mapped by a task will be moved to the new group
	 even if the task doesn't do page fault, i.e. not tasks' RSS."
?
Thanks,
-Kame

> +			inode = vma->vm_file->f_path.dentry->d_inode;
> +			mem_cgroup_get_shmem_target(inode, pgoff, &page, &ent);




> +			is_shmem = true;
> +		} else if (is_swap_pte(ptent)) {
>  			ent = pte_to_swp_entry(ptent);
>  			if (!move_anon || non_swap_entry(ent))
>  				return 0;
> @@ -4210,26 +4229,22 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  		page = vm_normal_page(vma, addr, ptent);
>  		if (!page || !page_mapped(page))
>  			return 0;
> -		/*
> -		 * TODO: We don't move charges of shmem/tmpfs pages for now.
> -		 */
>  		if (PageAnon(page)) {
>  			if (!move_anon)
>  				return 0;
>  		} else if (page_is_file_cache(page)) {
>  			if (!move_file)
>  				return 0;
> -		} else
> -			return 0;
> +		} else {
> +			if (!move_shmem)
> +				return 0;
> +			is_shmem = true;
> +		}
>  		if (!get_page_unless_zero(page))
>  			return 0;
>  		usage_count = page_mapcount(page);
>  	}
> -	if (usage_count > 1) {
> -		/*
> -		 * TODO: We don't move charges of shared(used by multiple
> -		 * processes) pages for now.
> -		 */
> +	if (usage_count > 1 && !is_shmem) {
>  		if (page)
>  			put_page(page);
>  		return 0;
> @@ -4284,6 +4299,8 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
>  
>  	down_read(&mm->mmap_sem);
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		bool move_shmem = test_bit(MOVE_CHARGE_TYPE_SHMEM,
> +					&mc.to->move_charge_at_immigrate);
>  		struct mm_walk mem_cgroup_count_precharge_walk = {
>  			.pmd_entry = mem_cgroup_count_precharge_pte_range,
>  			.mm = mm,
> @@ -4292,7 +4309,7 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
>  		if (is_vm_hugetlb_page(vma))
>  			continue;
>  		/* TODO: We don't move charges of shmem/tmpfs pages for now. */
> -		if (vma->vm_flags & VM_SHARED)
> +		if ((vma->vm_flags & VM_SHARED) && !move_shmem)
>  			continue;
>  		walk_page_range(vma->vm_start, vma->vm_end,
>  					&mem_cgroup_count_precharge_walk);
> @@ -4483,6 +4500,8 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
>  	down_read(&mm->mmap_sem);
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		int ret;
> +		bool move_shmem = test_bit(MOVE_CHARGE_TYPE_SHMEM,
> +					&mc.to->move_charge_at_immigrate);
>  		struct mm_walk mem_cgroup_move_charge_walk = {
>  			.pmd_entry = mem_cgroup_move_charge_pte_range,
>  			.mm = mm,
> @@ -4490,8 +4509,7 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
>  		};
>  		if (is_vm_hugetlb_page(vma))
>  			continue;
> -		/* TODO: We don't move charges of shmem/tmpfs pages for now. */
> -		if (vma->vm_flags & VM_SHARED)
> +		if ((vma->vm_flags & VM_SHARED) && !move_shmem)
>  			continue;
>  		ret = walk_page_range(vma->vm_start, vma->vm_end,
>  						&mem_cgroup_move_charge_walk);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index dde4363..cb87365 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2701,3 +2701,40 @@ int shmem_zero_setup(struct vm_area_struct *vma)
>  	vma->vm_ops = &shmem_vm_ops;
>  	return 0;
>  }
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/**
> + * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
> + * @inode: the inode to be searched
> + * @pgoff: the offset to be searched
> + * @pagep: the pointer for the found page to be stored
> + * @ent: the pointer for the found swap entry to be stored
> + *
> + * If a page is found, refcount of it is incremented. Callers should handle
> + * these refcount.
> + */
> +void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> +					struct page **pagep, swp_entry_t *ent)
> +{
> +	swp_entry_t entry = { .val = 0 }, *ptr;
> +	struct page *page = NULL;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +
> +	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
> +		goto out;
> +
> +	spin_lock(&info->lock);
> +	ptr = shmem_swp_entry(info, pgoff, NULL);
> +	if (ptr && ptr->val) {
> +		entry.val = ptr->val;
> +		page = find_get_page(&swapper_space, entry.val);
> +	} else
> +		page = find_get_page(inode->i_mapping, pgoff);
> +	if (ptr)
> +		shmem_swp_unmap(ptr);
> +	spin_unlock(&info->lock);
> +out:
> +	*pagep = page;
> +	*ent = entry;
> +}
> +#endif
> -- 
> 1.6.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
