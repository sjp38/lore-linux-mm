Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8B77C6B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:11:19 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so8229851pab.3
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:11:19 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so8024600pbc.15
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:11:16 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:11:12 -0700
From: Ning Qu <quning@gmail.com>
Subject: [PATCH 00/12] Transparent huge page cache support on tmpfs
Message-ID: <20131015001112.GA3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Transparent huge page support on tmpfs.

Please review.

Intro
-----
The goal of the project is to enable transparent huge page support on
tmpfs. 

The whole patchset is based on Kirill's latest patchset about Transparent
huge page cache v6. As the link below:

https://lkml.org/lkml/2013/9/23/230

To further proof that the proposed changes are functional we try enable
this feature for a more complex file system tmpfs besides ramfs. tmpfs
comes with swap support which make is more usable.

Design overview
---------------

We share the exact same design from Kirill's work. However, due to the 
complexity of tmpfs, we do a lot of refactoring on the implementation.


Known problem
---------------

We do try to make it work with swapping, but currently there are still
some problem with it. I am debbugging it.

However, it would be great to have more opinions about the design in
the current patchset and where we should be heading to.


Ning Qu (12):
  mm, thp, tmpfs: add function to alloc huge page for tmpfs
  mm, thp, tmpfs: support to add huge page into page cache for tmpfs
  mm, thp, tmpfs: handle huge page cases in shmem_getpage_gfp
  mm, thp, tmpfs: split huge page when moving from page cache to swap
  mm, thp, tmpfs: request huge page in shm_fault when needed
  mm, thp, tmpfs: initial support for huge page in write_begin/write_end
    in tmpfs
  mm, thp, tmpfs: handle huge page in shmem_undo_range for truncate
  mm, thp, tmpfs: huge page support in do_shmem_file_read
  mm, thp, tmpfs: huge page support in shmem_fallocate
  mm, thp, tmpfs: only alloc small pages in shmem_file_splice_read
  mm, thp, tmpfs: enable thp page cache in tmpfs
  mm, thp, tmpfs: misc fixes for thp tmpfs

 mm/Kconfig       |   4 +-
 mm/huge_memory.c |  27 +++
 mm/shmem.c       | 511 +++++++++++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 467 insertions(+), 75 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
