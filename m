Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF6D6B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 07:57:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t69so830420pfi.20
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:57:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id bg3-v6si1454121plb.118.2018.03.20.04.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 04:57:54 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim thread.
Date: Tue, 20 Mar 2018 20:57:55 +0900
Message-Id: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

I found that it is not difficult to hit "oom_reaper: unable to reap pid:"
messages if the victim thread is doing copy_process(). Since I noticed
that it is likely helpful to show trace of unable to reap victim thread
for finding locations which should use killable wait, this patch does so.

[  226.608508] oom_reaper: unable to reap pid:9261 (a.out)
[  226.611971] a.out           D13056  9261   6927 0x00100084
[  226.615879] Call Trace:
[  226.617926]  ? __schedule+0x25f/0x780
[  226.620559]  schedule+0x2d/0x80
[  226.623356]  rwsem_down_write_failed+0x2bb/0x440
[  226.626426]  ? rwsem_down_write_failed+0x55/0x440
[  226.629458]  ? anon_vma_fork+0x124/0x150
[  226.632679]  call_rwsem_down_write_failed+0x13/0x20
[  226.635884]  down_write+0x49/0x60
[  226.638867]  ? copy_process.part.41+0x12f2/0x1fe0
[  226.642042]  copy_process.part.41+0x12f2/0x1fe0 /* i_mmap_lock_write() in dup_mmap() */
[  226.645087]  ? _do_fork+0xe6/0x560
[  226.647991]  _do_fork+0xe6/0x560
[  226.650495]  ? syscall_trace_enter+0x1a9/0x240
[  226.653443]  ? retint_user+0x18/0x18
[  226.656601]  ? page_fault+0x2f/0x50
[  226.659159]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  226.662399]  do_syscall_64+0x74/0x230
[  226.664989]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  380.525910] oom_reaper: unable to reap pid:6927 (a.out)
[  380.529274] a.out           R  running task    13544  6927      1 0x00100084
[  380.533264] Call Trace:
[  380.535433]  ? __schedule+0x25f/0x780
[  380.538052]  ? mark_held_locks+0x60/0x80
[  380.540775]  schedule+0x2d/0x80
[  380.543258]  schedule_timeout+0x1a4/0x350
[  380.546053]  ? __next_timer_interrupt+0xd0/0xd0
[  380.549033]  msleep+0x25/0x30
[  380.551458]  shrink_inactive_list+0x5b7/0x690
[  380.554408]  ? __lock_acquire+0x1f1/0xfd0
[  380.557228]  ? find_held_lock+0x2d/0x90
[  380.559959]  shrink_node_memcg+0x340/0x770
[  380.562776]  ? __lock_acquire+0x246/0xfd0
[  380.565532]  ? mem_cgroup_iter+0x121/0x4f0
[  380.568337]  ? mem_cgroup_iter+0x121/0x4f0
[  380.571203]  shrink_node+0xd8/0x370
[  380.573745]  do_try_to_free_pages+0xe3/0x390
[  380.576759]  try_to_free_pages+0xc8/0x110
[  380.579476]  __alloc_pages_slowpath+0x28a/0x8d9
[  380.582639]  __alloc_pages_nodemask+0x21d/0x260
[  380.585662]  new_slab+0x558/0x760
[  380.588188]  ___slab_alloc+0x353/0x6f0
[  380.590962]  ? copy_process.part.41+0x121f/0x1fe0
[  380.594008]  ? find_held_lock+0x2d/0x90
[  380.596750]  ? copy_process.part.41+0x121f/0x1fe0
[  380.599852]  __slab_alloc+0x41/0x7a
[  380.602469]  ? copy_process.part.41+0x121f/0x1fe0
[  380.605607]  kmem_cache_alloc+0x1a6/0x1f0
[  380.608528]  copy_process.part.41+0x121f/0x1fe0 /* kmem_cache_alloc(GFP_KERNEL) in dup_mmap() */
[  380.611613]  ? _do_fork+0xe6/0x560
[  380.614299]  _do_fork+0xe6/0x560
[  380.616752]  ? syscall_trace_enter+0x1a9/0x240
[  380.619813]  ? retint_user+0x18/0x18
[  380.622588]  ? page_fault+0x2f/0x50
[  380.625184]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  380.628841]  do_syscall_64+0x74/0x230
[  380.631660]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  600.285293] oom_reaper: unable to reap pid:7550 (a.out)
[  600.289112] a.out           D13104  7550   6931 0x00100084
[  600.292918] Call Trace:
[  600.295506]  ? __schedule+0x25f/0x780
[  600.298614]  ? __lock_acquire+0x246/0xfd0
[  600.301879]  schedule+0x2d/0x80
[  600.304623]  schedule_timeout+0x1fd/0x350
[  600.307633]  ? find_held_lock+0x2d/0x90
[  600.310909]  ? mark_held_locks+0x60/0x80
[  600.314001]  ? _raw_spin_unlock_irq+0x24/0x30
[  600.317382]  wait_for_completion+0xab/0x130
[  600.320579]  ? wake_up_q+0x70/0x70
[  600.323419]  flush_work+0x1bd/0x260
[  600.326434]  ? flush_work+0x174/0x260
[  600.329332]  ? destroy_worker+0x90/0x90
[  600.332301]  drain_all_pages+0x16d/0x1e0
[  600.335464]  __alloc_pages_slowpath+0x443/0x8d9
[  600.338743]  __alloc_pages_nodemask+0x21d/0x260
[  600.342178]  new_slab+0x558/0x760
[  600.344861]  ___slab_alloc+0x353/0x6f0
[  600.347744]  ? copy_process.part.41+0x121f/0x1fe0
[  600.351213]  ? find_held_lock+0x2d/0x90
[  600.354119]  ? copy_process.part.41+0x121f/0x1fe0
[  600.357491]  __slab_alloc+0x41/0x7a
[  600.360206]  ? copy_process.part.41+0x121f/0x1fe0
[  600.363480]  kmem_cache_alloc+0x1a6/0x1f0
[  600.366579]  copy_process.part.41+0x121f/0x1fe0 /* kmem_cache_alloc(GFP_KERNEL) in dup_mmap() */
[  600.369761]  ? _do_fork+0xe6/0x560
[  600.372382]  _do_fork+0xe6/0x560
[  600.375142]  ? syscall_trace_enter+0x1a9/0x240
[  600.378258]  ? retint_user+0x18/0x18
[  600.380978]  ? page_fault+0x2f/0x50
[  600.383814]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  600.387096]  do_syscall_64+0x74/0x230
[  600.389928]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5336985..900300c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,7 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/sched/debug.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -596,6 +597,7 @@ static void oom_reap_task(struct task_struct *tsk)
 
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
+	sched_show_task(tsk);
 	debug_show_all_locks();
 
 done:
-- 
1.8.3.1
