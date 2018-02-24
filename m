Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9E66B0007
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 19:52:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s17so4965882pfm.23
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 16:52:13 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a34-v6si2634430pld.505.2018.02.23.16.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 16:52:12 -0800 (PST)
Subject: [PATCH v3 0/6] vfio,
 dax: prevent long term filesystem-dax pins and other fixes
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 23 Feb 2018 16:43:05 -0800
Message-ID: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jane Chu <jane.chu@oracle.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, Gerd Rausch <gerd.rausch@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>

Changes since v2 [1]:

* Fix yet more compile breakage in the FS_DAX=n and DEV_DAX=y case.
  (0day robot)

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-February/014046.html

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

---

Dan Williams (6):
      dax: fix vma_is_fsdax() helper
      dax: fix dax_mapping() definition in the FS_DAX=n + DEV_DAX=y case
      xfs, dax: introduce IS_FSDAX()
      dax: fix S_DAX definition
      dax: short circuit vma_is_fsdax() in the CONFIG_FS_DAX=n case
      vfio: disable filesystem-dax page pinning


 drivers/vfio/vfio_iommu_type1.c |   18 +++++++++++++++---
 fs/xfs/xfs_file.c               |   14 +++++++-------
 fs/xfs/xfs_ioctl.c              |    4 ++--
 fs/xfs/xfs_iomap.c              |    6 +++---
 fs/xfs/xfs_reflink.c            |    2 +-
 include/linux/dax.h             |    9 ++++++---
 include/linux/fs.h              |    8 ++++++--
 7 files changed, 40 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
