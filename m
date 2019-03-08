Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 968EEC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FD5920857
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eLdg3v+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FD5920857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4C338E0006; Fri,  8 Mar 2019 13:43:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDB358E0002; Fri,  8 Mar 2019 13:43:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9FCA8E0006; Fri,  8 Mar 2019 13:43:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66FD28E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:43:30 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h70so22996637pfd.11
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:43:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OplnuXRZxId0pdfBC75FwRElAzJw95m6KFBlT8ZCwYA=;
        b=o1mPgSxigbnPVZFiGRNlP5WpNR3gXmJBIRt+NH8CsXYWOXeWMqV+UwePrO6OJPWEMR
         3yxCF32KMWfbPjAe46pi57EuVthScwtlY3thQkCiOwuNlmfHN0RIy7uUAQNYUqeE44ZR
         7N9zK70NrJTx9g4ze6kNIGQE1QCByNkI3hiodJciErL29YG0LHvtxSwuewGaqnpd9AVj
         6i1cJSxjTu5AJOkeRKsrzsx3pIZ1YFhUwms0PK7Mi6xPVzxv44LO9QRWKMtO4TQXHoBA
         owY4vXDP4VNmgBU0R2iWwU7G2dSoKbAq7I25QMaFKol7PjcTxMtrJN7tWSqKpPfh4T32
         q1mg==
X-Gm-Message-State: APjAAAUARPKGu1HFkivKi3dgvu30vLKsHC2lpyvTn6qcCQ8AtDpppsEM
	6CQQLXgg+XN4gaV+2HWeaDaBgMtsaj8ffNSzyboubE6CnuMklWxCV2hbo7YnE7B/y/snCNl/jwS
	Usv82mDs+k2urmthfYxeszk9LjgPUcThAv2a57agz1IhnnsKBd1mh7zRihprRYI5HZhb0Q9AMmk
	gd4+Q9obQQ2BpsX5MSXTiLenKH2EJ9x2vRSHHq9AvrXyAgtn+pxA93YZRmmPhm+irksCd1hBadb
	PuWYNzYaub3IvYo8RDT9Qo9inmaWMGhNDI2AlyMOU5Vx9ipOT4ZoK03K2LQunfv78lAsYbDtBe3
	KWmAjr15wp4XGiZ3aw8R98cweqJEtYFzuVVqOtZpBUBf6Kkq0OuL/2HM9nxfXVkhQssPj/R4R48
	F
X-Received: by 2002:a63:5b43:: with SMTP id l3mr17894314pgm.298.1552070609997;
        Fri, 08 Mar 2019 10:43:29 -0800 (PST)
X-Received: by 2002:a63:5b43:: with SMTP id l3mr17894250pgm.298.1552070608977;
        Fri, 08 Mar 2019 10:43:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552070608; cv=none;
        d=google.com; s=arc-20160816;
        b=xuBPPGpEY2NURIXZFJgG2S2ngj1lQXVNsbO/08YWZd2XF5YW9hNscqJz3IhsLTSj8n
         pbmTcEUpxAd5/176gGkWM3cBsWBnKFknRC0DltzbQVxUUBw/+vFb3uQl5Sn/Z1cgsAI0
         2mSiguUhtqbWVk6tuNQG8WUMwWwRAhAZDlOe/+eT5+mG/z0yshote+8rSQAep4O1grcn
         +JUrQNBq64icRttMi48tw42YINtnBxt7snyG+1AOntuOdTzjNpMUoCqGyl55zXiIHrCd
         cKF1kbxhjpA77FEHPoCd4CuZ5svIvW5AECpO1zz8JUcZNTIqK3xTOhU44F2rsvXZ+8eI
         XliA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OplnuXRZxId0pdfBC75FwRElAzJw95m6KFBlT8ZCwYA=;
        b=tDc/yrzCNDb6cw7VFZjSN4IZmyrV8oafqvhdB9WK4PtoNuEL48oxy5yWzyrYHINcdU
         X48x9psOAMXA6VA72COKge7hVIyVvaKre4bVQOjqnLkGu9GVLCuOD57GdVPDc+LiwHEP
         2CSQFoU9EW9otQlpf60woBopvzrODyI22IuHOKiPbvJqLktXMrNMMthLznkh8g7SZQIL
         bjUZWBXFF5H/P0/3ILWrFjWLS3De+mJjuA5oQOkXDzMFp8EmwzLKGI3u/g5QgzZXZN2Q
         T0ZXmZpJ4qwsZ05x81H8MtKv+LAwCAqn+J3Vsqbr8wl1koDFrxyLBtL6XTbrCjT8VPHC
         Cfsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eLdg3v+n;
       spf=pass (google.com: domain of 30lecxaykcdujlivesxffxcv.tfdczelo-ddbmrtb.fix@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30LeCXAYKCDUjliVeSXffXcV.TfdcZelo-ddbmRTb.fiX@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i35sor13431056plg.40.2019.03.08.10.43.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:43:28 -0800 (PST)
Received-SPF: pass (google.com: domain of 30lecxaykcdujlivesxffxcv.tfdczelo-ddbmrtb.fix@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eLdg3v+n;
       spf=pass (google.com: domain of 30lecxaykcdujlivesxffxcv.tfdczelo-ddbmrtb.fix@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30LeCXAYKCDUjliVeSXffXcV.TfdcZelo-ddbmRTb.fiX@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OplnuXRZxId0pdfBC75FwRElAzJw95m6KFBlT8ZCwYA=;
        b=eLdg3v+nnsix/WEq9cIQXxF6rEMUbk6o+EfOnyMexjGolm48oKpVO/ZfgvFBUMzUQq
         +8vWtIHjH805IaHbtRpGR/K6cynyhI1tTZWOu4AycWFX2cseASldHKW47GOWpa8LeseY
         VeXtviVvtYaVHJuAnbU9eXRYGSrsoV6ozdT0HNj3IblQaTeM66Fd9Wi12o4N/exY0QVS
         6DziP/9QOuU3qVfJHxCJzF72/hSeY+YCyVPbHRPmCih1es7yMeURa5KNV84MCIL1FAtd
         pD7ba1BOE6DEusuV/JPafZp0iS2oMlOBLpfZXHW3PNCyQilkVG4SMnpJt8wT7I9epybu
         +2LQ==
X-Google-Smtp-Source: APXvYqyZSrbIf8B+VZMd4cruZgcwhbXTSNL/bwNkHx2baqHUb4H43f2sWNVaIXkX2++kPQabzgw+hIYX7Ho=
X-Received: by 2002:a17:902:7c93:: with SMTP id y19mr6384585pll.137.1552070608718;
 Fri, 08 Mar 2019 10:43:28 -0800 (PST)
Date: Fri,  8 Mar 2019 10:43:07 -0800
In-Reply-To: <20190308184311.144521-1-surenb@google.com>
Message-Id: <20190308184311.144521-4-surenb@google.com>
Mime-Version: 1.0
References: <20190308184311.144521-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v5 3/7] psi: rename psi fields in preparation for psi trigger addition
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
2.21.0.360.g471c308f928-goog

