Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 86D076B0034
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:19 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 15:14:18 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0917438C8045
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:14 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6QLEEMS185216
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:15 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6QLEEmb006603
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 15:14:14 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 0/5] Add rbtree postorder iteration functions, runtime tests, and update zswap to use.
Date: Fri, 26 Jul 2013 14:13:38 -0700
Message-Id: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Postorder iteration yields all of a node's children prior to yielding the node
itself, and this particular implementation also avoids examining the leaf links
in a node after that node has been yielded.

In what I expect will be it's most common usage, postorder iteration allows the
deletion of every node in an rbtree without modifying the rbtree nodes (no
_requirement_ that they be nulled) while avoiding referencing child nodes after
they have been "deleted" (most commonly, freed).

I have only updated zswap to use this functionality at this point, but numerous
bits of code (most notably in the filesystem drivers) use a hand rolled
postorder iteration that NULLs child links as it traverses the tree. Each of
those instances could be replaced with this common implementation.

Cody P Schafer (5):
  rbtree: add postorder iteration functions.
  rbtree: add rbtree_postorder_for_each_entry_safe() helper.
  rbtree_test: add test for postorder iteration.
  rbtree: allow tests to run as builtin
  mm/zswap: use postorder iteration when destroying rbtree

 include/linux/rbtree.h | 21 +++++++++++++++++++++
 lib/Kconfig.debug      |  2 +-
 lib/rbtree.c           | 40 ++++++++++++++++++++++++++++++++++++++++
 lib/rbtree_test.c      | 12 ++++++++++++
 mm/zswap.c             | 15 ++-------------
 5 files changed, 76 insertions(+), 14 deletions(-)

-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
