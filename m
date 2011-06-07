Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 74A0F6B007B
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:05:14 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57D4vX1005937
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:04:57 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D4vqD786588
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:04:57 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D4t6N026118
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:04:57 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:28:04 +0530
Message-Id: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 0/22]  0: Uprobes patchset with perf probe support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>


This patchset implements Uprobes which enables you to dynamically break
into any routine in a user space application and collect information
non-disruptively.

This patchset resolves most of the comments on the previous posting
https://lkml.org/lkml/2011/4/1/176 and inputs I got at LFCS.  This
patchset applies on top of tip commit 59c5f46fbe01

Uprobes Patches
This patchset implements inode based uprobes which are specified as
<file>:<offset> where offset is the offset from start of the map.
The probehit overhead is around 3X times the overhead from pid based
patchset.

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

For previous postings: please refer: http://lkml.org/lkml/2011/3/14/171/
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

Here is the list of TODO Items.

- Breakpoint handling should co-exist with singlestep/blockstep from
  another tracer/debugger.
- Queue and dequeue signals delivered from the singlestep till
  completion of postprocessing.
- Prefiltering (i.e filtering at the time of probe insertion)
- Return probes.
- Support for other architectures.
- Uprobes booster.
- replace macro W with bits in inat table.

To try please fetch using
git fetch \
git://git.kernel.org/pub/scm/linux/kernel/git/srikar/linux-uprobes.git \
tip_inode_uprobes_070611:tip_inode_uprobes

Please refer "[RFC] [PATCH 3.0-rc2-tip 18/22] tracing: tracing: Uprobe
tracer documentation" on how to use uprobe_tracer.

Please refer "[RFC] [PATCH 3.0-rc2-tip 22/22] perf: Documentation for perf
uprobes" on how to use uprobe_tracer.

Please do provide your valuable comments.

Thanks in advance.
Srikar

Srikar Dronamraju (22)
 0: Uprobes patchset with perf probe support
 1: X86 specific breakpoint definitions.
 2: uprobes: Breakground page replacement.
 3: uprobes: Adding and remove a uprobe in a rb tree.
 4: Uprobes: register/unregister probes.
 5: x86: analyze instruction and determine fixups.
 6: uprobes: store/restore original instruction.
 7: uprobes: mmap and fork hooks.
 8: x86: architecture specific task information.
 9: uprobes: task specific information.
10: uprobes: slot allocation for uprobes
11: uprobes: get the breakpoint address.
12: x86: x86 specific probe handling
13: uprobes: Handing int3 and singlestep exception.
14: x86: uprobes exception notifier for x86.
15: uprobes: register a notifier for uprobes.
16: tracing: Extract out common code for kprobes/uprobes traceevents.
17: tracing: uprobes trace_event interface
18: tracing: Uprobe tracer documentation
19: perf: rename target_module to target
20: perf: perf interface for uprobes
21: perf: show possible probes in a given executable file or library.
22: perf: Documentation for perf uprobes


 Documentation/trace/uprobetrace.txt     |   94 ++
 arch/Kconfig                            |    4 +
 arch/x86/Kconfig                        |    3 +
 arch/x86/include/asm/thread_info.h      |    2 +
 arch/x86/include/asm/uprobes.h          |   53 ++
 arch/x86/kernel/Makefile                |    1 +
 arch/x86/kernel/signal.c                |   14 +
 arch/x86/kernel/uprobes.c               |  591 +++++++++++++
 include/linux/mm_types.h                |    9 +
 include/linux/sched.h                   |    9 +-
 include/linux/uprobes.h                 |  194 ++++
 kernel/Makefile                         |    1 +
 kernel/fork.c                           |   10 +
 kernel/trace/Kconfig                    |   20 +
 kernel/trace/Makefile                   |    2 +
 kernel/trace/trace.h                    |    5 +
 kernel/trace/trace_kprobe.c             |  860 +------------------
 kernel/trace/trace_probe.c              |  752 ++++++++++++++++
 kernel/trace/trace_probe.h              |  160 ++++
 kernel/trace/trace_uprobe.c             |  812 +++++++++++++++++
 kernel/uprobes.c                        | 1476 +++++++++++++++++++++++++++++++
 mm/mmap.c                               |    6 +
 tools/perf/Documentation/perf-probe.txt |   21 +-
 tools/perf/builtin-probe.c              |   77 ++-
 tools/perf/util/probe-event.c           |  431 ++++++++--
 tools/perf/util/probe-event.h           |   12 +-
 tools/perf/util/symbol.c                |   10 +-
 tools/perf/util/symbol.h                |    1 +
 28 files changed, 4686 insertions(+), 944 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
