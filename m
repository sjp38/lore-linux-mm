Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84BE66B0005
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 22:14:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id y16-v6so1900558pgv.23
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 19:14:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 2-v6si6781159pfd.39.2018.08.08.19.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 19:14:09 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V3 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
Date: Thu,  9 Aug 2018 18:52:48 +0800
Message-Id: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

For device specific memory space, when we move these area of pfn to
memory zone, we will set the page reserved flag at that time, some of
these reserved for device mmio, and some of these are not, such as
NVDIMM pmem.

Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
backend, since these pages are reserved. the check of
kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
to indentify these pages are from NVDIMM pmem. and let kvm treat these
as normal pages.

Without this patch, Many operations will be missed due to this
mistreatment to pmem pages. For example, a page may not have chance to
be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.

V1:
https://lkml.org/lkml/2018/7/4/91

V2:
https://lkml.org/lkml/2018/7/10/135

V3:
[PATCH V3 1/4] Needs Comments.
[PATCH V3 2/4] Update the description of MEMORY_DEVICE_DEV_DAX: Jan
[PATCH V3 3/4] Acked-by: Jan in V2
[PATCH V3 4/4] Needs Comments.

Zhang Yi (4):
  kvm: remove redundant reserved page check
  mm: introduce memory type MEMORY_DEVICE_DEV_DAX
  mm: add a function to differentiate the pages is from DAX device
    memory
  kvm: add a check if pfn is from NVDIMM pmem.

 drivers/dax/pmem.c       |  1 +
 include/linux/memremap.h |  8 ++++++++
 include/linux/mm.h       | 12 ++++++++++++
 virt/kvm/kvm_main.c      | 16 ++++++++--------
 4 files changed, 29 insertions(+), 8 deletions(-)

-- 
2.7.4
