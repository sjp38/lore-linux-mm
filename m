Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B58C9C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D05D20851
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="rGwlcvcn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D05D20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC7C66B0276; Tue,  4 Jun 2019 22:45:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4F406B0277; Tue,  4 Jun 2019 22:45:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A405F6B0278; Tue,  4 Jun 2019 22:45:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6836B0276
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:10 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id w127so21464926ywe.6
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=F5q0Ous8JMckUZTK0P//WSX11GdeHQH8mlJbfSlHdWk=;
        b=sOPrx0y1t2UkRaFkO8GDMmFXOVzd8J7vSPHuAj6lOVciAItas3pXYEnA0KA2ZIMRUD
         eM/KsWCBevvDtQ5FzrQ7+qVfL2ySHGwbgEgZfTZHmG+xzqSigEU2fn3BGqsrVHc/8QRv
         3usjDZOpSrr/zym422CTeWtGEg3Dtw8TIAItlN+xc4Rti3HtStiVig+2sEHvv5cXkZjL
         8gOWXoa9bunF/T2ezkltLi5zefaI5wNvu2tTuGPI3PaxxJBZxnpFvRuKAjuNvDz9Fbpd
         ZTNjzC5sZCE4lgFyqygCT86dCP1AMN4m7Y6bdL9voBCaSe3mpWRLBx0Gvn2ac6URdEom
         cY8w==
X-Gm-Message-State: APjAAAVldtCM+iL/wcLlamFVWsksYeg3myrEr+qINpFLAI1WyeL6hzLa
	92ktvFLyExLWGmySMbBxbfqDKVHrd+jnPxpxPezz3HJ8otwhxvCdsJaQsPi8Gb8v4kb8G4epNh3
	IkrgjBnH6n0Civ3j9ulw3zuAG3+MqbUdbm/x8aDsByNYFBZkT/fKdzYvh6dMmPz6vww==
X-Received: by 2002:a81:195:: with SMTP id 143mr3001040ywb.147.1559702710183;
        Tue, 04 Jun 2019 19:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYljq+4AdaxqZA6y/1sabcbDQdD9x8cA22hMKMG8hZnypL5xCeXsRqFbMrC8SzcF2F+SMB
X-Received: by 2002:a81:195:: with SMTP id 143mr3000798ywb.147.1559702701793;
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702701; cv=none;
        d=google.com; s=arc-20160816;
        b=xNjcOF1ShBT7ffVx3n8wHN2LMmbQFSUYawOwFKrCfeDpr0MolCjtOy0XsFJ8l48mPA
         0kTrswGzKf1/HeCJz7hYfGd4AIWFQQcxG90mh5Tte4z0T3hFFrz+RMPGoY7nBtJWDH+v
         7I15M+cwDhsDcRRQ0+1deR7EtOAVE+AzDL0w2QfNrNco3DHPKC3d4BcV7xmE/9fKBCA6
         NrmV10EPAVvifzyG5E2hqL2epXwGCZ+481olWtGhHhdCqo4xzJERVuYdfPmLK3gxKpwZ
         2VHQFEurhgHD95Dq4VrmsPZe2NIdBU13Dpw+/e0zzGOv/0xvQCzEmJwZIWBdZI23gWKc
         jS7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=F5q0Ous8JMckUZTK0P//WSX11GdeHQH8mlJbfSlHdWk=;
        b=Rm0064ydAI8MBZnwh91nUTcoypYf4llHV7sOOfNtrSDf76+azA6LeL5Xa6NoGkrJA/
         P4BddJQFNJOCsEz3I1aXDMaLi0utpv0Be09SzpAUBh3j+DxS1Lq8OGwNmV3d867zl/si
         QK0QLh4AYEgu8Z9F1tsBptKcQ0znw8ouqPwthCYC/QU17wxkVchu9zhWFY9sEN/tWJzb
         1ImK4em9D4X9l63Ibk4gZeCpsXIzb05iUjSZlwnGcy45t28WQhvPvK1eo6dIcwx7FCi4
         29w0xoorWGbCHJvuRoUwXQvUAEQiPVnT8PiPZtdGX+5KlnnlbQkqkeEP46hfGRwPjynG
         mYqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rGwlcvcn;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q186si5644616ybq.473.2019.06.04.19.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rGwlcvcn;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552hZuX009253
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=F5q0Ous8JMckUZTK0P//WSX11GdeHQH8mlJbfSlHdWk=;
 b=rGwlcvcnL/0ke9glhflkD/OtcJdh+z/2LjCHptAG7F8zR31PfCGh0rUOenA1vqf1cWBS
 8M9UDjRc+tWJqZUSzyZU29ji1mlBYCu7A4DKB0wTNDS+9HHBMnOGksYaLVfq4nJpmkx2
 70iuLK1pb9QrdvTjyUSoLU9r4H5GH2KYWBg= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sx0j78sds-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:01 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:44:59 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 7FB4112C7FDC6; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 03/10] mm: rename slab delayed deactivation functions and fields
