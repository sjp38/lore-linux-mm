Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55213280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 05:25:14 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i83so642231wma.4
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 02:25:14 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id b16si913410ede.175.2018.01.04.02.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 02:25:13 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id ABA211C213C
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 10:25:12 +0000 (GMT)
Date: Thu, 4 Jan 2018 10:25:12 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: Pin address_space before dereferencing it while
 isolating an LRU page
Message-ID: <20180104102512.2qos3h5vqzeisrek@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Jan Kara <jack@suse.cz>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Minchan Kim asked the following question -- what locks protects
address_space destroying when race happens between inode trauncation and
__isolate_lru_page? Jan Kara clarified by describing the race as follows

CPU1                                            CPU2

truncate(inode)                                 __isolate_lru_page()
  ...
  truncate_inode_page(mapping, page);
    delete_from_page_cache(page)
      spin_lock_irqsave(&mapping->tree_lock, flags);
        __delete_from_page_cache(page, NULL)
          page_cache_tree_delete(..)
            ...                                   mapping = page_mapping(page);
            page->mapping = NULL;
            ...
      spin_unlock_irqrestore(&mapping->tree_lock, flags);
      page_cache_free_page(mapping, page)
        put_page(page)
          if (put_page_testzero(page)) -> false
- inode now has no pages and can be freed including embedded address_space

                                                  if (mapping && !mapping->a_ops->migratepage)
- we've dereferenced mapping which is potentially already free.

The race is theoritically possible but unlikely. Before the
delete_from_page_cache, truncate_cleanup_page is called so the page is
likely to be !PageDirty or PageWriteback which gets skipped by the only
caller that checks the mappping in __isolate_lru_page. Even if the race
occurs, a substantial amount of work has to happen during a tiny window
with no preemption but it could potentially be done using a virtual machine
to artifically slow one CPU or halt it during the critical window.

This patch should eliminate the race with truncation by try-locking the page
before derefencing mapping and aborting if the lock was not acquired. There
was a suggestion from Huang Ying to use RCU as a side-effect to prevent
mapping being freed. However, I do not like the solution as it's an
unconventional means of preserving a mapping and it's not a context where
rcu_read_lock is obviously protecting rcu data.

Fixes: c82449352854 ("mm: compaction: make isolate_lru_page() filter-aware again")
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c02c850ea349..61bf0bc60d96 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1433,14 +1433,24 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 
 		if (PageDirty(page)) {
 			struct address_space *mapping;
+			bool migrate_dirty;
 
 			/*
 			 * Only pages without mappings or that have a
 			 * ->migratepage callback are possible to migrate
-			 * without blocking
+			 * without blocking. However, we can be racing with
+			 * truncation so it's necessary to lock the page
+			 * to stabilise the mapping as truncation holds
+			 * the page lock until after the page is removed
+			 * from the page cache.
 			 */
+			if (!trylock_page(page))
+				return ret;
+
 			mapping = page_mapping(page);
-			if (mapping && !mapping->a_ops->migratepage)
+			migrate_dirty = mapping && mapping->a_ops->migratepage;
+			unlock_page(page);
+			if (!migrate_dirty)
 				return ret;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
