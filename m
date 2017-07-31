Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C055D6B04D1
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 19:53:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b83so1198875pfl.6
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 16:53:55 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id o1si12094880pld.1001.2017.07.31.16.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 16:53:54 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 0/3] mm: fixes of tlb_flush_pending
Date: Mon, 31 Jul 2017 09:43:22 -0700
Message-ID: <20170731164325.235019-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

These three patches address tlb_flush_pending issues. The first one address
a race when accessing tlb_flush_pending and is the important one.

The next two patch addresses Andrew Morton question regarding the barriers.
This patch is not really related to the first one: the atomic operations
atomic_read() and atomic_inc() do not act as a memory barrier, and
replacing existing barriers with smp_mb__after_atomic() did not seem
beneficial. Yet, while reviewing the memory barriers around the use of
tlb_flush_pending, few issues were identified.

v4 -> v5:
 - Fixing embarrassing build mistake (0day)

v3 -> v4:
 - Change function names to indicate they inc/dec and not set/clear
   (Sergey)
 - Avoid additional barriers, and instead revert the patch that accessed
   mm_tlb_flush_pending without a lock (Mel)

v2 -> v3:
 - Do not init tlb_flush_pending if it is not defined without (Sergey)
 - Internalize memory barriers to mm_tlb_flush_pending (Minchan) 

v1 -> v2:
 - Explain the implications of the implications of the race (Andrew)
 - Mark the patch that address the race as stable (Andrew)
 - Add another patch to clean the use of barriers (Andrew)

Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>


Nadav Amit (3):
  mm: migrate: prevent racy access to tlb_flush_pending
  mm: migrate: fix barriers around tlb_flush_pending
  Revert "mm: numa: defer TLB flush for THP migration as long as
    possible"

 include/linux/mm_types.h | 45 ++++++++++++++++++++++++++++++++-------------
 kernel/fork.c            |  2 +-
 mm/debug.c               |  2 +-
 mm/huge_memory.c         |  7 +++++++
 mm/migrate.c             |  6 ------
 mm/mprotect.c            |  4 ++--
 6 files changed, 43 insertions(+), 23 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
