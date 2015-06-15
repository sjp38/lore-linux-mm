Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id E23AA6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 03:51:06 -0400 (EDT)
Received: by lacny3 with SMTP id ny3so32326498lac.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:06 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id pa8si9843465lbb.88.2015.06.15.00.51.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 00:51:04 -0700 (PDT)
Received: by labbc20 with SMTP id bc20so16037501lab.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:03 -0700 (PDT)
Subject: [PATCH RFC v0 0/6] mm: proof-of-concept memory compaction without
 isolation
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 10:50:59 +0300
Message-ID: <20150615073926.18112.59207.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is incomplete implementation of non-isolating memory migration and
compaction. It's alive!

The main reason -- it can preserve lru order during compaction.


Also it makes implementation of migration for various types of pages: zram,
balloon, ptes, kernel stacks [ Why not? I've already migrated them accidentally
and kernel have crashed in very funny places ] much easier: owner just have to
set page->mappingw with valid method a_ops->migratepage.

---

Konstantin Khlebnikov (6):
      pagevec: segmented page vectors
      mm/migrate: move putback of old page out of unmap_and_move
      mm/cma: repalce reclaim_clean_pages_from_list with try_to_reclaim_page
      mm/migrate: page migration without page isolation
      mm/compaction: use migration without isolation
      mm/migrate: preserve lru order if possible


 include/linux/migrate.h           |    4 +
 include/linux/mm.h                |    1 
 include/linux/pagevec.h           |   48 ++++++++-
 include/trace/events/compaction.h |   12 +-
 mm/compaction.c                   |  205 +++++++++++++++++++++----------------
 mm/filemap.c                      |   20 ++++
 mm/internal.h                     |   12 +-
 mm/migrate.c                      |  141 +++++++++++++++++++++----
 mm/page_alloc.c                   |   35 ++++--
 mm/swap.c                         |   69 ++++++++++++
 mm/vmscan.c                       |   42 +-------
 11 files changed, 410 insertions(+), 179 deletions(-)

--
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
