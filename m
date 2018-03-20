Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 303706B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 07:57:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w23so771214pgv.17
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:57:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p1si1040170pfb.188.2018.03.20.04.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 04:57:54 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/2] mm,oom_reaper: Correct MAX_OOM_REAP_RETRIES'th attempt.
Date: Tue, 20 Mar 2018 20:57:56 +0900
Message-Id: <1521547076-3399-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

I got "oom_reaper: unable to reap pid:" messages when the victim thread
was blocked inside free_pgtables() (which occurred after returning from
unmap_vmas() and setting MMF_OOM_SKIP). We don't need to complain when
__oom_reap_task_mm() returned true (by e.g. finding MMF_OOM_SKIP already
set) when oom_reap_task() was trying MAX_OOM_REAP_RETRIES'th attempt.

[  663.593821] Killed process 7558 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  664.684801] oom_reaper: unable to reap pid:7558 (a.out)
[  664.892292] a.out           D13272  7558   6931 0x00100084
[  664.895765] Call Trace:
[  664.897574]  ? __schedule+0x25f/0x780
[  664.900099]  schedule+0x2d/0x80
[  664.902260]  rwsem_down_write_failed+0x2bb/0x440
[  664.905249]  ? rwsem_down_write_failed+0x55/0x440
[  664.908335]  ? free_pgd_range+0x569/0x5e0
[  664.911145]  call_rwsem_down_write_failed+0x13/0x20
[  664.914121]  down_write+0x49/0x60
[  664.916519]  ? unlink_file_vma+0x28/0x50
[  664.919255]  unlink_file_vma+0x28/0x50
[  664.922234]  free_pgtables+0x36/0x100
[  664.924797]  exit_mmap+0xbb/0x180
[  664.927220]  mmput+0x50/0x110
[  664.929504]  copy_process.part.41+0xb61/0x1fe0
[  664.932448]  ? _do_fork+0xe6/0x560
[  664.934902]  ? _do_fork+0xe6/0x560
[  664.937361]  _do_fork+0xe6/0x560
[  664.939742]  ? syscall_trace_enter+0x1a9/0x240
[  664.942693]  ? retint_user+0x18/0x18
[  664.945309]  ? page_fault+0x2f/0x50
[  664.947896]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  664.951075]  do_syscall_64+0x74/0x230
[  664.953747]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 900300c..1cb2b98 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -588,11 +588,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES) {
+		if (__oom_reap_task_mm(tsk, mm))
+			goto done;
 		schedule_timeout_idle(HZ/10);
-
-	if (attempts <= MAX_OOM_REAP_RETRIES)
-		goto done;
+	}
 
 
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-- 
1.8.3.1
