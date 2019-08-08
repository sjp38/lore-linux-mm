Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0104EC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:36:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8D3D2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:36:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Klhb8HsQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8D3D2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 385C06B0007; Thu,  8 Aug 2019 16:36:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 338616B0008; Thu,  8 Aug 2019 16:36:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FF276B000A; Thu,  8 Aug 2019 16:36:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E02116B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 16:36:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so59868842pfv.18
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 13:36:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=ZZ49snpRr7mPFov6Hyh1szaiWFNeYUXmStPACJSKaRA=;
        b=BvqvwxB7126AND0XQQM1Rmh4iFtE8cfW0Ok6CHXCTSesK9Q3rSZmrdlmugQcuQQBwp
         o5NbIpQr+yPi4njCCY8/8N5Peb99DZ0nBPA4nIbKvbzB/ZOtDBiFJrnxkDWu9dFoF+Wl
         DB/qdo1kAxQCuXEblC5742N8KYWYXoK1VybrqFS585WXSMaIYwo/6295m2v0gmIMA5Mf
         V2sxailKo1kHv35kGqcYXtvOGQv6wzcnmlvQMncSD3CZd7cvDTtuhIOFJ6eUULV/UReB
         D7bcKipiRZsmqu/a/iISYWEHIWhZ8bzSdiVudUSBrtkumuwgLT6gHPomdhr2cAPmWbbJ
         hvqA==
X-Gm-Message-State: APjAAAUiwkjMJLe0se1POQRw++4rWS5z8Irq5ih+XvppkdbC2gTnTsI5
	uuF/q+qDABLjIe0kVYY8t8GP2RKnT3+Y2NxUZAdJelWxr01V+9Sdddj9RFKhg7/0Ve8JgNmba7y
	15DNYlgrrJAlHPJEbKyX30b3fXmt7fXyfC4hxLiqHtw9CMDMSn+0Vw8ijEqSk09iWlA==
X-Received: by 2002:a63:b11:: with SMTP id 17mr13916241pgl.283.1565296571517;
        Thu, 08 Aug 2019 13:36:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiYUgcvUGWKNlpH6W7EjdvI5C5nrYLVyYxSjdW3hoDMnzV2+ZHH6MhRfeSwX/BuCVe3/CH
X-Received: by 2002:a63:b11:: with SMTP id 17mr13916192pgl.283.1565296570679;
        Thu, 08 Aug 2019 13:36:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565296570; cv=none;
        d=google.com; s=arc-20160816;
        b=Wwq7vBp/IrCgGRVKFQ+sAo3MKYkITeCeAafXkTG+SBJRTqWpLOsC5VYhH4+1ZwiSLO
         ijQ+9nz5pBaC3h4BYR16lD+uDOZeiStDvqDxOxJwv8D1XQQlPd8lkUs2NN6Yk8K2vv1l
         DoX3aceEq6aGNHlxRU1RDjOxCu/PwMmZlgOr6kFw2R8YY+jaZHG5rEUuivsDp6V+RPqX
         nfXRv6Ak4ZMaOextffznLyJcOKy2FIc1lT/+v7dPQVRK9YcIL5NaSFVB+Fl1A/h0umb4
         L0uCrzHC1Y1JkIbByqRsTnXYlwSTmn8facUz7+coxaT1g4Xi3rucd5Ha41Q3X0eCdJbv
         JY5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=ZZ49snpRr7mPFov6Hyh1szaiWFNeYUXmStPACJSKaRA=;
        b=p7htGCqK3RhWjzhNs+qRmSjUZlH/r+HmXY+PkYp2MzL8UtdxkqInnBiRDtJJHW09tY
         Rkv3QZ5ayg+CZ0B00JsbDVWJQF5CVyakqilgTApqB/goTAPaEsJn8pivZaMDL8YRjdUV
         bQMUGzxmwPy3HWMlM9YTtsrxy6MeSXGS+T/T9R7KV7tPvJK3Mi+BgLtNo3+yMkAkGEcF
         dEMdbygID+9z94JH+QTTUIVaMkO3AvbwetIFkm6B3kXzO3aHWxPXjvVBY6gDQT83VaCb
         jeXjqbFIQU58niAUj+VSCWbDhmXUpRhkq3GZpsD/zfdC3XI3corW56WJjFJfMQp1t/Pd
         3PQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Klhb8HsQ;
       spf=pass (google.com: domain of prvs=3123bb15f2=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3123bb15f2=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q2si2741161pjv.99.2019.08.08.13.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 13:36:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3123bb15f2=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Klhb8HsQ;
       spf=pass (google.com: domain of prvs=3123bb15f2=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3123bb15f2=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x78KSPHI019128
	for <linux-mm@kvack.org>; Thu, 8 Aug 2019 13:36:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=ZZ49snpRr7mPFov6Hyh1szaiWFNeYUXmStPACJSKaRA=;
 b=Klhb8HsQt8tPCzbKC7dpZtIacTMOTpYT4pc2p8Tcic7LcrC108eBMpYxKh8SS7y7Kn+z
 cJHuBZsGf8FfTFeBcx14dC9nlU283r1TajQD/Krg9UVSLcYyzEurDKXfexf7xNLMedQS
 L7b3z0Lv1v2HURbgIuv/sa5YilgtfroT8g8= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u8qpk8uh6-9
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Aug 2019 13:36:09 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 8 Aug 2019 13:36:07 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 7A07C1619126F; Thu,  8 Aug 2019 13:36:05 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH] mm: memcontrol: flush slab vmstats on kmem offlining
Date: Thu, 8 Aug 2019 13:36:04 -0700
Message-ID: <20190808203604.3413318-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-08_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=590 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908080181
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've noticed that the "slab" value in memory.stat is sometimes 0,
even if some children memory cgroups have a non-zero "slab" value.
The following investigation showed that this is the result
of the kmem_cache reparenting in combination with the per-cpu
batching of slab vmstats.

At the offlining some vmstat value may leave in the percpu cache,
not being propagated upwards by the cgroup hierarchy. It means
that stats on ancestor levels are lower than actual. Later when
slab pages are released, the precise number of pages is substracted
on the parent level, making the value negative. We don't show negative
values, 0 is printed instead.

To fix this issue, let's flush percpu slab memcg and lruvec stats
on memcg offlining. This guarantees that numbers on all ancestor
levels are accurate and match the actual number of outstanding
slab pages.

Fixes: fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_caches on cgroup removal")
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e821f34399f..3a5f6f486cdf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3412,6 +3412,50 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
 	return 0;
 }
 
