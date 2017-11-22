Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 152286B02CE
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 207so17244563pgc.21
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h6si13930156pll.190.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 52/62] ipc: Remove call to idr_preload
Date: Wed, 22 Nov 2017 13:07:29 -0800
Message-Id: <20171122210739.29916-53-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The ipc code follows a different pattern to most IDR preload users;
the lock that it is holding is embedded in the object, not protecting
the IDR (the IDR is protected by an rwsem).  Instead of dropping the
lock, allocating memory and retrying, we reserve a slot in the tree
before grabbing the lock, then merely replace the NULL entry with the
initialised object.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 ipc/util.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/ipc/util.c b/ipc/util.c
index ff045fec8d83..9a20354ce4fb 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -193,10 +193,10 @@ static struct kern_ipc_perm *ipc_findkey(struct ipc_ids *ids, key_t key)
 /*
  * Specify desired id for next allocated IPC object.
  */
-#define ipc_idr_alloc(ids, new)						\
-	idr_alloc(&(ids)->ipcs_idr, (new),				\
+#define ipc_idr_alloc(ids)						\
+	idr_alloc(&(ids)->ipcs_idr, NULL,				\
 		  (ids)->next_id < 0 ? 0 : ipcid_to_idx((ids)->next_id),\
-		  0, GFP_NOWAIT)
+		  0, GFP_KERNEL)
 
 static inline int ipc_buildid(int id, struct ipc_ids *ids,
 			      struct kern_ipc_perm *new)
@@ -214,8 +214,8 @@ static inline int ipc_buildid(int id, struct ipc_ids *ids,
 }
 
 #else
-#define ipc_idr_alloc(ids, new)					\
-	idr_alloc(&(ids)->ipcs_idr, (new), 0, 0, GFP_NOWAIT)
+#define ipc_idr_alloc(ids)					\
+	idr_alloc(&(ids)->ipcs_idr, NULL, 0, 0, GFP_KERNEL)
 
 static inline int ipc_buildid(int id, struct ipc_ids *ids,
 			      struct kern_ipc_perm *new)
@@ -254,34 +254,30 @@ int ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int limit)
 	if (!ids->tables_initialized || ids->in_use >= limit)
 		return -ENOSPC;
 
-	idr_preload(GFP_KERNEL);
+	id = ipc_idr_alloc(ids);
+	if (id < 0)
+		return id;
 
 	refcount_set(&new->refcount, 1);
 	spin_lock_init(&new->lock);
 	new->deleted = false;
-	rcu_read_lock();
 	spin_lock(&new->lock);
 
 	current_euid_egid(&euid, &egid);
 	new->cuid = new->uid = euid;
 	new->gid = new->cgid = egid;
 
-	id = ipc_idr_alloc(ids, new);
-	idr_preload_end();
+	idr_replace(&ids->ipcs_idr, new, id);
 
-	if (id >= 0 && new->key != IPC_PRIVATE) {
+	if (new->key != IPC_PRIVATE) {
 		err = rhashtable_insert_fast(&ids->key_ht, &new->khtnode,
 					     ipc_kht_params);
 		if (err < 0) {
 			idr_remove(&ids->ipcs_idr, id);
-			id = err;
+			spin_unlock(&new->lock);
+			return err;
 		}
 	}
-	if (id < 0) {
-		spin_unlock(&new->lock);
-		rcu_read_unlock();
-		return id;
-	}
 
 	ids->in_use++;
 	if (id > ids->max_id)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
