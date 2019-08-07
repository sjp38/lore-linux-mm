Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A4FCC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:19:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEC0D21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:19:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEC0D21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74AAF6B027E; Tue,  6 Aug 2019 22:19:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FB616B0282; Tue,  6 Aug 2019 22:19:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EB406B0286; Tue,  6 Aug 2019 22:19:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 251906B0282
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 22:19:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y9so49484168plp.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 19:19:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6dehf2KMRb7fhLYD72e0CQZ8EMzXR74e7VbIq3OK2SA=;
        b=jBdoYc+qgl081gpaQVEQWO7PftiL/EQ/l5VvI3QVIzJMHj2JdBTHm9sB8M2nA2rlF4
         NFjY+/1evdc/9CJxXwjCtEEAi2jiBk02UwR00QmSXFnogEW+RkqcNVnZcxU03GDXY1UJ
         8Rku4WPa1tl3xjEIYijYYrxyuOaka+aNggBrpELMRON5ILjuhr3fW8kPznPqKAF83F/6
         FUXvyhXtOksrw34bV8WsRpOwbKF4Gk61ttHF6MpMaQiTSpq9BJhXyC3rs+PDVp1pMQfc
         9WZVpAXbIe834BtThtpkwVBbEPVor2PwPF4wzvv4S9W0ycDu0D2xP6LWQZ/sKZhsCogJ
         3msw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVaxtZmr+UXz/AE/jCyE42sKPSMxwUTsDiSRkvLuciitA0/gmdO
	DWq7YcBylCL1f/zYlxAqoqFXRF6FPLPqopLHReaZKrY63YKYzw/cOV1OgN/Bw7IHs1qt4d2aa3a
	nrVnedcMfGG9vlROWBgxeShvoJzKpNLU6iY75IPv8SL29fDWErhXqh/pXZ6aqkH6/gg==
X-Received: by 2002:aa7:8218:: with SMTP id k24mr6618570pfi.221.1565144364792;
        Tue, 06 Aug 2019 19:19:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+b55mnve/6Xb5IxYFJaJa+4IaAjGlO4crIutgUBwFl3eBzICmlHLGqpn3bJvBTvZbSmis
X-Received: by 2002:aa7:8218:: with SMTP id k24mr6618504pfi.221.1565144363480;
        Tue, 06 Aug 2019 19:19:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565144363; cv=none;
        d=google.com; s=arc-20160816;
        b=VGnMHVSVYFNEKC+4/NLApKERtMD9V/YQFkX9tG8sdJY1y1SUtENA4TsHFf7P2uG+g8
         artW9qMtejtWt7LgIlrAtelZ4tzKRpRd9lr7Y00rQSJYfsRVIB6FnTQh/tzVsQTWCDpt
         88zKz2cNIoIGpDfemcXhXZpPfFveNxXFC1THf7ANLTypsTw+Vu3/qj16mwYnDFL9RQEz
         2OAvq88zBHmNHpVojVVQGNA/T64jVMphtmMuyjbcub3pBzVYXKur6Erm7fN+/jiTBveb
         /URr92bAlqxYYVXyjIIetyMAIzx5qTlz8g5v05fVrdyZtjQP/GScXQDx0orG7UOcqqLH
         gIfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6dehf2KMRb7fhLYD72e0CQZ8EMzXR74e7VbIq3OK2SA=;
        b=OlRN3m9Rn/Fs4NZYc/LbxzjE+Wwc9UF99rcDt/HMsO5fAdL8T4uGBh3NDvNA9X1Ni6
         a1haoZZjyxwymGC9hsDHouTGgoW0FQbyEHbRT9KSGX8cy2gac4awvBmKtChixlRqZl6c
         7ATWw7+TOjduKslpic+FgnWXl8w2o1k/TBZB/5TvIEk710zNfDdLJ8YYvjOY15whfSaL
         ePl6CLPM8d8d+bHof4zsi9O/UwlocRGtAI1suCJ1GXaqnQooJ+Q1uo+vk5o6MxZVyjEi
         qdGw85TtKCdmwVRKRiFk+LgB1ZG6NILDEca7xr7ZhUEzH5tgrZxulqCzC95+QW2ekSuU
         i62g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id x7si534312pfi.257.2019.08.06.19.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 19:19:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TYr3obk_1565144286;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TYr3obk_1565144286)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 07 Aug 2019 10:18:13 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	cai@lca.pw,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v5 PATCH 3/4] mm: shrinker: make shrinker not depend on memcg kmem
Date: Wed,  7 Aug 2019 10:17:56 +0800
Message-Id: <1565144277-36240-4-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently shrinker is just allocated and can work when memcg kmem is
enabled.  But, THP deferred split shrinker is not slab shrinker, it
doesn't make too much sense to have such shrinker depend on memcg kmem.
It should be able to reclaim THP even though memcg kmem is disabled.

Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker.
When memcg kmem is disabled, just such shrinkers can be called in
shrinking memcg slab.

Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Qian Cai <cai@lca.pw>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/memcontrol.h | 19 ++++++++-------
 include/linux/shrinker.h   |  3 ++-
 mm/memcontrol.c            |  9 +------
 mm/vmscan.c                | 60 ++++++++++++++++++++++++----------------------
 4 files changed, 45 insertions(+), 46 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44c4146..5771816 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -128,9 +128,8 @@ struct mem_cgroup_per_node {
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
 
-#ifdef CONFIG_MEMCG_KMEM
 	struct memcg_shrinker_map __rcu	*shrinker_map;
-#endif
+
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long		usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
@@ -1253,6 +1252,11 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 	} while ((memcg = parent_mem_cgroup(memcg)));
 	return false;
 }
