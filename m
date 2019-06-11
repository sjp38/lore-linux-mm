Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA522C31E46
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6515320872
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="UPa7blHQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6515320872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A50CA6B000D; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FF2B6B000E; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C9166B0269; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6896A6B000D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id d19so15427629ywb.2
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=53Eg2QAwVCvd3SsQpm1bINM6H+u/Outwh4WdWfAbIvI=;
        b=k8Fckos3I8BjJrw/xCmEJgzEhPxAxNAk/sDczfNsefKsWn/ptESVA7zUIaAtAexx1G
         RCIbiwyYaVVMd6CwKkstOosML3sntIrFS/sLnPNv6YAfH2dEcxVUqoDVSu1piNwJfPwj
         gTXUQ26sdTBitMFdg67WOiaqFPWICgoecaQNKFTy86fdRY9RYb05GRgnqApTT0WJfSQI
         +/qUgDbJCdkMCkPlweBh9mSFnEnto6Tq6MT9bRFQuEOak7y6P1Vnak6h6+wx0Dj/2UWA
         msdlnwyi98pVcLmj/7atgUUbhSVLHzd5rPMiIdSacX0t9XJRZ7TuFwWLxIqe3u3C69pT
         mLYQ==
X-Gm-Message-State: APjAAAWEi+yGXplFmX1KIKKU97OinjEwiESFvYArfEENJHShsgpZjkK/
	lwf4p/ao7QBlkzoFlkoFMdXQuvdztvFgO/OscPqN6vFqdbfvY7YLNAY4Ln3wD4RvGjymHnZGb/s
	2cdYoi47RQouR8rV/seMtmQrMLZpueN9t0SVFOC+vfxC6gxVeekj9PbSaY4EUd2t20w==
X-Received: by 2002:a81:3dc8:: with SMTP id k191mr40440511ywa.383.1560295104063;
        Tue, 11 Jun 2019 16:18:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvRfr7ROydJp013I9+bpCnb7uMR1+8x+gMvkgXKdwxKjuvDVGizBoBfcm8TxHLpXBi27kL
X-Received: by 2002:a81:3dc8:: with SMTP id k191mr40440484ywa.383.1560295103257;
        Tue, 11 Jun 2019 16:18:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560295103; cv=none;
        d=google.com; s=arc-20160816;
        b=yUzf1TsXsjPA3rt/2J14sgjugMcF736CqKRVjqtCTjGg2sOEz4m/PqATis9SFGgFgp
         KNN9uubhosLUFoOgWE7TYQHA7nm2VfzOb9BcSDqrifP1w097COM/Z6asLQWa7sHCTOQ8
         0I/bv/vSGvNuG17hQM1A8uOtmWCyRJLU72Tgj/h69HkVYlBk48UFu5NNDo2oL7oovgG0
         6cXeoz/OSWq1zcOAuvdDPSYCEZrMp3p3QfDRzL9LszMlpFkpdJwOqA1oUjatuhdd1gha
         5s0oM7FQ2OsevbJt6baIoiXbCmFthJ/qnrLo6aAUGvBlZt9Ls2PW24Fo8uSyHMCMpkH3
         1Ijw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=53Eg2QAwVCvd3SsQpm1bINM6H+u/Outwh4WdWfAbIvI=;
        b=AawbSTZuQq68MDBzk1x62qxkjaZqarfAZ+dmztdfJz5swSskpnM/zjDcWHhwqSmVqx
         UEo1zat0QFjIeagQVgiOt8L9uwwPc/QPufAiJ2EIiIIAJMCzEGfgXhCE2VM5Lm89G6w3
         NPkERSRlkjvdJCHQio9vfHmb4o5Nx0LPX16zDPZUjkCebKvuQEGdFo7YuDolfKrfvWjW
         xLHo2JreHc7XQ3WUeHbvKEJ5Ra4Ft/uBjrUjro1Ri2hExvoQgJRHAqyB2Ld8AE86JKyp
         ShxWG/JE8xu+hJDuKJvlkE92aIdPMMBSJtPJ8H5vb/S4XUhbP1xFk1es64Ekftqxtq1U
         j2gA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UPa7blHQ;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a67si2817635yba.200.2019.06.11.16.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 16:18:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UPa7blHQ;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BNBnCu008431
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=53Eg2QAwVCvd3SsQpm1bINM6H+u/Outwh4WdWfAbIvI=;
 b=UPa7blHQDDpA6oKRYk/eF2XbZhxMHkboJ0hHrxpb/j6G/eimP/p+zoW5df/5GP1Mv68r
 iyn9HKUFmrennZVSLesmK5RSSMNK/TF2YvD5THeLTsShOxvRiaGBplbBKZA9tz9oBzbn
 BWPsH//ZSmIWHPI/YgkSfUAHEoO1vL1EafM= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2t2dkmsy3b-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:22 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 11 Jun 2019 16:18:20 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 2A143130CBF67; Tue, 11 Jun 2019 16:18:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Shakeel Butt
	<shakeelb@google.com>, Waiman Long <longman@redhat.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v7 01/10] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()
Date: Tue, 11 Jun 2019 16:18:04 -0700
Message-ID: <20190611231813.3148843-2-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190611231813.3148843-1-guro@fb.com>
References: <20190611231813.3148843-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-11_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110151
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
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/slab.c        |  2 +-
 mm/slab.h        |  5 +++--
 mm/slab_common.c | 14 +++++++-------
 mm/slub.c        |  2 +-
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9e3eee5568b6..a4091f8b3655 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1239,7 +1239,7 @@ void __init kmem_cache_init(void)
 				  nr_node_ids * sizeof(struct kmem_cache_node *),
 				  SLAB_HWCACHE_ALIGN, 0, 0);
 	list_add(&kmem_cache->list, &slab_caches);
-	memcg_link_cache(kmem_cache);
+	memcg_link_cache(kmem_cache, NULL);
 	slab_state = PARTIAL;
 
 	/*
diff --git a/mm/slab.h b/mm/slab.h
index 739099af6cbb..86f7ede21203 100644
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
index 1802c87799ff..9cb2eef62a37 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4213,7 +4213,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	}
 	slab_init_memcg_params(s);
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, NULL);
 	return s;
 }
 
-- 
2.21.0

