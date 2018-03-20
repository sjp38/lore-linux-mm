Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C95876B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:09 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m3so2699119ioe.17
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:09 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id o76-v6si1942123ith.18.2018.03.20.14.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:08 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 0/8] Drop mmap_sem during unmapping large map
Date: Wed, 21 Mar 2018 05:31:18 +0800
Message-Id: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Background:
Recently, when we ran some vm scalability tests on machines with large memory,
we ran into a couple of mmap_sem scalability issues when unmapping large
memory space, please refer to https://lkml.org/lkml/2017/12/14/733 and
https://lkml.org/lkml/2018/2/20/576.

Then akpm suggested to unmap large mapping section by section and drop mmap_sem
at a time to mitigate it (see https://lkml.org/lkml/2018/3/6/784). So, this
series of patches are aimed to solve the mmap_sem issue by adopting akpm's
suggestion.


Approach:
A couple of approaches were explored.
#1. Unmap large map by section in vm_munmap(). It works, but just sys_munmap()
can benefit from this change.

#2. Do unmapping in deeper place of the call chain, i.e. zap_pmd_range().
    In this way, I don't have to define a magic size for unmapping. But, there
    are two major issues:
      * mmap_sem may be acquired by down_write() or down_read() in all the
        possible call paths. So, the call path has to be checked to determine
        to use which variants, either _write or _read. It increases the
        complexity significantly.
      * The below race condition might be introduced:
A A A A       CPU AA A A A A A A A A A A A A A A A A A A A A A A A  CPU B 
       ----------A A A A A A A A A A A A A A A       ---------- 
       do_munmap
     zap_pmd_range 
       up_writeA A A A A A A A A A A A A A A A A A A A A     do_munmap
A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A      down_write 
A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A      ...... 
A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A      remove_vma_list 
A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A      up_write 
      down_write 
     access vmasA  <-- use-after-free bug

        And, unmapping by section requires splitting vma, so the code has to
        deal with partial unmapped vma, it also increase the complexity
        significantly. 

#3. Do it in do_munmap(). I can keep splitting vma/unmap region/free pagetables
    /free vmas sequence atomic for every section. And, not only sys_munmap()
    can benefit, but also mremap and sysv shm. The only problem is it may not
    want to drop mmap_sem from some call paths. So, an extra parameter, called
    "atomic", is introduced to do_munmap(). The caller can pass "true" or "false"
    to tell do_munmap() if dropping mmap_sem is expected or not. "True" means not
    drop, "false" means drop. Since all callers to do_munmap() acquire mmap_sem
    by _write, so I just need deal with one variant. And, when re-acquiring
    mmap_sem, just use down_write() for now since dealing with the return value
    of down_write_killable() sounds unnecessary.

    Other than these, a magic section size has to be defined explicitly, now
    HPAGE_PUD_SIZE is used. According to my test, HPAGE_PUD_SIZE sounds good
    enough. This is also why down_write() is used for re-acquiring mmap_sem
    instead of down_write_killable(). Smaller size looks have to much overhead.

Regression and performance data:
Test is run on a machine with 32 cores of E5-2680 @ 2.70GHz and 384GB memory

Full LTP test is done, no regression issue.

Measurement of SyS_munmap() execution time:
  size        pristine        patched        delta
  80GB       5008377 us      4905841 us       -2%
  160GB      9129243 us      9145306 us       +0.18%
  320GB      17915310 us     17990174 us      +0.42%

Throughput of page faults (#/s) with vm-scalability:
                    pristine         patched         delta
mmap-pread-seq       554894           563517         +1.6%
mmap-pread-seq-mt    581232           580772         -0.079%
mmap-xread-seq-mt    99182            105400         +6.3%

Throughput of page faults (#/s) with the below stress-ng test:
stress-ng --mmap 0 --mmap-bytes 80G --mmap-file --metrics --perf
--timeout 600s
        pristine         patched          delta
         100165           108396          +8.2%


There are 8 patches in this series.
1/8:
  Introduce a??atomica?? parameter and define do_munmap_range(), modify
  do_munmap() to call do_munmap() to unmap memory by section
2/8 - 6/8:
  modify do_munmap() call sites in mm/mmap.c, mm/mremap.c,
  fs/proc/vmcore.c, ipc/shm.c and mm/nommu.c to adopt "atomic" parameter
7/8 - 8/8:
  modify the do_munmap() call sites in arch/x86 to adopt "atomic" parameter


Yang Shi (8):
      mm: mmap: unmap large mapping by section
      mm: mmap: pass atomic parameter to do_munmap() call sites
      mm: mremap: pass atomic parameter to do_munmap()
      mm: nommu: add atomic parameter to do_munmap()
      ipc: shm: pass atomic parameter to do_munmap()
      fs: proc/vmcore: pass atomic parameter to do_munmap()
      x86: mpx: pass atomic parameter to do_munmap()
      x86: vma: pass atomic parameter to do_munmap()

 arch/x86/entry/vdso/vma.c |  2 +-
 arch/x86/mm/mpx.c         |  2 +-
 fs/proc/vmcore.c          |  4 ++--
 include/linux/mm.h        |  2 +-
 ipc/shm.c                 |  9 ++++++---
 mm/mmap.c                 | 48 ++++++++++++++++++++++++++++++++++++++++++------
 mm/mremap.c               | 10 ++++++----
 mm/nommu.c                |  5 +++--
 8 files changed, 62 insertions(+), 20 deletions(-)
