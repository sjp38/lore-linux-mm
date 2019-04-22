Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39F6CC10F14
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:13:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D020920833
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:13:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D020920833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8234E6B0008; Sun, 21 Apr 2019 22:13:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D1DF6B000A; Sun, 21 Apr 2019 22:13:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C2716B000C; Sun, 21 Apr 2019 22:13:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30E166B0008
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 22:13:43 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o1so7091743pgv.15
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 19:13:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=nwfOC8RJhm6OU8t+xhI0HBAArOj5sRzoz/qLdrGHcDo=;
        b=o5T0WkAdKDIwq7CDd1mixgTWOdapIX8zJfJd0Erduqrl3Y7B/dTE2SFni7dweCQi9P
         BYJgDMl4chv+YBzOsznCgH5QWfkhbmzQRvEc0EYCME+i52ywnVmX7799ToiJQeOIbp6b
         IUBlLBcM8dmXjX3BFSH3jfM9qeLKQS6RwHG4Y3rabnAHQnuZSzbUwled0JpByC3ZJW6j
         kNQXXqULlzZlUoTPWnvbt9w0tYFkQJZmTXaiG+nCQb8nu6R7s9hWAZbhmtZsTcIiWNbF
         tWb6yHBm+RXfcKQ+rTsVEsz20S4bYWaItrDt85h7mzqXxCN8u6SBMvy+KeFsX3piw7ud
         5Mlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUjHqRQmRNIGqBvfOT9U6NFDBjq06A8HbsUZjhAXdmPwjatVhpR
	7mPiDptdw+xUzlcX4jg75yJJ2XlA7BQCycFy2bHZ9f2L2nHgwEqaIkFWRW/aq/5XN8AW4eqvQrX
	ktcwyMp89qjVEQpVOHau4EKuEoMP2fFBDJsgAUr2Ab1guSFYT0rvhR3C0IDrrVNAyWg==
X-Received: by 2002:a17:902:5a3:: with SMTP id f32mr14978032plf.82.1555899222842;
        Sun, 21 Apr 2019 19:13:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLWfDZSo2O6ohUs2dJyo2RRS7QCd4+qV6Q+waHDQRtG02w6ZURiEOsYPy17X7ATBVhoaVq
X-Received: by 2002:a17:902:5a3:: with SMTP id f32mr14977941plf.82.1555899221218;
        Sun, 21 Apr 2019 19:13:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555899221; cv=none;
        d=google.com; s=arc-20160816;
        b=kLYOvRE/HzVD8unP1/Jnzl3rY8Io7PbzBjuNo6R2PoXNf75zY024j6wkMH9WQxz+vA
         GEs66RhDvUoGPs7uuUG9mi6qdRdrlncoDKx9p2O9NXgw3r2jh8F/PXMghFCxc/YWWCda
         /HRnHm3VoAcaJesCmZX3DbVYupiijgywdMq6mYBbDCFLQCFxba8PsWHYAid0uX/xSvPo
         1MOT8O3nJmwWcDtp1tjZvR0hhGI3pHQNT3vn3ei4CPN6oifR26WPKXn4whEujCPfgw7F
         77eCBsXclq661M+eeE0xNBkzq84IgMGFUhfhJdFVxwGRlnSDMaxr11Yh8sbPqEas1rMG
         LNwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=nwfOC8RJhm6OU8t+xhI0HBAArOj5sRzoz/qLdrGHcDo=;
        b=WcINepwvnsBTkFcaxEO4zVzQ/0lfs/rCKfKhDfuNiwffMYR7HdJCFSX8jUs7oQ7CNl
         yj43UIwMlT97hXXClshRSs+oYskSsTLxHPWZjcy1HL/Tk1Mw5QwSrPcXx7WooXZe/XR4
         YCLYEQi+idpN08J9V6qMC2jFz4zF19G50daGd9Uk1GgqYryD98Hnow2SnnLX+ThLkK1y
         UqmQ5FbTpMZtGQ1GeuRmUAY/AFHFkraTcc8rnsBvVI5OwcS4nLXfLi12GoaiCTV8tzuZ
         TMrspywEy6YPiKJFI1ASjXDmLFvRphVOrqcvkKsy91r7G8yLGrTLqKDqCG+sDlQTFbMn
         /4Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id x5si12158544pfa.41.2019.04.21.19.13.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Apr 2019 19:13:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TPtrPj4_1555899216;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TPtrPj4_1555899216)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 22 Apr 2019 10:13:36 +0800
