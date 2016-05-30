Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E79B86B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:06:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f75so29152243wmf.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:06 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id g198si30684990wmd.58.2016.05.30.06.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 06:06:05 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so22523053wmn.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:05 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/6 -v2] Handle oom bypass more gracefully
Date: Mon, 30 May 2016 15:05:50 +0200
Message-Id: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
based on the feedback from Tetsuo and Vladimir (thanks to you both) I
had to change some of my assumptions and rework some patches. I planned
to resend later this week but I guess it would help to argue about the
code after those changes if I resubmit earlier. The previous version was
posted here http://lkml.kernel.org/r/1464266415-15558-1-git-send-email-mhocko@kernel.org

The following 6 patches should put some order to very rare cases of
mm shared between processes and make the paths which bypass the oom
killer oom reapable and so much more reliable finally. Even though mm
shared outside of threadgroup is rare (either vforked tasks for a
short period, use_mm by kernel threads or exotic thread model of
clone(CLONE_VM) without CLONE_THREAD resp. CLONE_SIGHAND). Not only it
makes the current oom killer logic quite hard to follow and evaluate it
can lead to weird corner cases. E.g. it is possible to select an oom
victim which shares the mm with unkillable process or bypass the oom
killer even when other processes sharing the mm are still alive and
other weird cases.

Patch 1 drops a bogus task_lock and mm check from oom_adj_write. This
can be considered a bug fix with a low impact as nobody has noticed
for years.

Patch 2 is a clean up of oom_score_adj handling and a preparatory
work. Patch 3 enforces oom_adj_score to be consistent between processes
sharing the mm to behave consistently with the regular thread
groups. This can be considered a user visible behavior change because
one thread group oom_score_adj update will affect others which share
the same mm via clone(CLONE_VM). I argue that this should be acceptable
because we already have the same behavior for threads in the same thread
group and sharing the mm without signal struct is just a different model
of threading. This is probably the most controversial part of the series,
I would like to find some consensus here though. There were some
suggestions to hook some counter/oom_score_adj into the mm_struct
but I feel that this is not necessary right now and we can rely on
proc handler + oom_kill_process to DTRT. I can be convinced otherwise
but I strongly think that whatever we do the userspace has to have
a way to see the current oom priority as consistently as possible.

Patch 4 makes sure that no vforked task is selected if it is sharing
the mm with oom unkillable task.

Patch 5 ensures that all tasks sharing the mm are killed which in turn
makes sure that all oom victims are oom reapable.

Patch 6 guarantees that task_will_free_mem will always imply reapable
bypass of the oom killer.

The patchset is based on the current mmotm tree (mmotm-2016-05-27-15-19).
I would really appreciate a deep review as this area is full of land
mines but I hope I've made the code much cleaner with less kludges.

I am CCing Oleg (sorry I know you hate this code) but I would feel much
better if you double checked my assumptions about locking and vfork
behavior.

Michal Hocko (6):
      proc, oom: drop bogus task_lock and mm check
      proc, oom_adj: extract oom_score_adj setting into a helper
      mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj
      mm, oom: skip vforked tasks from being selected
      mm, oom: kill all tasks sharing the mm
      mm, oom: fortify task_will_free_mem

 fs/proc/base.c      | 172 ++++++++++++++++++++++++++++++----------------------
 include/linux/mm.h  |   2 +
 include/linux/oom.h |  63 +++++++++++++++++--
 mm/memcontrol.c     |   4 +-
 mm/oom_kill.c       |  82 +++++--------------------
 5 files changed, 176 insertions(+), 147 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
