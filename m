Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 604C26B0256
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 16:53:29 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 63so22072703pfe.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 13:53:29 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f75si651830pfj.152.2016.03.03.13.53.27
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 13:53:27 -0800 (PST)
Subject: [PATCH v2 0/3] libnvdimm, pfn: support section misaligned pmem
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 03 Mar 2016 13:53:04 -0800
Message-ID: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Haozhong Zhang <haozhong.zhang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>, linux-mm@kvack.org

Permit platforms with section-misaligned persistent memory to establish
memory-mode (pfn) namespaces.  This sacrifices 64-128MB of pmem to gain
third-party DMA/RDMA support.

Changes since v1 [1]:

1/ Dropped "mm: fix mixed zone detection in devm_memremap_pages" since
   it was pulled into Andrew's tree.

2/ Moved CONFIG_SPARSEMEM #ifdef guards into drivers/nvdimm/pfn.h

3/ Added "libnvdimm, pmem: adjust for section collisions with 'System
   RAM'", i.e. support for reserving head and tail capacity out of a
   namespace to permit a section aligned range to be used for a
   'pfn'-device instance.

4/ Added 'resource' and 'size' attributes to an active pfn instance.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2016-February/004727.html

This series is built on top of tip.git/core/resources.

---

Dan Williams (3):
      libnvdimm, pmem: fix 'pfn' support for section-misaligned namespaces
      libnvdimm, pmem: adjust for section collisions with 'System RAM'
      libnvdimm, pfn: 'resource'-address and 'size' attributes for pfn devices


 drivers/nvdimm/namespace_devs.c |    7 ++
 drivers/nvdimm/pfn.h            |   23 ++++++
 drivers/nvdimm/pfn_devs.c       |   61 ++++++++++++++++
 drivers/nvdimm/pmem.c           |  145 ++++++++++++++++++++++++++++++---------
 4 files changed, 200 insertions(+), 36 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
