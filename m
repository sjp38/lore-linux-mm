Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C2DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5971C2183E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Q8ffQgdK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5971C2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 088776B000C; Tue, 19 Mar 2019 19:56:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 038136B000D; Tue, 19 Mar 2019 19:56:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E42726B000E; Tue, 19 Mar 2019 19:56:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5C9B6B000C
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:43 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 23so19215596qkl.16
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/1f+k74gk1272nyZAYvhUzZCD+eEvuFJDJVbOJgy+wk=;
        b=iTqCTR7aV+hUM4woDLn0KOK43ZKLmQF7A3dL21wF5s1MBiiC4Sfl9bH3S8ouNYJcS9
         LoWMxmMKtupMd3QQ9qrtdvmrwIE39hopLJrlT7uZrmBRhEu9meuFAGdk96JI+fBAGbH/
         IqJ2yNZ/kC3b8KJfI2obU3yrZVGE7BxTyUM0mkoEO3OYzgu+w1+KznO8Rum+xpe6ctKg
         4JIS4ZGouJmOvyCHEQ/5TMwcrOfiWuxESBZv4cvVGv0r/Ml3vwiBw69/K0L8WKP2kWFb
         idateBei4mTZrAqPE0PAcmTK99oJtE8tnAA1Qrrc7scVFU4W1W+J3CKHJfSG9tG2YKtO
         39ow==
X-Gm-Message-State: APjAAAW6LTup5Pz3GyKK9My2AYbYy3oVAKCTvCvq9SeR3fIPZ9/RjZXi
	p7LqtM6FraWpD2GrPeKuuMiC6Untx/kvd96HQ6ofsOrH3GFRJaYOJZsmKQQhJZh+ljzATbG3Yjr
	k8cwFGkTTGfvuzar3zR+ehIInC7bc6YlktD2nWBetA7+ZMPFj3QjvHmQiuKbI3wQOeg==
X-Received: by 2002:ae9:f00b:: with SMTP id l11mr4167593qkg.84.1553039803535;
        Tue, 19 Mar 2019 16:56:43 -0700 (PDT)
X-Received: by 2002:ae9:f00b:: with SMTP id l11mr4167466qkg.84.1553039800410;
        Tue, 19 Mar 2019 16:56:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039800; cv=none;
        d=google.com; s=arc-20160816;
        b=qhKnVwgzMoO2x1tueHE4Qlc0/DgeNc9aV67Ic9H61YlpinY7Xrc5fgN9j9/WG9+eRU
         S72JCAfYSC3Fh0uIFlPsmx+Hwr9YnZFzF9yspem7oziW6cKl3AgjpLmQloNbR0MVDvm2
         dDs+Vx418P742CzFqxdaSxemV5colH1PjOnAlB3202qjREOywzAkAZg1oGY9rFzbTuvg
         ITriYsyPYhe5c+1T3qG9NT04Gz+msxiE2nSOvneof7wBP7ICzSp/23vmSuVhTuMvopsT
         Uknxt2WIuUQ372I9cB3gwfjUJtjtZQ0vXlyGKWSxhCU4Gz7MIC49XQAuC46aLWCC9j6t
         B+rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/1f+k74gk1272nyZAYvhUzZCD+eEvuFJDJVbOJgy+wk=;
        b=LgaDSB5aGf5QQQqmvIonrY/fiGk4ssYnsosx1RYcdjhxFRA19eUh4lvPhKs5yERabZ
         Lma24cqDAcs3z5L6M/zHN4krtIIaHRd2Mop8Or3s5LK+KOPcStvFCoiVpv+iOZG+KHnv
         mOulNejnXoyBtjN6Np4qrfw7ggur3LwDA7CNmnR61jYwnRrjpy3bKgRsrJMSEEj83oQo
         VQ26dGXYC1+kfD4P5UHpVLGZ+4lIccYVQnq/CXXVjM7e15EYIQpefHxxTP1fuA1k+ZJW
         TKM4tuxf8A34b2mNXBZ/u2ZeOZPrB2ZEnBgs5h/dGv3olUZjHXIjP2P4ywalOqme6Htf
         tRmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q8ffQgdK;
       spf=pass (google.com: domain of 3uigrxaykcosfheraotbbtyr.pbzyvahk-zzxinpx.bet@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3uIGRXAYKCOsfheRaOTbbTYR.PbZYVahk-ZZXiNPX.beT@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id q11sor850611qtq.28.2019.03.19.16.56.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3uigrxaykcosfheraotbbtyr.pbzyvahk-zzxinpx.bet@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q8ffQgdK;
       spf=pass (google.com: domain of 3uigrxaykcosfheraotbbtyr.pbzyvahk-zzxinpx.bet@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3uIGRXAYKCOsfheRaOTbbTYR.PbZYVahk-ZZXiNPX.beT@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/1f+k74gk1272nyZAYvhUzZCD+eEvuFJDJVbOJgy+wk=;
        b=Q8ffQgdK/wkTC+TdacBpBr7s7ZA+ibEdwudd2fRpPvrcaC/Z4LqJTNqtLCyv8fay3Q
         chiHW354Gbcen71ue0RFArhXaTYhUvFlgw847q/e4JvbmuxVF1URZSS4uI5/2AOq95Tg
         EUZGBIm5ffQd2Ig8HQTcV4Ga4AwlViHgtFeDDiCPhfHDPO06IXDNPK9KlA6EzFdtzCZw
         XIpSvnBo/nnTQIl706MCfwLeDFb6UkMXt7TLQ9AlMLikpSRMRfuJ/IfBREdiXgcI3pzN
         Tqwh1wtk3Mfv6veI944tZm831+Y/Nmg0Yiy3lc4aslJlMD8H+RAAp6Z3buACiQNjY+Pi
         ZHIg==
X-Google-Smtp-Source: APXvYqw+3rmGmXN+0NOE9KYUNNYevZu09CHWRK5dGTsF91CDis8OUSyXsZ9D4hzjIdVioTkn+fpmgfJUK48=
X-Received: by 2002:ac8:1410:: with SMTP id k16mr13547779qtj.58.1553039800238;
 Tue, 19 Mar 2019 16:56:40 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:17 -0700
In-Reply-To: <20190319235619.260832-1-surenb@google.com>
Message-Id: <20190319235619.260832-6-surenb@google.com>
Mime-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 5/7] psi: track changed states
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
index ace5ed97b186..1b99eeffaa25 100644
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
@@ -719,7 +731,7 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 	/* Update averages before reporting them */
 	mutex_lock(&group->avgs_lock);
 	now = sched_clock();
-	collect_percpu_times(group);
+	collect_percpu_times(group, NULL);
 	if (now >= group->avg_next_update)
 		group->avg_next_update = update_averages(group, now);
 	mutex_unlock(&group->avgs_lock);
-- 
2.21.0.225.g810b269d1ac-goog

