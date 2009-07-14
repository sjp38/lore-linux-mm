Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 383D06B006A
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 05:31:50 -0400 (EDT)
Date: Tue, 14 Jul 2009 11:01:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH 2/2] HugeTLB mapping for drivers (export
	functions/identification of htlb mappings)
Message-ID: <20090714100157.GC28569@csn.ul.ie>
References: <alpine.LFD.2.00.0907140249240.25576@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0907140249240.25576@casper.infradead.org>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolev@infradead.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 14, 2009 at 02:50:13AM +0100, Alexey Korolev wrote:
> This patch changes the procedures of htlb file identification. 
> Since we can have non htlbfs files with htlb mapping we need to have
> another approach for identification if mapping is hugetlb or not. 

This needs to be explained better. What non-hugetlbfs file can have a
hugepage mapping? You might mean drivers but they don't exist at this
point so someone looking at the changelog in isolation might get
confused.

> This part is rather doubtful. Just checking of file operations seems
> to be a bad approach as drivers (as well as ipc/shm) need have own
> file_operations. The best place for identification of hugetlb mappings could be 
> maping->flags. But I'm still not sure if it is the best place. 
> 
> This patch slightly modifies the procedure of getting hstate from inode.
> If inode correspond to hugetlbfs - the hugetlbfs hstate will be
> returned, otherwise hstate_nores.
> 
> Also this patch exports/declares some hugetlb/htlbfs functions for use of drivers.
> 
>  fs/hugetlbfs/inode.c    |    9 +++++----
>  include/linux/hugetlb.h |   45 +++++++++++++++++++++++++++------------------
>  include/linux/pagemap.h |   13 +++++++++++++
>  include/linux/shm.h     |    5 -----
>  ipc/shm.c               |   12 ------------
>  mm/filemap.c            |    1 +
>  6 files changed, 46 insertions(+), 39 deletions(-)
> ---
> Signed-off-by: Alexey Korolev <akorolev@infradead.org>
> 
> diff -aurp ORIG/fs/hugetlbfs/inode.c NEW/fs/hugetlbfs/inode.c
> --- ORIG/fs/hugetlbfs/inode.c	2009-07-05 05:58:48.000000000 +1200
> +++ NEW/fs/hugetlbfs/inode.c	2009-07-11 10:23:00.000000000 +1200
> @@ -34,9 +34,6 @@
>  
>  #include <asm/uaccess.h>
>  
> -/* some random number */
> -#define HUGETLBFS_MAGIC	0x958458f6
> -
>  static const struct super_operations hugetlbfs_ops;
>  static const struct address_space_operations hugetlbfs_aops;
>  const struct file_operations hugetlbfs_file_operations;
> @@ -77,7 +74,7 @@ static void huge_pagevec_release(struct 
>  	pagevec_reinit(pvec);
>  }
>  
> -static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
> +int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  {
>  	struct inode *inode = file->f_path.dentry->d_inode;
>  	loff_t len, vma_len;
> @@ -121,6 +118,7 @@ out:
>  
>  	return ret;
>  }
> +EXPORT_SYMBOL(hugetlbfs_file_mmap);
>  
>  /*
>   * Called under down_write(mmap_sem).
> @@ -183,6 +181,7 @@ full_search:
>  	}
>  }
>  #endif
> +EXPORT_SYMBOL(hugetlb_get_unmapped_area);
>  

I think the patch that exports symbols from hugetlbfs needs to be a
separate patch explaining why they need to be exported for drivers to
take advantage of.

>  static int
>  hugetlbfs_read_actor(struct page *page, unsigned long offset,
> @@ -512,6 +511,7 @@ static struct inode *hugetlbfs_get_inode
>  			init_special_inode(inode, mode, dev);
>  			break;
>  		case S_IFREG:
> +			mapping_set_hugetlb(inode->i_mapping);
>  			inode->i_op = &hugetlbfs_inode_operations;
>  			inode->i_fop = &hugetlbfs_file_operations;
>  			break;
> @@ -988,6 +988,7 @@ struct file *hugetlb_file_setup(const ch
>  	if (!file)
>  		goto out_dentry; /* inode is already attached */
>  	ima_counts_get(file);
> +	mapping_set_hugetlb(file->f_mapping);
>  

