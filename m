Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2236B0010
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 02:51:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b9-v6so2012319pgq.17
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 23:51:48 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n7-v6si3011498pfn.270.2018.07.03.23.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 23:51:46 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH 0/3] Fix kvm misconceives NVDIMM pages as reserved mmio
Date: Wed,  4 Jul 2018 23:30:03 +0800
Message-Id: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
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

Zhang Yi (3):
  kvm: remove redundant reserved page check
  mm: introduce memory type MEMORY_DEVICE_DEV_DAX
  kvm: add a function to check if page is from NVDIMM pmem.

 drivers/dax/pmem.c       |  1 +
 include/linux/memremap.h |  1 +
 virt/kvm/kvm_main.c      | 25 +++++++++++++++++--------
 3 files changed, 19 insertions(+), 8 deletions(-)

-- 
2.7.4
