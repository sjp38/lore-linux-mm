Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 843BEC10F14
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11F7D2075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:11:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11F7D2075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90FF36B0006; Sun, 21 Apr 2019 22:11:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 895F46B0007; Sun, 21 Apr 2019 22:11:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7396A6B0008; Sun, 21 Apr 2019 22:11:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3185C6B0006
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 22:11:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n5so7104166pgk.9
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 19:11:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=/+uk769LOifZHkGx6iZ9R1GalybMGrzrLNtBe46uWio=;
        b=EBxEvgHMAcd5Cv6/tYfVUlfLOsw3y3OIXAlzHgChP+2ayjxPZKcV2MFROri+YHBXdn
         U/zlKtc7gCpTMWLa0GIvJxx0APxyZTzSc4DRcNhVaDeT/ItQKhVPQMRgLLZEFQI1b4Sd
         PycL4uegrBErl6vgLk/MpefT8ubPq1o0Vpz67gW0YQvLHnMZoRFtykAo1FArbvj0uXAM
         Vdlk9mv9F0NfjFZMOaw7eHADHl7Y7Gp2jga0kMLQAz7WWsX1iB/l8ssKuJVvuV305id9
         bt0Ox+8pIfqGqB2OTqAcsf7KfEhGG7HeYwlGMAyM+cJUoyjFX0mI//v+J7CMLfBLQXB/
         4feQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV2sU95APgNfZ125ZK/cVD9oZVuPquaI96nm7zdYbcvr5+rdPHF
	G4wM23kpbf3s5X0TXT9zTTCtyecjl/PcFI0otP8NK/m2doHHwu8n/hhlqVJDp1BKaQ+kTMNaJAR
	DGZ4/T0RnQ3AG5QaUEub0iWedWQAM6fGG2fvJjwCgTUvzIR8oBI8aKsXHOnoyZbUFxw==
X-Received: by 2002:a17:902:1681:: with SMTP id h1mr17665524plh.102.1555899089789;
        Sun, 21 Apr 2019 19:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZwNUup7n4wmKtit/uL0U6e+HT5MW8T+9J9UzwEA1C85B8Mycu/WVOILEfBfrwyCuQwjy+
X-Received: by 2002:a17:902:1681:: with SMTP id h1mr17665439plh.102.1555899088295;
        Sun, 21 Apr 2019 19:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555899088; cv=none;
        d=google.com; s=arc-20160816;
        b=aV2Kg/B+A/DcXoeZEw2LTC9M5wB1pWa19uj21XFh3sZdGFSi31smvAbBl2Az6WkZvW
         kmhBvjFz6KCVot4JVPRHPbMhcBFYHiVkIvpa0+jgf/j5E8kJ54hMaIVFkqbJwGbIKlh8
         /bUxPAaXk+gbTLNEodLYInUTHQMWKonPQtVL4F3rynS41sypIVsUpSoVgpuf82iURbhg
         ZH+FtYMwp6Uxt2fvZEPMbgWTVvTQ0LFe6nCtaeAqbhkJtPob/lGt4YYHMNlRalH3DqXd
         OOnZxwoToZ84tw1EnB2xxSILFXOtbLxTqrQBS921MpZN1BtswAtiUygjztS2Kllm24b2
         mAXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=/+uk769LOifZHkGx6iZ9R1GalybMGrzrLNtBe46uWio=;
        b=uEnujuMYNe/ynur4ak80ODgilL1lQz5eHMaNl87MEV4WsQhrQK5zp4uVLeS3tuQJeN
         jCqRbaWx3p+Zs65weTbIOKjne+ch9OhriKWg7RE0PI/5dO4+bGbUJBIoxkFlRXtIbEiK
         HX6jjWGZ9q0IHibRHpGHlSnze3vBrf9LRVSNKgUhNnMMpYsiRISQMDXsDZWd/g9r9WK/
         IeRSDQL5b435noMJPKXRzb404Q2bzVXdpWOazulom+M6tNRXoXWI4ZaUHX8k40yimaBw
         9g+dX6t2mAGiA3dLrhE5kq1I+iShSGzvWFmgdkofGL1e6Ukgulu5GcGmZKFMwN2LkIt+
         BHlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id t1si1264623plr.373.2019.04.21.19.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Apr 2019 19:11:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TPtsXaT_1555899084;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TPtsXaT_1555899084)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 22 Apr 2019 10:11:25 +0800
