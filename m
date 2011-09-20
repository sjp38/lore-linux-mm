Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A0C7B9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:13:23 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCDBNF026548
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:43:11 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCDBEm2662406
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:43:11 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCD9L5018082
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:43:11 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:29:38 +0530
Message-Id: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 0/26]   Uprobes patchset with perf probe support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>


This patchset implements Uprobes which enables you to dynamically break
into any routine in a user space application and collect information
non-disruptively.

This patchset resolves most of the comments on the previous posting
(https://lkml.org/lkml/2011/6/7/232) patchset applies on top of tip
commit e467f18f945c83e66

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

For previous postings: please refer: https://lkml.org/lkml/2011/4/1/176
http://lkml.org/lkml/2011/3/14/171/ http://lkml.org/lkml/2010/12/16/65
http://lkml.org/lkml/2010/8/25/165 http://lkml.org/lkml/2010/7/27/121
http://lkml.org/lkml/2010/7/12/67 http://lkml.org/lkml/2010/7/8/239
http://lkml.org/lkml/2010/6/29/299 http://lkml.org/lkml/2010/6/14/41
http://lkml.org/lkml/2010/3/20/107 and http://lkml.org/lkml/2010/5/18/307

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
- mmap_uprobe doesnt drop mmap_sem anymore
- Introduced uprobes_mmap_mutex to serialize mmap_uprobes.
- Uses i_mutex instead of uprobes_mutex.
- Introduces munmap_uprobes
- Change in perf probe interface as recommended by Masami.
- Doesnt depend on get_user_pages to do the COW.
- Slot allocation changed from per-task to shared slot allocation mechanism.

Here is the list of TODO Items.

- Prefiltering (i.e filtering at the time of probe insertion)
- Return probes.
- Support for other architectures.
- Uprobes booster.
- replace macro W with bits in inat table.

Please refer "[RFC] [PATCH 3.1-rc4-tip 21/26] tracing: tracing: Uprobe
tracer documentation" on how to use uprobe_tracer.

Please refer "[RFC] [PATCH 3.1-rc4-tip 25/26] perf: Documentation for perf
uprobes" on how to use uprobe_tracer.

Please do provide your valuable comments.

Thanks in advance.
Srikar
---
 0 files changed, 0 insertions(+), 0 deletions(-)


Srikar Dronamraju (26)
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
19: tracing: Extract out common code for kprobes/uprobes traceevents.
20: tracing: uprobes trace_event interface
21: tracing: uprobes Documentation
22: perf: rename target_module to target
23: perf: perf interface for uprobes
24: perf: show possible probes in a given executable file or library.
25: perf: Documentation for perf uprobes
26: uprobes: queue signals while thread is singlestepping.


 Documentation/trace/uprobetracer.txt    |   94 ++
 arch/Kconfig                            |    4 +
 arch/x86/Kconfig                        |    3 +
 arch/x86/include/asm/thread_info.h      |    2 +
 arch/x86/include/asm/uprobes.h          |   54 ++
 arch/x86/kernel/Makefile                |    1 +
 arch/x86/kernel/signal.c                |   14 +
 arch/x86/kernel/uprobes.c               |  562 ++++++++++++
 include/linux/mm_types.h                |    5 +
 include/linux/sched.h                   |    3 +
 include/linux/uprobes.h                 |  165 ++++
 kernel/Makefile                         |    1 +
 kernel/fork.c                           |   11 +
 kernel/signal.c                         |   22 +-
 kernel/trace/Kconfig                    |   20 +
 kernel/trace/Makefile                   |    2 +
 kernel/trace/trace.h                    |    5 +
 kernel/trace/trace_kprobe.c             |  894 +------------------
 kernel/trace/trace_probe.c              |  784 ++++++++++++++++
 kernel/trace/trace_probe.h              |  162 ++++
 kernel/trace/trace_uprobe.c             |  770 ++++++++++++++++
 kernel/uprobes.c                        | 1475 +++++++++++++++++++++++++++++++
 mm/memory.c                             |    4 +
 mm/mmap.c                               |    6 +
 tools/perf/Documentation/perf-probe.txt |   14 +
 tools/perf/builtin-probe.c              |   49 +-
 tools/perf/util/probe-event.c           |  410 +++++++--
 tools/perf/util/probe-event.h           |   12 +-
 tools/perf/util/symbol.c                |   10 +-
 tools/perf/util/symbol.h                |    1 +
 30 files changed, 4581 insertions(+), 978 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
