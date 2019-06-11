Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BAECC31E46
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAD932173C
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LSsD9PMp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAD932173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 375826B0272; Tue, 11 Jun 2019 19:18:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 288E36B0274; Tue, 11 Jun 2019 19:18:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1FAF6B0272; Tue, 11 Jun 2019 19:18:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A586B6B0274
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:18:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so9360370pfc.2
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=wvy1LTE78mhoSYH9KKkPh58hA9wYMnN4JWdHvONVtxM=;
        b=iic3lCOgjxWFiTCxaWN00l2M6VnoZ7t4Pi07M95DbmMrWJiduQKjfclsoo4j/zS4Nx
         mSSDqAw0UAzzbyEfqyQu/bEVpJy04r+UJZRde6Q9kTJX/I0s2NHEXrFjpcnhn0YtZqJg
         Td7U+c6UIY37zTDH8Sj96fAurY7pHifO19EuQqwF4a1qLIHcQRXNfO3WF38/PJOOjk9o
         0czbOvJHy4OEAfv+amUbBM85aDuNSY87I/+IJhsHlKSXxrVYKHwxyzbP9nnQ0fPlEW5d
         KFmBOYp+F1KeBGmQpKzH2JHv0UulcZ1TmZGR6YxIx32tmGQDHGLeRMbAhpz552VylBuQ
         mDsw==
X-Gm-Message-State: APjAAAU8N+/rDOnDsgGCz7YLalaXij3JYwSNSd4Yox1x2qzZxe5wYng4
	KWyL0KYL6DQh09Ktlg5M4/y0yJTLiKUhSYju6Q7vVLZnGntk+Jd0wVbN6shmkVb6b5fIMf+++jU
	LcxFPntsp26qimm70SkxTL17K1uG/aRciv8e8z8qyK2dNNuFt2Phn5Vtt8ot1BfI8yA==
X-Received: by 2002:a62:1c91:: with SMTP id c139mr75443181pfc.25.1560295115326;
        Tue, 11 Jun 2019 16:18:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn+awHncTrAOI6CJKRImoccRicBgTyuLYR4dMiQvJKQ7xkZuaGqv14u3qH05ErQ1tovzIw
X-Received: by 2002:a62:1c91:: with SMTP id c139mr75443077pfc.25.1560295113817;
        Tue, 11 Jun 2019 16:18:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560295113; cv=none;
        d=google.com; s=arc-20160816;
        b=aTI4eEW7BlQjFWgP7x4Itt3mgBCzYEUAfN0yVgKX8XxRVEnk+E1vZhXmudNQ1wR8Iq
         m0oRsVJ4XSFZ+KYgWjKNCTwYKDE7PTQNfRc1vABRT4ZY7TOIH7zkyjIsy831bs/bJTQu
         XDDFXsluPEqDxuTZvQeBTMMq1TlC8xaOHsdIetbm1qP2ugPee8rEce94RSYte4+CkOqw
         Rn3w+FL/y2UarAonm+rJKBWQ0RCgp3lN1G1IzPGz/7dOhLk11wIDBacLKLD1B+ln5JcR
         PrO1lJNHmHzY112y0vCewgoQip1D7issnkYMu5dDTNgbKRu/b1wUt319bSTOThfOOPHq
         lYEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=wvy1LTE78mhoSYH9KKkPh58hA9wYMnN4JWdHvONVtxM=;
        b=PWSBj+sSQw4bIwiTyv+QED9BOzQniymmsztfrHFIMpZXfRgx6esjPQId46PZtb9YtK
         jZZ9KMR5F8qIEqdn6sOBqCxsGmbKYlpAzYP1OWOggrbEPAzEv71QfZwEJRo6JelrTUuF
         YaehGzFEq8NHs/zjZoLcMkdAgAr0ndu2Z80OqwoWxdJh/BMledMd6eHJmFwxHoh3J28Y
         lCPNbyORXf7ztswElf5uM9LqTVX4IMC96k9lGJ+i3Inx08KxBhLIMMoPgTgnSOQ+v/XV
         3jWnpDrlQIlVgil56RXioXvlIKXIbGP/ZSkJ3wuC0GKiGaP6HklWmG9PJp6kg+lAQvLn
         4J/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LSsD9PMp;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y17si13090218plp.59.2019.06.11.16.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 16:18:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LSsD9PMp;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BN9aF7031322
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:33 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=wvy1LTE78mhoSYH9KKkPh58hA9wYMnN4JWdHvONVtxM=;
 b=LSsD9PMpW8fbsnC/E4xQtfhl4K7ThMyR8L2jfRX5XAtFIJOzguxeNNi20t8xHS9gi+AF
 BoQ1bcDQMVcFdpTOHkadn/SrIM943nw0YShfdEIhZGgfvOY9IyTTPxkQGU+OqKGycW/M
 WTHtfuR62ysJI/7iNO7NcLAL+qauqwy8VMk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t2ha1926c-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:33 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 11 Jun 2019 16:18:22 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 30FC6130CBF6B; Tue, 11 Jun 2019 16:18:20 -0700 (PDT)
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
Subject: [PATCH v7 03/10] mm: generalize postponed non-root kmem_cache deactivation
Date: Tue, 11 Jun 2019 16:18:06 -0700
Message-ID: <20190611231813.3148843-4-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190611231813.3148843-1-guro@fb.com>
References: <20190611231813.3148843-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-11_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110151
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
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
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
index 7ef695b91919..dc83583ee9dd 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -172,6 +172,7 @@ int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
@@ -290,8 +291,6 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 
 extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
-extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-				void (*work_fn)(struct kmem_cache *));
 
 #else /* CONFIG_MEMCG_KMEM */
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 99489d82ba78..5e7638f495d1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -708,7 +708,7 @@ static void kmemcg_workfn(struct work_struct *work)
 	put_online_mems();
 	put_online_cpus();
 
-	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
+	/* done, put the ref from kmemcg_cache_deactivate() */
 	css_put(&s->memcg_params.memcg->css);
 }
 
@@ -726,31 +726,21 @@ static void kmemcg_rcufn(struct rcu_head *head)
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
 
@@ -773,7 +763,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		if (!c)
 			continue;
 
-		__kmemcg_cache_deactivate(c);
+		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
@@ -866,11 +856,10 @@ static void flush_memcg_workqueue(struct kmem_cache *s)
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
2.21.0

