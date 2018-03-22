Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33C366B0003
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 07:36:49 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w19-v6so5212265plq.2
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:36:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h67si4789652pfj.11.2018.03.22.04.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 04:36:46 -0700 (PDT)
Subject: [PATCH] mm,oom_reaper: Check for MMF_OOM_SKIP before complain.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1521547076-3399-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180320121246.GK23100@dhcp22.suse.cz>
	<201803202137.CAC35494.OFtJLHFSFOMVOQ@I-love.SAKURA.ne.jp>
	<201803202147.ICB09393.FFSJOOtHVQOFLM@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.20.1803201349270.167205@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.20.1803201349270.167205@chino.kir.corp.google.com>
Message-Id: <201803221946.DHG65638.VFJHFtOSQLOMOF@I-love.SAKURA.ne.jp>
Date: Thu, 22 Mar 2018 19:46:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: rientjes@google.com, mhocko@suse.com, linux-mm@kvack.org

>From b141cdbe0db852549c94d5b1e6a9967ca69d59fd Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 22 Mar 2018 19:44:12 +0900
Subject: [PATCH] mm,oom_reaper: Check for MMF_OOM_SKIP before complain.

I got "oom_reaper: unable to reap pid:" messages when the victim thread
was blocked inside free_pgtables() (which occurred after returning from
unmap_vmas() and setting MMF_OOM_SKIP). We don't need to complain when
exit_mmap() already set MMF_OOM_SKIP.

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
Acked-by: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5336985..dfd3705 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -590,7 +590,8 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts <= MAX_OOM_REAP_RETRIES)
+	if (attempts <= MAX_OOM_REAP_RETRIES ||
+	    test_bit(MMF_OOM_SKIP, &mm->flags))
 		goto done;
 
 
-- 
1.8.3.1
