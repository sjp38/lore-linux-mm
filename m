Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25DFA6B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 02:26:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z5so3791120pfe.16
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 23:26:48 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o74si1403487pfj.75.2018.02.22.23.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 23:26:47 -0800 (PST)
Subject: [PATCH v2 0/5] vfio,
 dax: prevent long term filesystem-dax pins and other fixes
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 22 Feb 2018 23:17:40 -0800
Message-ID: <151937026001.18973.12034171121582300402.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Haozhong Zhang <haozhong.zhang@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, Gerd Rausch <gerd.rausch@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>

Changes since v1 [1]:

* Fix the detection of device-dax file instances in vma_is_fsdax().
  (Haozhong, Gerd)

* Fix compile breakage in the FS_DAX=n and DEV_DAX=y case. (0day robot)

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

Dan Williams (5):
      dax: fix vma_is_fsdax() helper
      dax: fix dax_mapping() definition in the FS_DAX=n + DEV_DAX=y case
      dax: fix S_DAX definition
      dax: short circuit vma_is_fsdax() in the CONFIG_FS_DAX=n case
      vfio: disable filesystem-dax page pinning


 drivers/vfio/vfio_iommu_type1.c |   18 +++++++++++++++---
 include/linux/dax.h             |    9 ++++++---
 include/linux/fs.h              |    6 ++++--
 3 files changed, 25 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
