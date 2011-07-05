Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7282590011E
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 04:22:51 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p658MmPZ006288
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:22:48 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p658MlHu1233070
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:22:47 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p658Mll8029348
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:22:47 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 0/5] mm,debug: VM framework to capture memory reference pattern
Date: Tue,  5 Jul 2011 13:52:34 +0530
Message-Id: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi,

This patch series is an instrumentation/debug infrastructure that captures
the memory reference pattern of applications (workloads). This patch is not
for inclusion yet, but I would like to share it and improve it wherever
possible. I have successfully used this framework to collect interesting data
pertaining to memory footprint and memory reference patterns of different
workloads and benchmarks. The raw access trace data that is generated can be
further post-processed using simple scripts to generate interesting plots and
compare different workloads/kernel behavior.

The basic operation of this framework is quite simple, it basically scans
through various page tables and collects page level reference bit (provided
by hardware) information for user, kernel and pagecache pages. The code
overhead to walk all the page tables is quite heavy and the amount of data
collected is also quite large depending upon the amount of system memory
present. However, the framework allows various configurable options to trade
overhead with accuracy. The instrumentation code is implemented as a module
and the data collection starts when the module is inserted. The module starts
a kernel thread which wakes-up at every sampling interval (configurable, 100ms
by default) and scans through all pages of the specified tasks (including
children/threads) running in the system. If the hardware reference bit in the
page table is set, then the page is marked as accessed over the last sampling
interval and the reference bit is cleared. The reference data collected from
both the user and kernel (page cache) pages are exported to users using the
trace event framework.

To reduce the volume of the data collected, physical addresses are grouped in
units called memblocks (set as 64MB by default, but is configurable). If a
page in a particular memory block is referenced, the entire block is marked
as being referenced. The data obtained can be post-processed to collect
useful information about workload memory reference pattern. Further, temporal
plots (indicate the amount of memory accessed over time) and spatial plots
(indicate the particular physical regions of memory accessed) can be generated
by appropriately processing the raw trace data. Rough estimate of the working
set size of an application could be derived as well.

This framework presently works on the x86_64 systems, but can be easily
extended to other platforms as well, the constraint being that the platform
must have support to update the pte reference bit in the hardware. This
framework can be used by application and kernel developer to mainly study
application and benchmark behavior and also to look at physical memory access
pattern if that is interesting.

The framework can be extended to even capture information about whether the
access was a read or a write one, provided the hardware supports the 'Changed'
bit in the page table.

Ankita Garg (5):
  Core kernel backend to capture the memory reference pattern
  memref module to walk the process page table
  Capture kernel memory references
  Capture references to page cache pages
  Logging the captured reference data

 arch/x86/include/asm/pgtable_64.h |    1 +
 arch/x86/mm/pgtable.c             |    2 +
 arch/x86/mm/tlb.c                 |    1 +
 drivers/misc/Kconfig              |    5 +
 drivers/misc/Makefile             |    1 +
 drivers/misc/memref.c             |  195 ++++++++++++++++++++++++++++++++++
 include/linux/memtrace.h          |   30 ++++++
 include/linux/sched.h             |    4 +
 include/trace/events/memtrace.h   |   28 +++++
 kernel/fork.c                     |    6 +
 kernel/pid.c                      |    1 +
 lib/Kconfig.debug                 |    4 +
 lib/Makefile                      |    1 +
 lib/memtrace.c                    |  207 +++++++++++++++++++++++++++++++++++++
 mm/filemap.c                      |    8 ++
 mm/memory.c                       |    1 +
 mm/pagewalk.c                     |    2 +
 17 files changed, 497 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/memref.c
 create mode 100644 include/linux/memtrace.h
 create mode 100644 include/trace/events/memtrace.h
 create mode 100644 lib/memtrace.c

-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
