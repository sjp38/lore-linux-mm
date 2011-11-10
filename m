Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDF26B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:02:32 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 00:32:25 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ2LBC4063440
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:32:22 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ2KNC013143
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:02:21 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:07:25 +0530
Message-Id: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 0/28]   Uprobes patchset with perf probe support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


This patchset implements Uprobes which enables you to dynamically probe
any routine in a user space application and collect information
non-disruptively.

This patchset resolves most of the comments on the previous posting
(https://lkml.org/lkml/2011/9/20/123) patchset applies on top of
commit 1ea6b8f48918

This patchset depends on bulkref patch from Paul McKenney
https://lkml.org/lkml/2011/11/2/365 and enable interrupts before
calling do_notify_resume on i686 patch
https://lkml.org/lkml/2011/10/25/265.

uprobes git is hosted at git://github.com/srikard/linux.git
with branch inode_uprobes_v32rc1. 
(The previous patchset posted to lkml has been rebased to 3.2-rc1 is also
available at branch inode_uprobes_v32rc1_prev. This is to help the
reviewers of the previous patchset to quickly identify the changes.)

Uprobes Patches
This patchset implements inode based uprobes which are specified as
<file>:<offset> where offset is the offset from start of the map.

When a uprobe is registered, Uprobes makes a copy of the probed
instruction, replaces the first byte(s) of the probed instruction with a
breakpoint instruction. (Uprobes uses background page replacement
mechanism and ensures that the breakpoint affects only that process.)

When a CPU hits the breakpoint instruction, Uprobes gets notified of
trap and finds the associated uprobe. It then executes the associated
handler. Uprobes single-steps its copy of the probed instruction and
resumes execution of the probed process at the instruction following the
probepoint. Instruction copies to be single-stepped are stored in a
per-mm "execution out of line (XOL) area". Currently XOL area is
allocated as one page vma.

For previous postings: please refer: https://lkml.org/lkml/2011/6/7/232
https://lkml.org/lkml/2011/4/1/176 http://lkml.org/lkml/2011/3/14/171/
http://lkml.org/lkml/2010/12/16/65 http://lkml.org/lkml/2010/8/25/165
http://lkml.org/lkml/2010/7/27/121 http://lkml.org/lkml/2010/7/12/67
http://lkml.org/lkml/2010/7/8/239 http://lkml.org/lkml/2010/6/29/299
http://lkml.org/lkml/2010/6/14/41 http://lkml.org/lkml/2010/3/20/107 and
http://lkml.org/lkml/2010/5/18/307

This patchset is a rework based on suggestions from discussions on lkml
in September, March and January 2010 (http://lkml.org/lkml/2010/1/11/92,
http://lkml.org/lkml/2010/1/27/19, http://lkml.org/lkml/2010/3/20/107
and http://lkml.org/lkml/2010/3/31/199 ). This implementation of uprobes
doesnt depend on utrace.

Advantages of uprobes over conventional debugging include:

1. Non-disruptive.
Unlike current ptrace based mechanisms, uprobes tracing wouldnt
involve signals, stopping threads and context switching between the
tracer and tracee.

2. Much better handling of multithreaded programs because of XOL.
Current ptrace based mechanisms use single stepping inline, i.e they
copy back the original instruction on hitting a breakpoint.  In such
mechanisms tracers have to stop all the threads on a breakpoint hit or
tracers will not be able to handle all hits to the location of
interest. Uprobes uses execution out of line, where the instruction to
be traced is analysed at the time of breakpoint insertion and a copy
of instruction is stored at a different location.  On breakpoint hit,
uprobes jumps to that copied location and singlesteps the same
instruction and does the necessary fixups post singlestepping.

3. Multiple tracers for an application.
Multiple uprobes based tracer could work in unison to trace an
application. There could one tracer that could be interested in
generic events for a particular set of process. While there could be
another tracer that is just interested in one specific event of a
particular process thats part of the previous set of process.

4. Corelating events from kernels and userspace.
Uprobes could be used with other tools like kprobes, tracepoints or as
part of higher level tools like perf to give a consolidated set of
events from kernel and userspace.  In future we could look at a single
backtrace showing application, library and kernel calls.

Changes from last patchset:
- Rebased to Linus's 3.2-rc1 (1ea6b8f48)
- hash locks instead of i_mutex. (suggested by Christoph)
- uprobes_mmap_mutex is also a hash mutex lock.
- Resolved comments from Stefan, Peter and Oleg.
- Overhauled signal handling based on Oleg's patches.

Here is the list of TODO Items.

- Prefiltering (i.e filtering at the time of probe insertion)
- Return probes.
- Support for other architectures.
- Uprobes booster.
- replace macro W with bits in inat table.

Please refer "[PATCH 3.2-rc1 21/28] tracing: tracing: Uprobe
tracer documentation" on how to use uprobe_tracer.

Please refer "[PATCH 3.2-rc1 23/28] perf: Documentation for perf
uprobes" on how to use uprobe_tracer.

Please do provide your valuable comments.

Thanks in advance.
Srikar

Srikar Dronamraju (28)
 0: Uprobes patchset with perf probe support
 1: uprobes: Auxillary routines to insert, find, delete uprobes
 2: Uprobes: Allow multiple consumers for an uprobe.
 3: Uprobes: register/unregister probes.
 4: uprobes: Define hooks for mmap/munmap.
 5: Uprobes: copy of the original instruction.
 6: Uprobes: define fixups.
 7: Uprobes: uprobes arch info
 8: x86: analyze instruction and determine fixups.
 9: Uprobes: Background page replacement.
10: x86: Set instruction pointer.
11: x86: Introduce TIF_UPROBE FLAG.
12: Uprobes: Handle breakpoint and Singlestep
13: x86: define a x86 specific exception notifier.
14: uprobe: register exception notifier
15: x86: Define x86_64 specific uprobe_task_arch_info structure
16: uprobes: Introduce uprobe_task_arch_info structure.
17: x86: arch specific hooks for pre/post singlestep handling.
18: uprobes: slot allocation.
19: tracing: modify is_delete, is_return from ints to bool.
20: tracing: Extract out common code for kprobes/uprobes traceevents.
21: tracing: uprobes trace_event interface
22: perf: rename target_module to target
23: perf: perf interface for uprobes
24: perf: show possible probes in a given executable file or library.
25: uprobes: call post_xol() unconditionally
26: uprobes: introduce uprobe_deny_signal()
27: uprobes: x86: introduce xol_was_trapped()
28: uprobes: introduce UTASK_SSTEP_TRAPPED logic


 Documentation/trace/uprobetracer.txt    |   93 ++
 arch/Kconfig                            |    3 +
 arch/x86/Kconfig                        |    5 +-
 arch/x86/include/asm/thread_info.h      |    2 +
 arch/x86/include/asm/uprobes.h          |   58 ++
 arch/x86/kernel/Makefile                |    1 +
 arch/x86/kernel/signal.c                |    6 +
 arch/x86/kernel/uprobes.c               |  594 ++++++++++++
 include/linux/mm_types.h                |    5 +
 include/linux/sched.h                   |    4 +
 include/linux/uprobes.h                 |  170 ++++
 kernel/Makefile                         |    1 +
 kernel/fork.c                           |   15 +
 kernel/signal.c                         |    3 +
 kernel/trace/Kconfig                    |   20 +
 kernel/trace/Makefile                   |    2 +
 kernel/trace/trace.h                    |    5 +
 kernel/trace/trace_kprobe.c             |  899 +------------------
 kernel/trace/trace_probe.c              |  785 ++++++++++++++++
 kernel/trace/trace_probe.h              |  161 ++++
 kernel/trace/trace_uprobe.c             |  768 ++++++++++++++++
 kernel/uprobes.c                        | 1489 +++++++++++++++++++++++++++++++
 mm/mmap.c                               |   33 +-
 tools/perf/Documentation/perf-probe.txt |   14 +
 tools/perf/builtin-probe.c              |   49 +-
 tools/perf/util/probe-event.c           |  411 +++++++--
 tools/perf/util/probe-event.h           |   12 +-
 tools/perf/util/symbol.c                |    8 +
 tools/perf/util/symbol.h                |    1 +
 29 files changed, 4636 insertions(+), 981 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
