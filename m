Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE9FB6B0261
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:17:51 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id s10so1746403oth.14
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:17:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l46si613716otb.119.2017.11.29.06.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:17:51 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH] list_lru: Prefetch neighboring list entries before acquiring lock
Date: Wed, 29 Nov 2017 09:17:34 -0500
Message-Id: <1511965054-6328-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Waiman Long <longman@redhat.com>

The list_lru_del() function removes the given item from the LRU list.
The operation looks simple, but it involves writing into the cachelines
of the two neighboring list entries in order to get the deletion done.
That can take a while if the cachelines aren't there yet, thus
prolonging the lock hold time.

To reduce the lock hold time, the cachelines of the two neighboring
list entries are now prefetched before acquiring the list_lru_node's
lock.

Using a multi-threaded test program that created a large number
of dentries and then killed them, the execution time was reduced
from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
72-thread x86-64 system.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/list_lru.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index f141f0c..65aae44 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -132,8 +132,16 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 	struct list_lru_node *nlru = &lru->node[nid];
 	struct list_lru_one *l;
 
+	/*
+	 * Prefetch the neighboring list entries to reduce lock hold time.
+	 */
+	if (unlikely(list_empty(item)))
+		return false;
+	prefetchw(item->prev);
+	prefetchw(item->next);
+
 	spin_lock(&nlru->lock);
-	if (!list_empty(item)) {
+	if (likely(!list_empty(item))) {
 		l = list_lru_from_kmem(nlru, item);
 		list_del_init(item);
 		l->nr_items--;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
