Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12321C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DBA120873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="m876/u6F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DBA120873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2CB6B0007; Tue, 14 May 2019 17:54:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3E586B0008; Tue, 14 May 2019 17:54:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C680C6B000A; Tue, 14 May 2019 17:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8FA6B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:54:59 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j62so652936ywe.3
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=OF8Q5UJujq3yq2uD1iW8qmk3bJXNnU37f/2il/QOiA0=;
        b=ZXWLyPSk32BSCqqPrjaWJyfMyDn1GEhF018KBBAUwBdEuKM48SiJg4EmvBMsaWIWZF
         1dOy/nCiUafSixXvokvRzSzPFlUXzOOeXr7de3OTkiZgBHCwr2Tq4HTAOiZkX/PZ5DKj
         P6UYOdu8Hl8d9eT9+QKckZPO/8eZgmMmVxPlP25MMWkp2OdNfdehFu551BCakpl1ZO8V
         ORvZTQbyokbzl3+3KhPuITSjXwQFTuli2U67vdQm5Ev9DD0k7S99yibUW7Ba1cskjf8y
         DdkLNenoWgnnPtOLW7XPGYfnLPL6pPDf2pNt34MhtzD0pzJ141do5ZPX6nlub+DbQxIQ
         QD/w==
X-Gm-Message-State: APjAAAVZdSz38D+wxtyPOx4B2W0PMjmU9q4dzmKAB4JbeSaXfaoNJy0m
	7UhlrZPnaYaShOJejYfYn5mhT//udR7H6e+bqETwSe3hWCpqIi42nLW6ur+3eu2IjPRGQJpb+tv
	3mcRO9SMMuxJa8SXsvmw5OFg2C3RLpwBkfppBtK93Hl6ehf8GZZ2bTUf11qgYdFaNHg==
X-Received: by 2002:a25:c68b:: with SMTP id k133mr19367182ybf.28.1557870899308;
        Tue, 14 May 2019 14:54:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdU67pefbfP85M3Xmbt8RQFkBXF6kzedxNCftpEqk6leAJSjMiULERzxnPIGFPivikj2Ah
X-Received: by 2002:a25:c68b:: with SMTP id k133mr19367148ybf.28.1557870897968;
        Tue, 14 May 2019 14:54:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557870897; cv=none;
        d=google.com; s=arc-20160816;
        b=vkTwS5APG61SYPoGRk/hgG2NwQJhEacEVz/rYOPRfagNjpmrZT+7dybOrocPma8SKv
         5ogjXH04YdK4/pAEI9NaZDG0XhogTD84BtAtnIsh+gGUhfHbKGNl1X47atdrtPyKBKHh
         kszaWYcgZCVv0OfS0gFB+Q+jc/PAGl9wJl4b2q3OUWaYL5OK3EpdKAsTdzTi5TmYI3En
         9AdUqXWUjpZr85q1DVrWrl1QppH+otNdopc7BxehCkivSCpRBr5fM/2dapM1DeylzPsN
         +y/rNAoCTi89FnlStfAB9rE1ypW8PaQ2fDczeJQ30MoluHN3WA6pf6ef2EIIsZ6IxSmS
         N3WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=OF8Q5UJujq3yq2uD1iW8qmk3bJXNnU37f/2il/QOiA0=;
        b=QaDnNcNkm8l/y4SuQs5DGq9E1G/fWs1hsh3aihrZ43keakCB0VwRUAKvgcB4QrTRct
         NkkIVD//3p00HeKPXeRhyZWBMKCWNt/ceRx8mKO3GPROJVpU1HD7s9vUoiMLLDxTevHE
         AIMDJy2TeHOfw3XhlIAIbaD7ODcCR8TbuCQCr1VohzJJnQ2qf5zuTeUxmdhX6fHOdRKx
         RIW2gAiO3MeHTeGyP6tp4vESIm87Ob0UcdL49FDf22BFjOBDSiwNpyjfTMoBYR6vPJNA
         RFUVLSA14WzHNTaB8M/gGp+axta4UNT+KukvTAqOEILH282N9S5/um6Yj4jpZ9P93rff
         LbOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="m876/u6F";
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q186si5465093ybq.441.2019.05.14.14.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:54:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="m876/u6F";
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4ELsDhT030316
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=OF8Q5UJujq3yq2uD1iW8qmk3bJXNnU37f/2il/QOiA0=;
 b=m876/u6FGdaFtFpk93N4Z/widucDQg2dlLtOb44CCUjBZQVpDD4TBt1B0ivodDbcbEiM
 Zhy3PZLK/7yZT9FrCINw1nxfJoYS+qa+np6uTrd4Y/9RhdaTCTyiQgmFEZhAWp0v2XdU
 w6igW7jzl+jfl+I1QOYDqWH7+9BI9MGl9Kw= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sg0pkhatf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:57 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 14 May 2019 14:54:56 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 88A1F120772AC; Tue, 14 May 2019 14:39:41 -0700 (PDT)
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
Subject: [PATCH v4 5/7] mm: rework non-root kmem_cache lifecycle management
Date: Tue, 14 May 2019 14:39:38 -0700
Message-ID: <20190514213940.2405198-6-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190514213940.2405198-1-guro@fb.com>
References: <20190514213940.2405198-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140144
X-FB-Internal: deliver
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
    repeat 10 times

