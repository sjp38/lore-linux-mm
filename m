Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3A9E6B0269
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 01:25:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id cf17-v6so6610014plb.2
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 22:25:13 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id cf13-v6si18773882plb.175.2018.07.10.22.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 22:25:12 -0700 (PDT)
Subject: [PATCH v4 7/8] mm, hmm: Mark hmm_devmem_{add,
 add_resource} EXPORT_SYMBOL_GPL
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Jul 2018 22:15:14 -0700
Message-ID: <153128611419.2928.14858876648286345508.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153128607743.2928.4465435789810433432.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153128607743.2928.4465435789810433432.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The routines hmm_devmem_add(), and hmm_devmem_add_resource() duplicated
devm_memremap_pages() and are now simple now wrappers around the core
facility to inject a dev_pagemap instance into the global pgmap_radix
and hook page-idle events. The devm_memremap_pages() interface is base
infrastructure for HMM. HMM has more and deeper ties into the kernel
memory management implementation than base ZONE_DEVICE which is itself a
EXPORT_SYMBOL_GPL facility.

Originally, the HMM page structure creation routines copied the
devm_memremap_pages() code and reused ZONE_DEVICE. A cleanup to unify
the implementations was discussed during the initial review:
http://lkml.iu.edu/hypermail/linux/kernel/1701.2/00812.html
Recent work to extend devm_memremap_pages() for the peer-to-peer-DMA
facility enabled this cleanup to move forward.

In addition to the integration with devm_memremap_pages() HMM depends on
other GPL-only symbols:

    mmu_notifier_unregister_no_release
    percpu_ref
    region_intersects
    __class_create

It goes further to consume / indirectly expose functionality that is not
exported to any other driver:

    alloc_pages_vma
    walk_page_range

HMM depends upon and extends deep core-kernel fundamentals. Mark its
main entry points EXPORT_SYMBOL_GPL().

Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/hmm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c5a6e61ee302..0af3220ffcba 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1055,7 +1055,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 		return result;
 	return devmem;
 }
-EXPORT_SYMBOL(hmm_devmem_add);
+EXPORT_SYMBOL_GPL(hmm_devmem_add);
 
 struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 					   struct device *device,
@@ -1109,7 +1109,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 		return result;
 	return devmem;
 }
-EXPORT_SYMBOL(hmm_devmem_add_resource);
+EXPORT_SYMBOL_GPL(hmm_devmem_add_resource);
 
 /*
  * A device driver that wants to handle multiple devices memory through a
