Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8018FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:40:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 197B92173B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:40:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="o0f+49xS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 197B92173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D0F16B0008; Wed,  8 May 2019 16:40:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 659076B000A; Wed,  8 May 2019 16:40:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FA0A6B000C; Wed,  8 May 2019 16:40:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6F2C6B0008
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:40:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so82676plt.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=ilqSfy/vzYbKLUEqz87/KxpSAdY0RPIvj65efPUF4Qc=;
        b=pPVOFz9bl0ZCi0xd8jdQJOw4MV8D5y1bHxd6n+LaXiApYTnGpyGMMeoIw19NyUZO6Y
         soyAeLmShoYHhdp0xnvzwKkOj8FQJJ9CJiBH9Fd01tXlSrKs2YoPlKkRVQ7O8kVYKGaM
         IWwN7mD4QMEshCvhqnUcxP/hdjWBtNEdtraWujwJSmQftbcRfjD9/wsHEUhDHe6ABkcU
         Irsmxl//PrXNncI+oxJint8uF7Zv3sxvp4UjGojpAUY3/BwVkYief68qSkS4Sd61oZPz
         dRM+5xj3DdKcmFJvy+kap1Pko1uREYSKtqrZyW6X1PA/AaJg5AmKYMdJQEaPMHWSOsEk
         1OgA==
X-Gm-Message-State: APjAAAWMm+OslSbB5div+1AI01bc7qovUvou8vBlPn7SeaY5NOM1qVK9
	MUw+4wrW5A5mguOSoH17m11MhniA3kAG7m/X+ZbgFGgFbzAhyo7Xiu2k8VTquBu2B+q2CL9ke+/
	BMHhnBtIK2S2afuOHxWLT8fgWqh28gywzq8PcWZt0MjmM6MFTxwlmVHHA4hE+DgHCQA==
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr50195740plb.112.1557348051478;
        Wed, 08 May 2019 13:40:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQABqPfZTKtMfMnClQntPKkQ0sP+2akYf1GNmI3WzvQUeBXv9FAhJlH2ttqoH5Q04Qp1sy
X-Received: by 2002:a17:902:e305:: with SMTP id cg5mr50195615plb.112.1557348050131;
        Wed, 08 May 2019 13:40:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557348050; cv=none;
        d=google.com; s=arc-20160816;
        b=1CQaaPEmTC0Eymns6NtZ+lw3X2KAfxn6t94rYuCw1Pgyp8WnngZn8TxoyRqa3W0ViG
         pd+CI12XXN3iDmm5Xzz+f5TNFXco/MRTRZHmUhe5cRGFDcukJ4Stalccfmb56/0KmA+6
         G8qcApc/4KPR1vO4seFQe4/nH7X2tnhSJO1XGQW0CNxJCDRUUfPzdopLBYtiKRivjlNY
         IVkuAPv3wODtfG+pEfx16P35+mvEEYgFZU/cEOjuGYZEF6xYr6sXLnsyS1fqGpuIM7wd
         Kt5uoZLgPHL/f194Hf+1kQdam33ZlEfiKTQkJJuzRSTiIyeL8PUreEII+gv7sQVTv7Xl
         hD2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=ilqSfy/vzYbKLUEqz87/KxpSAdY0RPIvj65efPUF4Qc=;
        b=0CTc23D9Ephe6cwBdcU9Ibpy5iOTtW1hdTpBW+Gr9XQW61cy0FFh26s0P4SkPUn9Kg
         GzxmD99EA3nOiJPZHPUxj1rakEQfmiHvDwYMqvs4tCzJs2kVFLr5Hi+x57kpWdOAwCQy
         Uvv3Uj2cH5vdKU7w0sg4z8BHYbvlszuJRGc1LMGvob8suQFrCbqGSnEyA9jR3gsnOnsL
         8hCMuhFbNC0q0UpyPkxpzMGB47fwwOFDwCpwdalL56gydm0Sm4cYhRdUbGz5QR3wF1em
         NOT/w3YpAvbxmP0dtLFlobHfE9TbdAuKuBf//SV4RKlU96YkGGh6QhChqLvd4GKfUeVv
         80Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=o0f+49xS;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k8si24826007pll.318.2019.05.08.13.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:40:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=o0f+49xS;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KeVE5023320
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:40:49 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=ilqSfy/vzYbKLUEqz87/KxpSAdY0RPIvj65efPUF4Qc=;
 b=o0f+49xS8bphtjt/Jn0Dvo5dx7chjIKwbFZt4wT+gKLVPWA4hr9hq2axPQBL1r1MHQIt
 /ez1MVbqAF5LF9fSG1B0lxOf7hPdy1I4MH74h+j2nZEOD0Yxc8hF+p4qy79fOPoJevNn
 vZ8YNmjNKwJ2PE0pYufRmCYRRRKnfmjH2Rk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc0p91d9f-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:49 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 8 May 2019 13:40:48 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 14C9C11CDBD00; Wed,  8 May 2019 13:25:00 -0700 (PDT)
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
Subject: [PATCH v3 5/7] mm: rework non-root kmem_cache lifecycle management
Date: Wed, 8 May 2019 13:24:56 -0700
Message-ID: <20190508202458.550808-6-guro@fb.com>
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

