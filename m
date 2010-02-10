Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 044D56B004D
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 01:26:03 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id o1A6PvOZ010787
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 11:55:57 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1A6Pu0U1687728
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 11:55:57 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1A6Pupj027252
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 17:25:56 +1100
Date: Wed, 10 Feb 2010 11:55:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Make vm_max_readahead configurable at run-time
Message-ID: <20100210062555.GA2989@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <201002091659.27037.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <201002091659.27037.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Nikanth Karthikesan <knikanth@suse.de> [2010-02-09 16:59:26]:

> Make vm_max_readahead configurable at run-time. Expose a sysctl knob
> in procfs to change it. This would ensure that new disks added would
> use this value as their default read_ahead_kb.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
>

Could you help us understand how you use this? The patch is straight
forward except some of the objections pointed out by Andrew, but the
help text below should help the user understand the trade-offs of
increasing or lowering the value.
 
> ---
> 
> Index: linux-2.6/block/blk-core.c
> ===================================================================
> --- linux-2.6.orig/block/blk-core.c
> +++ linux-2.6/block/blk-core.c
> @@ -499,7 +499,7 @@ struct request_queue *blk_alloc_queue_no
>  	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
>  	q->backing_dev_info.unplug_io_data = q;
>  	q->backing_dev_info.ra_pages =
> -			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
> +			(vm_max_readahead * 1024) / PAGE_CACHE_SIZE;

Why not use (vm_max_readahead >> (PAGE_CACHE_SHIFT - 10))? While you are
looking at it, might as well clean it up :) I am quite sure the
compiler gets it right, but might as well be sure.

>  	q->backing_dev_info.state = 0;
>  	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
>  	q->backing_dev_info.name = "block";
> Index: linux-2.6/fs/fuse/inode.c
> ===================================================================
> --- linux-2.6.orig/fs/fuse/inode.c
> +++ linux-2.6/fs/fuse/inode.c
> @@ -870,7 +870,7 @@ static int fuse_bdi_init(struct fuse_con
>  	int err;
> 
>  	fc->bdi.name = "fuse";
> -	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
> +	fc->bdi.ra_pages = (vm_max_readahead * 1024) / PAGE_CACHE_SIZE;

Ditto

>  	fc->bdi.unplug_io_fn = default_unplug_io_fn;
>  	/* fuse does it's own writeback accounting */
>  	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -1188,7 +1188,11 @@ int write_one_page(struct page *page, in
>  void task_dirty_inc(struct task_struct *tsk);
> 
>  /* readahead.c */
> -#define VM_MAX_READAHEAD	128	/* kbytes */
> +#define INITIAL_VM_MAX_READAHEAD	128	/* kbytes */
> +extern unsigned long vm_max_readahead;
> +
> +int sysctl_vm_max_readahead_handler(struct ctl_table *, int,
> +					void __user *, size_t *, loff_t *);
> 
>  int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  			pgoff_t offset, unsigned long nr_to_read);
> Index: linux-2.6/mm/backing-dev.c
> ===================================================================
> --- linux-2.6.orig/mm/backing-dev.c
> +++ linux-2.6/mm/backing-dev.c
> @@ -18,7 +18,7 @@ EXPORT_SYMBOL(default_unplug_io_fn);
> 
>  struct backing_dev_info default_backing_dev_info = {
>  	.name		= "default",
> -	.ra_pages	= VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
> +	.ra_pages	= INITIAL_VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
>  	.state		= 0,
>  	.capabilities	= BDI_CAP_MAP_COPY,
>  	.unplug_io_fn	= default_unplug_io_fn,
> Index: linux-2.6/mm/readahead.c
> ===================================================================
> --- linux-2.6.orig/mm/readahead.c
> +++ linux-2.6/mm/readahead.c
> @@ -17,6 +17,19 @@
>  #include <linux/pagevec.h>
>  #include <linux/pagemap.h>
> 
> +unsigned long vm_max_readahead = INITIAL_VM_MAX_READAHEAD;
> +
> +int sysctl_vm_max_readahead_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	proc_doulongvec_minmax(table, write, buffer, length, ppos);
> +
> +	default_backing_dev_info.ra_pages =
> +			vm_max_readahead >> (PAGE_CACHE_SHIFT - 10);
> +

Aaah.. here you got it right, please be consistent and use the same
thing everywhere.

> +	return 0;
> +}
> +
>  /*
>   * Initialise a struct file's readahead state.  Assumes that the caller has
>   * memset *ra to zero.
> Index: linux-2.6/kernel/sysctl.c
> ===================================================================
> --- linux-2.6.orig/kernel/sysctl.c
> +++ linux-2.6/kernel/sysctl.c
> @@ -1273,7 +1273,13 @@ static struct ctl_table vm_table[] = {
>  		.extra2		= &one,
>  	},
>  #endif
> -
> +	{
> +		.procname	= "max_readahead_kb",
> +		.data		= &vm_max_readahead,
> +		.maxlen		= sizeof(vm_max_readahead),
> +		.mode		= 0644,
> +		.proc_handler	= sysctl_vm_max_readahead_handler,
> +	},
>  	{ }
>  };
> 
> Index: linux-2.6/Documentation/sysctl/vm.txt
> ===================================================================
> --- linux-2.6.orig/Documentation/sysctl/vm.txt
> +++ linux-2.6/Documentation/sysctl/vm.txt
> @@ -31,6 +31,7 @@ Currently, these files are in /proc/sys/
>  - laptop_mode
>  - legacy_va_layout
>  - lowmem_reserve_ratio
> +- max_readahead_kb
>  - max_map_count
>  - memory_failure_early_kill
>  - memory_failure_recovery
> @@ -263,6 +264,12 @@ The minimum value is 1 (1/1 -> 100%).
> 
>  ==============================================================
> 
> +max_readahead_kb:
> +
> +This file contains the default maximum readahead that would be used.
> +
> +==============================================================
> +
>  max_map_count:
> 
>  This file contains the maximum number of memory map areas a process
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
