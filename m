Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57049C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03DF720828
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VOPrQ0JA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03DF720828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E72D6B0273; Tue,  4 Jun 2019 22:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 474E76B0274; Tue,  4 Jun 2019 22:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3146A6B0277; Tue,  4 Jun 2019 22:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D69F06B0273
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j36so13771318pgb.20
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=oKYQ1N3o2byC0i/b69CpGwU+m8Lkbxo7avMVOowYKjc=;
        b=EzSLBcli36aat1JJ5gbfDgM/bHNsqf4VdyiCu8guDk6bulpKv1aDiZc6myEU3V/7G8
         sMeAvBEcfftxhvJAaL96Y2PFq0X+p5HsCCd24y7PoEQLC8IfishfvV6moeZT+MyHMUHN
         Ru9QwDSdRGySV1VgYbIz74Xwc4p5xe4yzyoVERos41/uofcVBKUBPWdt6pAeGeO8zmRo
         o9vPxd3h31c8xyM5NILsOI6D8H59MlgjfVGG4NoeulZjjL22YSInuCZ44HezVa4/VQZJ
         //saQlRS15B/r6Zk4cVx7C0piJCF4ZCDhfE6hlwWYhD7zFaxbM5Rxtm5MnY/Hla+MBhW
         z80A==
X-Gm-Message-State: APjAAAXZep/W99UsuQQW3n5kUNTOrS+zLVVWT44X6aYM6LVJ0XD4Qu0o
	wZ8o5olgIyxKZuPzPnUwAIS9kM0iFVfHmFZus2yTcn1sk2J/mCfOrMwGTPUEezibwjXoRQi5kD6
	WoaJXFHYePjqQ5207F6gaY85IymO0o3+5vWTJwBHN9eXzg0Q97ht8YiXlBdO+rpv0wQ==
X-Received: by 2002:aa7:8c10:: with SMTP id c16mr40980233pfd.89.1559702705262;
        Tue, 04 Jun 2019 19:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdC5OB3n313hXuEp2yLHANHnsvI1C19CyWWs7HbTmI6gVHONwa9LFHKTb6LBvOplvTplOB
X-Received: by 2002:aa7:8c10:: with SMTP id c16mr40980165pfd.89.1559702704214;
        Tue, 04 Jun 2019 19:45:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702704; cv=none;
        d=google.com; s=arc-20160816;
        b=uMnfufF7efhMtbSlQM202wqHDNJhYdipP3yzbqFSEXITMlRVQ2JHdJ1YX66aw9IZsm
         cQUGTcZoNes866da/Ar74octSWIKDYN6zDSdc/yL38pFQXD+FUil6LjPs3zzum/Omfe+
         6HY6CtovpxxL+ISGp3qYz0+U7DX6EWBciwrMIBg/4Z9hVyrwni4I7DwEhGW0xorfAlSF
         u27VC7HgtiLgHBB+LKHO2W5Zl7S8fvuJMsjQ6Psf4ks+kf4fmFBcH+U1SS4jeiYobIej
         9sphjJth6YC1LOJ/VPdyFJlZ/NCRH6ebw3L557/MRkCbxHuOsLCocVckdoteOPXn15pg
         qqDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=oKYQ1N3o2byC0i/b69CpGwU+m8Lkbxo7avMVOowYKjc=;
        b=SR7+sGzYRAc7Z7qdspBVDCVKejQKC8mi1qK/g0hH7cV8sSnyznaLurRxCQ+N06+25X
         vusplJSFtCoM0tgd6b8ifZtRsvPEdpbsx+I5N4vuCrJma+8cxwDtisRd7eqwY7T3GNYp
         9D2AH1D57NwC0rzAJitCSCEsmQ1OzcbxRvpVMnxHWuDa4V5CHU+7utq1pfK4qSuACsNF
         CHAcpeotQSBUgqiYcwYOvfVsWMOPT98S1RuA6cG4oz1wmVp1GRSFxlYT5FcJhz8FzY4n
         2d/L8nxCdf44oBHvSqEmUyjx+GZX3Gkm5vY1EaICd/QSGlHgZJMzFGGHiIP58uGEeoK/
         KU4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VOPrQ0JA;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 2si26218293plc.228.2019.06.04.19.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VOPrQ0JA;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552iAP6001299
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=oKYQ1N3o2byC0i/b69CpGwU+m8Lkbxo7avMVOowYKjc=;
 b=VOPrQ0JAg/nra9uRdO5LxJgcMWkDfH3HsL+8GNCOyljMjWWb+C2yk+MorV/9zb3xGOAL
 7tN5UbvmTPnm5qvU2F/JS/9cmffrnu/PfF1YXdYQiVzSnxQEQ86jRc+BlsvuiP66dkFp
 noFLBbFEQ3fwQ+DTun+q7mTraroNGCyvOls= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2swq1tjy3t-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:03 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:44:59 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 8BB2312C7FDCC; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 06/10] mm: unify SLAB and SLUB page accounting
Date: Tue, 4 Jun 2019 19:44:50 -0700
Message-ID: <20190605024454.1393507-7-guro@fb.com>
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
index d35d85794247..345fb59afb8f 100644
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
@@ -362,6 +368,25 @@ static inline struct kmem_cache *virt_to_cache(const void *obj)
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
2.20.1

