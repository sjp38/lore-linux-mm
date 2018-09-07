Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16B3E6B7D9C
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 05:24:01 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 2-v6so6835382plc.11
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 02:24:01 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a8-v6si6744516plp.61.2018.09.07.02.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 02:23:59 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V5 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
Date: Sat,  8 Sep 2018 02:03:02 +0800
Message-Id: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

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
https://lkml.org/lkml/2018/8/9/17

V4:
https://lkml.org/lkml/2018/8/22/17

V5:
[PATCH V3 1/4] Reviewed-by: David / Acked-by: Pankaj
[PATCH V3 2/4] Reviewed-by: Jan
[PATCH V3 3/4] Acked-by: Jan
[PATCH V3 4/4] Added "Acked-by: Pankaj", Added in-line comments: Dave

Zhang Yi (4):
  kvm: remove redundant reserved page check
  mm: introduce memory type MEMORY_DEVICE_DEV_DAX
  mm: add a function to differentiate the pages is from DAX device
    memory
  kvm: add a check if pfn is from NVDIMM pmem.

 drivers/dax/pmem.c       |  1 +
 include/linux/memremap.h |  8 ++++++++
 include/linux/mm.h       | 12 ++++++++++++
 virt/kvm/kvm_main.c      | 24 ++++++++++++++++--------
 4 files changed, 37 insertions(+), 8 deletions(-)

-- 
2.7.4
