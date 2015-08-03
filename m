Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7A09003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 08:04:43 -0400 (EDT)
Received: by lbbpo9 with SMTP id po9so2605046lbb.2
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 05:04:42 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q2si11776846laq.102.2015.08.03.05.04.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 05:04:41 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/3] mm: move workingset_activation under lru_lock
Date: Mon, 3 Aug 2015 15:04:21 +0300
Message-ID: <9ddafcd3ee1f09962b7f570c3cf2237afefafba6.1438599199.git.vdavydov@parallels.com>
In-Reply-To: <cover.1438599199.git.vdavydov@parallels.com>
References: <cover.1438599199.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The following patch will move inactive_age from zone to lruvec in order
to make workingset detection logic memcg aware. To achieve that we need
to be able to call mem_cgroup_page_lruvec() from all the workingset
detection related functions. Currently, workingset_eviction() and
workingset_refault() meet this requirement, because both of them are
always called with the page isolated and locked, which prevents the page
from being migrated to another cgroup. However, workingset_activation(),
which is called from mark_page_accessed(), does not. To make this
function safe to call mem_cgroup_page_lruvec(), this patch moves its
invocation to __activate_page() called under the lru_lock.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/swap.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index db43c9b4891d..f3569c8280be 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -514,6 +514,9 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 
 		__count_vm_event(PGACTIVATE);
 		update_page_reclaim_stat(lruvec, file, 1);
+
+		if (file)
+			workingset_activation(page);
 	}
 }
 
@@ -618,8 +621,6 @@ void mark_page_accessed(struct page *page)
 		else
 			__lru_cache_activate_page(page);
 		ClearPageReferenced(page);
-		if (page_is_file_cache(page))
-			workingset_activation(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
