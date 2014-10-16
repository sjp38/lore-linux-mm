Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id A41D06B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:40:11 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so2349503lbg.32
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 00:40:10 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id mr6si33388185lbb.137.2014.10.16.00.40.07
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 00:40:09 -0700 (PDT)
Date: Thu, 16 Oct 2014 09:39:08 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
Message-ID: <20141016073908.GA15422@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>

On 25-Sep-2014 04:33:17 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> We currently have two unrelated things inside the Linux kernel called
> "XIP".  One allows the kernel to run out of flash without being copied
> into DRAM, the other allows executables to be run without copying them
> into the page cache.  The latter is almost the behaviour we want for
> NV-DIMMs, except that we primarily want data to be accessed through
> this filesystem, not executables.  We deal with the confusion between
> the two XIPs by renaming the second one to DAX (short for Direct Access).

Hi Matthew,

First of all, thanks a lot for this patchset! Secondly, I must voice out
that you really need to work on your marketing skills. What your
changelog does not show is that this feature is tremendously useful
*today* in the following use-case:

- On *any* platform for which you can teach the BIOS not to clear memory
  on soft reboot,
- Use a kernel argument to restrain it to portion of memory at boot
  (e.g. 15GB out of 16GB),
- Create an ext4 or ext2 filesystem in this available memory area,
- Mount it with DAX flags,

>From there, you can do lots of interesting stuff. In my use-case, I
would love to use it to mmap LTTng kernel/userspace tracer buffers, so
we can extract them after a soft reboot and analyze a system crash.

My recommendation would be to rename this patchset as e.g.

"DAX: Page cache bypass for in-memory persistent filesystems"

which might attract more interest from reviewers and maintainers, since
they can try it out today on commodity hardware. Also, pointing out to
ext4 specifically in the patchset introduction title does not reflect
the content accurately, since there is also ext2 implementation within
the series.

> 
> DAX bears some resemblance to its ancestor XIP but fixes many races that
> were not relevant for its original use case of storing executables.
> The major design change is using the filesystem's get_block routine
> instead of a special-purpose ->get_xip_mem() address_space operation.
> Further enhancements are planned, such as supporting huge pages, but
> this is a useful amount of work to merge before adding more functionality.

Getting the simple thing in seems like a sane approach. But IMHO it
really needs to be presented as something useful on existing commodity
hardware rather than something specific requiring vendor-specific memory
and CPU extensions that will only exist in 2 years from now.

> 
> This is not the only way to support NV-DIMMs, of course.  People have
> written new filesystems to support them, some of which have even seen
> the light of day.  We believe it is valuable to support traditional
> filesystems such as ext4 and XFS on NV-DIMMs in a more efficient manner
> than copying the contents of the NV-DIMM to DRAM.

Indeed, I think there is value in not reinventing the wheel: having the
data persistent across reboots makes it necessary to have the same set
of FS features and tools we currently have for block devices, e.g.
consistency of the filesystem when the OS crashes, and tools to repair
the FS such as fsck.

One thing I would really like to see is a Documentation file that
explains how to setup the kernel so it leaves a memory area free at the
end of the physical address space, and how to setup a filesystem into
it. Perhaps it already exists, in this case, pointing to it in the
patchset introduction changelog would be helpful. (IOW, answering the
question: how can someone test this today on commodity hardware ?).
Also, if there are ways to setup pstore or such to achieve something
similar of a wider range of systems, it would be nice to see
documentation (or links to doc) explaining how to configure this.

I'll try to review your patchset soon, however keeping in mind that it
would be best to have mm experts having a look into it.

Thanks,

Mathieu

> 
> Patch 1 is a bug fix.  It is obviously correct, and should be included
> into 3.18.
> 
> Patch 2 starts the transformation by changing how ->direct_access works.
> Much code is moved from the drivers and filesystems into the block
> layer, and we add the flexibility of being able to map more than one
> page at a time.  It would be good to get this patch into 3.18 as it is
> useful for people who are pursuing non-DAX approaches to working with
> persistent memory.
> 
> Patch 3 is also a bug fix, probably worth including in 3.18.
> 
> Patches 4-6 are infrastructure for DAX (note that patch 6 is in the
> for-next branch of Al Viro's VFS tree).
> 
> Patches 7-11 replace the XIP code with its DAX equivalents, transforming
> ext2 to use the DAX code as we go.  Note that patch 11 is the
> Documentation patch.
> 
> Patches 12-18 clean up after the XIP code, removing the infrastructure
> that is no longer needed and renaming various XIP things to DAX.
> Most of these patches were added after Jan found things he didn't
> like in an earlier version of the ext4 patch ... that had been copied
> from ext2.  So ext2 i being transformed to do things the same way that
> ext4 will later.  The ability to mount ext2 filesystems with the 'xip'
> option is retained, although the 'dax' option is now preferred.
> 
> Patch 19 adds some DAX infrastructure to support ext4.
> 
> Patch 20 adds DAX support to ext4.  It is broadly similar to ext2's DAX
> support, but it is more efficient than ext4's due to its support for
> unwritten extents.
> 
> Patch 21 is another cleanup patch renaming XIP to DAX.
> 
> Matthew Wilcox (20):
>   axonram: Fix bug in direct_access
>   block: Change direct_access calling convention
>   mm: Fix XIP fault vs truncate race
>   mm: Allow page fault handlers to perform the COW
>   vfs,ext2: Introduce IS_DAX(inode)
>   vfs: Add copy_to_iter(), copy_from_iter() and iov_iter_zero()
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
>  fs/dax.c                           | 532 +++++++++++++++++++++++++++++++++++++
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
>  fs/ext4/inode.c                    |  89 +++++--
>  fs/ext4/namei.c                    |  10 +-
>  fs/ext4/super.c                    |  39 ++-
>  fs/open.c                          |   5 +-
>  include/linux/blkdev.h             |   6 +-
>  include/linux/fs.h                 |  49 +++-
>  include/linux/mm.h                 |   1 +
>  include/linux/uio.h                |   3 +
>  mm/Makefile                        |   1 -
>  mm/fadvise.c                       |   6 +-
>  mm/filemap.c                       |  25 +-
>  mm/filemap_xip.c                   | 483 ---------------------------------
>  mm/iov_iter.c                      | 237 ++++++++++++++++-
>  mm/madvise.c                       |   2 +-
>  mm/memory.c                        |  33 ++-
>  41 files changed, 1305 insertions(+), 889 deletions(-)
>  create mode 100644 Documentation/filesystems/dax.txt
>  delete mode 100644 Documentation/filesystems/xip.txt
>  create mode 100644 fs/dax.c
>  delete mode 100644 fs/ext2/xip.c
>  delete mode 100644 fs/ext2/xip.h
>  delete mode 100644 mm/filemap_xip.c
> 
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
Key fingerprint: 2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
