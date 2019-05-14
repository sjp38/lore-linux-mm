Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CAD5C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42D8520873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="d4unQ8zZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42D8520873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDC6C6B000A; Tue, 14 May 2019 17:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C66FF6B000C; Tue, 14 May 2019 17:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B07526B000D; Tue, 14 May 2019 17:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0586B000A
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:55:27 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id y185so427096ybc.18
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=A03AYshFiKbUQ0yCq/bPVpZ5Z4eXewT0wNUpNBIpBX4=;
        b=bY+0zzCIzQikINxfcdWYPUCbUYKgb3dL/MhIoMB/Wq+xR3Xcd2QZO7pJywzhMq4JQR
         dT2ASBS++CtOWFTkQHAcsWF7X2AMRnWQ/cJD1eBVYfBjj8eq1rtLnAURgDiA6eUEM9aq
         pLP/bEliOw6bussbaAgkTy9cBpU9z6qJ2HCCKIHpbhA46Nty2+MdNHxbPOGnEUoOBR9o
         g6Sc5lI/Kdj+O5fXr1qsONeNudfuob0/2VEdX2RgW11jj47yiEkYcgbdu3D28dzEYW1D
         KPHPXIy56/lIk+hrkhJBwV44PwByxO3Oedz85K3ZjbwNsXzmVq66U5kE6M8zMzL6GBRW
         5qpQ==
X-Gm-Message-State: APjAAAVRc/soS8+AA4IKB5tP5oKUK2KWGY8+FIZ3Y0EzOZTBBqqDGWHV
	rMofWQPnVqUajqm0rsxUakA3OlydTUDvEZ3jdKLqmiQlpZzaU6NHRVC9dJqeJeAasYZ+zUZ3wKd
	DIaHNM0DyUnIJkcrnIw8AGRkbQCSC08raHfgD7rIjG5l05KCVCennPK+4zFinxqdMTw==
X-Received: by 2002:a25:c590:: with SMTP id v138mr17598333ybe.53.1557870927238;
        Tue, 14 May 2019 14:55:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxM4FvwzFq8lXOgxFr1oaHtdiwiG8hhchby+rHTLxbyGsgmY/ErPzKvTRpQsn4FhAvGjQO7
X-Received: by 2002:a25:c590:: with SMTP id v138mr17598303ybe.53.1557870926405;
        Tue, 14 May 2019 14:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557870926; cv=none;
        d=google.com; s=arc-20160816;
        b=w+wtjhOoIEXtrit+Dv2YAl961N7oowZADXCvcVjiUPmT7Mo9wMFx8IpISIH/2WfdgZ
         bhvYQw/3kKAMDfLYvrf4vCHZTShtm8ASVQlXKEJqizI8WhGFOkBN3L1cnH3mtZWuM3j9
         XrQadknsB9wf3pAYLg+NXktdmIBAW+tDs0sBswGqacDR5lvOS4L2A3F/fFDRhHI4DLo6
         mbfYAFfGVclt9DiWJe2fhc78W4UlQcK1O5aMajlNJ3K2FOOliNezcXzHBfQxsoItniX/
         L8PumyHQO/kzxdJcKFab+eOO+2gg7JQdNfixQMmayZfmM1Xzy9NLAZb8yiDrRPL1tUJG
         yhYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=A03AYshFiKbUQ0yCq/bPVpZ5Z4eXewT0wNUpNBIpBX4=;
        b=DoIfB9uJ9QyjD75QgICy792vggIQISD8VsHnaiRNNPEhhq3ezsWyGTQREBQbnnoIsA
         xAxcFLt/Q1PBy5RQa9sS+PVHJOt1G+0L4Wd95UKYPUQFzfP16zSWsQ52hl40enu4uvSg
         3mpD4A7+tyti1QhF0kEddJD0xWTml3xrwROqYNz5WT2YvWceXglYwXZmMvVC8op5gyAj
         9mE5mKs0JcyDgykHT8uMGdUhdECEWU8tdF4S2TmJq2HH2sEisIsDWg+vIlP2CRBDQgIv
         YfSndi/zgd1Kr+IVUoWs1JWZfvzeM8Ki+CZAuLBHA3co3DUBWN/BMhndAtCjKNfYvSjF
         UVPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d4unQ8zZ;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 125si5224542yby.302.2019.05.14.14.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:55:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d4unQ8zZ;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x4ELrUeA020485
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:55:26 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=A03AYshFiKbUQ0yCq/bPVpZ5Z4eXewT0wNUpNBIpBX4=;
 b=d4unQ8zZCvmRXYLUv8B7oSCdjekI/QhDlRNCjdDhi6/4EgqqWtiXgncPQ+uPGhjr8g3W
 MgLhS2EIgsAgsdaNSCnT7TOKlzwuZVx+dmCyWTcYsmViSfFjVDpaKia2mN/4WHcC8xcA
 PN/O/ibEdf55Ut0X8s3sWoizC2wxXFECP0k= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2sfv362bv9-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:55:26 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 14 May 2019 14:54:55 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 829F1120772A8; Tue, 14 May 2019 14:39:41 -0700 (PDT)
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
Subject: [PATCH v4 4/7] mm: unify SLAB and SLUB page accounting
Date: Tue, 14 May 2019 14:39:37 -0700
Message-ID: <20190514213940.2405198-5-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190514213940.2405198-1-guro@fb.com>
References: <20190514213940.2405198-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
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