Results (I've chosen best results in several runs):

        orig		patched

real	0m0.648s	real	0m0.593s
user	0m0.148s	user	0m0.162s
sys	0m0.295s	sys	0m0.253s

real	0m0.581s	real	0m0.649s
user	0m0.119s	user	0m0.136s
sys	0m0.254s	sys	0m0.250s

real	0m0.645s	real	0m0.705s
user	0m0.138s	user	0m0.138s
sys	0m0.263s	sys	0m0.250s

real	0m0.691s	real	0m0.718s
user	0m0.139s	user	0m0.134s
sys	0m0.262s	sys	0m0.253s

real	0m0.654s	real	0m0.715s
user	0m0.146s	user	0m0.128s
sys	0m0.247s	sys	0m0.261s

real	0m0.675s	real	0m0.717s
user	0m0.129s	user	0m0.137s
sys	0m0.277s	sys	0m0.248s

real	0m0.631s	real	0m0.719s
user	0m0.137s	user	0m0.134s
sys	0m0.255s	sys	0m0.251s

real	0m0.622s	real	0m0.715s
user	0m0.108s	user	0m0.124s
sys	0m0.279s	sys	0m0.264s

real	0m0.651s	real	0m0.669s
user	0m0.139s	user	0m0.139s
sys	0m0.252s	sys	0m0.247s

real	0m0.671s	real	0m0.632s
user	0m0.130s	user	0m0.139s
sys	0m0.263s	sys	0m0.245s

So it looks like the difference is not noticeable in this test.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  3 +-
 mm/memcontrol.c      | 57 +++++++++++++++++++++---------
 mm/slab.h            | 82 +++++++++++++++++++++++++-------------------
 mm/slab_common.c     | 74 +++++++++++++++++++++++----------------
 mm/slub.c            | 12 +------
 5 files changed, 135 insertions(+), 93 deletions(-)

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
index b2c39f187cbb..413cef3d8369 100644
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
@@ -2677,10 +2693,20 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	 * memcg_create_kmem_cache, this means no further allocation
 	 * could happen with the slab_mutex held. So it's better to
 	 * defer everything.
+	 *
+	 * If the memcg is dying or memcg_cache is about to be released,
+	 * don't bother creating new kmem_caches. Because memcg_cachep
+	 * is ZEROed as the fist step of kmem offlining, we don't need
+	 * percpu_ref_tryget() here. css_tryget_online() check in
+	 * memcg_schedule_kmem_cache_create() will prevent us from
+	 * creation of a new kmem_cache.
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
 
@@ -2691,7 +2717,7 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 	if (!is_root_cache(cachep))
-		css_put(&cachep->memcg_params.memcg->css);
+		percpu_ref_put(&cachep->memcg_params.refcnt);
 }
 
 /**
@@ -2719,9 +2745,6 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 		cancel_charge(memcg, nr_pages);
 		return -ENOMEM;
 	}
-
-	page->mem_cgroup = memcg;
-
 	return 0;
 }
 
@@ -2744,8 +2767,10 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
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
@@ -3238,7 +3263,7 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 		memcg_offline_kmem(memcg);
 
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
-		memcg_destroy_kmem_caches(memcg);
+		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
diff --git a/mm/slab.h b/mm/slab.h
index c9a31120fa1d..b86744c58702 100644
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
@@ -280,19 +256,49 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s->memcg_params.root_cache;
 }
 
+/*
+ * Charge the slab page belonging to the non-root kmem_cache.
+ * Can be called for non-root kmem_caches only.
+ */
 static __always_inline int memcg_charge_slab(struct page *page,
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
 
+/*
+ * Uncharge a slab page belonging to a non-root kmem_cache.
+ * Can be called for non-root kmem_caches only.
+ */
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
@@ -362,18 +368,24 @@ static __always_inline int charge_slab_page(struct page *page,
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
index 4e5b4292a763..1ee967b4805e 100644
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
@@ -130,6 +132,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 #ifdef CONFIG_MEMCG_KMEM
 
 LIST_HEAD(slab_root_caches);
+static DEFINE_SPINLOCK(memcg_kmem_wq_lock);
 
 void slab_init_memcg_params(struct kmem_cache *s)
 {
@@ -145,6 +148,12 @@ static int init_memcg_params(struct kmem_cache *s,
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
@@ -170,6 +179,8 @@ static void destroy_memcg_params(struct kmem_cache *s)
 {
 	if (is_root_cache(s))
 		kvfree(rcu_access_pointer(s->memcg_params.memcg_caches));
+	else
+		percpu_ref_exit(&s->memcg_params.refcnt);
 }
 
 static void free_memcg_params(struct rcu_head *rcu)
@@ -225,6 +236,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 	if (is_root_cache(s)) {
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
+		css_get(&memcg->css);
 		s->memcg_params.memcg = memcg;
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
@@ -240,6 +252,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
+		css_put(&s->memcg_params.memcg->css);
 	}
 }
 #else
@@ -708,16 +721,13 @@ static void kmemcg_after_rcu_workfn(struct work_struct *work)
 
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
@@ -727,9 +737,31 @@ static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
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
+	spin_lock(&memcg_kmem_wq_lock);
+	if (s->memcg_params.root_cache->memcg_params.dying)
+		goto unlock;
+
+	WARN_ON(s->memcg_params.work_fn);
+	s->memcg_params.work_fn = kmemcg_cache_shutdown_after_rcu;
+	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
+unlock:
+	spin_unlock(&memcg_kmem_wq_lock);
+}
+
 static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
 	__kmemcg_cache_deactivate_after_rcu(s);
+	percpu_ref_kill(&s->memcg_params.refcnt);
 }
 
 static void kmemcg_cache_deactivate(struct kmem_cache *s)
@@ -739,9 +771,6 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		return;
 
-	/* pin memcg so that @s doesn't get destroyed in the middle */
-	css_get(&s->memcg_params.memcg->css);
-
 	WARN_ON_ONCE(s->memcg_params.work_fn);
 	s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
@@ -775,28 +804,6 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
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
@@ -854,8 +861,15 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 
 static void flush_memcg_workqueue(struct kmem_cache *s)
 {
+	/*
+	 * memcg_params.dying is synchronized using slab_mutex AND
+	 * memcg_kmem_wq_lock spinlock, because it's not always
+	 * possible to grab slab_mutex.
+	 */
 	mutex_lock(&slab_mutex);
+	spin_lock(&memcg_kmem_wq_lock);
 	s->memcg_params.dying = true;
+	spin_unlock(&memcg_kmem_wq_lock);
 	mutex_unlock(&slab_mutex);
 
 	/*
diff --git a/mm/slub.c b/mm/slub.c
index 13e415cc71b7..0a4ddbeb5ca6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4018,18 +4018,8 @@ void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
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

