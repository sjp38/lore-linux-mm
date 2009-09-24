Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2DF626B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 03:43:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O7hgeK018446
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 16:43:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A608F45DE51
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:43:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7482145DE4F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:43:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 58E8DE38001
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:43:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F3C31E08006
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 16:43:41 +0900 (JST)
Date: Thu, 24 Sep 2009 16:41:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 8/8] memcg: migrate charge of shmem swap
Message-Id: <20090924164131.b2795e37.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090924145041.bcf98ab6.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924145041.bcf98ab6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 14:50:41 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch enables charge migration of shmem's swap.
> 
> To find the shmem's page or swap entry corresponding to a !pte_present pte,
> this patch add a function to search them from the inode and the offset.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I think it's not good to recharge shmem pages based on tasks while
we don't do it against file caches.

I recommend you to implement madivce() for recharging file caches or
shmem. Maybe there will use cases to isoalte some files/shmems's charge
to some special groups.

Thanks,
-Kame


> ---
>  include/linux/swap.h |    4 ++++
>  mm/memcontrol.c      |   21 +++++++++++++++++----
>  mm/shmem.c           |   37 +++++++++++++++++++++++++++++++++++++
>  3 files changed, 58 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 4ec9001..e232653 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -278,6 +278,10 @@ extern int kswapd_run(int nid);
>  /* linux/mm/shmem.c */
>  extern int shmem_unuse(swp_entry_t entry, struct page *page);
>  #endif /* CONFIG_MMU */
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +extern void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> +					struct page **pagep, swp_entry_t *ent);
> +#endif
>  
>  extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fe0902c..1c674b0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3310,10 +3310,23 @@ static int is_target_pte_for_migration(struct vm_area_struct *vma,
>  	if (!pte_present(ptent)) {
>  		if (!do_swap_account)
>  			return 0;
> -		/* TODO: handle swap of shmes/tmpfs */
> -		if (pte_none(ptent) || pte_file(ptent))
> -			return 0;
> -		else if (is_swap_pte(ptent)) {
> +		if (pte_none(ptent) || pte_file(ptent)) {
> +			if (!vma->vm_file)
> +				return 0;
> +			if (mapping_cap_swap_backed(vma->vm_file->f_mapping)) {
> +				struct inode *inode;
> +				pgoff_t pgoff = 0;
> +
> +				inode = vma->vm_file->f_path.dentry->d_inode;
> +				if (pte_none(ptent))
> +					pgoff = linear_page_index(vma, addr);
> +				if (pte_file(ptent))
> +					pgoff = pte_to_pgoff(ptent);
> +
> +				mem_cgroup_get_shmem_target(inode, pgoff,
> +								&page, &ent);
> +			}
> +		} else if (is_swap_pte(ptent)) {
>  			ent = pte_to_swp_entry(ptent);
>  			if (is_migration_entry(ent))
>  				return 0;
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 10b7f37..96bc1b7 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2714,3 +2714,40 @@ int shmem_zero_setup(struct vm_area_struct *vma)
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
> 1.5.6.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
