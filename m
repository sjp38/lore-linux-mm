Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC568E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 22:33:46 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r20-v6so1808568pgv.20
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 19:33:46 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 5-v6si2657044plx.27.2018.09.12.19.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 19:33:44 -0700 (PDT)
Subject: [PATCH v5 0/7] mm: Merge hmm into devm_memremap_pages, mark GPL-only
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Sep 2018 19:22:00 -0700
Message-ID: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v4 [1]:
* Rebase on v4.19-rc3
* Update changelogs and cover letter

[1]: https://lkml.org/lkml/2018/7/11/14

---

Hi Andrew,

Back from vacation and this series is still top of mind.
devm_memremap_pages() is a facility that can create struct page entries
for any arbitrary range and give drivers the ability to subvert core
aspects of page management. It, and anything derived from it (e.g. hmm,
pcip2p, etc...), is an EXPORT_SYMBOL_GPL() interface.

I see that commit 31c5bda3a656 "mm: fix exports that inadvertently make
put_page() EXPORT_SYMBOL_GPL" was merged ahead of this series to relieve
some of the pressure from innocent consumers of put_page(), but now we
need this series to address *producers* of device pages.

More details and justification in the changelogs. The 0day
infrastructure has reported success across 182 configs and this survives
the libnvdimm unit test suite. Aside from the controversial bits the
diffstat is compelling at:

    7 files changed, 138 insertions(+), 328 deletions(-).

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


 drivers/dax/pmem.c                |   15 --
 drivers/nvdimm/pmem.c             |   18 +-
 include/linux/hmm.h               |    4 
 include/linux/memremap.h          |    7 +
 kernel/memremap.c                 |   98 ++++++++----
 mm/hmm.c                          |  303 +++++--------------------------------
 tools/testing/nvdimm/test/iomap.c |   21 ++-
 7 files changed, 138 insertions(+), 328 deletions(-)
