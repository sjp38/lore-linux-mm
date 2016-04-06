Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1725F6B0253
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:21:54 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id e128so41073831pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id k80si6893726pfb.171.2016.04.06.14.21.50
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:50 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 02/30] radix tree test suite: Fix build
Date: Wed,  6 Apr 2016 17:21:11 -0400
Message-Id: <1459977699-2349-3-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

Add an empty linux/init.h, and definitions for a few parts of the kernel
API either in use now, or to be used in the near future.  Start using
the common definitions in tools/include/linux, although more work needs
to be done here.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 tools/testing/radix-tree/linux/init.h   |  0
 tools/testing/radix-tree/linux/kernel.h | 12 ++++++++++--
 tools/testing/radix-tree/linux/slab.h   |  1 -
 tools/testing/radix-tree/linux/types.h  |  7 ++-----
 4 files changed, 12 insertions(+), 8 deletions(-)
 create mode 100644 tools/testing/radix-tree/linux/init.h

diff --git a/tools/testing/radix-tree/linux/init.h b/tools/testing/radix-tree/linux/init.h
new file mode 100644
index 000000000000..e69de29bb2d1
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index ae013b0160ac..6d0cdf618084 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -7,19 +7,25 @@
 #include <stddef.h>
 #include <limits.h>
 
+#include "../../include/linux/compiler.h"
+
 #ifndef NULL
 #define NULL	0
 #endif
 
 #define BUG_ON(expr)	assert(!(expr))
+#define WARN_ON(expr)	assert(!(expr))
 #define __init
 #define __must_check
 #define panic(expr)
 #define printk printf
 #define __force
-#define likely(c) (c)
-#define unlikely(c) (c)
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
+#define pr_debug printk
+
+#define smp_rmb()	barrier()
+#define smp_wmb()	barrier()
+#define cpu_relax()	barrier()
 
 #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
 
@@ -28,6 +34,8 @@
 	(type *)( (char *)__mptr - offsetof(type, member) );})
 #define min(a, b) ((a) < (b) ? (a) : (b))
 
+#define cond_resched()	sched_yield()
+
 static inline int in_interrupt(void)
 {
 	return 0;
diff --git a/tools/testing/radix-tree/linux/slab.h b/tools/testing/radix-tree/linux/slab.h
index 57282506c21d..6d5a34770fd4 100644
--- a/tools/testing/radix-tree/linux/slab.h
+++ b/tools/testing/radix-tree/linux/slab.h
@@ -3,7 +3,6 @@
 
 #include <linux/types.h>
 
-#define GFP_KERNEL 1
 #define SLAB_HWCACHE_ALIGN 1
 #define SLAB_PANIC 2
 #define SLAB_RECLAIM_ACCOUNT    0x00020000UL            /* Objects are reclaimable */
diff --git a/tools/testing/radix-tree/linux/types.h b/tools/testing/radix-tree/linux/types.h
index 72a9d85f6c76..faa0b6ff9ca8 100644
--- a/tools/testing/radix-tree/linux/types.h
+++ b/tools/testing/radix-tree/linux/types.h
@@ -1,15 +1,13 @@
 #ifndef _TYPES_H
 #define _TYPES_H
 
+#include "../../include/linux/types.h"
+
 #define __rcu
 #define __read_mostly
 
 #define BITS_PER_LONG (sizeof(long) * 8)
 
-struct list_head {
-	struct list_head *next, *prev;
-};
-
 static inline void INIT_LIST_HEAD(struct list_head *list)
 {
 	list->next = list;
@@ -22,7 +20,6 @@ typedef struct {
 
 #define uninitialized_var(x) x = x
 
-typedef unsigned gfp_t;
 #include <linux/gfp.h>
 
 #endif
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
