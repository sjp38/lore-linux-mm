Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AEAFC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:31:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CCA021743
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="k9Ah/ffe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CCA021743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 726486B000C; Wed,  8 May 2019 16:30:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AEBD6B000D; Wed,  8 May 2019 16:30:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54EAA6B000E; Wed,  8 May 2019 16:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6A76B000C
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:30:58 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id 11so40147805ywt.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=ncEIzgzKw3O11kTP5Oohay5sLxt9wsLVCWoFPKhHn4M=;
        b=Wx/jRW4eF9mOPXl8Xmzs1yK8fWuoWcr7EPEGj6/Vu0KtL5smYBTX+MibGA/vl0aIrU
         /yhN5GbKU7M4touMBO/6vgVQv4/NExWN8Eik5LzZq4iYTGITMGf45cP2rHgQ1Qx/xp05
         4IuElc34y5qZnztrO0GSeoEb4JpriZyDP/JY/giBZcSxJ1xuGPJV/21X0BrHoB25hYuv
         8OgMuX9tad1JFct8Bx7qdCfOZMdw9Yu5QdXQjApXL3HC9F4QSiWmJNX38bIFRGR1seSE
         mKYl7kdQI+To9KnUTuyWjjGID097QrnsGA8XlMK5BI8wy0AI6w1FoFVR84KYmHFuFDld
         QtHA==
X-Gm-Message-State: APjAAAV+dw9tdYSLfMbG2x+SdI68PbwLo8ZwLJ/toSeJz6CjXGGU6I7o
	MSxILoX250Dolp2nQddQ8e+exr2W0POrxmqzli+BRcVAreR9Ngphzp7dq8TBL2gsZFXpU5QGVSH
	D0eBEPKzwRD80RB4Y9MVdvftKK/yNj5NVUYvGPcz8YYNpTiez3gQw1PSfato/P2CpPQ==
X-Received: by 2002:a25:268f:: with SMTP id m137mr25810921ybm.427.1557347457900;
        Wed, 08 May 2019 13:30:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2DGUXgk6MFLZddRiT5Sd+1LnHV5bSTxH2y/QswIZeolWXLDWw08ebuUFsWveoumnYKJGS
X-Received: by 2002:a25:268f:: with SMTP id m137mr25810879ybm.427.1557347457155;
        Wed, 08 May 2019 13:30:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557347457; cv=none;
        d=google.com; s=arc-20160816;
        b=GiXemcxYzMtejywxkjT1+N4hu5x18XTLBnRQdELu91CqPfycvoGzSb+HsraRylCazq
         lhwbdRa7Kzpi72Db5r0BzV8OTV4xT3porykzyvbx+3htn7on6wRevuuW9ggWt7Rsige6
         bHuCinoYPNGaBUAMuL5LTYSV0HZ4s3xAIjm2zlyUCDW1/xiBy0D1Ngtua/+KWd4L3CXs
         hiG0pEwkZ2vxw7FCjJ0woccHAh2Gj8a559gUVdBO+KOnzfDJodC50T1ZOoMwZfOA/OQe
         bHNDjo7wdOQdcmCLZW8ZzrN2W5Xgeb3iyQ5sHIN9k1FMxg6iyabL7b7m7xIGysBAX+pe
         BCLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=ncEIzgzKw3O11kTP5Oohay5sLxt9wsLVCWoFPKhHn4M=;
        b=oce85ag7Aw1dRIjHivZI0hu247S0ntTI1uTGDBbHixe6890kDz0QydeaOmox10EbKz
         VwPLznDIc+B2f/WSzZ1tWNALGEl25w0o/wKB/XeE8cEKrZn5unHuSD2djznnjf7I9tM0
         goB86wIiCI03zFOQ5hkM68f6R3ap7Pnac7Aee1u4JKU+pIJmtBdHTAMag1PtHBsdZ8Wl
         lbDBv5LQHJ4lQs6FYpDIe4LAai1FF72Rlw/4IriTfHRhsmrclGaK36HP+2hSUmgYx+wL
         7oUkbUtrS9mJYatjIlpIZYt7uhWlsa1Y+RPi7SXE7a+aFUaiRKTKo7WB/gCWl9P5izGP
         UB/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="k9Ah/ffe";
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v18si21659ywv.29.2019.05.08.13.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:30:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="k9Ah/ffe";
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KDoQJ029807
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:30:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=ncEIzgzKw3O11kTP5Oohay5sLxt9wsLVCWoFPKhHn4M=;
 b=k9Ah/ffeMZAPhZxcCiKcPI2JxLGC6QAf+VitJG/8yft11cQy61xAMYXZRzOBR2yjRRxf
 i+oSOhGXZ18+qxkJcfF2cqU4a/CvTzEC98NMy8wcVYMkZZhZqJ8M8jObRlGDJkEuDhnZ
 H9xv3JmO4qkJXDN8EQXQZnE5O41JsGGUtXM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc25590kt-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:56 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 8 May 2019 13:30:49 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 0409111CDBCF2; Wed,  8 May 2019 13:25:00 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Shakeel Butt
	<shakeelb@google.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Christoph Lameter
	<cl@linux.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v3 1/7] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()
Date: Wed, 8 May 2019 13:24:52 -0700
Message-ID: <20190508202458.550808-2-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508202458.550808-1-guro@fb.com>
References: <20190508202458.550808-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080124
X-FB-Internal: deliver
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
index 5b2e364102e1..16f7e4f5a141 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4219,7 +4219,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	}
 	slab_init_memcg_params(s);
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, NULL);
 	return s;
 }
 
-- 
2.20.1

