Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6504C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60943217F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ViufV3H9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60943217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08E436B0008; Tue, 19 Mar 2019 19:56:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 013676B000A; Tue, 19 Mar 2019 19:56:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81AB6B000C; Tue, 19 Mar 2019 19:56:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A06026B0008
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:36 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i23so595258pfa.0
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OBXkes655anl10ghu56F3PCl5wd5CeGj94L2IaEvAok=;
        b=lsNmAHPbXjHVCT4CSKV01gQyRg0xm6sZ+WoRZP9plRS+3JS4SjGnBmcafAXzFVcmrR
         zfVexytvvDQDJmacSg68CUgAQG2zbW5ValTlZxns2Pj8n7VFNXX6UZjSkaO2S6h2Wh1T
         4zggDyxnqqytLBjMd/wGz2Jq5+Htv8rcNRVtmQawC27AYf4lQLmz+QggSlhmxxQmc46Y
         BBTu0mKC0Ver+PjoJAi+dYnJSNQGsQtr98S7a1NOnhoEYqs8MN8eSkLZNnUCXePyCPDV
         kkPoaJ9AjLnMa4WYUddSTF6vhvmRiO86d3XoJhojUbqvcQenJ4r1PlZfTr7jo+d2kzTq
         Q0jA==
X-Gm-Message-State: APjAAAUXUraXmknzb2/AkWNfr80wakMOkK6cqrZeZ1P1jRccpKuvb6SR
	4Gic/p4ldMDQwR6v3h0bo8HafTBYmYdx5cz9Ysr507YxEM+Yykk8J7CnxFV8rGbo7a2J6iIQKAa
	YxWuHQmnP6XIWZVnHuv1ny3GZEh5hc5YE2ZwbcXhn9rqqTpFP3+MiobkAoj8OHiHtCQ==
X-Received: by 2002:a65:62d6:: with SMTP id m22mr4880985pgv.443.1553039796099;
        Tue, 19 Mar 2019 16:56:36 -0700 (PDT)
