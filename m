Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 11D8B6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 04:25:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y82-v6so7979243wmb.5
        for <linux-mm@kvack.org>; Tue, 22 May 2018 01:25:50 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o198-v6si11434221wmg.131.2018.05.22.01.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 01:25:49 -0700 (PDT)
Date: Tue, 22 May 2018 10:31:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 16/34] iomap: add initial support for writes without
	buffer heads
Message-ID: <20180522083103.GA10079@lst.de>
References: <20180518164830.1552-1-hch@lst.de> <20180518164830.1552-17-hch@lst.de> <20180521232700.GB14384@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521232700.GB14384@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

The fix should be as simple as this:

diff --git a/fs/iomap.c b/fs/iomap.c
index 357711e50cfa..212c3c21e51c 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -342,19 +342,19 @@ __iomap_write_begin(struct inode *inode, loff_t pos, unsigned len,
 	loff_t block_end = (pos + len + block_size - 1) & ~(block_size - 1);
 	unsigned poff = block_start & (PAGE_SIZE - 1);
 	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, block_end - block_start);
+	unsigned from = pos & (PAGE_SIZE - 1);
+	unsigned to = from + len;
 	int status;
 
 	WARN_ON_ONCE(i_blocksize(inode) < PAGE_SIZE);
 
 	if (PageUptodate(page))
 		return 0;
+	if (poff >= from && poff + len <= to)
+		return 0;
 
 	if (iomap_block_needs_zeroing(inode, block_start, iomap)) {
-		unsigned from = pos & (PAGE_SIZE - 1), to = from + len;
-		unsigned pend = poff + plen;
-
-		if (poff < from || pend > to)
-			zero_user_segments(page, poff, from, to, pend);
+		zero_user_segments(page, poff, from, to, poff + len);
 	} else {
 		status = iomap_read_page_sync(inode, block_start, page,
 				poff, plen, iomap);
