Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D32D76B065F
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 02:48:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so5558384pge.9
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 23:48:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z66si1004619pff.284.2017.08.02.23.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 23:48:39 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v13 2/5] xbitmap: add xb_find_next_bit() and xb_zero()
Date: Thu,  3 Aug 2017 14:38:16 +0800
Message-Id: <1501742299-4369-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org
Cc: virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

xb_find_next_bit() supports to find the next "1" or "0" bit in the
given range. xb_zero() supports to zero the given range of bits.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 include/linux/xbitmap.h |  4 ++++
 lib/radix-tree.c        | 28 ++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
index 0b93a46..88c2045 100644
--- a/include/linux/xbitmap.h
+++ b/include/linux/xbitmap.h
@@ -36,6 +36,10 @@ int xb_set_bit(struct xb *xb, unsigned long bit);
 bool xb_test_bit(const struct xb *xb, unsigned long bit);
 int xb_clear_bit(struct xb *xb, unsigned long bit);
 
+void xb_zero(struct xb *xb, unsigned long start, unsigned long end);
+unsigned long xb_find_next_bit(struct xb *xb, unsigned long start,
+			       unsigned long end, bool set);
+
 static inline bool xb_empty(const struct xb *xb)
 {
 	return radix_tree_empty(&xb->xbrt);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index d8c3c18..84842a3 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -2272,6 +2272,34 @@ bool xb_test_bit(const struct xb *xb, unsigned long bit)
 	return test_bit(bit, bitmap->bitmap);
 }
 
+void xb_zero(struct xb *xb, unsigned long start, unsigned long end)
+{
+	unsigned long i;
+
+	for (i = start; i <= end; i++)
+		xb_clear_bit(xb, i);
+}
+EXPORT_SYMBOL(xb_zero);
+
+/*
+ * Find the next one (@set = 1) or zero (@set = 0) bit within the bit range
+ * from @start to @end in @xb. If no such bit is found in the given range,
+ * bit end + 1 will be returned.
+ */
+unsigned long xb_find_next_bit(struct xb *xb, unsigned long start,
+			       unsigned long end, bool set)
+{
+	unsigned long i;
+
+	for (i = start; i <= end; i++) {
+		if (xb_test_bit(xb, i) == set)
+			break;
+	}
+
+	return i;
+}
+EXPORT_SYMBOL(xb_find_next_bit);
+
 void __rcu **idr_get_free(struct radix_tree_root *root,
 			struct radix_tree_iter *iter, gfp_t gfp, int end)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
