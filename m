Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F22BC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:55:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 018DA2186A
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:55:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WKg+XPP0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 018DA2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9704B6B000D; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 923BF6B0266; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E6936B000D; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19AE56B000D
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f7so179806plr.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:55:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2qTSnTK6DrJDXJXnCNRZMj0fJcJ1BWzKc8LF04T53hg=;
        b=nCOzR4A2nu6Z84uqOUrtKXCriPWy/H+bgWEiSi/Y1utHVBYzjkiXPkEKTduR8ZWMcV
         iGRfp/6xJ7cGQax3Rr35CdvMXSz4AkMWf9dcaX2CjqVBUEdVBEtYmUn87U8sdkxsPqu/
         e1E5AUm0I8ffENk8s/xe0OtgL8wOz0VYNNMdnY8FxP0VOhTqMXJQ+41oDSDhhZFI7RKE
         tb+Nsq/5lP3VHI0xYCJ+VeRNmedKQ/auDYd0h1Us2w3EKqmhfoRyaOO7guxLcOB+Sx9K
         kXlB1dSkhA/ZwDC5YO6mMDDKhalLTVuyug5j44t0FQ4FaCGKErJZ13Z5sPqlHxtSb/iB
         57/g==
X-Gm-Message-State: APjAAAVAE9I6UM7q7v03WzrOvN6ZUxUXAMZ21al1NkiTBAGTx4nEDwmq
	ycCl0J8uvdY5nnt/lpUso8xGTi76bP/GoFJ3R0m0AH5keC3hvKOzVAXVMz5Vr2qV7cl5qMERybr
	DSmT6bsbjDrdkZjaqJSWyI/yJMkU4OnCBH4hn2qTl6/bDdhqSguiE58wOR7yIXLl+fw==
X-Received: by 2002:a63:180a:: with SMTP id y10mr2048844pgl.450.1555538101635;
        Wed, 17 Apr 2019 14:55:01 -0700 (PDT)
X-Received: by 2002:a63:180a:: with SMTP id y10mr2048745pgl.450.1555538099769;
        Wed, 17 Apr 2019 14:54:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538099; cv=none;
        d=google.com; s=arc-20160816;
        b=TsDKTqaa/W1uBS4VV7by8FLfCD7CJZIrpFZnerHOIXoOVDG8Ga+MpYtDdbM9lj6IzZ
         zULqEbxKa5OkWq/T0pnurDT3sFsfthAb+7+x5f6wmVbVPDNlBbTdsEaaKx2RJ9DQaxJ8
         PGZ9JpEMMZkTROAfcGntj4nM5MHLng8YJMqYVZQ+cUCie7aKkfNs58e57ittzcVtyKAV
         9UWdm/hIVTq/oNLShPPLUAWqkW34VKwUiNQ0TfCmtKsNMHKh0K0yRkNKsPAo/Y/+1QIu
         YJaN8Pt63txE2gVGfjY1/+meZnFoxjgSpvTRIUzba9jgBkyQjt5ne8PjfjAxhdb3g8pT
         7xkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2qTSnTK6DrJDXJXnCNRZMj0fJcJ1BWzKc8LF04T53hg=;
        b=jUlBgEWqDw3v4XWdgw+sKu844ND9QMkNxci2wji0M18j7uoLVBVuEU8q1m8dtOrPGh
         YP7LUwqgl7TNTVQcC18wT9sf17vZnz0KV4IvTWLp8KRGvyFSjizXUfAt9eY4OVEnC990
         MyPOv1KHg4KHFlpbHB03P1S9N2P1LbrlgTvWI5yX6bNZycW5JHeX/1Qe1yHHjTFQXP7i
         VbhOPXfM8vQpv6BipetpOUmDW4hTA7FbjyRpdu8HL8HTyWuRmyBsVDt8qkzNjwqm4vDG
         qxoQ1T6Vts13wCV9+wNdHZ06MmSlvf3680sOuIzC1fFCRvMCkHYl8pdURdRjdHuS4ht1
         3fhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WKg+XPP0;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2sor46944pgv.32.2019.04.17.14.54.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:54:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WKg+XPP0;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2qTSnTK6DrJDXJXnCNRZMj0fJcJ1BWzKc8LF04T53hg=;
        b=WKg+XPP0EkFxCA1R9LDtszhfSNKpN3xu9VXo0hR8NaV9Hg5/d+F6vMYurdpDIaS8o3
         TnHzRETH1byoyF/S8KLPzSPDTFfOUARS9AfsMbAl6obmJXjVtR/G3x4qzSqbSp6cgVlS
         XOYWUQAGr4Vnet0g5ylHUUb3TS4NtLDVkXaaHd7uWJ/FWSXtWWvzB6RRdXUI3gEubnoy
         w4jUCf2AIP17EQqYsyPO0YzK4JOYaH2lvR9ND7qX6w3Qb7G3+1ttB70ZY+kksY3vRr0+
         8Dp54cYDpYnwD6wjegW9aQBZXV/EGqqOIDQlW7R4aeIKjZfnke6yaJOyL+QjN6x2Zppc
         ecpg==
