Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2836C06510
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:34:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D90220645
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:34:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D90220645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35CBC8E0005; Tue,  2 Jul 2019 23:34:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E77E8E0001; Tue,  2 Jul 2019 23:34:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1600F8E0005; Tue,  2 Jul 2019 23:34:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3FB58E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 23:34:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b18so728249pgg.8
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 20:34:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=Gk9SeGja9usBBJPCwER3YN/IVOL2c/cZ/AXA/jhDGO8=;
        b=apw8u2q0i+Zc1BbRrVLBxhxDEOOYGwyuFNO6q8sXsM9DIartuzQoM9S1sEOC9ZGWE+
         jrRu2R9xSUzzNP10kKAnPswdh00PK2W9HAhaXKCnAvWc6M8Ptw6VgBQeyQCDnfi89qBV
         RVZRKwA4FnEz4alOG2gEksrPr8ElRNIBYioc0GaQAJnCrGNaPi+oNE/Vh4OF7Jo8sZhn
         B6yc1ldT9JUc1dyC+Xw1zAHqFV9jBufDUjk05ccGp10E2RQ1MEJPRpFTeTdeF8jB4Uh8
         oEqYIt6gCgQJnrGhadikJf9dbHY6PNYznHC3mEYpMpLEESnUzqL3VPIFKpflLngr3jha
         hrZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXzGKnfkprBQ1J94p8LoLukqmAfeTHDbkenMHqAeSGJPQQH2lQm
	NEvkhV3q8rU0JfwDpzGkFwGPZ1YTiHjeeMErSH0nKGNJU9c49oWq4OBBhpfeAMB16S2Ta4q7E7H
	Peh1y3h8QARLVJDl0ysxM33rWW7XygqxNJ5EY1zVL3SmXBaoYIVEmgnBV6OLwVdY8Sg==
X-Received: by 2002:a17:90a:374f:: with SMTP id u73mr9689132pjb.4.1562124862389;
        Tue, 02 Jul 2019 20:34:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGAB1w5w+eWJX3HSNQxQuUOhMzrRRhjT4+PJmU6cDoUT5bn8JBSKwPTeN+sEgDHtc75iKL
X-Received: by 2002:a17:90a:374f:: with SMTP id u73mr9688925pjb.4.1562124860296;
        Tue, 02 Jul 2019 20:34:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562124860; cv=none;
        d=google.com; s=arc-20160816;
        b=afby8cM7nDVLAULpmvzmPEdxqKnG8Qo/h0gCFWNS9+y6upLut0HugYojLlZBRcHNfV
         A8FW/AdN/lfyD2PI7cfzMe1zVVoudvJvvfrXugNEQqo3WJMhSrEGpymMgO2GdiqENv9m
         DO1Kdyzuk2SbKqSMY20a8hGrgcvrieQjtzYeaxtXxmavi5AZYh8+rpOgHoIOLU7QWJmR
         1PrUhI7MnzyF9JLrwc53+nfcdR6lRRlyuBNVNXqykUDIA5tHEdkH2OvNC+S0bBvTfYZG
         BpB+SHyqYThyOzChK700FZKY/o2b4S8zYyzv6sg8h2Y+vomyjxVpFH9X2vK7OJHHczru
         B7lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=Gk9SeGja9usBBJPCwER3YN/IVOL2c/cZ/AXA/jhDGO8=;
        b=Q8g+n+N6Hxy6kRjdmlDWDeDKl30wWioDUJ5HNmltcsLiXFXnMl+hAjRicf3GzqQZSY
         n9rlIB3PWAjVlya93KXXU4NFqRfFGa0G4i+CcEPjYki2nWslLi9id45u+l5V63KMI47z
         U/x1uLe56+bMR6a8M5VnFPPkxwIMNHApMw+aebKgpw5obgQfqErcLcm48Zh55B1KKohu
         ohqjqWN/HUvfnnWpqXsGK//kmpQ28G+ANxky6RC04YYgZ8CT9zDYcAV0s0JddsgAzxmH
         8ipICv73bWQD6PRt6h/DpktmABkvFifaj6biF142LKRWaCuNSWRneU+nxU7d4oLX50rW
         z+gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id f15si976206plr.260.2019.07.02.20.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 20:34:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVvNlqm_1562124856;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TVvNlqm_1562124856)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 03 Jul 2019 11:34:17 +0800