Subject: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing locality,
 statistic
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Message-ID: <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
Date: Mon, 22 Apr 2019 10:11:24 +0800
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

This patch introduced numa locality statistic, which try to imply
the numa balancing efficiency per memory cgroup.

By doing 'cat /sys/fs/cgroup/memory/CGROUP_PATH/memory.numa_stat', we
see new output line heading with 'locality', the format is:

  locality 0~9% 10%~19% 20%~29% 30%~39% 40%~49% 50%~59% 60%~69% 70%~79%
80%~89% 90%~100%

interval means that on a task's last numa balancing, the percentage
of accessing local pages, which we called numa balancing locality.

And the number means inside the cgroup, how many ticks we hit tasks with
such locality are running, for example:

  locality 7260278 54860 90493 209327 295801 462784 558897 667242
2786324 7399308

the 7260278 means that this cgroup have some tasks with 0~9% locality
executed 7260278 ticks.

By monitoring the increment, we can check if the workload of a particular
cgroup is doing well with numa, when most of the tasks are running with
locality 0~9%, then something is wrong with your numa policy.

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
 include/linux/memcontrol.h | 38 +++++++++++++++++++++++++++++++++++
 include/linux/sched.h      |  8 +++++++-
 kernel/sched/debug.c       |  7 +++++++
 kernel/sched/fair.c        |  8 ++++++++
 mm/huge_memory.c           |  4 +---
 mm/memcontrol.c            | 50 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                |  5 ++---
 7 files changed, 113 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 534267947664..bb62e6294484 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -179,6 +179,27 @@ enum memcg_kmem_state {
 	KMEM_ONLINE,
 };

