Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 817D9C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C5602085A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="N2+/GhOQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C5602085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAC2C8E0007; Fri,  8 Mar 2019 13:43:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D836D8E0002; Fri,  8 Mar 2019 13:43:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C24888E0007; Fri,  8 Mar 2019 13:43:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 970788E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:43:33 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z123so16852121qka.20
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:43:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=5zrp8mnWP3uBM/Fizzp8Po+aOUFVr9GhLUoLscT+qvI=;
        b=tFY1let2czH04lJ6HgNavAxYSqW3GtgyEKY8gcBvTWJaa7D2xGKv3Z1x4R1ofQrObn
         OV3OlaXvsCourH0DwlLDkD+h6iOqwXphFtjRImKgbTFkiPgHpacGF0kmH05UnuhRkASW
         qfBa7rz0BWpjqhvbcQ07Hmv7AuInYM5rjjQ1TL9G6HkR6de5USEVe0ukolJXvOvIn2Jh
         OeAw2mU6QifKyfEbzuvzl/6zshUq/6WEu48mGsD3uMSUoJrp2I4s9OUuSPK2sACa6Vpz
         u6FrOsEgY0EMxV4FBSo1jbpmtcsLDw5JTgRo2D4KgSWZQiggG9nuumlKQObknAS2ATsM
         6BeQ==
X-Gm-Message-State: APjAAAUqp411DM8kip1wxwA78t+Sjexaz+9dvYbpNzrIS6a8TUd6IOah
	2edps1oS5QZ9ci1abMkz2CkIRtZWRhPXel0E51z3fU0SeuUh/1527bKesHdkgwTDVzoinSxKU6H
	G9bLKqgOyPwnGaEOBNwy+eYsyindX9Aq97a5Wwdbelxkm+gFO72qylFh/zYtmWY0K6ojfd9iv0x
	+rheltngaUWXoWrE0sg9UoKHr2CjjApj/7typ9AweE+NsKhH5Nh2hBJwxeasG1MEWWcOBu50qNm
	7GaQqlW2R41dfAJsGwoFwTVaR9DhTtaFHIjqmReeoWUZc5lxI7GIOEqw+DUz+zmz/7b0vTbraUh
	lUUHWD1fcW1626DoEKd7gEsMPJ15eetAE021LZSi3Ebism/WczFJ4ikIM1v6FkP49WyMwyBCqZ5
	U
X-Received: by 2002:a0c:e1c9:: with SMTP id v9mr16868057qvl.186.1552070613333;
        Fri, 08 Mar 2019 10:43:33 -0800 (PST)
