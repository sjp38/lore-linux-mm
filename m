Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB18EC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:58:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA41320B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:58:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA41320B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5691A6B0269; Wed, 12 Jun 2019 17:58:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F29C6B026A; Wed, 12 Jun 2019 17:58:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3945C6B026B; Wed, 12 Jun 2019 17:58:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 012456B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:58:11 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so12263166pgh.11
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:58:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=WYt88mczFbUWrzsWgFnx+WWVMyrL7TRO/qmUk0eA2zI=;
        b=WGbgDwrYMWEMzvoxfu1b4WPnD9JmOuAcLbAtHGlvukZVY92V5wgjjzQpUZb2QW6Le3
         zerZ3UEJ/riMw16VNKulr8MfEeC0wHKETEoCVI8NQFl4WabP0Gg6kDEEWDve5zVG2mwk
         Eb7dxTaNIwlJT8f8sTChOhz+p8VKhE/hQZqE+c+nEgrfZZxxXToMYtWWzOa5w9UNzR5S
         4hBSQZJO+AxmsQobpHpNFVjW5WhEwonVwlsk/o/t4y0liarP3bug/Xu94Dlwo2M7lfZ8
         IG9/dn2OJAHuZaKsu+MMBZqMGDx+NEhlUYIL+gEOcSptjzpWe7S8fbQpKoogQf/TZM1h
         cruA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVlI+S4c+8y1RQLiBfAD2UfVs0nZ0gByM3b8HEjh5fwSb264wed
	gizgXBbMw0YkyUqknrzGokWKyuNeugx7cU7kBqaL2NH07hblrkPtpr+dIMvj+gDOuGSHCvjc4d3
	IsX9dQ+BaAiJGPp7MzvDSK2K979PzhBYbLNrN7oJmdmXBdsEJHyUJLvekHy9uUQu3XA==
X-Received: by 2002:a62:ac11:: with SMTP id v17mr26591936pfe.236.1560376690646;
        Wed, 12 Jun 2019 14:58:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeFIpFKSDajOOk5TIMpfeNGQntn8T8l9mL5B1MoGvq2DGqJ4IuoE50Icxt7ANldPZW5Wgt
X-Received: by 2002:a62:ac11:: with SMTP id v17mr26591877pfe.236.1560376689524;
        Wed, 12 Jun 2019 14:58:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560376689; cv=none;
        d=google.com; s=arc-20160816;
        b=bXDs2W/aTDEw2xEMnFiHGlcG5zSmO6pR+A5YotXe3FrmfzRKLnVo755HyAMSK+1khm
         aXA6PVsSoNtlicSoNJdM/eKWZ+azSqR3Talu+niHjaWBKGJl3iKKBKtKRDAT+OpHYmw4
         OwXUziMXVQz3myuuIDEeMgYWTEWXormSk8NYUKPg0N7eTHbsccfOG69ZbjjTDjQiky9W
         J8sjs4gT1mNqQnYFiRwmsqJc8ywoMMZCBI/hlZnekCFp0jf0154cIeb1sQA2Sr2H4TOw
         2Ym3kRp0xrkBt4ynyN8vVFzHYtLoJfwFa1+p8Qm09V0kPVZj4jJisyS8f4TcaP0Bx6Vc
         bVsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=WYt88mczFbUWrzsWgFnx+WWVMyrL7TRO/qmUk0eA2zI=;
        b=oJ/zytpsST4UyzCCJ8nQm/KtnmDGTl+W7Bg/3NJA3Bj8iWUYW575EncsAP2Qoonseu
         b25pr00JngMQkJY606AjCw5W1tZ1PDxTLa7Y8oYthsskizJkOV+QCVbfMtFR4T343/o+
         XhSqepgWwNexLrdtUQQ/G3ccySpcIBYlv3vsth+ZLa4vWohJi6ZOTbGnkBQN0FSqDGC6
         hIxb5nb9VQbKVugJUmWJ0SQR7s8XwusEAeqSZGfbIp1Y3knuvXBlk8tCVb4DCMNwEEhl
         wyUlYrVBMGTy7mDL3NhRA6uWv7XEEb4tEyjka3WZAH0WLxlD/h/E3AdLydUdNws/upDQ
         NxUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id n11si739700plp.361.2019.06.12.14.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 14:58:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TU0Hbt._1560376624;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU0Hbt._1560376624)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 05:57:14 +0800
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
Subject: [v3 PATCH 3/4] mm: shrinker: make shrinker not depend on memcg kmem
Date: Thu, 13 Jun 2019 05:56:48 +0800
Message-Id: <1560376609-113689-4-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
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
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/shrinker.h |  3 +--
 mm/vmscan.c              | 27 ++++++---------------------
 2 files changed, 7 insertions(+), 23 deletions(-)

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

