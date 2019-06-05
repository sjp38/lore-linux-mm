Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20BC1C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B63162070D
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="XG1fZDQ/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B63162070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AC426B026F; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 581F86B0270; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3650C6B0273; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C11A6B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v205so5739710ywb.11
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=pBwyrsC3xS2PmE3Fb9BbKTWT0q0/P4Hp2VaXNFe4hs0=;
        b=IaKToa/RohHGbQnWssfoVKSXOr3VZV7GWFBd5k/s5cVRpgUIUPTb5X5uu05w6H5WA6
         WZKUtyPViuG5ae7FlfuOg8nh9UyFgH3ojvBYt0P/r+gr66XnutofnlrrE7/MbAyMcBUg
         9kYY6dztPI4bxKt/QFDUrlFKZ6U4nsmm/3fIcDSV/aADVNT1swCAEibdahGyVm5DWf5O
         ToB8eoW0kK3exfHAWHHWALinfl+XoA7nOigN3rltXPMQfJo9IxxdcVfGr+dyWmrz4t9D
         RCNcNteXMFRPs+KnTXHU6GN6740Z8NcoTQnEKRClqySNhJBdgH9ddlfPHAedgTyjem7n
         g2fg==
X-Gm-Message-State: APjAAAUzi8ytEiZn1lo971Aavlsx2vtFi456WVmA44otGfrPzPaueNNC
	Mpv2RlyEuc464NJ3jtHKaHGpQMBqyhFZjM6ArtPMupV9dfCxIAHXnf7Ii/ykI7BgdA3euwCgiMF
	1hWqOHkeM7QKyN15nprH9Kr5fUO1w0ka98d2HcPU9Yccuma4xVCXMf5xGo5WP6Lz2tA==
X-Received: by 2002:a81:30c9:: with SMTP id w192mr10434761yww.371.1559702702744;
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLhf6C8AF+dn4M3gYpLRFswQMLZFVQoKVt49+9hC1KoStIYtr7ckprSpZZa7Up0SDUdOqF
X-Received: by 2002:a81:30c9:: with SMTP id w192mr10434728yww.371.1559702701458;
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702701; cv=none;
        d=google.com; s=arc-20160816;
        b=J1kGX/AQac6pIjTmA+BgtU+7LRO1m9Kt/qKkP6HHQ8Ph8thhKBfljx1wfNyAGe22PH
         NDTtJnQjThVKmshLd+7JavxDlFkoKS3Obg0rkl+akk6WAMCbWbAgHMWdMvLzdIAPQyJm
         VaF5g3Bk15BxcH01CgfhF8OHzD55YQtB/iY5GsM7lS9YMLcmzicY9VHjFOCP60DDKbtk
         D9K+6sr8SALf3e/XMrBHsjYc0z759opZ5Yg0mv319ziWjimeieXCeD8CcN3cpgO8nNmT
         vJypToxY28MhWjiUD0kDbEnCNJZNBHAfvuOC9q62wbDU7HjrWiKy9TXDYGdzxUJbCs/x
         orlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=pBwyrsC3xS2PmE3Fb9BbKTWT0q0/P4Hp2VaXNFe4hs0=;
        b=sTrEdzDbyQbuHucU3CQNbsxLddZcWtBMsEVAqvCxt0FeS1DrKGOciiwyvR7IRbDIxN
         09xYjlq14kdiSzQsKok3hKIpFnUhoVpC08idoJK09KbSXssKzv/1l/5XF8LmcqdCupLJ
         AiwuPsDc9JCF2qiWUG6lox8VfkWuKItDmdW322DlnK08tm4i8OM2zWvN3qWFQ43C6iRJ
         gHDKh9FthHTFbu6JRqpoycjEOuHzMWlQD2w3SZafCnQzppZMt4uSDLjc9y3XR3NJlZaL
         JL64eahKNEuT48XJljY+AEPWQzIFhAdfZ/RbFOyf5/xphP/Bbld1ycJ2ZwZXNQiJBPWJ
         s2rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="XG1fZDQ/";
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e193si5953493ybh.416.2019.06.04.19.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="XG1fZDQ/";
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552glB3011319
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=pBwyrsC3xS2PmE3Fb9BbKTWT0q0/P4Hp2VaXNFe4hs0=;
 b=XG1fZDQ/VA/ty89WTMMiqHp0JJ3swFVe+4qf2QbZNoJY4fle/+lofAoPp4keSSC3Mapc
 JpBYgVQ6P405BKXa6ppg1BMRF57YiWhPmAGJo0eEajTbSyzr6bX8IuxQFvqwCKOdoyj4
 Za0G0aaLyviWCKsu+XXybzejJ2fE/hJhXMY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2swxuq1615-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:01 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 4 Jun 2019 19:44:59 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 947D512C7FDD0; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 08/10] mm: rework non-root kmem_cache lifecycle management
Date: Tue, 4 Jun 2019 19:44:52 -0700
Message-ID: <20190605024454.1393507-9-guro@fb.com>
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

