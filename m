Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A06C6B026D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 02:52:13 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so2561329plo.9
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 23:52:13 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id v18-v6si2803525pff.248.2018.07.03.23.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 23:52:11 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH 3/3] kvm: add a function to check if page is from NVDIMM pmem.
Date: Wed,  4 Jul 2018 23:30:28 +0800
Message-Id: <359fdf0103b61014bf811d88d4ce36bc793d18f2.1530716899.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
References: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
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

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
---
 virt/kvm/kvm_main.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index afb2e6e..1365d18 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -140,10 +140,23 @@ __weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 {
 }
 
+static bool kvm_is_nd_pfn(kvm_pfn_t pfn)
+{
+	struct page *page = pfn_to_page(pfn);
+
+	return is_zone_device_page(page) &&
+		((page->pgmap->type == MEMORY_DEVICE_FS_DAX) ||
+		 (page->pgmap->type == MEMORY_DEVICE_DEV_DAX));
+}
+
 bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
 {
-	if (pfn_valid(pfn))
-		return PageReserved(pfn_to_page(pfn));
+	struct page *page;
+
+	if (pfn_valid(pfn)) {
+		page = pfn_to_page(pfn);
+		return kvm_is_nd_pfn(pfn) ? false : PageReserved(page);
+	}
 
 	return true;
 }
-- 
2.7.4
