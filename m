Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 72A266B0075
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:40 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 15:19:39 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7E2F238C8062
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:36 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6TJJb6M150272
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6TJJbvk027534
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 16:19:37 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 0/5] Add rbtree postorder iteration functions, runtime tests, and update zswap to use
Date: Mon, 29 Jul 2013 12:19:25 -0700
Message-Id: <1375125570-9401-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Postorder iteration yields all of a node's children prior to yielding the node
itself, and this particular implementation also avoids examining the leaf links
in a node after that node has been yielded.

In what I expect will be its most common usage, postorder iteration allows the
deletion of every node in an rbtree without modifying the rbtree nodes (no
_requirement_ that they be nulled) while avoiding referencing child nodes after
they have been "deleted" (most commonly, freed).

I have only updated zswap to use this functionality at this point, but numerous
bits of code (most notably in the filesystem drivers) use a hand rolled
postorder iteration that NULLs child links as it traverses the tree. Each of
those instances could be replaced with this common implementation.

1 & 2 add rbtree postorder iteration functions.
3 adds testing of the iteration to the rbtree runtime tests
4 allows building the rbtree runtime tests as builtins
5 updates zswap.

--
since v1:
	- spacing
	- s/it's/its/
	- remove now unused var in zswap code.
	- Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>


Cody P Schafer (5):
  rbtree: add postorder iteration functions
  rbtree: add rbtree_postorder_for_each_entry_safe() helper
  rbtree_test: add test for postorder iteration
  rbtree: allow tests to run as builtin
  mm/zswap: use postorder iteration when destroying rbtree

 include/linux/rbtree.h | 22 ++++++++++++++++++++++
 lib/Kconfig.debug      |  2 +-
 lib/rbtree.c           | 40 ++++++++++++++++++++++++++++++++++++++++
 lib/rbtree_test.c      | 12 ++++++++++++
 mm/zswap.c             | 16 ++--------------
 5 files changed, 77 insertions(+), 15 deletions(-)

-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
