Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TKJbtB016724
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:37 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TKJas4255170
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 14:19:36 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TKJah4005459
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 14:19:36 -0600
Subject: [RFC][PATCH 01/10] put alignment macros in align.h
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 13:19:34 -0700
References: <20060829201934.47E63D1F@localhost.localdomain>
In-Reply-To: <20060829201934.47E63D1F@localhost.localdomain>
Message-Id: <20060829201934.A5363374@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There are several definitions of alignment macros.  We'll take this
one out of kernel.h and put it in align.h for now.  We can't just
include kernel.h because it has many other definitions, and we'll
get circular dependencies.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/linux/kernel.h |    2 +-
 threadalloc-dave/include/linux/align.h  |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff -puN include/linux/kernel.h~align-h include/linux/kernel.h
--- threadalloc/include/linux/kernel.h~align-h	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/include/linux/kernel.h	2006-08-29 13:14:50.000000000 -0700
@@ -13,6 +13,7 @@
 #include <linux/types.h>
 #include <linux/compiler.h>
 #include <linux/bitops.h>
+#include <linux/align.h>
 #include <asm/byteorder.h>
 #include <asm/bug.h>
 
@@ -31,7 +32,6 @@ extern const char linux_banner[];
 #define STACK_MAGIC	0xdeadbeef
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
-#define ALIGN(x,a) (((x)+(a)-1)&~((a)-1))
 #define FIELD_SIZEOF(t, f) (sizeof(((t*)0)->f))
 #define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))
 
diff -puN /dev/null include/linux/align.h
--- /dev/null	2005-03-30 22:36:15.000000000 -0800
+++ threadalloc-dave/include/linux/align.h	2006-08-29 13:14:50.000000000 -0700
@@ -0,0 +1,17 @@
+#ifndef _LINUX_ALIGN_H
+#define _LINUX_ALIGN_H
+
+/*
+ * This file should only contain macros which have no outside
+ * dependencies, and can be used safely from any other header.
+ */
+
+/*
+ * ALIGN is special.  There's a linkage.h as well that
+ * has a quite different meaning.
+ */
+#ifndef __ASSEMBLY__
+#define ALIGN(x,a) (((x)+(a)-1)&~((a)-1))
+#endif
+
+#endif /* _LINUX_ALIGN_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
