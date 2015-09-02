Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 024406B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 07:27:37 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so3704202pac.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 04:27:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mk2si34128123pab.110.2015.09.02.04.27.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Sep 2015 04:27:35 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508292014.ICI39552.tQJOFFOVMSOFHL@I-love.SAKURA.ne.jp>
	<20150901133403.GE8810@dhcp22.suse.cz>
In-Reply-To: <20150901133403.GE8810@dhcp22.suse.cz>
Message-Id: <201509022027.AEH95817.VFFOHtMQOLFOJS@I-love.SAKURA.ne.jp>
Date: Wed, 2 Sep 2015 20:27:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> Dunno, the argumentation seems quite artificial to me and not really
> relevant. Even when you see "Killed process..." then it doesn't mean
> anything. And you are quite likely to get swamped by the same messages
> the first time you hit sysrq+f.

It is no problem for me for the first time. I think I saw somewhere in
the past (maybe auditing related discussion?) that "Killed process..."
line gives us important information because that line is the only clue
when some PID unexpectedly ended.

If it is not such important, printing only number of co-killed thread
groups might be sufficient, for thread groups sharing mm can be guessed
via

  pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",

lines. We can shorten RCU period dominated by

  pr_info("Kill process %d (%s) sharing same memory\n",

for the first time.

> 
> I do agree that repeating those messages is quite annoying though and it
> doesn't make sense to print them if the task is known to have
> fatal_signal_pending already. So I do agree with the patch but I would
> really appreciate rewording of the changelog.

This changelog was intended for referencing from future patches.

> 
> I would be also tempted to change pr_err to pr_info for "Kill process %d
> (%s) sharing same memory\n"

OK. Here is an updated patch.
----------------------------------------
>From 7268b614a159cd7cb307c7dfab6241b72d9cef93 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 2 Sep 2015 20:03:16 +0900
Subject: [PATCH v2] mm/oom: Suppress unnecessary "sharing same memory" message.

oom_kill_process() sends SIGKILL to other thread groups sharing
victim's mm. But printing

  "Kill process %d (%s) sharing same memory\n"

lines makes no sense if they already have pending SIGKILL.
This patch reduces the "Kill process" lines by printing
that line with info level only if SIGKILL is not pending.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bc..610da01 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -576,9 +576,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		    !(p->flags & PF_KTHREAD)) {
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
+			if (fatal_signal_pending(p))
+				continue;
 
 			task_lock(p);	/* Protect ->comm from prctl() */
-			pr_err("Kill process %d (%s) sharing same memory\n",
+			pr_info("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
