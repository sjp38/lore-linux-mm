Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33B73C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFA3C2070D
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="N1ORyrtC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFA3C2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BAB66B026C; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81FBF6B0273; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A9146B026C; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 099D36B026F
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f1so17652532pfb.0
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=RAtQP8kdt+P/ff/UupI77hj0Bc++zM2YWzYBwAXPM6o=;
        b=oiO7sHPhVVXZZ1VgRQWwVsW2EsUgkRhhGfN7HvAqSp2Nj3RtXYqoEYFX3Bbwg9kOld
         F4xinnGjaIf1q3EXfwsdZ9X64erkYkzsjiPg5U4ZiS7MXFaiAtMEwS+IuPByCKrNaIWR
         v7wYK6z4YQ01K285DGccN1gq0110ynAzxEO0IfxfJA/0euoL5ct/VuvpfRJMkX7lImHi
         5Khrq1BqnmBlsygSnkXvJhvZoCgCGptNaYgSVacns3sZ28dXcX1zstR+ZY/M8yb9qrM8
         wmQjaDZ1kAMuc6PEQ/J8A/B5a8fCPLBWQNatJqcW5kw6viU2Y+olbImiAnss4+C8xDX8
         MGuw==
X-Gm-Message-State: APjAAAWd3KYsF1uVssvZNl65QQmvsYhkgJpaEDQ8khnoieJEHzLsBsz+
	w4+vvK46FLdM6o9INsdqitxu3bvr+dV1UNEcnAZx8sDI7qdbRZYsBOnoP5CpcGUBT2m+lcBrMyx
	tjwX2hNtiwkpRUSqarICrchcBqGAfox9QgiFb15INkjZeRMMadh38SZQILs9TrD5D5w==
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr20692505pje.14.1559702702500;
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYyM8hOd559tYZfftEdIgrdCLUgEYngBp5A4sgeEdrOZap2vQAwY+SuXuwZzzOYLf+NCie
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr20692438pje.14.1559702701355;
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702701; cv=none;
        d=google.com; s=arc-20160816;
        b=H+rJaIHf2HTW90kKFViyLaK1B4UsKQV2F4KlQlq6TimQDW3bi7tkLmHA7wytoVCdFk
         TFzdf4ywqhqUkbuAKlahpRMXx404L6TqMkYLuL+s05797ZURjdIZGxqpNpilnIezfMbz
         jhIBdm21xJQ+B82H4iZXc1tVZV2qoF302br5GbDno7JFENVEbkkt0JAWTBj50TLy1lPE
         8N0+U0fr/3WJhfbUsE2g8sHgvTTN6qyaLEN9Z2pEVRIW9YVGzM5pukzvv+p2GIu/6kOf
         xwLia2Xt73hRDmCMqNnVvs2ij0mXbrdkjpJZseuEzPnLn7HeymT0ixwHNgfZ1muQZwTp
         JvDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=RAtQP8kdt+P/ff/UupI77hj0Bc++zM2YWzYBwAXPM6o=;
        b=bEXZOeyF8sYM56cn3RLhAeAsUc33fT7FXa/ol1nQplo/CEUPGKqdzPzsQzmS9YRKwS
         VMMNdGi2Cwhs61fGRSa7OWebp7ckfbVOEKWgjsfm+i/O8wSRbkTBqEtAmGp3RRBgDNBa
         rWYyOW84iFuCotToUMA4WjfyP/Ak7lQ9mpndQAd/qXmtR5vDV8eU3A7C3hlYxmHX1ikY
         V6LQnSQyeICLUMYYyA1vacMyyv5OSou+/fJ1loF9j7ZFRC5E2q1aTgOzZl2RLMd1zPvw
         lm0kbO+D+B8Z16FTHOAx9jfhf6tz3VYcT6t5wp/A+/C6JgTkrZxJqacoD3kosLmupgJO
         Oz6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=N1ORyrtC;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a14si22826742pgm.206.2019.06.04.19.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=N1ORyrtC;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552hPgg011960
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=RAtQP8kdt+P/ff/UupI77hj0Bc++zM2YWzYBwAXPM6o=;
 b=N1ORyrtCMpqM8ArTqyLILrOwr/rNYmMHMW9zOhG/NRyrlupsDadIRbH+Gt2zpNdLeTHX
 6UchQ5coq6wyjYdFSjdBnNAWvDe9iDo/95rKavvBdoQXJ/GeLh+EHLugjQxPcLLLU5BB
 wHHKtT2bs17nxlMXfdM9vV2V0bZEmZnb0uA= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sx00b8y22-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:00 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 4 Jun 2019 19:44:59 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 8FE2012C7FDCE; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 07/10] mm: synchronize access to kmem_cache dying flag using a spinlock
Date: Tue, 4 Jun 2019 19:44:51 -0700
Message-ID: <20190605024454.1393507-8-guro@fb.com>
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
 mlxlogscore=755 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the memcg_params.dying flag and the corresponding
workqueue used for the asynchronous deactivation of kmem_caches
is synchronized using the slab_mutex.

It makes impossible to check this flag from the irq context,
which will be required in order to implement asynchronous release
of kmem_caches.

So let's switch over to the irq-save flavor of the spinlock-based
synchronization.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/slab_common.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 09b26673b63f..2914a8f0aa85 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -130,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 #ifdef CONFIG_MEMCG_KMEM
 
 LIST_HEAD(slab_root_caches);
+static DEFINE_SPINLOCK(memcg_kmem_wq_lock);
 
 void slab_init_memcg_params(struct kmem_cache *s)
 {
@@ -629,6 +630,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	struct memcg_cache_array *arr;
 	struct kmem_cache *s = NULL;
 	char *cache_name;
+	bool dying;
 	int idx;
 
 	get_online_cpus();
@@ -640,7 +642,13 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	 * The memory cgroup could have been offlined while the cache
 	 * creation work was pending.
 	 */
-	if (memcg->kmem_state != KMEM_ONLINE || root_cache->memcg_params.dying)
+	if (memcg->kmem_state != KMEM_ONLINE)
+		goto out_unlock;
+
+	spin_lock_irq(&memcg_kmem_wq_lock);
+	dying = root_cache->memcg_params.dying;
+	spin_unlock_irq(&memcg_kmem_wq_lock);
+	if (dying)
 		goto out_unlock;
 
 	idx = memcg_cache_id(memcg);
@@ -735,14 +743,17 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 
 	__kmemcg_cache_deactivate(s);
 
+	spin_lock_irq(&memcg_kmem_wq_lock);
 	if (s->memcg_params.root_cache->memcg_params.dying)
-		return;
+		goto unlock;
 
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
 	s->memcg_params.work_fn = __kmemcg_cache_deactivate_after_rcu;
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_rcufn);
+unlock:
+	spin_unlock_irq(&memcg_kmem_wq_lock);
 }
 
 void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
@@ -852,9 +863,9 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 
 static void flush_memcg_workqueue(struct kmem_cache *s)
 {
-	mutex_lock(&slab_mutex);
+	spin_lock_irq(&memcg_kmem_wq_lock);
 	s->memcg_params.dying = true;
-	mutex_unlock(&slab_mutex);
+	spin_unlock_irq(&memcg_kmem_wq_lock);
 
 	/*
 	 * SLAB and SLUB deactivate the kmem_caches through call_rcu. Make
-- 
2.20.1

