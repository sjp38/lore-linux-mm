Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CB27C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3313120857
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tjwDUtio"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3313120857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C99718E0008; Fri,  8 Mar 2019 13:43:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C71CE8E0002; Fri,  8 Mar 2019 13:43:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87998E0008; Fri,  8 Mar 2019 13:43:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92AC78E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:43:37 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id j18so12436778itl.6
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:43:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=il6G9EezI/fMlmphYMEu+28c9gYVmi2vxGNvZesouDw=;
        b=ja1mrYJ2kDl71UWxnE0vveE4BpeD6nq4DUcYGy0M2o+AkRrHXc0OZOAo2Ickxhu64G
         khLsXqLH68S+QAi2Jsm/5plkG6r7aJZ9YIdvZAUqV/C6lEGtWVEahpjUHTLOoJOBo9sf
         IpEKgic2thySCwIGrDm6yv0VKdJ2plbgs+SXyQ1PjmLeBeVz0S85BNZ7RJ02065ENX3a
         d53OJB5gI/Ifi/tQSvD71ayZzh3pPGAy9m3C815r6nGz72m/c7a7bTtZ7ak80BPxpDCL
         O0dYDJhbJY1Pdfs7pr3N+thDn/RrpwFKBkVzQtNvYJkaZ/WNbsGFesLpYIwTgM2tTC/h
         GMZA==
X-Gm-Message-State: APjAAAVKrrk0/1F38DFY72zwyfz33MYxy/nOcLKR8G0NZctKmf0G6cJx
	cHuDVhsiLS3zgubPoXHikOB86mper164HIa7oyNiyUQhfwUIDDTLvOp9dlcw78mrRQo3IySjGpL
	TNTrrbqXSXjVB7byZLh69QCEyvM7mgBPMTX1qQQR8TW0EDpxzZSYUgmeh7NoswyWPlt1UG7X1xT
	o5AeJ1BB+/MFbht0tj8DLvyzURHCsN1Jf+5En2Py/gqEKoMKW8ON+Sz5ybd0MmYV1PKYrJQwYBn
	nCae5BeN738JKaYBy2JWoJsVc3vkMxC0qVZWkqd73FhsF3VNPEcPvHs45sIeLh7jUJ7GONVs6/B
	OB7tdTmx8NZLOD6UE2e60hAoLXbjdzdMSw228he1mCva47V/S8zGYWDGgqlXPdoabMiuDAUBysm
	R
X-Received: by 2002:a02:c513:: with SMTP id s19mr4291316jam.107.1552070617258;
        Fri, 08 Mar 2019 10:43:37 -0800 (PST)
X-Received: by 2002:a02:c513:: with SMTP id s19mr4291282jam.107.1552070616303;
        Fri, 08 Mar 2019 10:43:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552070616; cv=none;
        d=google.com; s=arc-20160816;
        b=fnhJvmhwyc+kX5MSU9tusyHclhvWfxMYnq/FIRa8xeQaTKDshAZC6J/7i3p0prmq5F
         FTUGCk3psv1eUUxKycY1rilflfkicG9v34HStwSEIJJp1lFGSxyxJDv6VMR1c2D6HfIa
         cgKup4kxdKneJHbs5no9/tgciVLOeOQ2fKgcdCzQVJB37VG49h+axKvaKnkovHb34yeI
         cW7mC6KLzrP3Y7p7KHfUaU4UXVQrnLCBUzJI6WeMBs1MXe1eX4JK6BO4Pd+hriu4GPma
         pog40e/LcglXBSxC5Llmd7CXATZPj1+01gJkTjWsL1niLOd4Xy5IYnNKrPdoQJuWTHjk
         W41w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=il6G9EezI/fMlmphYMEu+28c9gYVmi2vxGNvZesouDw=;
        b=KI/oqfcMSgNvqbKg1R+25WRoitNI7qSUaNpH8EJNtWpswsXAwtsuqDMO53SZX+tvDr
         pBYgoTbn6NTryaa7cdXEaDKVBwoND0FvN34wft5PIImQJvFH5O4WIEdySO+hGndQ6jlN
         kcqa8Z+KXuwQrVY0NvLYv+EHeqCRB1T/peZB/XCTs01QAH9WU2p9kfUbT0GAyxAN5cZe
         tN4dn1cJN+WlbB/Y/qMwST2hl5pn3y5FPWOKsNtVMt3dB4riU3hJXblAYvVCraXBQ4Xy
         +4038howmQT6eCDgIoBTYw9s11+KgyFhHOSXsoKib1C7E+chqracECasYr5VeuY8A/+t
         hrFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tjwDUtio;
       spf=pass (google.com: domain of 317ecxaykcdwqspclzemmejc.amkjglsv-kkityai.mpe@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=317eCXAYKCDwqspclZemmejc.amkjglsv-kkitYai.mpe@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o3sor16306721itb.28.2019.03.08.10.43.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:43:36 -0800 (PST)
Received-SPF: pass (google.com: domain of 317ecxaykcdwqspclzemmejc.amkjglsv-kkityai.mpe@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tjwDUtio;
       spf=pass (google.com: domain of 317ecxaykcdwqspclzemmejc.amkjglsv-kkityai.mpe@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=317eCXAYKCDwqspclZemmejc.amkjglsv-kkitYai.mpe@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=il6G9EezI/fMlmphYMEu+28c9gYVmi2vxGNvZesouDw=;
        b=tjwDUtiobdfgKZIH++c88OYAAvRoSWJh7qHVhtehwxLEwOeHNDrMa9pD/txBuYov3w
         tpzrN9TjmUTADYocTrzDBUrTEzZMD5HxdOt2a9GMDUUyolNa+9tkNacxhzz4BzCGherl
         syRewsKwbdO+CjBTIM8eUiUdE6wz2kpm1eSAGLgIQgktEKLIThfLDv6pApzc1QI2qg2G
         klbVSbS32HsJq1EW8loyLsAGIsXoVyECiiHpJGdzMYVVZC+CFimkx6LQx5a+oPhpNKl8
         ig2xUUTSab4ro2ljYGE9dES4jtTPH+8mmUAJ60foFbGMnp0WadQ2fjLC/SzkO0K98Oj8
         DU1A==
X-Google-Smtp-Source: APXvYqwAwnYg5Nbq9SYI8Wv0WjT9si/BIA8kk9ROhAlWPiuYfhb0+1JdnfcDScdeun/zmwtuySgxLkrNte8=
X-Received: by 2002:a24:6cd5:: with SMTP id w204mr13988014itb.16.1552070615991;
 Fri, 08 Mar 2019 10:43:35 -0800 (PST)
Date: Fri,  8 Mar 2019 10:43:09 -0800
In-Reply-To: <20190308184311.144521-1-surenb@google.com>
Message-Id: <20190308184311.144521-6-surenb@google.com>
Mime-Version: 1.0
References: <20190308184311.144521-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v5 5/7] psi: track changed states
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

Introduce changed_states parameter into collect_percpu_times to track
the states changed since the last update.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 kernel/sched/psi.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 337a445aefa3..59e4e1f8bc02 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -210,7 +210,8 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
 	}
 }
 
