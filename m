Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B218C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 092AE20665
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="wVQiwl4e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 092AE20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 414996B0269; Wed,  5 Jun 2019 09:37:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3753B6B026B; Wed,  5 Jun 2019 09:37:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14F736B026C; Wed,  5 Jun 2019 09:37:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA7116B0269
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:37:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v62so10237103pgb.0
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:37:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5HG2ykM8vZOQrDb3fIWkzYXdll7yeKv29Vo426kliWk=;
        b=h2DmprRyd8r32YgXRennl4h8Vf0t3HXRd6SP7uHMd5Epe31FofGHopHi3sfnVNjgwO
         +58tulIMGih0JLifR5qJ5iAP1qwXqH+7XC8wxxlS/CecKzdqKbzAdLdYoTq6CFMBt1/x
         4SgeCIeCfijwIB1WhklxfD7UC+NuOy3yimfBFkhb4gVteEuYHfK7hnbEnV0xIXoiLpSf
         MppbKGqvmNbYYdv2XfP9WBlZPXu2LA428NBgLEM9yKTAleRJG6ZLx2OtmWEHakDuUZhR
         /fhYPSb1ndnPvdGm+6ZfjVSBrdVKO+meD4ZgEY5Q8lrltzI7nTC4vhtgb576Z//thiNj
         TtBA==
X-Gm-Message-State: APjAAAVikJbeW5nb7knvqg07pAFmMjtgdGdDX9I9jd5qo5l4JDS4mR9i
	+7c16oI/S2DpesiaxK89X8uP8w8uJ7q8N22/MHCJNUj2NhTOM+sjNrpZ2qcxA81cWHAlw7IMah4
	mb77rEM9cI+tBKqhDPuEAIcEYnHxWRU9y+bNdFZpMbC7JQZzO7gecJ5YD8C2VOMz41w==
X-Received: by 2002:a62:5f42:: with SMTP id t63mr46635638pfb.83.1559741850205;
        Wed, 05 Jun 2019 06:37:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdTxzTwB7PXbV76M+2icfWBwDNaAxUwcmIc9yDhSF7NM1JP/csJKelBvhOl5oCNjtiEyqs
X-Received: by 2002:a62:5f42:: with SMTP id t63mr46635442pfb.83.1559741848406;
        Wed, 05 Jun 2019 06:37:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559741848; cv=none;
        d=google.com; s=arc-20160816;
        b=yDus3vPi4L9R2VJW2eBUeIvqU0OWRVkrVfvFthETv7YuOtCG2CCsk42NCy/6MB7HOx
         MzQojVCNKtgnxwBrrGDkww8m5wAAITS6vNHFlNw9JgF+uJm6hFkFBtqel6+zcQSKPC5w
         ivHPyTTr+PnpBTNAsSUfeBktF1D65vlYyiKI5o6NhQK1sOPllLD0VxLHgCzHjkLJ9vsm
         Rq6wmiSwIRADaX7k2D3FXrK43s+sbPDHjEJAcz8oWoCd379N8Ju0AtAb2G6+6SUJ1DZG
         wauXEec5kpgXuUV3SIQjCRUuSJ8g/HaS+c9vS8II3qnhePBIOdrzky+fJ1gHlAgXjxA1
         3ifw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5HG2ykM8vZOQrDb3fIWkzYXdll7yeKv29Vo426kliWk=;
        b=f7eonj+Q6K/Djng5BQUqAKqG/uFHL1oMDB4bUgQL4xbO/S6wr2Gkg6RwjFcqy1Eu8N
         r/fSKOOq20Er5u/pcNRy+qCOeWqBvVZhAWVbBpA0tah+/TFgN6itU9S/Cxy+OP1/BjMq
         z+ZC5BNav4l0tWbb9WJA10S40VbQb4hvwjBh+EVyA8cL67ORRK1mjvveR8PzY+oJaqk1
         2yPybk+gK2LvtcjwczzJEv1DXcF6xtOku9v82RmoytOXfcJ1gXCboRtVI3GSh5TcEx1+
         Y516MjCdWdJEZ5fj6YiM1ennMslt8PBy5D8Pj6QOmbquNDSfgi513iolzrmiDmL+zW5x
         1BIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wVQiwl4e;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id w5si2402160pjt.86.2019.06.05.06.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:37:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wVQiwl4e;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DTFtq140137;
	Wed, 5 Jun 2019 13:37:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=5HG2ykM8vZOQrDb3fIWkzYXdll7yeKv29Vo426kliWk=;
 b=wVQiwl4eq6RdtcOrUhG2urGoSgRCEtxreZmXzLn1QE4jXW/ch9Hvl80KvnR/POVr2uYQ
 AhkTGOI5sfKakZfdhdgnCTP+E59MjRhkL8zgQjWgL2Rpp2az2D5MRklVUVeXJj2OpZzS
 uQwPeZeUVLGLp5XYOODEnHVtcOg9RMCuPEeODOmfWmM+F1mG5ucpUqgB01K0BInsxxjG
 DDQ5ttWHwS8kZ99Y+ZbzjBGNhqoS9Wvv3nNLdrBKkgO4fmuwHx0b/q9psEYqlGIWRXHc
 9ZBWXF0bjHpjQOzpS8Y/z15ywYKpU2Ihe9/V/hJA2wJ2WHlibAYpUgqIa/UmjLU2dVlA wg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2suevdjvbg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:09 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DadLx034051;
	Wed, 5 Jun 2019 13:37:09 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2swnhc4y3e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:08 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x55Db23H027139;
	Wed, 5 Jun 2019 13:37:02 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 05 Jun 2019 06:37:02 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: hannes@cmpxchg.org, jiangshanlai@gmail.com, lizefan@huawei.com,
        tj@kernel.org
