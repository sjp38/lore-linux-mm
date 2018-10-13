Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2060D6B0296
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 20:24:33 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s56-v6so14041482qtk.2
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:24:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 42-v6si72049qvp.34.2018.10.12.17.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 17:24:32 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/3] migrate_misplaced_transhuge_page race conditions
Date: Fri, 12 Oct 2018 20:24:27 -0400
Message-Id: <20181013002430.698-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

Aaron found a new instance of the THP MADV_DONTNEED race against
pmdp_clear_flush* variants, that was apparently left unfixed.

While looking into the race found by Aaron, I may have found two more
issues in migrate_misplaced_transhuge_page.

These race conditions would not cause kernel instability, but they'd
corrupt userland data or leave data non zero after MADV_DONTNEED.

I did only minor testing, and I don't expect to be able to reproduce
this (especially the lack of ->invalidate_range before
migrate_page_copy, requires the latest iommu hardware or infiniband to
reproduce). The last patch is noop for x86 and it needs further review
from maintainers of archs that implement flush_cache_range() (not in
CC yet).

To avoid confusion, it's not the first patch that introduces the
bug fixed in the second patch, even before removing the
pmdp_huge_clear_flush_notify, that _notify suffix was called after
migrate_page_copy already run.

Andrea Arcangeli (3):
  mm: thp: fix MADV_DONTNEED vs migrate_misplaced_transhuge_page race
    condition
  mm: thp: fix mmu_notifier in migrate_misplaced_transhuge_page()
  mm: thp: relocate flush_cache_range() in
    migrate_misplaced_transhuge_page()

 mm/huge_memory.c | 14 +++++++++++++-
 mm/migrate.c     | 43 ++++++++++++++++++++++++-------------------
 2 files changed, 37 insertions(+), 20 deletions(-)
