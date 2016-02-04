Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 11EA64403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 03:41:34 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id dx2so26889816lbd.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:41:34 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id pm3si6632059lbc.99.2016.02.04.00.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 00:41:32 -0800 (PST)
Received: by mail-lb0-x230.google.com with SMTP id x4so27401591lbm.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:41:32 -0800 (PST)
Subject: [PATCH] radix-tree: fix oops after radix_tree_iter_retry
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Thu, 04 Feb 2016 11:41:27 +0300
Message-ID: <145457528789.31321.4441662473067711123.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ohad Ben-Cohen <ohad@wizery.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, stable@vger.kernel.org

Helper radix_tree_iter_retry resets next_index to the current index.
In following radix_tree_next_slot current chunk size becomes zero.
This isn't checked and it tries to dereference null pointer in slot.

Tagged iterator is fine because retry happens only at slot 0 where
tag bitmask in iter->tags is filled with single bit.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Fixes: 46437f9a554f ("radix-tree: fix race in gang lookup")
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Ohad Ben-Cohen <ohad@wizery.com>
Cc: <stable@vger.kernel.org>
---
 include/linux/radix-tree.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 00b17c526c1f..f54be7082207 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -400,7 +400,7 @@ void **radix_tree_iter_retry(struct radix_tree_iter *iter)
  * @iter:	pointer to radix tree iterator
  * Returns:	current chunk size
  */
-static __always_inline unsigned
+static __always_inline long
 radix_tree_chunk_size(struct radix_tree_iter *iter)
 {
 	return iter->next_index - iter->index;
@@ -434,9 +434,9 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 			return slot + offset + 1;
 		}
 	} else {
-		unsigned size = radix_tree_chunk_size(iter) - 1;
+		long size = radix_tree_chunk_size(iter);
 
-		while (size--) {
+		while (--size > 0) {
 			slot++;
 			iter->index++;
 			if (likely(*slot))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