Cc: bsd@redhat.com, dan.j.williams@intel.com, daniel.m.jordan@oracle.com,
        dave.hansen@intel.com, juri.lelli@redhat.com, mhocko@kernel.org,
        peterz@infradead.org, steven.sistare@oracle.com, tglx@linutronix.de,
        tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: [RFC v2 2/5] workqueue, cgroup: add cgroup-aware workqueues
Date: Wed,  5 Jun 2019 09:36:47 -0400
Message-Id: <20190605133650.28545-3-daniel.m.jordan@oracle.com>
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

Workqueue workers ignore the cgroup of the queueing task, so workers'
resource usage normally goes unaccounted, with exceptions such as cgroup
writeback, and so can arbitrarily exceed controller limits.

Add cgroup awareness to workqueue workers.  Do it only for unbound
workqueue since these tend to be the most resource intensive.  There's a
design overview in the cover letter.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/cgroup.h          |  11 ++
 include/linux/workqueue.h       |  85 ++++++++++++
 kernel/cgroup/cgroup-internal.h |   1 -
 kernel/workqueue.c              | 236 +++++++++++++++++++++++++++++---
 kernel/workqueue_internal.h     |  45 ++++++
 5 files changed, 360 insertions(+), 18 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ad78784e3692..de578e29077b 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -91,6 +91,7 @@ extern struct css_set init_css_set;
 #define cgroup_subsys_on_dfl(ss)						\
 	static_branch_likely(&ss ## _on_dfl_key)
 
+bool cgroup_on_dfl(const struct cgroup *cgrp);
 bool css_has_online_children(struct cgroup_subsys_state *css);
 struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss);
 struct cgroup_subsys_state *cgroup_e_css(struct cgroup *cgroup,
@@ -531,6 +532,11 @@ static inline struct cgroup *task_dfl_cgroup(struct task_struct *task)
 	return task_css_set(task)->dfl_cgrp;
 }
 
+static inline struct cgroup *cgroup_dfl_root(void)
+{
+	return &cgrp_dfl_root.cgrp;
+}
+
 static inline int cgroup_attach_kthread_to_dfl_root(void)
 {
 	return cgroup_attach_kthread(&cgrp_dfl_root.cgrp);
@@ -694,6 +700,11 @@ struct cgroup_subsys_state;
 struct cgroup;
 
 static inline void css_put(struct cgroup_subsys_state *css) {}
+static inline void cgroup_put(struct cgroup *cgrp) {}
+static inline struct cgroup *task_dfl_cgroup(struct task_struct *task)
+{
+	return NULL;
+}
 static inline int cgroup_attach_task_all(struct task_struct *from,
 					 struct task_struct *t) { return 0; }
 static inline int cgroupstats_build(struct cgroupstats *stats,
diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index b5bc12cc1dde..c200ab5268df 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -14,7 +14,9 @@
 #include <linux/atomic.h>
 #include <linux/cpumask.h>
 #include <linux/rcupdate.h>
+#include <linux/numa.h>
 
+struct cgroup;
 struct workqueue_struct;
 
 struct work_struct;
@@ -133,6 +135,13 @@ struct rcu_work {
 	struct workqueue_struct *wq;
 };
 
+struct cgroup_work {
+	struct work_struct work;
+#ifdef CONFIG_CGROUPS
+	struct cgroup *cgroup;
+#endif
+};
+
 /**
  * struct workqueue_attrs - A struct for workqueue attributes.
  *
@@ -157,6 +166,12 @@ struct workqueue_attrs {
 	 * doesn't participate in pool hash calculations or equality comparisons.
 	 */
 	bool no_numa;
+
+	/**
+	 * Workers run work items while attached to the work's corresponding
+	 * cgroup.  This is a property of both workqueues and worker pools.
+	 */
+	bool cgroup_aware;
 };
 
 static inline struct delayed_work *to_delayed_work(struct work_struct *work)
@@ -169,6 +184,11 @@ static inline struct rcu_work *to_rcu_work(struct work_struct *work)
 	return container_of(work, struct rcu_work, work);
 }
 
