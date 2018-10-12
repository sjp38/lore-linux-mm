Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E69E6B000E
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:59:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p89-v6so12293496pfj.12
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:59:27 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d41-v6si1865212pla.172.2018.10.12.10.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 10:59:26 -0700 (PDT)
Subject: [PATCH v7 0/7] mm: Merge hmm into devm_memremap_pages, mark GPL-only
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 12 Oct 2018 10:47:37 -0700
Message-ID: <153936645715.1197954.17511560935912733744.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>=?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v6 [1]:
* Rebase on next-20181008 and fixup conflicts with the xarray conversion
  and hotplug optimizations
* It has soaked on a 0day visible branch for a few days without any
  reports.

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

	7 files changed, 126 insertions(+), 323 deletions(-)

Note that the series has some minor collisions with Alex's recent series
to improve devm_memremap_pages() scalability [2]. So, whichever you take
first the other will need a minor rebase.

[2]: https://www.lkml.org/lkml/2018/9/11/10

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
 kernel/memremap.c                 |   94 +++++++----
 mm/hmm.c                          |  305 +++++--------------------------------
 tools/testing/nvdimm/test/iomap.c |   17 ++
 7 files changed, 126 insertions(+), 323 deletions(-)
