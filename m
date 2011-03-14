Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 392A58D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:40:10 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDe23k014791
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:10:02 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDdhAG2469968
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:09:43 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDdhuO016238
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:09:44 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:04:03 +0530
Message-Id: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 0/20]  0: Inode based uprobes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


This patchset implements Uprobes which enables you to dynamically break
into any routine in a user space application and collect information
non-disruptively.

This patchset resolves most of the comments from Peter on the previous
posting https://lkml.org/lkml/2010/12/16/65.

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

For previous posting: please refer: http://lkml.org/lkml/2010/8/25/165
http://lkml.org/lkml/2010/7/27/121, http://lkml.org/lkml/2010/7/12/67,
http://lkml.org/lkml/2010/7/8/239, http://lkml.org/lkml/2010/6/29/299,
http://lkml.org/lkml/2010/6/14/41, http://lkml.org/lkml/2010/3/20/107
and http://lkml.org/lkml/2010/5/18/307

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

- Integrating perf probe with this patchset.
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
tip_inode_uprobes_140311:tip_inode_uprobes

Please refer "[RFC] [PATCH 2.6.37-rc5-tip 20/20] 20: tracing: uprobes
trace_event infrastructure" on how to use uprobe_tracer.

Please do provide your valuable comments.

Thanks in advance.
Srikar

 Srikar Dronamraju(20)
 0: Inode based uprobes
 1: mm: Move replace_page() to mm/memory.c
 2: X86 specific breakpoint definitions.
 3: uprobes: Breakground page replacement.
 4: uprobes: Adding and remove a uprobe in a rb tree.
 5: Uprobes: register/unregister probes.
 6: x86: analyze instruction and determine fixups.
 7: uprobes: store/restore original instruction.
 8: uprobes: mmap and fork hooks.
 9: x86: architecture specific task information.
10: uprobes: task specific information.
11: uprobes: slot allocation for uprobes
12: uprobes: get the breakpoint address.
13: x86: x86 specific probe handling
14: uprobes: Handing int3 and singlestep exception.
15: x86: uprobes exception notifier for x86.
16: uprobes: register a notifier for uprobes.
17: uprobes: filter chain
18: uprobes: commonly used filters.
19: tracing: Extract out common code for kprobes/uprobes traceevents.
20: tracing: uprobes trace_event interface

 arch/Kconfig                       |    4 +
 arch/x86/Kconfig                   |    3 +
 arch/x86/include/asm/thread_info.h |    2 +
 arch/x86/include/asm/uprobes.h     |   58 ++
 arch/x86/kernel/Makefile           |    1 +
 arch/x86/kernel/signal.c           |   14 +
 arch/x86/kernel/uprobes.c          |  600 ++++++++++++++++
 include/linux/mm.h                 |    2 +
 include/linux/mm_types.h           |    9 +
 include/linux/sched.h              |    3 +
 include/linux/uprobes.h            |  183 +++++
 kernel/Makefile                    |    1 +
 kernel/fork.c                      |   10 +
 kernel/trace/Kconfig               |   20 +
 kernel/trace/Makefile              |    2 +
 kernel/trace/trace.h               |    5 +
 kernel/trace/trace_kprobe.c        |  861 +-----------------------
 kernel/trace/trace_probe.c         |  753 ++++++++++++++++++++
 kernel/trace/trace_probe.h         |  160 +++++
 kernel/trace/trace_uprobe.c        |  800 ++++++++++++++++++++++
 kernel/uprobes.c                   | 1331 ++++++++++++++++++++++++++++++++++++
 mm/ksm.c                           |   62 --
 mm/memory.c                        |   62 ++
 mm/mmap.c                          |    2 +
 24 files changed, 4044 insertions(+), 904 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
