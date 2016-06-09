Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id F01B76B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 07:52:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so16659433lff.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:27 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h8si14229319wme.124.2016.06.09.04.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 04:52:26 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r5so10077929wmr.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Date: Thu,  9 Jun 2016 13:52:07 +0200
Message-Id: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
this is the v4 version of the patchse. Previous version was posted
http://lkml.kernel.org/r/1464945404-30157-1-git-send-email-mhocko@kernel.org
It's been mostly my screwups during the rebase that were fixed and
patch 10 reworked.

The following 10 patches should put some order to very rare cases of
mm shared between processes and make the paths which bypass the oom
killer oom reapable and therefore much more reliable finally. Even
though mm shared outside of thread group is rare (either vforked tasks
for a short period, use_mm by kernel threads or exotic thread model of
clone(CLONE_VM) without CLONE_SIGHAND) it is better to cover them. Not
only it makes the current oom killer logic quite hard to follow and
reason about it can lead to weird corner cases. E.g. it is possible to
select an oom victim which shares the mm with unkillable process or
bypass the oom killer even when other processes sharing the mm are still
alive and other weird cases.

Patch 1 drops bogus task_lock and mm check from oom_{score_}adj_write.
This can be considered a bug fix with a low impact as nobody has noticed
for years.

Patch 2 drops sighand lock because it is not needed anymore as pointed
by Oleg.

Patch 3 is a clean up of oom_score_adj handling and a preparatory
work for later patches.

Patch 4 enforces oom_adj_score to be consistent between processes
sharing the mm to behave consistently with the regular thread
groups. This can be considered a user visible behavior change because
one thread group updating oom_score_adj will affect others which share
the same mm via clone(CLONE_VM). I argue that this should be acceptable
because we already have the same behavior for threads in the same thread
group and sharing the mm without signal struct is just a different model
of threading. This is probably the most controversial part of the series,
I would like to find some consensus here. There were some suggestions
to hook some counter/oom_score_adj into the mm_struct but I feel that
this is not necessary right now and we can rely on proc handler +
oom_kill_process to DTRT. I can be convinced otherwise but I strongly
think that whatever we do the userspace has to have a way to see the
current oom priority as consistently as possible.

Patch 5 makes sure that no vforked task is selected if it is sharing
the mm with oom unkillable task.

Patch 6 ensures that all user tasks sharing the mm are killed which in
turn makes sure that all oom victims are oom reapable.

Patch 7 guarantees that task_will_free_mem will always imply reapable
bypass of the oom killer.

Patch 8 is new in this version and it addresses an issue pointed out
by 0-day OOM report where an oom victim was reaped several times.

Patch 9 puts an upper bound on how many times oom_reaper tries to reap a
task and hides it from the oom killer to move on when no progress can be
made. This will give an upper bound to how long an oom_reapable task can
block the oom killer from selecting another victim if the oom_reaper is
not able to reap the victim.

Patch 10 tries to plug the (hopefully) last hole when we can still lock
up when the oom victim is shared with oom unkillable tasks (kthreads
and global init). We just try to be best effort in that case and rather
fallback to kill something else than risk a lockup.

I believe that timeout based heurisitcs are no longer really needed
after this series. We still have some room for improvements, though. I
would like to explore ways how to remove kthreads (use_mm) special
case. It shouldn't be that hard, we just have to teach the page fault
handler to recognize oom victim mm and enforce EFAULT for kthreads which
have borrowed that mm.

The patchset is based on the current mmotm tree (mmotm-2016-06-08-15-25).
I would really appreciate a deep review as this area is full of land
mines but I hope I've made the code much cleaner with less kludges.

I have pushed the patchset to my git tree
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git to branch
attempts/process-share-mm-oom-sanitization

Michal Hocko (10):
      proc, oom: drop bogus task_lock and mm check
      proc, oom: drop bogus sighand lock
      proc, oom_adj: extract oom_score_adj setting into a helper
      mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj
      mm, oom: skip vforked tasks from being selected
      mm, oom: kill all tasks sharing the mm
      mm, oom: fortify task_will_free_mem
      mm, oom: task_will_free_mem should skip oom_reaped tasks
      mm, oom_reaper: do not attempt to reap a task more than twice
      mm, oom: hide mm which is shared with kthread or global init

 fs/proc/base.c        | 185 ++++++++++++++++++++++++----------------------
 include/linux/mm.h    |   2 +
 include/linux/oom.h   |  26 +------
 include/linux/sched.h |  27 +++++++
 mm/memcontrol.c       |   4 +-
 mm/oom_kill.c         | 201 ++++++++++++++++++++++++++++++++++----------------
 6 files changed, 266 insertions(+), 179 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
