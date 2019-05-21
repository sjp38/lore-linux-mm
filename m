Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B932AC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:23:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 629912173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:23:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="e+Wr4I9+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 629912173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D72E6B0003; Tue, 21 May 2019 16:23:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 088406B0006; Tue, 21 May 2019 16:23:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBB196B0007; Tue, 21 May 2019 16:23:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B318D6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:23:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t1so68130pfa.10
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:23:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=A03AYshFiKbUQ0yCq/bPVpZ5Z4eXewT0wNUpNBIpBX4=;
        b=dEoe+AK9T1Jgl2Z1kPVc98AYZsSSoqVBY2V0reIyTr9Xeu+CWf4G5oqFqdeB4qdlJQ
         gmsDLodqo04u0dmS3/c5pFeu6D53+4VzlV5iODKdgeo6YlacwIORvUEhGlftq6/zrGLs
         LSyQIe9YWNtA6MVkqsrCAKfLrIINNqVMd4VKRByWw5xjH1AwPUWi+h6YOhpXOVKtLG30
         Onl4g8DKWZKEZPDQoQPjJsgkQURRZoZP6V+V1U8e7BnhizDjFp4woeg4X/9cGtJdscL9
         mMW8BhCXcdeVMhi/uMX2GeOIbEzhBLxFX1tUd3avO6ZWXAA0OBkA/DjQkliSdA4nRkmF
         j2Mw==
X-Gm-Message-State: APjAAAWP+iR35Tfs/piR3NWePt9gi0tGyyfPgFPAau7ma7wgNADXcr1o
	MgKZHcxeI5AHct7bQ5U3dWKnwwsBxFgupbt9NlTPiCtfihVd61l/VpveIlqm0Tr9461/cw+ScSi
	xj40GxiVr5wvCfGYpgV7mrTqT9nCNahRsYzOBDdE/tkVqNCDErni26KVWOZBJm+rolA==
X-Received: by 2002:a17:902:ac98:: with SMTP id h24mr29224003plr.265.1558470231305;
        Tue, 21 May 2019 13:23:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKzl4gssoe8m141Rv94/GSDqXNCCPmcOAs6b50ocRBGcl9xLdOfiEHGXcBpfRX23nZgsSb
X-Received: by 2002:a17:902:ac98:: with SMTP id h24mr29223918plr.265.1558470230354;
        Tue, 21 May 2019 13:23:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558470230; cv=none;
        d=google.com; s=arc-20160816;
        b=xGHvN/aRX6FoRx0GUOQcvNkONt+CVXP0uQVkqYbyOi4tCxxu0hz5sg9s+cbBEx3eqG
         FyEFVuYAoHPiky3wOid+Zk8OInLs6JU6Rh2Ck1tqSrtrX2zIg3n8COM7TDiagBwEQuJj
         O7kJpIeeFNrgnUtfGMBVjbRqCOI4RFPPDJBvLwbpQPaPXZdr88sUCj3H3Fw6qm63bCzD
         QqzpaeNZo629dVY0ScSFSF6J1SeI0mDphZ5T/tOwv2GezljR48YMwvLStrKM7Gh3xr1N
         I5Y0DOU6Odqw1pjnV0q7A/5+jOucKpz4FVBSVPpmbUkXkfv2Zepne0grXPxpJ2Cp7AtE
         kauw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=A03AYshFiKbUQ0yCq/bPVpZ5Z4eXewT0wNUpNBIpBX4=;
        b=h3gYh8FiaTpA1TCl2+rm5kG41tEpA14RlwAoxpt3ce/uxmjgYjXLpyWATFkkIxSGhf
         9fM4hAidgJde/8z3tNQ320zglzN67IdvTE+bD7dVHTQdBLf7IdYa4lUGk69zFfiP+kNi
         kQ7f8keyt4D8YxbSIvEPAxMJ88GJ0gSRYdCchjnd1QCvEfKE55/0gJ801rQxsgKMec3J
         vayA9j5tev7l56KnyuemTVClBI9oZVPOh7qSyyROVWNBk9DNxiDTD6pdDWf9Oo+x4B0x
         BEOwJcFqFQRApIvnYaxfsb38N38LKcB58i8p6/s2wkcrJqWRmxwNQABKL2wgGdNEWWhP
         eYUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=e+Wr4I9+;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b3si10778762pgd.243.2019.05.21.13.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:23:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=e+Wr4I9+;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LKMxfR014110
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:23:49 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=A03AYshFiKbUQ0yCq/bPVpZ5Z4eXewT0wNUpNBIpBX4=;
 b=e+Wr4I9+mlsoWfyPjB0jQ7nRJjqCfBcqS6JZwm2pI4wiDvD52yGgW5DYQF3oi+kutj3k
 hl+HF/+Ryqjnoo/+5DUIYk2be/NsJ2HN1iKjbH7Pw0CS1g6IgvV7Cbuz11ninGCITUdu
 63xwrVTPOpS15HOudXlwggwhiTged/ak5OY= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2smd9cjgj3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:23:49 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 21 May 2019 13:23:48 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 0D3C01245FFA7; Tue, 21 May 2019 13:07:50 -0700 (PDT)
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
Subject: [PATCH v5 4/7] mm: unify SLAB and SLUB page accounting
Date: Tue, 21 May 2019 13:07:32 -0700
Message-ID: <20190521200735.2603003-5-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190521200735.2603003-1-guro@fb.com>
References: <20190521200735.2603003-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210127
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
index 8abd2d2a4ae4..13e415cc71b7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1490,7 +1490,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	else
 		page = __alloc_pages_node(node, flags, order);
 
-	if (page && memcg_charge_slab(page, flags, order, s)) {
+	if (page && charge_slab_page(page, flags, order, s)) {
 		__free_pages(page, order);
 		page = NULL;
 	}
@@ -1683,11 +1683,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		return NULL;
 
-	mod_lruvec_page_state(page,
-		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		1 << oo_order(oo));
-
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 
 	return page;
@@ -1721,18 +1716,13 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
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

