Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 77E156B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 20:37:54 -0400 (EDT)
Date: Fri, 25 Sep 2009 09:28:07 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 8/8] memcg: migrate charge of shmem swap
Message-Id: <20090925092807.1957be1e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090924164131.b2795e37.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924145041.bcf98ab6.nishimura@mxp.nes.nec.co.jp>
	<20090924164131.b2795e37.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 16:41:31 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 24 Sep 2009 14:50:41 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch enables charge migration of shmem's swap.
> > 
> > To find the shmem's page or swap entry corresponding to a !pte_present pte,
> > this patch add a function to search them from the inode and the offset.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I think it's not good to recharge shmem pages based on tasks while
> we don't do it against file caches.
> 
In current implementation, shmem pages or file caches which in on pte(pte_present()),
will be recharged.
But in case of !pte_present, hmm, you're right. File caches are not handled by this patch.

I think I can handle it by doing like:

	if (pte_none(ptent))
		pgoff = linear_page_index(vma, addr);
	if (pte_file(ptent))
		pgoff = pte_to_pgoff(pte);

	page = find_get_page(vma->vm_file->f_mapping, pgoff);

as mincore does.

Or, I'll change this patch(perhaps mem_cgroup_get_shmem_target()) to handle
only swap.

I preffer the former.
At least, I don't want to ignore shmem's swap.

> I recommend you to implement madivce() for recharging file caches or
> shmem. Maybe there will use cases to isoalte some files/shmems's charge
> to some special groups.
> 
Do you mean MADV_MEMCG_DO/DONT_RECHARGE or some ?
If so, I think it would be make sense(I think it might be used for anon pages too).


Thanks,
Daisuke Nishimura.

> Thanks,
> -Kame
> 
> 
> > ---
> >  include/linux/swap.h |    4 ++++
> >  mm/memcontrol.c      |   21 +++++++++++++++++----
> >  mm/shmem.c           |   37 +++++++++++++++++++++++++++++++++++++
> >  3 files changed, 58 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 4ec9001..e232653 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -278,6 +278,10 @@ extern int kswapd_run(int nid);
> >  /* linux/mm/shmem.c */
> >  extern int shmem_unuse(swp_entry_t entry, struct page *page);
> >  #endif /* CONFIG_MMU */
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +extern void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> > +					struct page **pagep, swp_entry_t *ent);
> > +#endif
> >  
> >  extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
> >  
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fe0902c..1c674b0 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3310,10 +3310,23 @@ static int is_target_pte_for_migration(struct vm_area_struct *vma,
> >  	if (!pte_present(ptent)) {
> >  		if (!do_swap_account)
> >  			return 0;
> > -		/* TODO: handle swap of shmes/tmpfs */
> > -		if (pte_none(ptent) || pte_file(ptent))
> > -			return 0;
> > -		else if (is_swap_pte(ptent)) {
> > +		if (pte_none(ptent) || pte_file(ptent)) {
> > +			if (!vma->vm_file)
> > +				return 0;
> > +			if (mapping_cap_swap_backed(vma->vm_file->f_mapping)) {
> > +				struct inode *inode;
> > +				pgoff_t pgoff = 0;
> > +
> > +				inode = vma->vm_file->f_path.dentry->d_inode;
> > +				if (pte_none(ptent))
> > +					pgoff = linear_page_index(vma, addr);
> > +				if (pte_file(ptent))
> > +					pgoff = pte_to_pgoff(ptent);
> > +
> > +				mem_cgroup_get_shmem_target(inode, pgoff,
> > +								&page, &ent);
> > +			}
> > +		} else if (is_swap_pte(ptent)) {
> >  			ent = pte_to_swp_entry(ptent);
> >  			if (is_migration_entry(ent))
> >  				return 0;
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 10b7f37..96bc1b7 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -2714,3 +2714,40 @@ int shmem_zero_setup(struct vm_area_struct *vma)
> >  	vma->vm_ops = &shmem_vm_ops;
> >  	return 0;
> >  }
> > +
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/**
> > + * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
> > + * @inode: the inode to be searched
> > + * @pgoff: the offset to be searched
> > + * @pagep: the pointer for the found page to be stored
> > + * @ent: the pointer for the found swap entry to be stored
> > + *
> > + * If a page is found, refcount of it is incremented. Callers should handle
> > + * these refcount.
> > + */
> > +void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
> > +					struct page **pagep, swp_entry_t *ent)
> > +{
> > +	swp_entry_t entry = { .val = 0 }, *ptr;
> > +	struct page *page = NULL;
> > +	struct shmem_inode_info *info = SHMEM_I(inode);
> > +
> > +	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
> > +		goto out;
> > +
> > +	spin_lock(&info->lock);
> > +	ptr = shmem_swp_entry(info, pgoff, NULL);
> > +	if (ptr && ptr->val) {
> > +		entry.val = ptr->val;
> > +		page = find_get_page(&swapper_space, entry.val);
> > +	} else
> > +		page = find_get_page(inode->i_mapping, pgoff);
> > +	if (ptr)
> > +		shmem_swp_unmap(ptr);
> > +	spin_unlock(&info->lock);
> > +out:
> > +	*pagep = page;
> > +	*ent = entry;
> > +}
> > +#endif
> > -- 
> > 1.5.6.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
