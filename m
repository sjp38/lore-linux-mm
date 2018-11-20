Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB94C6B2287
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 18:25:18 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id x7so4144607pll.23
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 15:25:18 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id bi6si28276432plb.279.2018.11.20.15.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 15:25:17 -0800 (PST)
Subject: [PATCH v8 0/7] mm: Merge hmm into devm_memremap_pages, mark GPL-only
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 20 Nov 2018 15:12:49 -0800
Message-ID: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>=?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

Changes since v7 [1]:
* Rebase on next-20181119

[1]: https://lkml.org/lkml/2018/10/12/878

---

At Maintainer Summit, Greg brought up a topic I proposed around
EXPORT_SYMBOL_GPL usage. The motivation was considerations for when
EXPORT_SYMBOL_GPL is warranted and the criteria for taking the
exceptional step of reclassifying an existing export. Specifically, I
wanted to make the case that although the line is fuzzy and hard to
specify in abstract terms, it is nonetheless clear that
devm_memremap_pages() and HMM (Heterogeneous Memory Management) have
crossed it. The devm_memremap_pages() facility should have been
EXPORT_SYMBOL_GPL from the beginning, and HMM as a derivative of that
functionality should have naturally picked up that designation as well.

Contrary to typical rules, the HMM infrastructure was merged upstream
with zero in-tree consumers. There was a promise at the time that those
users would be merged "soon", but it has been over a year with no drivers
arriving. While the Nouveau driver is about to belatedly make good on
that promise it is clear that HMM was targeted first and foremost at an
out-of-tree consumer.

HMM is derived from devm_memremap_pages(), a facility Christoph and I
spearheaded to support persistent memory. It combines a device lifetime
model with a dynamically created 'struct page' / memmap array for any
physical address range. It enables coordination and control of the many
code paths in the kernel built to interact with memory via 'struct page'
objects. With HMM the integration goes even deeper by allowing device
drivers to hook and manipulate page fault and page free events.

One interpretation of when EXPORT_SYMBOL is suitable is when it is
exporting stable and generic leaf functionality.  The
devm_memremap_pages() facility continues to see expanding use cases,
peer-to-peer DMA being the most recent, with no clear end date when it
will stop attracting reworks and semantic changes. It is not suitable to
export devm_memremap_pages() as a stable 3rd party driver API due to the
fact that it is still changing and manipulates core behavior. Moreover,
it is not in the best interest of the long term development of the core
memory management subsystem to permit any external driver to effectively
define its own system-wide memory management policies with no
encouragement to engage with upstream.

I am also concerned that HMM was designed in a way to minimize further
engagement with the core-MM. That, with these hooks in place,
device-drivers are free to implement their own policies without much
consideration for whether and how the core-MM could grow to meet that
need. Going forward not only should HMM be EXPORT_SYMBOL_GPL, but the
core-MM should be allowed the opportunity and stimulus to change and
address these new use cases as first class functionality.

There is some more detailed justification in the individual changelogs.
The 0day infrastructure has reported build success on 102 configs and
this survives the libnvdimm unit test suite. Setting aside the
controversial aspect, the diffstat is compelling at:

	7 files changed, 126 insertions(+), 323 deletions(-)

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
 kernel/memremap.c                 |   94 +++++++----
 mm/hmm.c                          |  305 +++++--------------------------------
 tools/testing/nvdimm/test/iomap.c |   17 ++
 7 files changed, 126 insertions(+), 323 deletions(-)
