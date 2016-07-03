Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 654A76B0005
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:37:12 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id cx13so65561386pac.2
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:37:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d196si1381895pfd.10.2016.07.02.19.37.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:37:11 -0700 (PDT)
Subject: [PATCH 0/8] Change OOM killer to use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:35:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

This is my alternative proposal compared to what Michal posted at
http://lkml.kernel.org/r/1467365190-24640-1-git-send-email-mhocko@kernel.org .

The series is based on top of linux-next-20160701 +
http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .

The key point of the series is [PATCH 3/8].
[PATCH 1/8] can be sent to current linux.git as a clean up.

The series does not include patches for use_mm() users and wait_event()
in oom_killer_disable(). Thus, some of Michal's patches can be added
on top of the series.

[PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run() failure check.
[PATCH 2/8] mm,oom_reaper: Reduce find_lock_task_mm() usage.
[PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
[PATCH 4/8] mm,oom: Remove OOM_SCAN_ABORT case.
[PATCH 5/8] mm,oom: Remove unused signal_struct->oom_victims.
[PATCH 6/8] mm,oom_reaper: Stop clearing TIF_MEMDIE on remote thread.
[PATCH 7/8] mm,oom_reaper: Pass OOM victim's comm and pid values via mm_struct.
[PATCH 8/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.

 include/linux/mm_types.h |   12 +
 include/linux/oom.h      |   16 --
 include/linux/sched.h    |    4
 kernel/exit.c            |    2
 kernel/fork.c            |    1
 kernel/power/process.c   |   12 -
 mm/memcontrol.c          |   16 --
 mm/oom_kill.c            |  336 +++++++++++++++++++++--------------------------
 8 files changed, 177 insertions(+), 222 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
