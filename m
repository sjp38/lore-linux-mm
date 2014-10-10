Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE006B0038
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 22:17:21 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kx10so811016pab.9
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 19:17:21 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id fk1si2292327pab.127.2014.10.09.19.17.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 09 Oct 2014 19:17:20 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0ND70086JICTY020@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Oct 2014 11:17:17 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm/cma: fix cma bitmap aligned mask computing
Date: Fri, 10 Oct 2014 10:15:53 +0800
Message-id: <000301cfe430$504b0290$f0e107b0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, m.szyprowski@samsung.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

The current cma bitmap aligned mask compute way is incorrect, it could
cause an unexpected align when using cma_alloc() if wanted align order
is bigger than cma->order_per_bit.

Take kvm for example (PAGE_SHIFT = 12), kvm_cma->order_per_bit is set to 6,
when kvm_alloc_rma() tries to alloc kvm_rma_pages, it will input 15 as
expected align value, after using current computing, however, we get 0 as
cma bitmap aligned mask other than 511.

This patch fixes the cma bitmap aligned mask compute way.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/cma.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index c17751c..f6207ef 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -57,7 +57,10 @@ unsigned long cma_get_size(struct cma *cma)
 
 static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
 {
-	return (1UL << (align_order >> cma->order_per_bit)) - 1;
+	if (align_order <= cma->order_per_bit)
+		return 0;
+	else
+		return (1UL << (align_order - cma->order_per_bit)) - 1;
 }
 
 static unsigned long cma_bitmap_maxno(struct cma *cma)
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
