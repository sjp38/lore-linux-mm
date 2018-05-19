Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5D856B06A7
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:44:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x21-v6so5673434pfn.23
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:44:50 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 65-v6si8786974pfo.229.2018.05.18.18.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 18:44:49 -0700 (PDT)
Subject: [PATCH v11 0/7] dax: fix dma vs truncate/hole-punch
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 18:34:51 -0700
Message-ID: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Matthew Wilcox <mawilcox@microsoft.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Heiko Carstens <heiko.carstens@de.ibm.com>, Jan Kara <jack@suse.cz>"Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, kbuild test robot <lkp@intel.com>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org, Thomas Meyer <thomas@m3y3r.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Changes since v9 [1] and v10 [2]

* Resend the full series with the reworked "mm: introduce
  MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS" (Christoph)
* Move generic_dax_pagefree() into the pmem driver (Christoph)
* Cleanup __bdev_dax_supported() (Christoph)
* Cleanup some stale SRCU bits leftover from other iterations (Jan)
* Cleanup xfs_break_layouts() (Jan)

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-April/015457.html
[2]: https://lists.01.org/pipermail/linux-nvdimm/2018-May/015885.html

---

Background:

get_user_pages() in the filesystem pins file backed memory pages for
access by devices performing dma. However, it only pins the memory pages
not the page-to-file offset association. If a file is truncated the
pages are mapped out of the file and dma may continue indefinitely into
a page that is owned by a device driver. This breaks coherency of the
file vs dma, but the assumption is that if userspace wants the
file-space truncated it does not matter what data is inbound from the
device, it is not relevant anymore. The only expectation is that dma can
safely continue while the filesystem reallocates the block(s).

Problem:

This expectation that dma can safely continue while the filesystem
changes the block map is broken by dax. With dax the target dma page
*is* the filesystem block. The model of leaving the page pinned for dma,
but truncating the file block out of the file, means that the filesytem
is free to reallocate a block under active dma to another file and now
the expected data-incoherency situation has turned into active
data-corruption.

Solution:

Defer all filesystem operations (fallocate(), truncate()) on a dax mode
file while any page/block in the file is under active dma. This solution
assumes that dma is transient. Cases where dma operations are known to
not be transient, like RDMA, have been explicitly disabled via
commits like 5f1d43de5416 "IB/core: disable memory registration of
filesystem-dax vmas".

The dax_layout_busy_page() routine is called by filesystems with a lock
held against mm faults (i_mmap_lock) to find pinned / busy dax pages.
The process of looking up a busy page invalidates all mappings
to trigger any subsequent get_user_pages() to block on i_mmap_lock.
The filesystem continues to call dax_layout_busy_page() until it finally
returns no more active pages. This approach assumes that the page
pinning is transient, if that assumption is violated the system would
have likely hung from the uncompleted I/O.

---

Dan Williams (7):
      memremap: split devm_memremap_pages() and memremap() infrastructure
      mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS
      mm: fix __gup_device_huge vs unmap
      mm, fs, dax: handle layout changes to pinned dax mappings
      xfs: prepare xfs_break_layouts() to be called with XFS_MMAPLOCK_EXCL
      xfs: prepare xfs_break_layouts() for another layout type
      xfs, dax: introduce xfs_break_dax_layouts()


 drivers/dax/super.c       |   14 ++-
 drivers/nvdimm/pfn_devs.c |    2 
 drivers/nvdimm/pmem.c     |   25 +++++
 fs/Kconfig                |    1 
 fs/dax.c                  |   97 +++++++++++++++++++++
 fs/xfs/xfs_file.c         |   72 ++++++++++++++--
 fs/xfs/xfs_inode.h        |   16 +++
 fs/xfs/xfs_ioctl.c        |    8 --
 fs/xfs/xfs_iops.c         |   16 ++-
 fs/xfs/xfs_pnfs.c         |   15 ++-
 fs/xfs/xfs_pnfs.h         |    5 +
 include/linux/dax.h       |    7 ++
 include/linux/memremap.h  |   36 ++------
 include/linux/mm.h        |   71 +++++++++++----
 kernel/Makefile           |    3 -
 kernel/iomem.c            |  167 ++++++++++++++++++++++++++++++++++++
 kernel/memremap.c         |  209 ++++++---------------------------------------
 mm/Kconfig                |    5 +
 mm/gup.c                  |   36 ++++++--
 mm/hmm.c                  |   13 ---
 mm/swap.c                 |    3 -
 21 files changed, 542 insertions(+), 279 deletions(-)
 create mode 100644 kernel/iomem.c
