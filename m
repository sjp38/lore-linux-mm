Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 420A76B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 03:12:43 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id w24so6051368plq.11
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 00:12:43 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 6si1486659pgf.474.2018.02.12.00.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 00:12:42 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] mm: Fix races between address_space dereference and free in page_evicatable
Date: Mon, 12 Feb 2018 16:12:27 +0800
Message-Id: <20180212081227.1940-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

From: Huang Ying <ying.huang@intel.com>

When page_mapping() is called and the mapping is dereferenced in
page_evicatable() through shrink_active_list(), it is possible for the
inode to be truncated and the embedded address space to be freed at
the same time.  This may lead to the following race.

CPU1                                                CPU2

truncate(inode)                                     shrink_active_list()
  ...                                                 page_evictable(page)
  truncate_inode_page(mapping, page);
    delete_from_page_cache(page)
      spin_lock_irqsave(&mapping->tree_lock, flags);
        __delete_from_page_cache(page, NULL)
          page_cache_tree_delete(..)
            ...                                         mapping = page_mapping(page);
            page->mapping = NULL;
            ...
      spin_unlock_irqrestore(&mapping->tree_lock, flags);
      page_cache_free_page(mapping, page)
        put_page(page)
          if (put_page_testzero(page)) -> false
- inode now has no pages and can be freed including embedded address_space

                                                        mapping_unevictable(mapping)
							  test_bit(AS_UNEVICTABLE, &mapping->flags);
- we've dereferenced mapping which is potentially already free.

Similar race exists between swap cache freeing and page_evicatable() too.

The address_space in inode and swap cache will be freed after a RCU
grace period.  So the races are fixed via enclosing the page_mapping()
and address_space usage in rcu_read_lock/unlock().  Some comments are
added in code to make it clear what is protected by the RCU read lock.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d1c1e00b08bb..10a0f32a3f90 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3886,7 +3886,13 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
  */
 int page_evictable(struct page *page)
 {
-	return !mapping_unevictable(page_mapping(page)) && !PageMlocked(page);
+	int ret;
+
+	/* Prevent address_space of inode and swap cache from being freed */
+	rcu_read_lock();
+	ret = !mapping_unevictable(page_mapping(page)) && !PageMlocked(page);
+	rcu_read_unlock();
+	return ret;
 }
 
 #ifdef CONFIG_SHMEM
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
