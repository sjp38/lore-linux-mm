Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 142BC6B0069
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 23:49:31 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id v10so7771874pde.16
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 20:49:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id hn2si15559097pbc.82.2014.11.22.20.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 22 Nov 2014 20:49:29 -0800 (PST)
Received: from fsav201.sakura.ne.jp (fsav201.sakura.ne.jp [210.224.168.163])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4nQjA080687
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:49:26 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4nQ4A080684
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:49:26 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [RFC PATCH 0/5] mm: Patches for mitigating memory allocation stalls.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:49:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This patchset serves for two purposes.

  (a) Mitigate one of phenomena

       "Regarding many of Linux kernel versions (from unknown till now), any
        local user can give a certain type of memory pressure which causes
        __alloc_pages_nodemask() to keep trying to reclaim memory for
        presumably forever. As a consequence, such user can disturb any users'
        activities by keeping the system stalled with 0% or 100% CPU usage.
        On systems where XFS is used, SysRq-f (forced OOM killer) may become
        unresponsive because kernel worker thread which is supposed to process
        SysRq-f request is blocked by previous request's GFP_WAIT allocation."

      which is triggered by a vulnerability which exists since (if I didn't
      miss something) Linux 2.0 (18 years ago).

      I reported this vulnerability last year and a CVE number was assigned,
      but no progress has been made. If a malicious local user notices a
      patchset that mitigates/fixes this vulnerability, the user is free to
      attack existing Linux systems. Therefore, I propose this patchset before
      any patchset that mitigates/fixes this vulnerability is proposed.

  (b) Help debugging memory allocation stall problems which are not caused
      by malicious attacks. Since I'm providing technical support service for
      troubleshooting RHEL systems, I sometimes encounter cases where memory
      allocation is suspicious. But SysRq or hung check timer does not report
      how long the thread stalled for memory allocation. Therefore, I propose
      this patchset for reporting and responding memory allocation stalls.

This patchset does the following things.

  [PATCH 1/5] mm: Introduce OOM kill timeout.

    Introduce timeout for TIF_MEMDIE threads in case they cannot be
    terminated immediately for some reason.

  [PATCH 2/5] mm: Kill shrinker's global semaphore.

    Don't respond with "try again" when we need to call out_of_memory().

  [PATCH 3/5] mm: Remember ongoing memory allocation status.

    Remember the starting time of ongoing memory allocation, and let
    thread dump print how long ongoing memory allocation is stalled.

  [PATCH 4/5] mm: Drop __GFP_WAIT flag when allocating from shrinker functions.

    Avoid potential deadlock or kernel stack overflow by calling shrinker
    functions recursively.

  [PATCH 5/5] mm: Insert some delay if ongoing memory allocation stalls.

    Introduce a small sleep for saving CPU when memory allocation is taking
    too long.

This patchset is meant for ease of backporting because fixing the root cause
requires fundamental changes which may prevent any Linux systems from working
unless carefully implemented and appropriately configured.

  drivers/staging/android/lowmemorykiller.c |    2
  include/linux/mm.h                        |    2
  include/linux/sched.h                     |    5 +
  include/linux/shrinker.h                  |    4 +
  kernel/sched/core.c                       |   17 ++++++
  mm/memcontrol.c                           |    2
  mm/oom_kill.c                             |   35 ++++++++++++-
  mm/page_alloc.c                           |   68 +++++++++++++++++++++++++-
  mm/vmscan.c                               |   78 +++++++++++++++++++++---------
  9 files changed, 184 insertions(+), 29 deletions(-)

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
