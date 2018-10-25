Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8963E6B026B
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:24:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k17-v6so4185095edr.18
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 01:24:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b25-v6sor2265800ejo.11.2018.10.25.01.24.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 01:24:11 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH v2 0/3] oom: rework oom_reaper vs. exit_mmap handoff
Date: Thu, 25 Oct 2018 10:24:00 +0200
Message-Id: <20181025082403.3806-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

The previous version of this RFC has been posted here [1]. I have fixed
few issues spotted during the review and by 0day bot. I have also reworked
patch 2 to be ratio rather than an absolute number based.

With this series applied the locking protocol between the oom_reaper and
the exit path is as follows.

All parts which cannot race should use the exclusive lock on the exit
path. Once the exit path has passed the moment when no blocking locks
are taken then it clears mm->mmap under the exclusive lock. oom_reaper
checks for this and sets MMF_OOM_SKIP only if the exit path is not guaranteed
to finish the job. This is patch 3 so see the changelog for all the details.

I would really appreciate if David could give this a try and see how
this behaves in workloads where the oom_reaper falls flat now. I have
been playing with sparsely allocated memory with a high pte/real memory
ratio and large mlocked processes and it worked reasonably well.

There is still some room for tuning here of course. We can change the
number of retries for the oom_reaper as well as the threshold when the
keep retrying.

Michal Hocko (3):
      mm, oom: rework mmap_exit vs. oom_reaper synchronization
      mm, oom: keep retrying the oom_reap operation as long as there is substantial memory left
      mm, oom: hand over MMF_OOM_SKIP to exit path if it is guranteed to finish

Diffstat:
 include/linux/oom.h |  2 --
 mm/internal.h       |  3 +++
 mm/memory.c         | 28 ++++++++++++++--------
 mm/mmap.c           | 69 +++++++++++++++++++++++++++++++++--------------------
 mm/oom_kill.c       | 45 ++++++++++++++++++++++++----------
 5 files changed, 97 insertions(+), 50 deletions(-)

[1] http://lkml.kernel.org/r/20180910125513.311-1-mhocko@kernel.org
