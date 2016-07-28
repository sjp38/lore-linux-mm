Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2F76B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 15:42:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so24895684wmz.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:42 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id i71si42922043wme.14.2016.07.28.12.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 12:42:40 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q128so12643199wma.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:40 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/10] fortify oom killer even more 
Date: Thu, 28 Jul 2016 21:42:24 +0200
Message-Id: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Marcelo Tosatti <mtosatti@redhat.com>, Michal Hocko <mhocko@suse.com>, Mikulas Patocka <mpatocka@redhat.com>

Hi,
I have sent this pile as an RFC [1] previously and after some testing
and discussion about an alternative approach [2] it seems this will plug
the remaining holes which could lead to oom lockups for CONFIG_MMU and
open doors to further improvements and cleanups.

I have added few more patches since the last time. Patches 1 and 2 can be
considered cleanups and I've taken them from Tetsuo's patchset [2].

Patch 3 is the core part of this series. It makes the mm of the oom victim
persistent in signal struct so that the oom killer can rely purely on this
mm rather than find_lock_task_mm which might not find any mm if all threads
passed exit_mm. Patch 4 is a follow up fix noticed during testing. I could
have folded it to the patch 3 but I guess both will be easier to review if
they are separate.

Patch 5 is a cleanup and it removes signal_struct::oom_victims which is no
longer needed.

Patch 6 makes oom_killer_disable full quiescent state barrier again.

Patch 7 is a pure cleanup. Again taken from Tetsuo's series [2].

Patch 8 moves exit_oom_victim out of exit_mm to the end of do_exit.

Patch 9 transforms vhost get_user/copy_from_user usage to oom reaper
safe variant. There were some proposals how to provide a different API -
e.g. a notification mechanism resp. processing SIGKILL from the kernel
thread - but none of them was either lockless or easier and I really do
not want to make further lock dependencies between oom killer and other
kernel subsystems. I didn't get to test this part because I do not have
much idea why. I would really appreciate help from Michael here.

Patch 10 then allows to reap oom victim memory even when it is shared
with a kthread via use_mm as the only problematic user is safe to after
the previous patch. This leaves the only non-reapable case when the global
init shares the mm with a different process (other than vfork) which I
would consider exotic and slightly idiotic so I wouldn't lose sleep over
it.

After this series we should have guaranteed forward progress for the oom
killer invocation for mmu arches AFAICS. It would be great if this could
make it into 4.9. I would like to build on top of this and clean up the
code even more. I would like to get rid of TIF_MEMDIE in the next step
and make memory reserves access completely independent on the rest of the
OOM killer logic.

I have run this through the hammering tests mostly coming from Tetsuo
and apart from the lockup fixed by the patch 4 and nothing popped out.

The series is based on top of the mmotm (2016-07-22-15-51). Feedback is
more than welcome.

Thanks!

[1] http://lkml.kernel.org/r/1467365190-24640-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp

Michal Hocko (7):
      oom: keep mm of the killed task available
      mm, oom: get rid of signal_struct::oom_victims
      kernel, oom: fix potential pgd_lock deadlock from __mmdrop
      oom, suspend: fix oom_killer_disable vs. pm suspend properly
      exit, oom: postpone exit_oom_victim to later
      vhost, mm: make sure that oom_reaper doesn't reap memory read by vhost
      oom, oom_reaper: allow to reap mm shared by the kthreads

Tetsuo Handa (3):
      mm,oom_reaper: Reduce find_lock_task_mm() usage.
      mm,oom_reaper: Do not attempt to reap a task twice.
      mm, oom: enforce exit_oom_victim on current task


 drivers/vhost/scsi.c     |   2 +-
 drivers/vhost/vhost.c    |  18 +++---
 include/linux/mm_types.h |   2 -
 include/linux/oom.h      |  10 ++-
 include/linux/sched.h    |  21 ++++++-
 include/linux/uaccess.h  |  22 +++++++
 include/linux/uio.h      |  10 +++
 kernel/exit.c            |   5 +-
 kernel/fork.c            |   7 +++
 kernel/power/process.c   |  17 +----
 mm/mmu_context.c         |   6 ++
 mm/oom_kill.c            | 161 +++++++++++++++++++++--------------------------
 12 files changed, 158 insertions(+), 123 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
