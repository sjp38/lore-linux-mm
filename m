Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CDD8C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF6122070D
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="oAw7uVY1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF6122070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AE676B026D; Tue,  4 Jun 2019 22:45:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 003C56B0270; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE6A16B0274; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1D896B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v6so18985181ybs.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=kSMcIoZOy8bv6oPhIhSwMshcDK0XomRQ4uXD2a50jbU=;
        b=RneP9FLrfpb3wLstDrMbhiIoM2SIqmFsuS081dTLvuoEPKrHzxNzfn7Kmle3ZoPMey
         QVGD3SWCaaef0r7xwrM8YNgNX1taQTodgEYWmkLVZUIGeF+aS3B10o9J3ds8arc9BK9O
         6fdLhoCzV3poZHqii3/cAkLGlk9BWiELpgeExgKS8Xk9eRy89wuVClTWao7DPuml6HYm
         mcE82mk4WuSHrWJIuMR5Gqg63s5fwFsiJg3BCE/nv7Kg7dtPd3ZRCZDsEaBV3Mf26B1r
         s/u23Be0NA5UGbOnPmI6jUsjqLAQbDE6/lDPRS3V4JkysRjJRAqWS2AAaSEI22enCllT
         Ujsw==
X-Gm-Message-State: APjAAAWunJjHZiGU8vVZ+fnPm/Mvg+QW2TfNfFtCVOgq7DoQd569rmCd
	8PrqRDRRmNON985UUUdi+DslRosM1sOMxR520EeKcKdVCdR/vpyewmMb/KHMELCXNubSMn8XspY
	foliXAMnVhro87JnAxexv8jg+upgqSXNxm33svf3wur8Ad+y32TVVDWBvnPj/LlnUbg==
X-Received: by 2002:a5b:b4e:: with SMTP id b14mr14382624ybr.74.1559702703467;
        Tue, 04 Jun 2019 19:45:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZfS1X6Ksyr75/1VSNGeYUaJEi4/pR7dYUPXi1AOp44KREi2o4M4kZZ9RM5KeD576oyDFV
X-Received: by 2002:a5b:b4e:: with SMTP id b14mr14382615ybr.74.1559702702936;
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702702; cv=none;
        d=google.com; s=arc-20160816;
        b=EaSvLhgXwl5iBHsptBPPqUTjKTYEOm+DJvLAXjTh7Qcj+SOGuiQ2TkDCpryW1C5vye
         +7YDsdxMwvx/Gtg4UrGF3zbYI/9tFlCuhMe3UBVkwfbHo1n92Ao9vrGd2i44CIsWyaOI
         rO1v+VpAZRnWINy4s3KEPna+kZGV0m3PhLIqe7En828Hrj3GT7UQuxHUbAGLVMuegxnm
         F2YIaqwSBJY/PAhpKrxqztN/mux3QJomf/sFW2amxBR2LwCZ2EXICguDRClJy5UawI9i
         MyIPF86eH7AU/EsakkqhokOHNDbJdt1OwmSiLeW/U63sUrdHstut8DNZh4HXccbYxAWY
         noGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=kSMcIoZOy8bv6oPhIhSwMshcDK0XomRQ4uXD2a50jbU=;
        b=Ik8Kj1CRmBn7lAGDeKT/Lbzc1IDjZkKrYv9DVUpZbTTRBfl5sM/9uZpq2WypL7l+Tf
         LNTl/hE8i0tl/twsX1eKFQ1Eijk0SuSSUZ70V2OahipXW5Ym74xFi+9jxdTK3ciaqMFy
         pcAusT6YETag3AkJzXs6vZpKXrGyGMTHiMFTZGuj4AGQmQB8RGjD8R2+kvPP4kF/vw8E
         TjsmRXYlt8+Wt99qBwDXz66Ka199Pe7MfvbtFNtU1wIL1bIcMRoJxmfhL232atZWLK69
         Sl7QgXdYZuy9nIClwvWrKLgEDa5bL4j7QoiJH0plUpy0T2gr80l/t36qEBuAecgzQyk0
         IHUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oAw7uVY1;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r1si5160361ybb.366.2019.06.04.19.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oAw7uVY1;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552i3Xw023200
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=kSMcIoZOy8bv6oPhIhSwMshcDK0XomRQ4uXD2a50jbU=;
 b=oAw7uVY12LZ2xbms08qwfD8NE4cyI/1+y+8BI8DKv6UEG/gLTJUBKxEGxa2NWIu4HGq5
 HRTcpwgTAToVDVUjrfe4gFCStwtKmP8QsTVU3TJ2F1LCaJ0JvFMjHb4OibE7hXY7EYfD
 ye9dcGmDdcu4Y7DbND0nfS9F49dQ+GIxU5Y= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sx41n84vt-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:02 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:45:00 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 87DB812C7FDCA; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 05/10] mm: introduce __memcg_kmem_uncharge_memcg()
Date: Tue, 4 Jun 2019 19:44:49 -0700
Message-ID: <20190605024454.1393507-6-guro@fb.com>
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
 mlxlogscore=899 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
X-FB-Internal: deliver
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
index 3ca57bacfdd2..9abf31bbe53a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1304,6 +1304,8 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void __memcg_kmem_uncharge(struct page *page, int order);
 int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			      struct mem_cgroup *memcg);
+void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
+				 unsigned int nr_pages);
 
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
@@ -1345,6 +1347,14 @@ static inline int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp,
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
index bdb66871cdec..3427396da612 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2731,6 +2731,22 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
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
@@ -2745,14 +2761,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
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

