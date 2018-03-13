Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23BE76B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:58:47 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z3-v6so10128361pln.23
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:58:47 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o6-v6si107996plh.287.2018.03.13.05.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 05:58:46 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] dcache: fix indirectly reclaimable memory accounting
Date: Tue, 13 Mar 2018 12:57:01 +0000
Message-ID: <20180313125701.7955-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

External names can be released using kfree_rcu()
from release_dentry_name_snapshot() and copy_name(),
and it will lead to the imbalance in the indirectly
reclaimable memory accounting.

Fix this by introducing __d_free_external_name() and
call it from all release paths.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 fs/dcache.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 98826efe22a0..9008057a7460 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -266,16 +266,24 @@ static void __d_free(struct rcu_head *head)
 	kmem_cache_free(dentry_cache, dentry); 
 }
 
-static void __d_free_external(struct rcu_head *head)
+static void __d_free_external_name(struct rcu_head *head)
 {
-	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
-	struct external_name *name = external_name(dentry);
+	struct external_name *name = container_of(head, struct external_name,
+						  u.head);
 
 	mod_node_page_state(page_pgdat(virt_to_page(name)),
 			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
 			    -ksize(name));
 
 	kfree(name);
+}
+
+static void __d_free_external(struct rcu_head *head)
+{
+	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
+
+	__d_free_external_name(&external_name(dentry)->u.head);
+
 	kmem_cache_free(dentry_cache, dentry);
 }
 
@@ -307,7 +315,7 @@ void release_dentry_name_snapshot(struct name_snapshot *name)
 		struct external_name *p;
 		p = container_of(name->name, struct external_name, name[0]);
 		if (unlikely(atomic_dec_and_test(&p->u.count)))
-			kfree_rcu(p, u.head);
+			call_rcu(&p->u.head, __d_free_external_name);
 	}
 }
 EXPORT_SYMBOL(release_dentry_name_snapshot);
@@ -2769,7 +2777,7 @@ static void copy_name(struct dentry *dentry, struct dentry *target)
 		dentry->d_name.hash_len = target->d_name.hash_len;
 	}
 	if (old_name && likely(atomic_dec_and_test(&old_name->u.count)))
-		kfree_rcu(old_name, u.head);
+		call_rcu(&old_name->u.head, __d_free_external_name);
 }
 
 static void dentry_lock_for_move(struct dentry *dentry, struct dentry *target)
-- 
2.14.3
