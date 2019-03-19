Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 471ABC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA6802175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="s39qkpCi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA6802175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82DE96B0006; Tue, 19 Mar 2019 19:56:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B1DE6B0007; Tue, 19 Mar 2019 19:56:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67DCE6B0008; Tue, 19 Mar 2019 19:56:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2F96B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:31 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id k5so401947ioh.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=BhrmowS2eMjbffJ9OB92bQfOOAToNjJ94P17cQjPdo8=;
        b=czxUHut575MMexrNKiIeeh4GmekW+TCcs+0lYsvy6rHCRx/qSjlzcjprund7iz82y7
         7jaTtfbfXTsXPhgv0mKKRxnvuKeftkrSPXHjmlZ3RHtrombdVVcmnOTwSv3/7vyGvi0w
         WD1HATaEZYLEutiORYo5I1pnRcrxi16ZYaSXmdjrG36ynhAiE+SUB+eZRtImXL2VTg+b
         vgdfY/4clhFp0U7UfMk1nqWiIItbRi+Ieq0nCOkmaOBFfZregqqWdrFljc0DYq8mvGtI
         6tezs1aZT9iXKi/2OYM7/UvAFIv3mxIxaMB9JRvXLKRufHjZAXBa+3ni3QZ0LHBVGY4G
         T9tg==
X-Gm-Message-State: APjAAAX1dXIxL24YmCeyMGLgry2rEPD4CUyo8zzHUPu3CVPeuu3/tdu6
	U4AuuaNGGb608t6GeDgyDcmBI5a7pJczcRtOcgV6Pr5ppxqOMtich5XSOlY2G4DtroXOVoHVMMe
	BMa8Nlr3GWZr1cVGxISEVnJwYwFFMa9hnr1kU/izSj9VgXcZmugZX7T8k4WEOYHLR2g==
X-Received: by 2002:a02:94a1:: with SMTP id x30mr3159488jah.82.1553039790933;
        Tue, 19 Mar 2019 16:56:30 -0700 (PDT)
