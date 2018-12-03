Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3661D6B6ABD
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 14:25:23 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so11994138pfe.10
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 11:25:23 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f63si16103419pfg.136.2018.12.03.11.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 11:25:21 -0800 (PST)
Subject: [PATCH RFC 0/3] Fix KVM misinterpreting Reserved page as an MMIO
 page
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 03 Dec 2018 11:25:20 -0800
Message-ID: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, pbonzini@redhat.com, yi.z.zhang@linux.intel.com, brho@google.com, kvm@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, rkrcmar@redhat.com, jglisse@redhat.com

I have loosely based this patch series off of the following patch series
from Zhang Yi:
https://lore.kernel.org/lkml/cover.1536342881.git.yi.z.zhang@linux.intel.com

The original set had attempted to address the fact that DAX pages were
treated like MMIO pages which had resulted in reduced performance. It
attempted to address this by ignoring the PageReserved flag if the page
was either a DEV_DAX or FS_DAX page.

I am proposing this as an alternative to that set. The main reason for this
is because I believe there are a few issues that were overlooked with that
original set. Specifically KVM seems to have two different uses for the
PageReserved flag. One being whether or not we can pin the memory, the other
being if we should be marking the pages as dirty or accessed. I believe
only the pinning really applies so I have split the uses of
kvm_is_reserved_pfn and updated the function uses to determine support for
page pinning to include a check of the pgmap to see if it supports pinning.

---

Alexander Duyck (3):
      kvm: Split use cases for kvm_is_reserved_pfn to kvm_is_refcounted_pfn
      mm: Add support for exposing if dev_pagemap supports refcount pinning
      kvm: Add additional check to determine if a page is refcounted


 arch/x86/kvm/mmu.c        |    6 +++---
 drivers/nvdimm/pfn_devs.c |    2 ++
 include/linux/kvm_host.h  |    2 +-
 include/linux/memremap.h  |    5 ++++-
 include/linux/mm.h        |   11 +++++++++++
 virt/kvm/kvm_main.c       |   34 +++++++++++++++++++++++++---------
 6 files changed, 46 insertions(+), 14 deletions(-)

--
