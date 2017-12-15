Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 823566B02FA
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:08:01 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id s1so2218976ybl.5
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:08:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q136si1534062ybq.589.2017.12.15.14.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:38 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 49/78] shmem: Convert shmem_free_swap to XArray
Date: Fri, 15 Dec 2017 14:04:21 -0800
Message-Id: <20171215220450.7899-50-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a perfect use for xa_cmpxchg().  Note the use of 0 for GFP
flags; we won't be allocating memory.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index bd66bbd40499..dd663341e01e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -635,16 +635,13 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 }
 
 /*
- * Remove swap entry from radix tree, free the swap and its page cache.
+ * Remove swap entry from page cache, free the swap and its page cache.
  */
 static int shmem_free_swap(struct address_space *mapping,
 			   pgoff_t index, void *radswap)
 {
-	void *old;
+	void *old = xa_cmpxchg(&mapping->pages, index, radswap, NULL, 0);
 
-	xa_lock_irq(&mapping->pages);
-	old = radix_tree_delete_item(&mapping->pages, index, radswap);
-	xa_unlock_irq(&mapping->pages);
 	if (old != radswap)
 		return -ENOENT;
 	free_swap_and_cache(radix_to_swp_entry(radswap));
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
