Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6533DC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1359A20665
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="KgjE/QqS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1359A20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 855936B0010; Wed,  5 Jun 2019 09:37:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 807786B0266; Wed,  5 Jun 2019 09:37:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6586E6B0269; Wed,  5 Jun 2019 09:37:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7496B0010
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:37:28 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g11so16073548plt.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:37:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8yYACzlvtHpZ4BGD0wo6T7cr3uUD8GGsT+k2KVWRDBw=;
        b=nJU2dlyNNp7AbO1ToPwjvL/v2ZubIFUHOOxdEbwhG8npBH+cuSgBMP/oX3O4jNAD2N
         MRzT6+uSB6apSoza7oIBEmpt4BNqGruErXycLEXHYkZZ24Rp0n+M6McHLxzDF7d3J6jT
         psqNiMZUsDUylfVE7DwXcTRdvhcTgrItD/sWgjxJNvUlH025RxoOuv0NwEbYhV1Y4cc5
         sCRQ2gGOZdAnLiB3CfBsGBZoVXrFGIUZfnc6SCCgBK8EHnO1ER2FRhR9GQp6z30+EZhF
         wjebjrRV3Z7XZ2bkj95aWaxkOi7T0zA4UaDQ4SSrWCbjBsy45ZNgy2nbVlNzhgTK4gHY
         bqRw==
X-Gm-Message-State: APjAAAUeJ/hBS8vxEjStx61OgCDjgLCVb1/IM1L6h2Bxibel2ZkAkx2y
	tATRrSBPrZSLgGAknc6LF/6qwTw1N8gsvopu1rMyWU+0FOH/9z6j21WMJJDiBHu77mouPwvx3yr
	nciJOJ1uG4WuD8qL4HwS+OaL2OyI1ZqycKu3KKgrIfAaLuvKpoHU5OUqFDKIiHhuTcg==
X-Received: by 2002:a17:902:b110:: with SMTP id q16mr35850777plr.218.1559741847608;
        Wed, 05 Jun 2019 06:37:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5gCYTfGgYFo5tLpXeoAazFfeq66l0xGR60sisrHVoMjDQ2/Q3hPKeccN3zCZ6LZDCyoHd
X-Received: by 2002:a17:902:b110:: with SMTP id q16mr35850674plr.218.1559741846647;
        Wed, 05 Jun 2019 06:37:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559741846; cv=none;
        d=google.com; s=arc-20160816;
        b=INKn3rsGy/XhBPa++mJNVstp0w/QPbiV6yNgVZgf+6oqpGYVjme28en8c6iPWl4a9C
         731xdEWLDheVk+TRlNcjQ/Y0lJebqjOCPu1mn9FsRl6+YdPCs0bb78sbv23Txn8sJlOy
         mCu80wcfa3AnK26r+rlP2lcamEdxNDzhI0pCp/c2BtFm1b9jQjr+DaTttTaDOsMMSGb+
         MDddBZ05Xp3xSQ5+vzTSbugfCcp5+NgsKrMR+JR3pvwVhy8vGFFFCpaKdfr3lHkVfDIT
         SxEntnWWmW7X4ZUYDuCZNWquRD6nJhMyVJanKdKUmFFxsszW9i1TFmOoHK2PwdqChmGW
         JJ/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8yYACzlvtHpZ4BGD0wo6T7cr3uUD8GGsT+k2KVWRDBw=;
        b=AiI24NpgjHbNv++jP58zMxCA28d0IkplOwl52/nlJM5J8YHbXMtESBhXDt0E4WuYHf
         aVsatQEkCLqsDuan1nh3QE3b6bWnVvJcxHoOtjShy+6fPzXqymOwKtyMAO/XuVinooy6
         a1iRkmHQRgTaiOPtXhMzaJ8u4n7sowMeWWJlhuS53KlVsLonnbY1Jft9sgwuT9TXg4C3
         PuF4eFSHM74yiskLk8qE7Ro0YpTltKHHkV1G1Z9UExhMPyX1XQ6hPdrwYg0Z4lYOVI7R
         MYXLELRwSfHIMGLB2GgvrNsAm1LHHNnWLZxsSGokC+KaTh/GpMr0htRODnEbqZWa4gnt
         T3RQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="KgjE/QqS";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k8si26495552pgi.123.2019.06.05.06.37.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:37:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="KgjE/QqS";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DTIKT119560;
	Wed, 5 Jun 2019 13:37:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=8yYACzlvtHpZ4BGD0wo6T7cr3uUD8GGsT+k2KVWRDBw=;
 b=KgjE/QqSvEaVhxjmUZSwxl3HJ81jm0KfBRa6GrQqRCsxSbtGJII3Vn0krmhid9ln8mxl
 /IAuycz4jC5dI7ZQ+BbIdfgrUIddnOrjMaUlQBmSmAjx7jbhhKxVHO0tmRvnjBa6T652
 1mOFsUnAF0jSPfRCh+xnFIDivnRf2yGS/XbnthP+tMOotD5MgJmBMZacmbItiC7n9UY8
 xouolCSMtTywmiU/Bp/x438/4Fs3wutxNVFHbbgMiC/WVKzta3VvayOSXeVvQmIe2eSu
 WNjobOq+HhQiFUAGXPjGTblcavUC3T9/ef9esBe90wb/Cr5yjigYZ00ZXYJUirGpd8z4 7w== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2sugstjn4c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:10 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55Db1Z1002510;
	Wed, 5 Jun 2019 13:37:10 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2swngkw19a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:09 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x55Db9LB022921;
	Wed, 5 Jun 2019 13:37:09 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 05 Jun 2019 06:37:08 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: hannes@cmpxchg.org, jiangshanlai@gmail.com, lizefan@huawei.com,
        tj@kernel.org
