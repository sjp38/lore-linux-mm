Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7578B6B02B4
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 17:41:13 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p10so34345901pgr.6
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 14:41:13 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h63si2587226pfb.82.2017.07.18.14.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 14:41:12 -0700 (PDT)
From: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>
Subject: [PATCH v1] mm/mempolicy.c: Fix get_nodes() off-by-one error.
Date: Tue, 18 Jul 2017 08:39:24 -0500
Message-Id: <1500385164-11062-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>

set_mempolicy() and mbind() take as argument a pointer to a bit mask
(nodemask) and the number of bits in the mask the kernel will use
(maxnode), among others.  For instace on a system with 2 NUMA nodes valid
masks are: 0b00, 0b01, 0b10 and 0b11 it's clear maxnode=2, however an
off-by-one error in get_nodes() the function that copies the node mask from
user space requires users to pass maxnode = 3 in this example and maxnode =
actual_maxnode + 1 in the general case. This patch fixes such error.

Signed-off-by: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>
---
 mm/mempolicy.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d911fa5..5274e9d2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1208,11 +1208,10 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
 	unsigned long nlongs;
 	unsigned long endmask;
 
-	--maxnode;
 	nodes_clear(*nodes);
-	if (maxnode == 0 || !nmask)
+	if (maxnode == 1 || !nmask)
 		return 0;
-	if (maxnode > PAGE_SIZE*BITS_PER_BYTE)
+	if (maxnode - 1 > PAGE_SIZE * BITS_PER_BYTE)
 		return -EINVAL;
 
 	nlongs = BITS_TO_LONGS(maxnode);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
