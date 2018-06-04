Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B63DD6B0266
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 19:22:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g15-v6so208683pfh.10
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 16:22:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b70-v6si22422296pga.536.2018.06.04.16.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 16:22:04 -0700 (PDT)
Subject: [PATCH v3 05/12] filesystem-dax: Set page->index
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 04 Jun 2018 16:12:06 -0700
Message-ID: <152815392667.39010.251950144812632482.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.orgjack@suse.cz

In support of enabling memory_failure() handling for filesystem-dax
mappings, set ->index to the pgoff of the page. The rmap implementation
requires ->index to bound the search through the vma interval tree. The
index is set and cleared at dax_associate_entry() and
dax_disassociate_entry() time respectively.

Cc: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index aaec72ded1b6..cccf6cad1a7a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -319,18 +319,27 @@ static unsigned long dax_radix_end_pfn(void *entry)
 	for (pfn = dax_radix_pfn(entry); \
 			pfn < dax_radix_end_pfn(entry); pfn++)
 
-static void dax_associate_entry(void *entry, struct address_space *mapping)
+/*
+ * TODO: for reflink+dax we need a way to associate a single page with
+ * multiple address_space instances at different linear_page_index()
+ * offsets.
+ */
+static void dax_associate_entry(void *entry, struct address_space *mapping,
+		struct vm_area_struct *vma, unsigned long address)
 {
-	unsigned long pfn;
+	unsigned long size = dax_entry_size(entry), pfn, index;
+	int i = 0;
 
 	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
 		return;
 
+	index = linear_page_index(vma, address & ~(size - 1));
 	for_each_mapped_pfn(entry, pfn) {
 		struct page *page = pfn_to_page(pfn);
 
 		WARN_ON_ONCE(page->mapping);
 		page->mapping = mapping;
+		page->index = index + i++;
 	}
 }
 
@@ -348,6 +357,7 @@ static void dax_disassociate_entry(void *entry, struct address_space *mapping,
 		WARN_ON_ONCE(trunc && page_ref_count(page) > 1);
 		WARN_ON_ONCE(page->mapping && page->mapping != mapping);
 		page->mapping = NULL;
+		page->index = 0;
 	}
 }
 
@@ -604,7 +614,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	new_entry = dax_radix_locked_entry(pfn, flags);
 	if (dax_entry_size(entry) != dax_entry_size(new_entry)) {
 		dax_disassociate_entry(entry, mapping, false);
-		dax_associate_entry(new_entry, mapping);
+		dax_associate_entry(new_entry, mapping, vmf->vma, vmf->address);
 	}
 
 	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
