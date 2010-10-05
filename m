Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C52F56B007E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:54:01 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o957rtqh029797
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:53:55 -0700
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by wpaz17.hot.corp.google.com with ESMTP id o957rrh6000616
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:53:53 -0700
Received: by pxi17 with SMTP id 17so1814065pxi.29
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 00:53:53 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/3] V2: Reduce mmap_sem hold times during file backed page faults
Date: Tue,  5 Oct 2010 00:53:32 -0700
Message-Id: <1286265215-9025-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

This is the second iteration of our change dropping mmap_sem when a disk
access occurs during a page fault to a file backed VMA.

Changes since V1:
- Cleaned up 'Retry page fault when blocking on disk transfer' applying
  linus's suggestions
- Added 'access_error API cleanup'

Tests:

- microbenchmark: thread A mmaps a large file and does random read accesses
  to the mmaped area - achieves about 55 iterations/s. Thread B does
  mmap/munmap in a loop at a separate location - achieves 55 iterations/s
  before, 15000 iterations/s after.
- We are seeing related effects in some applications in house, which show
  significant performance regressions when running without this change.
- I am looking for a microbenchmark to expose the worst case overhead of
  the page fault retry. Would FIO be a good match for that use ?

Michel Lespinasse (3):
  filemap_fault: unique path for locking page
  Retry page fault when blocking on disk transfer.
  access_error API cleanup

 arch/x86/mm/fault.c |   44 +++++++++++++++++++++++++++++---------------
 include/linux/mm.h  |    2 ++
 mm/filemap.c        |   41 ++++++++++++++++++++++++++++++++---------
 mm/memory.c         |    3 ++-
 4 files changed, 65 insertions(+), 25 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
