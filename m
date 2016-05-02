Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC2666B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 00:13:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so274710143pac.1
        for <linux-mm@kvack.org>; Sun, 01 May 2016 21:13:27 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id dy1si16703776pab.117.2016.05.01.21.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 May 2016 21:13:27 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id r5so70428541pag.1
        for <linux-mm@kvack.org>; Sun, 01 May 2016 21:13:26 -0700 (PDT)
Date: Sun, 1 May 2016 21:13:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] radix-tree: rewrite radix_tree_locate_item fix
Message-ID: <alpine.LSU.2.11.1605012108490.1166@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

radix_tree_locate_item() is often returning the wrong index, causing
swapoff of shmem to hang because it cannot find the swap entry there.
__locate()'s use of base is bogus, it adds an offset twice into index.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Fix to radix-tree-rewrite-radix_tree_locate_item.patch

 lib/radix-tree.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- 4.6-rc5-mm1/lib/radix-tree.c	2016-04-30 22:55:06.067184898 -0700
+++ linux/lib/radix-tree.c	2016-05-01 18:52:06.668085420 -0700
@@ -1254,15 +1254,14 @@ struct locate_info {
 static unsigned long __locate(struct radix_tree_node *slot, void *item,
 			      unsigned long index, struct locate_info *info)
 {
-	unsigned long base, i;
+	unsigned long i;
 
 	do {
 		unsigned int shift = slot->shift;
-		base = index & ~((1UL << shift) - 1);
 
 		for (i = (index >> shift) & RADIX_TREE_MAP_MASK;
 		     i < RADIX_TREE_MAP_SIZE;
-		     i++, index = base + (i << shift)) {
+		     i++, index += (1UL << shift)) {
 			struct radix_tree_node *node =
 					rcu_dereference_raw(slot->slots[i]);
 			if (node == RADIX_TREE_RETRY)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