At a first reading, I was not getting why there needs to be a new way
of identifying if a mapping is hugetlbfs-backed or not.  I get that it's
because drivers will have file_operations that we cannot possibly know about
in advance, particularly if they are loaded as modules but this really needs
it's own patch and changelog spelling it out. It also again raises the
question of why drivers would not use the internal hugetlbfs mount like
shm does.

>  	return file;
>  
> diff -aurp ORIG/include/linux/hugetlb.h NEW/include/linux/hugetlb.h
> --- ORIG/include/linux/hugetlb.h	2009-07-05 05:58:48.000000000 +1200
> +++ NEW/include/linux/hugetlb.h	2009-07-13 06:58:00.000000000 +1200
> @@ -5,6 +5,9 @@
>  
>  #ifdef CONFIG_HUGETLB_PAGE
>  
> +/* some random number */
> +#define HUGETLBFS_MAGIC	0x958458f6
> +
>  #include <linux/mempolicy.h>
>  #include <linux/shm.h>
>  #include <asm/tlbflush.h>
> @@ -61,6 +64,9 @@ int pud_huge(pud_t pmd);
>  void hugetlb_change_protection(struct vm_area_struct *vma,
>  		unsigned long address, unsigned long end, pgprot_t newprot);
>  
> +struct page *hugetlb_alloc_pages_node(int nid, gfp_t gfp_mask);
> +void hugetlb_free_pages(struct page *page);
> +

This looks like it belongs in the previous patch.

>  #else /* !CONFIG_HUGETLB_PAGE */
>  
>  static inline int PageHuge(struct page *page)
> @@ -102,6 +108,10 @@ static inline void hugetlb_report_meminf
>  
>  #define hugetlb_change_protection(vma, address, end, newprot)
>  
> +#define hugetlb_alloc_pages_node(nid, gfp_mask) 0
> +#define hugetlb_free_pages(page) BUG();
> +
> +

Ditto and some unnecessary whitespace there.

>  #ifndef HPAGE_MASK
>  #define HPAGE_MASK	PAGE_MASK		/* Keep the compiler happy */
>  #define HPAGE_SIZE	PAGE_SIZE
> @@ -152,31 +162,26 @@ void hugetlb_put_quota(struct address_sp
>  
>  static inline int is_file_hugepages(struct file *file)
>  {
> -	if (file->f_op == &hugetlbfs_file_operations)
> -		return 1;
> -	if (is_file_shm_hugepages(file))
> -		return 1;
> -
> -	return 0;
> +	return mapping_hugetlb(file->f_mapping);
>  }
>  
> -static inline void set_file_hugepages(struct file *file)
> -{
> -	file->f_op = &hugetlbfs_file_operations;
> -}
> +int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma);
> +
> +unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
> +			unsigned long len, unsigned long pgoff,
> +			unsigned long flags);
> +

Having the new exports and the new method for identifying if a file or
mapping is hugetlbfs in the same patch does make this harder. I see
nothing wrong with the above changes as such but I'm hard-wired into
thinking that everything in a patch is directly related.

