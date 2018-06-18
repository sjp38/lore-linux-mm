Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05BC56B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:34:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so10951051plo.9
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:34:51 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id a98-v6si16533656pla.117.2018.06.18.16.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 16:34:50 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v2 0/2] mm: zap pages with read mmap_sem in munmap for large mapping
Date: Tue, 19 Jun 2018 07:34:14 +0800
Message-Id: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


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

So, I came up with the V2 patch series per this suggestion. Here I don't call
madvise(MADV_DONTNEED) directly since it is a little different from what munmap
does, so I use unmap_region() as what do_munmap() does.
The patches may need more cleanup and refactor, but it sounds better to let the
community start review the patches early to make sure I'm on the right track.


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

The number looks a little bit better than v1.


Yang Shi (2):
      uprobes: make vma_has_uprobes non-static
      mm: mmap: zap pages with read mmap_sem for large mapping

 include/linux/uprobes.h |   7 ++++
 kernel/events/uprobes.c |   2 +-
 mm/mmap.c               | 148 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 155 insertions(+), 2 deletions(-)
