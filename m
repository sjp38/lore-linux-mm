Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 635B16B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:52:24 -0400 (EDT)
Subject: Detailed Stack Information Patch [0/3]
From: Stefani Seibold <stefani@seibold.net>
Content-Type: text/plain
Date: Tue, 31 Mar 2009 16:58:18 +0200
Message-Id: <1238511498.364.60.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

Hi,

this is a patch which give you a better overview of the userland
application stack usage, especially for embedded linux.

Currently you are only able to dump the main process/thread stack usage
which is showed in proc/pid/status by the "VmStk" Value. But you get no
information about the consumed stack memory of the the threads.

For some reasons it becomes important to know how much memory is
consumed by each thread:

- Get out of virtual memory by creating a lot of threads
 (f.e. the developer did assign each of them the default size)
- Misuse the thread stack for big temporary data buffers
- Thread stack overruns

So this patch gives the developer an important tool to figure out if there
is one of this issues.

The patch is splitted in three parts.

Part 1 :
--------

 fs/exec.c             |    4 ++++
 fs/proc/array.c       |   22 ++++++++++++++++++++++
 fs/proc/task_mmu.c    |   12 ++++++++++++
 include/linux/sched.h |    3 +++
 init/Kconfig          |   12 ++++++++++++
 kernel/fork.c         |    5 +++++
 6 files changed, 58 insertions(+)

This is an enhancement in the /proc/<pid>/tasks/<tid>/maps and
smaps which marks the mapping where the thread stack pointer reside with
"[thread stack]".

Also there is a new entry "stack usage" in proc/pid/status, which will
you give the current stack usage.

This feature will be enabled the which "enable /proc/<pid> stack
monitoring" under "General setup-->"


Part 2:
-------

 fs/proc/Makefile   |    1 
 fs/proc/stackmon.c |  254 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 init/Kconfig       |   10 ++
 3 files changed, 265 insertions(+)

This enable a new /proc/stackmon file entry. A cat /proc/stackmon
will produce a output like:

   bytes   pages maxpages vm_start vm_end   processid threadid  name
     436       1       1  afdbf000-afdd4000 pid:  409 tid:  409 syslogd
    1168       1       1  afd12000-afd27000 pid:  411 tid:  411 sh
     516       1       1  afe6c000-afe81000 pid:  412 tid:  412 getty
    4580       2       2  af918000-af92d000 pid:  419 tid:  419 cat
The first value is the current effektive stack usage in bytes.

The second value is the current real stack usage in pages. This means
how many pages are really occupied by the stack.

The thrird value is the maximum real stack usage in pages. This value
will be determinate by the difference of the highest used page in the
mapping and the page of stack start address.

The fourth value is the start- and end- address of the mapping where the
stack currently reside.

The fifth value process id.

The sixth value is thread id.

And the seventh and last entry is the name of the process.

This feature will be enabled the which "enable /proc/<pid> stack
monitoring" under "General setup-->".


Part 3:
-------

 init/Kconfig  |   13 ++
 mm/Makefile   |    1 
 mm/stackdbg.c |  319 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 332 insertions(+)

There is also an additional stack monitor which can be enabled by boot
time or by the /sys filesystem. Which this you are able to detect if a
application use more stack than a given value. If the application
exceeds this value, it will receive a SIGTRAP signal. 

If there is a debugger attached at this time, there is the ability to
examinate the stack usage. Otherwise the application will be terminated.
In both cases a kernel log entry "pid:%d (%s) tid:%d stack size %lu
exceeds max stack size." will be written.

There are following entries under /sys/kernel/stackmon to control the
monitor.

mode:
 Setting this to an value not equal zero will start the stack monitoring
thread. Default is 0. Setting it to zero will stop the kernel thread.

stacksize:
 This value is the stack size in kb which triggers a SIGTRAP to the
application, if the stack usage is equal or more. Default is 256 kb.
 
ticks:
 Number of ticks between the monitoring invocation. A higher value will
give a less change to trigger a stack over usage, but will also result
in a less CPU usage. Default is 1.

All this parameters can also set at boot time with the kernel parameter
"stackmon=<stacksize>:<mode>:<ticks>".

The stack monitor can also be compiled as a module.



This patch is against 2.6.29. The patch is cpu independent, so it
should work on all linux supported architectures, it was tested under
x86 and powerpc. There is no dependency to a library: glibc, uclibc
and all other should work.

I hope you like it and want ask for inclusion into the kernel or linux-next? 
Please give it a try.

If you have ideas how to do things in a better way, please let me know.

Have a nice day,
Stefani


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
