Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8865A6B0299
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:24:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w132so75383597ita.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:24:05 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id l195si231041ioe.182.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:05 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 28/29] radix-tree: Create all_tag_set
Date: Wed, 16 Nov 2016 16:16:59 -0800
Message-Id: <1479341856-30320-35-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

all_tag_set() sets every tag on a node.  This is useful for the IDR code
when we're creating new nodes which contain only free slots.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c8ef657..e063ca2 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -22,6 +22,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#include <linux/bitmap.h>
+#include <linux/bitops.h>
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
@@ -33,7 +35,6 @@
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/string.h>
-#include <linux/bitops.h>
 #include <linux/rcupdate.h>
 #include <linux/preempt.h>		/* in_interrupt() */
 
@@ -184,6 +185,11 @@ static inline int any_tag_set(struct radix_tree_node *node, unsigned int tag)
 	return 0;
 }
 
+static inline void all_tag_set(struct radix_tree_node *node, unsigned int tag)
+{
+	bitmap_fill(node->tags[tag], RADIX_TREE_MAP_SIZE);
+}
+
 /**
  * radix_tree_find_next_bit - find the next set bit in a memory region
  *
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
