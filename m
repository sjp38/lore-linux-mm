Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 512FDC28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0911220828
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ZH2TXFP5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0911220828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364906B0270; Tue,  4 Jun 2019 22:45:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F1576B0276; Tue,  4 Jun 2019 22:45:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB65B6B0273; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A94A66B026D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:03 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so15232027pla.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=nRQ8E2xsdPMn6A3dTdY86dEXrfQWn/mxew8g7sZDO2Y=;
        b=IyxKWlQLsemCGKZbAxB/8ywU96iJ8rmOHAjRqDYdVdriaT1w1ekEhP8c15tFvU8jGr
         lQmMQzcvZvGFzD6fCdfb8TwPmo3qV80hIuLxhBiLoYWvedyU45I+b8KN5LEzVG/49eSv
         D6CAyy1FUZUV5CyA3NxI4d+pqJ6qT2W/Epicr6StL8XVLSO/q8uRflRaDtQu5U2MWsHD
         D0iMFSzoX1lKshJtlGVhw7F8ieU0TZWLyvbqriY+QUZCvAg3tSX3aTZ0uk44ZRpe5VBn
         726XiF9GxmUyEOQ5II/apE4aJhnduSNhpswEDqgZ9G/l8v04E7CGuheCExwQ219CY+TU
         19xg==
X-Gm-Message-State: APjAAAVhXAK8ThPpD5LrYAf6ZjfYk5NG2cAgg+vZTlGJKQ2pSkQwQ09U
	JOTlCgUhAhGtSev2XUfSJvg8VLWtMJ+mUf5FWWvFxEMQK68fS02JMA1VhiI3NfuuULoCLwZwfXN
	KvAsC4RhHo6u2Ed2S9ird6wyc8joLYp6pOumXWcex86mu0C45xbxppzZASWIUggEHJg==
X-Received: by 2002:a63:de4b:: with SMTP id y11mr920603pgi.301.1559702703156;
        Tue, 04 Jun 2019 19:45:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFtMlKnYj+OXb9mj/lm85VoJqE4AVaEZ7U38uJ3o6a4G8UnLpvgsufmC3n11LBh391juMo
X-Received: by 2002:a63:de4b:: with SMTP id y11mr920560pgi.301.1559702702336;
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702702; cv=none;
        d=google.com; s=arc-20160816;
        b=Jdu5mD8PiZneRUJ+3iMjPpwPhGjaR2S5QAxL93wlw53x5veCPcJ6PlqHyDmcdhqimv
         gcz/GF4HAVDMDZtXmzptJO3VtlVfKOKNWI15cq55Azto4HzajtFXS2OQWi/1NnNMxqn/
         XzQBUQ83vm3L64C6SR2qK61RBRmxv2x8e0nSSmxFdKZJHqPudwIaRHawdn9YSiIkkjDV
         eAT+9eKklEh+DSZFXWw0uWM5yCOLM3srVpFyYG6e8R/1ybQ7zKFG5/cejw1AvT4ugYog
         EsnUl5+oUuBBM2Ohm3DzGHneD+IF7ucfb+ISPtGlYDZ7Ur+lw+Tyv6LudBtohj6YHtB3
         LgwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=nRQ8E2xsdPMn6A3dTdY86dEXrfQWn/mxew8g7sZDO2Y=;
        b=THagxa5LAPlpUa+9WwPzxPICr9i7GC8zBRZW4w+eSCHco7q06YosKvKiYPZY/vmsbD
         dyVt0AsfRvDAx++mzDKfsS2Lnlw9NuKBS+G8GCPXvals4WYQf4/vviL5ZquKu43qq2SF
         8VW3kFfgg4x59PeLbAsTPCpE3iVYZyF9kuUM7aE9D9SxMDpluMG2X5qpn329He5D6moT
         GE0Lq9oyvLA3rDkgM8o/BDb7gFhi8lCLu8v+XgcW5aFv0JxIfrgTL6h4mNyTKYH9a3zi
         TqLWxDwizlwkaw03M2Dx9Y8+5GBZVMAPiu9ayeqXkY8cgCvUKEZl7fMJT08tukSlYHO3
         EN2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ZH2TXFP5;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i8si23338646pgs.220.2019.06.04.19.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ZH2TXFP5;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552j059031912
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=nRQ8E2xsdPMn6A3dTdY86dEXrfQWn/mxew8g7sZDO2Y=;
 b=ZH2TXFP5HplCQcFb8fKTo705zDaomejANIkeVDEfi+eT9bkz/E/mo6EKWMQJWSm56Wop
 t6J0TxVTU+IuYGg522NC14setthkTEunGANNRnhXr+tpOQCz+p96U+h/61T3qcq7ATFn
 yhr6xk7Vm4ohJ6zLtKK9Z41q5ZPwiRPycHg= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2swx191ck2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:01 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:44:59 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 7928012C7FDC2; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
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
Subject: [PATCH v6 01/10] mm: add missing smp read barrier on getting memcg kmem_cache pointer
Date: Tue, 4 Jun 2019 19:44:45 -0700
Message-ID: <20190605024454.1393507-2-guro@fb.com>
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
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes noticed that reading the memcg kmem_cache pointer in
cache_from_memcg_idx() is performed using READ_ONCE() macro,
which doesn't implement a SMP barrier, which is required
by the logic.

Add a proper smp_rmb() to be paired with smp_wmb() in
memcg_create_kmem_cache().

The same applies to memcg_create_kmem_cache() itself,
which reads the same value without barriers and READ_ONCE().

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/slab.h        | 1 +
 mm/slab_common.c | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/slab.h b/mm/slab.h
index 739099af6cbb..1176b61bb8fc 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -260,6 +260,7 @@ cache_from_memcg_idx(struct kmem_cache *s, int idx)
 	 * memcg_caches issues a write barrier to match this (see
 	 * memcg_create_kmem_cache()).
 	 */
+	smp_rmb();
 	cachep = READ_ONCE(arr->entries[idx]);
 	rcu_read_unlock();
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..8092bdfc05d5 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -652,7 +652,8 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	 * allocation (see memcg_kmem_get_cache()), several threads can try to
 	 * create the same cache, but only one of them may succeed.
 	 */
-	if (arr->entries[idx])
+	smp_rmb();
+	if (READ_ONCE(arr->entries[idx]))
 		goto out_unlock;
 
 	cgroup_name(css->cgroup, memcg_name_buf, sizeof(memcg_name_buf));
-- 
2.20.1

