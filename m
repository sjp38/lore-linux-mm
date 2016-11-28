Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8F156B0293
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:57:54 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j92so262098313ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:57:54 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id q7si19932006itb.45.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 17/33] radix-tree: Make radix_tree_find_next_bit more useful
Date: Mon, 28 Nov 2016 13:50:55 -0800
Message-Id: <1480369871-5271-52-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>

From: Matthew Wilcox <willy@linux.intel.com>

Since this function is specialised to the radix tree, pass in the node
and tag to calculate the address of the bitmap in radix_tree_find_next_bit()
instead of the caller.  Likewise, there is no need to pass in the size of
the bitmap.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 lib/radix-tree.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c72da89..01ed70b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -190,13 +190,12 @@ static inline int any_tag_set(struct radix_tree_node *node, unsigned int tag)
  * Returns next bit offset, or size if nothing found.
  */
 static __always_inline unsigned long
-radix_tree_find_next_bit(const unsigned long *addr,
-			 unsigned long size, unsigned long offset)
+radix_tree_find_next_bit(struct radix_tree_node *node, unsigned int tag,
+			 unsigned long offset)
 {
-	if (!__builtin_constant_p(size))
-		return find_next_bit(addr, size, offset);
+	const unsigned long *addr = node->tags[tag];
 
-	if (offset < size) {
+	if (offset < RADIX_TREE_MAP_SIZE) {
 		unsigned long tmp;
 
 		addr += offset / BITS_PER_LONG;
@@ -204,14 +203,14 @@ radix_tree_find_next_bit(const unsigned long *addr,
 		if (tmp)
 			return __ffs(tmp) + offset;
 		offset = (offset + BITS_PER_LONG) & ~(BITS_PER_LONG - 1);
-		while (offset < size) {
+		while (offset < RADIX_TREE_MAP_SIZE) {
 			tmp = *++addr;
 			if (tmp)
 				return __ffs(tmp) + offset;
 			offset += BITS_PER_LONG;
 		}
 	}
-	return size;
+	return RADIX_TREE_MAP_SIZE;
 }
 
 #ifndef __KERNEL__
@@ -1159,9 +1158,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 				return NULL;
 
 			if (flags & RADIX_TREE_ITER_TAGGED)
-				offset = radix_tree_find_next_bit(
-						node->tags[tag],
-						RADIX_TREE_MAP_SIZE,
+				offset = radix_tree_find_next_bit(node, tag,
 						offset + 1);
 			else
 				while (++offset	< RADIX_TREE_MAP_SIZE) {
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
