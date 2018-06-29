Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B84006B000C
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:40:46 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so5706541pld.23
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:40:46 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id x70-v6si10245688pfa.108.2018.06.29.15.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 15:40:45 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v3 PATCH 0/5] mm: zap pages with read mmap_sem in munmap for large mapping
Date: Sat, 30 Jun 2018 06:39:40 +0800
Message-Id: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org


Background:
Recently, when we ran some vm scalability tests on machines with large memory,
we ran into a couple of mmap_sem scalability issues when unmapping large memory
space, please refer to https://lkml.org/lkml/2017/12/14/733 and
https://lkml.org/lkml/2018/2/20/576.


History:
Then akpm suggested to unmap large mapping section by section and drop mmap_sem
at a time to mitigate it (see https://lkml.org/lkml/2018/3/6/784).

V1 patch series was submitted to the mailing list per Andrewa??s suggestion
(see https://lkml.org/lkml/2018/3/20/786). Then I received a lot great feedback
and suggestions.

Then this topic was discussed on LSFMM summit 2018. In the summit, Michal Hock
suggested (also in the v1 patches review) to try "two phases" approach. Zapping
pages with read mmap_sem, then doing via cleanup with write mmap_sem (for
discussion detail, see https://lwn.net/Articles/753269/)


Changelog:
v2 a??> v3:
* Refactor do_munmap code to extract the common part per Peter's sugestion
* Introduced VM_DEAD flag per Michal's suggestion. Just handled VM_DEAD in 
  x86's page fault handler for the time being. Other architectures will be covered
  once the patch series is reviewed
* Now lookup vma (find and split) and set VM_DEAD flag with write mmap_sem, then
  zap mapping with read mmap_sem, then clean up pgtables and vmas with write
  mmap_sem per Peter's suggestion

v1 a??> v2:
* Re-implemented the code per the discussion on LSFMM summit

 
Regression and performance data:
Test is run on a machine with 32 cores of E5-2680 @ 2.70GHz and 384GB memory

Regression test with full LTP and trinity (munmap) with setting thresh to 4K in
the code (just for regression test only) so that the new code can be covered
better and trinity (munmap) test manipulates 4K mapping.

No regression issue is reported and the system survives under trinity (munmap)
test for 4 hours until I abort the test.

Throughput of page faults (#/s) with the below stress-ng test:
stress-ng --mmap 0 --mmap-bytes 80G --mmap-file --metrics --perf
--timeout 600s
        pristine         patched          delta
       89.41K/sec       97.29K/sec        +8.8%

The result is not very stable, and depends on timing. So, this is just for reference.


Yang Shi (5):
      uprobes: make vma_has_uprobes non-static
      mm: introduce VM_DEAD flag
      mm: refactor do_munmap() to extract the common part
      mm: mmap: zap pages with read mmap_sem for large mapping
      x86: check VM_DEAD flag in page fault

 arch/x86/mm/fault.c     |   4 ++
 include/linux/mm.h      |   6 +++
 include/linux/uprobes.h |   7 +++
 kernel/events/uprobes.c |   2 +-
 mm/mmap.c               | 243 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------
 5 files changed, 224 insertions(+), 38 deletions(-)
