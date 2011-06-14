Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 01ABB6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:41:17 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p5EAfF7K008070
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:41:15 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz21.hot.corp.google.com with ESMTP id p5EAf6KO028531
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:41:09 -0700
Received: by pzk9 with SMTP id 9so2562789pzk.19
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:41:06 -0700 (PDT)
Date: Tue, 14 Jun 2011 03:40:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/12] tmpfs: convert from old swap vector to radix tree
Message-ID: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's my third patchset for mmotm, completing the series.
Based on 3.0-rc3 plus the 14 in June 5th "mm: tmpfs and trunc changes"
plus the 7 in June 9th "tmpfs: simplify by splice instead of readpage",
which were in preparation for it.

I'm not sure who would really be interested in it: I'm Cc'ing this
header mail as notification to a number of people who might care;
but reluctant to spam you all with the 14+7+12 patches themselves,
I hope you can pick them up from the list if you want (or ask me).

What's it about?  Extending tmpfs to MAX_LFS_FILESIZE by abandoning
its peculiar swap vector, instead keeping a file's swap entries in
the same radix tree as its struct page pointers: thus saving memory,
and simplifying its code and locking.

 1/12 radix_tree: exceptional entries and indices
 2/12 mm: let swap use exceptional entries
 3/12 tmpfs: demolish old swap vector support
 4/12 tmpfs: miscellaneous trivial cleanups
 5/12 tmpfs: copy truncate_inode_pages_range
 6/12 tmpfs: convert shmem_truncate_range to radix-swap
 7/12 tmpfs: convert shmem_unuse_inode to radix-swap
 8/12 tmpfs: convert shmem_getpage_gfp to radix-swap
 9/12 tmpfs: convert mem_cgroup shmem to radix-swap
10/12 tmpfs: convert shmem_writepage and enable swap
11/12 tmpfs: use kmemdup for short symlinks
12/12 mm: a few small updates for radix-swap

 fs/stack.c                 |    5 
 include/linux/memcontrol.h |    8 
 include/linux/radix-tree.h |   36 
 include/linux/shmem_fs.h   |   17 
 include/linux/swapops.h    |   23 
 init/main.c                |    2 
 lib/radix-tree.c           |   29 
 mm/filemap.c               |   74 -
 mm/memcontrol.c            |   66 -
 mm/mincore.c               |   10 
 mm/shmem.c                 | 1515 +++++++++++------------------------
 mm/swapfile.c              |   20 
 mm/truncate.c              |    8 
 13 files changed, 669 insertions(+), 1144 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
