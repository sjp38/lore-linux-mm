Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CE0516B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:28:47 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so9142716pab.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:28:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r144si1157502pfr.2.2016.02.17.02.28.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 02:28:46 -0800 (PST)
Subject: [PATCH 0/6] preparation for merging the OOM reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 19:28:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I am posting this patchset for smoothly merging the OOM reaper without
worrying about corner cases. This patchset also applies cleanly on top of
the current Linus tree because this patchset is meant for applying before
merging the OOM reaper.

Several problems were found in oom reaper v5 patchset
( http://lkml.kernel.org/r/1454505240-23446-1-git-send-email-mhocko@kernel.org ).

(1) "[PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap
    the address space" was added in order to allow the OOM killer select
    next OOM victim by marking current OOM victim OOM-unkillable after the
    OOM reaper reaped current OOM victim's memory. But it was found that
    threads created by clone(!CLONE_SIGHAND && CLONE_VM) disable further
    OOM reaping because next OOM victim is sharing current OOM victim's
    memory and only current OOM victim is marked OOM-unkillable. While it
    would be possible to mark all processes sharing current OOM victim's
    memory OOM-unkillable, we are not trying to traverse the process list.
    ( http://lkml.kernel.org/r/201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp )

(2) It was found that clearing TIF_MEMDIE does not allow the OOM killer
    select next OOM victim if current OOM victim got stuck between getting
    PF_EXITING and doing victim's mm = NULL. Since it is possible that we
    hit silent OOM livelock before we select current OOM victim, we should
    fix it before merging the OOM reaper.
    ( http://lkml.kernel.org/r/20160111165214.GA32132@cmpxchg.org )

(3) "[PATCH 5/5] mm, oom_reaper: implement OOM victims queuing" was added
    in order to allow more robust queuing in case multiple OOM events occur
    in short period. But it was found that this queuing approach did not
    take into account oom_kill_allocating_task = 1 case which does not wait
    for existing TIF_MEMDIE threads to clear TIF_MEMDIE. Since this is a bug
    of the OOM killer rather than a bug of the OOM reaper, we should fix it
    before merging the OOM reaper.
    ( http://lkml.kernel.org/r/201602162011.ECG52697.VOLJFtOQHFMSFO@I-love.SAKURA.ne.jp )

(4) There is a very strong collision between Michal Hocko and Tetsuo Handa.
    Michal wants to merge the OOM reaper as soon as possible and correct
    corner cases afterward because this is not an urgent problem. Tetsuo
    wants to stop lying as soon as possible by papering over corner cases
    for now because this is "either address now or too late to address"
    problem, for this problem can annoy customers and technical staffs at
    support center (Tetsuo was working there) for next 10 years unless
    this problem is fixed before the DEADLINE (the day customers decide
    the distributor's specific kernel version to use for their systems).
    If we don't want to merge a mechanism for warning silent OOM livelock
    problems (e.g. kmallocwd), Tetsuo really wants to get rid of all
    possible locations that can cause silent OOM livelock problems.

This patchset does the following things.

  "[PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates."
  allows SysRq-f to select !TIF_MEMDIE process which fixes a bug in
  current kernels.

  "[PATCH 2/6] mm,oom: don't abort on exiting processes when selecting
  a victim." fixes a problem (2) explained above.

  "[PATCH 3/6] mm,oom: exclude oom_task_origin processes if they are
  OOM victims." fixes a problem similar to (2) explained above.

  "[PATCH 4/6] mm,oom: exclude oom_task_origin processes if they are
  OOM-unkillable." fixes a problem similar to (2) explained above.

  "[PATCH 5/6] mm,oom: Re-enable OOM killer using timers." mitigates
  a problem (1) explained above, by allowing the kernel ignore existing
  TIF_MEMDIE threads when OOM livelock is detected by timer based
  heuristics.

  "[PATCH 6/6] mm,oom: wait for OOM victims when using
  oom_kill_allocating_task == 1" fixes a problem (3) explained above.

By applying this patchset prior to applying the OOM reaper patchset,
we can start the OOM reaper without correcting problems found in
"[PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap
the address space" and "[PATCH 5/5] mm, oom_reaper: implement OOM
victims queuing".

 oom_kill.c |   71 +++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 51 insertions(+), 20 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
