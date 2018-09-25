Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAEF8E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 02:26:57 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r20-v6so9260496pgv.20
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 23:26:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id be11-v6si1484587plb.347.2018.09.24.23.26.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 23:26:55 -0700 (PDT)
Subject: [PATCH v6 0/7] mm: Merge hmm into devm_memremap_pages, mark GPL-only
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 24 Sep 2018 23:14:54 -0700
Message-ID: <153785609460.283091.17422092801700439095.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>=?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v5 [1]:
* Move the percpu-ref kill function to be passed in via @pgmap (Christoph)
* Added Christoph's ack for patches 2 and 4
* Added JA(C)rA'me's Reviewed-by for patches 2-6
* Fix MEMORY_DEVICE_PRIVATE support (JA(C)rA'me)

[1]: https://lkml.org/lkml/2018/9/13/104

---

Hi Andrew,

JA(C)rA'me has reviewed the cleanups, thanks JA(C)rA'me. We still disagree on
the EXPORT_SYMBOL_GPL status of the core HMM implementation, but Logan,
Christoph and I continue to support marking all devm_memremap_pages()
derivatives EXPORT_SYMBOL_GPL.

HMM has been upstream for over a year, with no in-tree users it is clear
it was designed first and foremost for out of tree drivers. It takes
advantage of a facility Christoph and I spearheaded to support
persistent memory. It continues to see expanding use cases with no clear
end date when it will stop attracting features / revisions. It is not
suitable to export devm_memremap_pages() as a stable 3rd party driver
api.

devm_memremap_pages() is a facility that can create struct page entries
for any arbitrary range and give out-of-tree drivers the ability to
subvert core aspects of page management. It, and anything derived from
it (e.g. hmm, pcip2p, etc...), is a deep integration point into the core
kernel, and an EXPORT_SYMBOL_GPL() interface. 

Commit 31c5bda3a656 "mm: fix exports that inadvertently make put_page()
EXPORT_SYMBOL_GPL" was merged ahead of this series to relieve some of
the pressure from innocent consumers of put_page(), but now we need this
series to address *producers* of device pages.

More details and justification in the changelogs. The 0day
infrastructure has reported success across 152 configs and this survives
the libnvdimm unit test suite. Aside from the controversial bits the
diffstat is compelling at:

    7 files changed, 127 insertions(+), 321 deletions(-)

Note that the series has some minor collisions with Alex's recent series
to improve devm_memremap_pages() scalability [2]. So, whichever you take
first the other will need a minor rebase.

[2]: https://www.lkml.org/lkml/2018/9/11/10

---

Dan Williams (7):
      mm, devm_memremap_pages: Mark devm_memremap_pages() EXPORT_SYMBOL_GPL
      mm, devm_memremap_pages: Kill mapping "System RAM" support
      mm, devm_memremap_pages: Fix shutdown handling
      mm, devm_memremap_pages: Add MEMORY_DEVICE_PRIVATE support
      mm, hmm: Use devm semantics for hmm_devmem_{add,remove}
      mm, hmm: Replace hmm_devmem_pages_create() with devm_memremap_pages()
      mm, hmm: Mark hmm_devmem_{add,add_resource} EXPORT_SYMBOL_GPL


 drivers/dax/pmem.c                |   14 --
 drivers/nvdimm/pmem.c             |   13 +-
 include/linux/hmm.h               |    4 
 include/linux/memremap.h          |    2 
 kernel/memremap.c                 |   95 +++++++-----
 mm/hmm.c                          |  303 +++++--------------------------------
 tools/testing/nvdimm/test/iomap.c |   17 ++
 7 files changed, 127 insertions(+), 321 deletions(-)
