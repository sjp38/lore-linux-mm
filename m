Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8296B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 04:09:17 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u57so380343wes.37
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 01:09:16 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id c19si13955971wiv.75.2014.08.28.01.09.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 01:09:15 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so7055651wiv.11
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 01:09:15 -0700 (PDT)
Message-ID: <53FEE379.9060204@gmail.com>
Date: Thu, 28 Aug 2014 11:08:25 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1409110741.git.matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: willy@linux.intel.com

On 08/27/2014 06:45 AM, Matthew Wilcox wrote:
> One of the primary uses for NV-DIMMs is to expose them as a block device
> and use a filesystem to store files on the NV-DIMM.  While that works,
> it currently wastes memory and CPU time buffering the files in the page
> cache.  We have support in ext2 for bypassing the page cache, but it
> has some races which are unfixable in the current design.  This series
> of patches rewrite the underlying support, and add support for direct
> access to ext4.
> 
> Note that patch 6/21 has been included in
> https://git.kernel.org/cgit/linux/kernel/git/viro/vfs.git/log/?h=for-next-candidate
> 

Matthew hi

Could you please push this to the regular or a new public tree?

(Old versions are at: https://github.com/01org/prd)

Thanks
Boaz

> This iteration of the patchset rebases to 3.17-rc2, changes the page fault
> locking, fixes a couple of bugs and makes a few other minor changes.
> 
>  - Move the calculation of the maximum size available at the requested
>    location from the ->direct_access implementations to bdev_direct_access()
>  - Fix a comment typo (Ross Zwisler)
>  - Check that the requested length is positive in bdev_direct_access().  If
>    it is not, assume that it's an errno, and just return it.
>  - Fix some whitespace issues flagged by checkpatch
>  - Added the Acked-by responses from Kirill that I forget in the last round
>  - Added myself to MAINTAINERS for DAX
>  - Fixed compilation with !CONFIG_DAX (Vishal Verma)
>  - Revert the locking in the page fault handler back to an earlier version.
>    If we hit the race that we were trying to protect against, we will leave
>    blocks allocated past the end of the file.  They will be removed on file
>    removal, the next truncate, or fsck.
> 
> 
> Matthew Wilcox (20):
>   axonram: Fix bug in direct_access
>   Change direct_access calling convention
>   Fix XIP fault vs truncate race
>   Allow page fault handlers to perform the COW
>   Introduce IS_DAX(inode)
>   Add copy_to_iter(), copy_from_iter() and iov_iter_zero()
>   Replace XIP read and write with DAX I/O
>   Replace ext2_clear_xip_target with dax_clear_blocks
>   Replace the XIP page fault handler with the DAX page fault handler
>   Replace xip_truncate_page with dax_truncate_page
>   Replace XIP documentation with DAX documentation
>   Remove get_xip_mem
>   ext2: Remove ext2_xip_verify_sb()
>   ext2: Remove ext2_use_xip
>   ext2: Remove xip.c and xip.h
>   Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to CONFIG_FS_DAX
>   ext2: Remove ext2_aops_xip
>   Get rid of most mentions of XIP in ext2
>   xip: Add xip_zero_page_range
>   brd: Rename XIP to DAX
> 
> Ross Zwisler (1):
>   ext4: Add DAX functionality
> 
>  Documentation/filesystems/Locking  |   3 -
>  Documentation/filesystems/dax.txt  |  91 +++++++
>  Documentation/filesystems/ext4.txt |   2 +
>  Documentation/filesystems/xip.txt  |  68 -----
>  MAINTAINERS                        |   6 +
>  arch/powerpc/sysdev/axonram.c      |  19 +-
>  drivers/block/Kconfig              |  13 +-
>  drivers/block/brd.c                |  26 +-
>  drivers/s390/block/dcssblk.c       |  21 +-
>  fs/Kconfig                         |  21 +-
>  fs/Makefile                        |   1 +
>  fs/block_dev.c                     |  40 +++
>  fs/dax.c                           | 497 +++++++++++++++++++++++++++++++++++++
>  fs/exofs/inode.c                   |   1 -
>  fs/ext2/Kconfig                    |  11 -
>  fs/ext2/Makefile                   |   1 -
>  fs/ext2/ext2.h                     |  10 +-
>  fs/ext2/file.c                     |  45 +++-
>  fs/ext2/inode.c                    |  38 +--
>  fs/ext2/namei.c                    |  13 +-
>  fs/ext2/super.c                    |  53 ++--
>  fs/ext2/xip.c                      |  91 -------
>  fs/ext2/xip.h                      |  26 --
>  fs/ext4/ext4.h                     |   6 +
>  fs/ext4/file.c                     |  49 +++-
>  fs/ext4/indirect.c                 |  18 +-
>  fs/ext4/inode.c                    |  51 ++--
>  fs/ext4/namei.c                    |  10 +-
>  fs/ext4/super.c                    |  39 ++-
>  fs/open.c                          |   5 +-
>  include/linux/blkdev.h             |   6 +-
>  include/linux/fs.h                 |  49 +++-
>  include/linux/mm.h                 |   1 +
>  include/linux/uio.h                |   3 +
>  mm/Makefile                        |   1 -
>  mm/fadvise.c                       |   6 +-
>  mm/filemap.c                       |   6 +-
>  mm/filemap_xip.c                   | 483 -----------------------------------
>  mm/iov_iter.c                      | 237 ++++++++++++++++--
>  mm/madvise.c                       |   2 +-
>  mm/memory.c                        |  33 ++-
>  41 files changed, 1229 insertions(+), 873 deletions(-)
>  create mode 100644 Documentation/filesystems/dax.txt
>  delete mode 100644 Documentation/filesystems/xip.txt
>  create mode 100644 fs/dax.c
>  delete mode 100644 fs/ext2/xip.c
>  delete mode 100644 fs/ext2/xip.h
>  delete mode 100644 mm/filemap_xip.c
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
