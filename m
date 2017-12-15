Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7FA46B0293
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:02 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id 1so7963102ybl.17
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v85si1426546ywc.468.2017.12.15.14.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:01 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 61/78] dax: Convert __dax_invalidate_mapping_entry to XArray
Date: Fri, 15 Dec 2017 14:04:33 -0800
Message-Id: <20171215220450.7899-62-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Simple now that we already have an xa_state!

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 2629ffa70575..d3894c15609a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -413,24 +413,24 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 	XA_STATE(xas, &mapping->pages, index);
 	int ret = 0;
 	void *entry;
-	struct radix_tree_root *pages = &mapping->pages;
 
 	xa_lock_irq(&mapping->pages);
 	entry = get_unlocked_mapping_entry(&xas);
 	if (!entry || WARN_ON_ONCE(!xa_is_value(entry)))
 		goto out;
 	if (!trunc &&
-	    (radix_tree_tag_get(pages, index, PAGECACHE_TAG_DIRTY) ||
-	     radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE)))
+	    (xas_get_tag(&xas, PAGECACHE_TAG_DIRTY) ||
+	     xas_get_tag(&xas, PAGECACHE_TAG_TOWRITE)))
 		goto out;
-	radix_tree_delete(pages, index);
+	xas_store(&xas, NULL);
 	mapping->nrexceptional--;
 	ret = 1;
 out:
 	put_unlocked_mapping_entry(&xas, entry);
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
 	return ret;
 }
+
 /*
  * Delete DAX entry at @index from @mapping.  Wait for it
  * to be unlocked before deleting it.
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
