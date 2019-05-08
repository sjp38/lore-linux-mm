Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3936C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:30:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A473520675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:30:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="KxxyRoNW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A473520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2D96B000A; Wed,  8 May 2019 16:30:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 466516B000C; Wed,  8 May 2019 16:30:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B8C76B000D; Wed,  8 May 2019 16:30:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id F27726B000A
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:30:56 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id a70so37253139ywe.21
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
        b=mWVmTELQxPGjQ7/MbJqMCOBHIgdt97nk1ppa7b3S+SvfvhfAJPCsgBrxgPkrcSSmxD
         DbeJ4TzXjPrsA9rBnLVGQ4P5E7KmS2BXOzcGWhF2MQBYj2T+GEhX0F9dnzmRHOMbpKWy
         +iLWJV1ItkvSLnclM55UEbAgFB+XBG+xp3g0LgmF3HiVK8t98Lf8X1sJpN9rY5cIzy/5
         oNOx59Ep1oCksLltOu4xjNPzlr8n3fBo/hTh0cDzoNcIpN5k3pmmR3uHfVaJon64guhc
         iZy740WysCAdGHSGNl0Sb3w8bUnkPw6svspFOkeEHjVR3L8Ku4n/lcu7N/ItDbsxb6Og
         aPRQ==
X-Gm-Message-State: APjAAAWasgjxCnloM8rqs+Tn1HPr1aqLRAM+yb0kXENL9Luw0zSUXHuf
	KruYXWsDlugqMEG+0qQSSTQV1ELeNcbZvcAUi/wLfVbYYG/a2LFkh5qSw29SJ8yL5E2Uh1nzxDF
	YaMZAu+6wotOrajhLDYsEI8IFVaw7/a1BSzoMW22LbqP2OCbCRIZlXsVYgVosJRRWUA==
X-Received: by 2002:a81:2fd6:: with SMTP id v205mr13388605ywv.205.1557347456586;
        Wed, 08 May 2019 13:30:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8AmocoS/++ZcCVkF+yR0eOXAcO9BpRKF8m0xLsZbVcL1D+nOI5HZDcpb7naYoJ5/i3ZK/
X-Received: by 2002:a81:2fd6:: with SMTP id v205mr13388561ywv.205.1557347455984;
        Wed, 08 May 2019 13:30:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557347455; cv=none;
        d=google.com; s=arc-20160816;
        b=hj1S8Qd9ynNgXa97exe1eJxmlhTMm84tGrsH+SuGDBaZiaYw1yyNfUWydIAmeH7/ez
         byN+P6D/AK2tFr/z54hibQgxNh0LkLJTL+JsHPEyLk3s/G2cQdmi4H0CCd3Va2G7Y0ET
         xhimgCO8vgcV1Froo9vTVBbjKU/FCF503YOzh/AZBuO8m6phyEagxuCj+cFdxsJMyDmL
         CQUpVoP8K4VWRWNYuu4AkCOMqI2xtnm8EXW9ZyARG8GHH05DV9VgUhwpgMIAbPPFk48l
         DnFc7NavvlAl2zoK9pN4AZ9MiL8ffRSXf5d5itDgUPnB2tOuZ4/coKWvctIyJeIAuhfn
         btAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
        b=Oc2Ovb9SXiXPB0W1UI3s/qBsmSNHZzFX5c//JIF5MQp06+a7z1/TK3bMuT46Fg5SmW
         /7SQJ9NDRBHElgGnhdIldkXZucyJ4Z+Nl8FYRgEhL18yFkWmuar2pkMhOzRRah6NL3Qv
         hw0i0eQx6rTtfE3kXYmc+jDv/Mf0GMa+7yUG0zKlAawZ+p14SipfC0hCRV53DvtLBBjr
         o0zWc4Z3IKjxKYM4BVxov0UnEqjfOrTDEVj9GoyL6MuxHXU+3hZVxOnBhcqkhVUA4jh8
         Jo6p/yPONNriAByugBsIP90PNDRjyw0K9FQWcCPS0Zc5C144O/7a/bXdkCvLY1TTWUKr
         N0Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KxxyRoNW;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id m79si42722ybm.359.2019.05.08.13.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:30:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KxxyRoNW;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KDOmS029689
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:30:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=cRmr36eXTaKgScK2fa3yPK15EeGvQLf0Lc+faeDoG3Q=;
 b=KxxyRoNWw5r0lsssspEynn5EEM+EXQJNywc6y79B8bU/5ri9UMYvV4KPL0gqvUbh3qjc
 eyZsnqk1OijDpHc3mMO4yry2z7lXWKyzKlmfKf9b5I1NRvrM55M4FOLBlit3Q88XlPua
 BAGRBadCHAldOTStaqAWBO6BlX9CFk5SHjc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc25590kn-14
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:55 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 8 May 2019 13:30:50 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 0B9FE11CDBCF6; Wed,  8 May 2019 13:25:00 -0700 (PDT)
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
Subject: [PATCH v3 3/7] mm: introduce __memcg_kmem_uncharge_memcg()
Date: Wed, 8 May 2019 13:24:54 -0700
Message-ID: <20190508202458.550808-4-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508202458.550808-1-guro@fb.com>
References: <20190508202458.550808-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=859 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080124
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

