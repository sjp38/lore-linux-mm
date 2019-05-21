Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BF41C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:19:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4D5C217F9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:18:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LOQ0FTTD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4D5C217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AD066B0003; Tue, 21 May 2019 16:18:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45D736B0006; Tue, 21 May 2019 16:18:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 324766B0007; Tue, 21 May 2019 16:18:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5016B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:18:59 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b81so18943670ywc.8
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:18:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=JPu1ZqgGG6VS+4jhCMwR1QB6RLw1Ggqmre9BJXnrVoY=;
        b=ktylAWoG7mR3+p0bynefdAvd099fMHTQaw3zQ1Y6uv9AVj8ER3ZdpRD1/w1t55qIcj
         MF5sIRIziiWC9uV41xRES3jB/rJ7d8PmDNfi+WYttMkHFX+DKRJhrag51Uqzi+qRq4mo
         MfCTVjTOje9oM56DdVn2dmggkzQjF3DAktNgtqP4W5sxeUbs3kbNuNfX9IUqrAm2Z9nk
         XFeiWBgf0pW9kEllTDY2bTq2eT0vi9dnj7mfVGeiwNO8acCmNTEXG2KrF9PpNEkzxIPM
         Tg4Oo6XiWr7zwnIKuJauFTS2rwUQoaDH6yPJ9VAGXAB06VXwrVkGnXDX5hRdsUdYNd+W
         os9Q==
X-Gm-Message-State: APjAAAVlSXWMuiH4IFQSCwJjr1DUiPN3q8fJHV4LcXtjBNxVf+4TdZny
	ipJIRBV34Nfr558bzBlld1bjE0ry7HsFHP2schR2PuUQvdhHt/qiW6J33+ZHbU0107raKSJUisl
	EUBGWZMT1aLrCFPlMjFCsYvIB2qKqMWWU79B4X78eAcdKq98JSyW92diffwMzPB7G9g==
X-Received: by 2002:a81:a189:: with SMTP id y131mr2729443ywg.245.1558469938691;
        Tue, 21 May 2019 13:18:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxH9+u6I47t6+syyrJS3wqQzi8KWX4r8Og6mhjEXdv+3y+5/2+B5LjVgk7bJ9JSBR/Ax7Ke
X-Received: by 2002:a81:a189:: with SMTP id y131mr2729411ywg.245.1558469937759;
        Tue, 21 May 2019 13:18:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558469937; cv=none;
        d=google.com; s=arc-20160816;
        b=dluIhtOjSMxjd7lk4BAUWtDlxMKBX2z2YYYPvLih4ipu4Z6qtROBgklLPzhIXW8cOs
         8fEVO1y7wueQjmMVE3EepAxwmTAKVJrgEqY0uOgFGnBbUsYSYi6Zpf8ag8/PcHu0QCvV
         3PlfqCSPAGkruZEBRuZOZbXQIdV9QZCZh+iU288PvdbMEBXbpE3VCP/pkk2BC8Wd16Jz
         l09fMFwWD8RRgExKo/4nS7UwNBpDpTStfhKwQrG7Opleo+7tFPTVnLj168re+TKTpQ43
         gNzav5B7X5bTV+jc6IvwbZ/VNcSLckKnHmPU/w4okqEb30EuD0JIxorzwrLHL+r2xX1C
         GoRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=JPu1ZqgGG6VS+4jhCMwR1QB6RLw1Ggqmre9BJXnrVoY=;
        b=lC2MHIoV4ZZ10epVpkxSoLvdi5dcJt6I4jWsCDfiAdkvdVZN8Aqr7WwJu1FpXi9+E/
         pTlQWQZSoX/AFyMPkOwSwNTc7ogPUZQyD3z5H+0GYudHyBHe0tAR7j9J6nkAj8XBZjTY
         s0fZBPwMH50ta9DALZGq2ZKLLoESkAd1wGsx165trpNtWmBJ4JQHBCFavi0tQ1oU3m7q
         cHCgnfohA+dfsUpU9PVlNAz5QmW4Jq3FWlOi7l3nn2NkDf+E5T8Rw5xuGX1GU79GxWW1
         h/rEAQ3qP09U5v3vF4gyKnrOzkt5MmwDhpUJiCKLz7wKj4lMUpMZss9RQ2a1P5aRCfXy
         om7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LOQ0FTTD;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y133si6729207ywa.233.2019.05.21.13.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:18:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LOQ0FTTD;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LKHVeV004126
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:18:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=JPu1ZqgGG6VS+4jhCMwR1QB6RLw1Ggqmre9BJXnrVoY=;
 b=LOQ0FTTD51OOaEqSKGW5yZmJhgz69LWxCXc8HqSY/aGFBwFM4G7X7GgVrLsugfDnwhWb
 t78peT3qAtIElp9GxmcqXcvcgop/y8m608MgmZjqrvjAuPnM6c39gIXYblpjei22sAAA
 WyaSVOrzdxSEP2qrH4QpHH9glnz0P//S0po= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2smb4mjrym-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:18:57 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 21 May 2019 13:18:47 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 08C751245FFA5; Tue, 21 May 2019 13:07:50 -0700 (PDT)
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
Subject: [PATCH v5 3/7] mm: introduce __memcg_kmem_uncharge_memcg()
Date: Tue, 21 May 2019 13:07:31 -0700
Message-ID: <20190521200735.2603003-4-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190521200735.2603003-1-guro@fb.com>
References: <20190521200735.2603003-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_05:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's separate the page counter modification code out of
__memcg_kmem_uncharge() in a way similar to what
__memcg_kmem_charge() and __memcg_kmem_charge_memcg() work.

