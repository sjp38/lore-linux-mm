Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDF5A6B0003
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:43:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n78so14241996pfj.4
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:43:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b8-v6si1517102pls.261.2018.04.24.16.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 16:42:59 -0700 (PDT)
Subject: [PATCH v9 0/9] dax: fix dma vs truncate/hole-punch
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 24 Apr 2018 16:33:01 -0700
Message-ID: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Heiko Carstens <heiko.carstens@de.ibm.com>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, kbuild test robot <lkp@intel.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, stable@vger.kernel.org, Thomas Meyer <thomas@m3y3r.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.orgjack@suse.czhch@lst.de

Changes since v8 [1]:
* Rebase on v4.17-rc2

* Fix get_user_pages_fast() for ZONE_DEVICE pages to revalidate the pte,
  pmd, pud after taking references (Jan)

* Kill dax_layout_lock(). With get_user_pages_fast() for ZONE_DEVICE
  fixed we can then rely on the {pte,pmd}_lock to synchronize
  dax_layout_busy_page() vs new page references (Jan)

* Hold the iolock over repeated invocations of dax_layout_busy_page() to
  enable truncate/hole-punch to make forward progress in the presence of
  a constant stream of new direct-I/O requests (Jan).

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-March/015058.html

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

Dan Williams (9):
      dax, dm: introduce ->fs_{claim,release}() dax_device infrastructure
      mm, dax: enable filesystems to trigger dev_pagemap ->page_free callbacks
      memremap: split devm_memremap_pages() and memremap() infrastructure
      mm, dev_pagemap: introduce CONFIG_DEV_PAGEMAP_OPS
      mm: fix __gup_device_huge vs unmap
      mm, fs, dax: handle layout changes to pinned dax mappings
      xfs: prepare xfs_break_layouts() to be called with XFS_MMAPLOCK_EXCL
      xfs: prepare xfs_break_layouts() for another layout type
      xfs, dax: introduce xfs_break_dax_layouts()


 drivers/dax/super.c      |   99 ++++++++++++++++++++--
 drivers/md/dm.c          |   57 +++++++++++++
 drivers/nvdimm/pmem.c    |    3 -
 fs/Kconfig               |    2 
 fs/dax.c                 |   97 +++++++++++++++++++++
 fs/ext2/super.c          |    6 +
 fs/ext4/super.c          |    6 +
 fs/xfs/xfs_file.c        |   72 +++++++++++++++-
 fs/xfs/xfs_inode.h       |   16 ++++
 fs/xfs/xfs_ioctl.c       |    8 --
 fs/xfs/xfs_iops.c        |   16 ++--
 fs/xfs/xfs_pnfs.c        |   16 ++--
 fs/xfs/xfs_pnfs.h        |    6 +
 fs/xfs/xfs_super.c       |   20 ++--
 include/linux/dax.h      |   71 +++++++++++++++-
 include/linux/memremap.h |   25 ++----
 include/linux/mm.h       |   71 ++++++++++++----
 kernel/Makefile          |    3 -
 kernel/iomem.c           |  167 +++++++++++++++++++++++++++++++++++++
 kernel/memremap.c        |  208 ++++++----------------------------------------
 mm/Kconfig               |    5 +
 mm/gup.c                 |   37 ++++++--
 mm/hmm.c                 |   13 ---
 mm/swap.c                |    3 -
 24 files changed, 730 insertions(+), 297 deletions(-)
 create mode 100644 kernel/iomem.c
