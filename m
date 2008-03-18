Date: Tue, 18 Mar 2008 15:02:18 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [6/18] Add support to have individual hstates for each hugetlbfs mount
Message-ID: <20080318150218.GF23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015819.E7ECB1B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080317015819.E7ECB1B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (17/03/08 02:58), Andi Kleen didst pronounce:
> - Add a new pagesize= option to the hugetlbfs mount that allows setting
> the page size
> - Set up pointers to a suitable hstate for the set page size option
> to the super block and the inode and the vma.
> - Change the hstate accessors to use this information
> - Add code to the hstate init function to set parsed_hstate for command
> line processing
> - Handle duplicated hstate registrations to the make command line user proof
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> ---
>  fs/hugetlbfs/inode.c    |   50 ++++++++++++++++++++++++++++++++++++++----------
>  include/linux/hugetlb.h |   12 ++++++++---
>  mm/hugetlb.c            |   22 +++++++++++++++++----
>  3 files changed, 67 insertions(+), 17 deletions(-)
> 
> Index: linux/include/linux/hugetlb.h
> ===================================================================
> --- linux.orig/include/linux/hugetlb.h
> +++ linux/include/linux/hugetlb.h
> @@ -134,6 +134,7 @@ struct hugetlbfs_config {
>  	umode_t mode;
>  	long	nr_blocks;
>  	long	nr_inodes;
> +	struct hstate *hstate;
>  };
>  
>  struct hugetlbfs_sb_info {
> @@ -142,12 +143,14 @@ struct hugetlbfs_sb_info {
>  	long	max_inodes;   /* inodes allowed */
>  	long	free_inodes;  /* inodes free */
>  	spinlock_t	stat_lock;
> +	struct hstate *hstate;

Minor nit. the other parameters are tabbed out.

>  };
>  
>  
>  struct hugetlbfs_inode_info {
>  	struct shared_policy policy;
>  	struct inode vfs_inode;
> +	struct hstate *hstate;
>  };

I'm somewhat surprised it is necessary for the hstate to be on a
per-inode basis when it's already in the hugetlbfs_sb_info. Would
HUGETLBFS_SB(inode->i_sb)->hstate not work?

>  
>  static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
> @@ -212,6 +215,7 @@ struct hstate {
>  };
>  
>  void __init huge_add_hstate(unsigned order);
> +struct hstate *huge_lookup_hstate(unsigned long pagesize);
>  

lookup_hstate_pagesize() maybe?  The name as-is told me nothing about what
it might do. It was the parameter name that gave it away.

>  #ifndef HUGE_MAX_HSTATE
>  #define HUGE_MAX_HSTATE 1
> @@ -223,17 +227,19 @@ extern struct hstate hstates[HUGE_MAX_HS
>  
>  static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
>  {
> -	return &global_hstate;
> +	return (struct hstate *)vma->vm_private_data;
>  }

It does appear that vm_private_data is currently unused and this is safe.

>  
>  static inline struct hstate *hstate_file(struct file *f)
>  {
> -	return &global_hstate;
> +	struct dentry *d = f->f_dentry;
> +	struct inode *i = d->d_inode;
> +	return HUGETLBFS_I(i)->hstate;

HUGETLBFS_SB(HUGETLBFS_I(i)->i_sb)->hstate ?

Pretty fugly I'll admit, but it's contained in a helper and keeps the
inode size down.

>  }
>  
>  static inline struct hstate *hstate_inode(struct inode *i)
>  {
> -	return &global_hstate;
> +	return HUGETLBFS_I(i)->hstate;
>  }
>  
>  static inline unsigned huge_page_size(struct hstate *h)
> Index: linux/fs/hugetlbfs/inode.c
> ===================================================================
> --- linux.orig/fs/hugetlbfs/inode.c
> +++ linux/fs/hugetlbfs/inode.c
> @@ -53,6 +53,7 @@ int sysctl_hugetlb_shm_group;
>  enum {
>  	Opt_size, Opt_nr_inodes,
>  	Opt_mode, Opt_uid, Opt_gid,
> +	Opt_pagesize,
>  	Opt_err,
>  };
>  
> @@ -62,6 +63,7 @@ static match_table_t tokens = {
>  	{Opt_mode,	"mode=%o"},
>  	{Opt_uid,	"uid=%u"},
>  	{Opt_gid,	"gid=%u"},
> +	{Opt_pagesize,	"pagesize=%s"},
>  	{Opt_err,	NULL},
>  };
>  
> @@ -92,6 +94,7 @@ static int hugetlbfs_file_mmap(struct fi
>  	 */
>  	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
>  	vma->vm_ops = &hugetlb_vm_ops;
> +	vma->vm_private_data = h;
>  
>  	if (vma->vm_pgoff & ~(huge_page_mask(h) >> PAGE_SHIFT))
>  		return -EINVAL;
> @@ -530,6 +533,7 @@ static struct inode *hugetlbfs_get_inode
>  			inode->i_op = &page_symlink_inode_operations;
>  			break;
>  		}
> +		info->hstate = HUGETLBFS_SB(sb)->hstate;
>  	}
>  	return inode;
>  }
> @@ -750,6 +754,8 @@ hugetlbfs_parse_options(char *options, s
>  	char *p, *rest;
>  	substring_t args[MAX_OPT_ARGS];
>  	int option;
> +	unsigned long long size = 0;
> +	enum { NO_SIZE, SIZE_STD, SIZE_PERCENT } setsize = NO_SIZE;
>  
>  	if (!options)
>  		return 0;
> @@ -780,17 +786,13 @@ hugetlbfs_parse_options(char *options, s
>  			break;
>  
>  		case Opt_size: {
> - 			unsigned long long size;
>  			/* memparse() will accept a K/M/G without a digit */
>  			if (!isdigit(*args[0].from))
>  				goto bad_val;
>  			size = memparse(args[0].from, &rest);
> -			if (*rest == '%') {
> -				size <<= HPAGE_SHIFT;
> -				size *= max_huge_pages;
> -				do_div(size, 100);
> -			}
> -			pconfig->nr_blocks = (size >> HPAGE_SHIFT);
> +			setsize = SIZE_STD;
> +			if (*rest == '%')
> +				setsize = SIZE_PERCENT;
>  			break;
>  		}
>  
> @@ -801,6 +803,19 @@ hugetlbfs_parse_options(char *options, s
>  			pconfig->nr_inodes = memparse(args[0].from, &rest);
>  			break;
>  
> +		case Opt_pagesize: {
> +			unsigned long ps;
> +			ps = memparse(args[0].from, &rest);
> +			pconfig->hstate = huge_lookup_hstate(ps);
> +			if (!pconfig->hstate) {
> +				printk(KERN_ERR
> +				"hugetlbfs: Unsupported page size %lu MB\n",
> +					ps >> 20);
> +				return -EINVAL;
> +			}
> +			break;
> +		}
> +
>  		default:
>  			printk(KERN_ERR "hugetlbfs: Bad mount option: \"%s\"\n",
>  				 p);
> @@ -808,6 +823,18 @@ hugetlbfs_parse_options(char *options, s
>  			break;
>  		}
>  	}
> +
> +	/* Do size after hstate is set up */
> +	if (setsize > NO_SIZE) {
> +		struct hstate *h = pconfig->hstate;
> +		if (setsize == SIZE_PERCENT) {
> +			size <<= huge_page_shift(h);
> +			size *= max_huge_pages[h - hstates];
> +			do_div(size, 100);
> +		}
> +		pconfig->nr_blocks = (size >> huge_page_shift(h));
> +	}
> +
>  	return 0;
>  
>  bad_val:
> @@ -832,6 +859,7 @@ hugetlbfs_fill_super(struct super_block 
>  	config.uid = current->fsuid;
>  	config.gid = current->fsgid;
>  	config.mode = 0755;
> +	config.hstate = &global_hstate;
>  	ret = hugetlbfs_parse_options(data, &config);
>  	if (ret)
>  		return ret;
> @@ -840,14 +868,15 @@ hugetlbfs_fill_super(struct super_block 
>  	if (!sbinfo)
>  		return -ENOMEM;
>  	sb->s_fs_info = sbinfo;
> +	sbinfo->hstate = config.hstate;
>  	spin_lock_init(&sbinfo->stat_lock);
>  	sbinfo->max_blocks = config.nr_blocks;
>  	sbinfo->free_blocks = config.nr_blocks;
>  	sbinfo->max_inodes = config.nr_inodes;
>  	sbinfo->free_inodes = config.nr_inodes;
>  	sb->s_maxbytes = MAX_LFS_FILESIZE;
> -	sb->s_blocksize = HPAGE_SIZE;
> -	sb->s_blocksize_bits = HPAGE_SHIFT;
> +	sb->s_blocksize = huge_page_size(config.hstate);
> +	sb->s_blocksize_bits = huge_page_shift(config.hstate);
>  	sb->s_magic = HUGETLBFS_MAGIC;
>  	sb->s_op = &hugetlbfs_ops;
>  	sb->s_time_gran = 1;
> @@ -949,7 +978,8 @@ struct file *hugetlb_file_setup(const ch
>  		goto out_dentry;
>  
>  	error = -ENOMEM;
> -	if (hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
> +	if (hugetlb_reserve_pages(inode, 0,
> +			size >> huge_page_shift(hstate_inode(inode))))
>  		goto out_inode;
>  
>  	d_instantiate(dentry, inode);
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -143,7 +143,7 @@ static void update_and_free_page(struct 
>  
>  static void free_huge_page(struct page *page)
>  {
> -	struct hstate *h = &global_hstate;
> +	struct hstate *h = huge_lookup_hstate(PAGE_SIZE << compound_order(page));
>  	int nid = page_to_nid(page);
>  	struct address_space *mapping;
>  
> @@ -519,7 +519,11 @@ module_init(hugetlb_init);
>  /* Should be called on processing a hugepagesz=... option */
>  void __init huge_add_hstate(unsigned order)
>  {
> -	struct hstate *h;
> +	struct hstate *h = huge_lookup_hstate(PAGE_SIZE << order);
> +	if (h) {
> +		parsed_hstate = h;
> +		return;
> +	}
>  	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
>  	BUG_ON(order <= HPAGE_SHIFT - PAGE_SHIFT);
>  	h = &hstates[max_hstate++];
> @@ -538,6 +542,16 @@ static int __init hugetlb_setup(char *s)
>  }
>  __setup("hugepages=", hugetlb_setup);
>  
> +struct hstate *huge_lookup_hstate(unsigned long pagesize)
> +{
> +	struct hstate *h;
> +	for_each_hstate (h) {
> +		if (huge_page_size(h) == pagesize)
> +			return h;
> +	}
> +	return NULL;
> +}
> +
>  static unsigned int cpuset_mems_nr(unsigned int *array)
>  {
>  	int node;
> @@ -1345,7 +1359,7 @@ out:
>  int hugetlb_reserve_pages(struct inode *inode, long from, long to)
>  {
>  	long ret, chg;
> -	struct hstate *h = &global_hstate;
> +	struct hstate *h = hstate_inode(inode);
>  
>  	chg = region_chg(&inode->i_mapping->private_list, from, to);
>  	if (chg < 0)
> @@ -1364,7 +1378,7 @@ int hugetlb_reserve_pages(struct inode *
>  
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
>  {
> -	struct hstate *h = &global_hstate;
> +	struct hstate *h = hstate_inode(inode);
>  	long chg = region_truncate(&inode->i_mapping->private_list, offset);
>  
>  	spin_lock(&inode->i_lock);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
