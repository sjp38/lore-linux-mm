Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEB37C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7147B20663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:26:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fCpgEkM3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7147B20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2AAC6B0007; Mon, 24 Jun 2019 17:26:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDBFD8E0003; Mon, 24 Jun 2019 17:26:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA3338E0002; Mon, 24 Jun 2019 17:26:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84D126B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:26:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h15so10358529pfn.3
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:26:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=QuhQR2g5/6NgmqGFuivV/bpabSOVZ9f1VzuLjz/nCSs=;
        b=Y0PD7IVzjrZkSUS/N4odZ0GfJ7HptMNq8C07SeDb1E43WVwGjbFiQxIOGxKOH6VFWE
         k5JoZssRU/jXrWpLk2j5bwbgNZAPe9o6Tp7CUeo6keNcAk3RcEindluSnGaWDqe0uyID
         0cZRQbkJYHsDDD4aLX10UvUgM7Mg2rzpn5lescN46bgnojiZ3noyxpT8wTTSWUBlLnNK
         uqP4JQWK2/PFnB0CajDv4sUzlZFPBC+b30/kxwZ8F9kssMnLF/9nyv/0w3Rnk3zt4Akl
         X6EEAd/FpKHrbUcD7WFR32ZazGk1rgR1bmJ5E9I5B0iFenVZkc9N5U6l5uMF/vTY3NK4
         iZhQ==
X-Gm-Message-State: APjAAAVd3w1NPYyUrWz3CPTFwXXDSpyud184+7kmjIS4IIi5WqDg2W3h
	hETAoIHWP9UfTe8cJvLjTT0s9hS88vO68VaFnIrc2q5BvQF2f9bO10k1Zt3tDrAFyUUL9kvOwpf
	T4ybKEvhd722UFWubyqbV4/YQUaiKnda1Jlpp2Qz2dWs6ufxyOLAZJiE8DpihLeU4iA==
X-Received: by 2002:a17:90a:cf0d:: with SMTP id h13mr27178774pju.63.1561411612023;
        Mon, 24 Jun 2019 14:26:52 -0700 (PDT)
X-Received: by 2002:a17:90a:cf0d:: with SMTP id h13mr27178684pju.63.1561411610978;
        Mon, 24 Jun 2019 14:26:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561411610; cv=none;
        d=google.com; s=arc-20160816;
        b=J+/sh6BBA8wbJkXuBG0rxiIbfGMr5Q5QtCqOnOWkUnvAwX090b8L0S1K2HX+It3tm+
         eijD/gXYwxYf8RTXRI83BORRlYoTouRQD9QDrA0il3Jx+voAS2wAiz/yF2/GcLsb8AxL
         1dhFMRYLVNM5m0XNbJYkfmDGlw+BLj1A759SNPh4gT2syzRvdoxJ1fUnO7IkDUCAn1EZ
         16uBOy6OUq9BM0B70OHfRGEni0HUISZYneXbygbmw7bkKhO3BKaWGT1sNUbHLe4CwXFQ
         VHrDIOFbjpSKwF1oKO6xM38vsP61z6uWmobJAeuSRrNzZVN9Ib+oH7N2XS6HNvfA82vX
         87ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=QuhQR2g5/6NgmqGFuivV/bpabSOVZ9f1VzuLjz/nCSs=;
        b=Z+XzvYYLorbuwJoh0iAhvciceDEQ92MqJ9yUZkqweh5doC54Uz4XjpcdatRW5KDFN5
         nfzfDWvS0/Fel7k19kPWXW/XC/3k48IWv8kLp8xAjI254Qh9xlDhib13kIqt1WKEITyT
         cEqmrASdFBQ3H1wbj3uFooYMRddCHyCVDKCax2eq7AAGLRLL+hTOy26/5ivdrHhIEJUA
         k1VG40jp4/poJNWHv2XEiVV6zps+ZLkLQ4jXT2y9GYeJ3T8pHDDEXDNGi3ic1Tfz9UKE
         SaUI5qDePf+/oaRZ7b8SBc7NkRWl+I7Iol+KLgFmTMBZqs1/U6Na8apqDmqcq3LFSMMr
         qnrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fCpgEkM3;
       spf=pass (google.com: domain of 3gkarxqgkcm0b0t3xx4uz77z4x.v75416dg-553etv3.7az@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3GkARXQgKCM0B0t3xx4uz77z4x.v75416DG-553Etv3.7Az@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a3sor7807372pfc.33.2019.06.24.14.26.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:26:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3gkarxqgkcm0b0t3xx4uz77z4x.v75416dg-553etv3.7az@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fCpgEkM3;
       spf=pass (google.com: domain of 3gkarxqgkcm0b0t3xx4uz77z4x.v75416dg-553etv3.7az@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3GkARXQgKCM0B0t3xx4uz77z4x.v75416DG-553Etv3.7Az@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=QuhQR2g5/6NgmqGFuivV/bpabSOVZ9f1VzuLjz/nCSs=;
        b=fCpgEkM3oU/q6tGjPXFgGeBjEu3hVd9yUvzw1RQH/0g25b6Jh+izus//6Javr+fxFc
         HH3rWllH1qzQxTgR+uHyVLDW9+cBU2XiQWne19jdSqEFYsuGN8N6hWC2lvovRusHjFPE
         wOHZB62oPVqhJ9vqAq/XIzj5rSF0X8WKlUCxK9TJtmCa/M1EUosulXBohIJZ5jLhOdY1
         h8BIR+9sdQhMyh/BkBVU8vmep7CExj0cBDdxuKwkUdAL/uvVGbi5K1xqsja0TmlJ+1ia
         lsKhi4mrjMbKSfw9mgRUaLGeY9+RY5b7ciQDh312AiL6TloQaBuIZobxBEM8VNlJd5vn
         PPSQ==
X-Google-Smtp-Source: APXvYqz5a7SZDemOpTEhQLNyJry7dI+Y4LMqToKE27cqw3yUALC3EexEf36v0Lyn6dcmeZbhLipgWCztywg1PA==
X-Received: by 2002:a63:296:: with SMTP id 144mr35516171pgc.141.1561411610100;
 Mon, 24 Jun 2019 14:26:50 -0700 (PDT)
Date: Mon, 24 Jun 2019 14:26:29 -0700
Message-Id: <20190624212631.87212-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 1/3] mm, oom: refactor dump_tasks for memcg OOMs
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, 
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, 
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Paul Jackson <pj@sgi.com>, 
	Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

dump_tasks() traverses all the existing processes even for the memcg OOM
context which is not only unnecessary but also wasteful. This imposes
a long RCU critical section even from a contained context which can be
quite disruptive.

Change dump_tasks() to be aligned with select_bad_process and use
mem_cgroup_scan_tasks to selectively traverse only processes of the
target memcg hierarchy during memcg OOM.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>

---
Changelog since v2:
- Updated the commit message.

Changelog since v1:
- Divide the patch into two patches.

 mm/oom_kill.c | 68 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 40 insertions(+), 28 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 05aaa1a5920b..bd80997e0969 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -385,10 +385,38 @@ static void select_bad_process(struct oom_control *oc)
 	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
 }
 
