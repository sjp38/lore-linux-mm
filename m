Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01A596B026B
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:19:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c20so131092632pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:19:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o81si7710341pfa.174.2016.04.14.07.19.16
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:19:16 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 10/29] radix-tree: Fix sibling entry insertion
Date: Thu, 14 Apr 2016 10:16:31 -0400
Message-Id: <1460643410-30196-11-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

The subtraction was the wrong way round, leading to undefined behaviour
(shift by an amount larger than the size of the type).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 585965a..c0366d1 100644
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
