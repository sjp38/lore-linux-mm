Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A78176B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 21:52:43 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u11so61046989qtu.10
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:52:43 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id t44si7802409qtt.350.2017.08.14.18.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 18:52:42 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 0/4] mm: hwpoison: soft-offline support for thp migration
Date: Mon, 14 Aug 2017 21:52:12 -0400
Message-Id: <20170815015216.31827-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

Hi Naoya,

Here is soft-offline support for thp migration. I need comments since it has
an interface change (Patch 2) of soft_offline_page() and
a behavior change (Patch 3) in migrate_pages(). soft_offline_page() is used
in store_soft_offline_page() from drivers/base/memory.c.

The patchset is on top of mmotm-2017-08-10-15-33.

The patchset is tested with:
1. simple madvise() call program (https://github.com/x-y-z/soft-offline-test) and
2. a local kernel change to intentionally fail allocating THPs for soft offline,
   which makes to-be-soft-offlined THPs being split by Patch 3.

Patch 1: obtain the size of a offlined page before it is offlined. The size is
used as the step value of the for-loop inside madvise_inject_error().
Originally, the for-loop used the size of offlined pages, which was OK.
But as a THP is offlined, it is split afterwards, so the page size obtained
after offlined is PAGE_SIZE instead of THP page size, which causes a THP being
offlined 512 times.

Patch 2: when offlining a THP, there are two situations, a) the THP is offlined
as a whole, or b) the THP is split and only the raw error page is offlined.
Thus, we need soft_offline_page() to tell us whether a THP is split during
offlining, which leads to a new interface parameter.

Patch 3: as Naoya suggested, if a THP fails to be offlined as a whole, we should
retry the raw error subpage. This patch implement it. This also requires
migrate_pages() not splitting a THP if migration fails for MR_MEMORY_FAILURE.

Patch 4: enable thp migration support for soft offline.

Any suggestions and comments are welcome.

Thanks.


Zi Yan (4):
  mm: madvise: read loop's step size beforehand in
    madvise_inject_error(), prepare for THP support.
  mm: soft-offline: Change soft_offline_page() interface to tell if the
    page is split or not.
  mm: soft-offline: retry to split and soft-offline the raw error if the
    original THP offlining fails.
  mm: hwpoison: soft offline supports thp migration

 drivers/base/memory.c |   2 +-
 include/linux/mm.h    |   2 +-
 mm/madvise.c          |  24 ++++++++++--
 mm/memory-failure.c   | 103 +++++++++++++++++++++++++++++---------------------
 mm/migrate.c          |  16 ++++++++
 5 files changed, 97 insertions(+), 50 deletions(-)

-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
