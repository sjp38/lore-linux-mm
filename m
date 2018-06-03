Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C264A6B000E
	for <linux-mm@kvack.org>; Sun,  3 Jun 2018 01:33:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z1-v6so16934056pfh.3
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 22:33:03 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f3-v6si42922912pld.513.2018.06.02.22.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jun 2018 22:33:02 -0700 (PDT)
Subject: [PATCH v2 04/11] device-dax: Set page->index
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 02 Jun 2018 22:23:05 -0700
Message-ID: <152800338510.17112.13056836346500332623.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

In support of enabling memory_failure() handling for device-dax
mappings, set ->index to the pgoff of the page. The rmap implementation
requires ->index to bound the search through the vma interval tree.

The ->index value is never cleared. There is no possibility for the
page to become associated with another pgoff while the device is
enabled. When the device is disabled the 'struct page' array for the
device is destroyed and ->index is reinitialized to zero.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index f7e926f4ec12..499299e36ee2 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -418,6 +418,7 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 
 	if (rc == VM_FAULT_NOPAGE) {
 		unsigned long i;
+		pgoff_t pgoff;
 
 		/*
 		 * In the device-dax case the only possibility for a
@@ -425,6 +426,8 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 		 * mapped. No need to consider the zero page, or racing
 		 * conflicting mappings.
 		 */
+		pgoff = linear_page_index(vma, vmf->address
+				& ~(fault_size - 1));
 		for (i = 0; i < fault_size / PAGE_SIZE; i++) {
 			struct page *page;
 
@@ -432,6 +435,7 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 			if (page->mapping)
 				continue;
 			page->mapping = filp->f_mapping;
+			page->index = pgoff + i;
 		}
 	}
 	dax_read_unlock(id);