This commit makes several important changes in the lifecycle
of a non-root kmem_cache, which also affect the lifecycle
of a memory cgroup.

Currently each charged slab page has a page->mem_cgroup pointer
to the memory cgroup and holds a reference to it.
Kmem_caches are held by the memcg and are released with it.
It means that none of kmem_caches are released unless at least one
reference to the memcg exists, which is not optimal.

So the current scheme can be illustrated as:
page->mem_cgroup->kmem_cache.

To implement the slab memory reparenting we need to invert the scheme
into: page->kmem_cache->mem_cgroup.

Let's make every page to hold a reference to the kmem_cache (we
already have a stable pointer), and make kmem_caches to hold a single
reference to the memory cgroup.

To make this possible we need to introduce a new percpu refcounter
for non-root kmem_caches. The counter is initialized to the percpu
mode, and is switched to atomic mode after deactivation, so we never
shutdown an active cache. The counter is bumped for every charged page
and also for every running allocation. So the kmem_cache can't
be released unless all allocations complete.

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

real	0m0.700s   0m0.722s
user	0m0.114s   0m0.120s
sys	0m0.317s   0m0.324s

real	0m0.729s   0m0.746s
user	0m0.110s   0m0.139s
sys	0m0.320s   0m0.317s

real	0m0.745s   0m0.719s
user	0m0.108s   0m0.124s
sys	0m0.320s   0m0.323s

