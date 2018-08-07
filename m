Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADF736B0274
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:38:13 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i16-v6so14277601wrr.9
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:38:13 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40105.outbound.protection.outlook.com. [40.107.4.105])
        by mx.google.com with ESMTPS id k1-v6si1554722wme.46.2018.08.07.08.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:38:12 -0700 (PDT)
Subject: [PATCH RFC 03/10] mm: Convert shrinker_rwsem to mutex
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:38:00 +0300
Message-ID: <153365628066.19074.11561153370778563231.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

There are no readers, so rwsem is not need anymore.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9dda903a1406..2dc274a385b9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -167,7 +167,7 @@ int vm_swappiness = 60;
 unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_RWSEM(shrinker_rwsem);
+static DEFINE_MUTEX(shrinker_mutex);
 DEFINE_STATIC_SRCU(srcu);
 
 #ifdef CONFIG_MEMCG_KMEM
@@ -192,7 +192,7 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
 {
 	int id, ret = -ENOMEM;
 
-	down_write(&shrinker_rwsem);
+	mutex_lock(&shrinker_mutex);
 	id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
 	if (id < 0)
 		goto unlock;
@@ -208,7 +208,7 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
 	shrinker->id = id;
 	ret = 0;
 unlock:
-	up_write(&shrinker_rwsem);
+	mutex_unlock(&shrinker_mutex);
 	return ret;
 }
 
@@ -218,9 +218,9 @@ static void unregister_memcg_shrinker(struct shrinker *shrinker)
 
 	BUG_ON(id < 0);
 
-	down_write(&shrinker_rwsem);
+	mutex_lock(&shrinker_mutex);
 	idr_remove(&shrinker_idr, id);
-	up_write(&shrinker_rwsem);
+	mutex_unlock(&shrinker_mutex);
 }
 #else /* CONFIG_MEMCG_KMEM */
 static int prealloc_memcg_shrinker(struct shrinker *shrinker)
@@ -405,10 +405,10 @@ void free_prealloced_shrinker(struct shrinker *shrinker)
 
 void register_shrinker_prepared(struct shrinker *shrinker)
 {
-	down_write(&shrinker_rwsem);
+	mutex_lock(&shrinker_mutex);
 	list_add_tail_rcu(&shrinker->list, &shrinker_list);
 	idr_replace(&shrinker_idr, shrinker, shrinker->id);
-	up_write(&shrinker_rwsem);
+	mutex_unlock(&shrinker_mutex);
 }
 
 int register_shrinker(struct shrinker *shrinker)
@@ -431,9 +431,9 @@ void unregister_shrinker(struct shrinker *shrinker)
 		return;
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
 		unregister_memcg_shrinker(shrinker);
-	down_write(&shrinker_rwsem);
+	mutex_lock(&shrinker_mutex);
 	list_del_rcu(&shrinker->list);
-	up_write(&shrinker_rwsem);
+	mutex_unlock(&shrinker_mutex);
 
 	synchronize_srcu(&srcu);
 
