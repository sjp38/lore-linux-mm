Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4504B6B033B
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:11:52 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so56955953wmd.6
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:11:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b124si4026829wmg.77.2016.11.17.11.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:11:51 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/9] mm: workingset: radix tree subtleties & single-page file refaults v3
Date: Thu, 17 Nov 2016 14:11:29 -0500
Message-Id: <20161117191138.22769-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This is another revision of the radix tree / workingset patches based
on feedback from Jan and Kirill. Thanks for your input.

This is a follow-up to d3798ae8c6f3 ("mm: filemap: don't plant shadow
entries without radix tree node"). That patch fixed an issue that was
caused mainly by the page cache sneaking special shadow page entries
into the radix tree and relying on subtleties in the radix tree code
to make that work. The fix also had to stop tracking refaults for
single-page files because shadow pages stored as direct pointers in
radix_tree_root->rnode weren't properly handled during tree extension.

These patches make the radix tree code explicitely support and track
such special entries, to eliminate the subtleties and to restore the
thrash detection for single-page files.

Changes since v2:
- Shadow entry accounting and radix tree node tracking are fully gone
  from the page cache code, making it much simpler and robust. Counts
  are kept natively in the radix tree, node tracking is done from one
  simple callback function in the workingset code. Thanks Jan.
- One more radix tree fix in khugepaged's new shmem collapsing code.
  Thanks Kirill and Jan.

 arch/s390/mm/gmap.c                   |   2 +-
 drivers/sh/intc/virq.c                |   2 +-
 fs/dax.c                              |  10 +-
 include/linux/radix-tree.h            |  34 ++--
 include/linux/swap.h                  |  34 +---
 lib/radix-tree.c                      | 297 ++++++++++++++++++++------------
 mm/filemap.c                          |  63 +------
 mm/khugepaged.c                       |  16 +-
 mm/migrate.c                          |   4 +-
 mm/shmem.c                            |   9 +-
 mm/truncate.c                         |  21 +--
 mm/workingset.c                       |  70 ++++++--
 tools/testing/radix-tree/multiorder.c |   2 +-
 13 files changed, 292 insertions(+), 272 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