So it looks like the difference is not noticeable in this test.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  3 +-
 mm/memcontrol.c      | 53 +++++++++++++++++++++----------
 mm/slab.h            | 74 +++++++++++++++++++++++---------------------
 mm/slab_common.c     | 63 +++++++++++++++++++------------------
 mm/slub.c            | 12 +------
 5 files changed, 112 insertions(+), 93 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 47923c173f30..1b54e5f83342 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -16,6 +16,7 @@
 #include <linux/overflow.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <linux/percpu-refcount.h>
 
 
 /*
@@ -152,7 +153,6 @@ int kmem_cache_shrink(struct kmem_cache *);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 void memcg_deactivate_kmem_caches(struct mem_cgroup *);
-void memcg_destroy_kmem_caches(struct mem_cgroup *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -641,6 +641,7 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
+			struct percpu_ref refcnt;
 
 			void (*work_fn)(struct kmem_cache *);
 			union {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2c39f187cbb..9b27988c8969 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2610,12 +2610,13 @@ static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 {
 	struct memcg_kmem_cache_create_work *cw;
 
+	if (!css_tryget_online(&memcg->css))
+		return;
+
 	cw = kmalloc(sizeof(*cw), GFP_NOWAIT | __GFP_NOWARN);
 	if (!cw)
 		return;
 
-	css_get(&memcg->css);
-
 	cw->memcg = memcg;
 	cw->cachep = cachep;
 	INIT_WORK(&cw->work, memcg_kmem_cache_create_func);
@@ -2651,20 +2652,35 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
 	int kmemcg_id;
+	struct memcg_cache_array *arr;
 
 	VM_BUG_ON(!is_root_cache(cachep));
 
 	if (memcg_kmem_bypass())
 		return cachep;
 
-	memcg = get_mem_cgroup_from_current();
+	rcu_read_lock();
+
+	if (unlikely(current->active_memcg))
+		memcg = current->active_memcg;
+	else
+		memcg = mem_cgroup_from_task(current);
+
+	if (!memcg || memcg == root_mem_cgroup)
+		goto out_unlock;
+
 	kmemcg_id = READ_ONCE(memcg->kmemcg_id);
 	if (kmemcg_id < 0)
-		goto out;
+		goto out_unlock;
 
-	memcg_cachep = cache_from_memcg_idx(cachep, kmemcg_id);
-	if (likely(memcg_cachep))
-		return memcg_cachep;
+	arr = rcu_dereference(cachep->memcg_params.memcg_caches);
+
+	/*
+	 * Make sure we will access the up-to-date value. The code updating
+	 * memcg_caches issues a write barrier to match this (see
+	 * memcg_create_kmem_cache()).
+	 */
+	memcg_cachep = READ_ONCE(arr->entries[kmemcg_id]);
 
 	/*
 	 * If we are in a safe context (can wait, and not in interrupt
@@ -2677,10 +2693,16 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	 * memcg_create_kmem_cache, this means no further allocation
 	 * could happen with the slab_mutex held. So it's better to
 	 * defer everything.
+	 *
+	 * If the memcg is dying or memcg_cache is about to be released,
+	 * don't bother creating new kmem_caches.
 	 */
-	memcg_schedule_kmem_cache_create(memcg, cachep);
-out:
-	css_put(&memcg->css);
+	if (unlikely(!memcg_cachep))
+		memcg_schedule_kmem_cache_create(memcg, cachep);
+	else if (percpu_ref_tryget(&memcg_cachep->memcg_params.refcnt))
+		cachep = memcg_cachep;
+out_unlock:
+	rcu_read_lock();
 	return cachep;
 }
 
@@ -2691,7 +2713,7 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 	if (!is_root_cache(cachep))
-		css_put(&cachep->memcg_params.memcg->css);
+		percpu_ref_put(&cachep->memcg_params.refcnt);
 }
 
 /**
@@ -2719,9 +2741,6 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 		cancel_charge(memcg, nr_pages);
 		return -ENOMEM;
 	}
-
-	page->mem_cgroup = memcg;
-
 	return 0;
 }
 
@@ -2744,8 +2763,10 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
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
@@ -3238,7 +3259,7 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 		memcg_offline_kmem(memcg);
 
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
-		memcg_destroy_kmem_caches(memcg);
+		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
diff --git a/mm/slab.h b/mm/slab.h
index c9a31120fa1d..2acc68a7e0a0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -173,6 +173,7 @@ void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
 void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
+void kmemcg_cache_shutdown(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
@@ -248,31 +249,6 @@ static inline const char *cache_name(struct kmem_cache *s)
 	return s->name;
 }
 
-/*
- * Note, we protect with RCU only the memcg_caches array, not per-memcg caches.
- * That said the caller must assure the memcg's cache won't go away by either
- * taking a css reference to the owner cgroup, or holding the slab_mutex.
- */
-static inline struct kmem_cache *
-cache_from_memcg_idx(struct kmem_cache *s, int idx)
-{
-	struct kmem_cache *cachep;
-	struct memcg_cache_array *arr;
-
-	rcu_read_lock();
-	arr = rcu_dereference(s->memcg_params.memcg_caches);
-
-	/*
-	 * Make sure we will access the up-to-date value. The code updating
-	 * memcg_caches issues a write barrier to match this (see
-	 * memcg_create_kmem_cache()).
-	 */
-	cachep = READ_ONCE(arr->entries[idx]);
-	rcu_read_unlock();
-
-	return cachep;
-}
-
 static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	if (is_root_cache(s))
