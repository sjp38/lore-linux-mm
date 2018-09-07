Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69C516B7DA6
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 05:25:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l65-v6so6926264pge.17
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 02:25:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d11-v6si8006684pgh.564.2018.09.07.02.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 02:25:05 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V5 4/4] kvm: add a check if pfn is from NVDIMM pmem.
Date: Sat,  8 Sep 2018 02:04:08 +0800
Message-Id: <4e8c2e0facd46cfaf4ab79e19c9115958ab6f218.1536342881.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

For device specific memory space, when we move these area of pfn to
memory zone, we will set the page reserved flag at that time, some of
these reserved for device mmio, and some of these are not, such as
NVDIMM pmem.

Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
backend, since these pages are reserved, the check of
kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
to identify these pages are from NVDIMM pmem and let kvm treat these
as normal pages.

Without this patch, many operations will be missed due to this
mistreatment to pmem pages, for example, a page may not have chance to
be unpinned for KVM guest(in kvm_release_pfn_clean), not able to be
marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Acked-by: Pankaj Gupta <pagupta@redhat.com>
---
 virt/kvm/kvm_main.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index c44c406..9c49634 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -147,8 +147,20 @@ __weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 
 bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
 {
-	if (pfn_valid(pfn))
-		return PageReserved(pfn_to_page(pfn));
+	struct page *page;
+
+	if (pfn_valid(pfn)) {
+		page = pfn_to_page(pfn);
+
+		/*
+		 * For device specific memory space, there is a case
+		 * which we need pass MEMORY_DEVICE_FS[DEV]_DAX pages
+		 * to kvm, these pages marked reserved flag as it is a
+		 * zone device memory, we need to identify these pages
+		 * and let kvm treat these as normal pages
+		 */
+		return PageReserved(page) && !is_dax_page(page);
+	}
 
 	return true;
 }
-- 
2.7.4
