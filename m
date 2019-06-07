Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BE21C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0571208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:08:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0571208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6672C6B0269; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F0F36B026B; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 492056B0271; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBD66B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n19so481557ota.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:08:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=OSZbGRf8RBV4JTgqy0gdidlw7WRQWqllwVVjoDAu5fQ=;
        b=e22Kr1VijA+ybxC9uTwzVv5yUzby/7QvjrmLf3d6IvmTih/WnelxxiJFMSQTZR18JZ
         +a0Ya3txUcBvVTbt2R17sONeqxEwHCtiT3geMIrx2+vUqJBcGdtV+HjZOAsPja0M4FnW
         Gg4686BbmcCG+WBs38Byl9oYopfT6NL/t1jtOtrqG3FBGnwxCIVij2zbHdZKMRi+UHag
         RZB/ET7R8qy1GXqpc/OjvkcIjKsyUWUUL1t9BFQIph8VJsVg5fjMkY9HViJPzPNOls44
         +Nmva9cY6RAAqVH2EcKNdW3q43TtNW4z6RxkR36beWWlKEvo5uJhDGFl9IeCx/4+v7pI
         2xyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUnrBsK6frCt2mAZ6FiI8Q96yyu54X0EbLfhNcLGfHWKyMf5rDL
	PgId1eg/C5rt9p+jUET0f/CDTTrgPbgLYpyx8+uqaXtw2bfXgg2ZoN9gdR/KnlNV460Vv8a6g1R
	4hnoQZkZp9iHEmw5A4I/uFpGVijsKksGkd8sFJVxr1WbxEAgYvQVk/GRdbr9Rl5mzzw==
X-Received: by 2002:a05:6830:1597:: with SMTP id i23mr12288499otr.281.1559887705689;
        Thu, 06 Jun 2019 23:08:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyN1DbOUSfBqBJH5333PHe2mxQIdDmdZsUTCI1QFb5FxJKmA1nIzYX7K3m9oVFryV1jR5WV
X-Received: by 2002:a05:6830:1597:: with SMTP id i23mr12288442otr.281.1559887704411;
        Thu, 06 Jun 2019 23:08:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559887704; cv=none;
        d=google.com; s=arc-20160816;
        b=OOf05wQNh3iwMEsnjfRPjjAx9n9uj/w5pvGqEMzUqjzJkbA3poeN6juLI8v2o4JUjs
         JvxX0Z+dzMdyBRLtBb7h9j1WXJoi+S4FuR+pqviC7WX1zuDTYe13fI39gY/Q54p9M6rg
         9sbpNCyXg+JUStzVaCrKEcQ+Iv7GRUDIDk6DfGDpAhD6fIT1/txrDi1qUOsrqc/AWwQ3
         kknnZnn7mtrfHAoYTfM3th5zPp3vvOt9hJ8EkKqkbY1NzU7htL7A+FZCkQtWtbmmqKa+
         z6f1Fa3WDdJQI7v/F7Vm1g30ISSnV+OxAnvQmie4i0IS7hW1HCfgTffCucNlLvEg1upe
         4fsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=OSZbGRf8RBV4JTgqy0gdidlw7WRQWqllwVVjoDAu5fQ=;
        b=Muhr6PeBq9MPj4+ZJW60c68/sf34EiXVvh/Z2mT0PIplQZuMtaDglj8pFZBat4aHLA
         +khoMYY6zHbkPybQH1b9ZayI2gPV8h8U1bkQ9NGG0p1XUceI/jQ96v8d/1NED0V4sMst
         F3rQktw/4UWQ5jhwfDiGloqBQzA0c1KoNP9zRSUIZjZIjUzgDHk8gmZH11MlAoKnJLVe
         FV+6n+xTG5uNj/Lou8wemafhVgY7qusT3Z1W7uez2zuYbQ5Ekmeisc6E8iVY6m7RBSmw
         4y501/GhupsZERO2ks/4+NnWEP1LSXkATpYhP5fCiD3gcQ/fHrbs3ulTxPvLnqekTshm
         SHKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id k83si796892oia.270.2019.06.06.23.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 23:08:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R751e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TTcZLUN_1559887677;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTcZLUN_1559887677)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 07 Jun 2019 14:08:11 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] mm: shrinker: make shrinker not depend on memcg kmem
Date: Fri,  7 Jun 2019 14:07:39 +0800
Message-Id: <1559887659-23121-5-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently shrinker is just allocated and can work when memcg kmem is
enabled.  But, THP deferred split shrinker is not slab shrinker, it
doesn't make too much sense to have such shrinker depend on memcg kmem.
It should be able to reclaim THP even though memcg kmem is disabled.

Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker,
i.e. THP deferred split shrinker.  When memcg kmem is disabled, just
such shrinkers can be called in shrinking memcg slab.

Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/shrinker.h |  3 +--
 mm/huge_memory.c         |  3 ++-
 mm/vmscan.c              | 27 ++++++---------------------
 3 files changed, 9 insertions(+), 24 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443caf..e14f68e 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -69,10 +69,8 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
-#ifdef CONFIG_MEMCG_KMEM
 	/* ID in shrinker_idr */
 	int id;
-#endif
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
@@ -81,6 +79,7 @@ struct shrinker {
 /* Flags */
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
+#define SHRINKER_NONSLAB	(1 << 2)
 
 extern int prealloc_shrinker(struct shrinker *shrinker);
 extern void register_shrinker_prepared(struct shrinker *shrinker);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 50f4720..e77a9fc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2913,7 +2913,8 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	.count_objects = deferred_split_count,
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
-	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
+	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE |
+		 SHRINKER_NONSLAB,
 };
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7acd0af..62000ae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -174,8 +174,6 @@ struct scan_control {
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
-#ifdef CONFIG_MEMCG_KMEM
-
 /*
  * We allow subsystems to populate their shrinker-related
  * LRU lists before register_shrinker_prepared() is called
@@ -227,16 +225,6 @@ static void unregister_memcg_shrinker(struct shrinker *shrinker)
 	idr_remove(&shrinker_idr, id);
 	up_write(&shrinker_rwsem);
 }
-#else /* CONFIG_MEMCG_KMEM */
-static int prealloc_memcg_shrinker(struct shrinker *shrinker)
-{
-	return 0;
-}
-
-static void unregister_memcg_shrinker(struct shrinker *shrinker)
-{
-}
-#endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
@@ -579,7 +567,6 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	return freed;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
 static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			struct mem_cgroup *memcg, int priority)
 {
@@ -587,7 +574,7 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 	unsigned long ret, freed = 0;
 	int i;
 
-	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
+	if (!mem_cgroup_online(memcg))
 		return 0;
 
 	if (!down_read_trylock(&shrinker_rwsem))
@@ -613,6 +600,11 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
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
@@ -649,13 +641,6 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 	up_read(&shrinker_rwsem);
 	return freed;
 }
-#else /* CONFIG_MEMCG_KMEM */
-static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
-			struct mem_cgroup *memcg, int priority)
-{
-	return 0;
-}
-#endif /* CONFIG_MEMCG_KMEM */
 
 /**
  * shrink_slab - shrink slab caches
-- 
1.8.3.1

