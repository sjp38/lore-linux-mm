Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 320D16B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:31 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so92833114pac.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:31 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id fe1si11001656pac.200.2016.04.14.07.17.30
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:30 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 02/29] radix tree test suite: Fix build
Date: Thu, 14 Apr 2016 10:16:23 -0400
Message-Id: <1460643410-30196-3-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

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
index 0000000..e69de29
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index ae013b0..6d0cdf6 100644
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
index 57282506..6d5a347 100644
--- a/tools/testing/radix-tree/linux/slab.h
+++ b/tools/testing/radix-tree/linux/slab.h
@@ -3,7 +3,6 @@
 
 #include <linux/types.h>
 
-#define GFP_KERNEL 1
 #define SLAB_HWCACHE_ALIGN 1
 #define SLAB_PANIC 2
 #define SLAB_RECLAIM_ACCOUNT    0x00020000UL            /* Objects are reclaimable */
diff --git a/tools/testing/radix-tree/linux/types.h b/tools/testing/radix-tree/linux/types.h
index 72a9d85..faa0b6f 100644
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
