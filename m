Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 137DB828E2
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:54:45 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj10so17742809pad.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:54:45 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e12si12407317pat.167.2016.03.03.08.54.44
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:54:44 -0800 (PST)
From: Mark Rutland <mark.rutland@arm.com>
Subject: [PATCHv2 0/3] KASAN: clean stale poison upon cold re-entry to kernel
Date: Thu,  3 Mar 2016 16:54:25 +0000
Message-Id: <1457024068-2236-1-git-send-email-mark.rutland@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, catalin.marinas@arm.com, glider@google.com, lorenzo.pieralisi@arm.com, mark.rutland@arm.com, peterz@infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Functions which the compiler has instrumented for ASAN place poison on
the stack shadow upon entry and remove this poison prior to returning.

In some cases (e.g. hotplug and idle), CPUs may exit the kernel a number
of levels deep in C code. If there are any instrumented functions on
this critical path, these will leave portions of the idle thread stack
shadow poisoned.

If a CPU returns to the kernel via a different path (e.g. a cold entry),
then depending on stack frame layout subsequent calls to instrumented
functions may use regions of the stack with stale poison, resulting in
(spurious) KASAN splats to the console.

Contemporary GCCs always add stack shadow poisoning when ASAN is
enabled, even when asked to not instrument a function [1], so we can't
simply annotate functions on the critical path to avoid poisoning.

Instead, this series explicitly removes any stale poison before it can
be hit. In the common hotplug case we clear the entire stack shadow in
common code, before a CPU is brought online.

On architectures which perform a cold return as part of cpu idle may
retain an architecture-specific amount of stack contents. To retain the
poison for this retained context, the arch code must call the core KASAN
code, passing a "watermark" stack pointer value beyond which shadow will
be cleared. Architectures which don't perform a cold return as part of
idle do not need any additional code.

This is a combination of previous approaches [2,3], attempting to keep
as much as possible generic.

Since v1 [4]:
* Clean from task_stack_page(task)
* Add acks from v1

Andrew, the conclusion [5] from v1 was that this should go via the mm tree.
Are you happy to pick this up? 

Ingo was happy for the sched patch to go via the arm64 tree, and I assume that
also holds for going via mm. Ingo, please shout if that's not the case!

Thanks,
Mark.

[1] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=69863
[2] http://lists.infradead.org/pipermail/linux-arm-kernel/2016-February/409466.html
[3] http://lists.infradead.org/pipermail/linux-arm-kernel/2016-February/411850.html
[4] http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/413093.html
[5] http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/413475.html

Mark Rutland (3):
  kasan: add functions to clear stack poison
  sched/kasan: remove stale KASAN poison after hotplug
  arm64: kasan: clear stale stack poison

 arch/arm64/kernel/sleep.S |  4 ++++
 include/linux/kasan.h     |  6 +++++-
 kernel/sched/core.c       |  3 +++
 mm/kasan/kasan.c          | 20 ++++++++++++++++++++
 4 files changed, 32 insertions(+), 1 deletion(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