X-Google-Smtp-Source: APXvYqz3rrrk7qPfYfvvzhHgMyqQGYm2yp5s+aBDKawTX9Uq/I5/BhGOZ5a1DLbYOKMEuo1Pd9uiJA==
X-Received: by 2002:a63:4548:: with SMTP id u8mr2043991pgk.435.1555538099326;
        Wed, 17 Apr 2019 14:54:59 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5597])
        by smtp.gmail.com with ESMTPSA id x6sm209024pfb.171.2019.04.17.14.54.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 14:54:58 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	david@fromorbit.com,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
Date: Wed, 17 Apr 2019 14:54:33 -0700
Message-Id: <20190417215434.25897-5-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417215434.25897-1-guro@fb.com>
References: <20190417215434.25897-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit makes several important changes in the lifecycle
of a non-root kmem_cache, which also affect the lifecycle
of a memory cgroup.

Currently each charged slab page has a page->mem_cgroup pointer
to the memory cgroup and holds a reference to it.
Kmem_caches are held by the cgroup. On offlining empty kmem_caches
are freed, all other are freed on cgroup release.

So the current scheme can be illustrated as:
page->mem_cgroup->kmem_cache.

To implement the slab memory reparenting we need to invert the scheme
into: page->kmem_cache->mem_cgroup.

Let's make every page to hold a reference to the kmem_cache (we
already have a stable pointer), and make kmem_caches to hold a single
reference to the memory cgroup.

To make this possible we need to introduce a new refcounter
for non-root kmem_caches. It's atomic for now, but can be easily
converted to a percpu counter, had we any performance penalty*.
The initial value is set to 1, and it's decremented on deactivation,
so we never shutdown an active cache.

To shutdown non-active empty kmem_caches, let's reuse the
infrastructure of the RCU-delayed work queue, used previously for
the deactivation. After the generalization, it's perfectly suited
for our needs.

Since now we can release a kmem_cache at any moment after the
deactivation, let's call sysfs_slab_remove() only from the shutdown
path. It makes deactivation path simpler.

Because we don't set the page->mem_cgroup pointer, we need to change
the way how memcg-level stats is working for slab pages. We can't use
mod_lruvec_page_state() helpers anymore, so switch over to
mod_lruvec_state().

* I used the following simple approach to test the performance
(stolen from another patchset by T. Harding):

    time find / -name fname-no-exist
    echo 2 > /proc/sys/vm/drop_caches
    repeat several times

