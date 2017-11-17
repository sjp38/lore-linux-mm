Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8E66B0253
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 20:49:40 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 79so6133062ioi.10
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:49:40 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id z67si1835159itf.129.2017.11.16.17.49.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 17:49:39 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v3 2/3] mm/mempolicy: fix the check of nodemask from user
Date: Fri, 17 Nov 2017 09:37:03 +0800
Message-ID: <1510882624-44342-3-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
References: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, ak@linux.intel.com, cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, tanxiaojun@huawei.com

As Xiaojun reported the ltp of migrate_pages01 will failed on ARCH arm64
system which has 4 nodes[0...3], all have memory and CONFIG_NODES_SHIFT=2:

migrate_pages01    0  TINFO  :  test_invalid_nodes
migrate_pages01   14  TFAIL  :  migrate_pages_common.c:45: unexpected failure - returned value = 0, expected: -1
migrate_pages01   15  TFAIL  :  migrate_pages_common.c:55: call succeeded unexpectedly

In this case the test_invalid_nodes of migrate_pages01 will call:
SYSC_migrate_pages as:

migrate_pages(0, , {0x0000000000000001}, 64, , {0x0000000000000010}, 64) = 0

The new nodes specifies one or more node IDs that are greater than the
maximum supported node ID, however, the errno is not set to EINVAL as
expected.

As man pages of set_mempolicy[1], mbind[2], and migrate_pages[3] memtioned,
when nodemask specifies one or more node IDs that are greater than the
maximum supported node ID, the errno should set to EINVAL. However, get_nodes
only check whether the part of bits [BITS_PER_LONG*BITS_TO_LONGS(MAX_NUMNODES),
maxnode) is zero or not,  and remain [MAX_NUMNODES, BITS_PER_LONG*BITS_TO_LONGS(MAX_NUMNODES)
unchecked.

This patch is to check the bits of [MAX_NUMNODES, maxnode) in get_nodes to
let migrate_pages set the errno to EINVAL when nodemask specifies one or
more node IDs that are greater than the maximum supported node ID, which
follows the manpage's guide.

[1] http://man7.org/linux/man-pages/man2/set_mempolicy.2.html
[2] http://man7.org/linux/man-pages/man2/mbind.2.html
[3] http://man7.org/linux/man-pages/man2/migrate_pages.2.html

Reported-by: Tan Xiaojun <tanxiaojun@huawei.com>
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6e867a8..65df28d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1263,6 +1263,7 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
 		     unsigned long maxnode)
 {
 	unsigned long k;
+	unsigned long t;
 	unsigned long nlongs;
 	unsigned long endmask;
 
@@ -1279,11 +1280,17 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
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
@@ -1296,6 +1303,16 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
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
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
