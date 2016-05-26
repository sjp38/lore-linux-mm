Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 608046B025E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 08:40:26 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 132so8834818lfz.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:26 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id r9si4487589wme.20.2016.05.26.05.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 05:40:25 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id n129so98213674wmn.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:24 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/5] Handle oom bypass more gracefully
Date: Thu, 26 May 2016 14:40:09 +0200
Message-Id: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
the following 6 patches should put some order to very rare cases of
mm shared between processes and make the paths which bypass the oom
killer oom reapable and so much more reliable finally.  Even though mm
shared outside of threadgroup is rare (either use_mm by kernel threads
or exotic clone(CLONE_VM) without CLONE_THREAD resp. CLONE_SIGHAND) it
makes the current oom killer logic quite hard to follow and evaluate. It
is possible to select an oom victim which shares the mm with unkillable
process or bypass the oom killer even when other processes sharing the
mm are still alive and other weird cases.

Patch 1 optimizes oom_kill_task to skip the costly process
iteration when the current oom victim is not sharing mm with other
processes. Patch 2 is a clean up of oom_score_adj handling and a
preparatory work. Patch 3 enforces oom_adj_score to be consistent
between processes sharing the mm to behave consistently with the regular
thread groups. Patch 4 tries to handle vforked tasks better in the oom
path, patch 5 ensures that all tasks sharing the mm are killed and
finally patch 6 should guarantee that task_will_free_mem will always
imply reapable bypass of the oom killer.

The patchset is based on the current mmotm tree (mmotm-2016-05-23-16-51).
I would really appreciate a deep review as this area is full of land
mines but I hope I've made the code much cleaner with less kludges.

I am CCing Oleg (sorry I know you hate this code) but I would feel much
better if you double checked my assumptions about locking and vfork
behavior.

Michal Hocko (6):
      mm, oom: do not loop over all tasks if there are no external tasks sharing mm
      proc, oom_adj: extract oom_score_adj setting into a helper
      mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj
      mm, oom: skip over vforked tasks
      mm, oom: kill all tasks sharing the mm
      mm, oom: fortify task_will_free_mem

 fs/proc/base.c      | 168 +++++++++++++++++++++++++++++-----------------------
 include/linux/mm.h  |   2 +
 include/linux/oom.h |  72 ++++++++++++++++++++--
 mm/memcontrol.c     |   4 +-
 mm/oom_kill.c       |  96 ++++++++++--------------------
 5 files changed, 196 insertions(+), 146 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
