Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD4286B0268
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:03:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i130so28353499pgc.5
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si5598218plt.90.2017.09.27.09.03.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:57 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 15/15] afs: Use find_get_pages_range_tag()
Date: Wed, 27 Sep 2017 18:03:34 +0200
Message-Id: <20170927160334.29513-16-jack@suse.cz>
In-Reply-To: <20170927160334.29513-1-jack@suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org

Use find_get_pages_range_tag() in afs_writepages_region() as we are
interested only in pages from given range. Remove unnecessary code after
this conversion.

CC: David Howells <dhowells@redhat.com>
CC: linux-afs@lists.infradead.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/afs/write.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/afs/write.c b/fs/afs/write.c
index 106e43db1115..d62a6b54152d 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -497,20 +497,13 @@ static int afs_writepages_region(struct address_space *mapping,
 	_enter(",,%lx,%lx,", index, end);
 
 	do {
-		n = find_get_pages_tag(mapping, &index, PAGECACHE_TAG_DIRTY,
-				       1, &page);
+		n = find_get_pages_range_tag(mapping, &index, end,
+					PAGECACHE_TAG_DIRTY, 1, &page);
 		if (!n)
 			break;
 
 		_debug("wback %lx", page->index);
 
-		if (page->index > end) {
-			*_next = index;
-			put_page(page);
-			_leave(" = 0 [%lx]", *_next);
-			return 0;
-		}
-
 		/* at this point we hold neither mapping->tree_lock nor lock on
 		 * the page itself: the page may be truncated or invalidated
 		 * (changing page->mapping to NULL), or even swizzled back from
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
