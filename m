Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FCB9C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:40:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32FB020850
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:40:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mZw/5JT1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32FB020850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12B2D6B000A; Wed,  8 May 2019 16:40:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B44A6B000C; Wed,  8 May 2019 16:40:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E487B6B000E; Wed,  8 May 2019 16:40:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 882C26B000A
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:40:53 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d10so80563plo.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=waf7z8I248qGj1WPv3szkFNRuIjadGqCnJ4vjGJ4B5U=;
        b=dW3g/h8hrZMbRoTgaIIknYZa7FsLzP1XlEJobjnLaauJK5Q4Lx2t1/usw261FNsNGL
         Xgr1a/yzhm34uyL5XiNmyGTbPYq9WYPdt9B7wG+V+BUFmdGqCyWbQBj6srSo4hD6Xps/
         ES2BDNhgFPttV8UOMmnag2nhhm8HwjwMdA8DOyRpJb2pguuuzjp86t9ebD3RBe/LM/rC
         3GvyTr6Q/kx7GFLQzma7oDN+ZLkwYMfz4eY4M5V1bQR1rMkZhrz6ttoXpIc/UG7Gxnx+
         iuKQkx8JclzEHjimH1Wq1E0SkUAzxMUmbnYHUZ59GqCiiscIpnwiqrrZMdixR0i9PcGK
         c8DQ==
X-Gm-Message-State: APjAAAUzFsyTe13l6ZJFvyrjGYrx5Weuxdd0dIMLNuzkQUrilMYzmwR+
	LUvMsbZhTlNMlhixfbXJorm+kseSX+YrqvyhkBWkRsJ0NxFbZHRhvzRhtS88mai9WnSDwMf0s8B
	AoVhsLMf2qan+Px1n47IRpz+QrEunEwK/m4SMuJE0gn+d4dmMf5LaA6lXS7wjOrh81g==
X-Received: by 2002:a63:dd58:: with SMTP id g24mr177632pgj.161.1557348053193;
        Wed, 08 May 2019 13:40:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhrR25to8qGuaJCXMNGxmgI+bt9InYANCOrLfcbs5aSamzGvYvgR7UKMeuQH/BDeMINBVD
X-Received: by 2002:a63:dd58:: with SMTP id g24mr177554pgj.161.1557348052288;
        Wed, 08 May 2019 13:40:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557348052; cv=none;
        d=google.com; s=arc-20160816;
        b=Lk8g80bJwEAZMFMyqNfbLauaYC76EXZf0xBlIK+dZ4db2BOyvziR5FJxqZ4oGNOj1+
         Wke0nuXnGyMhLpTe9tx+kC1jgDiI65pDM5eXYS2yIIaojP4rxZ6pFoRWA06aY401GW+M
         +sOOjb4pGVjVvWpsJQhxS8lLrT3ehqRUEVG49YrhEX/BIuc0lheeM3XnOGqUOixZsHfD
         sp5LZoqFFnw5/VT9kmO2wMs5ODB9XZMlHBFmIbCiMzTFZWGZALk6LK/a4wS5T0QpIc7h
         6tgEodBOFROG2g4gq5hlSvizMEkMbwMATitHtNTVB+Y59SrGjIJhpF9s/zzMzdSZxbx5
         HU0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=waf7z8I248qGj1WPv3szkFNRuIjadGqCnJ4vjGJ4B5U=;
        b=q0HJWY5GVdkQBpU3NaA9RMnG1UJ2ZJQwzzvqc371yR9sRm6GnSVfODEByNXmnq0YSE
         lAb7hGAwDygWe7QsUAbKeRa1QjROh0B4G0CwAwx2qY+2aue1gmX/oYdZ0GlTG0TBqFI6
         Z1RbQSvF3Dnjv7KwjbtJ6okxa1cRsuti7KZcPaZ2cRQlGMdwdUi3JjauOmqYTgS1fUA3
         gMZ+iDWD60KVtYl8kU6iYUNcxBBI44XIKipa+kP/n77bCzVIynJ4bNNCSwWIHkHB7dtS
         y0po3Iw/uUjhOvP89nG0lCp2rrBI3bWbmJ8pyF/o8p0BKumfd8FAEGJAaM0gfclws00g
         85JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="mZw/5JT1";
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s79si25120912pfa.69.2019.05.08.13.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:40:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="mZw/5JT1";
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KeVEB023320
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:40:51 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=waf7z8I248qGj1WPv3szkFNRuIjadGqCnJ4vjGJ4B5U=;
 b=mZw/5JT1BzFI2DXc0qEIgdhdIDH/8ub5Ar0QhPw9AdZhlvo4yw5L7NR1osh2eHJEQuXP
 CdJUvJPLWMol/aWq760mBflq4cL3A0529CUCuSe3q2vZn4ZaEHJhxDeD4zfZHZdAlHn4
 tqQPk/UX6foQ3DwxTE48AQsOVhfEGWIuCkg= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc0p91d9f-9
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:51 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 8 May 2019 13:40:48 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 10AA811CDBCFD; Wed,  8 May 2019 13:25:00 -0700 (PDT)
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
Subject: [PATCH v3 4/7] mm: unify SLAB and SLUB page accounting
Date: Wed, 8 May 2019 13:24:55 -0700
Message-ID: <20190508202458.550808-5-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508202458.550808-1-guro@fb.com>
References: <20190508202458.550808-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the page accounting code is duplicated in SLAB and SLUB
internals. Let's move it into new (un)charge_slab_page helpers
in the slab_common.c file. These helpers will be responsible
for statistics (global and memcg-aware) and memcg charging.
So they are replacing direct memcg_(un)charge_slab() calls.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/slab.c | 19 +++----------------
 mm/slab.h | 25 +++++++++++++++++++++++++
 mm/slub.c | 14 ++------------
 3 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 83000e46b870..32e6af9ed9af 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1389,7 +1389,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 								int nodeid)
 {
 	struct page *page;
-	int nr_pages;
 
 	flags |= cachep->allocflags;
 
@@ -1399,17 +1398,11 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 		return NULL;
 	}
 
