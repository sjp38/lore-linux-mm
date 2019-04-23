Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E81FC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 05:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FE5D218D2
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 05:25:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="fbPk8N3D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FE5D218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A978D6B0005; Wed, 24 Apr 2019 01:25:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1D9D6B0006; Wed, 24 Apr 2019 01:25:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BD5C6B0007; Wed, 24 Apr 2019 01:25:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3E26B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 01:25:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n25so9234562edd.5
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:25:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=76gfXMG+0uRElSBO/APtur6FtcIZXTee5d1iEwxVGMw=;
        b=fnVxplyPRbhFkVVhTMWMs+cStcG7Khuf/EwJW3FQCfTJnN4HFBNpqbo6OiYNUWWlpD
         PtfRyqm+mRlqcYeKLO2yPjqhfrS9H5Iute+OTgAzTpNyIQF7vNx1GsxibIrUwnP0RD0k
         CqJ4WsjvJWM8T1l3TtZ0BTeI3Jw35ayvDz83I90h5nkRp+h8fPZvZx9PlZ4iyx29A7Bz
         tCQvzSgyWaKVU2C6yjmB7DXqd9SjbxWnA5jo8/U2PL1SEHFyAyjmJ9VS/mZgsGKY5MvF
         9yKAykyUsrS5xk8yiykjYcd2+SKKmR3WRq5E0AU7R8k3wlMkEGkqGKrU8zYg4sFk+5kj
         FJqg==
X-Gm-Message-State: APjAAAXCqKeCCO/HttL3AUu3OlpCotUfSuGBxS+br4EjX7T63OC/4Ni+
	6LrPJKEahwDqnLSLSvLkmwaz9vwa9lL69+XSrmLuLsimmPjJ/vhWLBYxo2pGL2puJQIQd2Xs8ur
	phgwhdheD/DYROk+H/uwSGQclvnUcOsbXVP6ga3EHNWUACedbvxkXg0guBLSBPDGU2A==
X-Received: by 2002:a50:ed0a:: with SMTP id j10mr17970631eds.188.1556083502687;
        Tue, 23 Apr 2019 22:25:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd4xJeciem+O3fFWexFUaBIY8kFLIPZEcFobtdMCz7IHmS5eZS46JXwoW6gVAk0hwC6ALe
X-Received: by 2002:a50:ed0a:: with SMTP id j10mr17970599eds.188.1556083501835;
        Tue, 23 Apr 2019 22:25:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556083501; cv=none;
        d=google.com; s=arc-20160816;
        b=L9x1moumQFJOzG7RznqPWUQDQoPLtFehR+TgXGN84T3RuSoLYe79Nob0wth4PuMzXs
         Kt1vIqedaYNcL9LlrjRpVjZPBrZjhqRdjkKPtzhqmVmlG/s8m8jzzxxiAuWDIZqF15U7
         TU8cDuoLMDCejV4dvISODqPE0DtbHVusH494XF2LCv6Rx3HJ4/ovsFZYH1gNfGOqDPMy
         VSybqPG6vzXjogQIsncyTYjglKe4zi9joPKZMCsKKT6cJC6CrbUdETJPikYQUHn9gHYh
         I+jI/lfB48wuojtN8nGSplCCHdH8z69k+e3vXm7ArUM6K1JGjhXK7MM7y2q4ODgF6s6q
         VfSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=76gfXMG+0uRElSBO/APtur6FtcIZXTee5d1iEwxVGMw=;
        b=dzp9NgEKXyVQ27Q7qg5vZ/wbZR3yZEgiS+pqbGu7IisD/nCuAlUxtmq+WOIvnCa/1R
         3vZfXIr7Y+yKqo6UvokZ7GqfRbvb+lO6bdXLTMiewNzgz+xW/fsRlKGDtONv/E1sbc2J
         7YxlJlbO/o4w6mqe/x8CQZ9UbmIR/Gd8JjwAxseVKp1wnDtaw3CPehFAASkLrzJIyPf9
         aAC7PqJvIQ0A9GlDwJjurIgEqUIc1CVqg92rHj76HBbsBg/OlPDoGlT5axh1FpxA1QXc
         wftTqqbeDnF9x8Q1E7B+7EBwCRbZjXTia+c28DXcPeMIbvOQl8xt8L1PPFuz0m+w0s7d
         upGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fbPk8N3D;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l18si1306397ejp.166.2019.04.23.22.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 22:25:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fbPk8N3D;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3O5NIM3024315
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:25:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=76gfXMG+0uRElSBO/APtur6FtcIZXTee5d1iEwxVGMw=;
 b=fbPk8N3Dow+holCAQ3pCf4QAbbqddsS6NPrkcJh5/QiNWaTDi9YD90sMkGICKxU3HUQ7
 Rvyu2D2pzHyc6dLas8EtypUUHuMAoloq4yfc5bcS8GewMfvZxKcwHG1ruQn+fVFu5/Ro
 cuCf3AlXQXLrs9x25vA93N1ythjfbpb4Sxc= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2s2695bb1e-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:25:00 -0700