+#ifdef CONFIG_NUMA_BALANCING
+
+enum memcg_numa_locality_interval {
+	PERCENT_0_9,
+	PERCENT_10_19,
+	PERCENT_20_29,
+	PERCENT_30_39,
+	PERCENT_40_49,
+	PERCENT_50_59,
+	PERCENT_60_69,
+	PERCENT_70_79,
+	PERCENT_80_89,
+	PERCENT_90_100,
+	NR_NL_INTERVAL,
+};
+
+struct memcg_stat_numa {
+	u64 locality[NR_NL_INTERVAL];
+};
+
+#endif
 #if defined(CONFIG_SMP)
 struct memcg_padding {
 	char x[0];
@@ -311,6 +332,10 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;

+#ifdef CONFIG_NUMA_BALANCING
+	struct memcg_stat_numa __percpu *stat_numa;
+#endif
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
@@ -818,6 +843,14 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif

+#ifdef CONFIG_NUMA_BALANCING
+extern void memcg_stat_numa_update(struct task_struct *p);
+#else
+static inline void memcg_stat_numa_update(struct task_struct *p)
+{
+}
+#endif
+
 #else /* CONFIG_MEMCG */

 #define MEM_CGROUP_ID_SHIFT	0
@@ -1156,6 +1189,11 @@ static inline
 void count_memcg_event_mm(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline void memcg_stat_numa_update(struct task_struct *p)
+{
+}
+
 #endif /* CONFIG_MEMCG */

 /* idx can be of type enum memcg_stat_item or node_stat_item */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1a3c28d997d4..0b01262d110d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1049,8 +1049,14 @@ struct task_struct {
 	 * scan window were remote/local or failed to migrate. The task scan
 	 * period is adapted based on the locality of the faults with different
 	 * weights depending on whether they were shared or private faults
+	 *
+	 * 0 -- remote faults
+	 * 1 -- local faults
+	 * 2 -- page migration failure
+	 * 3 -- remote page accessing after page migration
+	 * 4 -- local page accessing after page migration
 	 */
-	unsigned long			numa_faults_locality[3];
+	unsigned long			numa_faults_locality[5];

 	unsigned long			numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index 8039d62ae36e..2898f5fa4fba 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -873,6 +873,13 @@ static void sched_show_numa(struct task_struct *p, struct seq_file *m)
 	SEQ_printf(m, "current_node=%d, numa_group_id=%d\n",
 			task_node(p), task_numa_group_id(p));
 	show_numa_stats(p, m);
+	SEQ_printf(m, "faults_locality local=%lu remote=%lu failed=%lu ",
+			p->numa_faults_locality[1],
+			p->numa_faults_locality[0],
+			p->numa_faults_locality[2]);
+	SEQ_printf(m, "lhit=%lu rhit=%lu\n",
+			p->numa_faults_locality[4],
+			p->numa_faults_locality[3]);
 	mpol_put(pol);
 #endif
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fdab7eb6f351..ba5a67139d57 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -23,6 +23,7 @@
 #include "sched.h"

 #include <trace/events/sched.h>
+#include <linux/memcontrol.h>

 /*
  * Targeted preemption latency for CPU-bound tasks:
@@ -2387,6 +2388,11 @@ void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
 		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
 	}

+	p->numa_faults_locality[mem_node == numa_node_id() ? 4 : 3] += pages;
+
+	if (mem_node == NUMA_NO_NODE)
+		return;
+
 	/*
 	 * First accesses are treated as private, otherwise consider accesses
 	 * to be private if the accessing pid has not changed
@@ -2604,6 +2610,8 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
 		return;

+	memcg_stat_numa_update(curr);
+
 	/*
 	 * Using runtime rather than walltime has the dual advantage that
 	 * we (mostly) drive the selection from busy threads and that the
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 404acdcd0455..2614ce725a63 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1621,9 +1621,7 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	if (anon_vma)
 		page_unlock_anon_vma_read(anon_vma);

-	if (page_nid != NUMA_NO_NODE)
-		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR,
-				flags);
+	task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, flags);

 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c532f8685aa3..b810d4e9c906 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -66,6 +66,7 @@
 #include <linux/lockdep.h>
 #include <linux/file.h>
 #include <linux/tracehook.h>
+#include <linux/cpuset.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -3396,10 +3397,50 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 		seq_putc(m, '\n');
 	}

+#ifdef CONFIG_NUMA_BALANCING
+	seq_puts(m, "locality");
+	for (nr = 0; nr < NR_NL_INTERVAL; nr++) {
+		int cpu;
+		u64 sum = 0;
+
+		for_each_possible_cpu(cpu)
+			sum += per_cpu(memcg->stat_numa->locality[nr], cpu);
+
+		seq_printf(m, " %llu", sum);
+	}
+	seq_putc(m, '\n');
+#endif
+
 	return 0;
 }
 #endif /* CONFIG_NUMA */

+#ifdef CONFIG_NUMA_BALANCING
+
+void memcg_stat_numa_update(struct task_struct *p)
+{
+	struct mem_cgroup *memcg;
+	unsigned long remote = p->numa_faults_locality[3];
+	unsigned long local = p->numa_faults_locality[4];
+	unsigned long idx = -1;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	if (remote || local) {
+		idx = (local * 10) / (remote + local);
+		if (idx >= NR_NL_INTERVAL)
+			idx = NR_NL_INTERVAL - 1;
+	}
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(p);
+	if (idx != -1)
+		this_cpu_inc(memcg->stat_numa->locality[idx]);
+	rcu_read_unlock();
+}
+#endif
+
 /* Universal VM events cgroup1 shows, original sort order */
 static const unsigned int memcg1_events[] = {
 	PGPGIN,
@@ -4435,6 +4476,9 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)

 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
+#ifdef CONFIG_NUMA_BALANCING
+	free_percpu(memcg->stat_numa);
+#endif
 	free_percpu(memcg->vmstats_percpu);
 	kfree(memcg);
 }
@@ -4468,6 +4512,12 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg->vmstats_percpu)
 		goto fail;

+#ifdef CONFIG_NUMA_BALANCING
+	memcg->stat_numa = alloc_percpu(struct memcg_stat_numa);
+	if (!memcg->stat_numa)
+		goto fail;
+#endif
+
 	for_each_node(node)
 		if (alloc_mem_cgroup_per_node_info(memcg, node))
 			goto fail;
diff --git a/mm/memory.c b/mm/memory.c
index c0391a9f18b8..fb0c1d940d36 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3609,7 +3609,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL;
 	int page_nid = NUMA_NO_NODE;
-	int last_cpupid;
+	int last_cpupid = 0;
 	int target_nid;
 	bool migrated = false;
 	pte_t pte, old_pte;
@@ -3689,8 +3689,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 		flags |= TNF_MIGRATE_FAIL;

 out:
-	if (page_nid != NUMA_NO_NODE)
-		task_numa_fault(last_cpupid, page_nid, 1, flags);
+	task_numa_fault(last_cpupid, page_nid, 1, flags);
 	return 0;
 }

-- 
2.14.4.44.g2045bb6