@@ -284,15 +260,37 @@ static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
 {
-	if (is_root_cache(s))
-		return 0;
-	return memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
+	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
+	int ret;
+
+	memcg = s->memcg_params.memcg;
+	ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
+	if (ret)
+		return ret;
+
+	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
+	mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
+
+	/* transer try_charge() page references to kmem_cache */
+	percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
+	css_put_many(&memcg->css, 1 << order);
+
+	return 0;
 }
 
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 						struct kmem_cache *s)
 {
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
@@ -362,18 +360,24 @@ static __always_inline int charge_slab_page(struct page *page,
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
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 4e5b4292a763..995920222127 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -45,6 +45,8 @@ static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work);
 static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
 		    slab_caches_to_rcu_destroy_workfn);
 
+static void kmemcg_queue_cache_shutdown(struct percpu_ref *percpu_ref);
+
 /*
  * Set of flags that will prevent slab merging
  */
@@ -145,6 +147,12 @@ static int init_memcg_params(struct kmem_cache *s,
 	struct memcg_cache_array *arr;
 
 	if (root_cache) {
+		int ret = percpu_ref_init(&s->memcg_params.refcnt,
+					  kmemcg_queue_cache_shutdown,
+					  0, GFP_KERNEL);
+		if (ret)
+			return ret;
+
 		s->memcg_params.root_cache = root_cache;
 		INIT_LIST_HEAD(&s->memcg_params.children_node);
 		INIT_LIST_HEAD(&s->memcg_params.kmem_caches_node);
@@ -170,6 +178,8 @@ static void destroy_memcg_params(struct kmem_cache *s)
 {
 	if (is_root_cache(s))
 		kvfree(rcu_access_pointer(s->memcg_params.memcg_caches));
+	else
+		percpu_ref_exit(&s->memcg_params.refcnt);
 }
 
 static void free_memcg_params(struct rcu_head *rcu)
@@ -225,6 +235,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 	if (is_root_cache(s)) {
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
+		css_get(&memcg->css);
 		s->memcg_params.memcg = memcg;
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
@@ -240,6 +251,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
+		css_put(&s->memcg_params.memcg->css);
 	}
 }
 #else
@@ -708,16 +720,13 @@ static void kmemcg_after_rcu_workfn(struct work_struct *work)
 
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
@@ -727,9 +736,28 @@ static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
 	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
 }
 
+static void kmemcg_cache_shutdown_after_rcu(struct kmem_cache *s)
+{
+	WARN_ON(shutdown_cache(s));
+}
+
+static void kmemcg_queue_cache_shutdown(struct percpu_ref *percpu_ref)
+{
+	struct kmem_cache *s = container_of(percpu_ref, struct kmem_cache,
+					    memcg_params.refcnt);
+
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
+	percpu_ref_kill(&s->memcg_params.refcnt);
 }
 
 static void kmemcg_cache_deactivate(struct kmem_cache *s)
@@ -739,9 +767,6 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		return;
 
-	/* pin memcg so that @s doesn't get destroyed in the middle */
-	css_get(&s->memcg_params.memcg->css);
-
 	WARN_ON_ONCE(s->memcg_params.work_fn);
 	s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
@@ -775,28 +800,6 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
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
index 9ec25a588bdd..e7ce810ebd02 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4022,18 +4022,8 @@ void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
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