This will allow to reuse this code later using a new
memcg_kmem_uncharge_memcg() wrapper, which calls
__memcg_kmem_uncharge_memcg() if memcg_kmem_enabled()
check is passed.

Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/memcontrol.h | 10 ++++++++++
 mm/memcontrol.c            | 25 +++++++++++++++++--------
 2 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 36bdfe8e5965..deb209510902 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1298,6 +1298,8 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void __memcg_kmem_uncharge(struct page *page, int order);
 int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			      struct mem_cgroup *memcg);
+void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
+				 unsigned int nr_pages);
 
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
@@ -1339,6 +1341,14 @@ static inline int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp,
 		return __memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	return 0;
 }
+
+static inline void memcg_kmem_uncharge_memcg(struct page *page, int order,
+					     struct mem_cgroup *memcg)
+{
+	if (memcg_kmem_enabled())
+		__memcg_kmem_uncharge_memcg(memcg, 1 << order);
+}
+
 /*
  * helper for accessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 48a8f1c35176..b2c39f187cbb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2750,6 +2750,22 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 	css_put(&memcg->css);
 	return ret;
 }
+
+/**
+ * __memcg_kmem_uncharge_memcg: uncharge a kmem page
+ * @memcg: memcg to uncharge
+ * @nr_pages: number of pages to uncharge
+ */
+void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
+				 unsigned int nr_pages)
+{
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		page_counter_uncharge(&memcg->kmem, nr_pages);
+
+	page_counter_uncharge(&memcg->memory, nr_pages);
+	if (do_memsw_account())
+		page_counter_uncharge(&memcg->memsw, nr_pages);
+}
 /**
  * __memcg_kmem_uncharge: uncharge a kmem page
  * @page: page to uncharge
@@ -2764,14 +2780,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 		return;
 
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
-
-	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
-		page_counter_uncharge(&memcg->kmem, nr_pages);
-
-	page_counter_uncharge(&memcg->memory, nr_pages);
-	if (do_memsw_account())
-		page_counter_uncharge(&memcg->memsw, nr_pages);
-
+	__memcg_kmem_uncharge_memcg(memcg, nr_pages);
 	page->mem_cgroup = NULL;
 
 	/* slab pages do not have PageKmemcg flag set */
-- 
2.20.1

