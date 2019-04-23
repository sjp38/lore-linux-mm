Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA64FC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 05:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AAC720878
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 05:11:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="UmOzXPgo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AAC720878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03EF06B0005; Wed, 24 Apr 2019 01:11:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2FEA6B0006; Wed, 24 Apr 2019 01:11:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF67F6B000A; Wed, 24 Apr 2019 01:11:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA706B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 01:11:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j9so4828772eds.17
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:11:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
        b=cjltM3PwRHKlunBeTZVTehXyFJS0UTo3dIGGM8A+7Ff2ACOjgTGZXzcKRxYzNwgtkF
         oObzCEHRggbD8XyI2x46eZrJyz3F8wzSh6EJjQo9xyz2GGFqG6cj7fuBrdnxLu+J0bAa
         ULQFuL3FSgp7RCxRYdHUAOR7aqafm92LiZqxHRg2n/D1ddsZecWS2bJAoD790BtiMo53
         7acJX6FGtlB55YUEGRbBsCj3FAVDWAqqYCYVLvIlM2EHVzr5ma0MAW8+WiHbhAeIDvGA
         VaIVkIIUbp6nhd4RyHCn92LkBLs6bYIhJ/it+AZhjM3GS62EQEpxzjTeDqS+fd9J2GLv
         IIpg==
X-Gm-Message-State: APjAAAUooD+Y+/+45bcazBtoOvIr9atqiJnhcjXAaEF5oCnW4hASi7WS
	jDXxshl/qI7ZqZiymVRs7tEcLmtfef3PZYA9SVuNJR4iECj25oumo8sv56NGqgE4pdBhaoA8pFG
	w/plliIxEgTBpGA/V+PFCN0MboxK+tm/ZEBzhjQryk/IDDxJC+3wWU0Bh674urCd3Ng==
X-Received: by 2002:a05:6402:1711:: with SMTP id y17mr18465496edu.275.1556082680946;
        Tue, 23 Apr 2019 22:11:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsGOD0a+64wsJf500PZNfUlJhRnWqICumtmO2OPEkD1Pog/vIntga4FgC8+Uk1rHWz/0I0
X-Received: by 2002:a05:6402:1711:: with SMTP id y17mr18465448edu.275.1556082679982;
        Tue, 23 Apr 2019 22:11:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556082679; cv=none;
        d=google.com; s=arc-20160816;
        b=zgEYEkwk65LAfwD4bf6QPNedUhy/jiVMue16ji/kDCPa8Uic6qH0x2JPV373nTt4oc
         CgjcT5foFSg7D97hkmspui5fteXfQYXxCSnzyEIcMsMqqq5cYH/hwGxeG9tK/rqC+cGR
         FrOr73vhIhr6tzK2vDIU3XwEQ5Kg+LCf5PhlOSVrL2Wf25SebgDCQ6rk2l95W98Db34K
         Zg1YpN/6bvflHjPXnW3K98I+Ev74Hi5Hi79WLRD2Bm2h7dOv/AlrPhYKXVQ71VUHkurp
         zX4TD2/JSF7LHs2Q7oOAxHAmdX+9bKeuoXkfuXkJ0mtkItDancm7oriwNMHIgwGkLNQ3
         8mIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
        b=TpYYUlTouhrhmukNKO8QEiiPzQeBbWpWsCNk16vqs7quyU173qqryJQqMHM5igOI3J
         fE0D0eFKEV9SnNNmzvw0vorlgiBkP/XsRYSS/3yQJwSrdqBarambIlfoV1dgnJ8QL8/c
         2tmtnKdVrpgWaMU90FLZl9OSYdPYk4m5a9JuXXcmpH/owPVbrJPP4KehHKpJYXSYB8/U
         jH2+AWFjdlHDYxjo/zjUoTgE6TRBnjh6fvyLnAMhRs/zHfPmdCH0ln1BFUR3/oKrseCl
         47d9IRgm3Opc2XB2iM7vh3b0dcMYVl//Y6HHCgPaMdLI07PIiMSif8Vsle1bGh8CfryV
         N+FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UmOzXPgo;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y12si2709772ejq.177.2019.04.23.22.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 22:11:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UmOzXPgo;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3O5AZ7i031564
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:11:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
 b=UmOzXPgoQyMb6775Oz2yU4LqMZg7j6hKF1EyxksST2XqEVT04qJqd9NI/yWg3n/yIqH/
 a5TMQXYG/BcjWC4uW47FfZCqbTOyhI3fFCgDBKNwLiJZUmz//uzvCGM79Jb8FC1VCzJi
 0YoFkJ587li2/ZqhKmpKSmSY/V+8v9wZ7Fw= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2s28tp2e8v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:11:18 -0700
Received: from mx-out.facebook.com (2620:10d:c0a1:3::13) by
 mail.thefacebook.com (2620:10d:c021:18::176) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 23 Apr 2019 22:11:16 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id C6D241142D2E4; Tue, 23 Apr 2019 14:31:36 -0700 (PDT)
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
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v2 3/6] mm: introduce __memcg_kmem_uncharge_memcg()
Date: Tue, 23 Apr 2019 14:31:30 -0700
Message-ID: <20190423213133.3551969-4-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190423213133.3551969-1-guro@fb.com>
References: <20190423213133.3551969-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_03:,,
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
__memcg_kmem_unchare_memcg() if memcg_kmem_enabled()
check is passed.

Signed-off-by: Roman Gushchin <guro@fb.com>
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