+static inline struct cgroup_work *to_cgroup_work(struct work_struct *work)
+{
+	return container_of(work, struct cgroup_work, work);
+}
+
 struct execute_work {
 	struct work_struct work;
 };
@@ -290,6 +310,12 @@ static inline unsigned int work_static(struct work_struct *work) { return 0; }
 #define INIT_RCU_WORK_ONSTACK(_work, _func)				\
 	INIT_WORK_ONSTACK(&(_work)->work, (_func))
 
+#define INIT_CGROUP_WORK(_work, _func)					\
+	INIT_WORK(&(_work)->work, (_func))
+
+#define INIT_CGROUP_WORK_ONSTACK(_work, _func)				\
+	INIT_WORK_ONSTACK(&(_work)->work, (_func))
+
 /**
  * work_pending - Find out whether a work item is currently pending
  * @work: The work item in question
@@ -344,6 +370,14 @@ enum {
 	 */
 	WQ_POWER_EFFICIENT	= 1 << 7,
 
+	/*
+	 * Workqueue is cgroup-aware.  Valid only for WQ_UNBOUND workqueues
+	 * since these work items tend to be the most resource-intensive and
+	 * thus worth the accounting overhead.  Only cgroup_work's may be
+	 * queued.
+	 */
+	WQ_CGROUP		= 1 << 8,
+
 	__WQ_DRAINING		= 1 << 16, /* internal: workqueue is draining */
 	__WQ_ORDERED		= 1 << 17, /* internal: workqueue is ordered */
 	__WQ_LEGACY		= 1 << 18, /* internal: create*_workqueue() */
@@ -514,6 +548,57 @@ static inline bool queue_delayed_work(struct workqueue_struct *wq,
 	return queue_delayed_work_on(WORK_CPU_UNBOUND, wq, dwork, delay);
 }
 
+#ifdef CONFIG_CGROUPS
+
+extern bool queue_cgroup_work_node(int node, struct workqueue_struct *wq,
+				   struct cgroup_work *cwork,
+				   struct cgroup *cgroup);
+
+/**
+ * queue_cgroup_work - queue work to be run in a cgroup
+ * @wq: workqueue to use
+ * @cwork: cgroup_work to queue
+ * @cgroup: cgroup that the worker assigned to @cwork will attach to
+ *
+ * A worker serving @wq will run @cwork while attached to @cgroup.
+ *
+ * Return: %false if @work was already on a queue, %true otherwise.
+ */
+static inline bool queue_cgroup_work(struct workqueue_struct *wq,
+				     struct cgroup_work *cwork,
+				     struct cgroup *cgroup)
+{
+	return queue_cgroup_work_node(NUMA_NO_NODE, wq, cwork, cgroup);
+}
+
+static inline struct cgroup *work_to_cgroup(struct work_struct *work)
+{
+	return to_cgroup_work(work)->cgroup;
+}
+
+#else  /* CONFIG_CGROUPS */
+
+static inline bool queue_cgroup_work_node(int node, struct workqueue_struct *wq,
+					  struct cgroup_work *cwork,
+					  struct cgroup *cgroup)
+{
+	return queue_work_node(node, wq, &cwork->work);
+}
+
+static inline bool queue_cgroup_work(struct workqueue_struct *wq,
+				     struct cgroup_work *cwork,
+				     struct cgroup *cgroup)
+{
+	return queue_work_node(NUMA_NO_NODE, wq, &cwork->work);
+}
+
+static inline struct cgroup *work_to_cgroup(struct work_struct *work)
+{
+	return NULL;
+}
+
+#endif /* CONFIG_CGROUPS */
+
 /**
  * mod_delayed_work - modify delay of or queue a delayed work
  * @wq: workqueue to use
diff --git a/kernel/cgroup/cgroup-internal.h b/kernel/cgroup/cgroup-internal.h
index 30e39f3932ad..575ca2d0a7bc 100644
--- a/kernel/cgroup/cgroup-internal.h
+++ b/kernel/cgroup/cgroup-internal.h
@@ -200,7 +200,6 @@ static inline void get_css_set(struct css_set *cset)
 }
 
 bool cgroup_ssid_enabled(int ssid);
-bool cgroup_on_dfl(const struct cgroup *cgrp);
 bool cgroup_is_thread_root(struct cgroup *cgrp);
 bool cgroup_is_threaded(struct cgroup *cgrp);
 
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 51aa010d728e..89b90899bc09 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -49,6 +49,7 @@
 #include <linux/uaccess.h>
 #include <linux/sched/isolation.h>
 #include <linux/nmi.h>
+#include <linux/cgroup.h>
 
 #include "workqueue_internal.h"
 
@@ -80,6 +81,11 @@ enum {
 	WORKER_UNBOUND		= 1 << 7,	/* worker is unbound */
 	WORKER_REBOUND		= 1 << 8,	/* worker was rebound */
 	WORKER_NICED		= 1 << 9,	/* worker's nice was adjusted */