Currently each charged slab page holds a reference to the cgroup to
which it's charged. Kmem_caches are held by the memcg and are released
all together with the memory cgroup. It means that none of kmem_caches
are released unless at least one reference to the memcg exists, which
is very far from optimal.

Let's rework it in a way that allows releasing individual kmem_caches
as soon as the cgroup is offline, the kmem_cache is empty and there
are no pending allocations.

To make it possible, let's introduce a new percpu refcounter for
non-root kmem caches. The counter is initialized to the percpu mode,
and is switched to the atomic mode during kmem_cache deactivation. The
counter is bumped for every charged page and also for every running
allocation. So the kmem_cache can't be released unless all allocations
complete.

To shutdown non-active empty kmem_caches, let's reuse the work queue,
previously used for the kmem_cache deactivation. Once the reference
counter reaches 0, let's schedule an asynchronous kmem_cache release.

* I used the following simple approach to test the performance
(stolen from another patchset by T. Harding):

    time find / -name fname-no-exist
    echo 2 > /proc/sys/vm/drop_caches
    repeat 10 times

Results:

        orig		patched

real	0m1.455s	real	0m1.355s
user	0m0.206s	user	0m0.219s
sys	0m0.855s	sys	0m0.807s

real	0m1.487s	real	0m1.699s
user	0m0.221s	user	0m0.256s
sys	0m0.806s	sys	0m0.948s

real	0m1.515s	real	0m1.505s
user	0m0.183s	user	0m0.215s
sys	0m0.876s	sys	0m0.858s

real	0m1.291s	real	0m1.380s
user	0m0.193s	user	0m0.198s
sys	0m0.843s	sys	0m0.786s

real	0m1.364s	real	0m1.374s
user	0m0.180s	user	0m0.182s
sys	0m0.868s	sys	0m0.806s

real	0m1.352s	real	0m1.312s
user	0m0.201s	user	0m0.212s
sys	0m0.820s	sys	0m0.761s

real	0m1.302s	real	0m1.349s
user	0m0.205s	user	0m0.203s
sys	0m0.803s	sys	0m0.792s

real	0m1.334s	real	0m1.301s
user	0m0.194s	user	0m0.201s
sys	0m0.806s	sys	0m0.779s

real	0m1.426s	real	0m1.434s
user	0m0.216s	user	0m0.181s
sys	0m0.824s	sys	0m0.864s

real	0m1.350s	real	0m1.295s
user	0m0.200s	user	0m0.190s
sys	0m0.842s	sys	0m0.811s

So it looks like the difference is not noticeable in this test.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  3 +-
 mm/memcontrol.c      | 51 +++++++++++++++++++++-------
 mm/slab.h            | 45 +++++++------------------
 mm/slab_common.c     | 79 ++++++++++++++++++++++++++------------------
 4 files changed, 100 insertions(+), 78 deletions(-)

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
index 3427396da612..49084e2d81ff 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2591,12 +2591,13 @@ static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
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
@@ -2631,6 +2632,7 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
+	struct memcg_cache_array *arr;
 	int kmemcg_id;
 
 	VM_BUG_ON(!is_root_cache(cachep));
@@ -2638,14 +2640,29 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
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
+
+	arr = rcu_dereference(cachep->memcg_params.memcg_caches);
 
