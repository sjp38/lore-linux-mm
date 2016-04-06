Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3548A6B0264
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:06 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fe3so40462450pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:06 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o68si6894186pfj.173.2016.04.06.14.21.52
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 10/30] radix-tree: Fix sibling entry insertion
Date: Wed,  6 Apr 2016 17:21:19 -0400
Message-Id: <1459977699-2349-11-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

The subtraction was the wrong way round, leading to undefined behaviour
(shift by an amount larger than the size of the type).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 40343f28a705..42a0492b2ba2 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -526,8 +526,8 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 	/* Insert pointers to the canonical entry */
-	if ((shift - order) > 0) {
-		int i, n = 1 << (shift - order);
+	if (order > shift) {
+		int i, n = 1 << (order - shift);
 		offset = offset & ~(n - 1);
 		slot = ptr_to_indirect(&node->slots[offset]);
 		for (i = 0; i < n; i++) {
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
