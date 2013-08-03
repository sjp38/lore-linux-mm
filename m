Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id D36A66B0031
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 13:00:30 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/7] improve memcg oom killer robustness v2
Date: Sat,  3 Aug 2013 12:59:53 -0400
Message-Id: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Changes in version 2:
o use user_mode() instead of open coding it on s390 (Heiko Carstens)
o clean up memcg OOM enable/disable toggling (Michal Hocko & KOSAKI
  Motohiro)
o add a separate patch to rework and document OOM locking
o fix a problem with lost wakeups when sleeping on the OOM lock
o fix OOM unlocking & wakeups with userspace OOM handling

The memcg code can trap tasks in the context of the failing allocation
until an OOM situation is resolved.  They can hold all kinds of locks
(fs, mm) at this point, which makes it prone to deadlocking.

This series converts memcg OOM handling into a two step process that
is started in the charge context, but any waiting is done after the
fault stack is fully unwound.

Patches 1-4 prepare architecture handlers to support the new memcg
requirements, but in doing so they also remove old cruft and unify
out-of-memory behavior across architectures.

Patch 5 disables the memcg OOM handling for syscalls, readahead,
kernel faults, because they can gracefully unwind the stack with
-ENOMEM.  OOM handling is restricted to user triggered faults that
have no other option.

Patch 6 reworks memcg's hierarchical OOM locking to make it a little
more obvious wth is going on in there: reduce locked regions, rename
locking functions, reorder and document.

Patch 7 implements the two-part OOM handling such that tasks are never
trapped with the full charge stack in an OOM situation.

 arch/alpha/mm/fault.c      |   7 +-
 arch/arc/mm/fault.c        |  11 +--
 arch/arm/mm/fault.c        |  23 +++--
 arch/arm64/mm/fault.c      |  23 +++--
 arch/avr32/mm/fault.c      |   4 +-
 arch/cris/mm/fault.c       |   6 +-
 arch/frv/mm/fault.c        |  10 +-
 arch/hexagon/mm/vm_fault.c |   6 +-
 arch/ia64/mm/fault.c       |   6 +-
 arch/m32r/mm/fault.c       |  10 +-
 arch/m68k/mm/fault.c       |   2 +
 arch/metag/mm/fault.c      |   6 +-
 arch/microblaze/mm/fault.c |   7 +-
 arch/mips/mm/fault.c       |   8 +-
 arch/mn10300/mm/fault.c    |   2 +
 arch/openrisc/mm/fault.c   |   1 +
 arch/parisc/mm/fault.c     |   7 +-
 arch/powerpc/mm/fault.c    |   7 +-
 arch/s390/mm/fault.c       |   2 +
 arch/score/mm/fault.c      |  13 ++-
 arch/sh/mm/fault.c         |   9 +-
 arch/sparc/mm/fault_32.c   |  12 ++-
 arch/sparc/mm/fault_64.c   |   8 +-
 arch/tile/mm/fault.c       |  13 +--
 arch/um/kernel/trap.c      |  22 +++--
 arch/unicore32/mm/fault.c  |  22 +++--
 arch/x86/mm/fault.c        |  43 ++++-----
 arch/xtensa/mm/fault.c     |   2 +
 include/linux/memcontrol.h |  65 +++++++++++++
 include/linux/mm.h         |   1 +
 include/linux/sched.h      |   7 ++
 mm/filemap.c               |  11 ++-
 mm/memcontrol.c            | 229 +++++++++++++++++++++++++++++----------------
 mm/memory.c                |  43 +++++++--
 mm/oom_kill.c              |   7 +-
 35 files changed, 444 insertions(+), 211 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
