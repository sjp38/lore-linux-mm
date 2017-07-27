Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 968716B04AE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:50:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o82so13352976pfj.11
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:50:10 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id m3si8751825pgc.963.2017.07.27.11.50.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 11:50:09 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 0/2] mm: fixes of tlb_flush_pending races
Date: Thu, 27 Jul 2017 04:40:13 -0700
Message-ID: <20170727114015.3452-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sergey.senozhatsky@gmail.com, minchan@kernel.org, nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, Nadav Amit <namit@vmware.com>

These two patches address tlb_flush_pending issues. The first one address a
race when accessing tlb_flush_pending and is the important one.

The second patch addresses Andrew Morton question regarding the barriers. This
patch is not really related to the first one: the atomic operations
atomic_read() and atomic_inc() do not act as a memory barrier, and replacing
existing barriers with smp_mb__after_atomic() did not seem beneficial. Yet,
while reviewing the memory barriers around the use of tlb_flush_pending, few
issues were identified.


v2 -> v3:
 - Do not init tlb_flush_pending if it is not defined without (Sergey)
 - Internalize memory barriers to mm_tlb_flush_pending (Minchan) 

v1 -> v2:
 - Explain the implications of the implications of the race (Andrew)
 - Mark the patch that address the race as stable (Andrew)
 - Add another patch to clean the use of barriers (Andrew)


Nadav Amit (2):
  mm: migrate: prevent racy access to tlb_flush_pending
  mm: migrate: fix barriers around tlb_flush_pending

 arch/arm/include/asm/pgtable.h   |  3 ++-
 arch/arm64/include/asm/pgtable.h |  3 ++-
 arch/x86/include/asm/pgtable.h   |  2 +-
 include/linux/mm_types.h         | 39 +++++++++++++++++++++++++++------------
 kernel/fork.c                    |  4 +++-
 mm/debug.c                       |  2 +-
 mm/migrate.c                     |  2 +-
 7 files changed, 37 insertions(+), 18 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
