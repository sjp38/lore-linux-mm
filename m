Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1111D6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 01:24:38 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z21-v6so6533104plo.13
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 22:24:38 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m24-v6si17840319pgl.452.2018.07.10.22.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 22:24:36 -0700 (PDT)
Subject: [PATCH v4 0/8] mm: Rework hmm to use devm_memremap_pages and other
 fixes
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Jul 2018 22:14:37 -0700
Message-ID: <153128607743.2928.4465435789810433432.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>, Joe Gorse <jhgorse@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v3 [1]:
* Collect Logan's reviewed-by on patch 3
* Collect John's and Joe's tested-by on patch 8
* Update the changelog for patch 1 and 7 to better explain the
  EXPORT_SYMBOL_GPL rationale.
* Update the changelog for patch 2 to clarify that it is a cleanup to
  make the following patch-3 fix easier

[1]: https://lkml.org/lkml/2018/6/19/108

---

Hi Andrew,

As requested, here is a resend of the devm_memremap_pages() fixups.
Please consider for 4.18.

---

As ZONE_DEVICE continues to attract new users, it is imperative to keep
all users consolidated on devm_memremap_pages() as the interface for
create "device pages".

The devm_memremap_pages() implementation was recently reworked to make
it more generic for arbitrary users, like the proposed peer-to-peer
PCI-E enabling. HMM pre-dated this rework and opted to duplicate
devm_memremap_pages() as hmm_devmem_pages_create().

Rework hmm to be a consumer of devm_memremap_pages() directly and fix up
the licensing on the exports given the deep dependencies and exposure of
core mm internals.

With the exports of devm_memremap_pages() and hmm fixed up we can fix
the regression of inadvertently making put_page() have EXPORT_SYMBOL_GPL
dependencies, which breaks consumers like OpenAFS.

The series was tested against v4.18-rc2.

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
 mm/hmm.c                          |  306 +++++--------------------------------
 tools/testing/nvdimm/test/iomap.c |   21 ++-
 7 files changed, 132 insertions(+), 323 deletions(-)
