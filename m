Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,TVD_PH_BODY_ACCOUNTS_PRE,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05237C76191
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:39:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6D592080A
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:39:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6D592080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5440B6B0008; Mon, 15 Jul 2019 23:39:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F5276B000A; Mon, 15 Jul 2019 23:39:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E4166B000C; Mon, 15 Jul 2019 23:39:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 098266B0008
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 23:39:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so11492026pfq.17
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 20:39:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=2xzKRS1NLr+aqh0erl+4XRn1hgTnnywqAcz2SHJsUXE=;
        b=Yl7JaJOlr7Tl2A/JhVOJtEVpFRRLZkYMmMixS6e+nCevkJ8valNQ+kqBhbs3fv5nKd
         WxOUosptd38NeBUYYpZVeYDfXyg356/X+Vfa2JVKfwrrb4WKcDN+syI+EqdFx+Zo2bH3
         yV2TBDHWVOk2gayuE7ooN6cVrAk0MLXDA0qVIBm9BnA7SNuZ4oj9baAf6oAW8icHe8sM
         MKlGf2ri5hd+oBMRUa4zl85gRT9KG6K0+g2wzYf4FOsKCOYTfrdNSgIOvrs54MQbvQ1P
         5k00JK0TFov7XJ2/JRs6iE87+qE6QZwGnSvW87jmVg9imwppp2KBz/X7o9DG1fU8kFkM
         S7BQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUFmpkz9VEIkSfbGsUndEnYE5CDXyBO+dvXWjm9ar4ihwcQeD1M
	5+D37w9lO8uuOPQRi5u4QU8dCUhEoK/6CrBJDIXQAhGQ3VeUsIS6SvRX3QQokBjw9tb0lEOOQp6
	wqssxzZ2NCDT6mKIdOvLsiwih2eE1GPPGxg1glBrcZCyklGeMsnmOFSUmTVsw/w5pYg==
X-Received: by 2002:a17:902:6b86:: with SMTP id p6mr33205156plk.14.1563248374679;
        Mon, 15 Jul 2019 20:39:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWMhORdpltq4abPnRI/NlHXL7trrTv9XwgAPOZyZ8h483yPAVyBTZDoeGBxok74LKyGt5i
X-Received: by 2002:a17:902:6b86:: with SMTP id p6mr33205083plk.14.1563248373728;
        Mon, 15 Jul 2019 20:39:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563248373; cv=none;
        d=google.com; s=arc-20160816;
        b=eX4dpPP0pMqMgHjHX8EFxmUjB8K4Iq0ybk0CPTIOa3XLp6lMBhQmSFHJZDmOBSur2L
         CTMRdcDaHThdbzRe/wZmL8kcrleg9uyMFUEvKd1Za/cJEQwn434tw5+zo4SL+QxpfCdm
         ZkOgHrpt5tys+dxKD1LJYH+a7RDDml4OJY5lcu3v8h7NNBMaT2d/CmbvmiImId6AnG8X
         UyPQeEl0+RviqWYOeUPiZyIjmy9tUkKhzVmL+TGGuynUlCUMnTjMKq7gyuooTSy5RUIc
         3+rPVTW4Y6Va9A8DeOalsSMuV1kfM3HJQLH31CWyiTyUMFcZSroHjnZDceOB1tURbdpZ
         fyzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=2xzKRS1NLr+aqh0erl+4XRn1hgTnnywqAcz2SHJsUXE=;
        b=dc8CBpWgvZfvJ4Sji2Lf9CHmgNMZSsVkU76ldWvrIACjJb/JUwn7ip4pXEFIfV12fU
         KSsJkDWp3MSS3LCe5/2/cFf1ZozHFKrKjiGJBIgt5mcDwZWaIK8bHMo/wseiANx1bhqE
         sew12Rw745JMZLGQ5xUxEC2a+5ee+r0xiUw6oZKT0jKpBrzqC59J9dgzWt1jY9f0X9QE
         Mn5MUIwaiFnNlLFJEQezIlxZp8ahfaKfJISvo5lnANGOy64eRWZPO4XpBrQj3bm1Zxxo
         g+17Oj0pp0JY/gEGuFxfp6LWLEr2IVQP9S8MCFyHh8hOE6Fps0TzxvMfWbzjfN95ULSH
         CP1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id i133si17736841pgc.109.2019.07.15.20.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 20:39:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TX1Yc3G_1563248369;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TX1Yc3G_1563248369)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 11:39:30 +0800
Subject: [PATCH v2 1/4] numa: introduce per-cgroup numa balancing locality
 statistic
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
 Hillf Danton <hdanton@sina.com>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
Message-ID: <120ffcaa-0281-5d30-c0c1-9464d93e935f@linux.alibaba.com>
Date: Tue, 16 Jul 2019 11:39:29 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduced numa locality statistic, which try to imply
the numa balancing efficiency per memory cgroup.

