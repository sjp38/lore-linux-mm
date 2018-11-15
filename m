Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B55CD6B0548
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 13:45:04 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id g21-v6so16592591pfg.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 10:45:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x69sor31727195pgx.20.2018.11.15.10.45.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 10:45:03 -0800 (PST)
From: p.jaroszynski@gmail.com
Subject: [PATCH v2] iomap: get/put the page in iomap_page_create/release()
Date: Thu, 15 Nov 2018 10:41:40 -0800
Message-Id: <20181115184140.1388751-1-pjaroszynski@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Piotr Jaroszynski <pjaroszynski@nvidia.com>

From: Piotr Jaroszynski <pjaroszynski@nvidia.com>

migrate_page_move_mapping() expects pages with private data set to have
a page_count elevated by 1. This is what used to happen for xfs through
the buffer_heads code before the switch to iomap in commit 82cb14175e7d
("xfs: add support for sub-pagesize writeback without buffer_heads").
Not having the count elevated causes move_pages() to fail on memory
mapped files coming from xfs.

Make iomap compatible with the migrate_page_move_mapping() assumption
by elevating the page count as part of iomap_page_create() and lowering
it in iomap_page_release().

Fixes: 82cb14175e7d ("xfs: add support for sub-pagesize writeback without buffer_heads")
Signed-off-by: Piotr Jaroszynski <pjaroszynski@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/iomap.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/iomap.c b/fs/iomap.c
index 90c2febc93ac..7c369faea1dc 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -117,6 +117,12 @@ iomap_page_create(struct inode *inode, struct page *page)
 	atomic_set(&iop->read_count, 0);
 	atomic_set(&iop->write_count, 0);
 	bitmap_zero(iop->uptodate, PAGE_SIZE / SECTOR_SIZE);
+
+	/*
+	 * migrate_page_move_mapping() assumes that pages with private data have
+	 * their count elevated by 1.
+	 */
+	get_page(page);
 	set_page_private(page, (unsigned long)iop);
 	SetPagePrivate(page);
 	return iop;
@@ -133,6 +139,7 @@ iomap_page_release(struct page *page)
 	WARN_ON_ONCE(atomic_read(&iop->write_count));
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
+	put_page(page);
 	kfree(iop);
 }
 
-- 
2.11.0.262.g4b0a5b2.dirty
