Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E40EC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5E3721850
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:54:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gdI5EkLP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5E3721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 663C16B0008; Wed, 17 Apr 2019 17:54:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612E06B000A; Wed, 17 Apr 2019 17:54:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BA866B000C; Wed, 17 Apr 2019 17:54:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3526B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:54:57 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j18so15147pfi.20
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:54:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=76gfXMG+0uRElSBO/APtur6FtcIZXTee5d1iEwxVGMw=;
        b=o/ZbxTo69x2VVNiCmvp7hGmKKBxQbm8AN6Hai0r+ZpBQcZyZ0xr7JPxqeN/w1YTXRZ
         h48GkuYIJfU42/AWzQKYEjoPTAzXsz93mHsd4XtB+DU/eNv0mDfnildCureMX3QPqr9B
         TB+SOoQag++Tz5QgBrRVlTcub8LiF88NSkB9e0zOouOwmZh5KqJHn8ekByOJKopyL+90
         5hsmWBq3kWpqEnBv6Hp5KU+i0XGR6w0OvUT9yRuiNaN0cKKJAdIFaQnv/xLJa/6XBfrE
         mtNvkI9CMYYhsraS/u9qGHLZrmasdeL+wWeSn12Fy0ulTQNDR4RwL6UbtKUKtKB73q9y
         WMhA==
X-Gm-Message-State: APjAAAXVzqAFC2z3MIXZsw5N0GLd+NKuLI3LonY7FFDkox3SJAiolOyz
	iwvVJB17NnXj7MWaGMwSsQ4nZSxDIOKKKGi11GVQSX7UxpBPwbqZDCkfsZZokd+Kyv/ofth2b9S
	Bx6ypGK1db5Mo5Rhu+d2NxwMcp0U2n5xLthLMcMu7e8s6T7+gCw4Hz+nw1nTlg3c3wQ==
X-Received: by 2002:a17:902:1c1:: with SMTP id b59mr73452708plb.182.1555538096620;
        Wed, 17 Apr 2019 14:54:56 -0700 (PDT)
X-Received: by 2002:a17:902:1c1:: with SMTP id b59mr73452609plb.182.1555538094945;
        Wed, 17 Apr 2019 14:54:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538094; cv=none;
        d=google.com; s=arc-20160816;
        b=BrPTF3Pz0IAnubAx7KmR5gkjLGdO9rnzssGyq2amruA5fgCmHt1zK49TPlYo8EDgmT
         A5/fqhAOIvJeL+7jEpkX4aRRxm+qUZGvty/OuZKsGkpwJW8xSNqcVOgEc5oAok5Pa68f
         Fw6mRHcCpPh8CENL4qrIA4Yc8Y4oFDUQ90PNL5h9HQzgL18zZKcMNFM6m8o5cDV47dwQ
         0KtvO1rZVIMB8K9ODOxrUyBCusSX/mL9CrJJ8DtWX6kdUvzUqnaBFao9s5u68DoAaeaY
         11/x2xF3T8WVXlxL77l+J1kKfo61KWIW97EPx1qGsXS09v8TdYijtjnmEUcknNwfBpbf
         5uZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=76gfXMG+0uRElSBO/APtur6FtcIZXTee5d1iEwxVGMw=;
        b=daCa32W1n58qEv1XcvbaxM/InYcKTOxUIzPOk2li6qo4RdaBUpKO5zZvNhaO3OFTdr
         ckmi5cnfbuIwNkY4xDTCw0Qnh8c6XTMHwMgtPfiSX6DkULe2rjZ1+IAGojm+JxCus5gO
         ZMI9nIZMskxu39VeupuZ4ZKEkZjTT529o0kDlCJ1WFTFaZXsl28Z1+T7vTPqjbXHr85A
         gpXXu5QW0EVqIHwwftkvxk2Xr/yknOBugn9rihnWh4VubtKWwzcL3Xv0oIyl9YX5XKLY
         awfjVQL09NPOubR4IYQThoWbkYCnUQdBGVC0FQKaZUGD1w+CaLqsHE8R176WGhKQfvJl
         eb+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gdI5EkLP;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1sor99658pfc.65.2019.04.17.14.54.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:54:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gdI5EkLP;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=76gfXMG+0uRElSBO/APtur6FtcIZXTee5d1iEwxVGMw=;
        b=gdI5EkLPUs5z6EaRfXGw41UkfBRR+UKMoxX+s1rEhoXw64sOhR8jwzVaL3cG3TWfx5
         o5aPe4KIU6ePKtPU2Uu5fTifU2uklWuSHVSrCpusHW4Ri0HIF5z2uMg1J/cR7CmROP0w
         lb6tUoAsX4j4BS6wtsZ5Qz7ICnhWgHnVqC++hCMJVymGGwketGMErK95ltTSPfj0xEE7
         hHE3k6GXHf4IHciGhiSWFeogsipTbMCm3FzroabyrNDzl1aQG1rN+lh5lO0Onwy5spfT
         R/PejDH+aBhLKbhGoS8FqSORqec0RybvC2TFq3PCOPBGsC6MESABES8Q0QdksuPQbHyT
         h3UA==
X-Google-Smtp-Source: APXvYqx8eaGaLpTxyhmCU99DvbZgOOvhza9jKdm621uZ7OVdDTLFJcxMXop75gq1ZtJxXug7JlIq/A==
X-Received: by 2002:a62:1f92:: with SMTP id l18mr93491326pfj.180.1555538094660;
        Wed, 17 Apr 2019 14:54:54 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5597])
        by smtp.gmail.com with ESMTPSA id x6sm209024pfb.171.2019.04.17.14.54.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 14:54:53 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	david@fromorbit.com,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 1/5] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()
Date: Wed, 17 Apr 2019 14:54:30 -0700
Message-Id: <20190417215434.25897-2-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417215434.25897-1-guro@fb.com>
References: <20190417215434.25897-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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

