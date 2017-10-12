Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 479D86B0261
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:16:46 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 24so2949291qts.2
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 23:16:46 -0700 (PDT)
Received: from sasl.smtp.pobox.com (pb-smtp2.pobox.com. [64.147.108.71])
        by mx.google.com with ESMTPS id d29si3721256qtc.94.2017.10.11.23.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 23:16:44 -0700 (PDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v6 0/4] cramfs refresh for embedded usage
Date: Thu, 12 Oct 2017 02:16:09 -0400
Message-Id: <20171012061613.28705-1-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

This series brings a nice refresh to the cramfs filesystem, adding the
following capabilities:

- Direct memory access, bypassing the block and/or MTD layers entirely.

- Ability to store individual data blocks uncompressed.

- Ability to locate individual data blocks anywhere in the filesystem.

The end result is a very tight filesystem that can be accessed directly
from ROM without any other subsystem underneath. This also allows for
user space XIP which is a very important feature for tiny embedded
systems.

This series is also available based on v4.14-rc3 via git here:

  http://git.linaro.org/people/nicolas.pitre/linux xipcramfs

Why cramfs?

  Because cramfs is very simple and small. With CONFIG_CRAMFS_BLOCK=n and
  CONFIG_CRAMFS_PHYSMEM=y the cramfs driver may use as little as 3704 bytes
  of code. That's many times smaller than squashfs. And the runtime memory
  usage is also much less with cramfs than squashfs. It packs very tightly
  already compared to romfs which has no compression support. And the cramfs
  format was simple to extend, allowing for both compressed and uncompressed
  blocks within the same file.

Does it use MTD or not?

  The MTD layer is used to get at the actual physical/virtual address
  for the filesystem image. The underlying MTD device (or a partition
  based on it) specified as mount argument must use a driver that
  implements the mtd->_point method. Once mtd_point() is successful,
  all accesses are performed directly in memory and the MTD layer is
  no longer involved. Patches adding point support to a few more MTD
  drivers can be found here:

    http://git.linaro.org/people/nicolas.pitre/linux mtd_point

Why not using DAX?

  DAX stands for "Direct Access" and is a generic kernel layer helping
  with the necessary tasks involved with XIP. It is tailored for large
  writable filesystems and relies on the presence of an MMU. It also has
  the following shortcoming: "The DAX code does not work correctly on
  architectures which have virtually mapped caches such as ARM, MIPS and
  SPARC." That makes it unsuitable for a large portion of the intended
  targets for this series. And due to the read-only nature of cramfs, it is
  possible to achieve the intended result with a much simpler approach making
  DAX somewhat overkill in this context.

The maximum size of a cramfs image can't exceed 272MB. In practice it is
likely to be much much less. Given this series is concerned with small
memory systems, even in the MMU case there is always plenty of vmalloc
space left to map it all and even a 272MB memremap() wouldn't be a
problem. If it is then maybe your system is big enough with large
resources to manage already and you're pretty unlikely to be using cramfs
in the first place.

Of course, while this cramfs remains backward compatible with existing
filesystem images, a newer mkcramfs version is necessary to take advantage
of the extended data layout. I created a version of mkcramfs that
detects ELF files and marks text+rodata segments for XIP and compresses the
rest of those ELF files automatically.

So here it is. I'm also willing to step up as cramfs maintainer given
that no sign of any maintenance activities appeared for years.


Changes from v5:

- Switch to MTD for obtaining the cramfs image memory address rather than
  accepting a physical address directly as a mount argument.
- Drop the patch for making root mount possible as the MTD mount case is
  already supported and that covers our usage.
- There is no longer a separate filesystem type. It is "cramfs" for both
  blockdev based and MTD/memory based accesses.
- Fix NULL deref in cramfs_statfs() when using direct memory access.

Changes from v4:

- Remove fault handler with vma splitting code in favor of VM_MIXEDMAP for
  much simpler code. Thanks to Christoph Hellwig for review and suggestions.
- Additional code cleanups, mostly from Christoph's suggestions.

Changes from v3:

- Rebased on v4.13.
- Made direct access depend on cramfs not being modular due to unexported
  vma handling functions.
- Solicit comments from mm people explicitly.

Changes from v2:

- Plugged a few races in cramfs_vmasplit_fault(). Thanks to Al Viro for
  highlighting them.
- Fixed some checkpatch warnings

Changes from v1:

- Improved mmap() support by adding the ability to partially populate a
  mapping and lazily split the non directly mapable pages to a separate
  vma at fault time (thanks to Chris Brandt for testing).
- Clarified the documentation some more.


diffstat:

 Documentation/filesystems/cramfs.txt |  42 +++
 MAINTAINERS                          |   4 +-
 fs/cramfs/Kconfig                    |  39 ++-
 fs/cramfs/README                     |  31 +-
 fs/cramfs/inode.c                    | 514 +++++++++++++++++++++++++----
 include/uapi/linux/cramfs_fs.h       |  26 +-
 6 files changed, 587 insertions(+), 69 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