Cc: bsd@redhat.com, dan.j.williams@intel.com, daniel.m.jordan@oracle.com,
        dave.hansen@intel.com, juri.lelli@redhat.com, mhocko@kernel.org,
        peterz@infradead.org, steven.sistare@oracle.com, tglx@linutronix.de,
        tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: [RFC v2 5/5] ktask, cgroup: attach helper threads to the master thread's cgroup
Date: Wed,  5 Jun 2019 09:36:50 -0400
Message-Id: <20190605133650.28545-6-daniel.m.jordan@oracle.com>
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

ktask tasks are expensive, and helper threads are not currently
throttled by the master's cgroup, so helpers' resource usage is
unbounded.

Attach helper threads to the master thread's cgroup to ensure helpers
get this throttling.

It's possible for the master to be migrated to a new cgroup before the
task is finished.  In that case, to keep it simple, the helpers continue
executing in the original cgroup.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/cgroup.h | 26 ++++++++++++++++++++++++++
 kernel/ktask.c         | 32 ++++++++++++++++++++------------
 2 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index de578e29077b..67b2c469f17f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -532,6 +532,28 @@ static inline struct cgroup *task_dfl_cgroup(struct task_struct *task)
 	return task_css_set(task)->dfl_cgrp;
 }
 
+/**
+ * task_get_dfl_cgroup - find and get the default hierarchy cgroup for task
+ * @task: the target task
+ *
+ * Find the default hierarchy cgroup for @task, take a reference on it, and
+ * return it.  Guaranteed to return a valid cgroup.
+ */
+static inline struct cgroup *task_get_dfl_cgroup(struct task_struct *task)
+{
+	struct cgroup *cgroup;
+
+	rcu_read_lock();
+	while (true) {
+		cgroup = task_dfl_cgroup(task);
+		if (likely(css_tryget_online(&cgroup->self)))
+			break;
+		cpu_relax();
+	}
+	rcu_read_unlock();
+	return cgroup;
+}
+
 static inline struct cgroup *cgroup_dfl_root(void)
 {
 	return &cgrp_dfl_root.cgrp;
@@ -705,6 +727,10 @@ static inline struct cgroup *task_dfl_cgroup(struct task_struct *task)
 {
 	return NULL;
 }
+static inline struct cgroup *task_get_dfl_cgroup(struct task_struct *task)
+{
+	return NULL;
+}
 static inline int cgroup_attach_task_all(struct task_struct *from,
 					 struct task_struct *t) { return 0; }
 static inline int cgroupstats_build(struct cgroupstats *stats,
diff --git a/kernel/ktask.c b/kernel/ktask.c
index 15d62ed7c67e..b047f30f77fa 100644
--- a/kernel/ktask.c
+++ b/kernel/ktask.c
@@ -14,6 +14,7 @@
 
 #ifdef CONFIG_KTASK
 
+#include <linux/cgroup.h>
 #include <linux/cpu.h>
 #include <linux/cpumask.h>
 #include <linux/init.h>
@@ -49,7 +50,7 @@ enum ktask_work_flags {
 
 /* Used to pass ktask data to the workqueue API. */
 struct ktask_work {
-	struct work_struct	kw_work;
+	struct cgroup_work	kw_work;
 	struct ktask_task	*kw_task;
 	int			kw_ktask_node_i;
 	int			kw_queue_nid;
@@ -76,6 +77,7 @@ struct ktask_task {
 	size_t			kt_nr_nodes;
 	size_t			kt_nr_nodes_left;
 	int			kt_error; /* first error from thread_func */
+	struct cgroup		*kt_cgroup;
 #ifdef CONFIG_LOCKDEP
 	struct lockdep_map	kt_lockdep_map;
 #endif
@@ -103,16 +105,16 @@ static void ktask_init_work(struct ktask_work *kw, struct ktask_task *kt,
 {
 	/* The master's work is always on the stack--in __ktask_run_numa. */
 	if (flags & KTASK_WORK_MASTER)
-		INIT_WORK_ONSTACK(&kw->kw_work, ktask_thread);
+		INIT_CGROUP_WORK_ONSTACK(&kw->kw_work, ktask_thread);
 	else
-		INIT_WORK(&kw->kw_work, ktask_thread);
+		INIT_CGROUP_WORK(&kw->kw_work, ktask_thread);
 	kw->kw_task = kt;
 	kw->kw_ktask_node_i = ktask_node_i;
 	kw->kw_queue_nid = queue_nid;
 	kw->kw_flags = flags;
 }
 
-static void ktask_queue_work(struct ktask_work *kw)
+static void ktask_queue_work(struct ktask_work *kw, struct cgroup *cgroup)
 {
 	struct workqueue_struct *wq;
 
@@ -128,7 +130,8 @@ static void ktask_queue_work(struct ktask_work *kw)
 	}
 
 	WARN_ON(!wq);
-	WARN_ON(!queue_work_node(kw->kw_queue_nid, wq, &kw->kw_work));
+	WARN_ON(!queue_cgroup_work_node(kw->kw_queue_nid, wq, &kw->kw_work,
+		cgroup));
 }
 
 /* Returns true if we're migrating this part of the task to another node. */
@@ -163,14 +166,15 @@ static bool ktask_node_migrate(struct ktask_node *old_kn, struct ktask_node *kn,
 
 	WARN_ON(kw->kw_flags & (KTASK_WORK_FINISHED | KTASK_WORK_UNDO));
 	ktask_init_work(kw, kt, ktask_node_i, new_queue_nid, kw->kw_flags);
-	ktask_queue_work(kw);
+	ktask_queue_work(kw, kt->kt_cgroup);
 
 	return true;
 }
 
 static void ktask_thread(struct work_struct *work)
 {
-	struct ktask_work  *kw = container_of(work, struct ktask_work, kw_work);
+	struct cgroup_work *cw = container_of(work, struct cgroup_work, work);
+	struct ktask_work  *kw = container_of(cw, struct ktask_work, kw_work);
 	struct ktask_task  *kt = kw->kw_task;
 	struct ktask_ctl   *kc = &kt->kt_ctl;
 	struct ktask_node  *kn = &kt->kt_nodes[kw->kw_ktask_node_i];
@@ -455,7 +459,7 @@ static void __ktask_wait_for_completion(struct ktask_task *kt,
 		while (!(READ_ONCE(work->kw_flags) & KTASK_WORK_FINISHED))
 			cpu_relax();
 	} else {
-		flush_work_at_nice(&work->kw_work, task_nice(current));
+		flush_work_at_nice(&work->kw_work.work, task_nice(current));
 	}
 }
 
@@ -530,15 +534,18 @@ int __ktask_run_numa(struct ktask_node *nodes, size_t nr_nodes,
 	kt.kt_chunk_size = ktask_chunk_size(kt.kt_total_size,
 					    ctl->kc_min_chunk_size, nr_works);
 
+	/* Ensure the master's cgroup throttles helper threads. */
+	kt.kt_cgroup = task_get_dfl_cgroup(current);
 	list_for_each_entry(work, &unfinished_works, kw_list)
-		ktask_queue_work(work);
+		ktask_queue_work(work, kt.kt_cgroup);
 
 	/* Use the current thread, which saves starting a workqueue worker. */
 	ktask_init_work(&kw, &kt, 0, nodes[0].kn_nid, KTASK_WORK_MASTER);
 	INIT_LIST_HEAD(&kw.kw_list);
-	ktask_thread(&kw.kw_work);
+	ktask_thread(&kw.kw_work.work);
 
 	ktask_wait_for_completion(&kt, &unfinished_works, &finished_works);
+	cgroup_put(kt.kt_cgroup);
 
 	if (kt.kt_error != KTASK_RETURN_SUCCESS && ctl->kc_undo_func)
 		ktask_undo(nodes, nr_nodes, ctl, &finished_works, &kw);
@@ -611,13 +618,14 @@ void __init ktask_init(void)
 	if (!ktask_rlim_init())
 		goto out;
 
-	ktask_wq = alloc_workqueue("ktask_wq", WQ_UNBOUND, 0);
+	ktask_wq = alloc_workqueue("ktask_wq", WQ_UNBOUND | WQ_CGROUP, 0);
 	if (!ktask_wq) {
 		pr_warn("disabled (failed to alloc ktask_wq)");
 		goto out;
 	}
 
-	ktask_nonuma_wq = alloc_workqueue("ktask_nonuma_wq", WQ_UNBOUND, 0);
+	ktask_nonuma_wq = alloc_workqueue("ktask_nonuma_wq",
+					  WQ_UNBOUND | WQ_CGROUP, 0);
 	if (!ktask_nonuma_wq) {
 		pr_warn("disabled (failed to alloc ktask_nonuma_wq)");
 		goto alloc_fail;
-- 
2.21.0