Subject: [PATCH 4/4] numa: introduce numa cling feature
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Message-ID: <9a440936-1e5d-d3bb-c795-ef6f9839a021@linux.alibaba.com>
Date: Wed, 3 Jul 2019 11:34:16 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Although we paid so many effort to settle down task on a particular
node, there are still chances for a task to leave it's preferred
node, that is by wakeup, numa swap migrations or load balance.

When we are using cpu cgroup in share way, since all the workloads
see all the cpus, it could be really bad especially when there
are too many fast wakeup, although now we can numa group the tasks,
they won't really stay on the same node, for example we have numa
group ng_A, ng_B, ng_C, ng_D, it's very likely result as:

	CPU Usage:
		Node 0		Node 1
		ng_A(600%)	ng_A(400%)
		ng_B(400%)	ng_B(600%)
		ng_C(400%)	ng_C(600%)
		ng_D(600%)	ng_D(400%)

	Memory Ratio:
		Node 0		Node 1
		ng_A(60%)	ng_A(40%)
		ng_B(40%)	ng_B(60%)
		ng_C(40%)	ng_C(60%)
		ng_D(60%)	ng_D(40%)

Locality won't be too bad but far from the best situation, we want
a numa group to settle down thoroughly on a particular node, with
every thing balanced.

Thus we introduce the numa cling, which try to prevent tasks leaving
the preferred node on wakeup fast path.

This help thoroughly settle down the workloads on single node, but when
multiple numa group try to settle down on the same node, unbalancing
could happen.

For example we have numa group ng_A, ng_B, ng_C, ng_D, it may result in
situation like:

CPU Usage:
	Node 0		Node 1
	ng_A(1000%)	ng_B(1000%)
	ng_C(400%)	ng_C(600%)
	ng_D(400%)	ng_D(600%)

Memory Ratio:
	Node 0		Node 1
	ng_A(100%)	ng_B(100%)
	ng_C(10%)	ng_C(90%)
	ng_D(10%)	ng_D(90%)

This is because when ng_C, ng_D start to have most of the memory on node
1 at some point, task_x of ng_C stay on node 0 will try to do numa swap
migration with the task_y of ng_D stay on node 1 as long as load balanced,
the result is task_x stay on node 1 and task_y stay on node 0, while both
of them prefer node 1.

Now when other tasks of ng_D stay on node 1 wakeup task_y, task_y will
very likely go back to node 1, and since numa cling enabled, it will
keep stay on node 1 although load unbalanced, this could be frequently
and more and more tasks will prefer the node 1 and make it busy.

So the key point here is to stop doing numa cling when load starting to
become unbalancing.

We achieved this by monitoring the migration failure ratio, in scenery
above, too much tasks prefer node 1 and will keep migrating to it, load
unbalancing could lead into the migration failure in this case, and when
the failure ratio above the specified degree, we pause the cling and try
to resettle the workloads on a better node by stop tasks prefer the busy
node, this will finally give us the result like:

CPU Usage:
	Node 0		Node 1
	ng_A(1000%)	ng_B(1000%)
	ng_C(1000%)	ng_D(1000%)

Memory Ratio:
	Node 0		Node 1
	ng_A(100%)	ng_B(100%)
	ng_C(100%)	ng_D(100%)

Now we achieved the best locality and maximum hot cache benefit.

Tested on a 2 node box with 96 cpus, do sysbench-mysql-oltp_read_write
testing, X mysqld instances created and attached to X cgroups, X sysbench
instances then created and attached to corresponding cgroup to test the
mysql with oltp_read_write script for 20 minutes, average eps show:

				origin		ng + cling
4 instances each 24 threads	7545.28		7790.49		+3.25%
4 instances each 48 threads	9359.36		9832.30		+5.05%
4 instances each 72 threads	9602.88		10196.95	+6.19%

8 instances each 24 threads	4478.82		4508.82		+0.67%
8 instances each 48 threads	5514.90		5689.93		+3.17%
8 instances each 72 threads	5582.19		5741.33		+2.85%

