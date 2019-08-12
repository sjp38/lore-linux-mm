Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0FD8C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:38:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EBBA20679
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:38:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="MIb4O3Hi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EBBA20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C5046B0003; Mon, 12 Aug 2019 19:38:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07A256B0005; Mon, 12 Aug 2019 19:38:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E30CC6B0006; Mon, 12 Aug 2019 19:38:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0024.hostedemail.com [216.40.44.24])
	by kanga.kvack.org (Postfix) with ESMTP id C41D86B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:38:01 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7072552A2
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:38:01 +0000 (UTC)
X-FDA: 75815391162.30.dad89_bcb916a33234
X-HE-Tag: dad89_bcb916a33234
X-Filterd-Recvd-Size: 4813
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:38:00 +0000 (UTC)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x7CNb71k012878
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:38:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=tVey46Cm3zNCRvto/Hdvva3sak33TFnvfc8h7R+vI7Y=;
 b=MIb4O3Hiizwuwf7yUFUwxnzEV0yRBP7LlCmdkJ4WjeH6zOD2N2xgbpAqrmByyq87MEgS
 6VaEboh9wxtdU7GQRgWDuMjDoALxE7LMmWSRlfjzIUVf7HmEXItNYzx/LLH0sV/dD6sS
 S8Ab7T2UnHEnjTZbHMFPfX0QtLYwLZn4JO4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2ubbbpstum-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:38:00 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 12 Aug 2019 16:37:58 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 86A9E164048AD; Mon, 12 Aug 2019 16:37:56 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH] mm: memcontrol: flush percpu vmevents before releasing memcg
Date: Mon, 12 Aug 2019 16:37:54 -0700
Message-ID: <20190812233754.2570543-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=884 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908120232
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similar to vmstats, percpu caching of local vmevents leads to an
accumulation of errors on non-leaf levels. This happens because
some leftovers may remain in percpu caches, so that they are
never propagated up by the cgroup tree and just disappear into
nonexistence with on releasing of the memory cgroup.

To fix this issue let's accumulate and propagate percpu vmevents
values before releasing the memory cgroup similar to what we're
doing with vmstats.

Since on cpu hotplug we do flush percpu vmstats anyway, we can
iterate only over online cpus.

Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6d2427abcc0c..249187907339 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3459,6 +3459,25 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg, bool slab_only)
 	}
 }
 
+static void memcg_flush_percpu_vmevents(struct mem_cgroup *memcg)
+{
+	unsigned long events[NR_VM_EVENT_ITEMS];
+	struct mem_cgroup *mi;
+	int cpu, i;
+
+	for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+		events[i] = 0;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+			events[i] += raw_cpu_read(
+				memcg->vmstats_percpu->events[i]);
+
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
+		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+			atomic_long_add(events[i], &mi->vmevents[i]);
+}
+
 static void memcg_offline_kmem(struct mem_cgroup *memcg)
 {
 	struct cgroup_subsys_state *css;
@@ -4860,10 +4879,11 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	int node;
 
 	/*
-	 * Flush percpu vmstats to guarantee the value correctness
+	 * Flush percpu vmstats and vmevents to guarantee the value correctness
 	 * on parent's and all ancestor levels.
 	 */
 	memcg_flush_percpu_vmstats(memcg, false);
+	memcg_flush_percpu_vmevents(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
-- 
2.21.0


