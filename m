Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A02C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB6EB217F5
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Z6b442+6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB6EB217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FE9D6B000A; Tue, 19 Mar 2019 19:56:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B0E96B000C; Tue, 19 Mar 2019 19:56:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBE736B000D; Tue, 19 Mar 2019 19:56:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B54516B000A
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:38 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id i21so653531ywe.15
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=dn6PEiCR+dScVGu5EewnvuQCwpS0GucFANxBNtI0jyg=;
        b=faJJ7Y0Qm8q4Ztw1LgniVeBCPkziMYHM2ZbZma1FhPgx1KKeEHVwvoBeYABPZLyKXt
         yHsXY3GamoJAwPHFyHxmg7wAxBbYhJUtbVJdRETWzC3s4F7Qyvc+2YyNGTDtp0GTmoXo
         Ja6TLVHgVytA93T4ff8kBdwnhPGGlbhQgVGe5pIr4Lx6q5kU42dDoYxZqn1mLfBeo3vc
         K9psVRUOIah81rAYfrNvg2M8zCh6qhM/QQ+giPWR40dM+1kaj3SkEpgf3D0ggGQImjyo
         +0YkUathPbmGvybESsA0N0qh2f72cKlHa9ZAHtK530lCll1cwtlbu9xF0KchLbBZO5RC
         f7ag==
X-Gm-Message-State: APjAAAUdIeBXqtli3frGNZkwYo86gNvBfo+X7cysdo9zORi1mbsugigy
	vi8P397nmvtBO6nOMSj8FF2IwMKEYr1tTnktsoXA+oaatN9DMbRBhsVrOCWtrX+ioaFfmaRyo59
	5Ul4qOAIeunSYXRaFs/4AEyLI4JehX2JkIw/BnzN/y7x+r7tZzee3BbBLUqKV9IS/3g==
X-Received: by 2002:a5b:70f:: with SMTP id g15mr4298312ybq.382.1553039798417;
        Tue, 19 Mar 2019 16:56:38 -0700 (PDT)
X-Received: by 2002:a5b:70f:: with SMTP id g15mr4298290ybq.382.1553039797596;
        Tue, 19 Mar 2019 16:56:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039797; cv=none;
        d=google.com; s=arc-20160816;
        b=bXDJZwS8frApcJ9mIKnaosjflmD2YPPzC83ZFXhmYNa/biI8XO/pVNvQfQcQar8db1
         zVCDa6fVBdg6AVS6T6qwJGh8g/bk5aUqP6ov2uZi77mI6OhrIOml4wp4B0nV3um2Mb8p
         Y2uKozy2+6eBVI34lIPUIoiEWXxtpJckwgFX2f6GuFaTdNS4nHI1N6OxuZQBEmG3CsJC
         R0rngupHlOWp4lXE3g+d/n0BtFI61jaIojCSweNFG8m6hdMZd66o5D3fqtrTlC3znFD4
         cPIKVoIoRGlctBqEZKHp7/dRzSCEG0ceACwcjApkz2fQG5Sb/RAkCl57iY8Fyj+BilkX
         qocA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=dn6PEiCR+dScVGu5EewnvuQCwpS0GucFANxBNtI0jyg=;
        b=dATSj3/EfnqEhi4owONDFk7yYoRXWyLb2DonmSGjKFAojZl+dUrXnkt/6NCmJvXQSS
         RJxk0+2JU+f50IdDhLRXfzrfIxq0pBFsNyTSoRvEl9iPH3ULrPtK5X9XCBkYpKbomYhX
         cjipkoZ9AzA0VBR5ItCvINa0ZSB+sH376O0dh6csJT1eXMmvv99k2AX7NuggNOYB+bdT
         RO+72vYpIavSUOmD2TBOKaoI6M6FotaEZG+wRG1CU8fhV7HImMim7Dy+wKw3Mok6OQdR
         UWtepChJu9kLP88dUtCrYNciDo1xLP6ZIWJWwzxQsQYfqLUIAN1GceLlRZE8eZUzN6qE
         llPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Z6b442+6;
       spf=pass (google.com: domain of 3tygrxaykcogceboxlqyyqvo.mywvsxeh-wwufkmu.ybq@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tYGRXAYKCOgcebOXLQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c83sor118540ybb.66.2019.03.19.16.56.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tygrxaykcogceboxlqyyqvo.mywvsxeh-wwufkmu.ybq@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Z6b442+6;
       spf=pass (google.com: domain of 3tygrxaykcogceboxlqyyqvo.mywvsxeh-wwufkmu.ybq@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tYGRXAYKCOgcebOXLQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=dn6PEiCR+dScVGu5EewnvuQCwpS0GucFANxBNtI0jyg=;
        b=Z6b442+6DNI/wL3Sl+GmBfCDemyRgLchS2XX8vUdUBCLvLTr6SRAXAFrKle3CWKt83
         v/Lyw5vroFag4ZNItRCs1E2AW0rTWPfFeUTPo1GonT4xq3BSGy7UAoDlpLr8wfzd4dEk
         cAQsQM3nDSIJoKigdyekrTeWCnEDlgdImc40cSqjYKkcrN0irpacS5iuUwz+nNKTfCj6
         gN9agbjk3JafwYtdbZcJrSQ9KVE5u5RPfTsRdqFUk6odVENAIbN2URKCX146f8h3tIki
         tQqvJcideceDh5tkn6j7mXS/7dCIydNbwoCEy1XZmg00rksFqoQLHtmFE2PGru24T2ue
         Q36A==
X-Google-Smtp-Source: APXvYqzqRXV9Su0O8ijkHzVc98Uu6jekXyU8mHEz8z0Z4ekoSX8Xd/HdmZXF1XnScGWT74vxfZWql8OgG4g=
X-Received: by 2002:a25:ae96:: with SMTP id b22mr1664495ybj.94.1553039797316;
 Tue, 19 Mar 2019 16:56:37 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:16 -0700
In-Reply-To: <20190319235619.260832-1-surenb@google.com>
Message-Id: <20190319235619.260832-5-surenb@google.com>
Mime-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 4/7] psi: split update_stats into parts
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

Split update_stats into collect_percpu_times and update_averages for
collect_percpu_times to be reused later inside psi monitor.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 kernel/sched/psi.c | 57 +++++++++++++++++++++++++++-------------------
 1 file changed, 34 insertions(+), 23 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 4fb4d9913bc8..ace5ed97b186 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -269,17 +269,13 @@ static void calc_avgs(unsigned long avg[3], int missed_periods,
 	avg[2] = calc_load(avg[2], EXP_300s, pct);
 }
 
-static bool update_stats(struct psi_group *group)
+static bool collect_percpu_times(struct psi_group *group)
 {
 	u64 deltas[NR_PSI_STATES - 1] = { 0, };
-	unsigned long missed_periods = 0;
 	unsigned long nonidle_total = 0;
-	u64 now, expires, period;
 	int cpu;
 	int s;
 
-	mutex_lock(&group->avgs_lock);
-
 	/*
 	 * Collect the per-cpu time buckets and average them into a
 	 * single time sample that is normalized to wallclock time.
@@ -317,11 +313,18 @@ static bool update_stats(struct psi_group *group)
 	for (s = 0; s < NR_PSI_STATES - 1; s++)
 		group->total[s] += div_u64(deltas[s], max(nonidle_total, 1UL));
 
+	return nonidle_total;
+}
+
+static u64 update_averages(struct psi_group *group, u64 now)
+{
+	unsigned long missed_periods = 0;
+	u64 expires, period;
+	u64 avg_next_update;
+	int s;
+
 	/* avgX= */
-	now = sched_clock();
 	expires = group->avg_next_update;
-	if (now < expires)
-		goto out;
 	if (now - expires >= psi_period)
 		missed_periods = div_u64(now - expires, psi_period);
 
@@ -332,7 +335,7 @@ static bool update_stats(struct psi_group *group)
 	 * But the deltas we sample out of the per-cpu buckets above
 	 * are based on the actual time elapsing between clock ticks.
 	 */
-	group->avg_next_update = expires + ((1 + missed_periods) * psi_period);
+	avg_next_update = expires + ((1 + missed_periods) * psi_period);
 	period = now - (group->avg_last_update + (missed_periods * psi_period));
 	group->avg_last_update = now;
 
@@ -362,9 +365,8 @@ static bool update_stats(struct psi_group *group)
 		group->avg_total[s] += sample;
 		calc_avgs(group->avg[s], missed_periods, sample, period);
 	}
-out:
-	mutex_unlock(&group->avgs_lock);
-	return nonidle_total;
+
+	return avg_next_update;
 }
 
 static void psi_avgs_work(struct work_struct *work)
