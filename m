Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 363E3C072B5
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:29:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9A462173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:29:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="hJH65C/8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9A462173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BDEE6B0007; Tue, 21 May 2019 16:29:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 170C06B0008; Tue, 21 May 2019 16:29:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 010686B000A; Tue, 21 May 2019 16:29:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCB286B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:29:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id k22so57929pfg.18
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:29:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=1MscbZFIv/dMuN0XCm8C96ivxHN/q8ldFdECslyEkfY=;
        b=o5cEZ93kya2W+aJxTR6rFrL8ClfreaN+LQF9VT5HjUqO74toQhHmrbT/MsiTE4Z9Pm
         R+J0F92PLTfYC8/aazcG6Ugc4JQuAmfxnKQCBhImIuy5VQVkvTy7uqZ/FPzGtAV7EBtx
         gHoDQtwOk57rOJm/TKk047j3WoLFb90gVBtl47H/t8cVpQI/e2Tr93anYEgXetgN6j1D
         uV+5xyC1AuGXU0g397uHy5Bfbauj5A+eQBAG6UFKxoTBmMEB9+5oxias0XgYiaAYmJ5l
         lxxIV8om/rLbZ1pp4lSVUpgsavk2e4PeCfeTqedLxIaxxMBcnkGVPYHfHEQJmIbzJxrc
         Ouhg==
X-Gm-Message-State: APjAAAW0ND+jCxGlpT8gjdBMsl2JddFWPa477oKr+0T7yRKOTTZ04lrv
	cpj6XsNYmsbvCNwCxhQ/ycwmwBM5WkgCnrMtbdDTE2G4/2bzDIIpho1DlQ8N7QLorBTpLPiSkOi
	J33BYMcXtcrTmxSErWW5oN9T6Tn87lG4PkHJUXfkC8VLUfEfDFTpSEMO21oN0JDo9uA==
X-Received: by 2002:a17:902:2be7:: with SMTP id l94mr30909708plb.185.1558470546416;
        Tue, 21 May 2019 13:29:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzrk+aEVlda3XlJpIDGWOK6MiCML8pvAiR3tJjTt2s+jEWbQCpXSYc9pdRDOeDIRvpKzj4
X-Received: by 2002:a17:902:2be7:: with SMTP id l94mr30909614plb.185.1558470545568;
        Tue, 21 May 2019 13:29:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558470545; cv=none;
        d=google.com; s=arc-20160816;
        b=RRqKv2G0ekvcuX6e51oKTh9VzGo4YuFLckXIqBGfvQxJv3SUhFbOAQM8ksvPAOPCOr
         mPHEvHtS3HjcOAk+piKaI67A4T5Mi3UMA4mnYiCHsaEHVgp1jjLXbKF8KAHYesYEamRX
         qwlVjaPlCBmMIfmZZKIIziwmP4SWXeIKWga4Kq4FQXtbr3nMAuT+Q38xVZf7GlfKOlAF
         9Q/NvwzC4fkQ8k3/wLUHu9bfV8hrfZeV2ZdDcnX3n/j6o7Q+WqXrhDtIO95qsJbof2MY
         /TyOlc4ENIO5/U5BO2KY6qP8y6/wSKzQzuBm9rsglCZTMx/1RHGFrzkTcGBkOQoybEDB
         MwoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=1MscbZFIv/dMuN0XCm8C96ivxHN/q8ldFdECslyEkfY=;
        b=vaKogCuj8XhidIFo7s28GC/upI1HGrMwlWJd/A2DTaMEjKeq6oqLeeOKnGYUksEVdA
         06BGXWEd+AbVNwfTd+MKf3FbAWBfDSAZM1huZgQghuce/t0A4f0muVT0qDjRIMUexyzV
         ZjjERLFP9R9heAZVKWKmywuzFL9AGMlZgqQ2tm6coltmdedZ7OGK8uDd3OVtDC8j4dV6
         rXa63nLkLRTR8KGZIOQxxKkbZAFKkfaJuCNrZFVJkPKizJH7x+lmeTvoL21O/lZEKBC1
         7PxfoX8N3j5DwJU8f2mb55NYct1zD/NrgxExzFf83zfPMx3b1i7eDqrEGC7m6ztWCOWQ
         24xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="hJH65C/8";
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x28si25566848pfr.289.2019.05.21.13.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:29:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="hJH65C/8";
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LKRnPs018599
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:29:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=1MscbZFIv/dMuN0XCm8C96ivxHN/q8ldFdECslyEkfY=;
 b=hJH65C/82a55FZSVGpq8mYpyG3sGGQ/lAiSIv0ANm1ProvQttMNZEXb3JrItoYBGjUSl
 aYgP3XaYZU+/7AuTUGj25iNKjOFDGWO9Saium5YzfznUII2HUvy03gT7NA6m46wbo3Ck
 XeqPLN+b9Q0nG0eQ96hg4TAhmMxCs3ZxEKM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2smd9cjh28-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:29:04 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 21 May 2019 13:29:01 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 1BAE91245FFB2; Tue, 21 May 2019 13:07:50 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Shakeel Butt
	<shakeelb@google.com>, Christoph Lameter <cl@linux.com>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v5 7/7] mm: fix /proc/kpagecgroup interface for slab pages
Date: Tue, 21 May 2019 13:07:35 -0700
Message-ID: <20190521200735.2603003-8-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190521200735.2603003-1-guro@fb.com>
References: <20190521200735.2603003-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=755 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210128
X-FB-Internal: deliver
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
Reviewed-by: Shakeel Butt <shakeelb@google.com>
---
 mm/memcontrol.c  |  5 ++++-
 mm/slab.h        | 25 +++++++++++++++++++++++++
 mm/slab_common.c |  1 +
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index de664ff1e310..f58454f5cedc 100644
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
index 7607a40772aa..e818609c8209 100644
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

