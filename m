Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E91466B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:11:52 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so3388491pbb.4
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:11:52 -0700 (PDT)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id xz4si18121590pac.71.2014.06.17.11.11.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 11:11:51 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so3854109pbb.25
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:11:51 -0700 (PDT)
Message-ID: <53A084E3.6080103@gmail.com>
Date: Tue, 17 Jun 2014 21:11:47 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 00/22] Support ext4 on NV-DIMMs
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: willy@linux.intel.com

On 03/23/2014 09:08 PM, Matthew Wilcox wrote:
> One of the primary uses for NV-DIMMs is to expose them as a block device
> and use a filesystem to store files on the NV-DIMM.  While that works,
> it currently wastes memory and CPU time buffering the files in the page
> cache.  We have support in ext2 for bypassing the page cache, but it
> has some races which are unfixable in the current design.  This series
> of patches rewrite the underlying support, and add support for direct
> access to ext4.
> 
> This iteration of the patchset rebases to Linus' 3.14-rc7 (plus Kirill's
> patches in linux-next http://marc.info/?l=linux-mm&m=139206489208546&w=2)
> and fixes several bugs:
> 
>  - Initialise cow_page in do_page_mkwrite() (Matthew Wilcox)
>  - Clear new or unwritten blocks in page fault handler (Matthew Wilcox)
>  - Only call get_block when necessary (Matthew Wilcox)
>  - Reword Kconfig options (Matthew Wilcox / Vishal Verma)
>  - Fix a race between page fault and truncate (Matthew Wilcox)
>  - Fix a race between fault-for-read and fault-for-write (Matthew Wilcox)
>  - Zero the correct bytes in dax_new_buf() (Toshi Kani)
>  - Add DIO_LOCKING to an invocation of dax_do_io in ext4 (Ross Zwisler)
> 
> Relative to the last patchset, I folded the 'Add reporting of major faults'
> patch into the patch that adds the DAX page fault handler.
> 
> The v6 patchset had seven additional xfstests failures.  This patchset
> now passes approximately as many xfstests as ext4 does on a ramdisk.
> 
> Matthew Wilcox (21):
>   Fix XIP fault vs truncate race
>   Allow page fault handlers to perform the COW
>   axonram: Fix bug in direct_access
>   Change direct_access calling convention
>   Introduce IS_DAX(inode)
>   Replace XIP read and write with DAX I/O
>   Replace the XIP page fault handler with the DAX page fault handler
>   Replace xip_truncate_page with dax_truncate_page
>   Remove mm/filemap_xip.c
>   Remove get_xip_mem
>   Replace ext2_clear_xip_target with dax_clear_blocks
>   ext2: Remove ext2_xip_verify_sb()
>   ext2: Remove ext2_use_xip
>   ext2: Remove xip.c and xip.h
>   Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to CONFIG_FS_DAX
>   ext2: Remove ext2_aops_xip
>   Get rid of most mentions of XIP in ext2
>   xip: Add xip_zero_page_range
>   ext4: Make ext4_block_zero_page_range static
>   ext4: Fix typos
>   brd: Rename XIP to DAX

Hi Matthew

I have some more trouble with DAX (and old XIP) please forgive me if I'm just senile and
clueless. And put some sense into me.

The title of this patchset is "ext4 on NV-DIMMs"

But all I see is that DAX (and old XIP) is supported by mounting over brd devices.
(On x86 I'm not sure about the other drivers)

But looking to use brd with real NV_DIMMS fails miserably. 
 (I'm talking about the RAM based NV_DIMMS (backed by flash) and not about
  the block based Diablo DDR bus flash devices type)

Looking at the brd code I fail to see how it will ever support NV_DIMMS.
brd is "struct page" based and shares RAM from the same memory pool as the rest
of the system. But NV_DIMMS is not page-based and is excluded from the
memory system. It needs to be exclusively owned by a device and the mounted
FS.

We currently have in our lab the old DDR3 based NV_DIMMS and on regular boot
it appears as RAM. We need to use memmap= option on command line of Kernel
to exclude it from use by Kernel.

We have received our DDR4 based NV_DIMMS but still waiting for the actual
system board to support it. As I understand from STD documentation
these devices will not identify as RAM and will be exported as ACPI or
SBUS devices that can be queried for sizes and address as well as properties
about the chips. So I imagine a udev rule will need to probe the right driver
to mount over those.

So currently from what I can see only the infamous PMFS is the setup that
can actually mount/support my NV_DIMMS today.

It seems to me like we need a *new* block device that receives, like PMFS,
an physical_address + size on load and will export this raw region as a block
device. Of course with support of new DAX API. Should I send in such a device
code.

(I've seen the linux-nvdimm project on github but did not see how my above
 problem is addressed, it looks geared for that other type DDR bus devices)

So please how is all that suppose to work, what is the strategy stack
for all this? I guess for now I'm stuck with PMFS.

(BTW: A public git tree of DAX patches ;-) )

Thanks
Boaz

> 
> Ross Zwisler (1):
>   ext4: Add DAX functionality
> 
>  Documentation/filesystems/Locking  |   3 -
>  Documentation/filesystems/dax.txt  |  84 ++++++
>  Documentation/filesystems/ext4.txt |   2 +
>  Documentation/filesystems/xip.txt  |  68 -----
>  arch/powerpc/sysdev/axonram.c      |   8 +-
>  drivers/block/Kconfig              |  13 +-
>  drivers/block/brd.c                |  22 +-
>  drivers/s390/block/dcssblk.c       |  19 +-
>  fs/Kconfig                         |  21 +-
>  fs/Makefile                        |   1 +
>  fs/dax.c                           | 509 +++++++++++++++++++++++++++++++++++++
>  fs/exofs/inode.c                   |   1 -
>  fs/ext2/Kconfig                    |  11 -
>  fs/ext2/Makefile                   |   1 -
>  fs/ext2/ext2.h                     |   9 +-
>  fs/ext2/file.c                     |  45 +++-
>  fs/ext2/inode.c                    |  37 +--
>  fs/ext2/namei.c                    |  13 +-
>  fs/ext2/super.c                    |  48 ++--
>  fs/ext2/xip.c                      |  91 -------
>  fs/ext2/xip.h                      |  26 --
>  fs/ext4/ext4.h                     |   8 +-
>  fs/ext4/file.c                     |  53 +++-
>  fs/ext4/indirect.c                 |  19 +-
>  fs/ext4/inode.c                    |  94 ++++---
>  fs/ext4/namei.c                    |  10 +-
>  fs/ext4/super.c                    |  39 ++-
>  fs/open.c                          |   5 +-
>  include/linux/blkdev.h             |   4 +-
>  include/linux/fs.h                 |  49 +++-
>  include/linux/mm.h                 |   2 +
>  mm/Makefile                        |   1 -
>  mm/fadvise.c                       |   6 +-
>  mm/filemap.c                       |   6 +-
>  mm/filemap_xip.c                   | 483 -----------------------------------
>  mm/madvise.c                       |   2 +-
>  mm/memory.c                        |  45 +++-
>  37 files changed, 984 insertions(+), 874 deletions(-)
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
