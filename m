Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA216B006C
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:03:52 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so2866567pad.15
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:03:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id og2si6899351pbc.104.2014.12.10.06.03.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Dec 2014 06:03:49 -0800 (PST)
Date: Wed, 10 Dec 2014 06:03:47 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-ID: <20141210140347.GA23252@infradead.org>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

What is the status of this patch set?

On Fri, Oct 24, 2014 at 05:20:32PM -0400, Matthew Wilcox wrote:
> DAX is a replacement for the variation of XIP currently supported by
> the ext2 filesystem.  We have three different things in the tree called
> 'XIP', and the new focus is on access to data rather than executables,
> so a name change was in order.  DAX stands for Direct Access.  The X is
> for eXciting.
> 
> The new focus on data access has resulted in more careful attention to
> races that exist in the current XIP code, but are not hit by the use-case
> that it was designed for.  XIP's architecture worked fine for ext2, but
> DAX is architected to work with modern filsystems such as ext4 and XFS.
> DAX is not intended for use with btrfs; the value that btrfs adds relies
> on manipulating data and writing data to different locations, while DAX's
> value is for write-in-place and keeping the kernel from touching the data.
> 
> DAX was developed in order to support NV-DIMMs, but it's become clear that
> its usefuless extends beyond NV-DIMMs and there are several potential
> customers including the tracing machinery.  Other people want to place
> the kernel log in an area of memory, as long as they have a BIOS that
> does not clear DRAM on reboot.
> 
> Patch 1 is a bug fix.  It is obviously correct, and should be included
> into 3.18.
> 
> Patch 2 starts the transformation by changing how ->direct_access works.
> Much code is moved from the drivers and filesystems into the block layer,
> and we add the flexibility of being able to map more than one page at
> a time.  It would be good to get this patch into 3.18 as it is also
> useful for people who are pursuing non-DAX approaches to working with
> persistent memory.
> 
> Patch 3 is also a bug fix, probably worth including in 3.18.
> 
> Patches 4 & 5 are infrastructure for DAX.
> 
> Patches 6-10 replace the XIP code with its DAX equivalents, transforming
> ext2 to use the DAX code as we go.  Note that patch 10 is the
> Documentation patch.
> 
> Patches 11-17 clean up after the XIP code, removing the infrastructure
> that is no longer needed and renaming various XIP things to DAX.
> Most of these patches were added after Jan found things he didn't
> like in an earlier version of the ext4 patch ... that had been copied
> from ext2.  So ext2 i being transformed to do things the same way that
> ext4 will later.  The ability to mount ext2 filesystems with the 'xip'
> option is retained, although the 'dax' option is now preferred.
> 
> Patch 18 adds some DAX infrastructure to support ext4.
> 
> Patch 19 adds DAX support to ext4.  It is broadly similar to ext2's DAX
> support, but it is more efficient than ext4's due to its support for
> unwritten extents.
> 
> Patch 20 is another cleanup patch renaming XIP to DAX.
> 
> 
> My thanks to Mathieu Desnoyers for his reviews of the v11 patchset.  Most
> of the changes below were based on his feedback.
> 
> Changes since v11:
>  - Rebased to 3.18-rc1, dropping patch "vfs: Add copy_to_iter(),
>    copy_from_iter() and iov_iter_zero()" as it was merged through Al's tree.
>  - Added cc to stable@vger.kernel.org on patch 1
>  - Fixed comment style in brd.c (Mathieu)
>  - Make more functions in fs.h common with and without CONFIG_FS_DAX set
>  - Improve type-checking with !CONFIG_FS_DAX
>  - Simplify check for holes in dax_io()
>  - Harden the loop in dax_clear_blocks()
>  - Add missing check against truncate of a page covering a hole
>  - Fix the page-fault handler to work for block devices too
>  - Change a few more places that mentioned 'XIP' into 'DAX'
>  - Update DAX documentation in a couple of places
> 
> Matthew Wilcox (19):
>   axonram: Fix bug in direct_access
>   block: Change direct_access calling convention
>   mm: Fix XIP fault vs truncate race
>   mm: Allow page fault handlers to perform the COW
>   vfs,ext2: Introduce IS_DAX(inode)
>   dax,ext2: Replace XIP read and write with DAX I/O
>   dax,ext2: Replace ext2_clear_xip_target with dax_clear_blocks
>   dax,ext2: Replace the XIP page fault handler with the DAX page fault
>     handler
>   dax,ext2: Replace xip_truncate_page with dax_truncate_page
>   dax: Replace XIP documentation with DAX documentation
>   vfs: Remove get_xip_mem
>   ext2: Remove ext2_xip_verify_sb()
>   ext2: Remove ext2_use_xip
>   ext2: Remove xip.c and xip.h
>   vfs,ext2: Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to
>     CONFIG_FS_DAX
>   ext2: Remove ext2_aops_xip
>   ext2: Get rid of most mentions of XIP in ext2
>   dax: Add dax_zero_page_range
>   brd: Rename XIP to DAX
> 
> Ross Zwisler (1):
>   ext4: Add DAX functionality
> 
>  Documentation/filesystems/00-INDEX |   5 +-
>  Documentation/filesystems/Locking  |   3 -
>  Documentation/filesystems/dax.txt  |  91 +++++++
>  Documentation/filesystems/ext2.txt |   5 +-
>  Documentation/filesystems/ext4.txt |   4 +
>  Documentation/filesystems/vfs.txt  |   7 -
>  Documentation/filesystems/xip.txt  |  68 -----
>  MAINTAINERS                        |   6 +
>  arch/powerpc/sysdev/axonram.c      |  19 +-
>  drivers/block/Kconfig              |  13 +-
>  drivers/block/brd.c                |  28 +-
>  drivers/s390/block/dcssblk.c       |  21 +-
>  fs/Kconfig                         |  21 +-
>  fs/Makefile                        |   1 +
>  fs/block_dev.c                     |  40 +++
>  fs/dax.c                           | 530 +++++++++++++++++++++++++++++++++++++
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
>  fs/ext4/file.c                     |  50 +++-
>  fs/ext4/indirect.c                 |  18 +-
>  fs/ext4/inode.c                    |  89 +++++--
>  fs/ext4/namei.c                    |  10 +-
>  fs/ext4/super.c                    |  39 ++-
>  fs/open.c                          |   5 +-
>  include/linux/blkdev.h             |   6 +-
>  include/linux/fs.h                 |  34 +--
>  include/linux/mm.h                 |   1 +
>  include/linux/rmap.h               |   2 +-
>  mm/Makefile                        |   1 -
>  mm/fadvise.c                       |   6 +-
>  mm/filemap.c                       |  25 +-
>  mm/filemap_xip.c                   | 483 ---------------------------------
>  mm/madvise.c                       |   2 +-
>  mm/memory.c                        |  33 ++-
>  scripts/diffconfig                 |   1 -
>  44 files changed, 1069 insertions(+), 893 deletions(-)
>  create mode 100644 Documentation/filesystems/dax.txt
>  delete mode 100644 Documentation/filesystems/xip.txt
>  create mode 100644 fs/dax.c
>  delete mode 100644 fs/ext2/xip.c
>  delete mode 100644 fs/ext2/xip.h
>  delete mode 100644 mm/filemap_xip.c
> 
> -- 
> 2.1.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
