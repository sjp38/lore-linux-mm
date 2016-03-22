Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CE49E6B0264
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:01:17 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l68so186703898wml.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:17 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id b77si19721335wmf.115.2016.03.22.04.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:01:10 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id p65so29046822wmp.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:10 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 8/9] oom: make oom_reaper freezable
Date: Tue, 22 Mar 2016 12:00:25 +0100
Message-Id: <1458644426-22973-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

After "oom: clear TIF_MEMDIE after oom_reaper managed to unmap the
address space" oom_reaper will call exit_oom_victim on the target
task after it is done. This might however race with the PM freezer:

CPU0				CPU1				CPU2
freeze_processes
  try_to_freeze_tasks
  				# Allocation request
				out_of_memory
  oom_killer_disable
				  wake_oom_reaper(P1)
				  				__oom_reap_task
								  exit_oom_victim(P1)
    wait_event(oom_victims==0)
[...]
    				do_exit(P1)
				  perform IO/interfere with the freezer

which breaks the oom_killer_disable semantic. We no longer have a
guarantee that the oom victim won't interfere with the freezer because
it might be anywhere on the way to do_exit while the freezer thinks the
task has already terminated. It might trigger IO or touch devices which
are frozen already.

In order to close this race, make the oom_reaper thread freezable. This
will work because
	a) already running oom_reaper will block freezer to enter the
	   quiescent state
	b) wake_oom_reaper will not wake up the reaper after it has been
	   frozen
	c) the only way to call exit_oom_victim after try_to_freeze_tasks
	   is from the oom victim's context when we know the further
	   interference shouldn't be possible

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index af75260f32c3..bed2885d10b0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -524,6 +524,8 @@ static void oom_reap_task(struct task_struct *tsk)
 
 static int oom_reaper(void *unused)
 {
+	set_freezable();
+
 	while (true) {
 		struct task_struct *tsk = NULL;
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
