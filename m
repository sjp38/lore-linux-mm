Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC0E831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 07:18:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m5so125250357pfc.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 04:18:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f1si16555941pgc.109.2017.05.22.04.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 04:18:44 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4MBFKrC116635
	for <linux-mm@kvack.org>; Mon, 22 May 2017 07:18:43 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2akp79cc54-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 May 2017 07:18:43 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 22 May 2017 21:18:41 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4MBIUvr53215314
	for <linux-mm@kvack.org>; Mon, 22 May 2017 21:18:38 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4MBHxOv016893
	for <linux-mm@kvack.org>; Mon, 22 May 2017 21:17:59 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm: Define KB, MB, GB, TB in core VM
Date: Mon, 22 May 2017 16:47:42 +0530
Message-Id: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

There are many places where we define size either left shifting integers
or multiplying 1024s without any generic definition to fall back on. But
there are couples of (powerpc and lz4) attempts to define these standard
memory sizes. Lets move these definitions to core VM to make sure that
all new usage come from these definitions eventually standardizing it
across all places.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash_utils_64.c | 4 ----
 include/linux/mm.h              | 5 +++++
 lib/lz4/lz4defs.h               | 5 +----
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index f2095ce..ef64040 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -74,10 +74,6 @@
 #define DBG_LOW(fmt...)
 #endif
 
-#define KB (1024)
-#define MB (1024*KB)
-#define GB (1024L*MB)
-
 /*
  * Note:  pte   --> Linux PTE
  *        HPTE  --> PowerPC Hashed Page Table Entry
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cb17c6..9f5779f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2549,5 +2549,10 @@ static inline bool page_is_guard(struct page *page)
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+#define KB (1UL << 10)
+#define MB (1UL << 20)
+#define GB (1UL << 30)
+#define TB (1UL << 40)
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
index 00a0b58..67a0f6d 100644
--- a/lib/lz4/lz4defs.h
+++ b/lib/lz4/lz4defs.h
@@ -37,6 +37,7 @@
 
 #include <asm/unaligned.h>
 #include <linux/string.h>	 /* memset, memcpy */
+#include <linux/mm.h>
 
 #define FORCE_INLINE __always_inline
 
@@ -81,10 +82,6 @@
 
 #define HASH_UNIT sizeof(size_t)
 
-#define KB (1 << 10)
-#define MB (1 << 20)
-#define GB (1U << 30)
-
 #define MAXD_LOG 16
 #define MAX_DISTANCE ((1 << MAXD_LOG) - 1)
 #define STEPSIZE sizeof(size_t)
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
