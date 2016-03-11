Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 229C56B007E
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 16:13:09 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 129so92021666pfw.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 13:13:09 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id y67si16150753pfi.213.2016.03.11.13.13.07
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 13:13:07 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 1/3] pfn_t: Change the encoding
Date: Fri, 11 Mar 2016 16:13:02 -0500
Message-Id: <1457730784-9890-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457730784-9890-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457730784-9890-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

By moving the flag bits to the bottom, we encourage commonality
between SGs with pages and those using pfn_t.  We can also then insert
a pfn_t into a radix tree, as it uses the same two bits for indirect &
exceptional indicators.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 include/linux/pfn_t.h | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 9499481..37c596c 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -8,16 +8,34 @@
  * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
  * PFN_DEV - pfn is not covered by system memmap by default
  * PFN_MAP - pfn has a dynamic page mapping established by a device driver
+ *
+ * Note that the bottom two bits in the pfn_t match the bottom two bits in the
+ * scatterlist so sg_is_chain() and sg_is_last() work.  These bits are also
+ * used by the radix tree for its own purposes, but a PFN cannot be in both a
+ * radix tree and a scatterlist simultaneously.  If a PFN is moved between the
+ * two usages, care should be taken to clear/set these bits appropriately.
  */
-#define PFN_FLAGS_MASK (((u64) ~PAGE_MASK) << (BITS_PER_LONG_LONG - PAGE_SHIFT))
-#define PFN_SG_CHAIN (1ULL << (BITS_PER_LONG_LONG - 1))
-#define PFN_SG_LAST (1ULL << (BITS_PER_LONG_LONG - 2))
-#define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))
-#define PFN_MAP (1ULL << (BITS_PER_LONG_LONG - 4))
+#define PFN_FLAG_BITS	4
+#define PFN_FLAGS_MASK	((1 << PFN_FLAG_BITS) - 1)
+#define __PFN_MAX	((1 << (BITS_PER_LONG - PFN_FLAG_BITS)) - 1)
+#define PFN_SG_CHAIN	0x01UL
+#define PFN_SG_LAST	0x02UL
+#define PFN_SG_MASK	(PFN_SG_CHAIN | PFN_SG_LAST)
+#define PFN_DEV		0x04UL
+#define PFN_MAP		0x08UL
+
+#if 0
+#define PFN_T_BUG_ON(x)	BUG_ON(x)
+#else
+#define PFN_T_BUG_ON(x)	BUILD_BUG_ON_INVALID(x)
+#endif
 
 static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, u64 flags)
 {
-	pfn_t pfn_t = { .val = pfn | (flags & PFN_FLAGS_MASK), };
+	pfn_t pfn_t = { .val = (pfn << PFN_FLAG_BITS) | flags };
+
+	PFN_T_BUG_ON(pfn & ~__PFN_MAX);
+	PFN_T_BUG_ON(flags & ~PFN_FLAGS_MASK);
 
 	return pfn_t;
 }
@@ -28,6 +46,12 @@ static inline pfn_t pfn_to_pfn_t(unsigned long pfn)
 	return __pfn_to_pfn_t(pfn, 0);
 }
 
+static inline unsigned long pfn_t_to_pfn(pfn_t pfn)
+{
+	unsigned long v = pfn.val;
+	return v >> PFN_FLAG_BITS;
+}
+
 extern pfn_t phys_to_pfn_t(phys_addr_t addr, u64 flags);
 
 static inline bool pfn_t_has_page(pfn_t pfn)
@@ -35,11 +59,6 @@ static inline bool pfn_t_has_page(pfn_t pfn)
 	return (pfn.val & PFN_MAP) == PFN_MAP || (pfn.val & PFN_DEV) == 0;
 }
 
-static inline unsigned long pfn_t_to_pfn(pfn_t pfn)
-{
-	return pfn.val & ~PFN_FLAGS_MASK;
-}
-
 static inline struct page *pfn_t_to_page(pfn_t pfn)
 {
 	if (pfn_t_has_page(pfn))
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