X-Received: by 2002:a02:94a1:: with SMTP id x30mr3159468jah.82.1553039789979;
        Tue, 19 Mar 2019 16:56:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039789; cv=none;
        d=google.com; s=arc-20160816;
        b=KFp/ntYGp+PAHSJW4gh4pJchtxSUSsn6aieb4XyxMC2PhPyC+yufZNES1f3d1+J1jl
         Xeu5OKBGanNf1J0/j5SfH8vIbWk6usEw1DDx90U79YoLhj5GejU8lNqRG7caqzR4XURm
         YQVmEPzfGUXqC3qvMYUdabnjdY9RMwqItga7SPa+u/TGy7Lh8f/swB14EhhakkxiOQtk
         XzSRiNk5BhSt1aaVXRdIsTiFoOZJH7S0WAQht214TBQuJ3WWQI/lLSf6fCow0j6X+0C9
         Y/+zxwCQOZTdRURtm1ZpuPFZud8t7uhCp6EIy61SNI3SpDwVq78EzKWW1xvHSvndpi6+
         p1kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=BhrmowS2eMjbffJ9OB92bQfOOAToNjJ94P17cQjPdo8=;
        b=JZxX/nZUkhFl6IOrRw/GAbTK7RLAPn7DD5vnZsOl0tvC8bJw8WSPzbZw0bGCzZi82w
         aSNzHOBqnbovO4IS3SJb2lkxzB8+fs+i94iYvdFTTuNPPWBG9mG6GqmUqd6qPMoqj3s6
         DywWCfyyZTCqQ6OvmP/D2RsB0kCF1r1sBm1RKXliIcIfWkrSmoxZmoCUFKEg4Ib4s6ce
         Lm0hOL+ePOXKqa4jaohx+KilFTbtUg1Bn39M4AAevffLZA5pM8wllIDKoUR+CivyL1rP
         lwftgN3Tbmt85yvh9IJNTl6ebt7d9fmi+KcxUQ8OBS3dHT54Mz5RMWgU2oOSRwn/oKN+
         QDnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=s39qkpCi;
       spf=pass (google.com: domain of 3rygrxaykcoauwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3rYGRXAYKCOAUWTGPDIQQING.EQONKPWZ-OOMXCEM.QTI@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w194sor590197ita.22.2019.03.19.16.56.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3rygrxaykcoauwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=s39qkpCi;
       spf=pass (google.com: domain of 3rygrxaykcoauwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3rYGRXAYKCOAUWTGPDIQQING.EQONKPWZ-OOMXCEM.QTI@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=BhrmowS2eMjbffJ9OB92bQfOOAToNjJ94P17cQjPdo8=;
        b=s39qkpCiLoow4b9/kgH0brUOsB6xmuRjJsD/eb1HqzNYh9jtmiyICnlIREYYOCKL88
         kXqqEiT1p592C2CJ41x570vo4IJQ+qIpXP1mS4NZTtgimX1bxdcuhLtuhXWjoT7rB8Dn
         cCHD7VVysNVpuZas/uyx34+spsa3iuS9UElEGU+wOJpvGuxLM1+50lBJdu72gwMh/7wj
         CCzhl3Pdf2CzqMNOj5pObXsCmj1nUNiS+EioFVGTxI0M1+2nuPhekgCPfSV6zecvX9yc
         rPXVPjJj0/fg2QH1UnaNfhmCPCuO7XIQEvbgcqFXz50DTetnIuZxNs6cQ/pmXD0+ZpAY
         nC8Q==
X-Google-Smtp-Source: APXvYqwLqcno9l8VDu4DML9YRADDsLxnjwNMeFZHijkxLWCWDs6v5BpwRuxZ0pdSzUMSpS6IEHp6v20vj2U=
X-Received: by 2002:a24:6545:: with SMTP id u66mr3145504itb.36.1553039789710;
 Tue, 19 Mar 2019 16:56:29 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:13 -0700
In-Reply-To: <20190319235619.260832-1-surenb@google.com>
Message-Id: <20190319235619.260832-2-surenb@google.com>
Mime-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 1/7] psi: introduce state_mask to represent stalled psi states
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The psi monitoring patches will need to determine the same states as
record_times().  To avoid calculating them twice, maintain a state mask
that can be consulted cheaply.  Do this in a separate patch to keep the
churn in the main feature patch at a minimum.

This adds 4-byte state_mask member into psi_group_cpu struct which results
in its first cacheline-aligned part becoming 52 bytes long.  Add explicit
values to enumeration element counters that affect psi_group_cpu struct
size.

Link: http://lkml.kernel.org/r/20190124211518.244221-4-surenb@google.com
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/psi_types.h |  9 ++++++---
 kernel/sched/psi.c        | 29 +++++++++++++++++++----------
 2 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 2cf422db5d18..762c6bb16f3c 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -11,7 +11,7 @@ enum psi_task_count {
 	NR_IOWAIT,
 	NR_MEMSTALL,
 	NR_RUNNING,
-	NR_PSI_TASK_COUNTS,
+	NR_PSI_TASK_COUNTS = 3,
 };
 
 /* Task state bitmasks */
@@ -24,7 +24,7 @@ enum psi_res {
 	PSI_IO,
 	PSI_MEM,
 	PSI_CPU,
-	NR_PSI_RESOURCES,
+	NR_PSI_RESOURCES = 3,
 };
 
 /*
@@ -41,7 +41,7 @@ enum psi_states {
 	PSI_CPU_SOME,
 	/* Only per-CPU, to weigh the CPU in the global average: */
 	PSI_NONIDLE,
-	NR_PSI_STATES,
+	NR_PSI_STATES = 6,
 };
 
 struct psi_group_cpu {
@@ -53,6 +53,9 @@ struct psi_group_cpu {
 	/* States of the tasks belonging to this group */
 	unsigned int tasks[NR_PSI_TASK_COUNTS];
 
+	/* Aggregate pressure state derived from the tasks */
+	u32 state_mask;
+
 	/* Period time sampling buckets for each state of interest (ns) */
 	u32 times[NR_PSI_STATES];
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 0e97ca9306ef..22c1505ad290 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -213,17 +213,17 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
 static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 {
 	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
-	unsigned int tasks[NR_PSI_TASK_COUNTS];
 	u64 now, state_start;
+	enum psi_states s;
 	unsigned int seq;
-	int s;
+	u32 state_mask;
 
 	/* Snapshot a coherent view of the CPU state */
 	do {
 		seq = read_seqcount_begin(&groupc->seq);
 		now = cpu_clock(cpu);
 		memcpy(times, groupc->times, sizeof(groupc->times));
-		memcpy(tasks, groupc->tasks, sizeof(groupc->tasks));
+		state_mask = groupc->state_mask;
 		state_start = groupc->state_start;
 	} while (read_seqcount_retry(&groupc->seq, seq));
 
@@ -239,7 +239,7 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 		 * (u32) and our reported pressure close to what's
 		 * actually happening.
 		 */
-		if (test_state(tasks, s))
+		if (state_mask & (1 << s))
 			times[s] += now - state_start;
 
 		delta = times[s] - groupc->times_prev[s];
@@ -407,15 +407,15 @@ static void record_times(struct psi_group_cpu *groupc, int cpu,
 	delta = now - groupc->state_start;
 	groupc->state_start = now;
 
-	if (test_state(groupc->tasks, PSI_IO_SOME)) {
+	if (groupc->state_mask & (1 << PSI_IO_SOME)) {
 		groupc->times[PSI_IO_SOME] += delta;
-		if (test_state(groupc->tasks, PSI_IO_FULL))
+		if (groupc->state_mask & (1 << PSI_IO_FULL))
 			groupc->times[PSI_IO_FULL] += delta;
 	}
 
-	if (test_state(groupc->tasks, PSI_MEM_SOME)) {
+	if (groupc->state_mask & (1 << PSI_MEM_SOME)) {
 		groupc->times[PSI_MEM_SOME] += delta;
-		if (test_state(groupc->tasks, PSI_MEM_FULL))
+		if (groupc->state_mask & (1 << PSI_MEM_FULL))
 			groupc->times[PSI_MEM_FULL] += delta;
 		else if (memstall_tick) {
 			u32 sample;
@@ -436,10 +436,10 @@ static void record_times(struct psi_group_cpu *groupc, int cpu,
 		}
 	}
 
-	if (test_state(groupc->tasks, PSI_CPU_SOME))
+	if (groupc->state_mask & (1 << PSI_CPU_SOME))
 		groupc->times[PSI_CPU_SOME] += delta;
 
-	if (test_state(groupc->tasks, PSI_NONIDLE))
+	if (groupc->state_mask & (1 << PSI_NONIDLE))
 		groupc->times[PSI_NONIDLE] += delta;
 }
 
@@ -448,6 +448,8 @@ static void psi_group_change(struct psi_group *group, int cpu,
 {
 	struct psi_group_cpu *groupc;
 	unsigned int t, m;
+	enum psi_states s;
+	u32 state_mask = 0;
 
 	groupc = per_cpu_ptr(group->pcpu, cpu);
 
@@ -480,6 +482,13 @@ static void psi_group_change(struct psi_group *group, int cpu,
 		if (set & (1 << t))
 			groupc->tasks[t]++;
 
+	/* Calculate state mask representing active states */
+	for (s = 0; s < NR_PSI_STATES; s++) {
+		if (test_state(groupc->tasks, s))
+			state_mask |= (1 << s);
+	}
+	groupc->state_mask = state_mask;
+
 	write_seqcount_end(&groupc->seq);
 }
 
-- 
2.21.0.225.g810b269d1ac-goog

