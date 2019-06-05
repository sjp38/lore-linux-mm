Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94142C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4265620665
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JTf9y2n/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4265620665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F82E6B000E; Wed,  5 Jun 2019 09:37:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CDE86B0010; Wed,  5 Jun 2019 09:37:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 482866B0269; Wed,  5 Jun 2019 09:37:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 098BE6B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:37:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u7so18698116pfh.17
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:37:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ww3UO2Y64LsDIspP9nYZfcD+xc5topDBTlHYu02FoZk=;
        b=Ob3QTY53GIy5VXZfLMxJaD4QXdink1iASljBkcyEhwXlnY0lZnOtSWewf+DFzenMZf
         EvB9nFFZFwOmSVWG+Ze0B33HPV/brawpzYUqz8/yZ2f082dEB/PrdMQj9xeydftbdJEr
         QOT4fxTbZ+SmMbP9lylsqWZWPIV03mGhTaACOO7OfSY2l9ZExBm4lfmGNU4UYtdr0wRn
         FAYT1QSi4REkIfONNj/a7zs9xCYxU/88etWf5cWT9+7u233PtwD2OK+TboswGrSbFbsc
         9+FsFrs/pJJgtn0w3g1bhvp+/FojUOq9yANPrwIAVo4hwXVKDND4jNv+rLBhmnIqcnAE
         5Qrw==
X-Gm-Message-State: APjAAAUI7FneuOfbHm0Qizs3JcxXcOCQlKhoIZv3VlXaVv0lJd0Tpt1g
	25p68CGz1+Ujof8+mbWpA1WVHYKaPIHtNCx715tMldpf6E6PO06UOe/PsghxGoHRr2w9jGH2ull
	i7wASTosw4b38cIcY/jCKf2qNz4SwTTggMvcWx+J78nfv2GYz2e5Ale6yDW4ZuL2ppA==
X-Received: by 2002:a62:bd0e:: with SMTP id a14mr46169465pff.44.1559741845452;
        Wed, 05 Jun 2019 06:37:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7N9hh69DkPkj+XRvTfgWed7MT2a+lj/BlwOanm4NjK3mS746Dx9sh5rWcucZiYbi436na
X-Received: by 2002:a62:bd0e:: with SMTP id a14mr46169364pff.44.1559741844578;
        Wed, 05 Jun 2019 06:37:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559741844; cv=none;
        d=google.com; s=arc-20160816;
        b=aHArLHJg6rPOfG8PS3ucBPZhdlBS2EIGHp0Tc49dbgkcFHkm0GsUCRvLuWI8NBFC+Z
         1RHj9syRvdIXhgX39YpEtPMfaHmoal1Azc08ASRsNZ4z6G9xQqqX+8Mi9go8I+Pi84cq
         PADdv4pomg3QWhgOcxtfzHbF3Xiw3TS5SW/fgkMEi/U0BihCfHFSanvlEsah+JmX/HQ5
         1L09UZ5/D/YoE7qBVheRuX5+AXxEwVt38TBbptolyBM+EEX5DdtJV+HIl3wUBKr21Acu
         I0HLwYWQeP8unORmT5dksjdOs3eRPAJbPIeKQMj1YOzVt829QfZf6WIA8NQNf6s9QrLr
         nYnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Ww3UO2Y64LsDIspP9nYZfcD+xc5topDBTlHYu02FoZk=;
        b=RpERhASg0kuvGHF37V5I0v7MUL1xNZSrVV20aKGnL6aOxpp931YxzVewH8KknIc/Vu
         JlvVkG23A8xvICLCg2lmOhHG1chzmzjrhNmzYDOH0eRSSafC7pkL0k4POJGAZDcgvoEd
         /hlB9JGWRUmzhBx7mttU38LQkHGhU8bickmq8JX2sf5txAvYkOF1hZNyigOd4kIw9vtH
         VFLE1JyAyRexhSKVMlXQGIpttVHgaZfbJh87o43NC8cCHPFGnmcIyux6BpRpMXyTw6qk
         TM+MYkcbIpXv4rTWVUpkOSRaLeC5yheU4473VbmZVU9A3saBKaLqyTlEClG3fQ9oX5OQ
         rfTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="JTf9y2n/";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c32si26999882pje.0.2019.06.05.06.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:37:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="JTf9y2n/";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DTRP0119591;
	Wed, 5 Jun 2019 13:37:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=Ww3UO2Y64LsDIspP9nYZfcD+xc5topDBTlHYu02FoZk=;
 b=JTf9y2n/Sjoe4pCzMh/uy2QTChLH80qdYMT4tF5HvvdqnddEB6F4E7F4ln19olEOst+P
 s1d70dD4bMVQKxP4Wu+TyCMvlVbnlNw1Av/XCyGAad3Kwj35hUXdccR6qBwRPSim9lCU
 7Rb092NiSatD4WL50ijDmD/UXKm3bjtZxCByZFaqV88vG2iSAbuTpL79Hr6kx3DNUG60
 AllDwHwTDfclIdN9dy8zeJbbxLGmOLYPfZcfR/ES2Mtuqu9X1mGhxP5+Spi6RjmpSb8q
 nMtE1DTLPDzZD13aqefL2bhadYVaee21oqJeziL5s7NwKS9ai+fBjUFarxilJfvPWhIH gA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sugstjn48-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:09 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DZsGf069290;
	Wed, 5 Jun 2019 13:37:08 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2swnghw2j7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:08 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x55Db4vD022901;
	Wed, 5 Jun 2019 13:37:04 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 05 Jun 2019 06:37:04 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: hannes@cmpxchg.org, jiangshanlai@gmail.com, lizefan@huawei.com,
        tj@kernel.org
