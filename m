Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD177C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 23:12:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EEBF20673
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 23:12:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="l+uIMTCI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EEBF20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEEAE8E0005; Mon, 17 Jun 2019 19:12:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9FA48E0001; Mon, 17 Jun 2019 19:12:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B678E8E0005; Mon, 17 Jun 2019 19:12:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 994A28E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 19:12:33 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r40so10769896qtk.0
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:12:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OqXw0t9fRr/azQRpWaonaAmH3L30B0p/Fx4/9IaKmEU=;
        b=ANnljVOC/r/8WpSP2Si+Xo6w5NeR7YMwmt27TAlXr/52SXbwr8vtHtpniyNgK/BLCe
         +aJYoG1l56UcBLsWvg2QlIj/Nm+uXGg8L4Wa//UvY5Fzr6Afk0PDztE6xzQYDGiwJh9O
         rbZjVnjQ8g2JDOGScVpe2BWf4upvxehK8OWlsrhfDDL0au+193Bl4pYAPR6R2d9WZAn3
         3TMc+etvfcdKnXlXmcITMd6Lt+yuc94Pq9CkVorZblS9jRWXEKG3d30tCmftxvVDEQqQ
         DEXuH4m83LRAm6xuXZs/+LwT3Y7zs5JJppmuVHN5UKilQmDyNiVoeqiSHyLicFbz0LhO
         syKA==
X-Gm-Message-State: APjAAAU6LS7lN/GA01NX8ZqLTvunXyEBbcI9HtU94zHHRt4vT3j/+thH
	YefVwmLRLNbzNrUTecA4jfZxcSqqsIQnK/zbkz3YKHy/jXkkUN/k8CjpIEyjBGQy645SCRax7Lm
	Efo0R03fROMT9YRrFPRu9B/ULSACtXhLy/67FwJsucoT4cOahGSkIKFjj1jsUNEkMnA==
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr96570032qtk.67.1560813153383;
        Mon, 17 Jun 2019 16:12:33 -0700 (PDT)
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr96569982qtk.67.1560813152621;
        Mon, 17 Jun 2019 16:12:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560813152; cv=none;
        d=google.com; s=arc-20160816;
        b=eYeumFfixs0zyCZlGR8WHA6jSQVatD1Xn18nCATRB5ZpQQR8dRNzACRyuq1ylRz6/+
         TfbOunDItMDekD/q4/ONyzt8WwEPnoov/BGo2vH9t0I93/WugAbcADwawkZWorVXu24Q
         +5UarXvtRIXF+i9R1RAckkVOr0SuCx05GKw8C/WEyUpjPWLaYmqxxMzkYGhyD/g3FaAk
         dJ9mlmCZEHenNl92QK63Ol4xU7SxmUJ4leBw0pXaheEzeCVd7IH16Lla0+A9h/r1Z5GQ
         97yfGEyUs9mt0jkNhwqBEgNAUdEXAvP2vSlt2UEq6jPKRptc7enK3FKR8BqEQaCJJVRn
         uQ+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OqXw0t9fRr/azQRpWaonaAmH3L30B0p/Fx4/9IaKmEU=;
        b=n4mF2eB7RZNzrFMWPxPVR9C/8arHkF1WV0wzFxYHmIzmi2dyRF+UTDR1RXhBKgl9bm
         /fQWlaHle6IQs9BzlM2MApfdqgWFnCU9N1Bxj4jxYbSg9GyhO+stQwa3pF4qfjtSL6cu
         3BYTOOfGyDBKKJw9zJek9qP2wkOMYNjFc/6NZpJznF0CVYsSbY01vsUdnJgnGW9F6XqU
         tmtTnZw0xdSEo8ua1M1PaQe7qcpOqiARIyRSo5YRWMVOBDXCjRJMy+PviP6s+0PgsIK1
         Sm5z/HuqRWF3SHSH2S85Mk6j3ONo2qJ6NlOeI3FTCRn9hPNojcIuHr98lb/shO/VWz6e
         k6Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l+uIMTCI;
       spf=pass (google.com: domain of 3yb4ixqgkcksdslvppwmrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3YB4IXQgKCKsdSLVPPWMRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t15sor18303653qth.2.2019.06.17.16.12.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 16:12:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3yb4ixqgkcksdslvppwmrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l+uIMTCI;
       spf=pass (google.com: domain of 3yb4ixqgkcksdslvppwmrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3YB4IXQgKCKsdSLVPPWMRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OqXw0t9fRr/azQRpWaonaAmH3L30B0p/Fx4/9IaKmEU=;
        b=l+uIMTCI5npW/nqR+ky6CSGLylxdHVeLxb2jOLCH1qr1XrTumE2XBxgN6ZmUkAXra1
         ntBZBh41tlpF3BBA55+I1PGrd6z4kEdS8Uv82kOLTTVnfUrFHdX7tbZQJyF8UcROls0i
         1c93b9o006nR8CZgd2EWyEyscBDXP8MnS+KB2Ue3lzsyD5dzhYW+nUGofuF/y74syGBs
         PYDHmZSJAzuMLtWDAbG4Af+6ggzwaueNFoqmaDUDXSIi/Z3MtYtfRNflCgo074OpQHfj
         EmRyhNDKDwlw3B3NOKNfeYgQU2FjysANV51nYmq0c4D+tKsQDNTP6PgD7PTxwPFDKxCU
         /p7A==
X-Google-Smtp-Source: APXvYqypIi8nO7ZBX6Y8v6IyGHG5MzrimR5HjvoCIsgCWDQWP5j91s5/qQKuaJpxz7EBH4UYoTFh6kJ18bE4Zw==
X-Received: by 2002:ac8:2b01:: with SMTP id 1mr26419700qtu.177.1560813152241;
 Mon, 17 Jun 2019 16:12:32 -0700 (PDT)
Date: Mon, 17 Jun 2019 16:12:07 -0700
In-Reply-To: <20190617231207.160865-1-shakeelb@google.com>
Message-Id: <20190617231207.160865-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190617231207.160865-1-shakeelb@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2 2/2] mm, oom: fix oom_unkillable_task for memcg OOMs
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently oom_unkillable_task() checks mems_allowed even for memcg OOMs
which does not make sense as memcg OOMs can not be triggered due to
numa constraints. Fixing that.

This commit also removed the bogus usage of oom_unkillable_task() from
oom_badness(). Currently reading /proc/[pid]/oom_score will do a bogus
cpuset_mems_allowed_intersects() check. Removing that.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- Divide the patch into two patches.

 fs/proc/base.c      |  3 +--
 include/linux/oom.h |  1 -
 mm/oom_kill.c       | 28 +++++++++++++++-------------
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index b8d5d100ed4a..57b7a0d75ef5 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -532,8 +532,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
 	unsigned long totalpages = totalram_pages() + total_swap_pages;
 	unsigned long points = 0;
 
-	points = oom_badness(task, NULL, NULL, totalpages) *
-					1000 / totalpages;
+	points = oom_badness(task, totalpages) * 1000 / totalpages;
 	seq_printf(m, "%lu\n", points);
 
 	return 0;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index d07992009265..c696c265f019 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -108,7 +108,6 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 bool __oom_reap_task_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
 
 extern bool out_of_memory(struct oom_control *oc);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bd80997e0969..d779d9da1069 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -152,20 +152,23 @@ static inline bool is_memcg_oom(struct oom_control *oc)
 }
 
 /* return true if the task is not adequate as candidate victim task. */