Subject: [RFC PATCH 3/5] numa: introduce per-cgroup preferred numa node
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Message-ID: <77452c03-bc4c-7aed-e605-d5351f868586@linux.alibaba.com>
Date: Mon, 22 Apr 2019 10:13:36 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch add a new entry 'numa_preferred' for each memory cgroup,
by which we can now override the memory policy of the tasks inside
a particular cgroup, combined with numa balancing, we now be able to
migrate the workloads of a cgroup to the specified numa node, in gentle
way.

The load balancing and numa prefer against each other on CPU locations,
which lead into the situation that although a particular node is capable
enough to hold all the workloads, tasks will still spread.

In order to acquire the numa benifit in this situation,  load balancing
should respect the prefer decision as long as the balancing won't be
broken.

This patch try to forbid workloads leave memcg preferred node, when
and only when numa preferred node configured, in case if load balancing
can't find other tasks to move and keep failing, we will then giveup
and allow the migration to happen.

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
 include/linux/memcontrol.h | 34 +++++++++++++++++++
 include/linux/sched.h      |  1 +
 kernel/sched/debug.c       |  1 +
 kernel/sched/fair.c        | 33 +++++++++++++++++++
 mm/huge_memory.c           |  3 ++
 mm/memcontrol.c            | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                |  4 +++
 mm/mempolicy.c             |  4 +++
 8 files changed, 162 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e784d6252d5e..0fd5eeb27c4f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -335,6 +335,8 @@ struct mem_cgroup {

 #ifdef CONFIG_NUMA_BALANCING
 	struct memcg_stat_numa __percpu *stat_numa;
+	s64 numa_preferred;
+	struct mutex numa_mutex;
 #endif

 	struct mem_cgroup_per_node *nodeinfo[0];
@@ -846,10 +848,26 @@ void mem_cgroup_split_huge_fixup(struct page *head);

 #ifdef CONFIG_NUMA_BALANCING
 extern void memcg_stat_numa_update(struct task_struct *p);
+extern int memcg_migrate_prep(int target_nid, int page_nid);
+extern int memcg_preferred_nid(struct task_struct *p, gfp_t gfp);
+extern struct page *alloc_page_numa_preferred(gfp_t gfp, unsigned int order);
 #else
 static inline void memcg_stat_numa_update(struct task_struct *p)
 {
 }
+static inline int memcg_migrate_prep(int target_nid, int page_nid)
+{
+	return target_nid;
+}
+static inline int memcg_preferred_nid(struct task_struct *p, gfp_t gfp)
+{
+	return -1;
+}
+static inline struct page *alloc_page_numa_preferred(gfp_t gfp,
+						     unsigned int order)
+{
+	return NULL;
+}
 #endif

 #else /* CONFIG_MEMCG */
@@ -1195,6 +1213,22 @@ static inline void memcg_stat_numa_update(struct task_struct *p)
 {
 }

+static inline int memcg_migrate_prep(int target_nid, int page_nid)
+{
+	return target_nid;
+}
+
+static inline int memcg_preferred_nid(struct task_struct *p, gfp_t gfp)
+{
+	return -1;
+}
+
+static inline struct page *alloc_page_numa_preferred(gfp_t gfp,
+						     unsigned int order)
+{
+	return NULL;
+}
+
 #endif /* CONFIG_MEMCG */

 /* idx can be of type enum memcg_stat_item or node_stat_item */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0b01262d110d..9f931db1d31f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -422,6 +422,7 @@ struct sched_statistics {
 	u64				nr_migrations_cold;
 	u64				nr_failed_migrations_affine;
 	u64				nr_failed_migrations_running;
+	u64				nr_failed_migrations_memcg;
 	u64				nr_failed_migrations_hot;
 	u64				nr_forced_migrations;

diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index 2898f5fa4fba..32f5fd66f0fe 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -934,6 +934,7 @@ void proc_sched_show_task(struct task_struct *p, struct pid_namespace *ns,
 		P_SCHEDSTAT(se.statistics.nr_migrations_cold);
 		P_SCHEDSTAT(se.statistics.nr_failed_migrations_affine);
 		P_SCHEDSTAT(se.statistics.nr_failed_migrations_running);
+		P_SCHEDSTAT(se.statistics.nr_failed_migrations_memcg);
 		P_SCHEDSTAT(se.statistics.nr_failed_migrations_hot);
 		P_SCHEDSTAT(se.statistics.nr_forced_migrations);
 		P_SCHEDSTAT(se.statistics.nr_wakeups);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ba5a67139d57..5d0758e78b96 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -6701,6 +6701,10 @@ select_task_rq_fair(struct task_struct *p, int prev_cpu, int sd_flag, int wake_f
 		new_cpu = find_idlest_cpu(sd, p, cpu, prev_cpu, sd_flag);
 	} else if (sd_flag & SD_BALANCE_WAKE) { /* XXX always ? */
 		/* Fast path */
+		int pnid = memcg_preferred_nid(p, 0);
+
+		if (pnid != NUMA_NO_NODE && pnid != cpu_to_node(new_cpu))
+			new_cpu = prev_cpu;

 		new_cpu = select_idle_sibling(p, prev_cpu, new_cpu);

@@ -7404,12 +7408,36 @@ static int migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
 	return dst_weight < src_weight;
 }

+static inline bool memcg_migrate_allow(struct task_struct *p,
+					struct lb_env *env)
+{
+	int src_nid, dst_nid, pnid;
+
+	/* failed too much could imply balancing broken, now be a good boy */
+	if (env->sd->nr_balance_failed > env->sd->cache_nice_tries)
+		return true;
+
+	src_nid = cpu_to_node(env->src_cpu);
+	dst_nid = cpu_to_node(env->dst_cpu);
+
+	pnid = memcg_preferred_nid(p, 0);
+	if (pnid != dst_nid && pnid == src_nid)
+		return false;
+
+	return true;
+}
 #else
 static inline int migrate_degrades_locality(struct task_struct *p,
 					     struct lb_env *env)
 {
 	return -1;
 }
+
+static inline bool memcg_migrate_allow(struct task_struct *p,
+					struct lb_env *env)
+{
+	return true;
+}
 #endif

 /*
@@ -7470,6 +7498,11 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 		return 0;
 	}

+	if (!memcg_migrate_allow(p, env)) {
+		schedstat_inc(p->se.statistics.nr_failed_migrations_memcg);
+		return 0;
+	}
+
 	/*
 	 * Aggressive migration if:
 	 * 1) destination numa is preferred
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2614ce725a63..c01e1bb22477 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1523,6 +1523,9 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	 */
 	page_locked = trylock_page(page);
 	target_nid = mpol_misplaced(page, vma, haddr);
+
+	target_nid = memcg_migrate_prep(target_nid, page_nid);
+
 	if (target_nid == NUMA_NO_NODE) {
 		/* If the page was locked, there are no parallel migrations */
 		if (page_locked)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 91bcd71fc38a..f1cb1e726430 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3452,6 +3452,79 @@ void memcg_stat_numa_update(struct task_struct *p)
 	this_cpu_inc(memcg->stat_numa->exectime);
 	rcu_read_unlock();
 }
+
+static s64 memcg_numa_preferred_read_s64(struct cgroup_subsys_state *css,
+				struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return memcg->numa_preferred;
+}
+
+static int memcg_numa_preferred_write_s64(struct cgroup_subsys_state *css,
+				struct cftype *cft, s64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	if (val != NUMA_NO_NODE && !node_isset(val, node_possible_map))
+		return -EINVAL;
+
+	mutex_lock(&memcg->numa_mutex);
+	memcg->numa_preferred = val;
+	mutex_unlock(&memcg->numa_mutex);
+
+	return 0;
+}
+
+int memcg_preferred_nid(struct task_struct *p, gfp_t gfp)
+{
+	int preferred_nid = NUMA_NO_NODE;
+
+	if (!mem_cgroup_disabled() &&
+	    !in_interrupt() &&
+	    !(gfp & __GFP_THISNODE)) {
+		struct mem_cgroup *memcg;
+
+		rcu_read_lock();
+		memcg = mem_cgroup_from_task(p);
+		if (memcg)
+			preferred_nid = memcg->numa_preferred;
+		rcu_read_unlock();
+	}
+
+	return preferred_nid;
+}
+
+int memcg_migrate_prep(int target_nid, int page_nid)
+{
+	bool ret = false;
+	unsigned int cookie;
+	int preferred_nid = memcg_preferred_nid(current, 0);
+
+	if (preferred_nid == NUMA_NO_NODE)
+		return target_nid;
+
+	do {
+		cookie = read_mems_allowed_begin();
+		ret = node_isset(preferred_nid, current->mems_allowed);
+	} while (read_mems_allowed_retry(cookie));
+
+	if (ret)
+		return page_nid == preferred_nid ? NUMA_NO_NODE : preferred_nid;
+
+	return target_nid;
+}
+
+struct page *alloc_page_numa_preferred(gfp_t gfp, unsigned int order)
+{
+	int pnid = memcg_preferred_nid(current, gfp);
+
+	if (pnid == NUMA_NO_NODE || !node_isset(pnid, current->mems_allowed))
+		return NULL;
+
+	return __alloc_pages_node(pnid, gfp, order);
+}
+
 #endif

 /* Universal VM events cgroup1 shows, original sort order */
@@ -4309,6 +4382,13 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.name = "numa_stat",
 		.seq_show = memcg_numa_stat_show,
 	},
+#endif
+#ifdef CONFIG_NUMA_BALANCING
+	{
+		.name = "numa_preferred",
+		.read_s64 = memcg_numa_preferred_read_s64,
+		.write_s64 = memcg_numa_preferred_write_s64,
+	},
 #endif
 	{
 		.name = "kmem.limit_in_bytes",
@@ -4529,6 +4609,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	memcg->stat_numa = alloc_percpu(struct memcg_stat_numa);
 	if (!memcg->stat_numa)
 		goto fail;
+	mutex_init(&memcg->numa_mutex);
+	memcg->numa_preferred = NUMA_NO_NODE;
 #endif

 	for_each_node(node)
diff --git a/mm/memory.c b/mm/memory.c
index fb0c1d940d36..98d988ca717c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -70,6 +70,7 @@
 #include <linux/dax.h>
 #include <linux/oom.h>
 #include <linux/numa.h>
+#include <linux/memcontrol.h>

 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -3675,6 +3676,9 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	target_nid = numa_migrate_prep(page, vma, vmf->address, page_nid,
 			&flags);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
+
+	target_nid = memcg_migrate_prep(target_nid, page_nid);
+
 	if (target_nid == NUMA_NO_NODE) {
 		put_page(page);
 		goto out;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index af171ccb56a2..6513504373b4 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2031,6 +2031,10 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,

 	pol = get_vma_policy(vma, addr);

+	page = alloc_page_numa_preferred(gfp, order);
+	if (page)
+		goto out;
+
 	if (pol->mode == MPOL_INTERLEAVE) {
 		unsigned nid;

-- 
2.14.4.44.g2045bb6