Cc: bsd@redhat.com, dan.j.williams@intel.com, daniel.m.jordan@oracle.com,
        dave.hansen@intel.com, juri.lelli@redhat.com, mhocko@kernel.org,
        peterz@infradead.org, steven.sistare@oracle.com, tglx@linutronix.de,
        tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: [RFC v2 3/5] workqueue, memcontrol: make memcg throttle workqueue workers
Date: Wed,  5 Jun 2019 09:36:48 -0400
Message-Id: <20190605133650.28545-4-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906050087
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906050087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Attaching a worker to a css_set isn't enough for all controllers to
throttle it.  In particular, the memory controller currently bypasses
accounting for kernel threads.

Support memcg accounting for cgroup-aware workqueue workers so that
they're appropriately throttled.

Another, probably better way to do this is to have kernel threads, or
even specifically cgroup-aware workqueue workers, call
memalloc_use_memcg and memalloc_unuse_memcg during cgroup migration
(memcg attach callback maybe).

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 kernel/workqueue.c          | 26 ++++++++++++++++++++++++++
 kernel/workqueue_internal.h |  5 +++++
 mm/memcontrol.c             | 26 ++++++++++++++++++++++++--
 3 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 89b90899bc09..c8cc69e296c0 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -50,6 +50,8 @@
 #include <linux/sched/isolation.h>
 #include <linux/nmi.h>
 #include <linux/cgroup.h>
+#include <linux/memcontrol.h>
+#include <linux/sched/mm.h>
 
 #include "workqueue_internal.h"
 
@@ -1829,6 +1831,28 @@ static inline bool worker_in_child_cgroup(struct worker *worker)
 	return (worker->flags & WORKER_CGROUP) && cgroup_parent(worker->cgroup);
 }
 
+/* XXX Put this in the memory controller's attach callback. */
+#ifdef CONFIG_MEMCG
+static void worker_unuse_memcg(struct worker *worker)
+{
+	if (worker->task->active_memcg) {
+		struct mem_cgroup *memcg = worker->task->active_memcg;
+
+		memalloc_unuse_memcg();
+		css_put(&memcg->css);
+	}
+}
+
+static void worker_use_memcg(struct worker *worker)
+{
+	struct mem_cgroup *memcg;
+
+	worker_unuse_memcg(worker);
+	memcg = mem_cgroup_from_css(task_get_css(worker->task, memory_cgrp_id));
+	memalloc_use_memcg(memcg);
+}
+#endif /* CONFIG_MEMCG */
+
 static void attach_worker_to_dfl_root(struct worker *worker)
 {
 	int ret;
@@ -1841,6 +1865,7 @@ static void attach_worker_to_dfl_root(struct worker *worker)
 		rcu_read_lock();
 		worker->cgroup = task_dfl_cgroup(worker->task);
 		rcu_read_unlock();
+		worker_unuse_memcg(worker);
 	} else {
 		/*
 		 * TODO Modify the cgroup migration path to guarantee that a
@@ -1880,6 +1905,7 @@ static void attach_worker_to_cgroup(struct worker *worker,
 
 	if (cgroup_attach_kthread(cgroup) == 0) {
 		worker->cgroup = cgroup;
+		worker_use_memcg(worker);
 	} else {
 		/*
 		 * Attach failed, so attach to the default root so the
diff --git a/kernel/workqueue_internal.h b/kernel/workqueue_internal.h
index 3ad5861258ca..f254b93edc2c 100644
--- a/kernel/workqueue_internal.h
+++ b/kernel/workqueue_internal.h
@@ -79,6 +79,11 @@ work_func_t wq_worker_last_func(struct task_struct *task);
 
 #ifdef CONFIG_CGROUPS
 
+#ifndef CONFIG_MEMCG
+static inline void worker_use_memcg(struct worker *worker) {}
+static inline void worker_unuse_memcg(struct worker *worker) {}
+#endif /* CONFIG_MEMCG */
+
 /*
  * A barrier work running in a cgroup-aware worker pool needs to specify a
  * cgroup.  For simplicity, WQ_BARRIER_CGROUP makes the worker stay in its
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 81a0d3914ec9..1a80931b124a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2513,9 +2513,31 @@ static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 
 static inline bool memcg_kmem_bypass(void)
 {
-	if (in_interrupt() || !current->mm || (current->flags & PF_KTHREAD))
+	if (in_interrupt())
 		return true;
-	return false;
+
+	if (unlikely(current->flags & PF_WQ_WORKER)) {
+		struct cgroup *parent;
+
+		/*
+		 * memcg should throttle cgroup-aware workers.  Infer the
+		 * worker is cgroup-aware by its presence in a non-root cgroup.
+		 *
+		 * This test won't detect a cgroup-aware worker attached to the
+		 * default root, but in that case memcg doesn't need to
+		 * throttle it anyway.
+		 *
+		 * XXX One alternative to this awkward block is adding a
+		 * cgroup-aware-worker bit to task_struct.
+		 */
+		rcu_read_lock();
+		parent = cgroup_parent(task_dfl_cgroup(current));
+		rcu_read_unlock();
+
+		return !parent;
+	}
+
+	return !current->mm || (current->flags & PF_KTHREAD);
 }
 
 /**
-- 
2.21.0

