Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF5686B0010
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 00:59:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k21-v6so2235834pfi.12
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 21:59:50 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z4-v6si23596400pgp.580.2018.07.13.21.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 21:59:49 -0700 (PDT)
Subject: [PATCH v6 04/13] filesystem-dax: Set page->index
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Jul 2018 21:49:50 -0700
Message-ID: <153154379074.34503.9610948190338126460.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In support of enabling memory_failure() handling for filesystem-dax
mappings, set ->index to the pgoff of the page. The rmap implementation
requires ->index to bound the search through the vma interval tree. The
index is set and cleared at dax_associate_entry() and
dax_disassociate_entry() time respectively.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 641192808bb6..4de11ed463ce 100644
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
 
@@ -701,7 +711,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	new_entry = dax_radix_locked_entry(pfn, flags);
 	if (dax_entry_size(entry) != dax_entry_size(new_entry)) {
 		dax_disassociate_entry(entry, mapping, false);
-		dax_associate_entry(new_entry, mapping);
+		dax_associate_entry(new_entry, mapping, vmf->vma, vmf->address);
 	}
 
 	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
