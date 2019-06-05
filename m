Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F35EC28D19
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDE532070D
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="d61Hm7uf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDE532070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E46886B0266; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C381B6B026D; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A14E56B026A; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 630306B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y7so14244397pfy.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=53XDDT3c53a/gFK121iyd3PvVTI7RPL9leWIgYOSFQQ=;
        b=H0HrtCiGqAKlFTl6GAI79MttFRhPvBqRZpITxAjF9f9IQYrRcEMaNATXpqfe6jQ0hp
         5h8QRRjUVAVkwtFo11SGOxiQZRPrPqEcdjQOZcSRtXsieYnlgcIp/xo6jgPmGsOMaDzZ
         BGESzQPO/2WuZBZ9Bc7WDGzDtLiPaFiy7+j8vRnwRflGYPep2+CyvWmsOBEbBk+gZ1/U
         cAHFnYTve2CYwOtoobl7jbrM2z0qeeOmPhhmLjlFZhZOvbb3sBRlqYWVs/h9gMri7uOV
         rG9Kqfkk/ctQT8GPBClk7QrTYddL6vS7uAHYDkMfMBuF9+HLlxhcdzcWdLZm0XVlhI0m
         x2qA==
X-Gm-Message-State: APjAAAXsiXoZpfABwB6TkQKU9UilNA7qnjvZJ55fEi4TIXljX/Wm7Uye
	zLbZEqSjTECkUJBiPze10Xc0O7aWHJz/0RKmsfxJNYvpjWKhGiVVZhRw/k9yUSkLIIozwAAK/pA
	2W4GaoYjuuvQeQCxn+0G/DnLMqUuX2DdhBwU5uXOIJwkRZGE+FdrOkukRrsMJdPfD9Q==
X-Received: by 2002:a17:902:4e:: with SMTP id 72mr41031850pla.80.1559702701796;
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywXLWSxG1IQwNIjHbyTqQAuFffLCx1Kt4zHCz4Dza3mXmdQRyo6+2RbDmo+UNyY2mJEfe6
X-Received: by 2002:a17:902:4e:: with SMTP id 72mr41031796pla.80.1559702700572;
        Tue, 04 Jun 2019 19:45:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702700; cv=none;
        d=google.com; s=arc-20160816;
        b=B0nFidKV4F/5hn384eQ0NyvZZs/TITpqZ6as1ib3Zx4Ou5klozs8lCycPWbCWBl5sh
         ig+qCM27GZJ/yA4ImyT94yP33tDti3Og2Qcq3Ju1JeOYEj1UTSjGxsalQ7KAHTCnxakk
         ehEeEkf8vueR6mIKJjHveSi1qOMfLSFDAS/OzHyXaGaWC3qi7zSlHtSIp6geEj769tdM
         5rEA4eWQaP7T6nu73DVegal6Q8sLE4wEjllnOx5d9SLinmxe4XDw/4jI5ew6Rnh5+yUB
         f2CmP4BSk+HSm8dhtjobMJUHnIwjWnXHc9iq8WXU1Me2BCSx7Pw5QKY8n3t1XuKh/kyN
         ZCgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=53XDDT3c53a/gFK121iyd3PvVTI7RPL9leWIgYOSFQQ=;
        b=B35hjNVWAxexxenpOLXp/wg5Jdb8WBXcWAZ/skQ+jaC/R2/nErgqs9pg2uTSWuGnMd
         WNSfQ8XMrEUDDHdgFJFEnwsW8REYOqbuJEA8Ago+Vig1yxpZ8kEaLpK3o5GWsmgxc4h2
         noroEtLy9DgH9mZtNUxK6WsGguQndxJAQnvD5TkHQrFYHejaxb7U73vNoydp831JN3FJ
         AuTHzw+T6NUQcU9jPEisbt628ORXZJFIaJbIHod4qfpj0PDrTYYmgB4+9/Uk3jyhmaFk
         RmiK2lEYOYm/F9Ze0Z7qVV93LonjRe9HudW1+Ut1HXfQPsqu4ulBI8KggtkhDD5SS5oW
         2jmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d61Hm7uf;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g95si25532010pje.41.2019.06.04.19.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d61Hm7uf;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552iAes001296
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=53XDDT3c53a/gFK121iyd3PvVTI7RPL9leWIgYOSFQQ=;
 b=d61Hm7ufr0aAMhFrupy0vRGQZna0IgnPrswvu9MJSbyokT+710j+Ey5+hyHsLCv4RITQ
 1vnoO0jPWyaKMilPry7ZQvuhlEOsJ7MzeqtWubdb1RecTe/cLJ/08+dfnvwEBSdxJxzy
 5WKIsXeyeQMWhYxhX8IXYs+i5zhhSbsYUlk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2swq1tjy3n-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:44:59 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 4 Jun 2019 19:44:58 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 7B24512C7FDC4; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Shakeel Butt
	<shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v6 02/10] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()
Date: Tue, 4 Jun 2019 19:44:46 -0700
Message-ID: <20190605024454.1393507-3-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190605024454.1393507-1-guro@fb.com>
References: <20190605024454.1393507-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
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
index 1176b61bb8fc..c16e5af0fb59 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -290,7 +290,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
-extern void memcg_link_cache(struct kmem_cache *s);
+extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 				void (*deact_fn)(struct kmem_cache *));
 
@@ -345,7 +345,8 @@ static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
 
-static inline void memcg_link_cache(struct kmem_cache *s)
+static inline void memcg_link_cache(struct kmem_cache *s,
+				    struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8092bdfc05d5..77df6029de8e 100644
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
@@ -998,7 +998,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 
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
2.20.1