-	if (memcg_charge_slab(page, flags, cachep->gfporder, cachep)) {
+	if (charge_slab_page(page, flags, cachep->gfporder, cachep)) {
 		__free_pages(page, cachep->gfporder);
 		return NULL;
 	}
 
-	nr_pages = (1 << cachep->gfporder);
-	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr_pages);
-	else
-		mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, nr_pages);
-
 	__SetPageSlab(page);
 	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
 	if (sk_memalloc_socks() && page_is_pfmemalloc(page))
@@ -1424,12 +1417,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 {
 	int order = cachep->gfporder;
-	unsigned long nr_freed = (1 << order);
-
-	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, -nr_freed);
-	else
-		mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, -nr_freed);
 
 	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
@@ -1438,8 +1425,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	page->mapping = NULL;
 
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += nr_freed;
-	memcg_uncharge_slab(page, order, cachep);
+		current->reclaim_state->reclaimed_slab += 1 << order;
+	uncharge_slab_page(page, order, cachep);
 	__free_pages(page, order);
 }
 
diff --git a/mm/slab.h b/mm/slab.h
index 4a261c97c138..c9a31120fa1d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -205,6 +205,12 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
+static inline int cache_vmstat_idx(struct kmem_cache *s)
+{
+	return (s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 
 /* List of all root caches. */
@@ -352,6 +358,25 @@ static inline void memcg_link_cache(struct kmem_cache *s,
 
 #endif /* CONFIG_MEMCG_KMEM */
 
+static __always_inline int charge_slab_page(struct page *page,
+					    gfp_t gfp, int order,
+					    struct kmem_cache *s)
+{
+	int ret = memcg_charge_slab(page, gfp, order, s);
+
+	if (!ret)
+		mod_lruvec_page_state(page, cache_vmstat_idx(s), 1 << order);
+
+	return ret;
+}
+
+static __always_inline void uncharge_slab_page(struct page *page, int order,
+					       struct kmem_cache *s)
+{
+	mod_lruvec_page_state(page, cache_vmstat_idx(s), -(1 << order));
+	memcg_uncharge_slab(page, order, s);
+}
+
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
 	struct kmem_cache *cachep;
diff --git a/mm/slub.c b/mm/slub.c
index 43c34d54ad86..9ec25a588bdd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1494,7 +1494,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	else
 		page = __alloc_pages_node(node, flags, order);
 
-	if (page && memcg_charge_slab(page, flags, order, s)) {
+	if (page && charge_slab_page(page, flags, order, s)) {
 		__free_pages(page, order);
 		page = NULL;
 	}
@@ -1687,11 +1687,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		return NULL;
 
-	mod_lruvec_page_state(page,
-		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		1 << oo_order(oo));
-
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 
 	return page;
@@ -1725,18 +1720,13 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 			check_object(s, page, p, SLUB_RED_INACTIVE);
 	}
 
-	mod_lruvec_page_state(page,
-		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		-pages);
-
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
 
 	page->mapping = NULL;
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-	memcg_uncharge_slab(page, order, s);
+	uncharge_slab_page(page, order, s);
 	__free_pages(page, order);
 }
 
-- 
2.20.1

