Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9E05E6B0068
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 06:56:24 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 10 Jan 2012 17:26:20 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0ABu4g92572288
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 17:26:04 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0ABu3hp018961
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 17:26:04 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 10 Jan 2012 17:18:21 +0530
Message-Id: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v9 3.2 0/9] Uprobes patchset with perf probe support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


This patchset implements Uprobes which enables you to dynamically probe
any routine in a user space application and collect information
non-disruptively.

This patchset resolves most of the comments on the previous posting
() patchset applies on top of
commit (805a6af8dba Linux 3.2)

This patchset depends on Paul McKenney's "rcu: Introduce raw SRCU
read-side primitives" - 0c53dd8b3; and my patches "x86: Clean up and
extend do_int3()" - cc3a1bf52; "x86: Call do_notify_resume() with
interrupts enabled" - 3596ff4e6b
All three commits in -tip tree.

uprobes git is hosted at git://github.com/srikard/linux.git
with branch inode_uprobes_v32. Branch for-next is also 
updated with these changes.

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

For previous postings: please refer: https://lkml.org/lkml/2011/11/18/149
https://lkml.org/lkml/2011/11/10/408 https://lkml.org/lkml/2011/9/20/123
https://lkml.org/lkml/2011/6/7/232 https://lkml.org/lkml/2011/4/1/176
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
- Rebased to 805a6af8dba Linux 3.2
- Handled comments from Masami on 'perf probe'
- Verify vma returned from find_vma as suggested by Oleg.

Here is the list of TODO Items.

- worker thread if unregister_uprobe were to fail.
- Prefiltering (i.e filtering at the time of probe insertion)
- Return probes.
- Support for other architectures.
- Uprobes booster.
- replace macro W with bits in inat table.

Please refer "[PATCH 3.2 7/9] tracing: uprobes trace_event interface".

Please refer "[PATCH 3.2 9/9] perf: perf interface for uprobes".

Please do provide your valuable comments.

Thanks in advance.
Srikar

Srikar Dronamraju (9)
 0: Uprobes patchset with perf probe support
 1: uprobes: Install and remove breakpoints.
 2: uprobes: handle breakpoint and signal step exception.
 3: uprobes: slot allocation.
 4: uprobes: counter to optimize probe hits.
 5: tracing: modify is_delete, is_return from ints to bool.
 6: tracing: Extract out common code for kprobes/uprobes traceevents.
 7: tracing: uprobes trace_event interface
 8: perf: rename target_module to target
 9: perf: perf interface for uprobes


 Documentation/trace/uprobetracer.txt    |   93 ++
 arch/Kconfig                            |    3 +
 arch/x86/Kconfig                        |    5 +-
 arch/x86/include/asm/thread_info.h      |    2 +
 arch/x86/include/asm/uprobes.h          |   59 ++
 arch/x86/kernel/Makefile                |    1 +
 arch/x86/kernel/signal.c                |    6 +
 arch/x86/kernel/uprobes.c               |  675 ++++++++++++++
 include/linux/mm_types.h                |    5 +
 include/linux/sched.h                   |    4 +
 include/linux/uprobes.h                 |  171 ++++
 kernel/Makefile                         |    1 +
 kernel/fork.c                           |   15 +
 kernel/signal.c                         |    3 +
 kernel/trace/Kconfig                    |   20 +
 kernel/trace/Makefile                   |    2 +
 kernel/trace/trace.h                    |    5 +
 kernel/trace/trace_kprobe.c             |  899 +-----------------
 kernel/trace/trace_probe.c              |  786 ++++++++++++++++
 kernel/trace/trace_probe.h              |  162 ++++
 kernel/trace/trace_uprobe.c             |  768 +++++++++++++++
 kernel/uprobes.c                        | 1546 +++++++++++++++++++++++++++++++
 mm/mmap.c                               |   33 +-
 tools/perf/Documentation/perf-probe.txt |   14 +
 tools/perf/builtin-probe.c              |   49 +-
 tools/perf/util/probe-event.c           |  430 +++++++--
 tools/perf/util/probe-event.h           |   12 +-
 tools/perf/util/symbol.c                |    8 +
 tools/perf/util/symbol.h                |    1 +
 29 files changed, 4790 insertions(+), 988 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