+static int dump_task(struct task_struct *p, void *arg)
+{
+	struct oom_control *oc = arg;
+	struct task_struct *task;
+
+	if (oom_unkillable_task(p, NULL, oc->nodemask))
+		return 0;
+
+	task = find_lock_task_mm(p);
+	if (!task) {
+		/*
+		 * This is a kthread or all of p's threads have already
+		 * detached their mm's.  There's no need to report
+		 * them; they can't be oom killed anyway.
+		 */
+		return 0;
+	}
+
+	pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
+		task->pid, from_kuid(&init_user_ns, task_uid(task)),
+		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
+		mm_pgtables_bytes(task->mm),
+		get_mm_counter(task->mm, MM_SWAPENTS),
+		task->signal->oom_score_adj, task->comm);
+	task_unlock(task);
+
+	return 0;
+}
+
 /**
  * dump_tasks - dump current memory state of all system tasks
- * @memcg: current's memory controller, if constrained
- * @nodemask: nodemask passed to page allocator for mempolicy ooms
+ * @oc: pointer to struct oom_control
  *
  * Dumps the current memory state of all eligible tasks.  Tasks not in the same
  * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
@@ -396,37 +424,21 @@ static void select_bad_process(struct oom_control *oc)
  * State information includes task's pid, uid, tgid, vm size, rss,
  * pgtables_bytes, swapents, oom_score_adj value, and name.
  */
-static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+static void dump_tasks(struct oom_control *oc)
 {
-	struct task_struct *p;
-	struct task_struct *task;
-
 	pr_info("Tasks state (memory values in pages):\n");
 	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
-	rcu_read_lock();
-	for_each_process(p) {
-		if (oom_unkillable_task(p, memcg, nodemask))
-			continue;
 
-		task = find_lock_task_mm(p);
-		if (!task) {
-			/*
-			 * This is a kthread or all of p's threads have already
-			 * detached their mm's.  There's no need to report
-			 * them; they can't be oom killed anyway.
-			 */
-			continue;
-		}
+	if (is_memcg_oom(oc))
+		mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
+	else {
+		struct task_struct *p;
 
-		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
-			task->pid, from_kuid(&init_user_ns, task_uid(task)),
-			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			mm_pgtables_bytes(task->mm),
-			get_mm_counter(task->mm, MM_SWAPENTS),
-			task->signal->oom_score_adj, task->comm);
-		task_unlock(task);
+		rcu_read_lock();
+		for_each_process(p)
+			dump_task(p, oc);
+		rcu_read_unlock();
 	}
-	rcu_read_unlock();
 }
 
 static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
@@ -458,7 +470,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 			dump_unreclaimable_slab();
 	}
 	if (sysctl_oom_dump_tasks)
-		dump_tasks(oc->memcg, oc->nodemask);
+		dump_tasks(oc);
 	if (p)
 		dump_oom_summary(oc, p);
 }
-- 
2.22.0.410.gd8fdbe21b5-goog

