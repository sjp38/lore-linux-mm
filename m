Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 40AA782F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:44 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so39109754igb.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si4630009igg.87.2015.10.29.13.12.35
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:35 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 07/11] mm: add find_get_entries_tag()
Date: Thu, 29 Oct 2015 14:12:11 -0600
Message-Id: <1446149535-16200-8-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Add find_get_entries_tag() to the family of functions that include
find_get_entries(), find_get_pages() and find_get_pages_tag().  This is
needed for DAX dirty page handling because we need a list of both page
offsets and radix tree entries ('indices' and 'entries' in this function)
that are marked with the PAGECACHE_TAG_TOWRITE tag.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/pagemap.h |  3 +++
 mm/filemap.c            | 61 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index a6c78e0..6fea3be 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -354,6 +354,9 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 			       unsigned int nr_pages, struct page **pages);
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages);
+unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
+			int tag, unsigned int nr_entries,
+			struct page **entries, pgoff_t *indices);
 
 struct page *grab_cache_page_write_begin(struct address_space *mapping,
 			pgoff_t index, unsigned flags);
diff --git a/mm/filemap.c b/mm/filemap.c
index c3a9e4f..992cf84 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1454,6 +1454,67 @@ repeat:
 }
 EXPORT_SYMBOL(find_get_pages_tag);
 
+/**
+ * find_get_entries_tag - find and return entries that match @tag
+ * @mapping:	the address_space to search
+ * @start:	the starting page cache index
+ * @tag:	the tag index
+ * @nr_entries:	the maximum number of entries
+ * @entries:	where the resulting entries are placed
+ * @indices:	the cache indices corresponding to the entries in @entries
+ *
+ * Like find_get_entries, except we only return entries which are tagged with
+ * @tag.
+ */
+unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
+			int tag, unsigned int nr_entries,
+			struct page **entries, pgoff_t *indices)
+{
+	void **slot;
+	unsigned int ret = 0;
+	struct radix_tree_iter iter;
+
+	if (!nr_entries)
+		return 0;
+
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_tagged(slot, &mapping->page_tree,
+				   &iter, start, tag) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot(slot);
+		if (unlikely(!page))
+			continue;
+		if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page))
+				goto restart;
+			/*
+			 * A shadow entry of a recently evicted page, a swap
+			 * entry from shmem/tmpfs or a DAX entry.  Return it
+			 * without attempting to raise page count.
+			 */
+			goto export;
+		}
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *slot)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+export:
+		indices[ret] = iter.index;
+		entries[ret] = page;
+		if (++ret == nr_entries)
+			break;
+	}
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL(find_get_entries_tag);
+
 /*
  * CD/DVDs are error prone. When a medium error occurs, the driver may fail
  * a _large_ part of the i/o request. Imagine the worst scenario:
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
