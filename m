Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 526436B0260
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:26:14 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id f73so3129991ioe.1
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:26:14 -0800 (PST)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id b98si2536724itd.13.2016.12.13.12.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:26:13 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 0/5] Additional radix tree patches for 4.10
Date: Tue, 13 Dec 2016 14:21:27 -0800
Message-Id: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Tejun Heo <tj@kernel.org>

From: Matthew Wilcox <mawilcox@microsoft.com>

Hi Andrew,

One bug has popped up in testing which is reasonably hard to hit (fixed
by patch 2 in this series).  I needed to change the test suite to be
able to catch the bug in action.  The test suite was returning freed
memory to glibc's malloc, but we have to keep a cache of objects in
order to notice that we freed something non-zero and then neglected to
initialise it back to zero upon reallocation.

Please drop the existing "reimplement IDR and IDA using the radix tree"
patch from your queue and replace it with these five patches.  I'd like
to see the first four patches head to Linus along with the rest of the
radix tree patches, and we can continue with the plan of holding patch 5
until 4.11.

I took your suggestion of moving as much as possible of the IDA and
IDR functionality back to idr.c.  That prompted creation of some nicer
APIs, such as radix_tree_iter_delete() and radix_tree_iter_lookup().

There are also some good bugs fixed in this revision, such as:
 - returning the correct error value from ida_get_new_above() if we run
   out of memory,
 - handling attempts to allocate from a full IDA correctly.
 - Correctly handle deleting the only entry at root with
   radix_tree_iter_delete()
I wrote test cases for all these situations, so they shouldn't
regress again.

Matthew Wilcox (5):
  radix tree test suite: Cache recently freed objects
  radix-tree: Ensure counts are initialised
  radix tree test suite: Add new tag check
  radix tree test suite: Delete unused rcupdate.c
  Reimplement IDR and IDA using the radix tree

 include/linux/idr.h                     |  138 ++--
 include/linux/radix-tree.h              |   53 +-
 init/main.c                             |    3 +-
 lib/idr.c                               | 1144 ++++++-------------------------
 lib/radix-tree.c                        |  358 ++++++++--
 tools/include/linux/spinlock.h          |    4 +
 tools/testing/radix-tree/.gitignore     |    1 +
 tools/testing/radix-tree/Makefile       |   10 +-
 tools/testing/radix-tree/idr-test.c     |  200 ++++++
 tools/testing/radix-tree/linux.c        |   48 +-
 tools/testing/radix-tree/linux/export.h |    1 +
 tools/testing/radix-tree/linux/gfp.h    |    8 +-
 tools/testing/radix-tree/linux/idr.h    |    1 +
 tools/testing/radix-tree/linux/kernel.h |    2 +
 tools/testing/radix-tree/linux/slab.h   |    5 -
 tools/testing/radix-tree/main.c         |    6 +
 tools/testing/radix-tree/multiorder.c   |   45 +-
 tools/testing/radix-tree/rcupdate.c     |   86 ---
 tools/testing/radix-tree/tag_check.c    |    3 +
 tools/testing/radix-tree/test.h         |    2 +
 20 files changed, 914 insertions(+), 1204 deletions(-)
 create mode 100644 tools/include/linux/spinlock.h
 create mode 100644 tools/testing/radix-tree/idr-test.c
 create mode 100644 tools/testing/radix-tree/linux/idr.h
 delete mode 100644 tools/testing/radix-tree/rcupdate.c

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