-static bool oom_unkillable_task(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask)
+static bool oom_unkillable_task(struct task_struct *p, struct oom_control *oc)
 {
 	if (is_global_init(p))
 		return true;
 	if (p->flags & PF_KTHREAD)
 		return true;
 
-	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
+	/*
+	 * For memcg OOM, we reach here through mem_cgroup_scan_tasks(), no
+	 * need to check p's memcg membership and the checks after this
+	 * are irrelevant for memcg OOMs.
+	 */
+	if (is_memcg_oom(oc))
+		return false;
 
 	/* p may not have freeable memory in nodemask */
-	if (!has_intersects_mems_allowed(p, nodemask))
+	if (!has_intersects_mems_allowed(p, oc->nodemask))
 		return true;
 
 	return false;
@@ -201,13 +204,12 @@ static bool is_dump_unreclaim_slabs(void)
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
-			  const nodemask_t *nodemask, unsigned long totalpages)
+unsigned long oom_badness(struct task_struct *p, unsigned long totalpages)
 {
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (is_global_init(p) || p->flags & PF_KTHREAD)
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -318,7 +320,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
+	if (oom_unkillable_task(task, oc))
 		goto next;
 
 	/*
@@ -342,7 +344,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto select;
 	}
 
-	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
+	points = oom_badness(task, oc->totalpages);
 	if (!points || points < oc->chosen_points)
 		goto next;
 
@@ -390,7 +392,7 @@ static int dump_task(struct task_struct *p, void *arg)
 	struct oom_control *oc = arg;
 	struct task_struct *task;
 
-	if (oom_unkillable_task(p, NULL, oc->nodemask))
+	if (oom_unkillable_task(p, oc))
 		return 0;
 
 	task = find_lock_task_mm(p);
@@ -1090,7 +1092,7 @@ bool out_of_memory(struct oom_control *oc)
 	check_panic_on_oom(oc, constraint);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
+	    current->mm && !oom_unkillable_task(current, oc) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
 		oc->chosen = current;
-- 
2.22.0.410.gd8fdbe21b5-goog

