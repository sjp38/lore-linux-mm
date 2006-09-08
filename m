Date: Fri, 8 Sep 2006 13:26:48 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 4/5] linear reclaim add pfn_valid_within for zone holes
Message-ID: <20060908122648.GA1481@shadowen.org>
References: <exportbomb.1157718286@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

linear reclaim add pfn_valid_within for zone holes

Generally we work under the assumption that memory the mem_map array
is contigious and valid out to MAX_ORDER blocks.  When this is not
true we much check each and every reference we make from a pfn.
Add a pfn_valid_within() which should be used when checking pages
within a block when we have already checked the validility of the
block normally.  This can then be optimised away when we have holes.

Added in: V1

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3d31354..8c09638 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -680,6 +680,18 @@ #endif
 void memory_present(int nid, unsigned long start, unsigned long end);
 unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 
+/*
+ * If we have holes within zones (smaller than MAX_ORDER) then we need
+ * to check pfn validility within MAX_ORDER blocks.  pfn_valid_within
+ * should be used in this case; we optimise this away when we have
+ * no holes.
+ */
+#ifdef CONFIG_HOLES_IN_ZONE
+#define pfn_valid_within(pfn) pfn_valid(pfn)
+#else
+#define pfn_valid_within(pfn) (1)
+#endif
+
 #endif /* !__ASSEMBLY__ */
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MMZONE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
