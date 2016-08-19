Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6AE6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 15:07:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so93514771pab.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 12:07:08 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id y15si6292622pfb.247.2016.08.19.12.07.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 12:07:06 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RESEND PATCH 1/1] mm/vmalloc: fix align value calculation error
Message-ID: <6a29a2c9-9c76-3493-f8e3-4b97700c7c82@zoho.com>
Date: Sat, 20 Aug 2016 03:05:44 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: torvalds@linux-foundation.org, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zijun_hu <zijun_hu@htc.com>

it causes double align requirement for __get_vm_area_node() if parameter
size is power of 2 and VM_IOREMAP is set in parameter flags, for example
size=0x10000 -> fls_long(0x10000)=17 -> align=0x20000

get_count_order_long() is implemented and used instead of fls_long() for
fixing the bug, for example
size=0x10000 -> get_count_order_long(0x10000)=16 -> align=0x10000

Andrew Morton help to names the function get_count_order_long and place it
near its counterpart get_count_order()

Signed-off-by: zijun_hu <zijun_hu@htc.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 Hi Andrew,

 please help to replace the following 6 patch series by this
 patch to make commit logs clear kindly, this patch is resulted
 from rebasing the 6 patch series into one, it maybe an alternative
 for you to rebasing them manually
 
 as we known, the 6 patch series fix the same issue together
 they are applied in mmotm and linux-next tree currently, not
 yet mainline

 the 6 patch series are listed as follows
 mm-vmalloc-fix-align-value-calculation-error.patch
 mm-vmalloc-fix-align-value-calculation-error-fix.patch
 mm-vmalloc-fix-align-value-calculation-error-v2.patch
 mm-vmalloc-fix-align-value-calculation-error-v2-fix.patch
 mm-vmalloc-fix-align-value-calculation-error-v2-fix-fix.patch
 mm-vmalloc-fix-align-value-calculation-error-v2-fix-fix-fix.patch

 include/linux/bitops.h | 36 ++++++++++++++++++++++++++----------
 mm/vmalloc.c           |  8 ++++----
 2 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index 299e76b59fe9..a83c822c35c2 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -65,16 +65,6 @@ static inline int get_bitmask_order(unsigned int count)
 	return order;	/* We could be slightly more clever with -1 here... */
 }
 
-static inline int get_count_order(unsigned int count)
-{
-	int order;
-
-	order = fls(count) - 1;
-	if (count & (count - 1))
-		order++;
-	return order;
-}
-
 static __always_inline unsigned long hweight_long(unsigned long w)
 {
 	return sizeof(w) == 4 ? hweight32(w) : hweight64(w);
@@ -191,6 +181,32 @@ static inline unsigned fls_long(unsigned long l)
 	return fls64(l);
 }
 
+static inline int get_count_order(unsigned int count)
+{
+	int order;
+
+	order = fls(count) - 1;
+	if (count & (count - 1))
+		order++;
+	return order;
+}
+
+/**
+ * get_count_order_long - get order after rounding @l up to power of 2
+ * @l: parameter
+ *
+ * it is same as get_count_order() but with long type parameter
+ */
+static inline int get_count_order_long(unsigned long l)
+{
+	if (l == 0UL)
+		return -1;
+	else if (l & (l - 1UL))
+		return (int)fls_long(l);
+	else
+		return (int)fls_long(l) - 1;
+}
+
 /**
  * __ffs64 - find first set bit in a 64 bit word
  * @word: The 64 bit word
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e78c516..80660a0f989b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1359,14 +1359,14 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 	struct vm_struct *area;
 
 	BUG_ON(in_interrupt());
-	if (flags & VM_IOREMAP)
-		align = 1ul << clamp_t(int, fls_long(size),
-				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
-
 	size = PAGE_ALIGN(size);
 	if (unlikely(!size))
 		return NULL;
 
+	if (flags & VM_IOREMAP)
+		align = 1ul << clamp_t(int, get_count_order_long(size),
+				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
+
 	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
 	if (unlikely(!area))
 		return NULL;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
