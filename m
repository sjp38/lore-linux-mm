Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1981A6B0038
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:41:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v78so16168923pgb.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:41:41 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c25si1822076pgn.756.2017.10.06.15.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 15:41:39 -0700 (PDT)
Subject: [PATCH v7 00/12] MAP_DIRECT for DAX RDMA and userspace flush
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Oct 2017 15:35:13 -0700
Message-ID: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Sean Hefty <sean.hefty@intel.com>, Jeff Layton <jlayton@poochiereds.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jeff Moyer <jmoyer@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Robin Murphy <robin.murphy@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Woodhouse <dwmw2@infradead.org>

Changes since v6 [1]:
* Abandon the concept of immutable files and rework the implementation
  to reuse same FL_LAYOUT file lease mechanism that coordinates pnfsd
  layouts vs local filesystem changes. This establishes an interface where
  the kernel is always in control of the block-map and is free to
  invalidate MAP_DIRECT mappings when a lease breaker arrives. (Christoph)

* Introduce a new ->mmap_validate() file operation since we need both
  the original @flags and @fd passed to mmap(2) to setup a MAP_DIRECT
  mapping.

* Introduce a ->lease_direct() vm operation to allow the RDMA core to
  safely register memory against DAX and tear down the mapping when the
  lease is broken. This can be reused by any sub-system that follows a
  memory registration semantic.

[1]: https://lkml.org/lkml/2017/8/23/754

---

MAP_DIRECT is a mechanism that allows an application to establish a
mapping where the kernel will not change the block-map, or otherwise
dirty the block-map metadata of a file without notification. It supports
a "flush from userspace" model where persistent memory applications can
bypass the overhead of ongoing coordination of writes with the
filesystem, and it provides safety to RDMA operations involving DAX
mappings.

The kernel always has the ability to revoke access and convert the file
back to normal operation after performing a "lease break". Similar to
fcntl leases, there is no way for userspace to to cancel the lease break
process once it has started, it can only delay it via the
/proc/sys/fs/lease-break-time setting.

MAP_DIRECT enables XFS to supplant the device-dax interface for
mmap-write access to persistent memory with no ongoing coordination with
the filesystem via fsync/msync syscalls.

---

Dan Williams (12):
      mm: introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap flags
      fs, mm: pass fd to ->mmap_validate()
      fs: introduce i_mapdcount
      fs: MAP_DIRECT core
      xfs: prepare xfs_break_layouts() for reuse with MAP_DIRECT
      xfs: wire up MAP_DIRECT
      dma-mapping: introduce dma_has_iommu()
      fs, mapdirect: introduce ->lease_direct()
      xfs: wire up ->lease_direct()
      device-dax: wire up ->lease_direct()
      IB/core: use MAP_DIRECT to fix / enable RDMA to DAX mappings
      tools/testing/nvdimm: enable rdma unit tests


 arch/alpha/include/uapi/asm/mman.h           |    1 
 arch/mips/include/uapi/asm/mman.h            |    1 
 arch/mips/kernel/vdso.c                      |    2 
 arch/parisc/include/uapi/asm/mman.h          |    1 
 arch/tile/mm/elf.c                           |    3 
 arch/x86/mm/mpx.c                            |    3 
 arch/xtensa/include/uapi/asm/mman.h          |    1 
 drivers/base/dma-mapping.c                   |   10 +
 drivers/dax/device.c                         |    4 
 drivers/infiniband/core/umem.c               |   90 ++++++-
 drivers/iommu/amd_iommu.c                    |    6 
 drivers/iommu/intel-iommu.c                  |    6 
 fs/Kconfig                                   |    4 
 fs/Makefile                                  |    1 
 fs/aio.c                                     |    2 
 fs/mapdirect.c                               |  349 ++++++++++++++++++++++++++
 fs/xfs/Kconfig                               |    4 
 fs/xfs/Makefile                              |    1 
 fs/xfs/xfs_file.c                            |  130 ++++++++++
 fs/xfs/xfs_iomap.c                           |    9 +
 fs/xfs/xfs_layout.c                          |   42 +++
 fs/xfs/xfs_layout.h                          |   13 +
 fs/xfs/xfs_pnfs.c                            |   30 --
 fs/xfs/xfs_pnfs.h                            |   10 -
 include/linux/dma-mapping.h                  |    3 
 include/linux/fs.h                           |   33 ++
 include/linux/mapdirect.h                    |   68 +++++
 include/linux/mm.h                           |   15 +
 include/linux/mman.h                         |   42 +++
 include/rdma/ib_umem.h                       |    8 +
 include/uapi/asm-generic/mman-common.h       |    1 
 include/uapi/asm-generic/mman.h              |    1 
 ipc/shm.c                                    |    3 
 mm/internal.h                                |    2 
 mm/mmap.c                                    |   28 ++
 mm/nommu.c                                   |    5 
 mm/util.c                                    |    7 -
 tools/include/uapi/asm-generic/mman-common.h |    1 
 tools/testing/nvdimm/Kbuild                  |   31 ++
 tools/testing/nvdimm/config_check.c          |    2 
 tools/testing/nvdimm/test/iomap.c            |    6 
 41 files changed, 906 insertions(+), 73 deletions(-)
 create mode 100644 fs/mapdirect.c
 create mode 100644 fs/xfs/xfs_layout.c
 create mode 100644 fs/xfs/xfs_layout.h
 create mode 100644 include/linux/mapdirect.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