Also tested with perf-bench-numa, dbench, sysbench-memory, pgbench, tiny
improvement observed.

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
 include/linux/sched/sysctl.h |   3 +
 kernel/sched/fair.c          | 283 +++++++++++++++++++++++++++++++++++++++++--
 kernel/sysctl.c              |   9 ++
 3 files changed, 283 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index d4f6215ee03f..6eef34331dd2 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -38,6 +38,9 @@ extern unsigned int sysctl_numa_balancing_scan_period_min;
 extern unsigned int sysctl_numa_balancing_scan_period_max;
 extern unsigned int sysctl_numa_balancing_scan_size;

+extern unsigned int sysctl_numa_balancing_cling_degree;
+extern unsigned int max_numa_balancing_cling_degree;
+
 #ifdef CONFIG_SCHED_DEBUG
 extern __read_mostly unsigned int sysctl_sched_migration_cost;
 extern __read_mostly unsigned int sysctl_sched_nr_migrate;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 6cf9c9c61258..a4a48cdd2bbd 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1067,6 +1067,20 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
 /* Scan @scan_size MB every @scan_period after an initial @scan_delay in ms */
 unsigned int sysctl_numa_balancing_scan_delay = 1000;

+/*
+ * The numa group serving task group will enable numa cling, a feature
+ * which try to prevent task leaving preferred node on wakeup.
+ *
+ * This help settle down the workloads thorouly and quickly on node,
+ * while introduce the risk of load unbalancing.
+ *
+ * In order to detect the risk in advance and pause the feature, we
+ * rely on numa migration failure stats, and when failure ratio above
+ * cling degree, we pause the numa cling until resettle done.
+ */
+unsigned int sysctl_numa_balancing_cling_degree = 20;
+unsigned int max_numa_balancing_cling_degree = 100;
+
 struct numa_group {
 	refcount_t refcount;

@@ -1074,11 +1088,15 @@ struct numa_group {
 	int nr_tasks;
 	pid_t gid;
 	int active_nodes;
+	int busiest_nid;
 	bool evacuate;
+	bool do_cling;
+	struct timer_list cling_timer;

 	struct rcu_head rcu;
 	unsigned long total_faults;
 	unsigned long max_faults_cpu;
+	unsigned long *migrate_stat;
 	/*
 	 * Faults_cpu is used to decide whether memory should move
 	 * towards the CPU. As a consequence, these stats are weighted
@@ -1088,6 +1106,8 @@ struct numa_group {
 	unsigned long faults[0];
 };

+static inline bool busy_node(struct numa_group *ng, int nid);
+
 static inline unsigned long group_faults_priv(struct numa_group *ng);
 static inline unsigned long group_faults_shared(struct numa_group *ng);

@@ -1132,8 +1152,14 @@ static unsigned int task_scan_start(struct task_struct *p)
 	unsigned long smin = task_scan_min(p);
 	unsigned long period = smin;

-	/* Scale the maximum scan period with the amount of shared memory. */
-	if (p->numa_group) {
+	/*
+	 * Scale the maximum scan period with the amount of shared memory.
+	 *
+	 * Not for the numa group serving task group, it's tasks are not
+	 * gathered for sharing memory, and we need to detect migration
+	 * failure in time.
+	 */
+	if (p->numa_group && !p->numa_group->do_cling) {
 		struct numa_group *ng = p->numa_group;
 		unsigned long shared = group_faults_shared(ng);
 		unsigned long private = group_faults_priv(ng);
@@ -1154,8 +1180,14 @@ static unsigned int task_scan_max(struct task_struct *p)
 	/* Watch for min being lower than max due to floor calculations */
 	smax = sysctl_numa_balancing_scan_period_max / task_nr_scan_windows(p);

-	/* Scale the maximum scan period with the amount of shared memory. */
-	if (p->numa_group) {
+	/*
+	 * Scale the maximum scan period with the amount of shared memory.
+	 *
+	 * Not for the numa group serving task group, it's tasks are not
+	 * gathered for sharing memory, and we need to detect migration
+	 * failure in time.
+	 */
+	if (p->numa_group && !p->numa_group->do_cling) {
 		struct numa_group *ng = p->numa_group;
 		unsigned long shared = group_faults_shared(ng);
 		unsigned long private = group_faults_priv(ng);
@@ -1475,6 +1507,19 @@ bool should_numa_migrate_memory(struct task_struct *p, struct page * page,
 					ACTIVE_NODE_FRACTION)
 		return true;

+	/*
+	 * Make sure pages do not stay on a busy node when numa cling
+	 * enabled, otherwise they could lead into more numa migration
+	 * to the busy node.
+	 */
+	if (ng->do_cling) {
+		if (busy_node(ng, dst_nid))
+			return false;
+
+		if (busy_node(ng, src_nid))
+			return true;
+	}
+
 	/*
 	 * Distribute memory according to CPU & memory use on each node,
 	 * with 3/4 hysteresis to avoid unnecessary memory migrations:
@@ -1874,9 +1919,190 @@ static int task_numa_migrate(struct task_struct *p)
 	return ret;
 }

+/*
+ * We scale the migration stat count to 1024, divide the maximum numa
+ * balancing scan period by 10 and make that the period of cling timer,
+ * this help to decay one count to 0 after one maximum scan period passed.
+ */
+#define NUMA_MIGRATE_SCALE 10
+#define NUMA_MIGRATE_WEIGHT 1024
+
+enum numa_migrate_stats {
+	FAILURE_SCALED,
+	TOTAL_SCALED,
+	FAILURE_RATIO,
+};
+
+static inline int mstat_idx(int nid, enum numa_migrate_stats s)
+{
+	return (nid + s * nr_node_ids);
+}
+
+static inline unsigned long
+mstat_failure_scaled(struct numa_group *ng, int nid)
+{
+	return ng->migrate_stat[mstat_idx(nid, FAILURE_SCALED)];
+}
+
+static inline unsigned long
+mstat_total_scaled(struct numa_group *ng, int nid)
+{
+	return ng->migrate_stat[mstat_idx(nid, TOTAL_SCALED)];
+}
+
+static inline unsigned long
+mstat_failure_ratio(struct numa_group *ng, int nid)
+{
+	return ng->migrate_stat[mstat_idx(nid, FAILURE_RATIO)];
+}
+
+/*
+ * A node is busy when the numa migration toward it failed too much,
+ * this imply the load already unbalancing for too much numa cling on
+ * that node.
+ */
+static inline bool busy_node(struct numa_group *ng, int nid)
+{
+	int degree = sysctl_numa_balancing_cling_degree;
+
+	if (mstat_failure_scaled(ng, nid) < NUMA_MIGRATE_WEIGHT)
+		return false;
+
+	/*
+	 * Allow only one busy node in one numa group, to prevent
+	 * ping-pong migration case between nodes.
+	 */
+	if (ng->busiest_nid != nid)
+		return false;
+
+	return mstat_failure_ratio(ng, nid) > degree;
+}
+
+/*
+ * Return true if the task should cling to snid, when it preferred snid
+ * rather than dnid and snid is not busy.
+ */
+static inline bool
+task_numa_cling(struct task_struct *p, int snid, int dnid)
+{
+	bool ret = false;
+	int pnid = p->numa_preferred_nid;
+	struct numa_group *ng;
+
+	rcu_read_lock();
+
+	ng = p->numa_group;
+
+	/* Do cling only when the feature enabled and not in pause */
+	if (!ng || !ng->do_cling)
+		goto out;
+
+	if (pnid == NUMA_NO_NODE ||
+	    dnid == pnid ||
+	    snid != pnid)
+		goto out;
+
+	/* Never allow cling to a busy node */
+	if (busy_node(ng, snid))
+		goto out;
+
+	ret = true;
+out:
+	rcu_read_unlock();
+	return ret;
+}
+
+/*
+ * Prevent more tasks from prefer the busy node to easy the unbalancing,
+ * also give the second candidate a chance.
+ */
+static inline bool group_pause_prefer(struct numa_group *ng, int nid)
+{
+	if (!ng || !ng->do_cling)
+		return false;
+
+	return busy_node(ng, nid);
+}
+
+static inline void update_failure_ratio(struct numa_group *ng, int nid)
+{
+	int f_idx = mstat_idx(nid, FAILURE_SCALED);
+	int t_idx = mstat_idx(nid, TOTAL_SCALED);
+	int fp_idx = mstat_idx(nid, FAILURE_RATIO);
+
+	ng->migrate_stat[fp_idx] =
+		ng->migrate_stat[f_idx] * 100 / (ng->migrate_stat[t_idx] + 1);
+}
+
+static void cling_timer_func(struct timer_list *t)
+{
+	int nid;
+	unsigned int degree;
+	unsigned long period, max_failure;
+	struct numa_group *ng = from_timer(ng, t, cling_timer);
+
+	degree = sysctl_numa_balancing_cling_degree;
+	period = msecs_to_jiffies(sysctl_numa_balancing_scan_period_max);
+	period /= NUMA_MIGRATE_SCALE;
+
+	spin_lock_irq(&ng->lock);
+
+	max_failure = 0;
+	for_each_online_node(nid) {
+		int f_idx = mstat_idx(nid, FAILURE_SCALED);
+		int t_idx = mstat_idx(nid, TOTAL_SCALED);
+
+		ng->migrate_stat[f_idx] /= 2;
+		ng->migrate_stat[t_idx] /= 2;
+
+		update_failure_ratio(ng, nid);
+
+		if (ng->migrate_stat[f_idx] > max_failure) {
+			ng->busiest_nid = nid;
+			max_failure = ng->migrate_stat[f_idx];
+		}
+	}
+
+	spin_unlock_irq(&ng->lock);
+
+	mod_timer(&ng->cling_timer, jiffies + period);
+}
+
+static inline void
+update_migrate_stat(struct task_struct *p, int nid, bool failed)
+{
+	int idx;
+	struct numa_group *ng = p->numa_group;
+
+	if (!ng || !ng->do_cling)
+		return;
+
+	spin_lock_irq(&ng->lock);
+
+	if (failed) {
+		idx = mstat_idx(nid, FAILURE_SCALED);
+		ng->migrate_stat[idx] += NUMA_MIGRATE_WEIGHT;
+	}
+
+	idx = mstat_idx(nid, TOTAL_SCALED);
+	ng->migrate_stat[idx] += NUMA_MIGRATE_WEIGHT;
+	update_failure_ratio(ng, nid);
+
+	spin_unlock_irq(&ng->lock);
+
+	/*
+	 * On failed task may prefer source node instead, this
+	 * cause ping-pong migration when numa cling enabled,
+	 * so let's reset the preferred node to none.
+	 */
+	if (failed)
+		sched_setnuma(p, NUMA_NO_NODE);
+}
+
 /* Attempt to migrate a task to a CPU on the preferred node. */
 static void numa_migrate_preferred(struct task_struct *p)
 {
+	bool failed, target;
 	unsigned long interval = HZ;

 	/* This task has no NUMA fault statistics yet */
@@ -1891,8 +2117,12 @@ static void numa_migrate_preferred(struct task_struct *p)
 	if (task_node(p) == p->numa_preferred_nid)
 		return;

+	target = p->numa_preferred_nid;
+
 	/* Otherwise, try migrate to a CPU on the preferred node */
-	task_numa_migrate(p);
+	failed = (task_numa_migrate(p) != 0);
+
+	update_migrate_stat(p, target, failed);
 }

 /*
@@ -2216,7 +2446,8 @@ static void task_numa_placement(struct task_struct *p)
 				max_faults = faults;
 				max_nid = nid;
 			}
-		} else if (group_faults > max_faults) {
+		} else if (group_faults > max_faults &&
+			   !group_pause_prefer(p->numa_group, nid)) {
 			max_faults = group_faults;
 			max_nid = nid;
 		}
@@ -2258,8 +2489,10 @@ void show_tg_numa_group(struct task_group *tg, struct seq_file *sf)
 		return;
 	}

-	seq_printf(sf, "id %d nr_tasks %d active_nodes %d\n",
-		   ng->gid, ng->nr_tasks, ng->active_nodes);
+	spin_lock_irq(&ng->lock);
+
+	seq_printf(sf, "id %d nr_tasks %d active_nodes %d busiest_nid %d\n",
+		   ng->gid, ng->nr_tasks, ng->active_nodes, ng->busiest_nid);

 	for_each_online_node(nid) {
 		int f_idx = task_faults_idx(NUMA_MEM, nid, 0);
@@ -2270,9 +2503,16 @@ void show_tg_numa_group(struct task_group *tg, struct seq_file *sf)
 		seq_printf(sf, "mem_private %lu mem_shared %lu ",
 			   ng->faults[f_idx], ng->faults[pf_idx]);

-		seq_printf(sf, "cpu_private %lu cpu_shared %lu\n",
+		seq_printf(sf, "cpu_private %lu cpu_shared %lu ",
 			   ng->faults_cpu[f_idx], ng->faults_cpu[pf_idx]);
+
+		seq_printf(sf, "migrate_stat %lu %lu %lu\n",
+			   mstat_failure_scaled(ng, nid),
+			   mstat_total_scaled(ng, nid),
+			   mstat_failure_ratio(ng, nid));
 	}
+
+	spin_unlock_irq(&ng->lock);
 }

 int update_tg_numa_group(struct task_group *tg, bool numa_group)
@@ -2286,20 +2526,26 @@ int update_tg_numa_group(struct task_group *tg, bool numa_group)
 	if (ng) {
 		/* put and evacuate tg's numa group */
 		rcu_assign_pointer(tg->numa_group, NULL);
+		del_timer_sync(&ng->cling_timer);
 		ng->evacuate = true;
 		put_numa_group(ng);
 	} else {
 		unsigned int size = sizeof(struct numa_group) +
-				    4*nr_node_ids*sizeof(unsigned long);
+				    7*nr_node_ids*sizeof(unsigned long);
+		unsigned int offset = NR_NUMA_HINT_FAULT_TYPES * nr_node_ids;

 		ng = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!ng)
 			return -ENOMEM;

 		refcount_set(&ng->refcount, 1);
+		ng->busiest_nid = NUMA_NO_NODE;
+		ng->do_cling = true;
+		timer_setup(&ng->cling_timer, cling_timer_func, 0);
 		spin_lock_init(&ng->lock);
-		ng->faults_cpu = ng->faults + NR_NUMA_HINT_FAULT_TYPES *
-						nr_node_ids;
+		ng->faults_cpu = ng->faults + offset;
+		ng->migrate_stat = ng->faults_cpu + offset;
+		add_timer(&ng->cling_timer);
 		/* now make tasks see and join */
 		rcu_assign_pointer(tg->numa_group, ng);
 	}
@@ -2436,6 +2682,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 			return;

 		refcount_set(&grp->refcount, 1);
+		grp->busiest_nid = NUMA_NO_NODE;
 		grp->active_nodes = 1;
 		grp->max_faults_cpu = 0;
 		spin_lock_init(&grp->lock);
@@ -2879,6 +3126,11 @@ static inline void update_scan_period(struct task_struct *p, int new_cpu)
 {
 }

+static inline bool task_numa_cling(struct task_struct *p, int snid, int dnid)
+{
+	return false;
+}
+
 #endif /* CONFIG_NUMA_BALANCING */

 static void
@@ -6195,6 +6447,13 @@ static int select_idle_sibling(struct task_struct *p, int prev, int target)
 	if ((unsigned)i < nr_cpumask_bits)
 		return i;

+	/*
+	 * Failed to find an idle cpu, wake affine may want to pull but
+	 * try stay on prev-cpu when the task cling to it.
+	 */
+	if (task_numa_cling(p, cpu_to_node(prev), cpu_to_node(target)))
+		return prev;
+
 	return target;
 }

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 078950d9605b..0a889dd1c7ed 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -417,6 +417,15 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= SYSCTL_ONE,
 	},
+	{
+		.procname	= "numa_balancing_cling_degree",
+		.data		= &sysctl_numa_balancing_cling_degree,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= SYSCTL_ZERO,
+		.extra2		= &max_numa_balancing_cling_degree,
+	},
 	{
 		.procname	= "numa_balancing",
 		.data		= NULL, /* filled in by handler */
-- 
2.14.4.44.g2045bb6

