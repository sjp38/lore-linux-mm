Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF1C3C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 04:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42138218D2
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 04:44:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bHFYCX9d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42138218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B76236B0005; Wed, 24 Apr 2019 00:44:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B25556B0006; Wed, 24 Apr 2019 00:44:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ECEF6B0007; Wed, 24 Apr 2019 00:44:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 786546B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:44:24 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id g186so13958659ybg.16
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 21:44:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=DYe1Kczls7Vz3TOywv3SCxyloB0ylRoW+6/MG/k28Aw=;
        b=DVvyT5foRXkai1jZUNTHYzJfnglGC6zr7bhUiv+jE/Yu3PO5XKd2sy0a+HgA0dHBrB
         1L2nFezAbi3lJkRyDxVA+oqOQL8s8uxp/gkrTybkW/+cfzpmzlffJYOnRVpg1mv6YIiQ
         QpSIQ8FLQfpHNGWRWYbCmA4DWv2t1Srr4fl+yT8xokNUsvuETjJbcBG2lfvO+Htmcop2
         gJfWgqOUUZ1zDPBDx/nSIt7Y9HRaLaW4y8hMsQVFo6ZEb1mutkCBUnoATl4Utl8hiNSC
         0xD5xquinggebXhU9ve/obWup/cdD8KlW17ksS4JH3flsrAH9o4Km63HDnaI+uHChykW
         2/XA==
X-Gm-Message-State: APjAAAW5/GtFR8LXwXax5ctmZA0jeeSS4S+M7+ElpIe1rheRx96CnHza
	rJVJIXnjbazx13yI70tteGdhg4gIEkVVbqHsiNa2X9tnkYrRtcI7bSux9YLcppq84uL0OLMSQgc
	ugSa0Y/dRNY6+c2/fji52E4P0BAuS0HjgcySemTO4Y9TpbKf0niuBGbdW0wbPmEAVdg==
X-Received: by 2002:a81:7c56:: with SMTP id x83mr1592385ywc.303.1556081064201;
        Tue, 23 Apr 2019 21:44:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQXH2RDkpXNDVEtztn4YY1peBN+RZLoAKasrUhPt+QZ3z9ABPNs88J9WPjX+krAZxAffZn
X-Received: by 2002:a81:7c56:: with SMTP id x83mr1592343ywc.303.1556081063192;
        Tue, 23 Apr 2019 21:44:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556081063; cv=none;
        d=google.com; s=arc-20160816;
        b=lccI+HC4KvR1L0kFI5khL7R1hnbWR9Fwb+0h7rfo/qFsVZEAGgDJ42GrvBbIqKUkQ9
         f0SAwUIDB91ILTL3UwoiBljqsNNhsEVllOJG7ueC3g0ENd6xmMu8j/X31+/hC//AHNcd
         /qJ1tirtIYXOlZviMRXGM4+OCHM6tMWMnfcjqoayp5q4acGitsiamvIRffLxVNaDcnmp
         O2DQ+AopgzTYXxCpEdt4WNpqg36nDHew761ecc2ow6bZg+NZohAAEZY/5dySsrtDKZii
         NqX436MwqrPBOOeaTeK1MP4SbBxvURjo7TFVKGhEol/5axBHTtmwRWphTWN0/aRriTKp
         K7qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=DYe1Kczls7Vz3TOywv3SCxyloB0ylRoW+6/MG/k28Aw=;
        b=RG9R8xaRm2xIibxg2v2oP/RWpInJm99QG+f0/ZrVHwoJVEy4Re5a65MW1U9L2UNb2J
         DJJOi0IBhYDKFff1kdIdVpddflhmYOjLVvCYnWGTNkGsrqLaXyOcPUZiLxDR2x5mNiER
         Pw50GEdUPEuyfT7G5Sf+INyV7FoRmmAfM/xG7tUqitBtZ655fBiS3efygU3cGw8+vfVK
         d8AP94lo4yq7f5lB7jDZ3XxHtQGQo0RYNsbH/Cda/DhR8sbwdxNtJuTdpTPQxsLp261T
         elyKLCiNqYzXrt2+mmp+KdJbX7i4/93gjwzM+UkBdEcNP9TDwU82IQofHEZNvmhpQxBt
         FIiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bHFYCX9d;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id j74si12375977ybj.472.2019.04.23.21.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 21:44:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bHFYCX9d;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x3O4ftRX022118
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 21:44:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=DYe1Kczls7Vz3TOywv3SCxyloB0ylRoW+6/MG/k28Aw=;
 b=bHFYCX9dNv+cHnVzRdmj18VbL4bDaxiJJyLgc94iTPCfRd9wNi3dL/rByW9imQZa6iGr
 kACIO/RjRo+g9bmaNvlqG0vBB/KS4n/qab2mlGo2lBZ6N+pY8AiRkfvXFNklVhQHI0sR
 qBwXvEKBnK4lJsv6nu2Q33NJFu6LmyVS0aY= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by m0001303.ppops.net with ESMTP id 2s28ke1upn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 21:44:22 -0700
Received: from mx-out.facebook.com (2620:10d:c0a1:3::13) by
 mail.thefacebook.com (2620:10d:c021:18::174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 23 Apr 2019 21:44:21 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id CBFA01142D2E6; Tue, 23 Apr 2019 14:31:36 -0700 (PDT)
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
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v2 4/6] mm: unify SLAB and SLUB page accounting
Date: Tue, 23 Apr 2019 14:31:31 -0700
Message-ID: <20190423213133.3551969-5-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190423213133.3551969-1-guro@fb.com>
References: <20190423213133.3551969-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_02:,,
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
 mm/slab.h | 22 ++++++++++++++++++++++
 mm/slub.c | 14 ++------------
 3 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 14466a73d057..53e6b2687102 100644
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
index 4a261c97c138..0f5c5444acf1 100644
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
@@ -352,6 +358,22 @@ static inline void memcg_link_cache(struct kmem_cache *s,
 
 #endif /* CONFIG_MEMCG_KMEM */
 
+static __always_inline int charge_slab_page(struct page *page,
+					    gfp_t gfp, int order,
+					    struct kmem_cache *s)
+{
+	memcg_charge_slab(page, gfp, order, s);
+	mod_lruvec_page_state(page, cache_vmstat_idx(s), 1 << order);
+	return 0;
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
index 195f61785c7d..90563c0b3b5f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1499,7 +1499,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	else
 		page = __alloc_pages_node(node, flags, order);
 
-	if (page && memcg_charge_slab(page, flags, order, s)) {
+	if (page && charge_slab_page(page, flags, order, s)) {
 		__free_pages(page, order);
 		page = NULL;
 	}
@@ -1692,11 +1692,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		return NULL;
 
-	mod_lruvec_page_state(page,
-		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		1 << oo_order(oo));
-
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 
 	return page;
@@ -1730,18 +1725,13 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
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

