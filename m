Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id B0EE36B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 10:05:51 -0400 (EDT)
Received: by qgj62 with SMTP id 62so4651628qgj.2
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:05:51 -0700 (PDT)
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com. [209.85.192.43])
        by mx.google.com with ESMTPS id b69si1125659qkj.86.2015.08.19.07.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 07:05:50 -0700 (PDT)
Received: by qgj62 with SMTP id 62so4651108qgj.2
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:05:50 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH] list_lru: don't call list_lru_from_kmem if the list_head is empty
Date: Wed, 19 Aug 2015 10:05:40 -0400
Message-Id: <1439993140-13362-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If the list_head is empty then we'll have called list_lru_from_kmem
for nothing. Move that call inside of the list_empty if block.

Cc: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 mm/list_lru.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 909eca2c820e..e1da19fac1b3 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -99,8 +99,8 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 	struct list_lru_one *l;
 
 	spin_lock(&nlru->lock);
-	l = list_lru_from_kmem(nlru, item);
 	if (list_empty(item)) {
+		l = list_lru_from_kmem(nlru, item);
 		list_add_tail(item, &l->list);
 		l->nr_items++;
 		spin_unlock(&nlru->lock);
@@ -118,8 +118,8 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 	struct list_lru_one *l;
 
 	spin_lock(&nlru->lock);
-	l = list_lru_from_kmem(nlru, item);
 	if (!list_empty(item)) {
+		l = list_lru_from_kmem(nlru, item);
 		list_del_init(item);
 		l->nr_items--;
 		spin_unlock(&nlru->lock);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