+#ifdef CONFIG_CGROUPS
+	WORKER_CGROUP		= 1 << 10,	/* worker is cgroup-aware */
+#else
+	WORKER_CGROUP		= 0,		/* eliminate branches */
+#endif
 
 	WORKER_NOT_RUNNING	= WORKER_PREP | WORKER_CPU_INTENSIVE |
 				  WORKER_UNBOUND | WORKER_REBOUND,
@@ -106,6 +112,9 @@ enum {
 	HIGHPRI_NICE_LEVEL	= MIN_NICE,
 
 	WQ_NAME_LEN		= 24,
+
+	/* flags for __queue_work */
+	QUEUE_WORK_CGROUP	= 1,
 };
 
 /*
@@ -1214,6 +1223,8 @@ static void pwq_dec_nr_in_flight(struct pool_workqueue *pwq, int color)
  * @work: work item to steal
  * @is_dwork: @work is a delayed_work
  * @flags: place to store irq state
+ * @is_cwork: set to %true if @work is a cgroup_work and PENDING is stolen
+ *            (ret == 1)
  *
  * Try to grab PENDING bit of @work.  This function can handle @work in any
  * stable state - idle, on timer or on worklist.
@@ -1237,7 +1248,7 @@ static void pwq_dec_nr_in_flight(struct pool_workqueue *pwq, int color)
  * This function is safe to call from any context including IRQ handler.
  */
 static int try_to_grab_pending(struct work_struct *work, bool is_dwork,
-			       unsigned long *flags)
+			       unsigned long *flags, bool *is_cwork)
 {
 	struct worker_pool *pool;
 	struct pool_workqueue *pwq;
@@ -1297,6 +1308,8 @@ static int try_to_grab_pending(struct work_struct *work, bool is_dwork,
 
 		/* work->data points to pwq iff queued, point to pool */
 		set_work_pool_and_keep_pending(work, pool->id);
+		if (unlikely(is_cwork && (pwq->wq->flags & WQ_CGROUP)))
+			*is_cwork = true;
 
 		spin_unlock(&pool->lock);
 		return 1;
@@ -1394,7 +1407,7 @@ static int wq_select_unbound_cpu(int cpu)
 }
 
 static void __queue_work(int cpu, struct workqueue_struct *wq,
-			 struct work_struct *work)
+			 struct work_struct *work, int flags)
 {
 	struct pool_workqueue *pwq;
 	struct worker_pool *last_pool;
@@ -1416,6 +1429,12 @@ static void __queue_work(int cpu, struct workqueue_struct *wq,
 	if (unlikely(wq->flags & __WQ_DRAINING) &&
 	    WARN_ON_ONCE(!is_chained_work(wq)))
 		return;
+
+	/* not allowed to queue regular works on a cgroup-aware workqueue */
+	if (unlikely(wq->flags & WQ_CGROUP) &&
+	    WARN_ON_ONCE(!(flags & QUEUE_WORK_CGROUP)))
+		return;
+
 retry:
 	if (req_cpu == WORK_CPU_UNBOUND)
 		cpu = wq_select_unbound_cpu(raw_smp_processor_id());
@@ -1516,7 +1535,7 @@ bool queue_work_on(int cpu, struct workqueue_struct *wq,
 	local_irq_save(flags);
 
 	if (!test_and_set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(work))) {
-		__queue_work(cpu, wq, work);
+		__queue_work(cpu, wq, work, 0);
 		ret = true;
 	}
 
@@ -1600,7 +1619,7 @@ bool queue_work_node(int node, struct workqueue_struct *wq,
 	if (!test_and_set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(work))) {
 		int cpu = workqueue_select_cpu_near(node);
 
-		__queue_work(cpu, wq, work);
+		__queue_work(cpu, wq, work, 0);
 		ret = true;
 	}
 
@@ -1614,7 +1633,7 @@ void delayed_work_timer_fn(struct timer_list *t)
 	struct delayed_work *dwork = from_timer(dwork, t, timer);
 
 	/* should have been called from irqsafe timer with irq already off */
-	__queue_work(dwork->cpu, dwork->wq, &dwork->work);
+	__queue_work(dwork->cpu, dwork->wq, &dwork->work, 0);
 }
 EXPORT_SYMBOL(delayed_work_timer_fn);
 
@@ -1636,7 +1655,7 @@ static void __queue_delayed_work(int cpu, struct workqueue_struct *wq,
 	 * on that there's no such delay when @delay is 0.
 	 */
 	if (!delay) {
-		__queue_work(cpu, wq, &dwork->work);
+		__queue_work(cpu, wq, &dwork->work, 0);
 		return;
 	}
 
@@ -1706,7 +1725,7 @@ bool mod_delayed_work_on(int cpu, struct workqueue_struct *wq,
 	int ret;
 
 	do {
-		ret = try_to_grab_pending(&dwork->work, true, &flags);
+		ret = try_to_grab_pending(&dwork->work, true, &flags, NULL);
 	} while (unlikely(ret == -EAGAIN));
 
 	if (likely(ret >= 0)) {
@@ -1725,7 +1744,7 @@ static void rcu_work_rcufn(struct rcu_head *rcu)
 
 	/* read the comment in __queue_work() */
 	local_irq_disable();
-	__queue_work(WORK_CPU_UNBOUND, rwork->wq, &rwork->work);
+	__queue_work(WORK_CPU_UNBOUND, rwork->wq, &rwork->work, 0);
 	local_irq_enable();
 }
 
@@ -1753,6 +1772,129 @@ bool queue_rcu_work(struct workqueue_struct *wq, struct rcu_work *rwork)
 }
 EXPORT_SYMBOL(queue_rcu_work);
 
+#ifdef CONFIG_CGROUPS
+
+/**
+ * queue_cgroup_work_node - queue work to be run in a cgroup on a specific node
+ * @node: node to execute work on
+ * @wq: workqueue to use
+ * @cwork: work to queue
+ * @cgroup: cgroup that the assigned worker should attach to
+ *
+ * Queue @cwork to be run by a worker attached to @cgroup.
+ *
+ * It is the caller's responsibility to ensure @cgroup is valid until this
+ * function returns.
+ *
+ * Supports cgroup v2 only.  If @cgroup is on a v1 hierarchy, the assigned
+ * worker runs in the root of the default hierarchy.
+ *
+ * Return: %false if @work was already on a queue, %true otherwise.
+ */
+bool queue_cgroup_work_node(int node, struct workqueue_struct *wq,
+			    struct cgroup_work *cwork, struct cgroup *cgroup)
+{
+	bool ret = false;
+	unsigned long flags;
+
+	if (WARN_ON_ONCE(!(wq->flags & WQ_CGROUP)))
+		return ret;
+
+	local_irq_save(flags);
+
+	if (!test_and_set_bit(WORK_STRUCT_PENDING_BIT,
+			      work_data_bits(&cwork->work))) {
+		int cpu = workqueue_select_cpu_near(node);
+
+		if (cgroup_on_dfl(cgroup))
+			cwork->cgroup = cgroup;
+		else
+			cwork->cgroup = cgroup_dfl_root();
+
+		/*
+		 * cgroup_put happens after a worker is assigned to @work and
+		 * migrated into @cgroup, or @work is cancelled.
+		 */
+		cgroup_get(cwork->cgroup);
+		__queue_work(cpu, wq, &cwork->work, QUEUE_WORK_CGROUP);
+		ret = true;
+	}
+
+	local_irq_restore(flags);
+	return ret;
+}
+
+static inline bool worker_in_child_cgroup(struct worker *worker)
+{
+	return (worker->flags & WORKER_CGROUP) && cgroup_parent(worker->cgroup);
+}
+
+static void attach_worker_to_dfl_root(struct worker *worker)
+{
+	int ret;
+
+	if (!worker_in_child_cgroup(worker))
+		return;
+
+	ret = cgroup_attach_kthread_to_dfl_root();
+	if (ret == 0) {
+		rcu_read_lock();
+		worker->cgroup = task_dfl_cgroup(worker->task);
+		rcu_read_unlock();
+	} else {
+		/*
+		 * TODO Modify the cgroup migration path to guarantee that a
+		 * kernel thread can successfully migrate to the default root
+		 * cgroup.
+		 */
+		WARN_ONCE(1, "can't migrate %s to dfl root (%d)\n",
+			  current->comm, ret);
+	}
+}
+
+/**
+ * attach_worker_to_cgroup - attach worker to work's corresponding cgroup
+ * @worker: worker thread to attach
+ * @work: work used to decide which cgroup to attach to
+ *
+ * Attach a cgroup-aware worker to work's corresponding cgroup.
+ */
+static void attach_worker_to_cgroup(struct worker *worker,
+				    struct work_struct *work)
+{
+	struct cgroup_work *cwork;
+	struct cgroup *cgroup;
+
+	if (!(worker->flags & WORKER_CGROUP))
+		return;
+
+	cwork = to_cgroup_work(work);
+
+	if (unlikely(is_wq_barrier_cgroup(cwork)))
+		return;
+
+	cgroup = cwork->cgroup;
+
+	if (cgroup == worker->cgroup)
+		goto out;
+
+	if (cgroup_attach_kthread(cgroup) == 0) {
+		worker->cgroup = cgroup;
+	} else {
+		/*
+		 * Attach failed, so attach to the default root so the
+		 * work isn't accounted to an unrelated cgroup.
+		 */
+		attach_worker_to_dfl_root(worker);
+	}
+
+out:
+	/* Pairs with cgroup_get in queue_cgroup_work_node. */
+	cgroup_put(cgroup);
+}
+
+#endif /* CONFIG_CGROUPS */
+
 /**
  * worker_enter_idle - enter idle state
  * @worker: worker which is entering idle state
@@ -1934,6 +2076,12 @@ static struct worker *create_worker(struct worker_pool *pool)
 
 	set_user_nice(worker->task, pool->attrs->nice);
 	kthread_bind_mask(worker->task, pool->attrs->cpumask);
+	if (pool->attrs->cgroup_aware) {
+		rcu_read_lock();
+		worker->cgroup = task_dfl_cgroup(worker->task);
+		rcu_read_unlock();
+		worker->flags |= WORKER_CGROUP;
+	}
 
 	/* successful, attach the worker to the pool */
 	worker_attach_to_pool(worker, pool);
@@ -2242,6 +2390,8 @@ __acquires(&pool->lock)
 
 	spin_unlock_irq(&pool->lock);
 
+	attach_worker_to_cgroup(worker, work);
+
 	lock_map_acquire(&pwq->wq->lockdep_map);
 	lock_map_acquire(&lockdep_map);
 	/*
@@ -2434,6 +2584,21 @@ static int worker_thread(void *__worker)
 		}
 	} while (keep_working(pool));
 
+	/*
+	 * Migrate a worker attached to a non-root cgroup to the root so a
+	 * sleeping worker won't cause cgroup_rmdir to fail indefinitely.
+	 *
+	 * XXX Should probably also modify cgroup core so that cgroup_rmdir
+	 * fails only if there are user (i.e. non-kthread) tasks in a cgroup;
+	 * otherwise, long-running workers can still cause cgroup_rmdir to fail
+	 * and userspace can't do anything other than wait.
+	 */
+	if (worker_in_child_cgroup(worker)) {
+		spin_unlock_irq(&pool->lock);
+		attach_worker_to_dfl_root(worker);
+		spin_lock_irq(&pool->lock);
+	}
+
 	worker_set_flags(worker, WORKER_PREP);
 sleep:
 	/*
@@ -2619,7 +2784,10 @@ static void check_flush_dependency(struct workqueue_struct *target_wq,
 }
 
 struct wq_barrier {
-	struct work_struct	work;
+	union {
+		struct work_struct	work;
+		struct cgroup_work	cwork;
+	};
 	struct completion	done;
 	struct task_struct	*task;	/* purely informational */
 };
@@ -2660,6 +2828,7 @@ static void insert_wq_barrier(struct pool_workqueue *pwq,
 {
 	struct list_head *head;
 	unsigned int linked = 0;
+	struct work_struct *barr_work;
 
 	/*
 	 * debugobject calls are safe here even with pool->lock locked
@@ -2667,8 +2836,17 @@ static void insert_wq_barrier(struct pool_workqueue *pwq,
 	 * checks and call back into the fixup functions where we
 	 * might deadlock.
 	 */
-	INIT_WORK_ONSTACK(&barr->work, wq_barrier_func);
-	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&barr->work));
+
+	if (unlikely(pwq->wq->flags & WQ_CGROUP)) {
+		barr_work = &barr->cwork.work;
+		INIT_CGROUP_WORK_ONSTACK(&barr->cwork, wq_barrier_func);
+		set_wq_barrier_cgroup(&barr->cwork);
+	} else {
+		barr_work = &barr->work;
+		INIT_WORK_ONSTACK(barr_work, wq_barrier_func);
+	}
+
+	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(barr_work));
 
 	init_completion_map(&barr->done, &target->lockdep_map);
 
