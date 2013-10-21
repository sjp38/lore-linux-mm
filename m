Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 355596B034A
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:46:04 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id jt11so1651912pbb.29
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:46:03 -0700 (PDT)
Received: from psmtp.com ([74.125.245.172])
        by mx.google.com with SMTP id gw3si10193058pac.317.2013.10.21.14.46.02
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:46:03 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so9177972pde.37
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:46:01 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:45:57 -0700
From: Ning Qu <quning@gmail.com>
Subject: [PATCHv2 00/13] Transparent huge page cache support on tmpfs
Message-ID: <20131021214557.GA29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

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

Changes since v1
---------------

* extract common code from add_to_page_cache_locked, so most of the
function could be shared by shmem
* remove all the ifdef for thp page cache as it's not necessary
* completely rewrite shmem_writepage to handle huge page correctly
* fix the problem about when to split huge page in shmem_fault 
* leave the GFP_MOVABLE flags untouched, from the current code,
seems the migration code should have splitted the huge page before
migration.

Known problem
---------------

We do try to make it work with swapping, but currently there are still
some problem with it. Things are getting better with rewriting the 
shmem_wrigepage logic. However, it is still crashing after running into
swapping for a whileI, I am debbugging it.

It would be great to have more opinions about the design in the current
patchset and where we should be heading.

Ning Qu (13):
  mm, thp: extract the common code from add_to_page_cache_locked
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

 include/linux/huge_mm.h |   2 +
 include/linux/pagemap.h |   2 +
 mm/Kconfig              |   4 +-
 mm/filemap.c            |  91 ++++++---
 mm/huge_memory.c        |  27 +++
 mm/shmem.c              | 521 +++++++++++++++++++++++++++++++++++++++---------
 6 files changed, 522 insertions(+), 125 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
