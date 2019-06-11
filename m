Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EFA1C31E45
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F10DD20872
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Z0bvFpiu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F10DD20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 659146B0269; Tue, 11 Jun 2019 19:18:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60CBB6B026B; Tue, 11 Jun 2019 19:18:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 481D26B026C; Tue, 11 Jun 2019 19:18:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3C16B0269
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:18:27 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id 75so9372323ywb.3
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=qH2mK7ADNJ2npb+novhRBQUAsWfqGb1hE4WTZyKm8WI=;
        b=X123vEtMYA1a+N07tfdJ27r5XtApqazNw2WSzQBauHKFFCOzQjupBSKBHoPnzM/XxZ
         JGXALLcTvqaXgdAnyGWNliUq/1dQY0OaHcSt3XdKUV4eb9Tt+wiVYFutVk8izWdXm8cv
         eKwPPT19VJaUP4CUYyt1g5Ie+ugTQyzRpy4jTnt2UpgnF/7iqjrwt9+zf1dG6aKNYCAr
         zap9vuPvnBhrFl70X/7gLe/Cx2amEwtgyqCnifoJ3LqT65iweYCogk20/9wcB1NvJt3Z
         apZFCFdDNuhb4qennsWtnFckAdPlOXNTQ62fcOWsMXTWdM6fMPzbGEl8SliFcLGqGBrI
         ztmA==
X-Gm-Message-State: APjAAAUvQ574Pr8DEzJGT1Z8lkgrXmENZ5g0AiKnwAbP+N6H3dvHVUdL
	pbdu0HN2mbBM871OA6qkmBLEcHCugEezts8x9dM5JovatuuMA/e1PeSaxeS6emrqNwAzafk4wjA
	tlj5viI0+oLmmQ/2rRyOTwgDhB3m887lyzeW3VsoQC4tEWwIsVT0N7iqCHuRonAcLxA==
X-Received: by 2002:a81:148b:: with SMTP id 133mr29023487ywu.394.1560295106871;
        Tue, 11 Jun 2019 16:18:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5nIE+0wmIZsT6HJkyBMlpYDH9e5/b0egV2HaX/Asvo4kI3POmZJR1gloDNS2XsWVk2STB
X-Received: by 2002:a81:148b:: with SMTP id 133mr29023451ywu.394.1560295106175;
        Tue, 11 Jun 2019 16:18:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560295106; cv=none;
        d=google.com; s=arc-20160816;
        b=Kq5dktcHmQpX0KPSf2X31qX853kd5fe6Q5xklwitvY9glueJgacz+07jlpPU956jok
         xE2NlA6IwrhMO+emwFkJ+S84eO9GZRBPPx3jhQYoP8I1T/R7mmAJs6w0ZtY1fMG3uX+t
         sL/IkAOHHbnaqg9tei+6d31YpthEAiyNiNocKQaO51U0SszNa8IhxyMob4nFfjOG0h/D
         fHwnSRlZJZ4mPqbHJJWVvCaXnSRiaXJ5heS3FlJcYq+bFMEMHZ8xCYnntPdG5JEyW5n2
         Cje8oVyo8vdb4nt8hnzUMV6+3phmupyIyhWI/yaRtsaZ75vW5ArUENhT6B7v5+KucR8z
         5sqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=qH2mK7ADNJ2npb+novhRBQUAsWfqGb1hE4WTZyKm8WI=;
        b=pK0nXQJGSm1o7C6jIHtm5nnRKKybgVVZmIwJ92GTbbaXcsRg8nhDHknsCMIZ84fVW/
         5/0pLVQGbp/oPrf33o4Rv024+eA5PqK7qujJezer26tzZkfEzCQSUaYhC3UWZc+RQEsZ
         YmLE7TNgJbmqZsh/LhBX4gXxNt0uTXPzGkgV86VUUgu7Uep2pSCzOzalgRKkWGyvQqRt
         MFAAiNxics/7vTTbPCVsGloMabnfgbMm/qLzgNlDHGTgY4BnbKzjh99gn1IOuN9sR+29
         TDo/bI5q26bfoAL4o6OPU97wQmy8/UhMb4A/RO4SGv5iLYqNczO6gYYaprDotXUN9uAL
         h1sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Z0bvFpiu;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b5si5016487ywf.221.2019.06.11.16.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 16:18:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Z0bvFpiu;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BNBnD4008431
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:26 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qH2mK7ADNJ2npb+novhRBQUAsWfqGb1hE4WTZyKm8WI=;
 b=Z0bvFpiudRjXKo4lqflXk3QO0pA8BeE7EHfgcY+YiyX1VvUivQx92uxfFm+t8YnHrsRg
 S7A25vFea7iz3ZQq64EMk2FbRpNBIpmupB6aLFiY8x+MA6eLdN+2gZY/xwmVtndcZjcr
 jdfqQla+d3aCNp2fr3iDPym1O2jLiAwIQrU= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2t2dkmsy3b-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:25 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 11 Jun 2019 16:18:21 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 3A2DC130CBF6F; Tue, 11 Jun 2019 16:18:20 -0700 (PDT)
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
Subject: [PATCH v7 05/10] mm: unify SLAB and SLUB page accounting
Date: Tue, 11 Jun 2019 16:18:08 -0700
Message-ID: <20190611231813.3148843-6-guro@fb.com>
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

Currently the page accounting code is duplicated in SLAB and SLUB
internals. Let's move it into new (un)charge_slab_page helpers
in the slab_common.c file. These helpers will be responsible
for statistics (global and memcg-aware) and memcg charging.
So they are replacing direct memcg_(un)charge_slab() calls.

Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/slab.c | 19 +++----------------
 mm/slab.h | 25 +++++++++++++++++++++++++
 mm/slub.c | 14 ++------------
 3 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4b865393ebb4..b417824a9b15 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1360,7 +1360,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 								int nodeid)
 {
 	struct page *page;
-	int nr_pages;
 
 	flags |= cachep->allocflags;
 
@@ -1370,17 +1369,11 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
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
@@ -1395,12 +1388,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
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
@@ -1409,8 +1396,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	page->mapping = NULL;
 
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += nr_freed;
-	memcg_uncharge_slab(page, order, cachep);
+		current->reclaim_state->reclaimed_slab += 1 << order;
+	uncharge_slab_page(page, order, cachep);
 	__free_pages(page, order);
 }
 
diff --git a/mm/slab.h b/mm/slab.h
index dc83583ee9dd..46623a576a3c 100644
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
@@ -361,6 +367,25 @@ static inline struct kmem_cache *virt_to_cache(const void *obj)
 	return page->slab_cache;
 }
 
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
index ae3b1e49ecec..6a5174b51cd6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1488,7 +1488,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	else
 		page = __alloc_pages_node(node, flags, order);
 
-	if (page && memcg_charge_slab(page, flags, order, s)) {
+	if (page && charge_slab_page(page, flags, order, s)) {
 		__free_pages(page, order);
 		page = NULL;
 	}
@@ -1681,11 +1681,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		return NULL;
 
-	mod_lruvec_page_state(page,
-		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		1 << oo_order(oo));
-
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 
 	return page;
@@ -1719,18 +1714,13 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
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
2.21.0

