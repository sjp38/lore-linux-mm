Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78F0A6B0277
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:38:23 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g7-v6so13743587qtp.19
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:38:23 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40104.outbound.protection.outlook.com. [40.107.4.104])
        by mx.google.com with ESMTPS id e64-v6si1530383qkb.255.2018.08.07.08.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:38:22 -0700 (PDT)
Subject: [PATCH RFC 04/10] mm: Split unregister_shrinker()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:38:12 +0300
Message-ID: <153365629257.19074.5257843346605031007.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This and the next patches in this series aim to make
time effect of synchronize_srcu() invisible for user.
The patch splits unregister_shrinker() in two functions:

	unregister_shrinker_delayed_initiate()
	unregister_shrinker_delayed_finalize()

and shrinker users may make the second of them to be called
asynchronous (e.g., from workqueue). Next patches make
superblock shrinker to follow this way, so user-visible
umount() time won't contain delays from synchronize_srcu().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/shrinker.h |    2 ++
 mm/vmscan.c              |   22 ++++++++++++++++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443cafd1969..92062d1239c2 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -86,5 +86,7 @@ extern int prealloc_shrinker(struct shrinker *shrinker);
 extern void register_shrinker_prepared(struct shrinker *shrinker);
 extern int register_shrinker(struct shrinker *shrinker);
 extern void unregister_shrinker(struct shrinker *shrinker);
+extern void unregister_shrinker_delayed_initiate(struct shrinker *shrinker);
+extern void unregister_shrinker_delayed_finalize(struct shrinker *shrinker);
 extern void free_prealloced_shrinker(struct shrinker *shrinker);
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2dc274a385b9..fba4996dfe25 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -422,10 +422,7 @@ int register_shrinker(struct shrinker *shrinker)
 }
 EXPORT_SYMBOL(register_shrinker);
 
-/*
- * Remove one
- */
-void unregister_shrinker(struct shrinker *shrinker)
+void unregister_shrinker_delayed_initiate(struct shrinker *shrinker)
 {
 	if (!shrinker->nr_deferred)
 		return;
@@ -434,12 +431,29 @@ void unregister_shrinker(struct shrinker *shrinker)
 	mutex_lock(&shrinker_mutex);
 	list_del_rcu(&shrinker->list);
 	mutex_unlock(&shrinker_mutex);
+}
+EXPORT_SYMBOL(unregister_shrinker_delayed_initiate);
+
+void unregister_shrinker_delayed_finalize(struct shrinker *shrinker)
+{
+	if (!shrinker->nr_deferred)
+		return;
 
 	synchronize_srcu(&srcu);
 
 	kfree(shrinker->nr_deferred);
 	shrinker->nr_deferred = NULL;
 }
+EXPORT_SYMBOL(unregister_shrinker_delayed_finalize);
+
+/*
+ * Remove one
+ */
+void unregister_shrinker(struct shrinker *shrinker)
+{
+	unregister_shrinker_delayed_initiate(shrinker);
+	unregister_shrinker_delayed_finalize(shrinker);
+}
 EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