+static void memcg_flush_slab_node_stats(struct mem_cgroup *memcg, int node)
+{
+	struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
+	struct mem_cgroup_per_node *pi;
+	unsigned long recl = 0, unrecl = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		recl += raw_cpu_read(
+			pn->lruvec_stat_cpu->count[NR_SLAB_RECLAIMABLE]);
+		unrecl += raw_cpu_read(
+			pn->lruvec_stat_cpu->count[NR_SLAB_UNRECLAIMABLE]);
+	}
+
+	for (pi = pn; pi; pi = parent_nodeinfo(pi, node)) {
+		atomic_long_add(recl,
+				&pi->lruvec_stat[NR_SLAB_RECLAIMABLE]);
+		atomic_long_add(unrecl,
+				&pi->lruvec_stat[NR_SLAB_UNRECLAIMABLE]);
+	}
+}
+
+static void memcg_flush_slab_vmstats(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *mi;
+	unsigned long recl = 0, unrecl = 0;
+	int node, cpu;
+
+	for_each_possible_cpu(cpu) {
+		recl += raw_cpu_read(
+			memcg->vmstats_percpu->stat[NR_SLAB_RECLAIMABLE]);
+		unrecl += raw_cpu_read(
+			memcg->vmstats_percpu->stat[NR_SLAB_UNRECLAIMABLE]);
+	}
+
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi)) {
+		atomic_long_add(recl, &mi->vmstats[NR_SLAB_RECLAIMABLE]);
+		atomic_long_add(unrecl, &mi->vmstats[NR_SLAB_UNRECLAIMABLE]);
+	}
+
+	for_each_node(node)
+		memcg_flush_slab_node_stats(memcg, node);
+}
+
 static void memcg_offline_kmem(struct mem_cgroup *memcg)
 {
 	struct cgroup_subsys_state *css;
@@ -3432,7 +3476,14 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 	if (!parent)
 		parent = root_mem_cgroup;
 
+	/*
+	 * Deactivate and reparent kmem_caches. Then Flush percpu
+	 * slab statistics to have precise values at the parent and
+	 * all ancestor levels. It's required to keep slab stats
+	 * accurate after the reparenting of kmem_caches.
+	 */
 	memcg_deactivate_kmem_caches(memcg, parent);
+	memcg_flush_slab_vmstats(memcg);
 
 	kmemcg_id = memcg->kmemcg_id;
 	BUG_ON(kmemcg_id < 0);
-- 
2.21.0