On numa balancing, we trace the local page accessing ratio of tasks,
which we call the locality.

By doing 'cat /sys/fs/cgroup/cpu/CGROUP_PATH/cpu.numa_stat', we
see output line heading with 'locality', like:

  locality 15393 21259 13023 44461 21247 17012 28496 145402

locality divided into 8 regions, each number standing for the micro
seconds we hit a task running with the locality within that region,
for example here we have tasks with locality around 0~12% running for
15393 ms, and tasks with locality around 88~100% running for 145402 ms.

By monitoring the increment, we can check if the workloads of a
particular cgroup is doing well with numa, when most of the tasks are
running in low locality region, then something is wrong with your numa
policy.

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
Since v1:
  * move implementation from memory cgroup into cpu group
  * introduce new entry 'numa_stat' to present locality
  * locality now accounting in hierarchical way
  * locality now accounted into 8 regions equally

 include/linux/sched.h |  8 +++++++-
 kernel/sched/core.c   | 40 ++++++++++++++++++++++++++++++++++++++++
 kernel/sched/debug.c  |  7 +++++++
 kernel/sched/fair.c   | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/sched/sched.h  | 29 +++++++++++++++++++++++++++++
 5 files changed, 132 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 907808f1acc5..eb26098de6ea 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1117,8 +1117,14 @@ struct task_struct {
 	 * scan window were remote/local or failed to migrate. The task scan
 	 * period is adapted based on the locality of the faults with different
 	 * weights depending on whether they were shared or private faults
+	 *
+	 * 0 -- remote faults
+	 * 1 -- local faults
+	 * 2 -- page migration failure
+	 * 3 -- remote page accessing
+	 * 4 -- local page accessing
 	 */
-	unsigned long			numa_faults_locality[3];
+	unsigned long			numa_faults_locality[5];

 	unsigned long			numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index fa43ce3962e7..71a8d3ed8495 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6367,6 +6367,10 @@ static struct kmem_cache *task_group_cache __read_mostly;
 DECLARE_PER_CPU(cpumask_var_t, load_balance_mask);
 DECLARE_PER_CPU(cpumask_var_t, select_idle_mask);

+#ifdef CONFIG_NUMA_BALANCING
+DECLARE_PER_CPU(struct numa_stat, root_numa_stat);
+#endif
+
 void __init sched_init(void)
 {
 	unsigned long alloc_size = 0, ptr;
@@ -6416,6 +6420,10 @@ void __init sched_init(void)
 	init_defrootdomain();
 #endif

+#ifdef CONFIG_NUMA_BALANCING
+	root_task_group.numa_stat = &root_numa_stat;
+#endif
+
 #ifdef CONFIG_RT_GROUP_SCHED
 	init_rt_bandwidth(&root_task_group.rt_bandwidth,
 			global_rt_period(), global_rt_runtime());
@@ -6727,6 +6735,7 @@ static DEFINE_SPINLOCK(task_group_lock);

 static void sched_free_group(struct task_group *tg)
 {
+	free_tg_numa_stat(tg);
 	free_fair_sched_group(tg);
 	free_rt_sched_group(tg);
 	autogroup_free(tg);
@@ -6742,6 +6751,9 @@ struct task_group *sched_create_group(struct task_group *parent)
 	if (!tg)
 		return ERR_PTR(-ENOMEM);

+	if (!alloc_tg_numa_stat(tg))
+		goto err;
+
 	if (!alloc_fair_sched_group(tg, parent))
 		goto err;

@@ -7277,6 +7289,28 @@ static u64 cpu_rt_period_read_uint(struct cgroup_subsys_state *css,
 }
 #endif /* CONFIG_RT_GROUP_SCHED */

+#ifdef CONFIG_NUMA_BALANCING
+static int cpu_numa_stat_show(struct seq_file *sf, void *v)
+{
+	int nr;
+	struct task_group *tg = css_tg(seq_css(sf));
+
+	seq_puts(sf, "locality");
+	for (nr = 0; nr < NR_NL_INTERVAL; nr++) {
+		int cpu;
+		u64 sum = 0;
+
+		for_each_possible_cpu(cpu)
+			sum += per_cpu(tg->numa_stat->locality[nr], cpu);
+
+		seq_printf(sf, " %u", jiffies_to_msecs(sum));
+	}
+	seq_putc(sf, '\n');
+
+	return 0;
+}
+#endif
+
 static struct cftype cpu_legacy_files[] = {
 #ifdef CONFIG_FAIR_GROUP_SCHED
 	{
@@ -7312,6 +7346,12 @@ static struct cftype cpu_legacy_files[] = {
 		.read_u64 = cpu_rt_period_read_uint,
 		.write_u64 = cpu_rt_period_write_uint,
 	},
+#endif
+#ifdef CONFIG_NUMA_BALANCING
+	{
+		.name = "numa_stat",
+		.seq_show = cpu_numa_stat_show,
+	},
 #endif
 	{ }	/* Terminate */
 };
diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index f7e4579e746c..a22b2a62aee2 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -848,6 +848,13 @@ static void sched_show_numa(struct task_struct *p, struct seq_file *m)
 	P(total_numa_faults);
 	SEQ_printf(m, "current_node=%d, numa_group_id=%d\n",
 			task_node(p), task_numa_group_id(p));
+	SEQ_printf(m, "faults_locality local=%lu remote=%lu failed=%lu ",
+			p->numa_faults_locality[1],
+			p->numa_faults_locality[0],
+			p->numa_faults_locality[2]);
+	SEQ_printf(m, "lhit=%lu rhit=%lu\n",
+			p->numa_faults_locality[4],
+			p->numa_faults_locality[3]);
 	show_numa_stats(p, m);
 	mpol_put(pol);
 #endif
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 036be95a87e9..cd716355d70e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2449,6 +2449,12 @@ void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
 	p->numa_faults[task_faults_idx(NUMA_MEMBUF, mem_node, priv)] += pages;
 	p->numa_faults[task_faults_idx(NUMA_CPUBUF, cpu_node, priv)] += pages;
 	p->numa_faults_locality[local] += pages;
+	/*
+	 * We want to have the real local/remote page access statistic
+	 * here, so use 'mem_node' which is the real residential node of
+	 * page after migrate_misplaced_page().
+	 */
+	p->numa_faults_locality[3 + !!(mem_node == numa_node_id())] += pages;
 }

 static void reset_ptenuma_scan(struct task_struct *p)
@@ -2611,6 +2617,47 @@ void task_numa_work(struct callback_head *work)
 	}
 }

+DEFINE_PER_CPU(struct numa_stat, root_numa_stat);
+
+int alloc_tg_numa_stat(struct task_group *tg)
+{
+	tg->numa_stat = alloc_percpu(struct numa_stat);
+	if (!tg->numa_stat)
+		return 0;
+
+	return 1;
+}
+
+void free_tg_numa_stat(struct task_group *tg)
+{
+	free_percpu(tg->numa_stat);
+}
+
+static void update_tg_numa_stat(struct task_struct *p)
+{
+	struct task_group *tg;
+	unsigned long remote = p->numa_faults_locality[3];
+	unsigned long local = p->numa_faults_locality[4];
+	int idx = -1;
+
+	/* Tobe scaled? */
+	if (remote || local)
+		idx = NR_NL_INTERVAL * local / (remote + local + 1);
+
+	rcu_read_lock();
+
+	tg = task_group(p);
+	while (tg) {
+		/* skip account when there are no faults records */
+		if (idx != -1)
+			this_cpu_inc(tg->numa_stat->locality[idx]);
+
+		tg = tg->parent;
+	}
+
+	rcu_read_unlock();
+}
+
 /*
  * Drive the periodic memory faults..
  */
@@ -2625,6 +2672,8 @@ static void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
 		return;

+	update_tg_numa_stat(curr);
+
 	/*
 	 * Using runtime rather than walltime has the dual advantage that
 	 * we (mostly) drive the selection from busy threads and that the
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 802b1f3405f2..685a9e670880 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -353,6 +353,17 @@ struct cfs_bandwidth {
 #endif
 };

+#ifdef CONFIG_NUMA_BALANCING
+
+/* NUMA Locality Interval, 8 bucket for cache align */
+#define NR_NL_INTERVAL	8
+
+struct numa_stat {
+	u64 locality[NR_NL_INTERVAL];
+};
+
+#endif
+
 /* Task group related information */
 struct task_group {
 	struct cgroup_subsys_state css;
@@ -393,8 +404,26 @@ struct task_group {
 #endif

 	struct cfs_bandwidth	cfs_bandwidth;
+
+#ifdef CONFIG_NUMA_BALANCING
+	struct numa_stat __percpu *numa_stat;
+#endif
 };

+#ifdef CONFIG_NUMA_BALANCING
+int alloc_tg_numa_stat(struct task_group *tg);
+void free_tg_numa_stat(struct task_group *tg);
+#else
+static int alloc_tg_numa_stat(struct task_group *tg)
+{
+	return 1;
+}
+
+static void free_tg_numa_stat(struct task_group *tg)
+{
+}
+#endif
+
 #ifdef CONFIG_FAIR_GROUP_SCHED
 #define ROOT_TASK_GROUP_LOAD	NICE_0_LOAD

-- 
2.14.4.44.g2045bb6