@@ -372,10 +374,16 @@ static void psi_avgs_work(struct work_struct *work)
 	struct delayed_work *dwork;
 	struct psi_group *group;
 	bool nonidle;
+	u64 now;
 
 	dwork = to_delayed_work(work);
 	group = container_of(dwork, struct psi_group, avgs_work);
 
+	mutex_lock(&group->avgs_lock);
+
+	now = sched_clock();
+
+	nonidle = collect_percpu_times(group);
 	/*
 	 * If there is task activity, periodically fold the per-cpu
 	 * times and feed samples into the running averages. If things
@@ -383,19 +391,15 @@ static void psi_avgs_work(struct work_struct *work)
 	 * Once restarted, we'll catch up the running averages in one
 	 * go - see calc_avgs() and missed_periods.
 	 */
-
-	nonidle = update_stats(group);
+	if (now >= group->avg_next_update)
+		group->avg_next_update = update_averages(group, now);
 
 	if (nonidle) {
-		unsigned long delay = 0;
-		u64 now;
-
-		now = sched_clock();
-		if (group->avg_next_update > now)
-			delay = nsecs_to_jiffies(
-					group->avg_next_update - now) + 1;
-		schedule_delayed_work(dwork, delay);
+		schedule_delayed_work(dwork, nsecs_to_jiffies(
+				group->avg_next_update - now) + 1);
 	}
+
+	mutex_unlock(&group->avgs_lock);
 }
 
 static void record_times(struct psi_group_cpu *groupc, int cpu,
@@ -707,11 +711,18 @@ void cgroup_move_task(struct task_struct *task, struct css_set *to)
 int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 {
 	int full;
+	u64 now;
 
 	if (static_branch_likely(&psi_disabled))
 		return -EOPNOTSUPP;
 
-	update_stats(group);
+	/* Update averages before reporting them */
+	mutex_lock(&group->avgs_lock);
+	now = sched_clock();
+	collect_percpu_times(group);
+	if (now >= group->avg_next_update)
+		group->avg_next_update = update_averages(group, now);
+	mutex_unlock(&group->avgs_lock);
 
 	for (full = 0; full < 2 - (res == PSI_CPU); full++) {
 		unsigned long avg[3];
-- 
2.21.0.225.g810b269d1ac-goog

