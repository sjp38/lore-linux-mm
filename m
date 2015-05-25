Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 55D7E6B00D5
	for <linux-mm@kvack.org>; Mon, 25 May 2015 10:33:34 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so70840426pdf.3
        for <linux-mm@kvack.org>; Mon, 25 May 2015 07:33:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id py8si16439110pdb.157.2015.05.25.07.33.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 May 2015 07:33:33 -0700 (PDT)
Received: from fsav301.sakura.ne.jp (fsav301.sakura.ne.jp [153.120.85.132])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t4PEXUUm010392
	for <linux-mm@kvack.org>; Mon, 25 May 2015 23:33:30 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126227184186.bbtec.net [126.227.184.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t4PEXUoV010389
	for <linux-mm@kvack.org>; Mon, 25 May 2015 23:33:30 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201505252333.FJG56590.OOFSHQMOJtFFVL@I-love.SAKURA.ne.jp>
Date: Mon, 25 May 2015 23:33:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From 3728807fe66ebc24a8a28455593754b9532bbe74 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 25 May 2015 22:26:07 +0900
Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.

If the mm struct which the OOM victim is using is shared by e.g. 1000
threads, and the lock dependency prevents all threads except the OOM
victim thread from terminating until they get TIF_MEMDIE flag, the OOM
killer will be invoked for 1000 times on this mm struct. As a result,
the kernel would emit

  "Kill process %d (%s) sharing same memory\n"

line for 1000 * 1000 / 2 times. But once these threads got pending SIGKILL,
emitting this information is nothing but noise. This patch filters them.

Similarly,

  "[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n"

lines in dump_task() might be sufficient for once per each mm struct. But
this patch does not filter them because we want a marker field in the mm
struct and a lock for protecting the marker if we want to eliminate
duplication.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5cfda39..d0eccbb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -583,6 +583,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		    !(p->flags & PF_KTHREAD)) {
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
+			if (fatal_signal_pending(p))
+				continue;
 
 			task_lock(p);	/* Protect ->comm from prctl() */
 			pr_err("Kill process %d (%s) sharing same memory\n",
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
