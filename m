Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D3A5C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBA762070D
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="V/rfOhOR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBA762070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A84D6B0269; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07B0B6B026C; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD49C6B026F; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id A96E56B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id r142so13485057ybc.0
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Wv6PULr08vn6aMDCf+MGkZnKQqchIV9NxQ/kg/T87Dk=;
        b=WSIjup7FOcTC+Tmg2uQ2FW/C0OwKwpY4Tk3/5Pi9zBkm8oflEdQCYiXccHzVrsEOt+
         LuznMPTzALwuXrQiJEIhXslJCkke8sXfSirdzK6jrCPylTjcCJ2sbXIoXpK1MuEW4A7f
         keOuzWfFrpXql0bv7eSLdA0UqvYiwfT9XRscMABonldf93URTDnKZfzSOzwUwdv4AJ0O
         mIsQVKe6ur3eEtXGSgoYL9Qw3uJogrdBt4Q0+YtKutdQz49TeoeT+0DMZf2zXDAxU58c
         4YsxHutaHlvQSmxBwfjhoawSkM74hmZylfR5TmG5r7rEtfDVy1xlMuZ3XVppk1x9rhmg
         zKGQ==
X-Gm-Message-State: APjAAAWxzaJ+SF6zHh/EpF09eP5E/WsPeWOxBbF6PflVzXc6NxxxhB2o
	9uac7lSO2jZkBJdWZay5isiPj6944su/3TsRhQ/POc90tBuBswbuhPCiLBkvj56NnZnX3NVDVZD
	TzXCnsHjBgRDbPPYymfttqDa/0DhHh1W5XcUPWSC+fYB7gPa4rA4l1MQRVWaNL5PKhw==
X-Received: by 2002:a25:7712:: with SMTP id s18mr16798462ybc.263.1559702702382;
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVHgSK3pAWuth2y0YUg7NEIFi83mVc0Vat/UV4kTJDC8YKoYgZS2+QPYXn+lGIIoNgcXlS
X-Received: by 2002:a25:7712:: with SMTP id s18mr16798443ybc.263.1559702701526;
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702701; cv=none;
        d=google.com; s=arc-20160816;
        b=iiTOjFCuSUiuDB2jkRcRRz3/5nYI7zQ6N+AgnKevESm678ASOjOiA2KEKA2dF7F/z5
         dlPc64wuB7fJmAIH7eW64xjP64pbOwnbZMumDa5aNS4IR/ncJ4OLiHTzPO2o61GA5Ihx
         xjp0Ch2NhULvNh8i/f5Twy62QLFi09Ae6+hGFkh4Sib7wkVAE05e2f/eCNnawy/Kqdbd
         LuOs7Ts8K8t89fnmkSAD9Ob7Xpd80NWgfWINj6IVtLZQ318XutRnxzIY9VDQtwyE+LbH
         7B4qvOdYB4Hjwb7Eflxt303PsLxtb3xFmKullu5skrl8ZOsagZcsDoP3qskkXYm7wBKQ
         mPzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Wv6PULr08vn6aMDCf+MGkZnKQqchIV9NxQ/kg/T87Dk=;
        b=UzJ8VXKUmef4goUbGlEeLmnDLVOKQf++5HkLO6LEeOnjjYkq23FlbD+ARFPJ7brWyj
         7HOI2/8I8ShPnLyxw1EX4poedwK1G1dmczWgFBdnl+4HJ6A2a0ac2K5HcEQ+jLXEIw43
         gDHm4ehhnUD2tQRYKxeeFudnx6k0o0bE5vkVjrp5/V31U88MkfUdlb27qY5f1lFz6C8a
         9tZVjXKi38JPy61sBoHqAS7etC4gXqNK/z5ZKuYX+nr0n98+dxP+rC1UwWPqkdsis/X3
         OR7YE4Nfy0EmQMQCqG4MMkhYf67T5K+BFfD+k/9+aFFMaApjvWMJvDcAP5CvBkfSzKGQ
         /Nzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="V/rfOhOR";
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v12si5275432ybm.290.2019.06.04.19.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="V/rfOhOR";
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552hgSe023104
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Wv6PULr08vn6aMDCf+MGkZnKQqchIV9NxQ/kg/T87Dk=;
 b=V/rfOhOR1cl30AcZIOb+eG4ipiYWLHfyERFMHlNPGsiZBivqkgrS4m8TeWLxuBcEBrhb
 bn0jJ8hPEKWkfBLiKHf+V2jlKxFpIYFrpbU4y2/Bv/+V/1ZOoQLbdiPZLFx0WnL4pKKA
 +zFdPCbi0Pbd17HY3nQV4JDVBeGyKiU2+n4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sx41n84vs-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:01 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:44:59 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 83CC012C7FDC8; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 04/10] mm: generalize postponed non-root kmem_cache deactivation
