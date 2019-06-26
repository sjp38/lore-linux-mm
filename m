Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3DBFC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:04:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6113A20883
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:04:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6113A20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12A636B0003; Tue, 25 Jun 2019 20:04:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DC608E0003; Tue, 25 Jun 2019 20:04:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33638E0002; Tue, 25 Jun 2019 20:04:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEF186B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:04:10 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id m16so186127otq.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:04:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=PV8bMP2UMNlkx7OeCEesXi507zEmJNhr1YhzchIxGFw=;
        b=VMcl9yOUwimfyyp1xOlNvatRARN9RV3uuCXNBJ0Ys+IAZCGEk/h7TBqIlT8JwSiqmQ
         LZoBbGHjFXkG+LNb1Ih0TqCHRwpMxjKZ4cewr47GfOFC3Gl+SsCzbFZh8+h8WH867g0J
         BZPFkux0b0V9D3mijbx0CfKGVDNQvmAwG8b7fg00D/cp8xqbe5W15shWUEY0Twnq93ZH
         cRVQcwWBktVo/4dvd3r5R5cTdxspTYSeC7T2RFjihsDONiOxFRVcdiweaXaIwRpWCOoe
         pO2e8T7disrvyeMY8OQ2Bg/LxEXaKFs81oS0wMtKgH+BWB45F/+5gU+FqDWYXgStKiC/
         VSzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW3a7OkZkFhmsUT45tfJwXWu9nrDzPo9tHJjBEwWc6y8DmN+HaF
	hMewP717WQJesXKRXl9xtG7HQZINt04QcKFiDIwfI57RikbyDV0jM7jslQB3ckLW6ymd7CGnXDT
	igEXy1IkX3BVaxy1GgAFYzCXf8wjdSDwJB3rio1YPbvps/Y0UQj1v9+zOj9b9U9fARA==
X-Received: by 2002:a9d:6d06:: with SMTP id o6mr903790otp.225.1561507450605;
        Tue, 25 Jun 2019 17:04:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzR56wkTtXaqlEom5859xW2kOwvna338GM1DBXOUn9wPbz66SYChGqLPVXUqxIKmcs6dUZG
X-Received: by 2002:a9d:6d06:: with SMTP id o6mr903621otp.225.1561507448071;
        Tue, 25 Jun 2019 17:04:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561507448; cv=none;
        d=google.com; s=arc-20160816;
        b=e87tc4+x9cU1umFmds0AkHoP0G24NEDb/JFz8KXa37A54pGmmdRC0SF8Wb1lg1ld/P
         ukuY9CWpc9bOlpOZVszXwFav5XjVNbP1rafCYFh+vrDfmMSyilSmAmE4tX/3S8oV0xYd
         FPKsk0YFI/3fCr3XdhXVRsdTijWFX1yC4xWUkxfOnIukSY1Zk/ujEjpXqieOmkrBJSS5
         e7MK/fVhB3M4uJ8pcFhEfVJe9vy9TxElfEAMiu2qx61WgBAHZKUw9CMuQc5svs2BVeJo
         jSOv//xFs9tiboblitBfhWJNj6iM8nXq+kC06CsphFTT+y4NRj2WEg2/mXJZqRX5ljSz
         YKxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=PV8bMP2UMNlkx7OeCEesXi507zEmJNhr1YhzchIxGFw=;
        b=IJj0ES2tLu3Febf6w1KD2lnSqsbCv/SOPgVMN/HydRNSZRGpzbXMFkuWnxa5N7Wn8T
         eEAPp2IcV993VhUtHbU98ZYjXJ+2phKVrjy4kstQiCSnZ5T+bq4DVtb9tlNFJWjckqNb
         J+RGd9WmY1nS3M84hrRmFXKUGYTE4NvyLbIB+z/fDf+mGfGIS8n4i3PNLW+xmTzqSFmP
         3Nf8//tOpVZxZlnkgExyLQs0wSrMXivaHSSAK3glcyNtm1oBkpKlVy1L4BTQ1sSSeZlR
         LOP57GA7KgHOSF4zieWTOXvgTy0rSzsGglq2lIEaNEznlwtJ2u9Rov/cSOXyNps3U9aR
         V9Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id i20si8385870otr.202.2019.06.25.17.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 17:04:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVCYVJX_1561507375;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVCYVJX_1561507375)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 26 Jun 2019 08:03:03 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v4 PATCH 3/4] mm: shrinker: make shrinker not depend on memcg kmem
Date: Wed, 26 Jun 2019 08:02:40 +0800
Message-Id: <1561507361-59349-4-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
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
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/shrinker.h |  3 ++-
 mm/vmscan.c              | 36 +++++++++++++++++++-----------------
 2 files changed, 21 insertions(+), 18 deletions(-)

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
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7889f58..187cacb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -174,8 +174,7 @@ struct scan_control {
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
-#ifdef CONFIG_MEMCG_KMEM
-
+#ifdef CONFIG_MEMCG
 /*
  * We allow subsystems to populate their shrinker-related
  * LRU lists before register_shrinker_prepared() is called
@@ -227,18 +226,7 @@ static void unregister_memcg_shrinker(struct shrinker *shrinker)
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
-#ifdef CONFIG_MEMCG
 static bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup;
@@ -293,6 +281,15 @@ static bool memcg_congested(pg_data_t *pgdat,
 
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
@@ -579,7 +576,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	return freed;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			struct mem_cgroup *memcg, int priority)
 {
@@ -587,7 +584,7 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 	unsigned long ret, freed = 0;
 	int i;
 
-	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
+	if (!mem_cgroup_online(memcg))
 		return 0;
 
 	if (!down_read_trylock(&shrinker_rwsem))
@@ -613,6 +610,11 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
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
@@ -649,13 +651,13 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
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