>  #else /* !CONFIG_HUGETLBFS */
>  
>  #define is_file_hugepages(file)			0
> -#define set_file_hugepages(file)		BUG()
>  #define hugetlb_file_setup(name,size,acctflag)	ERR_PTR(-ENOSYS)
>  
> +#define hugetlbfs_file_mmap(file, vma) (-ENOSYS)
> +#define hugetlb_get_unmapped_area(file, addr, len, \
> +		pgoff, flags) (-ENOSYS)
> +
>  #endif /* !CONFIG_HUGETLBFS */
>  
> -#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
> -unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
> -					unsigned long len, unsigned long pgoff,
> -					unsigned long flags);
> -#endif /* HAVE_ARCH_HUGETLB_UNMAPPED_AREA */
>  
>  #ifdef CONFIG_HUGETLB_PAGE
>  
> @@ -216,14 +221,18 @@ struct hstate *size_to_hstate(unsigned l
>  
>  extern struct hstate hstates[HUGE_MAX_HSTATE];
>  extern unsigned int default_hstate_idx;
> +extern struct hstate hstate_nores;
>  
>  #define default_hstate (hstates[default_hstate_idx])
>  
>  static inline struct hstate *hstate_inode(struct inode *i)
>  {
>  	struct hugetlbfs_sb_info *hsb;
> -	hsb = HUGETLBFS_SB(i->i_sb);
> -	return hsb->hstate;
> +	if (i->i_sb->s_magic == HUGETLBFS_MAGIC) {
> +		hsb = HUGETLBFS_SB(i->i_sb);
> +		return hsb->hstate;
> +	}
> +	return &hstate_nores;

This needs a comment and the changelog needs to spell out better that you are
expanding what hugetlbfs is. This chunk is basically saying that it's possible
to have an inode that is backed by hugepages but that is not a hugetlbfs
file. Your changelog needs to explain why hugetlbfs files were not created
in the same way they are created for shared memory mappings on the internal
hugetlbfs mount. Maybe we discussed this before but I forget the reasoning.

>  }
>  
>  static inline struct hstate *hstate_file(struct file *f)
> diff -aurp ORIG/include/linux/pagemap.h NEW/include/linux/pagemap.h
> --- ORIG/include/linux/pagemap.h	2009-07-05 05:58:48.000000000 +1200
> +++ NEW/include/linux/pagemap.h	2009-07-11 08:29:00.000000000 +1200
> @@ -23,6 +23,7 @@ enum mapping_flags {
>  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> +	AS_HUGETLB	= __GFP_BITS_SHIFT + 4,	/* under HUGE TLB */
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> @@ -52,6 +53,18 @@ static inline int mapping_unevictable(st
>  	return !!mapping;
>  }
>  
> +static inline void mapping_set_hugetlb(struct address_space *mapping)
> +{
> +	set_bit(AS_HUGETLB, &mapping->flags);
> +}
> +
> +static inline int mapping_hugetlb(struct address_space *mapping)
> +{
> +	if (likely(mapping))
> +		return test_bit(AS_HUGETLB, &mapping->flags);
> +	return !!mapping;
> +}

That !!mapping looks a bit unnecessary.  Why is !!NULL always going to
evaluate to 0?  I know it's copying from mapping_unevictable(), but that
doesn't help me figure out why it looks like that.

> +
>  static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
>  {
>  	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
> diff -aurp ORIG/include/linux/shm.h NEW/include/linux/shm.h
> --- ORIG/include/linux/shm.h	2009-07-05 05:58:48.000000000 +1200
> +++ NEW/include/linux/shm.h	2009-07-11 08:29:00.000000000 +1200
> @@ -105,17 +105,12 @@ struct shmid_kernel /* private to the ke
>  
>  #ifdef CONFIG_SYSVIPC
>  long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr);
> -extern int is_file_shm_hugepages(struct file *file);
>  #else
>  static inline long do_shmat(int shmid, char __user *shmaddr,
>  				int shmflg, unsigned long *addr)
>  {
>  	return -ENOSYS;
>  }
> -static inline int is_file_shm_hugepages(struct file *file)
> -{
> -	return 0;
> -}
>  #endif
>  
>  #endif /* __KERNEL__ */
> diff -aurp ORIG/ipc/shm.c NEW/ipc/shm.c
> --- ORIG/ipc/shm.c	2009-07-05 05:58:48.000000000 +1200
> +++ NEW/ipc/shm.c	2009-07-11 08:29:00.000000000 +1200
> @@ -293,18 +293,6 @@ static unsigned long shm_get_unmapped_ar
>  	return get_unmapped_area(sfd->file, addr, len, pgoff, flags);
>  }
>  
> -int is_file_shm_hugepages(struct file *file)
> -{
> -	int ret = 0;
> -
> -	if (file->f_op == &shm_file_operations) {
> -		struct shm_file_data *sfd;
> -		sfd = shm_file_data(file);
> -		ret = is_file_hugepages(sfd->file);
> -	}
> -	return ret;
> -}
> -
>  static const struct file_operations shm_file_operations = {
>  	.mmap		= shm_mmap,
>  	.fsync		= shm_fsync,
> diff -aurp ORIG/mm/filemap.c NEW/mm/filemap.c
> --- ORIG/mm/filemap.c	2009-07-05 05:58:48.000000000 +1200
> +++ NEW/mm/filemap.c	2009-07-11 08:29:00.000000000 +1200
> @@ -146,6 +146,7 @@ void remove_from_page_cache(struct page 
>  	spin_unlock_irq(&mapping->tree_lock);
>  	mem_cgroup_uncharge_cache_page(page);
>  }
> +EXPORT_SYMBOL(remove_from_page_cache);
>  
>  static int sync_page(void *word)
>  {
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
