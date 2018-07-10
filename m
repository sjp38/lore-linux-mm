Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED4C96B000D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 04:23:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t10-v6so13525386pfh.0
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 01:23:05 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d11-v6si12604031pgm.556.2018.07.10.01.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 01:23:04 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V2 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
Date: Wed, 11 Jul 2018 01:01:25 +0800
Message-Id: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
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
*Add documentation for MEMORY_DEVICE_DEV_DAX memory type in comment block
*Add is_dax_page() in mm.h to differentiate the pages is from DAX device.
*Remove the function kvm_is_nd_pfn().

Zhang Yi (4):
  kvm: remove redundant reserved page check
  mm: introduce memory type MEMORY_DEVICE_DEV_DAX
  mm: add a function to differentiate the pages is from DAX device
    memory
  kvm: add a check if pfn is from NVDIMM pmem.

 drivers/dax/pmem.c       |  1 +
 include/linux/memremap.h |  9 +++++++++
 include/linux/mm.h       | 12 ++++++++++++
 virt/kvm/kvm_main.c      | 16 ++++++++--------
 4 files changed, 30 insertions(+), 8 deletions(-)

-- 
2.7.4
