Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8E86B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:25:58 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j5-v6so1397257oiw.13
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:25:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p14-v6si437269oic.106.2018.07.03.07.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:25:57 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup problem.
Date: Tue,  3 Jul 2018 23:25:01 +0900
Message-Id: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

This series provides

  (1) Mitigation and a fix for CVE-2016-10723.

  (2) A mitigation for needlessly selecting next OOM victim reported
      by David Rientjes and rejected by Michal Hocko.

  (3) A preparation for handling many concurrent OOM victims which
      could become real by introducing memcg-aware OOM killer.

Tetsuo Handa (7):
  mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
  mm,oom: Check pending victims earlier in out_of_memory().
  mm,oom: Fix unnecessary killing of additional processes.
  mm,page_alloc: Make oom_reserves_allowed() even.
  mm,oom: Bring OOM notifier to outside of oom_lock.
  mm,oom: Make oom_lock static variable.
  mm,oom: Do not sleep with oom_lock held.
Michal Hocko (1):
  mm,page_alloc: Move the short sleep to should_reclaim_retry().

 drivers/tty/sysrq.c        |   2 -
 include/linux/memcontrol.h |   9 +-
 include/linux/oom.h        |   6 +-
 include/linux/sched.h      |   7 +-
 include/trace/events/oom.h |  64 -------
 kernel/fork.c              |   2 +
 mm/memcontrol.c            |  24 +--
 mm/mmap.c                  |  17 +-
 mm/oom_kill.c              | 439 +++++++++++++++++++++------------------------
 mm/page_alloc.c            | 134 ++++++--------
 10 files changed, 287 insertions(+), 417 deletions(-)

-- 
1.8.3.1