Results (I've chosen best results in several runs):

        orig       patched

real	0m0.712s   0m0.690s
user	0m0.104s   0m0.101s
sys	0m0.346s   0m0.340s

real	0m0.728s   0m0.723s
user	0m0.114s   0m0.115s
sys	0m0.342s   0m0.338s

real	0m0.685s   0m0.767s
user	0m0.118s   0m0.114s
sys	0m0.343s   0m0.336s

So it looks like the difference is not noticeable in this test.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  2 +-
 mm/memcontrol.c      |  9 ++++----
 mm/slab.c            | 15 +-----------
 mm/slab.h            | 54 +++++++++++++++++++++++++++++++++++++++++---
 mm/slab_common.c     | 51 +++++++++++++++++------------------------
 mm/slub.c            | 22 +-----------------
 6 files changed, 79 insertions(+), 74 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 47923c173f30..4daaade76c63 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -152,7 +152,6 @@ int kmem_cache_shrink(struct kmem_cache *);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 void memcg_deactivate_kmem_caches(struct mem_cgroup *);
-void memcg_destroy_kmem_caches(struct mem_cgroup *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -641,6 +640,7 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
+			atomic_long_t refcnt;
 
 			void (*work_fn)(struct kmem_cache *);
 			union {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2c39f187cbb..87c06e342e05 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2719,9 +2719,6 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 		cancel_charge(memcg, nr_pages);
 		return -ENOMEM;
 	}
-
-	page->mem_cgroup = memcg;
-
 	return 0;
 }
 
@@ -2744,8 +2741,10 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
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
@@ -3238,7 +3237,7 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 		memcg_offline_kmem(memcg);
 
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
-		memcg_destroy_kmem_caches(memcg);
+		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
diff --git a/mm/slab.c b/mm/slab.c
index 14466a73d057..171b21ca617f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1389,7 +1389,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 								int nodeid)
 {
 	struct page *page;
-	int nr_pages;
 
 	flags |= cachep->allocflags;
 
@@ -1404,12 +1403,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
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
@@ -1438,7 +1425,7 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	page->mapping = NULL;
 
 	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += nr_freed;
+		current->reclaim_state->reclaimed_slab += 1 << order;
 	memcg_uncharge_slab(page, order, cachep);
 	__free_pages(page, order);
 }
diff --git a/mm/slab.h b/mm/slab.h
index 4a261c97c138..1f49945f5c1d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -173,7 +173,9 @@ void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
 void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
+void kmemcg_cache_shutdown(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
+void kmemcg_queue_cache_shutdown(struct kmem_cache *s);
 
 struct seq_file;
 struct file;
@@ -274,19 +276,65 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s->memcg_params.root_cache;
 }
 
