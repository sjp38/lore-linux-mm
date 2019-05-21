Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82D6AC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:19:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39D11217F9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:19:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mdTCJovY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39D11217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD7196B0006; Tue, 21 May 2019 16:19:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B875D6B0007; Tue, 21 May 2019 16:19:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A508E6B0008; Tue, 21 May 2019 16:19:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8426B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:19:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b3so48927pgt.12
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:19:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Gl8pp3KYsdZV699fGKd7n8I36sqXFKD3Pr1ctINiCIU=;
        b=td/3B4AouEVoLpMyjT8PDgoosgpW6A9zLVvz/gUth0te+0Whl9xbhG9MDCiW5OzoEQ
         yn2Y4RkpIR2nn89NWpIdHX9Nn1sZM3lgwEMwcZY892rYFrP81Zg2zWXGEYv49hRRXVmD
         GnHwOwf5ic+JLGzOiADpTcEQ2tz/l/lXoiEYHo8XfgBB0mFq9sD6W68HQ8k/JAZCYGG9
         FOZm8dsnJrLhRqbfCiygoODGpYJnw3fqRnpsU6fQzmgSFF1MqX/ZXwmhU3oqRpB4UTGL
         X5GbxHPmswuWwdy55JuNlNGTlXV3rok91xKZWTat7KXGMs0GT5vU0sRFcH1pTLVhkleN
         3kRw==
X-Gm-Message-State: APjAAAW1UR7xqm+ifUByVbVYjgyVQvtcACRlpftxNAMLX2PhS/PaYC9Z
	gQuQ6oZ+JUr6QVkc5JdUZ4jA6SBj/ZH6kuCj4e1BIGOHLrib/pifJY9xRpKAGrbOiPecCx6OVwh
	FiyCWxjepErGnJWvaTeXYMX7wOdqdtIN3G5wRNZITHxs8I8swsDMcHIc+9S/GuB9FRw==
X-Received: by 2002:a17:902:e18d:: with SMTP id cd13mr17846296plb.301.1558469958965;
        Tue, 21 May 2019 13:19:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3MBxDC2YkJ1XSDqaDLAr2fb+mv92epFDWEWpN3ttlbvG0esw6mC3jJO8YNEUkpvN1Ujts
X-Received: by 2002:a17:902:e18d:: with SMTP id cd13mr17846244plb.301.1558469958211;
        Tue, 21 May 2019 13:19:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558469958; cv=none;
        d=google.com; s=arc-20160816;
        b=UtmF8hynVfqXURdTUXG1atxDLvQIBokmYUlJG4NjgFqPIOhPZlOnSI+JkBi91gfyI/
         9zWkQkiUWiD2LV52pq2Al3DTC/SvlGFGCIZm0UjlEYb6QdwSx5e75djpxVIPCw/G8qNR
         xjAy6IUpbGJWJxxv0+o5LKkU2bpqBBykCXZ2PuupK+86QOfQSNfpVeypKNCArWt9ioWi
         nAQb8jRoPum+KY/MbKc/hCUMWXfN7V3PR6DHd3GH9S1sjOhM4iCAouu8572I5eH+ZNAw
         4LZqHSHzv0rjhAOQB2Uf9JWB+HD0E22Icoob7VlONxwm96ZTKwwyzwihOfOMHlx8l2rc
         JUow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Gl8pp3KYsdZV699fGKd7n8I36sqXFKD3Pr1ctINiCIU=;
        b=lqkCeNPGjf9Ax5aQkcYv8EFf+NtgP4d1YxeAfIsNJrNaT4ObMEoknay4Max1uPXKux
         W8p+4ll9Tp5yrbVFfZu7fthcy28KLM1Y6e+7r4k1i/IqDSS+9LUO8/Q257D5L7bTIusG
         VAHm1iUEzVQE+5RAcS9qUX0s+0V6NvEIo/xgFO7vqQCba9WBQuREEIdoDonpp7nh86qB
         EAkgjkxKhRb2kWfvURnCJAqwV/xZ42cAfKKVvyHHi+3KcprlbMFA4cS9+4LOmew32bpO
         /7j09JB0ZMFOuc/jfAU5iy+pN9bc8MmAgdQWDM44BRBSxBMfx+JY29jR1pL5OnEpPx7a
         yvug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mdTCJovY;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l21si22780245pgc.190.2019.05.21.13.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:19:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mdTCJovY;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LKIq3m032264
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:19:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Gl8pp3KYsdZV699fGKd7n8I36sqXFKD3Pr1ctINiCIU=;
 b=mdTCJovYDY8s62vH1SNfYC0cOM+pHXoPII8bODX/C8DtB2YTVnWgJlyd5giamFTvuNJ7
 cq3TjfATua+VjkXWpQkBPQXT2AmynX5+8btcc9igt9sPjC9BcoHnnd+K8q857rub/yVY
 eYQ3tCJB5DCkeFWW+1CeYCImw/DSi8IAReU= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2smhav1qa6-13
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:19:17 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 21 May 2019 13:18:47 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 0071E1245FFA1; Tue, 21 May 2019 13:07:49 -0700 (PDT)
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
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v5 1/7] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()
Date: Tue, 21 May 2019 13:07:29 -0700
Message-ID: <20190521200735.2603003-2-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190521200735.2603003-1-guro@fb.com>
References: <20190521200735.2603003-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_05:,,
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
Reviewed-by: Shakeel Butt <shakeelb@google.com>
---
 mm/slab.c        |  2 +-
 mm/slab.h        |  5 +++--
 mm/slab_common.c | 14 +++++++-------
 mm/slub.c        |  2 +-
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2915d912e89a..f6eff59e018e 100644
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
index cd04dbd2b5d0..c5646cb02055 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4215,7 +4215,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	}
 	slab_init_memcg_params(s);
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, NULL);
 	return s;
 }
 
-- 
2.20.1

