Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 824A16B0037
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 04:35:20 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 4/5] readahead: remove end range check
Date: Wed,  3 Jul 2013 17:34:19 +0900
Message-Id: <1372840460-5571-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/readahead.c b/mm/readahead.c
index daed28d..3932f28 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -166,6 +166,8 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		goto out;
 
 	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+	if (offset + nr_to_read > end_index + 1)
+		nr_to_read = end_index - offset + 1;
 
 	/*
 	 * Preallocate as many pages as we will need.
@@ -173,9 +175,6 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
 
-		if (page_offset > end_index)
-			break;
-
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		rcu_read_unlock();
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
