Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id F17ED6B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:07:12 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id p4so3452001oti.15
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:07:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e59si1452345ote.482.2017.11.30.06.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 06:07:11 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2] list_lru: Prefetch neighboring list entries before acquiring lock
Date: Thu, 30 Nov 2017 09:06:54 -0500
Message-Id: <1512050814-6374-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Waiman Long <longman@redhat.com>

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
 v1->v2: Include prefetch.h to prevent build error in other archs.

 mm/list_lru.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index f141f0c..981fca6 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -11,6 +11,7 @@
 #include <linux/slab.h>
 #include <linux/mutex.h>
 #include <linux/memcontrol.h>
+#include <linux/prefetch.h>
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 static LIST_HEAD(list_lrus);
@@ -132,8 +133,16 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
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
