Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7B396B027E
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:00:13 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id e8-v6so2646870ljg.22
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:00:13 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q5-v6si16548373lji.207.2018.11.12.04.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 04:00:12 -0800 (PST)
From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH v2] mm: cleancache: fix corruption on missed inode invalidation
Date: Mon, 12 Nov 2018 15:00:03 +0300
Message-Id: <20181112120003.23245-1-ptikhomirov@virtuozzo.com>
In-Reply-To: <20181112113153.GC7175@quack2.suse.cz>
References: <20181112113153.GC7175@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Vasily Averin <vvs@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Konstantin Khorenko <khorenko@virtuozzo.com>, Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If all pages are deleted from the mapping by memory reclaim and also
moved to the cleancache:

__delete_from_page_cache
  (no shadow case)
  unaccount_page_cache_page
    cleancache_put_page
  page_cache_delete
    mapping->nrpages -= nr
    (nrpages becomes 0)

We don't clean the cleancache for an inode after final file truncation
(removal).

truncate_inode_pages_final
  check (nrpages || nrexceptional) is false
    no truncate_inode_pages
      no cleancache_invalidate_inode(mapping)

These way when reading the new file created with same inode we may get
these trash leftover pages from cleancache and see wrong data instead of
the contents of the new file.

Fix it by always doing truncate_inode_pages which is already ready for
nrpages == 0 && nrexceptional == 0 case and just invalidates inode.

v2: add comment

Fixes: commit 91b0abe36a7b ("mm + fs: store shadow entries in page cache")
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Reviewed-by: Vasily Averin <vvs@virtuozzo.com>
Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 mm/truncate.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 45d68e90b703..2c5285767ce5 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -517,9 +517,14 @@ void truncate_inode_pages_final(struct address_space *mapping)
 		 */
 		xa_lock_irq(&mapping->i_pages);
 		xa_unlock_irq(&mapping->i_pages);
-
-		truncate_inode_pages(mapping, 0);
 	}
+
+	/*
+	 * Cleancache needs notification even if there are no pages or shadow
+	 * entries, else we will leave leftover pages in the cleancache for
+	 * a deleted inode.
+	 */
+	truncate_inode_pages(mapping, 0);
 }
 EXPORT_SYMBOL(truncate_inode_pages_final);
 
-- 
2.17.1
