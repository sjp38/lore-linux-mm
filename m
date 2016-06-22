Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E88A66B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:14:07 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id c1so39905277lbw.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:14:07 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id kq10si43833932wjc.2.2016.06.22.05.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 05:14:06 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 187so632746wmz.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:14:06 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] oom, suspend: fix oom_reaper vs. oom_killer_disable race
Date: Wed, 22 Jun 2016 14:13:54 +0200
Message-Id: <1466597634-16199-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has reported the following potential oom_killer_disable vs.
oom_reaper race:

(1) freeze_processes() starts freezing user space threads.
(2) Somebody (maybe a kenrel thread) calls out_of_memory().
(3) The OOM killer calls mark_oom_victim() on a user space thread
    P1 which is already in __refrigerator().
(4) oom_killer_disable() sets oom_killer_disabled = true.
(5) P1 leaves __refrigerator() and enters do_exit().
(6) The OOM reaper calls exit_oom_victim(P1) before P1 can call
    exit_oom_victim(P1).
(7) oom_killer_disable() returns while P1 not yet finished
(8) P1 perform IO/interfere with the freezer.

This situation is unfortunate. We cannot move oom_killer_disable after
all the freezable kernel threads are frozen because the oom victim might
depend on some of those kthreads to make a forward progress to exit so
we could deadlock. It is also far from trivial to teach the oom_reaper
to not call exit_oom_victim() because then we would lose a guarantee of
the OOM killer and oom_killer_disable forward progress because
exit_mm->mmput might block and never call exit_oom_victim.

It seems the easiest way forward is to workaround this race by calling
try_to_freeze_tasks again after oom_killer_disable. This will make sure
that all the tasks are frozen or it bails out.

Fixes: 449d777d7ad6 ("mm, oom_reaper: clear TIF_MEMDIE for all tasks queued for oom_reaper")
Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this is a temporal fix that is easy enough for the current 4.7 cycle.
Even though I suspect PM suspend race with the OOM killer is super
unlikely it is better to not risk it considering the patch is quite
trivial. I plan to come up with a proper solution later on after some
other OOM killer/reaper changes settle down.  It is really desirable
that oom_killer_disable() is a full "barrier" rather than working around
potential issues.

So if this looks like a proper fix to you Rafael I would route this via Andrew.
What do you think?

 kernel/power/process.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/kernel/power/process.c b/kernel/power/process.c
index df058bed53ce..0c2ee9761d57 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -146,6 +146,18 @@ int freeze_processes(void)
 	if (!error && !oom_killer_disable())
 		error = -EBUSY;
 
+	/*
+	 * There is a hard to fix race between oom_reaper kernel thread
+	 * and oom_killer_disable. oom_reaper calls exit_oom_victim
+	 * before the victim reaches exit_mm so try to freeze all the tasks
+	 * again and catch such a left over task.
+	 */
+	if (!error) {
+		pr_info("Double checking all user space processes after OOM killer disable... ");
+		error = try_to_freeze_tasks(true);
+		pr_cont("\n");
+	}
+
 	if (error)
 		thaw_processes();
 	return error;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