X-Received: by 2002:a0c:e1c9:: with SMTP id v9mr16868003qvl.186.1552070612566;
        Fri, 08 Mar 2019 10:43:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552070612; cv=none;
        d=google.com; s=arc-20160816;
        b=fo0bfvT/X83yzWpP7vFPklqjkIFG8oquzB0NGR43zWwPlr8S8iVrQ69jwNuYlOfVHZ
         T4gpf4zBH65cGHIyglBCeph++ibYxOXvo6Ajzd3TFnt3k54vvSQFuejMMv11GmwFFQFB
         Y0yu36qH8xO8XWE67r+mTipKRdEM9DvZPBkAcfQc+YrpJKzdR0h6ODlFqh0YIVHN5FJ8
         GPjyhy1b980E0WhxR4rNEbd59PyQjulSq6NfkQCQGVAsDdizScLkOCx5t+Ite42Owe64
         WvAf5/y6Dr1VpPHUP+toTOnJ+DAujWhWHASU7MIrLZNePJu8oW5g4PJH1lSbc2sDrIJN
         oUEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=5zrp8mnWP3uBM/Fizzp8Po+aOUFVr9GhLUoLscT+qvI=;
        b=H9wJTWg99naiGz13FFZVYOCudByqHk8YidTvdX4AdJKqRUNJH++JKDvRPV/7JMvFxK
         RaxXw1j543qygDdfq6+tQi99y8U6aqgjcklKWTudOOVbH2g5V7qw3l+b6SB0mRvVZWoq
         kJdI5Q1plJQWLP7l83V5knkjDGwUke1IpaU1V8STH/yLOd/11G7WtwWrZ7PW1jyvYeBR
         0Pi3jg1mJ5NhechdJbpbns80jK+lEanbz8K/tgkbuGz2dfJIz1no47hGqXFw2/4/Sba/
         bXnEI4cfK1MEN8SWefRomGu96dSB6AlP9cMtkFYaUzgQBU6BSr9grtIpNHyQ7NPblZHP
         Yv/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="N2+/GhOQ";
       spf=pass (google.com: domain of 31lecxaykcdknpmziwbjjbgz.xjhgdips-hhfqvxf.jmb@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=31LeCXAYKCDknpmZiWbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p12sor304053qkg.5.2019.03.08.10.43.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:43:32 -0800 (PST)
Received-SPF: pass (google.com: domain of 31lecxaykcdknpmziwbjjbgz.xjhgdips-hhfqvxf.jmb@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="N2+/GhOQ";
       spf=pass (google.com: domain of 31lecxaykcdknpmziwbjjbgz.xjhgdips-hhfqvxf.jmb@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=31LeCXAYKCDknpmZiWbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=5zrp8mnWP3uBM/Fizzp8Po+aOUFVr9GhLUoLscT+qvI=;
        b=N2+/GhOQIjgVthz+h+5kaB8hfb4yyrZZVmHe16ICqrfbYVc24XX7MCC9FuWksubwVU
         Xyjd64Yr/Z+WlCHwqfmHEv+CiriSFEdGbJ9EhGMGWuc80Qr3DgYdfRRtcofQeNGTEdK6
         3T8qSakvYZgmXfkQbtgGE7jw2pDafLAazJmbRsYkcTi49Se0zeK6UtEa9Ve9E0guUnNS
         wL8US7Ad5FVeD8X6Dbv/kQhn8oAj8KtMLTIjQz2bKZGZyoHB2wqqUQfC1pY0+K6tFI9s
         dUnUhmXIejpHH3UJHFZ6OtQ1mkX12leikIcwcgQhb8msIez1QXxhLaRnmJcOLvQ207By
         Rpow==
X-Google-Smtp-Source: APXvYqyMGccggJ9hSdX5o1VkyMLTNxFEnyQRtZiCw//yBJ/b6Rl0YnlaVKMZGIxvWbcqMUZYihjxrpjsucE=
X-Received: by 2002:a37:ba47:: with SMTP id k68mr11068794qkf.60.1552070612363;
 Fri, 08 Mar 2019 10:43:32 -0800 (PST)
Date: Fri,  8 Mar 2019 10:43:08 -0800
In-Reply-To: <20190308184311.144521-1-surenb@google.com>
Message-Id: <20190308184311.144521-5-surenb@google.com>
Mime-Version: 1.0
References: <20190308184311.144521-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v5 4/7] psi: split update_stats into parts
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
 kernel/sched/psi.c | 55 +++++++++++++++++++++++++++-------------------
 1 file changed, 32 insertions(+), 23 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 4fb4d9913bc8..337a445aefa3 100644
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
@@ -384,18 +392,15 @@ static void psi_avgs_work(struct work_struct *work)
 	 * go - see calc_avgs() and missed_periods.
 	 */
 
-	nonidle = update_stats(group);
-
 	if (nonidle) {
-		unsigned long delay = 0;
-		u64 now;
-
-		now = sched_clock();
-		if (group->avg_next_update > now)
-			delay = nsecs_to_jiffies(
-					group->avg_next_update - now) + 1;
-		schedule_delayed_work(dwork, delay);
+		if (now >= group->avg_next_update)
+			group->avg_next_update = update_averages(group, now);
+
+		schedule_delayed_work(dwork, nsecs_to_jiffies(
+				group->avg_next_update - now) + 1);
 	}
+
+	mutex_unlock(&group->avgs_lock);
 }
 
 static void record_times(struct psi_group_cpu *groupc, int cpu,
@@ -711,7 +716,11 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 	if (static_branch_likely(&psi_disabled))
 		return -EOPNOTSUPP;
 
-	update_stats(group);
+	/* Update averages before reporting them */
+	mutex_lock(&group->avgs_lock);
+	collect_percpu_times(group);
+	update_averages(group, sched_clock());
+	mutex_unlock(&group->avgs_lock);
 
 	for (full = 0; full < 2 - (res == PSI_CPU); full++) {
 		unsigned long avg[3];
-- 
2.21.0.360.g471c308f928-goog

