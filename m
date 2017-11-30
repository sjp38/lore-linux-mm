Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE7296B0260
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:22 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o20so4566561wro.8
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i7si3968285wra.478.2017.11.30.14.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:21 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:18 -0800
From: akpm@linux-foundation.org
Subject: [patch 03/15] mm/mempolicy: fix the check of nodemask from user
Message-ID: <5a2082f6.7hw24yhDG2JJVZau%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, xieyisheng1@huawei.com, ak@linux.intel.com, cl@linux.com, mingo@kernel.org, n-horiguchi@ah.jp.nec.com, rientjes@google.com, salls@cs.ucsb.edu, tanxiaojun@huawei.com, vbabka@suse.cz

From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: mm/mempolicy: fix the check of nodemask from user

As Xiaojun reported the ltp of migrate_pages01 will fail on arm64 system
which has 4 nodes[0...3], all have memory and CONFIG_NODES_SHIFT=2:

migrate_pages01    0  TINFO  :  test_invalid_nodes
migrate_pages01   14  TFAIL  :  migrate_pages_common.c:45: unexpected failure - returned value = 0, expected: -1
migrate_pages01   15  TFAIL  :  migrate_pages_common.c:55: call succeeded unexpectedly

In this case the test_invalid_nodes of migrate_pages01 will call:
SYSC_migrate_pages as:

migrate_pages(0, , {0x0000000000000001}, 64, , {0x0000000000000010}, 64) = 0

The new nodes specifies one or more node IDs that are greater than the
maximum supported node ID, however, the errno is not set to EINVAL as
expected.

As man pages of set_mempolicy[1], mbind[2], and migrate_pages[3]
mentioned, when nodemask specifies one or more node IDs that are greater
than the maximum supported node ID, the errno should set to EINVAL. 
However, get_nodes only check whether the part of bits
[BITS_PER_LONG*BITS_TO_LONGS(MAX_NUMNODES), maxnode) is zero or not, and
remain [MAX_NUMNODES, BITS_PER_LONG*BITS_TO_LONGS(MAX_NUMNODES) unchecked.

This patch is to check the bits of [MAX_NUMNODES, maxnode) in get_nodes to
let migrate_pages set the errno to EINVAL when nodemask specifies one or
more node IDs that are greater than the maximum supported node ID, which
follows the manpage's guide.

[1] http://man7.org/linux/man-pages/man2/set_mempolicy.2.html
[2] http://man7.org/linux/man-pages/man2/mbind.2.html
[3] http://man7.org/linux/man-pages/man2/migrate_pages.2.html

Link: http://lkml.kernel.org/r/1510882624-44342-3-git-send-email-xieyisheng1@huawei.com
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Reported-by: Tan Xiaojun <tanxiaojun@huawei.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Chris Salls <salls@cs.ucsb.edu>
Cc: Christopher Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mempolicy.c |   23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff -puN mm/mempolicy.c~mm-mempolicy-fix-the-check-of-nodemask-from-user mm/mempolicy.c
--- a/mm/mempolicy.c~mm-mempolicy-fix-the-check-of-nodemask-from-user
+++ a/mm/mempolicy.c
@@ -1263,6 +1263,7 @@ static int get_nodes(nodemask_t *nodes,
 		     unsigned long maxnode)
 {
 	unsigned long k;
+	unsigned long t;
 	unsigned long nlongs;
 	unsigned long endmask;
 
@@ -1279,11 +1280,17 @@ static int get_nodes(nodemask_t *nodes,
 	else
 		endmask = (1UL << (maxnode % BITS_PER_LONG)) - 1;
 
-	/* When the user specified more nodes than supported just check
-	   if the non supported part is all zero. */
+	/*
+	 * When the user specified more nodes than supported just check
+	 * if the non supported part is all zero.
+	 *
+	 * If maxnode have more longs than MAX_NUMNODES, check
+	 * the bits in that area first. And then go through to
+	 * check the rest bits which equal or bigger than MAX_NUMNODES.
+	 * Otherwise, just check bits [MAX_NUMNODES, maxnode).
+	 */
 	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
 		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
-			unsigned long t;
 			if (get_user(t, nmask + k))
 				return -EFAULT;
 			if (k == nlongs - 1) {
@@ -1296,6 +1303,16 @@ static int get_nodes(nodemask_t *nodes,
 		endmask = ~0UL;
 	}
 
+	if (maxnode > MAX_NUMNODES && MAX_NUMNODES % BITS_PER_LONG != 0) {
+		unsigned long valid_mask = endmask;
+
+		valid_mask &= ~((1UL << (MAX_NUMNODES % BITS_PER_LONG)) - 1);
+		if (get_user(t, nmask + nlongs - 1))
+			return -EFAULT;
+		if (t & valid_mask)
+			return -EINVAL;
+	}
+
 	if (copy_from_user(nodes_addr(*nodes), nmask, nlongs*sizeof(unsigned long)))
 		return -EFAULT;
 	nodes_addr(*nodes)[nlongs-1] &= endmask;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
