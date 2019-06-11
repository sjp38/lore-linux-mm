Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 513B3C31E44
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07CC221734
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="A657KbJo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07CC221734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAF5D6B026C; Tue, 11 Jun 2019 19:18:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B60A36B026D; Tue, 11 Jun 2019 19:18:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C9036B026E; Tue, 11 Jun 2019 19:18:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62D5C6B026C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:18:30 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id f69so14383168ywb.21
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Xx5Luiw4ossPD+e7sUfpgznJxtqNhDquLK7q4vM5gv8=;
        b=ij0cJvRF+zNTBSr1c32DcWrLVEaT6W47q9ZlynnIdIa8ucb5+sRzufdmi4KxLxm4qF
         vOT2+DYbIe24Z9iWvADew7prXnLWOLk5UE3PG0Y1dBVJ767kKGoMYjaiTtlwpPsw2oHo
         8A03jnbspFTbeWHCbxTaoJOp8b6uFBPsImffuMWdRRIzq/6gwEQnzyEzsEHaTZq1C4oT
         NQmof/ODT+zDjc2ACMQWPFbSZBgzvmOo5KYWny1wqo5UfRQ2/R/TGOwlkyZPmyQuv+/q
         gUo6tP4PHGeUcW2pRBZyz/nU+StbtH4aMHWiwcJ/36FipoaHijX7QXKXxyyNj6edwbL8
         opwA==
X-Gm-Message-State: APjAAAXW4wo+5XtsS5FPZke/hAQNrx/UvN74Q3BJFYdUPMIxoRl37Ute
	VOq1lBBRMleiFyn/cB8elbIiSCEMkuS/nBbZpcvEZgzU2r+rf+jsm/CU7Lrw/NIZbVfbjoo5tb1
	ElXItTH11XwTNcQpZkYstFbMHGDiKlcEG1CGBRJ4XvWxHDoQhbSACkv2/jE1OeYFWwA==
X-Received: by 2002:a0d:ea91:: with SMTP id t139mr34324223ywe.119.1560295110164;
        Tue, 11 Jun 2019 16:18:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6TKAD3z5VX7b8LMuSxS38UkUZxM1H2yRWKran40pPt0SoA2E3SrofMaYtJBXNuJ2Ay5wt
X-Received: by 2002:a0d:ea91:: with SMTP id t139mr34324203ywe.119.1560295109655;
        Tue, 11 Jun 2019 16:18:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560295109; cv=none;
        d=google.com; s=arc-20160816;
        b=EAjdyKsKT5z6zMX6EK8FJRlvqnZ+Xl+846X5B2Qw5R+d5jyg3UciwuZwyJZrb9uwxc
         jGExaQ7xCaW5IAU7CPLM6/lcTRSRDL8Pxno075ZvBKC7POxQnyzzVGLyYH8VEGumRwZ3
         u6ijlWYn9L/Q9MqrzMY0Qdz+Nuka4Bedc8Op8/eykR4JegiLyEXUuZySlXG3dh9NrBGF
         kjxzjH8HUxUn/eXxCKAeWUDwhIggqGMq4zGOL0q/4eS0PiXhFfSjTF02FMh6p6qNy+8K
         vZ1w0tS3KRHMaMN4kgjhWJeGB2Pq1i3CObU0EfrWIR/7TibskihgHq9jsZhgWum+8YrX
         VF8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Xx5Luiw4ossPD+e7sUfpgznJxtqNhDquLK7q4vM5gv8=;
        b=oAqLPeoLkhsDYd55NTneW8WYyo80HagFsULvi1MpeXKZbqOyNlzvtG3HBmCrpfHfmW
         VOezkvkQH6KQVUL8wBJ1yyFdlgsLKmGckpKx1vePq1+6HutAtWOdBpOpBxTBdvuOjoGI
         fiFr1y9jwe28ysKVyc9ywkp0MHE+uGLcGHhnYygtfYHHgsrIct/QP5D5iu9/77DgKaaw
         nMd+jXqYfEN2RiPArsuUFbEPQy5x8IrLictAcW95v90IYppfWEPapEcSCNqCLRhNY4KF
         kMqLhMGsu/XM5Bwkxv1fMV5vWloVdpYaN48mSd7DMkjksTVbmF1DIP84tlMhR/rtlSe+
         w7QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=A657KbJo;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 206si4531913ywv.82.2019.06.11.16.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 16:18:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=A657KbJo;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BNBnDC008431
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Xx5Luiw4ossPD+e7sUfpgznJxtqNhDquLK7q4vM5gv8=;
 b=A657KbJouvq/Ev7aTKFK7x7621+5wRCN625mZI/d0duLQMf3Y0bLvGhFDQTyvbDjFDij
 I0L3vq6qbr2k/DGA8SpeLWInH4njDu4xksjnSt/AlX68oOG+nGwkwtx9ZsNp/0jmB2YT
 ftJFna0Bi2j88VEk1lI8RiIdyVr5ebgANFU= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2t2dkmsy3b-18
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:29 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 11 Jun 2019 16:18:21 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 42C22130CBF73; Tue, 11 Jun 2019 16:18:20 -0700 (PDT)
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
Subject: [PATCH v7 07/10] mm: synchronize access to kmem_cache dying flag using a spinlock
Date: Tue, 11 Jun 2019 16:18:10 -0700
Message-ID: <20190611231813.3148843-8-guro@fb.com>
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
 mlxlogscore=734 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110151
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
 mm/slab_common.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9383104651cd..1e5eaf84bf08 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -130,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 #ifdef CONFIG_MEMCG_KMEM
 
 LIST_HEAD(slab_root_caches);
+static DEFINE_SPINLOCK(memcg_kmem_wq_lock);
 
 void slab_init_memcg_params(struct kmem_cache *s)
 {
@@ -734,14 +735,22 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 
 	__kmemcg_cache_deactivate(s);
 
+	/*
+	 * memcg_kmem_wq_lock is used to synchronize memcg_params.dying
+	 * flag and make sure that no new kmem_cache deactivation tasks
+	 * are queued (see flush_memcg_workqueue() ).
+	 */
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
@@ -851,9 +860,9 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 
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
2.21.0

