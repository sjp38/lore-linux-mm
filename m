Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7E00D9003C8
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 22:53:52 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so32076626pdj.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 19:53:52 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id hu9si17106208pdb.252.2015.07.10.19.53.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 19:53:51 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so61445695pdr.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 19:53:51 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 2/2] mm/shrinker: add init_shrinker() function
Date: Sat, 11 Jul 2015 11:51:55 +0900
Message-Id: <1436583115-6323-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

All zeroes shrinker is now treated as 'initialized, but
not registered'. If, for some reason, you can't zero your
shrinker struct (or don't want to) then use init_shrinker()
function. Otherwise, in some cases, unregister_shrinker()
may Oops.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/shrinker.h |  1 +
 mm/vmscan.c              | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 4fcacd9..bffb660 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -67,6 +67,7 @@ struct shrinker {
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
 
+extern void init_shrinker(struct shrinker *);
 extern int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cadc8a2..4bbcfcf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -221,6 +221,18 @@ static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 }
 
 /*
+ * All-zeroes shrinker considered to be initialized. Use this
+ * function if you can't (don't want to) zero out your shrinker
+ * structure.
+ */
+void init_shrinker(struct shrinker *shrinker)
+{
+	shrinker->nr_deferred = NULL;
+	INIT_LIST_HEAD(&shrinker->list);
+}
+EXPORT_SYMBOL(init_shrinker);
+
+/*
  * Add a shrinker callback to be called from the vm.
  */
 int register_shrinker(struct shrinker *shrinker)
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
