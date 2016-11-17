Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A69A66B02A2
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:24:05 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n68so71750135itn.4
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:24:05 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id q200si235460iod.156.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:05 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 26/29] idr: Reduce the number of bits per level from 8 to 6
Date: Wed, 16 Nov 2016 16:17:30 -0800
Message-Id: <1479341856-30320-66-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

In preparation for merging the IDR and radix tree, reduce the fanout at
each level from 256 to 64.  If this causes a performance problem then
a bisect will point to this commit, and we'll have a better idea about
what we might do to fix it.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/idr.h | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 1eb755f..3c01b89 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -18,12 +18,11 @@
 #include <linux/rcupdate.h>
 
 /*
- * We want shallower trees and thus more bits covered at each layer.  8
- * bits gives us large enough first layer for most use cases and maximum
- * tree depth of 4.  Each idr_layer is slightly larger than 2k on 64bit and
- * 1k on 32bit.
+ * Using 6 bits at each layer allows us to allocate 7 layers out of each page.
+ * 8 bits only gave us 3 layers out of every pair of pages, which is less
+ * efficient except for trees with a largest element between 192-255 inclusive.
  */
-#define IDR_BITS 8
+#define IDR_BITS 6
 #define IDR_SIZE (1 << IDR_BITS)
 #define IDR_MASK ((1 << IDR_BITS)-1)
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
