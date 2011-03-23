Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A595D8D0048
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:46:19 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 resend 0/12] enable writing to /proc/pid/mem
Date: Wed, 23 Mar 2011 10:43:49 -0400
Message-Id: <1300891441-16280-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

This is a resend[1] of a patch series that implements safe writes to
/proc/pid/mem.  Such functionality is useful as it gives debuggers a simple and
efficient mechanism to manipulate a process' address space.  Memory can be read
and written using single calls to pread(2) and pwrite(2) instead of iteratively
calling into ptrace(2).


Since the first version this series has had some good review.  However, I think
the first half of the series (patches 1-5) would benefit from an ACK by one of
the x86 maintainers before the mm side of things can move forward.

All changes wrt to x86 are in patches 1-5.  These make is_gate_vma() and
in_gate_vma() functions of mm_struct, not task_struct.  This is accomplished by
adding a field to mm->mm_context_t that mirrors TIF_IA32.  This change will
help simplify current and future operations on mm's.  For example, it allows
some code paths to avoid holding task_lock, or to simply avoid passing a
task_struct around when an mm will do.  


Patches 6-12 build on this flexibility to enable secure writes to
/proc/pid/mem.  These patches impact the memory and procfs subsystems.   The
principle strategy is to get a reference to the target task's mm before the
permission check, and to hold that reference until after the write completes.


This patch set is based on v2.6.38.
 
The general approach used was suggested to me by Alexander Viro, but any
mistakes present in these patches are entirely my own.


Thanks!

--
steve

[1] lkml.org/lkml/2011/3/13/147


Changes since v1:

  - Rename mm_context_t.compat to ia32_compat as suggested by Michel
    Lespinasse.

  - Rework check_mem_permission() to return ERR_PTR and hold cred_guard_mutex
    as suggested by Alexander Viro.

  - Collapse patches into a single series.

Stephen Wilson (12):
      x86: add context tag to mark mm when running a task in 32-bit compatibility mode
      x86: mark associated mm when running a task in 32 bit compatibility mode
      mm: arch: make get_gate_vma take an mm_struct instead of a task_struct
      mm: arch: make in_gate_area take an mm_struct instead of a task_struct
      mm: arch: rename in_gate_area_no_task to in_gate_area_no_mm
      mm: use mm_struct to resolve gate vma's in __get_user_pages
      mm: factor out main logic of access_process_vm
      mm: implement access_remote_vm
      proc: disable mem_write after exec
      proc: hold cred_guard_mutex in check_mem_permission()
      proc: make check_mem_permission() return an mm_struct on success
      proc: enable writing to /proc/pid/mem


 arch/powerpc/kernel/vdso.c         |    6 +-
 arch/s390/kernel/vdso.c            |    6 +-
 arch/sh/kernel/vsyscall/vsyscall.c |    6 +-
 arch/x86/ia32/ia32_aout.c          |    1 +
 arch/x86/include/asm/mmu.h         |    6 +++
 arch/x86/kernel/process_64.c       |    8 ++++
 arch/x86/mm/init_64.c              |   16 ++++----
 arch/x86/vdso/vdso32-setup.c       |   15 ++++---
 fs/binfmt_elf.c                    |    2 +-
 fs/proc/base.c                     |   79 ++++++++++++++++++++++++------------
 fs/proc/task_mmu.c                 |    8 ++-
 include/linux/mm.h                 |   12 +++--
 kernel/kallsyms.c                  |    4 +-
 mm/memory.c                        |   73 ++++++++++++++++++++++++---------
 mm/mlock.c                         |    4 +-
 mm/nommu.c                         |    2 +-
 16 files changed, 165 insertions(+), 83 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
