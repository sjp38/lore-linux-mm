Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 224336B0098
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 12:13:52 -0500 (EST)
Received: by pvc30 with SMTP id 30so143145pvc.14
        for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:13:49 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 0/5] Change page reference hanlding semantic of page cache
Date: Sat, 18 Dec 2010 02:13:35 +0900
Message-Id: <cover.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

I copy description of 1/5.

Now we add page reference on add_to_page_cache but doesn't drop it
in remove_from_page_cache. Such asymmetric makes confusing about
page reference so that caller should notice it and comment why they
release page reference. It's not good API.

Long time ago, Hugh tried it[1] but gave up of reason which
reiser4's drop_page had to unlock the page between removing it from
page cache and doing the page_cache_release. But now the situation is
changed. I think at least things in current mainline doesn't have any
obstacles. The problem is fs or somethings out of mainline.
If it has done such thing like reiser4, this patch could be a problem.

Do anyone know the such things? Do we care about things out of mainline?

[1] http://lkml.org/lkml/2004/10/24/140

Minchan Kim (5):
  drop page reference on remove_from_page_cache
  fuse: Remove unnecessary page release
  tlbfs: Remove unnecessary page release
  swap: Remove unnecessary page release
  truncate: Remove unnecessary page release

 fs/fuse/dev.c        |    1 -
 fs/hugetlbfs/inode.c |    1 -
 mm/filemap.c         |   12 ++++++++++++
 mm/shmem.c           |    1 -
 mm/truncate.c        |    1 -
 5 files changed, 12 insertions(+), 4 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
