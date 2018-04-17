Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2D2E6B0008
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p17so14784170wre.7
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 21:33:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m25si7738702edf.375.2018.04.16.21.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 21:33:23 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H4SxTs037650
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:22 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hd59h295f-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:22 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 05:33:20 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v3 0/9] trace_uprobe: Support SDT markers having reference count (semaphore)
Date: Tue, 17 Apr 2018 10:02:35 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Userspace Statically Defined Tracepoints[1] are dtrace style markers
inside userspace applications. Applications like PostgreSQL, MySQL,
Pthread, Perl, Python, Java, Ruby, Node.js, libvirt, QEMU, glib etc
have these markers embedded in them. These markers are added by developer
at important places in the code. Each marker source expands to a single
nop instruction in the compiled code but there may be additional
overhead for computing the marker arguments which expands to couple of
instructions. In case the overhead is more, execution of it can be
omitted by runtime if() condition when no one is tracing on the marker:

    if (reference_counter > 0) {
        Execute marker instructions;
    }   

Default value of reference counter is 0. Tracer has to increment the 
reference counter before tracing on a marker and decrement it when
done with the tracing.

Currently, perf tool has limited supports for SDT markers. I.e. it
can not trace markers surrounded by reference counter. Also, it's
not easy to add reference counter logic in userspace tool like perf,
so basic idea for this patchset is to add reference counter logic in
the trace_uprobe infrastructure. Ex,[2]

  # cat tick.c
    ... 
    for (i = 0; i < 100; i++) {
	DTRACE_PROBE1(tick, loop1, i);
        if (TICK_LOOP2_ENABLED()) {
            DTRACE_PROBE1(tick, loop2, i); 
        }
        printf("hi: %d\n", i); 
        sleep(1);
    }   
    ... 

Here tick:loop1 is marker without reference counter where as tick:loop2
is surrounded by reference counter condition.

  # perf buildid-cache --add /tmp/tick
  # perf probe sdt_tick:loop1
  # perf probe sdt_tick:loop2

  # perf stat -e sdt_tick:loop1,sdt_tick:loop2 -- /tmp/tick
  hi: 0
  hi: 1
  hi: 2
  ^C
  Performance counter stats for '/tmp/tick':
             3      sdt_tick:loop1
             0      sdt_tick:loop2
     2.747086086 seconds time elapsed

Perf failed to record data for tick:loop2. Same experiment with this
patch series:

  # ./perf buildid-cache --add /tmp/tick
  # ./perf probe sdt_tick:loop2
  # ./perf stat -e sdt_tick:loop2 /tmp/tick
    hi: 0
    hi: 1
    hi: 2
    ^C  
     Performance counter stats for '/tmp/tick':
                 3      sdt_tick:loop2
       2.561851452 seconds time elapsed


Note:
 - 'reference counter' is called as 'semaphore' in original Dtrace
   (or Systemtap, bcc and even in ELF) documentation and code. But the 
   term 'semaphore' is misleading in this context. This is just a counter
   used to hold number of tracers tracing on a marker. This is not really
   used for any synchronization. So we are referring it as 'reference
   counter' in kernel / perf code.

v3 changes:
 - [PATCH v3 6/9] Fix build failure.
 - [PATCH v3 6/9] Move uprobe_mmap_callback() after no_uprobe_events()
   check. Actually, it should be moved after MMF_HAS_UPROBES as well.
   But current implementation is sub-optimal. If there are multiple
   instances of same application running and user wants to trace any
   particular instance, trace_uprobe is updating reference counter in
   all instances. This is not a problem on user side because instruction
   is not replaced with trap/int3 and thus user will only see samples
   from his interested process. But still this is more of a correctness
   issue. I'm working on a fix for this. Once this gets fixed, we can
   move uprobe_mmap_callback() call after MMF_HAS_UPROBES.
 - [PATCH v3 7/9] Remove mmu_notifier. Instead, use callback from
   uprobe_clear_state(). Again, uprobe_clear_state_callback() should be
   moved after MMF_HAS_UPROBES. But that should be done when move
   uprobe_mmap_callback() first.
 - [PATCH v3 7/9] Properly handle error cases for sdt_increment_ref_ctr()
   and trace_uprobe_mmap().
 - [PATCH v3 9/9] Show warning if kernel doesn't support ref_ctr logic
   and user tries to use it. Also, return error in this case instead
   of adding entry in uprobe_events.
 - [PATCH v3 9/9] Don't check kernel ref_ctr support while adding files
   into buildid-cache.