+
+extern int memcg_expand_shrinker_maps(int new_id);
+
+extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
+				   int nid, int shrinker_id);
 #else
 #define mem_cgroup_sockets_enabled 0
 static inline void mem_cgroup_sk_alloc(struct sock *sk) { };
@@ -1261,6 +1265,11 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 	return false;
 }
+
+static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
+					  int nid, int shrinker_id)
+{
+}
 #endif
 
 struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
@@ -1332,10 +1341,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
-extern int memcg_expand_shrinker_maps(int new_id);
-
-extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
-				   int nid, int shrinker_id);
 #else
 
 static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
@@ -1377,8 +1382,6 @@ static inline void memcg_put_cache_ids(void)
 {
 }
 
-static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
-					  int nid, int shrinker_id) { }
 #endif /* CONFIG_MEMCG_KMEM */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443caf..9e112d6 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -69,7 +69,7 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	/* ID in shrinker_idr */
 	int id;
 #endif
@@ -81,6 +81,7 @@ struct shrinker {
 /* Flags */
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
+#define SHRINKER_NONSLAB	(1 << 2)
 
 extern int prealloc_shrinker(struct shrinker *shrinker);
 extern void register_shrinker_prepared(struct shrinker *shrinker);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a8..d90ded1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -313,6 +313,7 @@ void memcg_put_cache_ids(void)
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 struct workqueue_struct *memcg_kmem_cache_wq;
+#endif
 
 static int memcg_shrinker_map_size;
 static DEFINE_MUTEX(memcg_shrinker_map_mutex);
@@ -436,14 +437,6 @@ void memcg_set_shrinker_bit(struct mem_cgroup *memcg, int nid, int shrinker_id)
 	}
 }
 
-#else /* CONFIG_MEMCG_KMEM */
-static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
-{
-	return 0;
-}
-static void memcg_free_shrinker_maps(struct mem_cgroup *memcg) { }
-#endif /* CONFIG_MEMCG_KMEM */
-
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b1b5e5f..093b76d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -174,11 +174,22 @@ struct scan_control {
  */
 unsigned long vm_total_pages;
 
+static void set_task_reclaim_state(struct task_struct *task,
+				   struct reclaim_state *rs)
+{
+	/* Check for an overwrite */
+	WARN_ON_ONCE(rs && task->reclaim_state);
+
+	/* Check for the nulling of an already-nulled member */
+	WARN_ON_ONCE(!rs && !task->reclaim_state);
+
+	task->reclaim_state = rs;
+}
+
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
-#ifdef CONFIG_MEMCG_KMEM
-
+#ifdef CONFIG_MEMCG
 /*
  * We allow subsystems to populate their shrinker-related
  * LRU lists before register_shrinker_prepared() is called
@@ -230,30 +241,7 @@ static void unregister_memcg_shrinker(struct shrinker *shrinker)
 	idr_remove(&shrinker_idr, id);
 	up_write(&shrinker_rwsem);
 }
-#else /* CONFIG_MEMCG_KMEM */
-static int prealloc_memcg_shrinker(struct shrinker *shrinker)
-{
-	return 0;
-}
 
-static void unregister_memcg_shrinker(struct shrinker *shrinker)
-{
-}
-#endif /* CONFIG_MEMCG_KMEM */
-
-static void set_task_reclaim_state(struct task_struct *task,
-				   struct reclaim_state *rs)
-{
-	/* Check for an overwrite */
-	WARN_ON_ONCE(rs && task->reclaim_state);
-
-	/* Check for the nulling of an already-nulled member */
-	WARN_ON_ONCE(!rs && !task->reclaim_state);
-
-	task->reclaim_state = rs;
-}
-
-#ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup;
@@ -308,6 +296,15 @@ static bool memcg_congested(pg_data_t *pgdat,
 
 }
 #else
+static int prealloc_memcg_shrinker(struct shrinker *shrinker)
+{
+	return 0;
+}
+
+static void unregister_memcg_shrinker(struct shrinker *shrinker)
+{
+}
+
 static bool global_reclaim(struct scan_control *sc)
 {
 	return true;
@@ -594,7 +591,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	return freed;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			struct mem_cgroup *memcg, int priority)
 {
@@ -602,7 +599,7 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 	unsigned long ret, freed = 0;
 	int i;
 
-	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
+	if (!mem_cgroup_online(memcg))
 		return 0;
 
 	if (!down_read_trylock(&shrinker_rwsem))
@@ -628,6 +625,11 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			continue;
 		}
 
+		/* Call non-slab shrinkers even though kmem is disabled */
+		if (!memcg_kmem_enabled() &&
+		    !(shrinker->flags & SHRINKER_NONSLAB))
+			continue;
+
 		ret = do_shrink_slab(&sc, shrinker, priority);
 		if (ret == SHRINK_EMPTY) {
 			clear_bit(i, map->map);
@@ -664,13 +666,13 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 	up_read(&shrinker_rwsem);
 	return freed;
 }
-#else /* CONFIG_MEMCG_KMEM */
+#else /* CONFIG_MEMCG */
 static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			struct mem_cgroup *memcg, int priority)
 {
 	return 0;
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 /**
  * shrink_slab - shrink slab caches
-- 
1.8.3.1

