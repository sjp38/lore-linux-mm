Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71F2CC31681
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 18:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 327252085A
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 18:51:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fYw2FSTi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 327252085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C146B8E0003; Mon, 21 Jan 2019 13:51:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC3378E0001; Mon, 21 Jan 2019 13:51:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8E18E0003; Mon, 21 Jan 2019 13:51:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 665088E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:51:19 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b24so13659199pls.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:51:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=ttDeZKtDPkc6RYeRn0bjQXMJKzEwH+kUuuC5XU8aTs8=;
        b=OwIDznOxYZ7cXBX3x/CYS681sd1SarkZJYzNxwywna8qF6XL3sH0Gix/6hNESpUZcz
         bndNTGfau0QNzcHvQhfquFUUTQu+mQrca/tAGmd4WZrd40Ovcn5o43jl3JlQxIfCC54B
         dLMZiFTlZrT4MjF6cj2dQJHP4nbRS1De/Du7k53n5UDR0Z+mKLgvsS0ZUGi8QoGz+rEK
         FHZzfxGV3+/rs1VTMpvz/r2A/j4IGVgWXFYpCkP46jv5BLH5p/2FVyqf0yHsr5oG6fvk
         aPspo0E9S4GUuO5twJxWKR6yPLwj0hc3lO3gXz9bigCt0C4OoCEUYl14cxkHVNHf4uFM
         gEyA==
X-Gm-Message-State: AJcUukc40KEJZzOV2Q8rdkOxdjI1H+KEQ6EvWuLGeNvQODFZyYan9ahI
	9Nu5kWuNz6gs05t4XQ8bkmhXTm32NgV5jlw25TbhIZ6CVahodMmP5YOoUayg0xcYihhNsrBJvRs
	W/1X2hny45nWY30PzQJCpyX409DzkGIGK9DpISJ72/R+AEXcus6m6Sq6XyvifFzeOXeRJa9Ymu7
	j/faejFwHxUt5edpqOLvIafEerqUCighufA0zwzrvOrLmy38kl2gknUieQS4TsckYDpHocctvLZ
	nXUHIkwXMA3B0d4z7UB7OhV09K7BsXn4C+xCGWlrd7hLn/jEUTB+s7mzqhhSrhb+q6Oac+3XaVU
	vGVtz3xtMiwLG9TDWA1Bckrby0eas+8/YHXAYr9a5AMIsFWqag1eKy6v+pln5aZKBWRqSQLmMGw
	5
X-Received: by 2002:a63:65c7:: with SMTP id z190mr29255657pgb.249.1548096678944;
        Mon, 21 Jan 2019 10:51:18 -0800 (PST)