X-Received: by 2002:a65:62d6:: with SMTP id m22mr4880935pgv.443.1553039795003;
        Tue, 19 Mar 2019 16:56:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039794; cv=none;
        d=google.com; s=arc-20160816;
        b=RN/r2eKTRLptkGt8r8fsY5D/xSidTgQwEVVPiwTU+GMnTdUPpDhfn1zCVuWwo7l0Pl
         jiKIn20rFQix/zt6tRmevm+rLuxZpAtW3wgDisUI47oWClgV/R9CNUvYx+Bpr8Au02ed
         DzTSMFW8f9wbnxxVo3bJee4effhIDhrQKYx7Z7s5vFPN0sOT1e5q9uL6MMwzpOdKL/dx
         HlOSEpidAX9bUNQ8lD6QJeQzPFJ2HOuR5XYWx0cfHIdjlWaf9JBQflQG6mrKDBk7RVC5
         K89cMPGXkE7c9vIJnPzOd426JMG0xQ059HzimN35BRWtDnUzjTCnMmdp2G2p+RFn+PVC
         OhyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OBXkes655anl10ghu56F3PCl5wd5CeGj94L2IaEvAok=;
        b=pk069JAHTyg1tRJwrsywa5KmLBrUs187gDNrBuMmVmha5fUYCrniOT++zH+TjQH/gZ
         G16t407NHJa0324gwOWU4qnLOk4XfU9W2fYQ95R6jgiMRbIw3zn7K+5vcRyagcDacP2+
         peiK4+gmwKCF8d1q3R4y7oxFFO0bQlSSX8E5vFTIaaEE3lfrOD05EWe0e04AZ8Np9hBP
         Pabt5PKTh5xDPli9Bf377zKro0y+KPAgxu3x766kBjCMc6n3PqeVDzHut71jfiq7KXbG
         ZYJHUvotdE4bxG5sGHwoOaM+Fsep6RNKNGfjd3mXA9CfT5cMCrRfhimh1wA8L3BiErHT
         kcDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ViufV3H9;
       spf=pass (google.com: domain of 3sogrxaykcouzbyluinvvnsl.jvtspube-ttrchjr.vyn@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3soGRXAYKCOUZbYLUINVVNSL.JVTSPUbe-TTRcHJR.VYN@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w8sor300136pgs.25.2019.03.19.16.56.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3sogrxaykcouzbyluinvvnsl.jvtspube-ttrchjr.vyn@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ViufV3H9;
       spf=pass (google.com: domain of 3sogrxaykcouzbyluinvvnsl.jvtspube-ttrchjr.vyn@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3soGRXAYKCOUZbYLUINVVNSL.JVTSPUbe-TTRcHJR.VYN@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OBXkes655anl10ghu56F3PCl5wd5CeGj94L2IaEvAok=;
        b=ViufV3H9RpAeDfEYRca09ZHiuCDEEE7bKNCDMcMtKBrJC14eRqNfcqNHHYQOq+na9V
         6H7JdNNGddCsCaecqnHRDT4qvYX1DB8C6plteEXU+zIk9R8baXzQOsoHfLMW7UYoIrJa
         xnxyu8o4Ns4Hw4KIqkgi04u/ojN0sGrpDJ53t1VKOu9ympyYotAVuoZWBitaFUIMdMav
         Nyhu/nbgRgdMV1SO9zoqliqG4Z3hvkfNYsgnd1suNAvHG589L2XGHM6fZx/n65Up7Ijh
         Cxbjtaq3cvyaQyocIsPIbFFUuY28iDEH1CwonE07NSVXVpttNoqUiLr31kJH9b2CyWhZ
         7Azw==
X-Google-Smtp-Source: APXvYqyuwpOXbhD+fWfIrgCA7neQKWQsukpEJktLS0Mziza+SL39C80NgdVKpxLsF1KcKTsjtymvde1TM/8=
X-Received: by 2002:a65:6495:: with SMTP id e21mr8268337pgv.58.1553039794697;
 Tue, 19 Mar 2019 16:56:34 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:15 -0700
In-Reply-To: <20190319235619.260832-1-surenb@google.com>
Message-Id: <20190319235619.260832-4-surenb@google.com>
Mime-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 3/7] psi: rename psi fields in preparation for psi trigger addition
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Renaming psi_group structure member fields used for calculating psi totals
and averages for clear distinction between them and trigger-related fields
that will be added next.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 include/linux/psi_types.h | 14 ++++++-------
 kernel/sched/psi.c        | 41 ++++++++++++++++++++-------------------
 2 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 762c6bb16f3c..4d1c1f67be18 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -69,17 +69,17 @@ struct psi_group_cpu {
 };
 
 struct psi_group {
-	/* Protects data updated during an aggregation */
-	struct mutex stat_lock;
+	/* Protects data used by the aggregator */
+	struct mutex avgs_lock;
 
 	/* Per-cpu task state & time tracking */
 	struct psi_group_cpu __percpu *pcpu;
 
-	/* Periodic aggregation state */
-	u64 total_prev[NR_PSI_STATES - 1];
-	u64 last_update;
-	u64 next_update;
-	struct delayed_work clock_work;
+	/* Running pressure averages */
+	u64 avg_total[NR_PSI_STATES - 1];
+	u64 avg_last_update;
+	u64 avg_next_update;
+	struct delayed_work avgs_work;
 
 	/* Total stall times and sampled pressure averages */
 	u64 total[NR_PSI_STATES - 1];
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 281702de9772..4fb4d9913bc8 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -165,7 +165,7 @@ static struct psi_group psi_system = {
 	.pcpu = &system_group_pcpu,
 };
 
-static void psi_update_work(struct work_struct *work);
+static void psi_avgs_work(struct work_struct *work);
 
 static void group_init(struct psi_group *group)
 {
@@ -173,9 +173,9 @@ static void group_init(struct psi_group *group)
 
 	for_each_possible_cpu(cpu)
 		seqcount_init(&per_cpu_ptr(group->pcpu, cpu)->seq);
-	group->next_update = sched_clock() + psi_period;
-	INIT_DELAYED_WORK(&group->clock_work, psi_update_work);
-	mutex_init(&group->stat_lock);
+	group->avg_next_update = sched_clock() + psi_period;
+	INIT_DELAYED_WORK(&group->avgs_work, psi_avgs_work);
+	mutex_init(&group->avgs_lock);
 }
 
 void __init psi_init(void)
@@ -278,7 +278,7 @@ static bool update_stats(struct psi_group *group)
 	int cpu;
 	int s;
 
-	mutex_lock(&group->stat_lock);
+	mutex_lock(&group->avgs_lock);
 
 	/*
 	 * Collect the per-cpu time buckets and average them into a
@@ -319,7 +319,7 @@ static bool update_stats(struct psi_group *group)
 
 	/* avgX= */
 	now = sched_clock();
-	expires = group->next_update;
+	expires = group->avg_next_update;
 	if (now < expires)
 		goto out;
 	if (now - expires >= psi_period)
@@ -332,14 +332,14 @@ static bool update_stats(struct psi_group *group)
 	 * But the deltas we sample out of the per-cpu buckets above
 	 * are based on the actual time elapsing between clock ticks.
 	 */
-	group->next_update = expires + ((1 + missed_periods) * psi_period);
-	period = now - (group->last_update + (missed_periods * psi_period));
-	group->last_update = now;
+	group->avg_next_update = expires + ((1 + missed_periods) * psi_period);
+	period = now - (group->avg_last_update + (missed_periods * psi_period));
+	group->avg_last_update = now;
 
 	for (s = 0; s < NR_PSI_STATES - 1; s++) {
 		u32 sample;
 
-		sample = group->total[s] - group->total_prev[s];
+		sample = group->total[s] - group->avg_total[s];
 		/*
 		 * Due to the lockless sampling of the time buckets,
 		 * recorded time deltas can slip into the next period,
@@ -359,22 +359,22 @@ static bool update_stats(struct psi_group *group)
 		 */
 		if (sample > period)
 			sample = period;
-		group->total_prev[s] += sample;
+		group->avg_total[s] += sample;
 		calc_avgs(group->avg[s], missed_periods, sample, period);
 	}
 out:
-	mutex_unlock(&group->stat_lock);
+	mutex_unlock(&group->avgs_lock);
 	return nonidle_total;
 }
 
-static void psi_update_work(struct work_struct *work)
+static void psi_avgs_work(struct work_struct *work)
 {
 	struct delayed_work *dwork;
 	struct psi_group *group;
 	bool nonidle;
 
 	dwork = to_delayed_work(work);
-	group = container_of(dwork, struct psi_group, clock_work);
+	group = container_of(dwork, struct psi_group, avgs_work);
 
 	/*
 	 * If there is task activity, periodically fold the per-cpu
@@ -391,8 +391,9 @@ static void psi_update_work(struct work_struct *work)
 		u64 now;
 
 		now = sched_clock();
-		if (group->next_update > now)
-			delay = nsecs_to_jiffies(group->next_update - now) + 1;
+		if (group->avg_next_update > now)
+			delay = nsecs_to_jiffies(
+					group->avg_next_update - now) + 1;
 		schedule_delayed_work(dwork, delay);
 	}
 }
@@ -546,13 +547,13 @@ void psi_task_change(struct task_struct *task, int clear, int set)
 	 */
 	if (unlikely((clear & TSK_RUNNING) &&
 		     (task->flags & PF_WQ_WORKER) &&
-		     wq_worker_last_func(task) == psi_update_work))
+		     wq_worker_last_func(task) == psi_avgs_work))
 		wake_clock = false;
 
 	while ((group = iterate_groups(task, &iter))) {
 		psi_group_change(group, cpu, clear, set);
-		if (wake_clock && !delayed_work_pending(&group->clock_work))
-			schedule_delayed_work(&group->clock_work, PSI_FREQ);
+		if (wake_clock && !delayed_work_pending(&group->avgs_work))
+			schedule_delayed_work(&group->avgs_work, PSI_FREQ);
 	}
 }
 
@@ -649,7 +650,7 @@ void psi_cgroup_free(struct cgroup *cgroup)
 	if (static_branch_likely(&psi_disabled))
 		return;
 
-	cancel_delayed_work_sync(&cgroup->psi.clock_work);
+	cancel_delayed_work_sync(&cgroup->psi.avgs_work);
 	free_percpu(cgroup->psi.pcpu);
 }
 
-- 
2.21.0.225.g810b269d1ac-goog

