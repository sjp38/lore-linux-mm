Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABC9E6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:45:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f10-v6so10800104pln.21
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:45:12 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b8-v6si14817158ple.469.2018.05.21.15.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:45:11 -0700 (PDT)
Subject: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 21 May 2018 15:35:14 -0700
Message-ID: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew, please consider this series for 4.18.

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

Dan Williams (5):
      mm, devm_memremap_pages: mark devm_memremap_pages() EXPORT_SYMBOL_GPL
      mm, devm_memremap_pages: handle errors allocating final devres action
      mm, hmm: use devm semantics for hmm_devmem_{add,remove}
      mm, hmm: replace hmm_devmem_pages_create() with devm_memremap_pages()
      mm, hmm: mark hmm_devmem_{add,add_resource} EXPORT_SYMBOL_GPL


 Documentation/vm/hmm.txt |    1 
 include/linux/hmm.h      |    4 -
 include/linux/memremap.h |    1 
 kernel/memremap.c        |   39 +++++-
 mm/hmm.c                 |  297 +++++++---------------------------------------
 5 files changed, 77 insertions(+), 265 deletions(-)
