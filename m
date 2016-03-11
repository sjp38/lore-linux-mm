Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DEA8A828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 16:13:13 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 129so92022676pfw.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 13:13:13 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id y67si16150753pfi.213.2016.03.11.13.13.07
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 13:13:07 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 2/3] pfn_t: Support for huge PFNs
Date: Fri, 11 Mar 2016 16:13:03 -0500
Message-Id: <1457730784-9890-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457730784-9890-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457730784-9890-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

We need to put entries in the radix tree that represent PMDs and PUDs.
Use another bit to determine if this PFN entry represents a huge page
or not.  If it does, we know the bottom few bits of the PFN are zero,
so we can reuse them to distinguish between PMDs and PUDs.  Thanks to
Neil Brown for suggesting this more compact encoding.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 include/linux/pfn_t.h | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 37c596c..0ff4c4e 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -8,14 +8,21 @@
  * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
  * PFN_DEV - pfn is not covered by system memmap by default
  * PFN_MAP - pfn has a dynamic page mapping established by a device driver
+ * PFN_HUGE - pfn represents a huge page
  *
  * Note that the bottom two bits in the pfn_t match the bottom two bits in the
  * scatterlist so sg_is_chain() and sg_is_last() work.  These bits are also
  * used by the radix tree for its own purposes, but a PFN cannot be in both a
  * radix tree and a scatterlist simultaneously.  If a PFN is moved between the
  * two usages, care should be taken to clear/set these bits appropriately.
+ *
+ * If PFN_HUGE is set, the bottom PMD_SHIFT-PAGE_SHIFT bits are known to be
+ * zero.  We reuse them to indicate whether the PFN represents a PMD or a PUD.
+ *
+ * This scheme supports 27 bits on a 32-bit system (512GB of physical address
+ * space) and 59 bits on a 64-bit system (2048EB of physical address space).
  */
-#define PFN_FLAG_BITS	4
+#define PFN_FLAG_BITS	5
 #define PFN_FLAGS_MASK	((1 << PFN_FLAG_BITS) - 1)
 #define __PFN_MAX	((1 << (BITS_PER_LONG - PFN_FLAG_BITS)) - 1)
 #define PFN_SG_CHAIN	0x01UL
@@ -23,6 +30,11 @@
 #define PFN_SG_MASK	(PFN_SG_CHAIN | PFN_SG_LAST)
 #define PFN_DEV		0x04UL
 #define PFN_MAP		0x08UL
+#define PFN_HUGE	0x10UL
+#define PFN_SIZE_MASK	0x30UL
+#define PFN_SIZE_PTE	0x00UL
+#define PFN_SIZE_PMD	0x10UL
+#define PFN_SIZE_PUD	0x30UL
 
 #if 0
 #define PFN_T_BUG_ON(x)	BUG_ON(x)
@@ -35,7 +47,7 @@ static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, u64 flags)
 	pfn_t pfn_t = { .val = (pfn << PFN_FLAG_BITS) | flags };
 
 	PFN_T_BUG_ON(pfn & ~__PFN_MAX);
-	PFN_T_BUG_ON(flags & ~PFN_FLAGS_MASK);
+	PFN_T_BUG_ON(flags & ~(PFN_FLAGS_MASK | PFN_SIZE_MASK));
 
 	return pfn_t;
 }
@@ -46,9 +58,12 @@ static inline pfn_t pfn_to_pfn_t(unsigned long pfn)
 	return __pfn_to_pfn_t(pfn, 0);
 }
 
+/* The bottom bits of the PFN may be set if PFN_HUGE is set */
 static inline unsigned long pfn_t_to_pfn(pfn_t pfn)
 {
 	unsigned long v = pfn.val;
+	if (v & PFN_HUGE)
+		v &= ~PFN_SIZE_MASK;
 	return v >> PFN_FLAG_BITS;
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
