Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8996B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:14:40 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x32-v6so11482870pld.16
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:14:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f40-v6si14395235plb.504.2018.06.18.23.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 23:14:39 -0700 (PDT)
Subject: [PATCH v3 0/8] mm: Rework hmm to use devm_memremap_pages and other
 fixes
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Jun 2018 23:04:39 -0700
Message-ID: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>, Joe Gorse <jhgorse@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v2 [1]:
* Rebased on v4.18-rc1
* Collect Logan's reviewed-by for "mm, devm_memremap_pages: Add
  MEMORY_DEVICE_PRIVATE support"
* Convert __put_devmap_managed_page and devmap_managed_key to
  EXPORT_SYMBOL otherwise put_page() becomes limited to GPL-only
  modules.
* Clarify some of the changelogs.

[1]: https://lkml.org/lkml/2018/5/23/24

---

Hi Andrew, here's v3 to replace these 5 currently in mm:

mm-devm_memremap_pages-mark-devm_memremap_pages-export_symbol_gpl.patch
mm-devm_memremap_pages-handle-errors-allocating-final-devres-action.patch
mm-hmm-use-devm-semantics-for-hmm_devmem_add-remove.patch
mm-hmm-replace-hmm_devmem_pages_create-with-devm_memremap_pages.patch
mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl.patch

For maintainability, as ZONE_DEVICE continues to attract new users,
it is useful to keep all users consolidated on devm_memremap_pages() as
the interface for create "device pages".

The devm_memremap_pages() implementation was recently reworked to make
it more generic for arbitrary users, like the proposed peer-to-peer
PCI-E enabling. HMM pre-dated this rework and opted to duplicate
devm_memremap_pages() as hmm_devmem_pages_create().

Rework HMM to be a consumer of devm_memremap_pages() directly and fix up
the licensing on the exports given the deep dependencies on the mm.

Patches based on v4.18-rc1 where there are no upstream consumers of the
HMM functionality.

---

Dan Williams (8):
      mm, devm_memremap_pages: Mark devm_memremap_pages() EXPORT_SYMBOL_GPL
      mm, devm_memremap_pages: Kill mapping "System RAM" support
      mm, devm_memremap_pages: Fix shutdown handling
      mm, devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE support
      mm, hmm: Use devm semantics for hmm_devmem_{add,remove}
      mm, hmm: Replace hmm_devmem_pages_create() with devm_memremap_pages()
      mm, hmm: Mark hmm_devmem_{add,add_resource} EXPORT_SYMBOL_GPL
      mm: Fix exports that inadvertently make put_page() EXPORT_SYMBOL_GPL


 drivers/dax/pmem.c                |   10 -
 drivers/nvdimm/pmem.c             |   18 +-
 include/linux/hmm.h               |    4 
 include/linux/memremap.h          |    7 +
 kernel/memremap.c                 |   89 +++++++----
 mm/hmm.c                          |  307 +++++--------------------------------
 tools/testing/nvdimm/test/iomap.c |   21 ++-
 7 files changed, 132 insertions(+), 324 deletions(-)