X-Received: by 2002:a63:65c7:: with SMTP id z190mr29255620pgb.249.1548096678245;
        Mon, 21 Jan 2019 10:51:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548096678; cv=none;
        d=google.com; s=arc-20160816;
        b=KPfZxsQ/N+UOjHjIUtqDjCgwRPNQbsgIwvnhUp9sIioVaoq38IEhjfzrrkbnY/Z22A
         wE1bNs4IU7g8XJ48gJr9AXyiIqiXVFexoXuXHvOOuXKgmjU9LuENHPclCTNuBCQNs3P+
         WOhccJPD9DbQJyxIE3eAW2YnrTMtk7liW8QtWhUPCEiVNRnrSo2C50QrQFHFeSjO2UER
         XYHaeZIWdClUhFbBMXq5Pwlnqb1LSTWZ2gPsopWTNGZL66aVbng4lhfk28auLQ7KqLNg
         PCFn/MaYYuwv7rliNJRP6vHB4p3IopMLtfyUfroTbTGUOAi9oTM7Rn4XkbMjNkLt2yKs
         SMdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=ttDeZKtDPkc6RYeRn0bjQXMJKzEwH+kUuuC5XU8aTs8=;
        b=GmO6Kig4wzuB2W5ymkvptk5Nyf0ervaXZW8moFcaeVHfrZRGMn1qfn4EGRbY9ksUWt
         2a3z0L4z/Sq8teLAfyZ6CC97K0bYw4BQ+S711kMEi8yyrNOGK1fxCJsPzRS53YTBLkzM
         HLoLA2iNOQHDSbyskgFo5+y/jIX9mOxzKa9TyS2hJ+KGY1xR91DSqo7taFgrjvmQORnj
         cDf3coMyQls4E2+OK0xbStylYESS/BPDv3LsSMAjR2GTgTMI/km/O5m8VbU+5Nkkk1l6
         VQJD8HDWu3bAQurASxxX9wbqY21DvYugy69DzwW/iCLFmL/uUkdLNucawWGFcYSu9Oaq
         z9aA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fYw2FSTi;
       spf=pass (google.com: domain of 3prrgxagkcm4c1u4yy5v08805y.w86527eh-664fuw4.8b0@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pRRGXAgKCM4C1u4yy5v08805y.w86527EH-664Fuw4.8B0@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 32sor19075937plb.49.2019.01.21.10.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:51:18 -0800 (PST)
Received-SPF: pass (google.com: domain of 3prrgxagkcm4c1u4yy5v08805y.w86527eh-664fuw4.8b0@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fYw2FSTi;
       spf=pass (google.com: domain of 3prrgxagkcm4c1u4yy5v08805y.w86527eh-664fuw4.8b0@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pRRGXAgKCM4C1u4yy5v08805y.w86527EH-664Fuw4.8B0@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=ttDeZKtDPkc6RYeRn0bjQXMJKzEwH+kUuuC5XU8aTs8=;
        b=fYw2FSTizyV/U1RRHYmFSgKk6DYt86c/ushk+JIy6/a82gcn0qUwvUDbSWCrBAbauV
         AKwnK9CcexEy4G4uFSPG4T3rNgyqs2LSgA4lhzIfwPY+p1BvmCevkLtKEbM4U/TP27mX
         fViGckFu+7l3SDn/vugm73AiRsSt5hdhwvzkbyp1AJMLNiyN0x9yd/YX/qc7S196uVuV
         38XJBtDz3wHzyeDqXJGf2OmHJak7cdZozvsXyTHpg7UQkOa4Wp9oxsKL7jEesNHEYO1e
         o5D/+2+Javv0lMm6P2/OlEFRqFdg+r7Shitl5UdxEoizCZe7KI/iEWrOo/5DD3BrOWl9
         lqfw==
X-Google-Smtp-Source: ALg8bN7chtpo61mycKV13Mz6uexoGRR3DjFBND6zmTxUVEBBwnmFMapT9sp49lBTdo3i+HcVKfKHSuiYldU19g==
X-Received: by 2002:a17:902:4483:: with SMTP id l3mr10631728pld.16.1548096677859;
 Mon, 21 Jan 2019 10:51:17 -0800 (PST)
Date: Mon, 21 Jan 2019 10:50:32 -0800
In-Reply-To: <20190121185033.161015-1-shakeelb@google.com>
Message-Id: <20190121185033.161015-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190121185033.161015-1-shakeelb@google.com>
X-Mailer: git-send-email 2.20.1.321.g9e740568ce-goog
Subject: [PATCH v2 2/2] mm, oom: remove 'prefer children over parent' heuristic
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121185032.283jJykw3vc_jhsPGGE28IGoyAPdtPkGv9jXx5oWSDk@z>

From the start of the git history of Linux, the kernel after selecting
the worst process to be oom-killed, prefer to kill its child (if the
child does not share mm with the parent). Later it was changed to prefer
to kill a child who is worst. If the parent is still the worst then the
parent will be killed.

This heuristic assumes that the children did less work than their parent
and by killing one of them, the work lost will be less. However this is
very workload dependent. If there is a workload which can benefit from
this heuristic, can use oom_score_adj to prefer children to be killed
before the parent.

The select_bad_process() has already selected the worst process in the
system/memcg. There is no need to recheck the badness of its children
and hoping to find a worse candidate. That's a lot of unneeded racy
work. Also the heuristic is dangerous because it make fork bomb like
workloads to recover much later because we constantly pick and kill
processes which are not memory hogs. So, let's remove this whole
heuristic.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
Changelog since v1:
- Improved commit message based on mhocko's comment.
- Replaced 'p' with 'victim'.
- Removed extra pr_err message.

 mm/oom_kill.c | 62 ++++++++-------------------------------------------
 1 file changed, 9 insertions(+), 53 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1a007dae1e8f..4da73e656c29 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -943,13 +943,8 @@ static int oom_kill_memcg_member(struct task_struct *task, void *unused)
 
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
-	struct task_struct *p = oc->chosen;
-	unsigned int points = oc->chosen_points;
-	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
+	struct task_struct *victim = oc->chosen;
 	struct mem_cgroup *oom_group;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
@@ -958,57 +953,18 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 * its children or threads, just give it access to memory reserves
 	 * so it can die quickly
 	 */
-	task_lock(p);
-	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
+	task_lock(victim);
+	if (task_will_free_mem(victim)) {
+		mark_oom_victim(victim);
+		wake_oom_reaper(victim);
+		task_unlock(victim);
+		put_task_struct(victim);
 		return;
 	}
-	task_unlock(p);
+	task_unlock(victim);
 
 	if (__ratelimit(&oom_rs))
-		dump_header(oc, p);
-
-	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
-
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-
-	/*
-	 * The task 'p' might have already exited before reaching here. The
-	 * put_task_struct() will free task_struct 'p' while the loop still try
-	 * to access the field of 'p', so, get an extra reference.
-	 */
-	get_task_struct(p);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (process_shares_mm(child, p->mm))
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child,
-				oc->memcg, oc->nodemask, oc->totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	put_task_struct(p);
-	read_unlock(&tasklist_lock);
+		dump_header(oc, victim);
 
 	/*
 	 * Do we need to kill the entire memory cgroup?
-- 
2.20.1.321.g9e740568ce-goog

