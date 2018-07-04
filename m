Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91D1D6B0010
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 17:50:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s3-v6so460767plp.21
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 14:50:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i66-v6si4770331pfb.149.2018.07.04.14.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 14:50:46 -0700 (PDT)
Subject: [PATCH v5 03/11] device-dax: Set page->index
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 14:40:39 -0700
Message-ID: <153074043918.27838.10612469015732111514.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, hch@lst.dehch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.orgjack@suse.cz, ross.zwisler@linux.intel.com

In support of enabling memory_failure() handling for device-dax
mappings, set ->index to the pgoff of the page. The rmap implementation
requires ->index to bound the search through the vma interval tree.

The ->index value is never cleared. There is no possibility for the
page to become associated with another pgoff while the device is
enabled. When the device is disabled the 'struct page' array for the
device is destroyed and ->index is reinitialized to zero.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 95cfcfd612df..361a11089591 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -416,6 +416,7 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 
 	if (rc == VM_FAULT_NOPAGE) {
 		unsigned long i;
+		pgoff_t pgoff;
 
 		/*
 		 * In the device-dax case the only possibility for a
@@ -423,6 +424,8 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 		 * mapped. No need to consider the zero page, or racing
 		 * conflicting mappings.
 		 */
+		pgoff = linear_page_index(vmf->vma, vmf->address
+				& ~(fault_size - 1));
 		for (i = 0; i < fault_size / PAGE_SIZE; i++) {
 			struct page *page;
 
@@ -430,6 +433,7 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 			if (page->mapping)
 				continue;
 			page->mapping = filp->f_mapping;
+			page->index = pgoff + i;
 		}
 	}
 	dax_read_unlock(id);
