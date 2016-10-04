Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 882636B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 05:00:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cg13so385956496pac.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:19 -0700 (PDT)
Received: from mail-pa0-f67.google.com (mail-pa0-f67.google.com. [209.85.220.67])
        by mx.google.com with ESMTPS id gb9si2661397pac.298.2016.10.04.02.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 02:00:18 -0700 (PDT)
Received: by mail-pa0-f67.google.com with SMTP id r9so9033164paz.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:18 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/4] mm, oom: get rid of TIF_MEMDIE
Date: Tue,  4 Oct 2016 11:00:05 +0200
Message-Id: <20161004090009.7974-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>

Hi,
I have posted this as an RFC [1] to see whether the approach I've taken
is acceptable. There didn't seem to be any fundamental opposition
so I have dropped the RFC. I would like to target this for 4.10
and sending this early because I will be offline for a longer time
at the end of Oct.  The series is on top of the current mmotm tree
(2016-09-27-16-08). It has passed my basic testing and nothing blew up
but this additional testing never hurts as well as a deep review I would
be really grateful for.

The primary point of this series is to get rid of TIF_MEMDIE
finally. This has been on my TODO list for quite some time because
the flag has proven to cause many problems. First of all, the flag
was terribly overloaded. It used to act as a oom lock to prevent from
multiple oom selection, then it grants access to memory reserves and
finally it is used to count oom victims for oom_killer_disable() logic.

It really didn't help that the flag is per task_struct (aka thread)
while the OOM is mm_struct scope operation. This means that all threads
in the same thread group - or in general all processes sharing the mm -
will have to get the flag for the code to rely on it reliably. This was
not that easy because at least access to memory reserves for all threads
could deplete them quite easily. Setting the flag to all threads is
quite challenging, though, because mark_oom_victim can race with
copy_process and we could easily miss a thread.  That being said it
would be better to get rid of the flag rather workaround existing issues
and add more complicated code to fix the fundamental mismatch.

Recent changes in the oom proper allows for that finally, I believe. Now
that all the oom victims are reapable we are no longer depending on
ALLOC_NO_WATERMARKS because the memory held by the victim is reclaimed
asynchronously. A partial access to memory reserves should be sufficient
just to guarantee that the oom victim is not starved due to other
memory consumers. This also means that we do not have to pretend to be
conservative and give access to memory reserves only to one thread from
the process at the time. This is patch 1.

Patch 2 is a simple cleanup which turns TIF_MEMDIE users to tsk_is_oom_victim
which is process rather than thread centric. None of those callers really
requires to be thread aware AFAICS.

The tricky part then is exit_oom_victim vs. oom_killer_disable because
TIF_MEMDIE acted as a token there so we had a way to count threads from
the process. It didn't work 100% reliably and had its own issues but we
have to replace it with something which doesn't rely on counting threads
but rather find a moment when all threads have reached steady state in
do_exit. This is what patch 3 does and I would really appreciate if Oleg
could double check my thinking there. I am also CCing Al on that one
because I am moving exit_io_context up in do_exit right before exit_notify.

The last patch just removes TIF_MEMDIE from the arch code because it is
no longer needed anywhere.

I really appreciate any feedback.

Changes since RFC
- add motivation to the cover as suggested by Johannes
- rebased on top of the current mmotm

[1] http://lkml.kernel.org/r/1472723464-22866-1-git-send-email-mhocko@kernel.org
Michal Hocko (4):
      mm, oom: do not rely on TIF_MEMDIE for memory reserves access
      mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
      mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
      arch: get rid of TIF_MEMDIE

The diffstat looks quite promissing to me.
 arch/alpha/include/asm/thread_info.h      |  1 -
 arch/arc/include/asm/thread_info.h        |  2 --
 arch/arm/include/asm/thread_info.h        |  1 -
 arch/arm64/include/asm/thread_info.h      |  1 -
 arch/avr32/include/asm/thread_info.h      |  2 --
 arch/blackfin/include/asm/thread_info.h   |  1 -
 arch/c6x/include/asm/thread_info.h        |  1 -
 arch/cris/include/asm/thread_info.h       |  1 -
 arch/frv/include/asm/thread_info.h        |  1 -
 arch/h8300/include/asm/thread_info.h      |  1 -
 arch/hexagon/include/asm/thread_info.h    |  1 -
 arch/ia64/include/asm/thread_info.h       |  1 -
 arch/m32r/include/asm/thread_info.h       |  1 -
 arch/m68k/include/asm/thread_info.h       |  1 -
 arch/metag/include/asm/thread_info.h      |  1 -
 arch/microblaze/include/asm/thread_info.h |  1 -
 arch/mips/include/asm/thread_info.h       |  1 -
 arch/mn10300/include/asm/thread_info.h    |  1 -
 arch/nios2/include/asm/thread_info.h      |  1 -
 arch/openrisc/include/asm/thread_info.h   |  1 -
 arch/parisc/include/asm/thread_info.h     |  1 -
 arch/powerpc/include/asm/thread_info.h    |  1 -
 arch/s390/include/asm/thread_info.h       |  1 -
 arch/score/include/asm/thread_info.h      |  1 -
 arch/sh/include/asm/thread_info.h         |  1 -
 arch/sparc/include/asm/thread_info_32.h   |  1 -
 arch/sparc/include/asm/thread_info_64.h   |  1 -
 arch/tile/include/asm/thread_info.h       |  2 --
 arch/um/include/asm/thread_info.h         |  2 --
 arch/unicore32/include/asm/thread_info.h  |  1 -
 arch/x86/include/asm/thread_info.h        |  1 -
 arch/xtensa/include/asm/thread_info.h     |  1 -
 include/linux/sched.h                     |  2 +-
 kernel/cpuset.c                           |  9 ++---
 kernel/exit.c                             | 38 +++++++++++++++------
 kernel/freezer.c                          |  3 +-
 mm/internal.h                             | 11 ++++++
 mm/memcontrol.c                           |  2 +-
 mm/oom_kill.c                             | 40 +++++++++++++---------
 mm/page_alloc.c                           | 57 +++++++++++++++++++++++++------
 40 files changed, 117 insertions(+), 81 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
