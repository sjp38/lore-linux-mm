Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 322068D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 19:33:08 -0500 (EST)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 0/5] make *_gate_vma accept mm_struct instead of task_struct
Date: Tue,  8 Mar 2011 19:31:56 -0500
Message-Id: <1299630721-4337-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Morally, the question of whether an address lies in a gate vma should be asked
with respect to an mm, not a particular task.

Practically, dropping the dependency on task_struct will help make current and
future operations on mm's more flexible and convenient.  In particular, it
allows some code paths to avoid the need to hold task_lock.

The only architecture this change impacts in any significant way is x86_64.
The principle change on that architecture is to mirror TIF_IA32 via
a new flag in mm_context_t. 

This is the first of a two part series that implements safe writes to
/proc/pid/mem.  I will be posting the second series to lkml shortly.  These
patches are based on v2.6.38-rc8.  The general approach used here was suggested
to me by Alexander Viro, but any mistakes present in these patches are entirely
my own.


--
steve


Stephen Wilson (5):
      x86: add context tag to mark mm when running a task in 32-bit compatibility mode
      x86: mark associated mm when running a task in 32 bit compatibility mode
      mm: arch: make get_gate_vma take an mm_struct instead of a task_struct
      mm: arch: make in_gate_area take an mm_struct instead of a task_struct
      mm: arch: rename in_gate_area_no_task to in_gate_area_no_mm


 arch/powerpc/kernel/vdso.c         |    6 +++---
 arch/s390/kernel/vdso.c            |    6 +++---
 arch/sh/kernel/vsyscall/vsyscall.c |    6 +++---
 arch/x86/ia32/ia32_aout.c          |    1 +
 arch/x86/include/asm/mmu.h         |    6 ++++++
 arch/x86/kernel/process_64.c       |    8 ++++++++
 arch/x86/mm/init_64.c              |   16 ++++++++--------
 arch/x86/vdso/vdso32-setup.c       |   15 ++++++++-------
 fs/binfmt_elf.c                    |    2 +-
 fs/proc/task_mmu.c                 |    8 +++++---
 include/linux/mm.h                 |   10 +++++-----
 kernel/kallsyms.c                  |    4 ++--
 mm/memory.c                        |    8 ++++----
 mm/mlock.c                         |    4 ++--
 mm/nommu.c                         |    2 +-
 15 files changed, 61 insertions(+), 42 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
