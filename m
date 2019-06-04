Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90BC4C04AB5
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5109826400
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5109826400
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD7A56B0269; Mon,  3 Jun 2019 21:58:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAD186B026A; Mon,  3 Jun 2019 21:58:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D406B026B; Mon,  3 Jun 2019 21:58:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 913F86B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 21:58:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m12so12960086pls.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 18:58:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ktGf/cQzKJ4MjI4oBxcYqq/43d2V0RTD+hrirgwIQ4Y=;
        b=uIQlLTqF8Mf70IM5lxHmeJ+80cCiJGuvtoes3NzwiGTBaEPl7IuetbCIWvOs0jovrM
         SYCJzjHFzHt+Zw5V8LifqkHJvZ0Sw18lX1OOoDoh4gZxKgD32ByG+lKLQswygXrEH4bG
         PQI+glwnjB9S15v1RZq6Zu4+JEa05UfY62LaWQSp+WPe5kqh/20DBHMWSwDbfGj9RSWV
         Vs0GY2OtUKJnppC7yOPt1cohM0mgNmfGIkuRo6gLNGLWSTP32l1op6P+5IHP9sUOjuA5
         rn5EDseeDQJplNVABjTN0460gPVbBrGEihEmTaM5+oJZSzUc9NvgVs5CI+miiBgpAwku
         DqlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUIpybFVaZflZZWjnB25rVZqqGjol0El+rQGpB+X+cSofwzsmfW
	49pIBeeT5FdJZZEQOj7G4Bo8V1z4Kd4nNoZsqWdi9HfkxfXRCYAbDwz/obAZ/0Q2Sf7KgZlTWtA
	OnXzk70jXTk4MH/+AcegHK7YmmBlYaYyoNbIgTg6ZrWb+FAO4BDkKiYdUvvtlDgkvZQ==
X-Received: by 2002:aa7:9a8c:: with SMTP id w12mr34891649pfi.187.1559613514267;
        Mon, 03 Jun 2019 18:58:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/uJ2pUjfchX6cWl5IqAuYzetD5UvyjvSvLA99BYjDSrHkev51sVpFDBtw5RuUCUsTHwyU
X-Received: by 2002:aa7:9a8c:: with SMTP id w12mr34891532pfi.187.1559613513022;
        Mon, 03 Jun 2019 18:58:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559613513; cv=none;
        d=google.com; s=arc-20160816;
        b=JEDLvLFgrkbLby4jH75+RhAdc8FeBxbyxN0Htkfd7YiAoDHeFyNuc8ii2sQauSC3t8
         TpBsS4b3PQ/K++uShE4FrIjplQpGqoTbkpSvzDE71gecBl0EIOLc3gce+PCyerfjnN0m
         6JlPv0chScSGJGvvLkm9VkM0gJLUDUBsYV58pY4PaGtnEkNy6EWqORlpoU9323hkA4GQ
         HF5cC3t8JiHylAEeGnaf7FUS4IfwFBcw+oruraco1TBay3CbpQ/2UV7j3Q9MYMcVdNri
         UFnmaG0W9c2dHNYbPP411gk9EzvVB/l4QyWnOqa+COWJQ7A/4xcYNETwQWM7L6nStgek
         cKgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ktGf/cQzKJ4MjI4oBxcYqq/43d2V0RTD+hrirgwIQ4Y=;
        b=m1lDocjfIPV8aUeHb3DMn+W1HiPt7N38lHwxDLx1u0YOXEwfJlPbPDQgxOVJCLp6qK
         TH0gvay+qpdXwwzbfLjo4P5zN6L4DxOQZDm9XoeSZun7HtcFnm5xMbXMZBc7ziyW+FAl
         Ae3P3r17HFSUMDZvkDY7/XSo1YuhEvWizcaGdKdKCLR/T2EDr/Erd9RMSqP0byDPI50k
         cBKxgM2T9ST7SycP5NwgLrKdyyFn6WwKTf2CaBKesRF48uM5ljDV434DK9wRfMheE5OQ
         1WECQlMIf8BcZRhfaCAvpV7rAQ4cj0/gk5wKffyX49KrwxJeuOCpwr1OTos7yf4b1Dul
         wuuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id 11si6222623pfx.243.2019.06.03.18.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 18:58:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R441e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TTNnVvj_1559613510;
Received: from localhost(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0TTNnVvj_1559613510)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 04 Jun 2019 09:58:30 +0800
From: Joseph Qi <joseph.qi@linux.alibaba.com>
To: linux-mm@kvack.org,
	cgroups@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>,
	Jiufei Xue <jiufei.xue@linux.alibaba.com>,
	Caspar Zhang <caspar@linux.alibaba.com>,
	Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: [RFC PATCH 2/3] psi: cgroup v1 support