+static __always_inline void kmemcg_cache_get_many(struct kmem_cache *s, long n)
+{
+	atomic_long_add(n, &s->memcg_params.refcnt);
+}
+
+static __always_inline void kmemcg_cache_put_many(struct kmem_cache *s, long n)
+{
+	if (atomic_long_sub_and_test(n, &s->memcg_params.refcnt))
+		kmemcg_queue_cache_shutdown(s);
+}
+
 static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
 {
-	if (is_root_cache(s))
+	int idx = (s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
+	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
+	int ret;
+
+	if (is_root_cache(s)) {
+		mod_node_page_state(page_pgdat(page), idx, 1 << order);
 		return 0;
-	return memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
+	}
+
+	memcg = s->memcg_params.memcg;
+	ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
+	if (!ret) {
+		lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
+		mod_lruvec_state(lruvec, idx, 1 << order);
+
+		/* transer try_charge() page references to kmem_cache */
+		kmemcg_cache_get_many(s, 1 << order);
+		css_put_many(&memcg->css, 1 << order);
+	}
+
+	return 0;
 }
 
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 						struct kmem_cache *s)
 {
-	memcg_kmem_uncharge(page, order);
+	int idx = (s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
+	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
+
+	if (is_root_cache(s)) {
+		mod_node_page_state(page_pgdat(page), idx, -(1 << order));
+		return;
+	}
+
+	memcg = s->memcg_params.memcg;
+	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
+	mod_lruvec_state(lruvec, idx, -(1 << order));
+	memcg_kmem_uncharge_memcg(page, order, memcg);
+
+	kmemcg_cache_put_many(s, 1 << order);
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 4e5b4292a763..3fdd02979a1c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -148,6 +148,7 @@ static int init_memcg_params(struct kmem_cache *s,
 		s->memcg_params.root_cache = root_cache;
 		INIT_LIST_HEAD(&s->memcg_params.children_node);
 		INIT_LIST_HEAD(&s->memcg_params.kmem_caches_node);
+		atomic_long_set(&s->memcg_params.refcnt, 1);
 		return 0;
 	}
 
@@ -225,6 +226,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 	if (is_root_cache(s)) {
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
+		css_get(&memcg->css);
 		s->memcg_params.memcg = memcg;
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
@@ -240,6 +242,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
+		css_put(&s->memcg_params.memcg->css);
 	}
 }
 #else
@@ -703,21 +706,19 @@ static void kmemcg_after_rcu_workfn(struct work_struct *work)
 
 	s->memcg_params.work_fn(s);
 	s->memcg_params.work_fn = NULL;
+	kmemcg_cache_put_many(s, 1);
 
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
 	put_online_cpus();
-
-	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
-	css_put(&s->memcg_params.memcg->css);
 }
 
 /*
  * We need to grab blocking locks.  Bounce to ->work.  The
  * work item shares the space with the RCU head and can't be
- * initialized eariler.
-*/
+ * initialized earlier.
+ */
 static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
 {
 	struct kmem_cache *s = container_of(head, struct kmem_cache,
@@ -727,6 +728,21 @@ static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
 	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
 }
 
+static void kmemcg_cache_shutdown_after_rcu(struct kmem_cache *s)
+{
+	WARN_ON(shutdown_cache(s));
+}
+
+void kmemcg_queue_cache_shutdown(struct kmem_cache *s)
+{
+	if (s->memcg_params.root_cache->memcg_params.dying)
+		return;
+
+	WARN_ON(s->memcg_params.work_fn);
+	s->memcg_params.work_fn = kmemcg_cache_shutdown_after_rcu;
+	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
+}
+
 static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
 	__kmemcg_cache_deactivate_after_rcu(s);
@@ -739,9 +755,6 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		return;
 
-	/* pin memcg so that @s doesn't get destroyed in the middle */
-	css_get(&s->memcg_params.memcg->css);
-
 	WARN_ON_ONCE(s->memcg_params.work_fn);
 	s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
@@ -775,28 +788,6 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 	put_online_cpus();
 }
 
-void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
-{
-	struct kmem_cache *s, *s2;
-
-	get_online_cpus();
-	get_online_mems();
-
-	mutex_lock(&slab_mutex);
-	list_for_each_entry_safe(s, s2, &memcg->kmem_caches,
-				 memcg_params.kmem_caches_node) {
-		/*
-		 * The cgroup is about to be freed and therefore has no charges
-		 * left. Hence, all its caches must be empty by now.
-		 */
-		BUG_ON(shutdown_cache(s));
-	}
-	mutex_unlock(&slab_mutex);
-
-	put_online_mems();
-	put_online_cpus();
-}
-
 static int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	struct memcg_cache_array *arr;
diff --git a/mm/slub.c b/mm/slub.c
index 195f61785c7d..a28b3b3abf29 100644
--- a/mm/slub.c
+++ b/mm/slub.c
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
@@ -1730,11 +1725,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 			check_object(s, page, p, SLUB_RED_INACTIVE);
 	}
 
-	mod_lruvec_page_state(page,
-		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		-pages);
-
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
 
@@ -4037,18 +4027,8 @@ void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
 	/*
 	 * Called with all the locks held after a sched RCU grace period.
-	 * Even if @s becomes empty after shrinking, we can't know that @s
-	 * doesn't have allocations already in-flight and thus can't
-	 * destroy @s until the associated memcg is released.
-	 *
-	 * However, let's remove the sysfs files for empty caches here.
-	 * Each cache has a lot of interface files which aren't
-	 * particularly useful for empty draining caches; otherwise, we can
-	 * easily end up with millions of unnecessary sysfs files on
-	 * systems which have a lot of memory and transient cgroups.
 	 */
-	if (!__kmem_cache_shrink(s))
-		sysfs_slab_remove(s);
+	__kmem_cache_shrink(s);
 }
 
 void __kmemcg_cache_deactivate(struct kmem_cache *s)
-- 
2.20.1

