Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBF66B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 01:20:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p189-v6so12542244pfp.2
        for <linux-mm@kvack.org>; Tue, 22 May 2018 22:20:16 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y34-v6si18372184plb.317.2018.05.22.22.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 22:20:14 -0700 (PDT)
Subject: [PATCH v2 0/7] mm: Rework hmm to use devm_memremap_pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 22 May 2018 22:10:17 -0700
Message-ID: <152705221686.21414.771870778478134768.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v1: [1]
* Kill support for mapping System RAM as a nop. No one uses this
  functionality and it is broken relative to percpu_ref management.

* Fix percpu_ref teardown. Given that devm_memremap_pages() has strict
  assumptions about when the percpu_ref is killed, give it
  responsibility to make the live-dead transition explicitly. (Logan)

* Split the patch that adds HMM support to devm_memremap_pages() from
  the patch that converts HMM to use devm_memremap_pages(). This caught
  an incomplete conversion in v1. (Logan)

* Collect Christoph's reviewed-by.

[1]: https://lkml.org/lkml/2018/5/21/1109

---

Hi Andrew, here's v2 to replace the 5 currently in mm. The first and
last patch did not change.

For maintainability, as ZONE_DEVICE continues to attract new users,
it is useful to keep all users consolidated on devm_memremap_pages() as
the interface for create "device pages".

The devm_memremap_pages() implementation was recently reworked to make
it more generic for arbitrary users, like the proposed peer-to-peer
PCI-E enabling. HMM pre-dated this rework and opted to duplicate
devm_memremap_pages() as hmm_devmem_pages_create().

Rework HMM to be a consumer of devm_memremap_pages() directly and fix up
the licensing on the exports given the deep dependencies on the mm.

Patches based on v4.17-rc6 where there are no upstream consumers of the
HMM functionality.

---

Dan Williams (7):
      mm, devm_memremap_pages: Mark devm_memremap_pages() EXPORT_SYMBOL_GPL
      mm, devm_memremap_pages: Kill mapping "System RAM" support
      mm, devm_memremap_pages: Fix shutdown handling
      mm, devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE support
      mm, hmm: Use devm semantics for hmm_devmem_{add,remove}
      mm, hmm: Replace hmm_devmem_pages_create() with devm_memremap_pages()
      mm, hmm: Mark hmm_devmem_{add,add_resource} EXPORT_SYMBOL_GPL


 Documentation/vm/hmm.txt          |    1 
 drivers/dax/pmem.c                |   10 -
 drivers/nvdimm/pmem.c             |   18 +-
 include/linux/hmm.h               |    4 
 include/linux/memremap.h          |    7 +
 kernel/memremap.c                 |   85 +++++++---
 mm/hmm.c                          |  307 +++++--------------------------------
 tools/testing/nvdimm/test/iomap.c |   21 ++-
 8 files changed, 130 insertions(+), 323 deletions(-)