Date: Tue,  4 Jun 2019 09:57:44 +0800
Message-Id: <20190604015745.78972-3-joseph.qi@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.856.g8858448bb
In-Reply-To: <20190604015745.78972-1-joseph.qi@linux.alibaba.com>
References: <20190604015745.78972-1-joseph.qi@linux.alibaba.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Implements pressure stall tracking for cgroup v1.

Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
---
 kernel/sched/psi.c | 65 +++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 56 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 7acc632c3b82..909083c828d5 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -719,13 +719,30 @@ static u32 psi_group_change(struct psi_group *group, int cpu,
 	return state_mask;
 }
 
-static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
+static struct cgroup *psi_task_cgroup(struct task_struct *task, enum psi_res res)
+{
+	switch (res) {
+	case NR_PSI_RESOURCES:
+		return task_dfl_cgroup(task);
+	case PSI_IO:
+		return task_cgroup(task, io_cgrp_subsys.id);
+	case PSI_MEM:
+		return task_cgroup(task, memory_cgrp_subsys.id);
+	case PSI_CPU:
+		return task_cgroup(task, cpu_cgrp_subsys.id);
+	default:  /* won't reach here */
+		return NULL;
+	}
+}
+
+static struct psi_group *iterate_groups(struct task_struct *task, void **iter,
+					enum psi_res res)
 {
 #ifdef CONFIG_CGROUPS
 	struct cgroup *cgroup = NULL;
 
 	if (!*iter)
-		cgroup = task->cgroups->dfl_cgrp;
+		cgroup = psi_task_cgroup(task, res);
 	else if (*iter == &psi_system)
 		return NULL;
 	else
@@ -776,15 +793,45 @@ void psi_task_change(struct task_struct *task, int clear, int set)
 		     wq_worker_last_func(task) == psi_avgs_work))
 		wake_clock = false;
 
-	while ((group = iterate_groups(task, &iter))) {
-		u32 state_mask = psi_group_change(group, cpu, clear, set);
+	if (cgroup_subsys_on_dfl(cpu_cgrp_subsys) ||
+	    cgroup_subsys_on_dfl(memory_cgrp_subsys) ||
+	    cgroup_subsys_on_dfl(io_cgrp_subsys)) {
+		while ((group = iterate_groups(task, &iter, NR_PSI_RESOURCES))) {
+			u32 state_mask = psi_group_change(group, cpu, clear, set);
 
-		if (state_mask & group->poll_states)
-			psi_schedule_poll_work(group, 1);
+			if (state_mask & group->poll_states)
+				psi_schedule_poll_work(group, 1);
 
-		if (wake_clock && !delayed_work_pending(&group->avgs_work))
-			schedule_delayed_work(&group->avgs_work, PSI_FREQ);
+			if (wake_clock && !delayed_work_pending(&group->avgs_work))
+				schedule_delayed_work(&group->avgs_work, PSI_FREQ);
+		}
+	} else {
+		enum psi_task_count i;
+		enum psi_res res;
+		int psi_flags = clear | set;
+
+		for (i = NR_IOWAIT; i < NR_PSI_TASK_COUNTS; i++) {
+			if ((i == NR_IOWAIT) && (psi_flags & TSK_IOWAIT))
+				res = PSI_IO;
+			else if ((i == NR_MEMSTALL) && (psi_flags & TSK_MEMSTALL))
+				res = PSI_MEM;
+			else if ((i == NR_RUNNING) && (psi_flags & TSK_RUNNING))
+				res = PSI_CPU;
+			else
+				continue;
+
+			while ((group = iterate_groups(task, &iter, res))) {
+				u32 state_mask = psi_group_change(group, cpu, clear, set);
+
+				if (state_mask & group->poll_states)
+					psi_schedule_poll_work(group, 1);
+
+				if (wake_clock && !delayed_work_pending(&group->avgs_work))
+					schedule_delayed_work(&group->avgs_work, PSI_FREQ);
+			}
+		}
 	}
+
 }
 
 void psi_memstall_tick(struct task_struct *task, int cpu)
@@ -792,7 +839,7 @@ void psi_memstall_tick(struct task_struct *task, int cpu)
 	struct psi_group *group;
 	void *iter = NULL;
 
-	while ((group = iterate_groups(task, &iter))) {
+	while ((group = iterate_groups(task, &iter, PSI_MEM))) {
 		struct psi_group_cpu *groupc;
 
 		groupc = per_cpu_ptr(group->pcpu, cpu);
-- 
2.19.1.856.g8858448bb