Date: Tue, 4 Jun 2019 19:44:47 -0700
Message-ID: <20190605024454.1393507-4-guro@fb.com>
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

The delayed work/rcu deactivation infrastructure of non-root
kmem_caches can be also used for asynchronous release of these
objects. Let's get rid of the word "deactivation" in corresponding
names to make the code look better after generalization.

It's easier to make the renaming first, so that the generalized
code will look consistent from scratch.

Let's rename struct memcg_cache_params fields:
  deact_fn -> work_fn
  deact_rcu_head -> rcu_head
  deact_work -> work

And RCU/delayed work callbacks in slab common code:
  kmemcg_deactivate_rcufn -> kmemcg_rcufn
  kmemcg_deactivate_workfn -> kmemcg_workfn

This patch contains no functional changes, only renamings.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  6 +++---
 mm/slab.h            |  2 +-
 mm/slab_common.c     | 30 +++++++++++++++---------------
 3 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..47923c173f30 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -642,10 +642,10 @@ struct memcg_cache_params {
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
 
-			void (*deact_fn)(struct kmem_cache *);
+			void (*work_fn)(struct kmem_cache *);
 			union {
-				struct rcu_head deact_rcu_head;
-				struct work_struct deact_work;
+				struct rcu_head rcu_head;
+				struct work_struct work;
 			};
 		};
 	};
diff --git a/mm/slab.h b/mm/slab.h
index c16e5af0fb59..8ff90f42548a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -292,7 +292,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-				void (*deact_fn)(struct kmem_cache *));
+				void (*work_fn)(struct kmem_cache *));
 
 #else /* CONFIG_MEMCG_KMEM */
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 77df6029de8e..d019ee66bdc4 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -692,17 +692,17 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	put_online_cpus();
 }
 
-static void kmemcg_deactivate_workfn(struct work_struct *work)
+static void kmemcg_workfn(struct work_struct *work)
 {
 	struct kmem_cache *s = container_of(work, struct kmem_cache,
-					    memcg_params.deact_work);
+					    memcg_params.work);
 
 	get_online_cpus();
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
-	s->memcg_params.deact_fn(s);
+	s->memcg_params.work_fn(s);
 
 	mutex_unlock(&slab_mutex);
 
@@ -713,36 +713,36 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
 	css_put(&s->memcg_params.memcg->css);
 }
 
-static void kmemcg_deactivate_rcufn(struct rcu_head *head)
+static void kmemcg_rcufn(struct rcu_head *head)
 {
 	struct kmem_cache *s = container_of(head, struct kmem_cache,
-					    memcg_params.deact_rcu_head);
+					    memcg_params.rcu_head);
 
 	/*
-	 * We need to grab blocking locks.  Bounce to ->deact_work.  The
+	 * We need to grab blocking locks.  Bounce to ->work.  The
 	 * work item shares the space with the RCU head and can't be
 	 * initialized eariler.
 	 */
-	INIT_WORK(&s->memcg_params.deact_work, kmemcg_deactivate_workfn);
-	queue_work(memcg_kmem_cache_wq, &s->memcg_params.deact_work);
+	INIT_WORK(&s->memcg_params.work, kmemcg_workfn);
+	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
 }
 
 /**
  * slab_deactivate_memcg_cache_rcu_sched - schedule deactivation after a
  *					   sched RCU grace period
  * @s: target kmem_cache
- * @deact_fn: deactivation function to call
+ * @work_fn: deactivation function to call
  *
- * Schedule @deact_fn to be invoked with online cpus, mems and slab_mutex
+ * Schedule @work_fn to be invoked with online cpus, mems and slab_mutex
  * held after a sched RCU grace period.  The slab is guaranteed to stay
- * alive until @deact_fn is finished.  This is to be used from
+ * alive until @work_fn is finished.  This is to be used from
  * __kmemcg_cache_deactivate().
  */
 void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-					   void (*deact_fn)(struct kmem_cache *))
+					   void (*work_fn)(struct kmem_cache *))
 {
 	if (WARN_ON_ONCE(is_root_cache(s)) ||
-	    WARN_ON_ONCE(s->memcg_params.deact_fn))
+	    WARN_ON_ONCE(s->memcg_params.work_fn))
 		return;
 
 	if (s->memcg_params.root_cache->memcg_params.dying)
@@ -751,8 +751,8 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
-	s->memcg_params.deact_fn = deact_fn;
-	call_rcu(&s->memcg_params.deact_rcu_head, kmemcg_deactivate_rcufn);
+	s->memcg_params.work_fn = work_fn;
+	call_rcu(&s->memcg_params.rcu_head, kmemcg_rcufn);
 }
 
 void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
-- 
2.20.1

