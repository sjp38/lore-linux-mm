Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8627D8D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 15:50:09 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 0/12] enable writing to /proc/pid/mem
Date: Sun, 13 Mar 2011 15:49:12 -0400
Message-Id: <1300045764-24168-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

For a long time /proc/pid/mem has provided a read-only interface, at least
since 2.4.0.  However, a write capability has existed "forever" in tree via the
function mem_write(), disabled with an #ifdef along with the comment "this is a
security hazard".  Currently, the main problem with mem_write() is that between
the time permissions are checked and the actual write the target task could
exec a setuid-root binary.

This patch series enables safe writes to /proc/pid/mem.  Such functionality is
useful as it gives debuggers a simple and efficient mechanism to manipulate a
process' address space.  Memory can be read and written using single calls to
pread(2) and pwrite(2) instead of iteratively calling into ptrace(2).  In
addition, /proc/pid/mem has always had write permissions enabled, so clearly it
*wants* to be written to. 


The first version of these patches was split into two series.  Here they are
combined together for easier reference and review.


Patches 1-5 make is_gate_vma() and in_gate_vma() functions of mm_struct, not
task_struct.  These patches are of particular interest to the x86 architecture
maintainers and were originally distributed as a stand alone series[1].  From a
conceptual point of view, the question of whether an address lies in a gate vma
should be asked with respect to a particular mm, not a particular task.  From a
practical point of view, this change will help simplify current and future
operations on mm's.  In particular, it allows some code paths to avoid the need
to hold task_lock.  The principle change there is to mirror TIF_IA32 via a new
flag in mm_context_t. 


Patches 6-12 build on the new flexibility to enable secure writes to
/proc/pid/mem.  These patches impact the memory and procfs subsystems and were
originally distributed as a stand alone series[2].   The principle strategy is
to get a reference to the target task's mm before the permission check, and to
hold that reference until after the write completes.

This patch set is based on v2.6.38-rc8.
 
The general approach used was suggested to me by Alexander Viro, but any
mistakes present in these patches are entirely my own.

--
steve


[1] lkml.org/lkml/2011/3/8/409
[2] lkml.org/lkml/2011/3/8/418


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
