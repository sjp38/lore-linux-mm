Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E80A86B004D
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:51:46 -0500 (EST)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH v2] Make vm_max_readahead configurable at run-time
Date: Wed, 10 Feb 2010 19:22:40 +0530
References: <201002091659.27037.knikanth@suse.de> <201002101623.30302.knikanth@suse.de> <20100210110551.GA1323@localhost>
In-Reply-To: <20100210110551.GA1323@localhost>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201002101922.40122.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 February 2010 16:35:51 Wu Fengguang wrote:
> Nikanth,
> 
> > Make vm_max_readahead configurable at run-time. Expose a sysctl knob
> > in procfs to change it. This would ensure that new disks added would
> > use this value as their default read_ahead_kb.
> 
> Do you have use case, or customer demand for it?
> 

No body requested for it. But when doing some performance testing with 
readahead_kb re-compiling would be a pain, and thought that having a 
configurable default might be useful.

> > Also filesystems which use default_backing_dev_info would also
> > use this new value, even if they were already mounted.
> >
> > Currently xfs, btrfs, nilfs, raw, mtd use the default_backing_dev_info.
> 
> This sounds like bad interface, in that users will be confused by the
> tricky details of "works for new devices" and "works for some fs".
> 
> One more tricky point is, btrfs/md/dm readahead size may not be
> influenced if some of the component disks are hot added.
> 
> So this patch is only going to work for hot-plugged disks that
> contains _standalone_ filesystem. Is this typical use case in servers?
> 

Yes, it would work only if the top-level disk is hot-plugged/created.

Thanks
Nikanth


> Thanks,
> Fengguang
> 
> > Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> >
> > ---
> >
> > Index: linux-2.6/block/blk-core.c
> > ===================================================================
> > --- linux-2.6.orig/block/blk-core.c
> > +++ linux-2.6/block/blk-core.c
> > @@ -499,7 +499,7 @@ struct request_queue *blk_alloc_queue_no
> >  	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
> >  	q->backing_dev_info.unplug_io_data = q;
> >  	q->backing_dev_info.ra_pages =
> > -			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
> > +			(vm_max_readahead_kb * 1024) / PAGE_CACHE_SIZE;
> >  	q->backing_dev_info.state = 0;
> >  	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
> >  	q->backing_dev_info.name = "block";
> > Index: linux-2.6/fs/fuse/inode.c
> > ===================================================================
> > --- linux-2.6.orig/fs/fuse/inode.c
> > +++ linux-2.6/fs/fuse/inode.c
> > @@ -870,7 +870,7 @@ static int fuse_bdi_init(struct fuse_con
> >  	int err;
> >
> >  	fc->bdi.name = "fuse";
> > -	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
> > +	fc->bdi.ra_pages = (vm_max_readahead_kb * 1024) / PAGE_CACHE_SIZE;
> >  	fc->bdi.unplug_io_fn = default_unplug_io_fn;
> >  	/* fuse does it's own writeback accounting */
> >  	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
> > Index: linux-2.6/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm.h
> > +++ linux-2.6/include/linux/mm.h
> > @@ -1188,7 +1188,11 @@ int write_one_page(struct page *page, in
> >  void task_dirty_inc(struct task_struct *tsk);
> >
> >  /* readahead.c */
> > -#define VM_MAX_READAHEAD	128	/* kbytes */
> > +#define INITIAL_VM_MAX_READAHEAD_KB	128
> > +extern unsigned long vm_max_readahead_kb;
> > +
> > +int sysctl_vm_max_readahead_kb_handler(struct ctl_table *table, int
> > write, +		void __user *buffer, size_t *length, loff_t *ppos);
> >
> >  int force_page_cache_readahead(struct address_space *mapping, struct
> > file *filp, pgoff_t offset, unsigned long nr_to_read);
> > Index: linux-2.6/mm/backing-dev.c
> > ===================================================================
> > --- linux-2.6.orig/mm/backing-dev.c
> > +++ linux-2.6/mm/backing-dev.c
> > @@ -18,7 +18,8 @@ EXPORT_SYMBOL(default_unplug_io_fn);
> >
> >  struct backing_dev_info default_backing_dev_info = {
> >  	.name		= "default",
> > -	.ra_pages	= VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
> > +	.ra_pages	= INITIAL_VM_MAX_READAHEAD_KB
> > +					>> (PAGE_CACHE_SHIFT - 10),
> >  	.state		= 0,
> >  	.capabilities	= BDI_CAP_MAP_COPY,
> >  	.unplug_io_fn	= default_unplug_io_fn,
> > Index: linux-2.6/mm/readahead.c
> > ===================================================================
> > --- linux-2.6.orig/mm/readahead.c
> > +++ linux-2.6/mm/readahead.c
> > @@ -17,6 +17,19 @@
> >  #include <linux/pagevec.h>
> >  #include <linux/pagemap.h>
> >
> > +unsigned long vm_max_readahead_kb = INITIAL_VM_MAX_READAHEAD_KB;
> > +
> > +int sysctl_vm_max_readahead_kb_handler(struct ctl_table *table, int
> > write, +		void __user *buffer, size_t *length, loff_t *ppos)
> > +{
> > +	proc_doulongvec_minmax(table, write, buffer, length, ppos);
> > +
> > +	default_backing_dev_info.ra_pages =
> > +			vm_max_readahead_kb >> (PAGE_CACHE_SHIFT - 10);
> > +
> > +	return 0;
> > +}
> > +
> >  /*
> >   * Initialise a struct file's readahead state.  Assumes that the caller
> > has * memset *ra to zero.
> > Index: linux-2.6/kernel/sysctl.c
> > ===================================================================
> > --- linux-2.6.orig/kernel/sysctl.c
> > +++ linux-2.6/kernel/sysctl.c
> > @@ -1273,7 +1273,13 @@ static struct ctl_table vm_table[] = {
> >  		.extra2		= &one,
> >  	},
> >  #endif
> > -
> > +	{
> > +		.procname	= "max_readahead_kb",
> > +		.data		= &vm_max_readahead_kb,
> > +		.maxlen		= sizeof(vm_max_readahead_kb),
> > +		.mode		= 0644,
> > +		.proc_handler	= sysctl_vm_max_readahead_kb_handler,
> > +	},
> >  	{ }
> >  };
> >
> > Index: linux-2.6/Documentation/sysctl/vm.txt
> > ===================================================================
> > --- linux-2.6.orig/Documentation/sysctl/vm.txt
> > +++ linux-2.6/Documentation/sysctl/vm.txt
> > @@ -31,6 +31,7 @@ Currently, these files are in /proc/sys/
> >  - laptop_mode
> >  - legacy_va_layout
> >  - lowmem_reserve_ratio
> > +- max_readahead_kb
> >  - max_map_count
> >  - memory_failure_early_kill
> >  - memory_failure_recovery
> > @@ -263,6 +264,18 @@ The minimum value is 1 (1/1 -> 100%).
> >
> >  ==============================================================
> >
> > +max_readahead_kb:
> > +
> > +This file contains the default maximum readahead that would be
> > +used, when new disks would be added to the system.
> > +
> > +Also filesystems which use default_backing_dev_info would also
> > +use this new value, even if they were already mounted.
> > +
> > +xfs, btrfs, nilfs, raw, mtd use the default_backing_dev_info.
> > +
> > +==============================================================
> > +
> >  max_map_count:
> >
> >  This file contains the maximum number of memory map areas a process
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
