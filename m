Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68B736B5A6C
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:52:55 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so5048295plb.17
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:52:55 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id i129si6691798pfb.32.2018.11.30.13.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 13:52:53 -0800 (PST)
Subject: [mm PATCH v6 1/7] mm: Use mm_zero_struct_page from SPARC on all 64b
 architectures
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 30 Nov 2018 13:52:53 -0800
Message-ID: <154361477318.7497.13432441396440493352.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
References: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

Use the same approach that was already in use on Sparc on all the
architectures that support a 64b long.

This is mostly motivated by the fact that 7 to 10 store/move instructions
are likely always going to be faster than having to call into a function
that is not specialized for handling page init.

An added advantage to doing it this way is that the compiler can get away
with combining writes in the __init_single_page call. As a result the
memset call will be reduced to only about 4 write operations, or at least
that is what I am seeing with GCC 6.2 as the flags, LRU pointers, and
count/mapcount seem to be cancelling out at least 4 of the 8 assignments on
my system.

One change I had to make to the function was to reduce the minimum page
size to 56 to support some powerpc64 configurations.

This change should introduce no change on SPARC since it already had this
code. In the case of x86_64 I saw a reduction from 3.75s to 2.80s when
initializing 384GB of RAM per node. Pavel Tatashin tested on a system with
Broadcom's Stingray CPU and 48GB of RAM and found that __init_single_page()
takes 19.30ns / 64-byte struct page before this patch and with this patch
it takes 17.33ns / 64-byte struct page. Mike Rapoport ran a similar test on
a OpenPower (S812LC 8348-21C) with Power8 processor and 128GB or RAM. His
results per 64-byte struct page were 4.68ns before, and 4.59ns after this
patch.

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 arch/sparc/include/asm/pgtable_64.h |   30 --------------------------
 include/linux/mm.h                  |   41 ++++++++++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 33 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 1393a8ac596b..22500c3be7a9 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -231,36 +231,6 @@ extern unsigned long _PAGE_ALL_SZ_BITS;
 extern struct page *mem_map_zero;
 #define ZERO_PAGE(vaddr)	(mem_map_zero)
 
-/* This macro must be updated when the size of struct page grows above 80
- * or reduces below 64.
- * The idea that compiler optimizes out switch() statement, and only
- * leaves clrx instructions
- */
-#define	mm_zero_struct_page(pp) do {					\
-	unsigned long *_pp = (void *)(pp);				\
-									\
-	 /* Check that struct page is either 64, 72, or 80 bytes */	\
-	BUILD_BUG_ON(sizeof(struct page) & 7);				\
-	BUILD_BUG_ON(sizeof(struct page) < 64);				\
-	BUILD_BUG_ON(sizeof(struct page) > 80);				\
-									\
-	switch (sizeof(struct page)) {					\
-	case 80:							\
-		_pp[9] = 0;	/* fallthrough */			\
-	case 72:							\
-		_pp[8] = 0;	/* fallthrough */			\
-	default:							\
-		_pp[7] = 0;						\
-		_pp[6] = 0;						\
-		_pp[5] = 0;						\
-		_pp[4] = 0;						\
-		_pp[3] = 0;						\
-		_pp[2] = 0;						\
-		_pp[1] = 0;						\
-		_pp[0] = 0;						\
-	}								\
-} while (0)
-
 /* PFNs are real physical page numbers.  However, mem_map only begins to record
  * per-page information starting at pfn_base.  This is to handle systems where
  * the first physical page in the machine is at some huge physical address,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 692158d6c619..eb6e52b66bc2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -123,10 +123,45 @@ extern int mmap_rnd_compat_bits __read_mostly;
 
 /*
  * On some architectures it is expensive to call memset() for small sizes.
- * Those architectures should provide their own implementation of "struct page"
- * zeroing by defining this macro in <asm/pgtable.h>.
+ * If an architecture decides to implement their own version of
+ * mm_zero_struct_page they should wrap the defines below in a #ifndef and
+ * define their own version of this macro in <asm/pgtable.h>
  */
-#ifndef mm_zero_struct_page
+#if BITS_PER_LONG == 64
+/* This function must be updated when the size of struct page grows above 80
+ * or reduces below 56. The idea that compiler optimizes out switch()
+ * statement, and only leaves move/store instructions. Also the compiler can
+ * combine write statments if they are both assignments and can be reordered,
+ * this can result in several of the writes here being dropped.
+ */
+#define	mm_zero_struct_page(pp) __mm_zero_struct_page(pp)
+static inline void __mm_zero_struct_page(struct page *page)
+{
+	unsigned long *_pp = (void *)page;
+
+	 /* Check that struct page is either 56, 64, 72, or 80 bytes */
+	BUILD_BUG_ON(sizeof(struct page) & 7);
+	BUILD_BUG_ON(sizeof(struct page) < 56);
+	BUILD_BUG_ON(sizeof(struct page) > 80);
+
+	switch (sizeof(struct page)) {
+	case 80:
+		_pp[9] = 0;	/* fallthrough */
+	case 72:
+		_pp[8] = 0;	/* fallthrough */
+	case 64:
+		_pp[7] = 0;	/* fallthrough */
+	case 56:
+		_pp[6] = 0;
+		_pp[5] = 0;
+		_pp[4] = 0;
+		_pp[3] = 0;
+		_pp[2] = 0;
+		_pp[1] = 0;
+		_pp[0] = 0;
+	}
+}
+#else
 #define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
 #endif
 
