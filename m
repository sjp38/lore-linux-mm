Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6176EC28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B60920851
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dWZpvwBN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B60920851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 905626B0274; Tue,  4 Jun 2019 22:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B88A6B0276; Tue,  4 Jun 2019 22:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E6EC6B0278; Tue,  4 Jun 2019 22:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 297F26B0276
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y187so5758560pgd.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=n7BlWccP5e9E4x6aVqJtrHQl4d1EpfzcQz8Ne0PToZU=;
        b=hviQcPf1f8hdHk3Lwl0SLQrgA5eFVhcjDOqozsqesLUjPRjnhMMNpIfyWv+QQPTUPg
         SK6N/KoFXN+fEu/pECtcQgp9yWfecewIuBiLDd08q+mgS/6P2NPoSTsXLlTMT5hhWKs4
         s0NSDQ7zlwfcpLHZg7oXr+Q7BjSksXSmhhPQH3q5EE/SqXhbzRNkVgKsUmTQajIPIsKe
         sTDPGW11Ogen3SZ6WRPkFUbGQsmXE5q9azJ+aLEwZFsyYhTbn0mqKZBXT3oT0U5MKp20
         4uZgPD94LkSlVvd32uBVB/8yaEEaJZfCoZEA8atosgz6Bb1x1wAwNMuL3J8udygnTHWq
         v3Eg==
X-Gm-Message-State: APjAAAUjWvZE4W86GIBnM7EtL9BQ6QOKvunf4eLWiqCVcjbWyWT0gzPg
	oHqAWVBEl9xnypatsQ7zSlxuwtnqeN/E3+azhXD+jixuZRun24hezlWkaOZwnCKkxChvKhmd7hh
	XhOTNo5sWPeS+fASrGhFe/3lxr/5dgoWeifDe1jz5EimtyeQNeYy3iO00UKA0bQv8Mg==
X-Received: by 2002:a17:90a:b78b:: with SMTP id m11mr41027743pjr.106.1559702705655;
        Tue, 04 Jun 2019 19:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEy+juNHCN4laE4+nhy0qaddeKfNYCcdyzv5yKAAHcBW4tCMpf7PM+CEyjEmsC/eZ10iSK
X-Received: by 2002:a17:90a:b78b:: with SMTP id m11mr41027683pjr.106.1559702704558;
        Tue, 04 Jun 2019 19:45:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702704; cv=none;
        d=google.com; s=arc-20160816;
        b=wt0y+BwYgz7ZpaqQEWpG9El3ExbLLerlkfib8qREASVeJur1OuuarQNn/TI/fNoJI/
         fU6jaF9IgkqQsR0VsZsUJ9dHDlpOd8FUVxZ5YsEKvstajill03ObGHthM6KFS637g8W/
         EEm2PwPU4kk/oEF7g0ubA2AQnt7Brqo3aadGMaPV7nsAhaoSukJdU/EIN76WCTUkKi1+
         uRt+Wbe3s3SnpmhRt3trzlNKuH6IYFHWU+tEQdhwyoYBDAOjdm3IoDHcsNO+4qLUsBJD
         npFjePke5W/HTah2ssALKjb4FnaIYaCNOOGsSPAbohq8w8cfoBVTzffN7U1vxLGTN4+D
         C0LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=n7BlWccP5e9E4x6aVqJtrHQl4d1EpfzcQz8Ne0PToZU=;
        b=kL6feF26boUYMxd8M0E1WPoJ5IaMNV5ewtW4OcKmNy8B8ljVMucXSqlQCDzj++egWN
         02i7g+mRFef51yUODq1UwCe+KpSvCKRBBS1NOgAHkjrtO2KehgJqJD+BXgLNI2WDhKAm
         2qlegDgOiAkm0Z4C2cEZcklkNa7qeJ+Tehu8u37rVV4TlG+nFzsBWjVbK0bBCd/8lUQt
         wkylIwtz0Kgw1C6P09UCsMa60t+W9cEbM8rSKfx5u72wKgibedd3h7gO24JkUa+isLic
         RlBI5C1Nylro22geNs7ihMBzSQfbxlK9eU7sLfVmsowQeONJRgNCH30h7DWjtIMQWDrN
         DuIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dWZpvwBN;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x3si23317213pgr.22.2019.06.04.19.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dWZpvwBN;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552j05E031912
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=n7BlWccP5e9E4x6aVqJtrHQl4d1EpfzcQz8Ne0PToZU=;
 b=dWZpvwBNdjJhXRH3Co8LeCEWmYGp7BZyMm2pKcsTPXZ7X75DWj9ViSkotXNM+IPfy9EN
 E08ucVEDNX1WHNtbEmUyeZHGzxktgV503nSgovL0VXK0aEQ4AKV2zb3dsNweZOs2U1Qk
 6Z6nJ4UH6C4g0rBSbllLSze0zk4ewsf7hnQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2swx191ck2-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:03 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:45:00 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 986C112C7FDD2; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 09/10] mm: stop setting page->mem_cgroup pointer for slab pages
Date: Tue, 4 Jun 2019 19:44:53 -0700
Message-ID: <20190605024454.1393507-10-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190605024454.1393507-1-guro@fb.com>
References: <20190605024454.1393507-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=626 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Every slab page charged to a non-root memory cgroup has a pointer
to the memory cgroup and holds a reference to it, which protects
a non-empty memory cgroup from being released. At the same time
the page has a pointer to the corresponding kmem_cache, and also
hold a reference to the kmem_cache. And kmem_cache by itself
holds a reference to the cgroup.

