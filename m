Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 689E2C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B04020873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:55:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="rQiUKzLp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B04020873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EAEF6B0006; Tue, 14 May 2019 17:54:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 675696B0007; Tue, 14 May 2019 17:54:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 454096B0008; Tue, 14 May 2019 17:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 056316B0006
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:54:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g38so368527pgl.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=aGRxiMv3PcI8LcBLMKV807UIVqUNvcuklnYvAN4lYgI=;
        b=Z8cYGWOf+YdKk/LAkSxY3kNWag5XYrFZOEcQOEYI96iVBFbw1IqRCXP8ndTvG8y8QP
         0Ll5xrR/C6KRygrvAf2FGNlQIdHUxwyUqlmjYXa/L7SSf53QfVVqhTHedjvGI9SmbQR5
         +c2yhhrcO42qsKAAcvKAv0ucttD6JGda+5p7Gfw6eXj0WLOjPitw2cK4Uu9/OQQ7rhqh
         9QS0Mbdz0RCLoLZgnZBXRGXU6Nu8G2m8dRXbpgtRAUvWd/vRy8z44t8YCH9B9kP5jH0A
         yDFTi4OkL44hya81RTNNHrxFRe7wOyhI51XbewhlZcedHDV9oJowFPsUoHJnX1N0A5uE
         DPog==
X-Gm-Message-State: APjAAAVI8wWfp/g2wJTgFe8KB8NltF6ka7YUrYYp8m75RdVn5D3V0NJg
	vvil8o8S8LY8KI89VdksrIPo2cEXDu9OQOAWfsO24rxIkd/ZBc9AWTICPKQYZskgnB7dmytMM8G
	V/EktsURpxi8VlhqHFyqAguyYHZwwM7mGb2xcFZOgKIe9ximQGIsgbZickQ3IOQk6Fg==
X-Received: by 2002:a63:fc55:: with SMTP id r21mr40008604pgk.441.1557870898628;
        Tue, 14 May 2019 14:54:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAFwwo3gqtM3vHfdE0ZrpK6MmRTe23pvV12xekZUPFpDzQVUMNkqEoKlBwOEEvYGzBhHtD
X-Received: by 2002:a63:fc55:: with SMTP id r21mr40008561pgk.441.1557870897629;
        Tue, 14 May 2019 14:54:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557870897; cv=none;
        d=google.com; s=arc-20160816;
        b=MnfnWdniTTZ0MSN8SuNqrduBhKqDN3vL+pkxEfWOlPVnyu6XBMXdJtFHsB4CiDRffG
         fYxiXrd3NwNbL7HhSVFQE4nHqyJyXIk6BV12KWSCD+So2ZMPLYh2GUgkBY05XzUZyhww
         RDx/18ssB2GuG1EX/X3fZ3xu671CAfeo89XXYtARecnAjt5q6BhbLPZ7apkczcYs1Da4
         arYvB7ILyOvIF9M4FHspRCfJM+BF856RSC6+RHmu7OwECDNjqzQYzjfxjBuP64HZ6tFp
         6wasXdWirxm7+d6pT2L2mcbavsMiStbwiAYzVGK4nf0k7Yppq7mJZTMG4REj2GZuQYWQ
         FOkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=aGRxiMv3PcI8LcBLMKV807UIVqUNvcuklnYvAN4lYgI=;
        b=gcoGLiYe7JUAGU464j6/Ky/6fCiNCYih6nZwxcT3y70XCuSA+4MspuzXbkJ7dDE1xJ
         aOR6WJjKeEW9i6X6BLb5d11Eb4+dJlju2SmY4+lTY1iUH96R7/cjNGDOIwgTp7anSnEf
         aSY1vbk76NMU1cNxO5Q94Ve0aO8IsH4OnbLS7M+p7S3jbasvAPypY1VmUw15uhICE0Id
         cEQ7eD6kPfOc4RQdYAZ8OWlzurBfASycgkANWmpt7gvUWzGDTfNLtxS8YDf7cGK/ZOIr
         XUUH4fOb+sMBV6TOtRx5KnNdNMpnbuRir2Otmfq2KazQ+0SiU+XE63tGfkvl3UAMkPKW
         d0/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rQiUKzLp;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p12si44594pgc.310.2019.05.14.14.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:54:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rQiUKzLp;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4ELr9qw032600
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=aGRxiMv3PcI8LcBLMKV807UIVqUNvcuklnYvAN4lYgI=;
 b=rQiUKzLp+AvTEAKujdOo4UpiE80oxYUwcu7qKQEh2t4wJyTvd9nweaxpxeb+94WVcImc
 CRNYaBGzX3OW6GLSQwN3Bq6uPSEH/x+tZaHnr+tVOPr6tazRM/L1WZsIhAYCAN1A03lp
 Ue7VmllzQREsM7qLxdPVai4uf2jzdUi1fKQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sg2m18tty-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:57 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 14 May 2019 14:54:55 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 908A9120772B0; Tue, 14 May 2019 14:39:41 -0700 (PDT)
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
Subject: [PATCH v4 7/7] mm: fix /proc/kpagecgroup interface for slab pages
Date: Tue, 14 May 2019 14:39:40 -0700
Message-ID: <20190514213940.2405198-8-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190514213940.2405198-1-guro@fb.com>
References: <20190514213940.2405198-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switching to an indirect scheme of getting mem_cgroup pointer for
!root slab pages broke /proc/kpagecgroup interface for them.

Let's fix it by learning page_cgroup_ino() how to get memcg
pointer for slab pages.

Reported-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/memcontrol.c  |  5 ++++-
 mm/slab.h        | 25 +++++++++++++++++++++++++
 mm/slab_common.c |  1 +
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0655639433ed..9b2413c2e9ea 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -494,7 +494,10 @@ ino_t page_cgroup_ino(struct page *page)
 	unsigned long ino = 0;
 
 	rcu_read_lock();
-	memcg = READ_ONCE(page->mem_cgroup);
+	if (PageHead(page) && PageSlab(page))
+		memcg = memcg_from_slab_page(page);
+	else
+		memcg = READ_ONCE(page->mem_cgroup);
 	while (memcg && !(memcg->css.flags & CSS_ONLINE))
 		memcg = parent_mem_cgroup(memcg);
 	if (memcg)
diff --git a/mm/slab.h b/mm/slab.h
index 7ba50e526d82..50fa534c0fc0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -256,6 +256,26 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s->memcg_params.root_cache;
 }
 
+/*
+ * Expects a pointer to a slab page. Please note, that PageSlab() check
+ * isn't sufficient, as it returns true also for tail compound slab pages,
+ * which do not have slab_cache pointer set.
+ * So this function assumes that the page can pass PageHead() and PageSlab()
+ * checks.
+ */
+static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
+{
+	struct kmem_cache *s;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	s = READ_ONCE(page->slab_cache);
+	if (s && !is_root_cache(s))
+		return rcu_dereference(s->memcg_params.memcg);
+
+	return NULL;
+}
+
 /*
  * Charge the slab page belonging to the non-root kmem_cache.
  * Can be called for non-root kmem_caches only.
@@ -353,6 +373,11 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s;
 }
 
+static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
+{
+	return NULL;
+}
+
 static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
 				    struct kmem_cache *s)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 354762394162..9d2a3d6245dc 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -254,6 +254,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 		list_del(&s->memcg_params.kmem_caches_node);
 		mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
 			lockdep_is_held(&slab_mutex)));
+		rcu_assign_pointer(s->memcg_params.memcg, NULL);
 	}
 }
 #else
-- 
2.20.1