-	memcg_cachep = cache_from_memcg_idx(cachep, kmemcg_id);
-	if (likely(memcg_cachep))
-		return memcg_cachep;
+	/*
+	 * Make sure we will access the up-to-date value. The code updating
+	 * memcg_caches issues a write barrier to match this (see
+	 * memcg_create_kmem_cache()).
+	 */
+	smp_rmb();
+	memcg_cachep = READ_ONCE(arr->entries[kmemcg_id]);
 
 	/*
 	 * If we are in a safe context (can wait, and not in interrupt
@@ -2658,10 +2675,20 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	 * memcg_create_kmem_cache, this means no further allocation
 	 * could happen with the slab_mutex held. So it's better to
 	 * defer everything.
+	 *
+	 * If the memcg is dying or memcg_cache is about to be released,
+	 * don't bother creating new kmem_caches. Because memcg_cachep
+	 * is ZEROed as the fist step of kmem offlining, we don't need
+	 * percpu_ref_tryget_live() here. css_tryget_online() check in
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
+	rcu_read_unlock();
 	return cachep;
 }
 
@@ -2672,7 +2699,7 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 	if (!is_root_cache(cachep))
-		css_put(&cachep->memcg_params.memcg->css);
+		percpu_ref_put(&cachep->memcg_params.refcnt);
 }
 
 /**
@@ -3219,7 +3246,7 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 		memcg_offline_kmem(memcg);
 
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
-		memcg_destroy_kmem_caches(memcg);
+		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 345fb59afb8f..5d2b8511e6fb 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -248,32 +248,6 @@ static inline const char *cache_name(struct kmem_cache *s)
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
-	smp_rmb();
-	cachep = READ_ONCE(arr->entries[idx]);
-	rcu_read_unlock();
-
-	return cachep;
-}
-
 static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	if (is_root_cache(s))
@@ -285,14 +259,25 @@ static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
 {
+	int ret;
+
 	if (is_root_cache(s))
 		return 0;
-	return memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
+
+	ret = memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
+	if (ret)
+		return ret;
+
+	percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
+
+	return 0;
 }
 
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 						struct kmem_cache *s)
 {
+	if (!is_root_cache(s))
+		percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
 	memcg_kmem_uncharge(page, order);
 }
 
@@ -324,12 +309,6 @@ static inline const char *cache_name(struct kmem_cache *s)
 	return s->name;
 }
 
-static inline struct kmem_cache *
-cache_from_memcg_idx(struct kmem_cache *s, int idx)
-{
-	return NULL;
-}
-
 static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	return s;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2914a8f0aa85..8255283025e3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -132,6 +132,8 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 LIST_HEAD(slab_root_caches);
 static DEFINE_SPINLOCK(memcg_kmem_wq_lock);
 
+static void kmemcg_cache_shutdown(struct percpu_ref *percpu_ref);
+
 void slab_init_memcg_params(struct kmem_cache *s)
 {
 	s->memcg_params.root_cache = NULL;
@@ -146,6 +148,12 @@ static int init_memcg_params(struct kmem_cache *s,
 	struct memcg_cache_array *arr;
 
 	if (root_cache) {
+		int ret = percpu_ref_init(&s->memcg_params.refcnt,
+					  kmemcg_cache_shutdown,
+					  0, GFP_KERNEL);
+		if (ret)
+			return ret;
+
 		s->memcg_params.root_cache = root_cache;
 		INIT_LIST_HEAD(&s->memcg_params.children_node);
 		INIT_LIST_HEAD(&s->memcg_params.kmem_caches_node);
@@ -171,6 +179,8 @@ static void destroy_memcg_params(struct kmem_cache *s)
 {
 	if (is_root_cache(s))
 		kvfree(rcu_access_pointer(s->memcg_params.memcg_caches));
+	else
+		percpu_ref_exit(&s->memcg_params.refcnt);
 }
 
 static void free_memcg_params(struct rcu_head *rcu)
@@ -226,6 +236,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 	if (is_root_cache(s)) {
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
+		css_get(&memcg->css);
 		s->memcg_params.memcg = memcg;
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
@@ -241,6 +252,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
+		css_put(&s->memcg_params.memcg->css);
 	}
 }
 #else
@@ -686,7 +698,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	}
 
 	/*
-	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
+	 * Since readers won't lock (see memcg_kmem_get_cache()), we need a
 	 * barrier here to ensure nobody will see the kmem_cache partially
 	 * initialized.
 	 */
@@ -711,14 +723,12 @@ static void kmemcg_workfn(struct work_struct *work)
 	mutex_lock(&slab_mutex);
 
 	s->memcg_params.work_fn(s);
+	s->memcg_params.work_fn = NULL;
 
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
 	put_online_cpus();
-
-	/* done, put the ref from kmemcg_cache_deactivate() */
-	css_put(&s->memcg_params.memcg->css);
 }
 
 static void kmemcg_rcufn(struct rcu_head *head)
@@ -735,10 +745,39 @@ static void kmemcg_rcufn(struct rcu_head *head)
 	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
 }
 
+static void kmemcg_cache_shutdown_fn(struct kmem_cache *s)
+{
+	WARN_ON(shutdown_cache(s));
+}
+
+static void kmemcg_cache_shutdown(struct percpu_ref *percpu_ref)
+{
+	struct kmem_cache *s = container_of(percpu_ref, struct kmem_cache,
+					    memcg_params.refcnt);
+	unsigned long flags;
+
+	spin_lock_irqsave(&memcg_kmem_wq_lock, flags);
+	if (s->memcg_params.root_cache->memcg_params.dying)
+		goto unlock;
+
+	WARN_ON(s->memcg_params.work_fn);
+	s->memcg_params.work_fn = kmemcg_cache_shutdown_fn;
+	INIT_WORK(&s->memcg_params.work, kmemcg_workfn);
+	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
+
+unlock:
+	spin_unlock_irqrestore(&memcg_kmem_wq_lock, flags);
+}
+
+static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
+{
+	__kmemcg_cache_deactivate_after_rcu(s);
+	percpu_ref_kill(&s->memcg_params.refcnt);
+}
+
 static void kmemcg_cache_deactivate(struct kmem_cache *s)
 {
-	if (WARN_ON_ONCE(is_root_cache(s)) ||
-	    WARN_ON_ONCE(s->memcg_params.work_fn))
+	if (WARN_ON_ONCE(is_root_cache(s)))
 		return;
 
 	__kmemcg_cache_deactivate(s);
@@ -747,10 +786,8 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		goto unlock;
 
-	/* pin memcg so that @s doesn't get destroyed in the middle */
-	css_get(&s->memcg_params.memcg->css);
-
-	s->memcg_params.work_fn = __kmemcg_cache_deactivate_after_rcu;
+	WARN_ON_ONCE(s->memcg_params.work_fn);
+	s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_rcufn);
 unlock:
 	spin_unlock_irq(&memcg_kmem_wq_lock);
@@ -784,28 +821,6 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
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
-- 
2.20.1

