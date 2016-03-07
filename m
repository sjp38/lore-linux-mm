Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 27C88828E4
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 06:57:24 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id x188so55145206pfb.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 03:57:24 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id gr1si2726551pac.52.2016.03.07.03.57.22
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 03:57:22 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/4] thp: simplify freeze_page() and unfreeze_page()
Date: Mon,  7 Mar 2016 14:57:14 +0300
Message-Id: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patchset rewrites freeze_page() and unfreeze_page() using try_to_unmap()
and remove_migration_ptes(). Result is much simpler, but somewhat slower.

Comparing to v1, I've recovered most of performance for PMD-mapped THPs
with few shortcuts.

Migration 8GiB worth of PMD-mapped THP:

Baseline	20.21 A+- 0.393
Patched		20.73 A+- 0.082
Slowdown	1.03x

It's 3% slower, comparing to 14% in v1. I don't it should be a stopper.

Splitting of PTE-mapped pages slowed more. But this is not that often
case.

Migration 8GiB worth of PMD-mapped THP:

Baseline	20.39 A+- 0.225
Patched		22.43 A+- 0.496
Slowdown	1.10x

Please, consider applying.

Kirill A. Shutemov (4):
  rmap: introduce rmap_walk_locked()
  rmap: extend try_to_unmap() to be usable by split_huge_page()
  mm: make remove_migration_ptes() beyond mm/migration.c
  thp: rewrite freeze_page()/unfreeze_page() with generic rmap walkers

 include/linux/huge_mm.h |  13 ++-
 include/linux/rmap.h    |   6 ++
 mm/huge_memory.c        | 204 +++++++-----------------------------------------
 mm/migrate.c            |  15 ++--
 mm/rmap.c               |  70 +++++++++++++----
 5 files changed, 106 insertions(+), 202 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