v2 can be found at:
  https://lkml.org/lkml/2018/4/4/127

v2 changes:
 - [PATCH v2 3/9] is new. build_map_info() has a side effect. One has
   to perform mmput() when he is done with the mm. Let free_map_info()
   take care of mmput() so that one does not need to worry about it.
 - [PATCH v2 6/9] sdt_update_ref_ctr(). No need to use memcpy().
   Reference counter can be directly updated using normal assignment.
 - [PATCH v2 6/9] Check valid vma is returned by sdt_find_vma() before
   incrementing / decrementing a reference counter.
 - [PATCH v2 6/9] Introduce utility functions for taking write lock on
   dup_mmap_sem. Use these functions in trace_uprobe to avoid race with
   fork / dup_mmap().
 - [PATCH v2 6/9] Don't check presence of mm in tu->sml at decrement
   time. Purpose of maintaining the list is to ensure increment happen
   only once for each {trace_uprobe,mm} tuple.
 - [PATCH v2 7/9] v1 was not removing mm from tu->sml when process
   exits and tracing is still on. This leads to a problem if same
   address gets used by new mm. Use mmu_notifier to remove such mm
   from the list. This guarantees that all mm which has been added
   to tu->sml will be removed from list either when tracing ends or
   when process goes away.
 - [PATCH v2 7/9] Patch description was misleading. Change it. Add
   more generic python example.
 - [PATCH v2 7/9] Convert sml_rw_sem into mutex sml_lock.
 - [PATCH v2 7/9] Use builtin linked list in sdt_mm_list instead of
   defining it's own pointer chain.
 - Change the order of last two patches.
 - [PATCH v2 9/9] Check availability of ref_ctr_offset support by
   trace_uprobe infrastructure before using it. This ensures newer
   perf tool will still work on older kernels which does not support
   trace_uprobe with reference counter.
 - Other changes as suggested by Masami, Oleg and Steve.

v1 can be found at:
  https://lkml.org/lkml/2018/3/13/432

[1] https://sourceware.org/systemtap/wiki/UserSpaceProbeImplementation
[2] https://github.com/iovisor/bcc/issues/327#issuecomment-200576506
[3] https://lkml.org/lkml/2017/12/6/976

Oleg Nesterov (1):
  Uprobe: Move mmput() into free_map_info()

Ravi Bangoria (8):
  Uprobe: Export vaddr <-> offset conversion functions
  mm: Prefix vma_ to vaddr_to_offset() and offset_to_vaddr()
  Uprobe: Rename map_info to uprobe_map_info
  Uprobe: Export uprobe_map_info along with
    uprobe_{build/free}_map_info()
  trace_uprobe: Support SDT markers having reference count (semaphore)
  trace_uprobe/sdt: Fix multiple update of same reference counter
  trace_uprobe/sdt: Document about reference counter
  perf probe: Support SDT markers having reference counter (semaphore)

 Documentation/trace/uprobetracer.txt |  16 ++-
 include/linux/mm.h                   |  12 ++
 include/linux/uprobes.h              |  20 +++
 kernel/events/uprobes.c              |  90 +++++++-----
 kernel/trace/trace.c                 |   2 +-
 kernel/trace/trace_uprobe.c          | 271 ++++++++++++++++++++++++++++++++++-
 tools/perf/util/probe-event.c        |  39 ++++-
 tools/perf/util/probe-event.h        |   1 +
 tools/perf/util/probe-file.c         |  34 ++++-
 tools/perf/util/probe-file.h         |   1 +
 tools/perf/util/symbol-elf.c         |  46 ++++--
 tools/perf/util/symbol.h             |   7 +
 12 files changed, 472 insertions(+), 67 deletions(-)

-- 
1.8.3.1
