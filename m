Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD876B02B4
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 22:03:11 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p13so6409475qtp.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 19:03:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j189si1812087qkj.93.2017.08.28.19.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 19:03:10 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v7 07/11] sparc64: optimized struct page zeroing
Date: Mon, 28 Aug 2017 22:02:18 -0400
Message-Id: <1503972142-289376-8-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1503972142-289376-1-git-send-email-pasha.tatashin@oracle.com>
References: <1503972142-289376-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Add an optimized mm_zero_struct_page(), so struct page's are zeroed without
calling memset(). We do eight to ten regular stores based on the size of
struct page. Compiler optimizes out the conditions of switch() statement.

SPARC-M6 with 15T of memory, single thread performance:

                               BASE            FIX  OPTIMIZED_FIX
        bootmem_init   28.440467985s   2.305674818s   2.305161615s
free_area_init_nodes  202.845901673s 225.343084508s 172.556506560s
                      --------------------------------------------
Total                 231.286369658s 227.648759326s 174.861668175s

BASE:  current linux
FIX:   This patch series without "optimized struct page zeroing"
OPTIMIZED_FIX: This patch series including the current patch.

bootmem_init() is where memory for struct pages is zeroed during
allocation. Note, about two seconds in this function is a fixed time: it
does not increase as memory is increased.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 arch/sparc/include/asm/pgtable_64.h | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 6fbd931f0570..cee5cc7ccc51 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -230,6 +230,36 @@ extern unsigned long _PAGE_ALL_SZ_BITS;
 extern struct page *mem_map_zero;
 #define ZERO_PAGE(vaddr)	(mem_map_zero)
 
+/* This macro must be updated when the size of struct page grows above 80
+ * or reduces below 64.
+ * The idea that compiler optimizes out switch() statement, and only
+ * leaves clrx instructions
+ */
+#define	mm_zero_struct_page(pp) do {					\
+	unsigned long *_pp = (void *)(pp);				\
+									\
+	 /* Check that struct page is either 64, 72, or 80 bytes */	\
+	BUILD_BUG_ON(sizeof(struct page) & 7);				\
+	BUILD_BUG_ON(sizeof(struct page) < 64);				\
+	BUILD_BUG_ON(sizeof(struct page) > 80);				\
+									\
+	switch (sizeof(struct page)) {					\
+	case 80:							\
+		_pp[9] = 0;	/* fallthrough */			\
+	case 72:							\
+		_pp[8] = 0;	/* fallthrough */			\
+	default:							\
+		_pp[7] = 0;						\
+		_pp[6] = 0;						\
+		_pp[5] = 0;						\
+		_pp[4] = 0;						\
+		_pp[3] = 0;						\
+		_pp[2] = 0;						\
+		_pp[1] = 0;						\
+		_pp[0] = 0;						\
+	}								\
+} while (0)
+
 /* PFNs are real physical page numbers.  However, mem_map only begins to record
  * per-page information starting at pfn_base.  This is to handle systems where
  * the first physical page in the machine is at some huge physical address,
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
