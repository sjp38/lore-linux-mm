Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0406B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 05:51:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m139so33717661wma.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 02:51:17 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 8si9094891wmu.68.2016.09.01.02.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 02:51:15 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so11765099wmf.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 02:51:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 0/4] mm, oom: get rid of TIF_MEMDIE
Date: Thu,  1 Sep 2016 11:51:00 +0200
Message-Id: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>

Hi,
this is an early RFC to see whether the approach I've taken is acceptable.
The series is on top of the current mmotm tree (2016-08-31-16-06). I didn't
get to test it so it might be completely broken.

The primary point of this series is to get rid of TIF_MEMDIE finally.
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
the process. It didn't work 100% reliably and had it own issues but we
have to replace it with something which doesn't rely on counting threads
but rather find a moment when all threads have reached steady state in
do_exit. This is what patch 3 does and I would really appreciate if Oleg
could double check my thinking there. I am also CCing Al on that one
because I am moving exit_io_context up in do_exit right before exit_notify.

The last patch just removes TIF_MEMDIE from the arch code because it is
no longer needed anywhere.

I would give it some more testing but I am leaving for couple of days
and I wanted to check whether this is a sound way to go before that.

I really appreciate any feedback.

Michal Hocko (4):
      mm, oom: do not rely on TIF_MEMDIE for memory reserves access
      mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
      mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
      arch: get rid of TIF_MEMDIE


The diffstat looks quite promissing to me
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
 mm/oom_kill.c                             | 42 +++++++++++++----------
 mm/page_alloc.c                           | 57 +++++++++++++++++++++++++------
 40 files changed, 118 insertions(+), 82 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