Date: Tue, 4 Jun 2019 19:44:48 -0700
Message-ID: <20190605024454.1393507-5-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190605024454.1393507-1-guro@fb.com>
References: <20190605024454.1393507-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently SLUB uses a work scheduled after an RCU grace period
to deactivate a non-root kmem_cache. This mechanism can be reused
for kmem_caches release, but requires generalization for SLAB
case.

Introduce kmemcg_cache_deactivate() function, which calls
allocator-specific __kmem_cache_deactivate() and schedules
execution of __kmem_cache_deactivate_after_rcu() with all
necessary locks in a worker context after an rcu grace period.

Here is the new calling scheme:
  kmemcg_cache_deactivate()
    __kmemcg_cache_deactivate()                  SLAB/SLUB-specific
    kmemcg_rcufn()                               rcu
      kmemcg_workfn()                            work
        __kmemcg_cache_deactivate_after_rcu()    SLAB/SLUB-specific

instead of:
  __kmemcg_cache_deactivate()                    SLAB/SLUB-specific
    slab_deactivate_memcg_cache_rcu_sched()      SLUB-only
      kmemcg_rcufn()                             rcu
        kmemcg_workfn()                          work
          kmemcg_cache_deact_after_rcu()         SLUB-only

For consistency, all allocator-specific functions start with "__".

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/slab.c        |  4 ++++
 mm/slab.h        |  3 +--
 mm/slab_common.c | 27 ++++++++-------------------
 mm/slub.c        |  8 +-------
 4 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a4091f8b3655..4b865393ebb4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2252,6 +2252,10 @@ void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
 {
 	__kmem_cache_shrink(cachep);
 }
+
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
+{
+}
 #endif
 
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index 8ff90f42548a..d35d85794247 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -172,6 +172,7 @@ int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
@@ -291,8 +292,6 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 
 extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
-extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-				void (*work_fn)(struct kmem_cache *));
 
 #else /* CONFIG_MEMCG_KMEM */
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d019ee66bdc4..09b26673b63f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -709,7 +709,7 @@ static void kmemcg_workfn(struct work_struct *work)
 	put_online_mems();
 	put_online_cpus();
 
-	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
+	/* done, put the ref from kmemcg_cache_deactivate() */
 	css_put(&s->memcg_params.memcg->css);
 }
 
@@ -727,31 +727,21 @@ static void kmemcg_rcufn(struct rcu_head *head)
 	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
 }
 
-/**
- * slab_deactivate_memcg_cache_rcu_sched - schedule deactivation after a
- *					   sched RCU grace period
- * @s: target kmem_cache
- * @work_fn: deactivation function to call
- *
- * Schedule @work_fn to be invoked with online cpus, mems and slab_mutex
- * held after a sched RCU grace period.  The slab is guaranteed to stay
- * alive until @work_fn is finished.  This is to be used from
- * __kmemcg_cache_deactivate().
- */
-void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-					   void (*work_fn)(struct kmem_cache *))
+static void kmemcg_cache_deactivate(struct kmem_cache *s)
 {
 	if (WARN_ON_ONCE(is_root_cache(s)) ||
 	    WARN_ON_ONCE(s->memcg_params.work_fn))
 		return;
 
+	__kmemcg_cache_deactivate(s);
+
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		return;
 
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
-	s->memcg_params.work_fn = work_fn;
+	s->memcg_params.work_fn = __kmemcg_cache_deactivate_after_rcu;
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_rcufn);
 }
 
@@ -774,7 +764,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		if (!c)
 			continue;
 
-		__kmemcg_cache_deactivate(c);
+		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
@@ -867,11 +857,10 @@ static void flush_memcg_workqueue(struct kmem_cache *s)
 	mutex_unlock(&slab_mutex);
 
 	/*
-	 * SLUB deactivates the kmem_caches through call_rcu. Make
+	 * SLAB and SLUB deactivate the kmem_caches through call_rcu. Make
 	 * sure all registered rcu callbacks have been invoked.
 	 */
-	if (IS_ENABLED(CONFIG_SLUB))
-		rcu_barrier();
+	rcu_barrier();
 
 	/*
 	 * SLAB and SLUB create memcg kmem_caches through workqueue and SLUB
diff --git a/mm/slub.c b/mm/slub.c
index 9cb2eef62a37..ae3b1e49ecec 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4022,7 +4022,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 }
 
 #ifdef CONFIG_MEMCG
-static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
 	/*
 	 * Called with all the locks held after a sched RCU grace period.
@@ -4048,12 +4048,6 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 */
 	slub_set_cpu_partial(s, 0);
 	s->min_partial = 0;
-
-	/*
-	 * s->cpu_partial is checked locklessly (see put_cpu_partial), so
-	 * we have to make sure the change is visible before shrinking.
-	 */
-	slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
 }
 #endif	/* CONFIG_MEMCG */
 
-- 
2.20.1