-static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
+static void get_recent_times(struct psi_group *group, int cpu, u32 *times,
+			     u32 *pchanged_states)
 {
 	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
 	u64 now, state_start;
@@ -218,6 +219,8 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 	unsigned int seq;
 	u32 state_mask;
 
+	*pchanged_states = 0;
+
 	/* Snapshot a coherent view of the CPU state */
 	do {
 		seq = read_seqcount_begin(&groupc->seq);
@@ -246,6 +249,8 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 		groupc->times_prev[s] = times[s];
 
 		times[s] = delta;
+		if (delta)
+			*pchanged_states |= (1 << s);
 	}
 }
 
@@ -269,10 +274,11 @@ static void calc_avgs(unsigned long avg[3], int missed_periods,
 	avg[2] = calc_load(avg[2], EXP_300s, pct);
 }
 
-static bool collect_percpu_times(struct psi_group *group)
+static void collect_percpu_times(struct psi_group *group, u32 *pchanged_states)
 {
 	u64 deltas[NR_PSI_STATES - 1] = { 0, };
 	unsigned long nonidle_total = 0;
+	u32 changed_states = 0;
 	int cpu;
 	int s;
 
@@ -287,8 +293,11 @@ static bool collect_percpu_times(struct psi_group *group)
 	for_each_possible_cpu(cpu) {
 		u32 times[NR_PSI_STATES];
 		u32 nonidle;
+		u32 cpu_changed_states;
 
-		get_recent_times(group, cpu, times);
+		get_recent_times(group, cpu, times,
+				&cpu_changed_states);
+		changed_states |= cpu_changed_states;
 
 		nonidle = nsecs_to_jiffies(times[PSI_NONIDLE]);
 		nonidle_total += nonidle;
@@ -313,7 +322,8 @@ static bool collect_percpu_times(struct psi_group *group)
 	for (s = 0; s < NR_PSI_STATES - 1; s++)
 		group->total[s] += div_u64(deltas[s], max(nonidle_total, 1UL));
 
-	return nonidle_total;
+	if (pchanged_states)
+		*pchanged_states = changed_states;
 }
 
 static u64 update_averages(struct psi_group *group, u64 now)
@@ -373,6 +383,7 @@ static void psi_avgs_work(struct work_struct *work)
 {
 	struct delayed_work *dwork;
 	struct psi_group *group;
+	u32 changed_states;
 	bool nonidle;
 	u64 now;
 
@@ -383,7 +394,8 @@ static void psi_avgs_work(struct work_struct *work)
 
 	now = sched_clock();
 
-	nonidle = collect_percpu_times(group);
+	collect_percpu_times(group, &changed_states);
+	nonidle = changed_states & (1 << PSI_NONIDLE);
 	/*
 	 * If there is task activity, periodically fold the per-cpu
 	 * times and feed samples into the running averages. If things
@@ -718,7 +730,7 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 
 	/* Update averages before reporting them */
 	mutex_lock(&group->avgs_lock);
-	collect_percpu_times(group);
+	collect_percpu_times(group, NULL);
 	update_averages(group, sched_clock());
 	mutex_unlock(&group->avgs_lock);
 
-- 
2.21.0.360.g471c308f928-goog

