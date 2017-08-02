Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 784CF6B0613
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 16:39:08 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id t7so26426260qta.3
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 13:39:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r11si30365263qti.314.2017.08.02.13.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 13:39:07 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 09/15] sparc64: optimized struct page zeroing
Date: Wed,  2 Aug 2017 16:38:18 -0400
Message-Id: <1501706304-869240-10-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
References: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

Add an optimized mm_zero_struct_page(), so struct page's are zeroed without
calling memset(). We do eight regular stores, thus avoid cost of membar.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 arch/sparc/include/asm/pgtable_64.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 6fbd931f0570..23ad51ea5340 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -230,6 +230,24 @@ extern unsigned long _PAGE_ALL_SZ_BITS;
 extern struct page *mem_map_zero;
 #define ZERO_PAGE(vaddr)	(mem_map_zero)
 
+/* This macro must be updated when the size of struct page changes,
+ * so use static assert to enforce the assumed size.
+ */
+#define	mm_zero_struct_page(pp)					\
+	do {							\
+		unsigned long *_pp = (void *)(pp);		\
+								\
+		BUILD_BUG_ON(sizeof(struct page) != 64);	\
+		_pp[0] = 0;					\
+		_pp[1] = 0;					\
+		_pp[2] = 0;					\
+		_pp[3] = 0;					\
+		_pp[4] = 0;					\
+		_pp[5] = 0;					\
+		_pp[6] = 0;					\
+		_pp[7] = 0;					\
+	} while (0)
+
 /* PFNs are real physical page numbers.  However, mem_map only begins to record
  * per-page information starting at pfn_base.  This is to handle systems where
  * the first physical page in the machine is at some huge physical address,
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
