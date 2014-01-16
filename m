Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id E9EAB6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:46:35 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so770434yho.16
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:46:35 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id n44si7528342yhn.190.2014.01.15.17.46.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jan 2014 17:46:32 -0800 (PST)
Message-ID: <52D739F4.8060108@infradead.org>
Date: Wed, 15 Jan 2014 17:46:28 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH v5 10/22] Remove get_xip_mem
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <557203b474f633a59f32fee1f624a5239effcab7.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <557203b474f633a59f32fee1f624a5239effcab7.1389779961.git.matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On 01/15/2014 05:24 PM, Matthew Wilcox wrote:
> All callers of get_xip_mem() are now gone.  Remove checks for it,
> initialisers of it, documentation of it and the only implementation of it.
> 
> Add documentation for the new way of writing an XIP filesystem.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  Documentation/filesystems/Locking |   3 -
>  Documentation/filesystems/xip.txt | 116 +++++++++++++++++++++-----------------
>  fs/exofs/inode.c                  |   1 -
>  fs/ext2/inode.c                   |   1 -
>  fs/ext2/xip.c                     |  37 ------------
>  fs/ext2/xip.h                     |   3 -
>  fs/open.c                         |   5 +-
>  include/linux/fs.h                |   2 -
>  mm/fadvise.c                      |   6 +-
>  mm/madvise.c                      |   2 +-
>  10 files changed, 70 insertions(+), 106 deletions(-)
> 
> diff --git a/Documentation/filesystems/xip.txt b/Documentation/filesystems/xip.txt
> index b62eabf..520e73a 100644
> --- a/Documentation/filesystems/xip.txt
> +++ b/Documentation/filesystems/xip.txt
> @@ -3,69 +3,81 @@ Execute-in-place for file mappings
>  
>  Motivation
>  ----------
> -File mappings are performed by mapping page cache pages to userspace. In
> -addition, read&write type file operations also transfer data from/to the page
> -cache.
> -
> -For memory backed storage devices that use the block device interface, the page
> -cache pages are in fact copies of the original storage. Various approaches
> -exist to work around the need for an extra copy. The ramdisk driver for example
> -does read the data into the page cache, keeps a reference, and discards the
> -original data behind later on.
> -
> -Execute-in-place solves this issue the other way around: instead of keeping
> -data in the page cache, the need to have a page cache copy is eliminated
> -completely. With execute-in-place, read&write type operations are performed
> -directly from/to the memory backed storage device. For file mappings, the
> -storage device itself is mapped directly into userspace.
> -
> -This implementation was initially written for shared memory segments between
> -different virtual machines on s390 hardware to allow multiple machines to
> -share the same binaries and libraries.
> -
> -Implementation
> ---------------
> -Execute-in-place is implemented in three steps: block device operation,
> -address space operation, and file operations.
> -
> -A block device operation named direct_access is used to translate the
> -block device sector number to a page frame number (pfn) that identifies
> -the physical page for the memory.  It also returns a kernel virtual
> -address that can be used to access the memory.
> +
> +File mappings are usually performed by mapping page cache pages to
> +userspace.  In addition, read & write file operations also transfer data
> +between the page cache and storage.
> +
> +For memory backed storage devices that use the block device interface,
> +the page cache pages are just copies of the original storage.  The
> +execute-in-place code removes the extra copy by performing reads and
> +writes directly on the memory backed storage device.  For file mappings,
> +the storage device itself is mapped directly into userspace.
> +
> +
> +Implementation Tips for Block Driver Writers
> +--------------------------------------------
> +
> +To support XIP in your block driver, implement the 'direct_access'
> +block device operation.  It is used to translate the sector number
> +(expressed in units of 512-byte sectors) to a page frame number (pfn)
> +that identifies the physical page for the memory.  It also returns a
> +kernel virtual address that can be used to access the memory.
>  
>  The direct_access method takes a 'size' parameter that indicates the
>  number of bytes being requested.  The function should return the number
>  of bytes that it can provide, although it must not exceed the number of
>  bytes requested.  It may also return a negative errno if an error occurs.
>  
> -The block device operation is optional, these block devices support it as of
> -today:
> +In order to support this method, the storage must be byte-accessable by

                                                        byte-accessible

