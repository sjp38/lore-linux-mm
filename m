Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECA876B000D
	for <linux-mm@kvack.org>; Tue, 22 May 2018 10:50:04 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id a6-v6so12183233pll.22
        for <linux-mm@kvack.org>; Tue, 22 May 2018 07:50:04 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id i15-v6si17066377pfk.146.2018.05.22.07.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 07:50:03 -0700 (PDT)
Subject: [PATCH 06/11] filesystem-dax: perform
 __dax_invalidate_mapping_entry() under the page lock
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 22 May 2018 07:40:03 -0700
Message-ID: <152700000355.24093.14726378287214432782.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, tony.luck@intel.com

Hold the page lock while invalidating mapping entries to prevent races
between rmap using the address_space and the filesystem freeing the
address_space.

This is more complicated than the simple description implies because
dev_pagemap pages that fsdax uses do not have any concept of page size.
Size information is stored in the radix and can only be safely read
while holding the xa_lock. Since lock_page() can not be taken while
holding xa_lock, drop xa_lock and speculatively lock all the associated
pages. Once all the pages are locked re-take the xa_lock and revalidate
that the radix entry did not change.

Cc: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 85 insertions(+), 6 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 2e4682cd7c69..e6d44d336283 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -319,6 +319,13 @@ static unsigned long dax_radix_end_pfn(void *entry)
 	for (pfn = dax_radix_pfn(entry); \
 			pfn < dax_radix_end_pfn(entry); pfn++)
 
+#define for_each_mapped_pfn_reverse(entry, pfn) \
+	for (pfn = dax_radix_end_pfn(entry) - 1; \
+			dax_entry_size(entry) \
+			&& pfn >= dax_radix_pfn(entry); \
+			pfn--)
+
+
 static void dax_associate_entry(void *entry, struct address_space *mapping,
 		struct vm_area_struct *vma, unsigned long address)
 {
@@ -497,6 +504,80 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	return entry;
 }
 
+static bool dax_lock_pages(struct address_space *mapping, pgoff_t index,
+		void **entry)
+{
+	struct radix_tree_root *pages = &mapping->i_pages;
+	unsigned long pfn;
+	void *entry2;
+
+	xa_lock_irq(pages);
+	*entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	if (!*entry || WARN_ON_ONCE(!radix_tree_exceptional_entry(*entry))) {
+		put_unlocked_mapping_entry(mapping, index, entry);
+		xa_unlock_irq(pages);
+		return false;
+	}
+
+	/*
+	 * In the limited case there are no races to prevent with rmap,
+	 * because rmap can not perform pfn_to_page().
+	 */
+	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
+		return true;
+
+	/*
+	 * Now, drop the xa_lock, grab all the page locks then validate
+	 * that the entry has not changed and return with the xa_lock
+	 * held.
+	 */
+	xa_unlock_irq(pages);
+
+	/*
+	 * Retry until the entry stabilizes or someone else invalidates
+	 * the entry;
+	 */
+	for (;;) {
+		for_each_mapped_pfn(*entry, pfn)
+			lock_page(pfn_to_page(pfn));
+
+		xa_lock_irq(pages);
+		entry2 = get_unlocked_mapping_entry(mapping, index, NULL);
+		if (!entry2 || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry2))
+				|| entry2 != *entry) {
+			put_unlocked_mapping_entry(mapping, index, entry2);
+			xa_unlock_irq(pages);
+
+			for_each_mapped_pfn_reverse(*entry, pfn)
+				unlock_page(pfn_to_page(pfn));
+
+			if (!entry2 || !radix_tree_exceptional_entry(entry2))
+				return false;
+			*entry = entry2;
+			continue;
+		}
+		break;
+	}
+
+	return true;
+}
+
+static void dax_unlock_pages(struct address_space *mapping, pgoff_t index,
+		void *entry)
+{
+	struct radix_tree_root *pages = &mapping->i_pages;
+	unsigned long pfn;
+
+	put_unlocked_mapping_entry(mapping, index, entry);
+	xa_unlock_irq(pages);
+
+	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
+		return;
+
+	for_each_mapped_pfn_reverse(entry, pfn)
+		unlock_page(pfn_to_page(pfn));
+}
+
 static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
@@ -504,10 +585,8 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 	void *entry;
 	struct radix_tree_root *pages = &mapping->i_pages;
 
-	xa_lock_irq(pages);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
-	if (!entry || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)))
-		goto out;
+	if (!dax_lock_pages(mapping, index, &entry))
+		return ret;
 	if (!trunc &&
 	    (radix_tree_tag_get(pages, index, PAGECACHE_TAG_DIRTY) ||
 	     radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE)))
@@ -517,8 +596,8 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 	mapping->nrexceptional--;
 	ret = 1;
 out:
-	put_unlocked_mapping_entry(mapping, index, entry);
-	xa_unlock_irq(pages);
+	dax_unlock_pages(mapping, index, entry);
+
 	return ret;
 }
 /*
