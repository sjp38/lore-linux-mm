Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B80836B008A
	for <linux-mm@kvack.org>; Sun,  2 Jan 2011 10:44:53 -0500 (EST)
Received: by pzk27 with SMTP id 27so3325751pzk.14
        for <linux-mm@kvack.org>; Sun, 02 Jan 2011 07:44:51 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 0/7] Change page reference handling semantic of page cache
Date: Mon,  3 Jan 2011 00:44:29 +0900
Message-Id: <cover.1293982522.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Now we increases page reference on add_to_page_cache but doesn't decrease it
in remove_from_page_cache. Such asymmetric makes confusing about
page reference so that caller should notice it and comment why they
release page reference. It's not good API.

Long time ago, Hugh tried it[1] but gave up of reason which
reiser4's drop_page had to unlock the page between removing it from
page cache and doing the page_cache_release. But now the situation is
changed. I think at least things in current mainline doesn't have any
obstacles. The problem is fs or somethings out of mainline.
If it has done such thing like reiser4, this patch could be a problem but
they found it when compile time since we remove remove_from_page_cache.

[1] http://lkml.org/lkml/2004/10/24/140

The series configuration is following as. 

[1/7] : This patch introduces new API delete_from_page_cache.
[2,3,4,5/7] : Change remove_from_page_cache with delete_from_page_cache.
Intentionally I divide patch per file since someone might have a concern 
about releasing page reference of delete_from_page_cache in 
somecase (ex, truncate.c)
[6/7] : Remove old API so out of fs can meet compile error when build time
and can notice it.
[7/7] : Change __remove_from_page_cache with __delete_from_page_cache, too.
In this time, I made all-in-one patch because it doesn't change old behavior
so it has no concern. Just clean up patch.

from v1
 - Add Acked-by
 - rebase on mmotm-12-23
  
Minchan Kim (7):
  [1/7] Introduce delete_from_page_cache
  [2/7] fuse: Change remove_from_page_cache
  [3/7] tlbfs: Change remove_from_page_cache
  [4/7] swap: Change remove_from_page_cache
  [5/7] truncate: Change remove_from_page_cache
  [6/7] Good bye remove_from_page_cache
  [7/7] Change __remove_from_page_cache

 fs/fuse/dev.c           |    3 +--
 fs/hugetlbfs/inode.c    |    3 +--
 include/linux/pagemap.h |    4 ++--
 mm/filemap.c            |   22 +++++++++++++++++-----
 mm/memory-failure.c     |    2 +-
 mm/shmem.c              |    3 +--
 mm/truncate.c           |    7 +++----
 mm/vmscan.c             |    2 +-
 8 files changed, 27 insertions(+), 19 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
