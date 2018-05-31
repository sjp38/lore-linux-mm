Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6306B0278
	for <linux-mm@kvack.org>; Thu, 31 May 2018 14:07:02 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so13634588pld.23
        for <linux-mm@kvack.org>; Thu, 31 May 2018 11:07:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h16-v6si10164677pgv.354.2018.05.31.11.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 May 2018 11:07:01 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 13/13] xfs: use iomap for blocksize == PAGE_SIZE readpage and readpages
Date: Thu, 31 May 2018 20:06:14 +0200
Message-Id: <20180531180614.21506-14-hch@lst.de>
In-Reply-To: <20180531180614.21506-1-hch@lst.de>
References: <20180531180614.21506-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

For file systems with a block size that equals the page size we never do
partial reads, so we can use the buffer_head-less iomap versions of
readpage and readpages without conflicting with the buffer_head structures
create later in write_begin.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_aops.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 56e405572909..c631c457b444 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1402,6 +1402,8 @@ xfs_vm_readpage(
 	struct page		*page)
 {
 	trace_xfs_vm_readpage(page->mapping->host, 1);
+	if (i_blocksize(page->mapping->host) == PAGE_SIZE)
+		return iomap_readpage(page, &xfs_iomap_ops);
 	return mpage_readpage(page, xfs_get_blocks);
 }
 
@@ -1413,6 +1415,8 @@ xfs_vm_readpages(
 	unsigned		nr_pages)
 {
 	trace_xfs_vm_readpages(mapping->host, nr_pages);
+	if (i_blocksize(mapping->host) == PAGE_SIZE)
+		return iomap_readpages(mapping, pages, nr_pages, &xfs_iomap_ops);
 	return mpage_readpages(mapping, pages, nr_pages, xfs_get_blocks);
 }
 
-- 
2.17.0
