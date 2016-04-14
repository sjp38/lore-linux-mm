Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 49FCC6B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:19:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so131382457pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:19:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o81si7710341pfa.174.2016.04.14.07.19.15
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:19:15 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 04/29] radix tree test suite: Allow testing other fan-out values
Date: Thu, 14 Apr 2016 10:16:25 -0400
Message-Id: <1460643410-30196-5-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

The defines in regression2.c are already in radix-tree.h and duplicating
them in the test case makes experimenting with other values for the
fan-out harder than necessary.  Allow the user of the radix tree to decide
what the fan-out should be rather than fixing it to 8 for non-kernel uses.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h              | 4 +---
 tools/testing/radix-tree/linux/kernel.h | 2 ++
 tools/testing/radix-tree/regression2.c  | 7 -------
 3 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 83f708e..5ce5a1e 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -70,10 +70,8 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 
 #define RADIX_TREE_MAX_TAGS 3
 
-#ifdef __KERNEL__
+#ifndef RADIX_TREE_MAP_SHIFT
 #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
-#else
-#define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
 #endif
 
 #define RADIX_TREE_MAP_SIZE	(1UL << RADIX_TREE_MAP_SHIFT)
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 76a88f3..31fe2c77 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -12,6 +12,8 @@
 #define CONFIG_SHMEM
 #define CONFIG_SWAP
 
+#define RADIX_TREE_MAP_SHIFT	3
+
 #ifndef NULL
 #define NULL	0
 #endif
diff --git a/tools/testing/radix-tree/regression2.c b/tools/testing/radix-tree/regression2.c
index 5d2fa28..63bf347 100644
--- a/tools/testing/radix-tree/regression2.c
+++ b/tools/testing/radix-tree/regression2.c
@@ -51,13 +51,6 @@
 
 #include "regression.h"
 
-#ifdef __KERNEL__
-#define RADIX_TREE_MAP_SHIFT    (CONFIG_BASE_SMALL ? 4 : 6)
-#else
-#define RADIX_TREE_MAP_SHIFT    3       /* For more stressful testing */
-#endif
-
-#define RADIX_TREE_MAP_SIZE     (1UL << RADIX_TREE_MAP_SHIFT)
 #define PAGECACHE_TAG_DIRTY     0
 #define PAGECACHE_TAG_WRITEBACK 1
 #define PAGECACHE_TAG_TOWRITE   2
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
