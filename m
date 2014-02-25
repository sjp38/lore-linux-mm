Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 44A216B00CC
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:54:18 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id gl10so4602472lab.14
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:54:17 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id x5si1832495lal.60.2014.02.25.12.54.15
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 12:54:16 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCHv4 0/3] [RESEND] mm, thp: Add mm flag to control THP
Date: Tue, 25 Feb 2014 14:54:03 -0600
Message-Id: <cover.1392009759.rs.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

(First send had too big of a cc list to make it into all the mailing lists.)

This patch is based on some of my work combined with some
suggestions/patches given by Oleg Nesterov.  The main goal here is to
add a prctl switch to allow us to disable to THP on a per mm_struct
basis.

Changes for v4:

* Added a bit of documentation for flag changes
* Changed the prctl switch code so that get/set operations are
  processed in separate cases
* Added information about the new flags to the user-facing prctl docs
  (this is in a separate patch, everyone will be cc'd there as well)

The main motivation behind this patch is to provide a way to disable THP
for jobs where the code cannot be modified, and using a malloc hook with
madvise is not an option (i.e. statically allocated data).  This patch
allows us to do just that, without affecting other jobs running on the
system.

We need to do this sort of thing for jobs where THP hurts performance,
due to the possibility of increased remote memory accesses that can be
created by situations such as the following:

When you touch 1 byte of an untouched, contiguous 2MB chunk, a THP will
be handed out, and the THP will be stuck on whatever node the chunk was
originally referenced from.  If many remote nodes need to do work on
that same chunk, they'll be making remote accesses.

With THP disabled, 4K pages can be handed out to separate nodes as
they're needed, greatly reducing the amount of remote accesses to
memory.

Here's a bit of test data with the new patch in place...

First with the flag unset:

# perf stat -a ./prctl_wrapper_mmv3 0 ./thp_pthread -C 0 -m 0 -c 512 -b 256g                  
Setting thp_disabled for this task...
thp_disable: 0
Set thp_disabled state to 0
Process pid = 18027

                                                                                                                     PF/
                                MAX        MIN                                  TOTCPU/      TOT_PF/   TOT_PF/     WSEC/
TYPE:               CPUS       WALL       WALL        SYS     USER     TOTCPU       CPU     WALL_SEC   SYS_SEC       CPU   NODES
 512      1.120      0.060      0.000    0.110      0.110     0.000    28571428864 -9223372036854775808  55803572      23

 Performance counter stats for './prctl_wrapper_mmv3_hack 0 ./thp_pthread -C 0 -m 0 -c 512 -b 256g':

  273719072.841402 task-clock                #  641.026 CPUs utilized           [100.00%]
         1,008,986 context-switches          #    0.000 M/sec                   [100.00%]
             7,717 CPU-migrations            #    0.000 M/sec                   [100.00%]
         1,698,932 page-faults               #    0.000 M/sec
355,222,544,890,379 cycles                    #    1.298 GHz                     [100.00%]
536,445,412,234,588 stalled-cycles-frontend   #  151.02% frontend cycles idle    [100.00%]
409,110,531,310,223 stalled-cycles-backend    #  115.17% backend  cycles idle    [100.00%]
148,286,797,266,411 instructions              #    0.42  insns per cycle
                                             #    3.62  stalled cycles per insn [100.00%]
27,061,793,159,503 branches                  #   98.867 M/sec                   [100.00%]
     1,188,655,196 branch-misses             #    0.00% of all branches

     427.001706337 seconds time elapsed

Now with the flag set:

# perf stat -a ./prctl_wrapper_mmv3 1 ./thp_pthread -C 0 -m 0 -c 512 -b 256g
Setting thp_disabled for this task...
thp_disable: 1
Set thp_disabled state to 1
Process pid = 144957

                                                                                                                     PF/
                                MAX        MIN                                  TOTCPU/      TOT_PF/   TOT_PF/     WSEC/
TYPE:               CPUS       WALL       WALL        SYS     USER     TOTCPU       CPU     WALL_SEC   SYS_SEC       CPU   NODES
 512      0.620      0.260      0.250    0.320      0.570     0.001    51612901376 128000000000 100806448      23

 Performance counter stats for './prctl_wrapper_mmv3_hack 1 ./thp_pthread -C 0 -m 0 -c 512 -b 256g':

  138789390.540183 task-clock                #  641.959 CPUs utilized           [100.00%]
           534,205 context-switches          #    0.000 M/sec                   [100.00%]
             4,595 CPU-migrations            #    0.000 M/sec                   [100.00%]
        63,133,119 page-faults               #    0.000 M/sec
147,977,747,269,768 cycles                    #    1.066 GHz                     [100.00%]
200,524,196,493,108 stalled-cycles-frontend   #  135.51% frontend cycles idle    [100.00%]
105,175,163,716,388 stalled-cycles-backend    #   71.07% backend  cycles idle    [100.00%]
180,916,213,503,160 instructions              #    1.22  insns per cycle
                                             #    1.11  stalled cycles per insn [100.00%]
26,999,511,005,868 branches                  #  194.536 M/sec                   [100.00%]
       714,066,351 branch-misses             #    0.00% of all branches

     216.196778807 seconds time elapsed

As with previous versions of the patch, We're getting about a 2x
performance increase here.  Here's a link to the test case I used, along
with the little wrapper to activate the flag:

http://oss.sgi.com/projects/memtests/thp_pthread_mmprctlv3.tar.gz

Let me know if anybody has any further suggestions here.  Thanks!

(Sorry for the big cc list!)

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org

Alex Thorlton (3):
  Revert "thp: make MADV_HUGEPAGE check for mm->def_flags"
  Add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE
  exec: kill the unnecessary mm->def_flags setting in load_elf_binary()

 arch/s390/mm/pgtable.c     |  3 +++
 fs/binfmt_elf.c            |  4 ----
 include/linux/mm.h         |  3 +++
 include/uapi/linux/prctl.h |  3 +++
 kernel/fork.c              | 11 ++++++++---
 kernel/sys.c               | 15 +++++++++++++++
 mm/huge_memory.c           |  4 ----
 7 files changed, 32 insertions(+), 11 deletions(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
