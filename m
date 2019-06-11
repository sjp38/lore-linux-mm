Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0695C31E45
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7853421773
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Zk3BS+Qo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7853421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399906B026F; Tue, 11 Jun 2019 19:18:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34B286B0270; Tue, 11 Jun 2019 19:18:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1528F6B0271; Tue, 11 Jun 2019 19:18:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C08926B026F
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:18:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k36so5579326pgl.7
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=JhIs3/HCydWffB+uV1RGxA08DRLtLPsTTqEKxSMP1fY=;
        b=FPQyjv2cnWI6EAyxTmFSpModVy06aoloDB2bDSvKEEmv4/hByG4Ieg27Uv7uH7lNZs
         VBxMZGiOi1VW4cG32baIyoFnx46IAcLgU06ODkwYtCLkcH+ovgeMAYr9siN/0FP+oYGw
         GApoj9qmh+k4t8wPGkFR5Uk0kr4m43jGoMLSOmiNNpamUj2ioYRgxcLYJWwd0DWSePjZ
         9a9leq4yM4+2Y8FkQku9xRZ/UCCxvJ63D3LcaPiIkVhiXdzOJLKMg4jcocJ4iF0mtVun
         CWwDycK1VuTlprWGHWFdT43DJe0J8AfpMg+Kq4GRbrUTtzbKGMOnErmhR9FND2b6IOX5
         Vxvg==
X-Gm-Message-State: APjAAAU5ZOvO9maACVJQ1L5svhViWiocchjF04vF43qzj92vG6Pwxmpa
	8grL5/HheFrw+zq8gkmdUW/icqdTzbjCXwsgsG9f1oxyEpX/RkprC89NSKb4lO+ylk8ft8pFvL2
	3QJBEXDGitboPNoceUb3n++AYpM26qkjXwDBF9fbkYDpHoyPkRQaCXlamVd1YOE3DsQ==
X-Received: by 2002:a17:90a:208e:: with SMTP id f14mr29835233pjg.57.1560295113387;
        Tue, 11 Jun 2019 16:18:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCcBDxKA/OlqIjEf3nLHenpBNSWwsXFz4BxDAoGX/lN0GDtrHFV6GGQ2ZOk8i1dlt4xC6n
X-Received: by 2002:a17:90a:208e:: with SMTP id f14mr29835185pjg.57.1560295112586;
        Tue, 11 Jun 2019 16:18:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560295112; cv=none;
        d=google.com; s=arc-20160816;
        b=G8D/Ij2P4Jf8tJAOftLwqQIaaxDUM6vjRuGTzINo4xwfxXc6RZ5rtYDlmsTgkWxB8T
         o7Zdc92+472E8ao6KWCLlCdq2/Bijem9PZ5838HyYX5ri9eE1bpl/7TMO9jIFZEnSivY
         E+7b1M6YQY1qiojOjk+9vU9FnHV7xvPv9t+MPKFUGhF/WVE36Swy/bjFLPwOoQEEHapM
         K5JIvme+iamgF+v2gqz0qKSNQAx9M+enR6dO0Ltk4E9wtQiAKudDIwg+GKPIWNXPMdCC
         vsIwtbJCMRtm8NO/6sJ6zoAcB7KAAUz5yTfQG9/PpnxxjygFaKJjKt0KaeVMXNMPYKYA
         H/bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=JhIs3/HCydWffB+uV1RGxA08DRLtLPsTTqEKxSMP1fY=;
        b=k1E+3yiwQyVQhIlRsqwCWxU2q+eL8prUqBaJFmS1ycmon657R9uVByNgA+nn1aZ5uU
         t4ifNXvZbQOca0jh+SyBCpoxr0tIdJOhpEJqieSGzZLJNzWWLgOI5wHuspASN7seg/h8
         7KGsw22VBPkpnTsLupgKxKl70ogftq/cByCnr9HEwJImeQk5EhoypvUwFpWX6g9Q3T8E
         v5fgTCslmlfUZM8XRF952ypVrmxhzCnbiwCdrTblYBSUk9IPUYxoz9FVxr3kSJO78oDK
         lN5603K791+hAlGdaEO02+C06Vf94iGsq0p7kft5OU9n/42Z5MF8ubnBANm0QpGoZ4pB
         dBRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Zk3BS+Qo;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h3si2721012pgv.403.2019.06.11.16.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 16:18:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Zk3BS+Qo;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BNAEP6024730
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:32 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=JhIs3/HCydWffB+uV1RGxA08DRLtLPsTTqEKxSMP1fY=;
 b=Zk3BS+QoAeRg4WWCaz05ocuVThlNe41m7dPL12u8XO0/tdXd0hGBEwMvHnFYHMreoq+Z
 vKyranxiKgeotgqqiTLUQHMhhBrp9CLOU5qIcgjkIWnDW1xx41kANpgts1x+5GG0cFQP
 FmeXRqW/Nx9lpVsVLV4vcMTRwEiWmZEI4qQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t2n4j04ug-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:32 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 11 Jun 2019 16:18:21 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 35E75130CBF6D; Tue, 11 Jun 2019 16:18:20 -0700 (PDT)
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
Subject: [PATCH v7 04/10] mm: introduce __memcg_kmem_uncharge_memcg()
Date: Tue, 11 Jun 2019 16:18:07 -0700
Message-ID: <20190611231813.3148843-5-guro@fb.com>
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
 mlxlogscore=939 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110151
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
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
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
index be9344777b29..8eaf553b67f1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2812,6 +2812,22 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
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
@@ -2826,14 +2842,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
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
2.21.0