So there is clearly some redundancy, which allows to stop setting
the page->mem_cgroup pointer and rely on getting memcg pointer
indirectly via kmem_cache. Further it will allow to change this
pointer easier, without a need to go over all charged pages.

So let's stop setting page->mem_cgroup pointer for slab pages,
and stop using the css refcounter directly for protecting
the memory cgroup from going away. Instead rely on kmem_cache
as an intermediate object.

Make sure that vmstats and shrinker lists are working as previously,
as well as /proc/kpagecgroup interface.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/list_lru.c   |  3 +-
 mm/memcontrol.c | 12 ++++----
 mm/slab.h       | 74 ++++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 70 insertions(+), 19 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 927d85be32f6..0f1f6b06b7f3 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/mutex.h>
 #include <linux/memcontrol.h>
+#include "slab.h"
 
 #ifdef CONFIG_MEMCG_KMEM
 static LIST_HEAD(list_lrus);
@@ -63,7 +64,7 @@ static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
 	if (!memcg_kmem_enabled())
 		return NULL;
 	page = virt_to_head_page(ptr);
-	return page->mem_cgroup;
+	return memcg_from_slab_page(page);
 }
 
 static inline struct list_lru_one *
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 49084e2d81ff..c097b1fc74ec 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -485,7 +485,10 @@ ino_t page_cgroup_ino(struct page *page)
 	unsigned long ino = 0;
 
 	rcu_read_lock();
-	memcg = READ_ONCE(page->mem_cgroup);
+	if (PageHead(page) && PageSlab(page))
+		memcg = memcg_from_slab_page(page);
+	else
+		memcg = READ_ONCE(page->mem_cgroup);
 	while (memcg && !(memcg->css.flags & CSS_ONLINE))
 		memcg = parent_mem_cgroup(memcg);
 	if (memcg)
@@ -2727,9 +2730,6 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 		cancel_charge(memcg, nr_pages);
 		return -ENOMEM;
 	}
-
-	page->mem_cgroup = memcg;
-
 	return 0;
 }
 
@@ -2752,8 +2752,10 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 	memcg = get_mem_cgroup_from_current();
 	if (!mem_cgroup_is_root(memcg)) {
 		ret = __memcg_kmem_charge_memcg(page, gfp, order, memcg);
-		if (!ret)
+		if (!ret) {
+			page->mem_cgroup = memcg;
 			__SetPageKmemcg(page);
+		}
 	}
 	css_put(&memcg->css);
 	return ret;
diff --git a/mm/slab.h b/mm/slab.h
index 5d2b8511e6fb..7ead47cb9338 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -255,30 +255,67 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s->memcg_params.root_cache;
 }
 
+/*
+ * Expects a pointer to a slab page. Please note, that PageSlab() check
+ * isn't sufficient, as it returns true also for tail compound slab pages,
+ * which do not have slab_cache pointer set.
+ * So this function assumes that the page can pass PageHead() and PageSlab()
+ * checks.
+ */
+static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
+{
+	struct kmem_cache *s;
+
+	s = READ_ONCE(page->slab_cache);
+	if (s && !is_root_cache(s))
+		return s->memcg_params.memcg;
+
+	return NULL;
+}
+
+/*
+ * Charge the slab page belonging to the non-root kmem_cache.
+ * Can be called for non-root kmem_caches only.
+ */
 static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
 {
+	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
 	int ret;
 
-	if (is_root_cache(s))
-		return 0;
-
-	ret = memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
+	memcg = s->memcg_params.memcg;
+	ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	if (ret)
 		return ret;
 
+	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
+	mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
+
+	/* transer try_charge() page references to kmem_cache */
 	percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
+	css_put_many(&memcg->css, 1 << order);
 
 	return 0;
 }
 
+/*
+ * Uncharge a slab page belonging to a non-root kmem_cache.
+ * Can be called for non-root kmem_caches only.
+ */
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 						struct kmem_cache *s)
 {
-	if (!is_root_cache(s))
-		percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
-	memcg_kmem_uncharge(page, order);
+	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
+
+	memcg = s->memcg_params.memcg;
+	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
+	mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
+	memcg_kmem_uncharge_memcg(page, order, memcg);
+
+	percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
@@ -314,6 +351,11 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s;
 }
 
+static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
+{
+	return NULL;
+}
+
 static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
 				    struct kmem_cache *s)
 {
@@ -351,18 +393,24 @@ static __always_inline int charge_slab_page(struct page *page,
 					    gfp_t gfp, int order,
 					    struct kmem_cache *s)
 {
-	int ret = memcg_charge_slab(page, gfp, order, s);
-
-	if (!ret)
-		mod_lruvec_page_state(page, cache_vmstat_idx(s), 1 << order);
+	if (is_root_cache(s)) {
+		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
+				    1 << order);
+		return 0;
+	}
 
-	return ret;
+	return memcg_charge_slab(page, gfp, order, s);
 }
 
 static __always_inline void uncharge_slab_page(struct page *page, int order,
 					       struct kmem_cache *s)
 {
-	mod_lruvec_page_state(page, cache_vmstat_idx(s), -(1 << order));
+	if (is_root_cache(s)) {
+		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
+				    -(1 << order));
+		return;
+	}
+
 	memcg_uncharge_slab(page, order, s);
 }
 
-- 
2.20.1

