Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCB396B0346
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:49:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j14so13166825pfn.11
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:49:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v80si14937264pfa.173.2018.05.09.00.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:49:00 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/33] mm: split ->readpages calls to avoid non-contiguous pages lists
Date: Wed,  9 May 2018 09:48:04 +0200
Message-Id: <20180509074830.16196-8-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

That way file systems don't have to go spotting for non-contiguous pages
and work around them.  It also kicks off I/O earlier, allowing it to
finish earlier and reduce latency.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/readahead.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 16d0cb1e2616..3f608e00286d 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -177,8 +177,18 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->i_pages, page_offset);
 		rcu_read_unlock();
-		if (page && !radix_tree_exceptional_entry(page))
+		if (page && !radix_tree_exceptional_entry(page)) {
+			/*
+			 * Page already present?  Kick off the current batch of
+			 * contiguous pages before continueing with the next
+			 * batch.
+			 */
+			if (nr_pages)
+				read_pages(mapping, filp, &page_pool, nr_pages,
+						gfp_mask);
+			nr_pages = 0;
 			continue;
+		}
 
 		page = __page_cache_alloc(gfp_mask);
 		if (!page)
-- 
2.17.0
