Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 271496B026F
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:03:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m186so228418597ioa.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:03:36 -0700 (PDT)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id d22si3959619iof.82.2016.09.22.10.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 10:03:35 -0700 (PDT)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 1/2] radix tree test suite: Test radix_tree_replace_slot() for multiorder entries
Date: Thu, 22 Sep 2016 11:53:34 -0700
Message-Id: <1474570415-14938-2-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

When we replace a multiorder entry, check that all indices reflect the
new value.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/multiorder.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 39d9b95..05d7bc4 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -124,6 +124,8 @@ static void multiorder_check(unsigned long index, int order)
 	unsigned long i;
 	unsigned long min = index & ~((1UL << order) - 1);
 	unsigned long max = min + (1UL << order);
+	void **slot;
+	struct item *item2 = item_create(min);
 	RADIX_TREE(tree, GFP_KERNEL);
 
 	printf("Multiorder index %ld, order %d\n", index, order);
@@ -139,13 +141,19 @@ static void multiorder_check(unsigned long index, int order)
 		item_check_absent(&tree, i);
 	for (i = max; i < 2*max; i++)
 		item_check_absent(&tree, i);
+	for (i = min; i < max; i++)
+		assert(radix_tree_insert(&tree, i, item2) == -EEXIST);
+
+	slot = radix_tree_lookup_slot(&tree, index);
+	free(*slot);
+	radix_tree_replace_slot(slot, item2);
 	for (i = min; i < max; i++) {
-		static void *entry = (void *)
-					(0xA0 | RADIX_TREE_EXCEPTIONAL_ENTRY);
-		assert(radix_tree_insert(&tree, i, entry) == -EEXIST);
+		struct item *item = item_lookup(&tree, i);
+		assert(item != 0);
+		assert(item->index == min);
 	}
 
-	assert(item_delete(&tree, index) != 0);
+	assert(item_delete(&tree, min) != 0);
 
 	for (i = 0; i < 2*max; i++)
 		item_check_absent(&tree, i);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
