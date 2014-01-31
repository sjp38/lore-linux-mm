Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id DD99B6B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 13:23:56 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id as1so4700989iec.16
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 10:23:55 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.179.29])
        by mx.google.com with ESMTP id mg9si15620836icc.115.2014.01.31.10.23.54
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 10:23:55 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCHv3 0/3] Add mm flag to control THP
Date: Fri, 31 Jan 2014 12:23:42 -0600
Message-Id: <1391192628-113858-2-git-send-email-athorlton@sgi.com>
In-Reply-To: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
References: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Ingo Molnar <mingo@kernel.org>, Jiang Liu <liuj97@gmail.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <holt@sgi.com>, linux390@de.ibm.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org

This patch is based on some of my work combined with some
suggestions/patches given by Oleg Nesterov.  The main goal here is to
add a prctl switch to allow us to disable to THP on a per mm_struct
basis.

Changes for v3:

* Pulled in Oleg's idea to use mm->def_flags and the VM_NOHUGEPAGE flag,
  which will get copied down to each vm, instead of adding in a whole
  new MMF_THP_DISABLE flag to mm->flags.  This also creates a
  VM_INIT_DEF_MASK which allows the VM_NOHUGEPAGE flag to get carried
  down from def_flags.
	- Main benefit of implementing the flag this way is that, if a
	  user specifically requests THP via madvise, that request can
	  still be respected in vmas where necessary; however, for all
	  other vmas we can have THP turned off.
	- This also prevents us from having to check for a new flag in
	  multiple locations, since the VM_NOHUGEPAGE flag is already
	  respected wherever necessary.
* Made some adjustments to the way that the prctl call returns
  information, made sure to return -EINVAL when unnecessary arguments
  are passed for PRCTL_GET/SET_THP_DISABLE.
* Reverted/added some code for s390 arch that was needed to get the
  VM_INIT_DEF_MASK idea working.

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

Alex Thorlton (3):
  Revert "thp: make MADV_HUGEPAGE check for mm->def_flags"
  Add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE
  exec: kill the unnecessary mm->def_flags setting in load_elf_binary()

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Robin Holt <holt@sgi.com>
Cc: linux390@de.ibm.com
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-s390@vger.kernel.org

 arch/s390/mm/pgtable.c     |  3 +++
 fs/binfmt_elf.c            |  4 ----
 include/linux/mm.h         |  2 ++
 include/uapi/linux/prctl.h |  3 +++
 kernel/fork.c              | 11 ++++++++---
 kernel/sys.c               | 17 +++++++++++++++++
 mm/huge_memory.c           |  4 ----
 7 files changed, 33 insertions(+), 11 deletions(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
