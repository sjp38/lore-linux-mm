Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B80646B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 18:12:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u7so185190377pgo.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:12:17 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id x69si7317990pfj.283.2017.07.26.15.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 15:12:16 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v2 0/2] mm: fixes of tlb_flush_pending
Date: Wed, 26 Jul 2017 08:02:12 -0700
Message-ID: <20170726150214.11320-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, Nadav Amit <namit@vmware.com>

These two patches address tlb_flush_pending issues. The first one address a
race when accessing tlb_flush_pending  and is the important one.

The second patch addresses Andrew Morton question regarding the barriers.  This
patch is not really related to the first one: the atomic operations
atomic_read() and atomic_inc() do not act as a memory barrier, and replacing
existing barriers with smp_mb__after_atomic() did not seem beneficial. Yet,
while reviewing the memory barriers around the use of tlb_flush_pending, few
issues were identified.


v1 -> v2:
 - Explain the implications of the implications of the race (Andrew)
 - Mark the patch that address the race as stable (Andrew)
 - Add another patch to clean the use of barriers (Andrew)

Nadav Amit (2):
  mm: migrate: prevent racy access to tlb_flush_pending
  mm: migrate: fix barriers around tlb_flush_pending

 include/linux/mm_types.h | 26 ++++++++++++++++----------
 kernel/fork.c            |  2 +-
 mm/debug.c               |  2 +-
 mm/migrate.c             |  9 +++++++++
 4 files changed, 27 insertions(+), 12 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
