Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F47F6B000E
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 23:02:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m19so3552826pgv.5
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 20:02:40 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c18si4138928pfe.335.2018.03.01.20.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 20:02:39 -0800 (PST)
Subject: [PATCH v5 00/12] vfio,
 dax: prevent long term filesystem-dax pins and other fixes
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:53:33 -0800
Message-ID: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-xfs@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, kvm@vger.kernel.org, Haozhong Zhang <haozhong.zhang@intel.com>, Jane Chu <jane.chu@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Gerd Rausch <gerd.rausch@oracle.com>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Theodore Ts'o <tytso@mit.edu>linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v4 [1]:
* Fix the changelog of "dax: introduce IS_DEVDAX() and IS_FSDAX()" to
  better clarify the need for new helpers (Jan)
* Replace dax_sem_is_locked() with dax_sem_assert_held() (Jan)
* Use file_inode() in vma_is_dax() (Jan)
* Resend the full series to linux-xfs@ (Dave)
* Collect Jan's Reviewed-by

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-February/014271.html
---

The vfio interface, like RDMA, wants to setup long term (indefinite)
pins of the pages backing an address range so that a guest or userspace
driver can perform DMA to the with physical address. Given that this
pinning may lead to filesystem operations deadlocking in the
filesystem-dax case, the pinning request needs to be rejected.

The longer term fix for vfio, RDMA, and any other long term pin user, is
to provide a 'pin with lease' mechanism. Similar to the leases that are
hold for pNFS RDMA layouts, this userspace lease gives the kernel a way
to notify userspace that the block layout of the file is changing and
the kernel is revoking access to pinned pages.

Related to this change is the discovery that vma_is_fsdax() was causing
device-dax inode detection to fail. That lead to series of fixes and
cleanups to make sure that S_DAX is defined correctly in the
CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case.

---

Dan Williams (12):
      dax: fix vma_is_fsdax() helper
      dax: introduce IS_DEVDAX() and IS_FSDAX()
      ext2, dax: finish implementing dax_sem helpers
      ext2, dax: define ext2_dax_*() infrastructure in all cases
      ext4, dax: define ext4_dax_*() infrastructure in all cases
      ext2, dax: replace IS_DAX() with IS_FSDAX()
      ext4, dax: replace IS_DAX() with IS_FSDAX()
      xfs, dax: replace IS_DAX() with IS_FSDAX()
      mm, dax: replace IS_DAX() with IS_DEVDAX() or IS_FSDAX()
      fs, dax: kill IS_DAX()
      dax: fix S_DAX definition
      vfio: disable filesystem-dax page pinning


 drivers/vfio/vfio_iommu_type1.c |   18 ++++++++++++++--
 fs/ext2/ext2.h                  |    6 +++++
 fs/ext2/file.c                  |   19 +++++------------
 fs/ext2/inode.c                 |   10 ++++-----
 fs/ext4/file.c                  |   18 +++++-----------
 fs/ext4/inode.c                 |    4 ++--
 fs/ext4/ioctl.c                 |    2 +-
 fs/ext4/super.c                 |    2 +-
 fs/iomap.c                      |    2 +-
 fs/xfs/xfs_file.c               |   14 ++++++-------
 fs/xfs/xfs_ioctl.c              |    4 ++--
 fs/xfs/xfs_iomap.c              |    6 +++--
 fs/xfs/xfs_reflink.c            |    2 +-
 include/linux/dax.h             |   12 ++++++++---
 include/linux/fs.h              |   43 ++++++++++++++++++++++++++++-----------
 mm/fadvise.c                    |    3 ++-
 mm/filemap.c                    |    4 ++--
 mm/huge_memory.c                |    4 +++-
 mm/madvise.c                    |    3 ++-
 19 files changed, 102 insertions(+), 74 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