> +the CPU at all times.  If your device uses paging techniques to expose
> +a large amount of memory through a smaller window, then you cannot
> +implement direct_access.  Equally, if your device can occasionally
> +stall the CPU for an extended period, you should also not attempt to
> +implement direct_access.
> +
> +These block devices may be used for inspiration:
> +- axonram: Axon DDR2 device driver
> +- brd: RAM backed block device driver
>  - dcssblk: s390 dcss block device driver
>  
> -An address space operation named get_xip_mem is used to retrieve references
> -to a page frame number and a kernel address. To obtain these values a reference
> -to an address_space is provided. This function assigns values to the kmem and
> -pfn parameters. The third argument indicates whether the function should allocate
> -blocks if needed.
>  
> -This address space operation is mutually exclusive with readpage&writepage that
> -do page cache read/write operations.
> -The following filesystems support it as of today:
> -- ext2: the second extended filesystem, see Documentation/filesystems/ext2.txt
> +Implementation Tips for Filesystem Writers
> +------------------------------------------
> +
> +Filesystem support consists of
> +- adding support to mark inodes as being XIP by setting the S_XIP flag in
> +  i_flags
> +- implementing the direct_IO address space operation, and calling
> +  xip_do_io() instead of blockdev_direct_IO() if S_XIP is set
> +- implementing an mmap file operation for XIP files which sets the
> +  VM_MIXEDMAP flag on the VMA, and setting the vm_ops to include handlers
> +  for fault and page_mkwrite (which should probably call xip_fault() and
> +  xip_mkwrite(), passing the appropriate get_block() callback)
> +- calling xip_truncate_page() instead of block_truncate_page() for XIP files
> +- ensuring that there is sufficient locking between reads, writes,
> +  truncates and page faults

     truncates, and
but that's up to you and your editor/proofreader etc.  :)

> +
> +The get_block() callback passed to xip_do_io(), xip_fault(), xip_mkwrite()
> +and xip_truncate_page() must not return uninitialised extents.  It must zero
> +any blocks that it returns, and it must ensure that simultaneous calls to
> +get_block() (for example by a page-fault racing with a read() or a write())
> +work correctly.
>  
> -A set of file operations that do utilize get_xip_page can be found in
> -mm/filemap_xip.c . The following file operation implementations are provided:
> -- aio_read/aio_write
> -- readv/writev
> -- sendfile
> +These filesystems may be used for inspiration:
> +- ext2: the second extended filesystem, see Documentation/filesystems/ext2.txt
>  
> -The generic file operations do_sync_read/do_sync_write can be used to implement
> -classic synchronous IO calls.
>  
>  Shortcomings
>  ------------
> -This implementation is limited to storage devices that are cpu addressable at
> -all times (no highmem or such). It works well on rom/ram, but enhancements are
> -needed to make it work with flash in read+write mode.
> -Putting the Linux kernel and/or its modules on a xip filesystem does not mean
> -they are not copied.
> +
> +Even if the kernel or its modules are stored on an filesystem that supports

                                                   a

> +XIP on a block device that supports XIP, they will still be copied into RAM.
> +
> +Calling get_user_pages() on a range of user memory that has been mmaped
> +from an XIP file will fail as there are no 'struct page' to describe
> +those pages.  This problem is being worked on.  That means that O_DIRECT
> +reads/writes to those memory ranges from a non-XIP file will fail (note
> +that O_DIRECT reads/writes _of an XIP file_ do work, it is the memory
> +that is being accessed that is key here).  Other things that will not
> +work include RDMA, sendfile() and splice().

                      sendfile(),
same comment as above.



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
