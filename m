Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E033A6B0292
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:00 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id g81so3179741ioa.14
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f26si27280ioj.157.2017.12.15.14.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:00 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 02/78] fscache: Use appropriate radix tree accessors
Date: Fri, 15 Dec 2017 14:03:34 -0800
Message-Id: <20171215220450.7899-3-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Don't open-code accesses to data structure internals.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/fscache/cookie.c | 2 +-
 fs/fscache/object.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index ff84258132bb..e9054e0c1a49 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -608,7 +608,7 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
 	/* Clear pointers back to the netfs */
 	cookie->netfs_data	= NULL;
 	cookie->def		= NULL;
-	BUG_ON(cookie->stores.rnode);
+	BUG_ON(!radix_tree_empty(&cookie->stores));
 
 	if (cookie->parent) {
 		ASSERTCMP(atomic_read(&cookie->parent->usage), >, 0);
diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index 7a182c87f378..aa0e71f02c33 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -956,7 +956,7 @@ static const struct fscache_state *_fscache_invalidate_object(struct fscache_obj
 	 * retire the object instead.
 	 */
 	if (!fscache_use_cookie(object)) {
-		ASSERT(object->cookie->stores.rnode == NULL);
+		ASSERT(radix_tree_empty(&object->cookie->stores));
 		set_bit(FSCACHE_OBJECT_RETIRED, &object->flags);
 		_leave(" [no cookie]");
 		return transit_to(KILL_OBJECT);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
