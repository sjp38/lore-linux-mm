Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68A706B02A2
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x25-v6so10303439pfn.21
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l26-v6si24626318pfe.299.2018.06.11.07.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:13 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 64/72] dax: Convert dax_layout_busy_page to XArray
Date: Mon, 11 Jun 2018 07:06:31 -0700
Message-Id: <20180611140639.17215-65-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

Instead of using a pagevec, just use the XArray iterators.  Add a
conditional rescheduling point which probably should have been there in
the original.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 57 +++++++++++++++++++++-----------------------------------
 1 file changed, 21 insertions(+), 36 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 1c9b736147d3..b8ed7bf32ba1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -621,11 +621,10 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
  */
 struct page *dax_layout_busy_page(struct address_space *mapping)
 {
-	pgoff_t	indices[PAGEVEC_SIZE];
+	XA_STATE(xas, &mapping->i_pages, 0);
+	void *entry;
+	unsigned int scanned = 0;
 	struct page *page = NULL;
-	struct pagevec pvec;
-	pgoff_t	index, end;
-	unsigned i;
 
 	/*
 	 * In the 'limited' case get_user_pages() for dax is disabled.
@@ -636,13 +635,9 @@ struct page *dax_layout_busy_page(struct address_space *mapping)
 	if (!dax_mapping(mapping) || !mapping_mapped(mapping))
 		return NULL;
 
-	pagevec_init(&pvec);
-	index = 0;
-	end = -1;
-
 	/*
 	 * If we race get_user_pages_fast() here either we'll see the
-	 * elevated page count in the pagevec_lookup and wait, or
+	 * elevated page count in the iteration and wait, or
 	 * get_user_pages_fast() will see that the page it took a reference
 	 * against is no longer mapped in the page tables and bail to the
 	 * get_user_pages() slow path.  The slow path is protected by
@@ -654,36 +649,26 @@ struct page *dax_layout_busy_page(struct address_space *mapping)
 	 */
 	unmap_mapping_range(mapping, 0, 0, 1);
 
-	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE),
-				indices)) {
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *pvec_ent = pvec.pages[i];
-			void *entry;
-
-			index = indices[i];
-			if (index >= end)
-				break;
-
-			if (!xa_is_value(pvec_ent))
-				continue;
-
-			xa_lock_irq(&mapping->i_pages);
-			entry = get_unlocked_mapping_entry(mapping, index, NULL);
-			if (entry)
-				page = dax_busy_page(entry);
-			put_unlocked_mapping_entry(mapping, index, entry);
-			xa_unlock_irq(&mapping->i_pages);
-			if (page)
-				break;
-		}
-		pagevec_remove_exceptionals(&pvec);
-		pagevec_release(&pvec);
-		index++;
-
+	xas_lock_irq(&xas);
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		if (!xa_is_value(entry))
+			continue;
+		if (unlikely(dax_is_locked(entry)))
+			entry = get_unlocked_entry(&xas);
+		if (entry)
+			page = dax_busy_page(entry);
+		put_unlocked_entry(&xas, entry);
 		if (page)
 			break;
+		if (++scanned % XA_CHECK_SCHED)
+			continue;
+
+		xas_pause(&xas);
+		xas_unlock_irq(&xas);
+		cond_resched();
+		xas_lock_irq(&xas);
 	}
+	xas_unlock_irq(&xas);
 	return page;
 }
 EXPORT_SYMBOL_GPL(dax_layout_busy_page);
-- 
2.17.1
