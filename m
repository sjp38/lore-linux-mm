Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E31CA6B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 01:22:27 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 134so33300066qkh.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 22:22:27 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s185si11031281qkc.26.2017.06.19.22.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 22:22:26 -0700 (PDT)
Date: Mon, 19 Jun 2017 22:22:14 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170620052214.GA3787@birch.djwong.org>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, xfs <linux-xfs@vger.kernel.org>

[add linux-xfs to the fray]

On Fri, Jun 16, 2017 at 06:15:35PM -0700, Dan Williams wrote:
> To date, the full promise of byte-addressable access to persistent
> memory has only been half realized via the filesystem-dax interface. The
> current filesystem-dax mechanism allows an application to consume (read)
> data from persistent storage at byte-size granularity, bypassing the
> full page reads required by traditional storage devices.
> 
> Now, for writes, applications still need to contend with
> page-granularity dirtying and flushing semantics as well as filesystem
> coordination for metadata updates after any mmap write. The current
> situation precludes use cases that leverage byte-granularity / in-place
> updates to persistent media.
> 
> To get around this limitation there are some specialized applications
> that are using the device-dax interface to bypass the overhead and
> data-safety problems of the current filesystem-dax mmap-write path.
> QEMU-KVM is forced to use device-dax to safely pass through persistent
> memory to a guest [1]. Some specialized databases are using device-dax
> for byte-granularity writes. Outside of those cases, device-dax is
> difficult for general purpose persistent memory applications to consume.
> There is demand for access to pmem without needing to contend with
> special device configuration and other device-dax limitations.
> 
> The 'daxfile' interface satisfies this demand and realizes one of Dave
> Chinner's ideas for allowing pmem applications to safely bypass
> fsync/msync requirements. The idea is to make the file immutable with
> respect to the offset-to-block mappings for every extent in the file
> [2]. It turns out that filesystems already need to make this guarantee
> today. This property is needed for files marked as swap files.
> 
> The new daxctl() syscall manages setting a file into 'static-dax' mode
> whereby it arranges for the file to be treated as a swapfile as far as
> the filesystem is concerned, but not registered with the core-mm as
> swapfile space. A file in this mode is then safe to be mapped and
> written without the requirement to fsync/msync the writes.  The cpu
> cache management for flushing data to persistence can be handled
> completely in userspace.
> 
> [1]: https://lists.gnu.org/archive/html/qemu-devel/2017-06/msg01207.html
> [2]: https://lkml.org/lkml/2016/9/11/159
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/entry/syscalls/syscall_64.tbl |    1 
>  include/linux/dax.h                    |    9 ++
>  include/linux/fs.h                     |    3 +
>  include/linux/syscalls.h               |    1 
>  include/uapi/linux/dax.h               |    8 +
>  mm/Kconfig                             |    5 +
>  mm/Makefile                            |    1 
>  mm/daxfile.c                           |  186 ++++++++++++++++++++++++++++++++
>  mm/page_io.c                           |   31 +++++
>  9 files changed, 245 insertions(+)
>  create mode 100644 include/uapi/linux/dax.h
>  create mode 100644 mm/daxfile.c
> 
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 5aef183e2f85..795eb93d6beb 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -339,6 +339,7 @@
>  330	common	pkey_alloc		sys_pkey_alloc
>  331	common	pkey_free		sys_pkey_free
>  332	common	statx			sys_statx
> +333	64	daxctl			sys_daxctl
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 5ec1f6c47716..5f1d0e0ed30f 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -4,8 +4,17 @@
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/radix-tree.h>
> +#include <uapi/linux/dax.h>
>  #include <asm/pgtable.h>
>  
> +/*
> + * TODO: make sys_daxctl() be the generic interface for toggling S_DAX
> + * across filesystems. For now, mark DAXCTL_F_DAX as an invalid flag
> + */
> +#define DAXCTL_VALID_FLAGS (DAXCTL_F_GET | DAXCTL_F_STATIC)
> +
> +int daxfile_activate(struct file *daxfile, unsigned align);
> +
>  struct iomap_ops;
>  struct dax_device;
>  struct dax_operations {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3e68cabb8457..3af649fb669f 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1824,8 +1824,10 @@ struct super_operations {
>  #define S_NOSEC		4096	/* no suid or xattr security attributes */
>  #ifdef CONFIG_FS_DAX
>  #define S_DAX		8192	/* Direct Access, avoiding the page cache */
> +#define S_DAXFILE	16384	/* no truncate (swapfile) semantics + dax */
>  #else
>  #define S_DAX		0	/* Make all the DAX code disappear */
> +#define S_DAXFILE	0
>  #endif
>  
>  /*
> @@ -1865,6 +1867,7 @@ struct super_operations {
>  #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
>  #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
>  #define IS_DAX(inode)		((inode)->i_flags & S_DAX)
> +#define IS_DAXFILE(inode)	((inode)->i_flags & S_DAXFILE)
>  
>  #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
>  				 (inode)->i_rdev == WHITEOUT_DEV)
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 980c3c9b06f8..49e5cc4c192e 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -701,6 +701,7 @@ asmlinkage long sys_prctl(int option, unsigned long arg2, unsigned long arg3,
>  			unsigned long arg4, unsigned long arg5);
>  asmlinkage long sys_swapon(const char __user *specialfile, int swap_flags);
>  asmlinkage long sys_swapoff(const char __user *specialfile);
> +asmlinkage long sys_daxctl(const char __user *path, int flags, int align);
>  asmlinkage long sys_sysctl(struct __sysctl_args __user *args);
>  asmlinkage long sys_sysinfo(struct sysinfo __user *info);
>  asmlinkage long sys_sysfs(int option,
> diff --git a/include/uapi/linux/dax.h b/include/uapi/linux/dax.h
> new file mode 100644
> index 000000000000..78a41bb392c0
> --- /dev/null
> +++ b/include/uapi/linux/dax.h
> @@ -0,0 +1,8 @@
> +#ifndef _UAPI_LINUX_DAX_H
> +#define _UAPI_LINUX_DAX_H
> +
> +#define DAXCTL_F_GET    (1 << 0)
> +#define DAXCTL_F_DAX    (1 << 1)
> +#define DAXCTL_F_STATIC (1 << 2)
> +
> +#endif /* _UAPI_LINUX_DAX_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index beb7a455915d..b874565c34eb 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -450,6 +450,11 @@ config	TRANSPARENT_HUGE_PAGECACHE
>  	def_bool y
>  	depends on TRANSPARENT_HUGEPAGE
>  
> +config DAXFILE
> +	def_bool y
> +	depends on FS_DAX
> +	depends on SWAP
> +
>  #
>  # UP and nommu archs use km based percpu allocator
>  #
> diff --git a/mm/Makefile b/mm/Makefile
> index 026f6a828a50..38d9025a3e37 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -56,6 +56,7 @@ endif
>  obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
>  
>  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
> +obj-$(CONFIG_DAXFILE)	+= daxfile.o
>  obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
>  obj-$(CONFIG_ZSWAP)	+= zswap.o
>  obj-$(CONFIG_HAS_DMA)	+= dmapool.o
> diff --git a/mm/daxfile.c b/mm/daxfile.c
> new file mode 100644
> index 000000000000..fe230199c855
> --- /dev/null
> +++ b/mm/daxfile.c
> @@ -0,0 +1,186 @@
> +/*
> + * Copyright(c) 2017 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of version 2 of the GNU General Public License as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + */
> +#include <linux/dax.h>
> +#include <linux/slab.h>
> +#include <linux/highmem.h>
> +#include <linux/pagemap.h>
> +#include <linux/syscalls.h>
> +
> +/*
> + * TODO: a list to lookup daxfiles assumes a low number of instances,
> + * revisit.
> + */
> +static LIST_HEAD(daxfiles);
> +static DEFINE_SPINLOCK(dax_lock);
> +
> +struct dax_info {
> +	struct list_head list;
> +	struct file *daxfile;
> +};
> +
> +static int daxfile_disable(struct file *victim)
> +{
> +	int found = 0;
> +	struct dax_info *d;
> +	struct inode *inode;
> +	struct file *daxfile;
> +	struct address_space *mapping;
> +
> +	mapping = victim->f_mapping;
> +	spin_lock(&dax_lock);
> +	list_for_each_entry(d, &daxfiles, list)
> +		if (d->daxfile->f_mapping == mapping) {
> +			list_del(&d->list);
> +			found = 1;
> +			break;
> +		}
> +	spin_unlock(&dax_lock);
> +
> +	if (!found)
> +		return -EINVAL;
> +
> +	daxfile = d->daxfile;
> +
> +	inode = mapping->host;
> +	inode->i_flags &= ~(S_SWAPFILE | S_DAXFILE);
> +	filp_close(daxfile, NULL);
> +
> +	return 0;
> +}
> +
> +static int claim_daxfile_checks(struct inode *inode)
> +{
> +	if (!S_ISREG(inode->i_mode))
> +		return -EINVAL;
> +
> +	if (!IS_DAX(inode))
> +		return -EINVAL;
> +
> +	if (IS_SWAPFILE(inode) || IS_DAXFILE(inode))
> +		return -EBUSY;
> +
> +	return 0;
> +}
> +
> +int daxfile_enable(struct file *daxfile, int align)
> +{
> +	struct address_space *mapping;
> +	struct inode *inode;
> +	struct dax_info *d;
> +	int rc;
> +
> +	if (align < 0)
> +		return -EINVAL;
> +
> +	mapping = daxfile->f_mapping;
> +	inode = mapping->host;
> +
> +	rc = claim_daxfile_checks(inode);
> +	if (rc)
> +		return rc;
> +
> +	rc = daxfile_activate(daxfile, align);
> +	if (rc)
> +		return rc;
> +
> +	d = kzalloc(sizeof(*d), GFP_KERNEL);
> +	if (!d)
> +		return -ENOMEM;
> +	INIT_LIST_HEAD(&d->list);
> +	d->daxfile = daxfile;
> +
> +	spin_lock(&dax_lock);
> +	list_add(&d->list, &daxfiles);
> +	spin_unlock(&dax_lock);
> +
> +	/*
> +	 * We set S_SWAPFILE to gain "no truncate" / static block
> +	 * allocation semantics, and S_DAXFILE so we can differentiate
> +	 * traditional swapfiles and assume static block mappings in the
> +	 * dax mmap path.
> +	 */
> +	inode->i_flags |= S_SWAPFILE | S_DAXFILE;

Yikes.  You know, I hadn't even thought about considering swap files as
a subcase of files with immutable block maps, but here we are.  Both
swap files and DAX require absolutely stable block mappings, they are
both (probably) intolerant of inode metadata changes (size, mtime, etc.)

But on the other hand, the bmap interface is so... yuck.  We return zero
to indicate no mapping or error or whatever, it doesn't actually tell us
/which/ device it's returning offsets into, etc.  I was writing a
regression test earlier to check that we've sealed off XFS RT files from
becoming swap files (because bmap is broken, not (afaik) because of any
weird limitation of xfs) and forgot that quirk long enough to waste time
wondering why it failed to fail on a 4.11 kernel.  That's right, the
first rt file gets block zero and magically doesn't fail to fail if
that's the swap file.

Gross.  I've now ranted twice this month about how bmap() doesn't work
on reflinked files on XFS.

Honestly, I realize we've gone back, forth, and around all over the
place on this.  I still prefer something similar to a permanent flag,
similar to what Dave suggested, though I hate the name PMEM_IMMUTABLE
and some of the semantics.

First, a new inode flag S_IOMAP_FROZEN that means the file's block map
cannot change.

Second, some kind of function to toggle the S_IOMAP_FROZEN flag.
Turning it on will lock the inode, check the extent map for holes,
shared, or unwritten bits, and bail out if it finds any, or set the
flag.  Not sure if we should require CAP_LINUX_IMMUTABLE -- probably
yes, at least at first.  I don't currently have any objection to writing
non-iomap inode metadata out to disk.

Third, the flag can only be cleared if the file isn't mapped.

Fourth, the VFS entry points for things like read, write, truncate,
utimes, fallocate, etc. all just bail out if S_IOMAP_FROZEN is set on a
file, so that the block map cannot be modified.  mmap is still allowed,
as we've discussed.  /Maybe/ we can allow fallocate to extend a file
with zeroed extents (it will be slow) as I've heard murmurs about
wanting to be able to extend a file, maybe not.

Fifth, swapfiles now require the S_IOMAP_FROZEN flag since they want
stable iomap but probably don't care about things like mtime.  Maybe
they can call iomap too.

Sixth, XFS can record the S_IOMAP_FROZEN state in di_flags2 and set it
whenever the in-core inode gets constructed.  This enables us to
prohibit reflinking and other such undesirable activity.

If we actually /do/ come up with a reference implementation for XFS, I'd
be ok with tacking it on the end of my dev branch, which will give us a
loooong runway to try it out.  The end of the dev branch is beyond
online XFS fsck and repair and the "root metadata btrees in inodes"
rework; since that's ~90 patches with my name on it that I cannot also
review, it won't go in for a long time indeed!

(Yes, that was also sort of a plea for someone to go review the XFS
scrub patches.)

> +	return 0;
> +}
> +
> +SYSCALL_DEFINE3(daxctl, const char __user *, path, int, flags, int, align)

I was /about/ to grouse about this syscall, then realized that maybe it
/is/ useful to be able to check a specific alignment.  Maybe not, since
I had something more permanent in mind anyway.  In any case, just pass
in an opened fd if this sticks around.

--D

> +{
> +	int rc;
> +	struct filename *name;
> +	struct inode *inode = NULL;
> +	struct file *daxfile = NULL;
> +	struct address_space *mapping;
> +
> +	if (flags & ~DAXCTL_VALID_FLAGS)
> +		return -EINVAL;
> +
> +	name = getname(path);
> +	if (IS_ERR(name))
> +		return PTR_ERR(name);
> +
> +	daxfile = file_open_name(name, O_RDWR|O_LARGEFILE, 0);
> +	if (IS_ERR(daxfile)) {
> +		rc = PTR_ERR(daxfile);
> +		daxfile = NULL;
> +		goto out;
> +	}
> +
> +	mapping = daxfile->f_mapping;
> +	inode = mapping->host;
> +	if (flags & DAXCTL_F_GET) {
> +		/*
> +		 * We only report the state of DAXCTL_F_STATIC since
> +		 * there is no actions for applications to take based on
> +		 * the setting of S_DAX. However, if this interface is
> +		 * used for toggling S_DAX presumably userspace would
> +		 * want to know the state of the flag.
> +		 *
> +		 * TODO: revisit whether we want to report DAXCTL_F_DAX
> +		 * in the IS_DAX() case.
> +		 */
> +		if (IS_DAXFILE(inode))
> +			rc = DAXCTL_F_STATIC;
> +		else
> +			rc = 0;
> +
> +		goto out;
> +	}
> +
> +	/*
> +	 * TODO: Should unprivileged users be allowed to control daxfile
> +	 * behavior? Perhaps a mount flag... is -o dax that flag?
> +	 */
> +	if (!capable(CAP_LINUX_IMMUTABLE)) {
> +		rc = -EPERM;
> +		goto out;
> +	}
> +
> +	inode_lock(inode);
> +	if (!IS_DAXFILE(inode) && (flags & DAXCTL_F_STATIC)) {
> +		rc = daxfile_enable(daxfile, align);
> +		/* if successfully enabled hold daxfile open */
> +		if (rc == 0)
> +			daxfile = NULL;
> +	} else if (IS_DAXFILE(inode) && !(flags & DAXCTL_F_STATIC))
> +		rc = daxfile_disable(daxfile);
> +	else
> +		rc = 0;
> +	inode_unlock(inode);
> +
> +out:
> +	if (daxfile)
> +		filp_close(daxfile, NULL);
> +	if (name)
> +		putname(name);
> +	return rc;
> +}
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 5cec9a3d49f2..35160ad9c51f 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -244,6 +244,37 @@ static int bmap_walk(struct file *file, const unsigned page_size,
>  	goto out;
>  }
>  
> +static int daxfile_check(sector_t block, unsigned long page_no,
> +		enum bmap_check type, void *none)
> +{
> +	if (type == BMAP_WALK_DONE)
> +		return 0;
> +
> +	/*
> +	 * Unlike the swapfile case, fail daxfile_activate() if any file
> +	 * extent is not page aligned.
> +	 */
> +	if (type != BMAP_WALK_FULLPAGE)
> +		return -EINVAL;
> +	return 0;
> +}
> +
> +int daxfile_activate(struct file *daxfile, unsigned align)
> +{
> +	int rc;
> +
> +	if (!align)
> +		align = PAGE_SIZE;
> +
> +	if (align < PAGE_SIZE || !is_power_of_2(align))
> +		return -EINVAL;
> +
> +	rc = bmap_walk(daxfile, align, ULONG_MAX, NULL, daxfile_check, NULL);
> +	if (rc)
> +		pr_debug("daxctl: daxfile has holes\n");
> +	return rc;
> +}
> +
>  static int swapfile_check(sector_t block, unsigned long page_no,
>  		enum bmap_check type, void *_sis)
>  {
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
