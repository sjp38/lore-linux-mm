Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 257176B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 14:07:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so25296891wme.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 11:07:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w133si10076757wmf.59.2016.11.07.11.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 11:07:56 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/6] mm: workingset: radix tree subtleties & single-page file refaults
Date: Mon,  7 Nov 2016 14:07:35 -0500
Message-Id: <20161107190741.3619-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This is another revision of the radix tree / workingset patches based
on feedback from Linus and Jan. Thanks for your input.

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

 arch/s390/mm/gmap.c                   |  2 +-
 drivers/sh/intc/virq.c                |  2 +-
 fs/dax.c                              |  9 ++--
 include/linux/radix-tree.h            | 30 ++++--------
 include/linux/swap.h                  | 32 -------------
 lib/radix-tree.c                      | 84 +++++++++++++++++++++++++++++++--
 mm/filemap.c                          | 41 +++++-----------
 mm/khugepaged.c                       |  8 ++--
 mm/migrate.c                          |  4 +-
 mm/shmem.c                            |  8 ++--
 mm/truncate.c                         |  6 +--
 mm/workingset.c                       | 25 ++++++----
 tools/testing/radix-tree/multiorder.c |  2 +-
 13 files changed, 140 insertions(+), 113 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
