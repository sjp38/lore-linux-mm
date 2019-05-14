Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 920D1C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:44:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5326520879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:44:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="O5udvkqQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5326520879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B86916B0005; Tue, 14 May 2019 17:44:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B35F56B0006; Tue, 14 May 2019 17:44:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D6916B0007; Tue, 14 May 2019 17:44:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF4C6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:44:57 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id d10so392239ybn.23
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:44:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=JPu1ZqgGG6VS+4jhCMwR1QB6RLw1Ggqmre9BJXnrVoY=;
        b=eLFnr1+sBT7o/Gat9FwVMPBDeSp8YydTegMx/RF+4TkdEvbG1PsiyxiUYCP7WGluuS
         AMjuNc9tz3GMnjca7cPbK7s4UFFalIQbYPedh8jIWlo++syhgeZs8S8fY+LLCUDMuLNL
         Vp+orVxYXDeUMitnvRSwdYwU0n3kTXMGdhdg3WDA0+S46O+jgcFq+SV/3W2bm7chS01Q
         J5Ea4GM+OTtq+nCfW+G+p+ETcuNYRzaV//XbE5PQHv9ISCGWDMf7QE+40hKHdgm6UqpG
         Hx1Gcy5I7Zr/PVfUSnQ6Bs2VaneqiTbpP0SAKDHBGy4azR6KyarpqNAV5+NZHvdk+d39
         8OoA==
X-Gm-Message-State: APjAAAX5bIKJKuQLCtnZ1fX0ddakHktw9gxVyaN01hJVBuTlnMUdg+XB
	Iciwq8xbSNY7Uk7qiupZ+LwUISFJD8nL/yX69bbYwg+JMwFMGcmQBOHTUviV/PkJaHyRXjLRvCq
	wYUHTRVDDr1zC6SKioH9FnOFUi3QgtJMyuLVgj9FEUwgt+6+G4DydBbX6PGHNIOcquw==
X-Received: by 2002:a81:5f56:: with SMTP id t83mr19875389ywb.179.1557870297249;
        Tue, 14 May 2019 14:44:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6xsX7XliGWsl/hIJF+xXJvcaHqsZoERA951dytb24ITvU1EY8Bq/5NzltYnfa1ssXC5Ad
X-Received: by 2002:a81:5f56:: with SMTP id t83mr19875358ywb.179.1557870296495;
        Tue, 14 May 2019 14:44:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557870296; cv=none;
        d=google.com; s=arc-20160816;
        b=rYY+ojwvkD9CWfGatbi7BLzZaYCWgP/J+pqH6d9dZlLOC7UX5udyR/uOflc4BTtbwB
         l6RrU7iDU7tyYRnJ4u6/CYSNs2XAS8DlASTh4HXWFLr5qWCrZBCNMyuQ34EvdFHX7/WB
         H51geJGEp2/56nSJday1UevIn3ABX1QjtqzVb6jfxh/9nMx41WSlHD2FclUcsP+I80uf
         NeiENt1xlr/U/FoFqvqs+gHwboA2Jy3vN9Sh0fcPIpzDI8XdBgd9/rL2uPtUD9EGqgjm
         9egEf86FIgYKsWh50AJXv5EHsi/DOJLwELCRZfLdq+975gs9yCQZtZ7RYxGMRQzQHhni
         EpdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=JPu1ZqgGG6VS+4jhCMwR1QB6RLw1Ggqmre9BJXnrVoY=;
        b=F/cfflTKL6CZmZJPQEFNzGZoRxHEXdvMZHXpozPtQDAYoMB+nk+YyopFeltnpB88xN
         59tI2r+uwhbguk9YmocFM6L3R9Npqq+jeGzeBgTj4Sasq+MmkfekJyvueDSG72M6l0Ay
         LfjUTT/asqEr1kXR8Y8W+dKHDK7asAqJVI7WKUcbySKSaUrAVhdxbP81OTs5Ys34xL2/
         3RPrNP0SRjApNn0iUhtbBygwlBmnY/NslYO1ZrDeVAI5zv9ArlVQCdbygm7iQLqaQYLQ
         nW2vdLW8ounPyXI3PVxg8js67KOW473uUSrmugb4jLBIv61+G1FhKA5vVPTtfqN1+FJQ
         CfvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=O5udvkqQ;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d17si4555813ybq.356.2019.05.14.14.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:44:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=O5udvkqQ;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4ELhtg2009938
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:44:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=JPu1ZqgGG6VS+4jhCMwR1QB6RLw1Ggqmre9BJXnrVoY=;
 b=O5udvkqQlOyeiCzPAr0ial+WE4ZaoCA8UTZvbjaS8/jhDpEtTHXaO9CFxTDF1ja9JhQo
 gxvMehqqxrNwTFGXHtPUMXQnCesCcBobpKrsz3rAjjcytiBGFrCDxOZKgchd7Wt95VgW
 MuUg46ffASGbnPk4spaMKyBP7npMb+A7K0w= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sg5bm840w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:44:56 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 14 May 2019 14:44:55 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 7DF75120772A3; Tue, 14 May 2019 14:39:41 -0700 (PDT)
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
Subject: [PATCH v4 3/7] mm: introduce __memcg_kmem_uncharge_memcg()
Date: Tue, 14 May 2019 14:39:36 -0700
Message-ID: <20190514213940.2405198-4-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190514213940.2405198-1-guro@fb.com>
References: <20190514213940.2405198-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=946 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140143
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