Received: from mx-out.facebook.com (2620:10d:c0a1:3::13) by
 mail.thefacebook.com (2620:10d:c021:18::171) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 23 Apr 2019 22:24:52 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id BFBD71142D2E0; Tue, 23 Apr 2019 14:31:36 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Shakeel Butt
	<shakeelb@google.com>, Christoph Lameter <cl@linux.com>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v2 1/6] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()
Date: Tue, 23 Apr 2019 14:31:28 -0700
Message-ID: <20190423213133.3551969-2-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190423213133.3551969-1-guro@fb.com>
References: <20190423213133.3551969-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_03:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Initialize kmem_cache->memcg_params.memcg pointer in
memcg_link_cache() rather than in init_memcg_params().

Once kmem_cache will hold a reference to the memory cgroup,
it will simplify the refcounting.

For non-root kmem_caches memcg_link_cache() is always called
before the kmem_cache becomes visible to a user, so it's safe.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/slab.c        |  2 +-
 mm/slab.h        |  5 +++--
 mm/slab_common.c | 14 +++++++-------
 mm/slub.c        |  2 +-
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b1eefe751d2a..57a332f524cf 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1268,7 +1268,7 @@ void __init kmem_cache_init(void)
 				  nr_node_ids * sizeof(struct kmem_cache_node *),
 				  SLAB_HWCACHE_ALIGN, 0, 0);
 	list_add(&kmem_cache->list, &slab_caches);
-	memcg_link_cache(kmem_cache);
+	memcg_link_cache(kmem_cache, NULL);
 	slab_state = PARTIAL;
 
 	/*
diff --git a/mm/slab.h b/mm/slab.h
index 43ac818b8592..6a562ca72bca 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -289,7 +289,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
-extern void memcg_link_cache(struct kmem_cache *s);
+extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 				void (*deact_fn)(struct kmem_cache *));
 
@@ -344,7 +344,8 @@ static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
 
-static inline void memcg_link_cache(struct kmem_cache *s)
+static inline void memcg_link_cache(struct kmem_cache *s,
+				    struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..6e00bdf8618d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -140,13 +140,12 @@ void slab_init_memcg_params(struct kmem_cache *s)
 }
 
 static int init_memcg_params(struct kmem_cache *s,
-		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+			     struct kmem_cache *root_cache)
 {
 	struct memcg_cache_array *arr;
 
 	if (root_cache) {
 		s->memcg_params.root_cache = root_cache;
-		s->memcg_params.memcg = memcg;
 		INIT_LIST_HEAD(&s->memcg_params.children_node);
 		INIT_LIST_HEAD(&s->memcg_params.kmem_caches_node);
 		return 0;
@@ -221,11 +220,12 @@ int memcg_update_all_caches(int num_memcgs)
 	return ret;
 }
 
-void memcg_link_cache(struct kmem_cache *s)
+void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 {
 	if (is_root_cache(s)) {
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
+		s->memcg_params.memcg = memcg;
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
 		list_add(&s->memcg_params.kmem_caches_node,
@@ -244,7 +244,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 }
 #else
 static inline int init_memcg_params(struct kmem_cache *s,
-		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+				    struct kmem_cache *root_cache)
 {
 	return 0;
 }
@@ -384,7 +384,7 @@ static struct kmem_cache *create_cache(const char *name,
 	s->useroffset = useroffset;
 	s->usersize = usersize;
 
-	err = init_memcg_params(s, memcg, root_cache);
+	err = init_memcg_params(s, root_cache);
 	if (err)
 		goto out_free_cache;
 
@@ -394,7 +394,7 @@ static struct kmem_cache *create_cache(const char *name,
 
 	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, memcg);
 out:
 	if (err)
 		return ERR_PTR(err);
@@ -997,7 +997,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 
 	create_boot_cache(s, name, size, flags, useroffset, usersize);
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, NULL);
 	s->refcount = 1;
 	return s;
 }
diff --git a/mm/slub.c b/mm/slub.c
index a34fbe1f6ede..2b9244529d76 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4224,7 +4224,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	}
 	slab_init_memcg_params(s);
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, NULL);
 	return s;
 }
 
-- 
2.20.1