@@ -2689,8 +2867,8 @@ static void insert_wq_barrier(struct pool_workqueue *pwq,
 		__set_bit(WORK_STRUCT_LINKED_BIT, bits);
 	}
 
-	debug_work_activate(&barr->work);
-	insert_work(pwq, &barr->work, head,
+	debug_work_activate(barr_work);
+	insert_work(pwq, barr_work, head,
 		    work_color_to_flags(WORK_NO_COLOR) | linked);
 }
 
@@ -3171,10 +3349,11 @@ static bool __cancel_work_timer(struct work_struct *work, bool is_dwork)
 {
 	static DECLARE_WAIT_QUEUE_HEAD(cancel_waitq);
 	unsigned long flags;
+	bool is_cwork = false;
 	int ret;
 
 	do {
-		ret = try_to_grab_pending(work, is_dwork, &flags);
+		ret = try_to_grab_pending(work, is_dwork, &flags, &is_cwork);
 		/*
 		 * If someone else is already canceling, wait for it to
 		 * finish.  flush_work() doesn't work for PREEMPT_NONE
@@ -3210,6 +3389,10 @@ static bool __cancel_work_timer(struct work_struct *work, bool is_dwork)
 	mark_work_canceling(work);
 	local_irq_restore(flags);
 
+	/* PENDING stolen, so drop the cgroup ref from queueing @work. */
+	if (ret == 1 && is_cwork)
+		cgroup_put(work_to_cgroup(work));
+
 	/*
 	 * This allows canceling during early boot.  We know that @work
 	 * isn't executing.
@@ -3271,7 +3454,7 @@ bool flush_delayed_work(struct delayed_work *dwork)
 {
 	local_irq_disable();
 	if (del_timer_sync(&dwork->timer))
-		__queue_work(dwork->cpu, dwork->wq, &dwork->work);
+		__queue_work(dwork->cpu, dwork->wq, &dwork->work, 0);
 	local_irq_enable();
 	return flush_work(&dwork->work);
 }
@@ -3300,15 +3483,20 @@ EXPORT_SYMBOL(flush_rcu_work);
 static bool __cancel_work(struct work_struct *work, bool is_dwork)
 {
 	unsigned long flags;
+	bool is_cwork = false;
 	int ret;
 
 	do {
-		ret = try_to_grab_pending(work, is_dwork, &flags);
+		ret = try_to_grab_pending(work, is_dwork, &flags, &is_cwork);
 	} while (unlikely(ret == -EAGAIN));
 
 	if (unlikely(ret < 0))
 		return false;
 
+	/* PENDING stolen, so drop the cgroup ref from queueing @work. */
+	if (ret == 1 && is_cwork)
+		cgroup_put(work_to_cgroup(work));
+
 	set_work_pool_and_clear_pending(work, get_work_pool_id(work));
 	local_irq_restore(flags);
 	return ret;
@@ -3465,12 +3653,13 @@ static void copy_workqueue_attrs(struct workqueue_attrs *to,
 	 * get_unbound_pool() explicitly clears ->no_numa after copying.
 	 */
 	to->no_numa = from->no_numa;
+	to->cgroup_aware = from->cgroup_aware;
 }
 
 /* hash value of the content of @attr */
 static u32 wqattrs_hash(const struct workqueue_attrs *attrs)
 {
-	u32 hash = 0;
+	u32 hash = attrs->cgroup_aware;
 
 	hash = jhash_1word(attrs->nice, hash);
 	hash = jhash(cpumask_bits(attrs->cpumask),
@@ -3486,6 +3675,8 @@ static bool wqattrs_equal(const struct workqueue_attrs *a,
 		return false;
 	if (!cpumask_equal(a->cpumask, b->cpumask))
 		return false;
+	if (a->cgroup_aware != b->cgroup_aware)
+		return false;
 	return true;
 }
 
@@ -4002,6 +4193,8 @@ apply_wqattrs_prepare(struct workqueue_struct *wq,
 	if (unlikely(cpumask_empty(new_attrs->cpumask)))
 		cpumask_copy(new_attrs->cpumask, wq_unbound_cpumask);
 
+	new_attrs->cgroup_aware = !!(wq->flags & WQ_CGROUP);
+
 	/*
 	 * We may create multiple pwqs with differing cpumasks.  Make a
 	 * copy of @new_attrs which will be modified and used to obtain
@@ -4323,6 +4516,13 @@ struct workqueue_struct *alloc_workqueue(const char *fmt,
 	if ((flags & WQ_POWER_EFFICIENT) && wq_power_efficient)
 		flags |= WQ_UNBOUND;
 
+	/*
+	 * cgroup awareness supported only in unbound workqueues since those
+	 * tend to be the most resource-intensive.
+	 */
+	if (WARN_ON_ONCE((flags & WQ_CGROUP) && !(flags & WQ_UNBOUND)))
+		flags &= ~WQ_CGROUP;
+
 	/* allocate wq and format name */
 	if (flags & WQ_UNBOUND)
 		tbl_size = nr_node_ids * sizeof(wq->numa_pwq_tbl[0]);
@@ -5980,6 +6180,7 @@ int __init workqueue_init_early(void)
 
 		BUG_ON(!(attrs = alloc_workqueue_attrs(GFP_KERNEL)));
 		attrs->nice = std_nice[i];
+		attrs->cgroup_aware = true;
 		unbound_std_wq_attrs[i] = attrs;
 
 		/*
@@ -5990,6 +6191,7 @@ int __init workqueue_init_early(void)
 		BUG_ON(!(attrs = alloc_workqueue_attrs(GFP_KERNEL)));
 		attrs->nice = std_nice[i];
 		attrs->no_numa = true;
+		attrs->cgroup_aware = true;
 		ordered_wq_attrs[i] = attrs;
 	}
 
diff --git a/kernel/workqueue_internal.h b/kernel/workqueue_internal.h
index cb68b03ca89a..3ad5861258ca 100644
--- a/kernel/workqueue_internal.h
+++ b/kernel/workqueue_internal.h
@@ -32,6 +32,7 @@ struct worker {
 	work_func_t		current_func;	/* L: current_work's fn */
 	struct pool_workqueue	*current_pwq; /* L: current_work's pwq */
 	struct list_head	scheduled;	/* L: scheduled works */
+	struct cgroup		*cgroup;	/* private to worker->task */
 
 	/* 64 bytes boundary on 64bit, 32 on 32bit */
 
@@ -76,4 +77,48 @@ void wq_worker_waking_up(struct task_struct *task, int cpu);
 struct task_struct *wq_worker_sleeping(struct task_struct *task);
 work_func_t wq_worker_last_func(struct task_struct *task);
 
+#ifdef CONFIG_CGROUPS
+
+/*
+ * A barrier work running in a cgroup-aware worker pool needs to specify a
+ * cgroup.  For simplicity, WQ_BARRIER_CGROUP makes the worker stay in its
+ * current cgroup, which correctly accounts the barrier work to the cgroup of
+ * the work being flushed in most cases.  The only exception is when the
+ * flushed work is in progress and a worker collision has caused a work from a
+ * different cgroup to be scheduled before the barrier work, but that seems
+ * acceptable since the barrier work isn't resource-intensive anyway.
+ */
+#define WQ_BARRIER_CGROUP	((struct cgroup *)1)
+
+static inline void set_wq_barrier_cgroup(struct cgroup_work *cwork)
+{
+	cwork->cgroup = WQ_BARRIER_CGROUP;
+}
+
+static inline bool is_wq_barrier_cgroup(struct cgroup_work *cwork)
+{
+	return cwork->cgroup == WQ_BARRIER_CGROUP;
+}
+
+#else
+
+static inline void set_wq_barrier_cgroup(struct cgroup_work *cwork) {}
+
+static inline bool is_wq_barrier_cgroup(struct cgroup_work *cwork)
+{
+	return false;
+}
+
+static inline bool worker_in_child_cgroup(struct worker *worker)
+{
+	return false;
+}
+
+static inline void attach_worker_to_cgroup(struct worker *worker,
+					   struct work_struct *work) {}
+
+static inline void attach_worker_to_dfl_root(struct worker *worker) {}
+
+#endif /* CONFIG_CGROUPS */
+
 #endif /* _KERNEL_WORKQUEUE_INTERNAL_H */
-- 
2.21.0

