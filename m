Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id D807B6B0254
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 14:30:18 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so47952198qkc.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 11:30:18 -0700 (PDT)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id b9si4801032qgb.45.2015.09.08.11.30.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Sep 2015 11:30:18 -0700 (PDT)
Received: from /spool/local
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 8 Sep 2015 14:30:17 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C5806C90045
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 14:21:18 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t88IUEHM66322486
	for <linux-mm@kvack.org>; Tue, 8 Sep 2015 18:30:14 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t88IUECN010303
	for <linux-mm@kvack.org>; Tue, 8 Sep 2015 14:30:14 -0400
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH  1/2] mm: Replace nr_node_ids for loop with for_each_node in list lru
Date: Wed,  9 Sep 2015 00:01:46 +0530
Message-Id: <1441737107-23103-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
In-Reply-To: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org
Cc: nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, zhong@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, raghavendra.kt@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The functions used in the patch are in slowpath, which gets called
whenever alloc_super is called during mounts.

Though this should not make difference for the architectures with
sequential numa node ids, for the powerpc which can potentially have
sparse node ids (for e.g., 4 node system having numa ids, 0,1,16,17
is common), this patch saves some unnecessary allocations for
non existing numa nodes.

Even without that saving, perhaps patch makes code more readable.

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 mm/list_lru.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 909eca2..5a97f83 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -377,7 +377,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 {
 	int i;
 
-	for (i = 0; i < nr_node_ids; i++) {
+	for_each_node(i) {
 		if (!memcg_aware)
 			lru->node[i].memcg_lrus = NULL;
 		else if (memcg_init_list_lru_node(&lru->node[i]))
@@ -385,8 +385,11 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 	}
 	return 0;
 fail:
-	for (i = i - 1; i >= 0; i--)
+	for (i = i - 1; i >= 0; i--) {
+		if (!lru->node[i].memcg_lrus)
+			continue;
 		memcg_destroy_list_lru_node(&lru->node[i]);
+	}
 	return -ENOMEM;
 }
 
@@ -397,7 +400,7 @@ static void memcg_destroy_list_lru(struct list_lru *lru)
 	if (!list_lru_memcg_aware(lru))
 		return;
 
-	for (i = 0; i < nr_node_ids; i++)
+	for_each_node(i)
 		memcg_destroy_list_lru_node(&lru->node[i]);
 }
 
@@ -409,16 +412,20 @@ static int memcg_update_list_lru(struct list_lru *lru,
 	if (!list_lru_memcg_aware(lru))
 		return 0;
 
-	for (i = 0; i < nr_node_ids; i++) {
+	for_each_node(i) {
 		if (memcg_update_list_lru_node(&lru->node[i],
 					       old_size, new_size))
 			goto fail;
 	}
 	return 0;
 fail:
-	for (i = i - 1; i >= 0; i--)
+	for (i = i - 1; i >= 0; i--) {
+		if (!lru->node[i].memcg_lrus)
+			continue;
+
 		memcg_cancel_update_list_lru_node(&lru->node[i],
 						  old_size, new_size);
+	}
 	return -ENOMEM;
 }
 
@@ -430,7 +437,7 @@ static void memcg_cancel_update_list_lru(struct list_lru *lru,
 	if (!list_lru_memcg_aware(lru))
 		return;
 
-	for (i = 0; i < nr_node_ids; i++)
+	for_each_node(i)
 		memcg_cancel_update_list_lru_node(&lru->node[i],
 						  old_size, new_size);
 }
@@ -485,7 +492,7 @@ static void memcg_drain_list_lru(struct list_lru *lru,
 	if (!list_lru_memcg_aware(lru))
 		return;
 
-	for (i = 0; i < nr_node_ids; i++)
+	for_each_node(i)
 		memcg_drain_list_lru_node(&lru->node[i], src_idx, dst_idx);
 }
 
@@ -522,7 +529,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 	if (!lru->node)
 		goto out;
 
-	for (i = 0; i < nr_node_ids; i++) {
+	for_each_node(i) {
 		spin_lock_init(&lru->node[i].lock);
 		if (key)
 			lockdep_set_class(&lru->node[i].lock, key);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
