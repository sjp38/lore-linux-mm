Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8387F83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:28 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so28652706lfw.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:28 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id fs16si12979181wjc.230.2016.08.25.03.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:27 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so6661991wme.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 0/10] fortify oom killer even more 
Date: Thu, 25 Aug 2016 12:03:05 +0200
Message-Id: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>

Hi,
I have sent this pile as an [1] previously. There are two changes since
then. I have dropped patch 8 [2] because Tetsuo was concerned that it
might increase chances to deplete memory reserves. While I am not sure
this would be the case I agree that it is not really necessary for this
series and it will fit better into changes I am plaiing later on.
Then I have replaced patch 9 [3] because Michael has noted that [4]
that protecting vhost get_user usage is not sufficient because the driver
can call into tun so that would need some changes as well and who knows
what else might need tweaking.

Patch 1 and 2 are cleanups from Tetsuo.

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

Patch 8 makes sure that all kthreads (use_mm users) will detect that the mm
might have been reaped and do not trust memory returned from the page fault.

Patch 9 then allows to reap oom victim memory even when it is shared
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

The series is based on top of the mmotm (2016-08-23-14-42). Feedback is
more than welcome.

Thanks!

[1] http://lkml.kernel.org/r/1469734954-31247-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/1469734954-31247-9-git-send-email-mhocko@kernel.org
[3] http://lkml.kernel.org/r/1469734954-31247-10-git-send-email-mhocko@kernel.org
[4] http://lkml.kernel.org/r/20160822210123.5k6zwdrkhrwjw5vv@redhat.com

Michal Hocko (6):
      oom: keep mm of the killed task available
      kernel, oom: fix potential pgd_lock deadlock from __mmdrop
      mm, oom: get rid of signal_struct::oom_victims
      oom, suspend: fix oom_killer_disable vs. pm suspend properly
      mm: make sure that kthreads will not refault oom reaped memory
      oom, oom_reaper: allow to reap mm shared by the kthreads

Tetsuo Handa (3):
      mm,oom_reaper: Reduce find_lock_task_mm() usage.
      mm,oom_reaper: Do not attempt to reap a task twice.
      mm, oom: enforce exit_oom_victim on current task


 include/linux/mm_types.h |   2 -
 include/linux/oom.h      |   9 ++-
 include/linux/sched.h    |  21 ++++++-
 kernel/exit.c            |   2 +-
 kernel/fork.c            |   7 +++
 kernel/power/process.c   |  17 +----
 mm/memory.c              |  13 ++++
 mm/oom_kill.c            | 161 ++++++++++++++++++++---------------------------
 8 files changed, 118 insertions(+), 114 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
