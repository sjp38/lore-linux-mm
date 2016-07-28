Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9B06B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 15:47:37 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ca5so66838420pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:47:37 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id w10si13830816pag.138.2016.07.28.12.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 12:47:36 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] ARC: mm: don't loose PTE_SPECIAL in pte_modify()
Date: Thu, 28 Jul 2016 12:47:22 -0700
Message-ID: <1469735242-6003-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-snps-arc@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>

LTP madvise05 was generating mm splat

| [ARCLinux]# /sd/ltp/testcases/bin/madvise05
| BUG: Bad page map in process madvise05  pte:80e08211 pmd:9f7d4000
| page:9fdcfc90 count:1 mapcount:-1 mapping:  (null) index:0x0 flags: 0x404(referenced|reserved)
| page dumped because: bad pte
| addr:200b8000 vm_flags:00000070 anon_vma:  (null) mapping:  (null) index:1005c
| file:  (null) fault:  (null) mmap:  (null) readpage:  (null)
| CPU: 2 PID: 6707 Comm: madvise05

And for newer kernels, the system was rendered unusable afterwards.

The problem was mprotect->pte_modify() clearing PTE_SPECIAL (which is
set to identify the special zero page wired to the pte).
When pte was finally unmapped, special casing for zero page was not
done, and instead it was treated as a "normal" page, tripping on the
map counts etc.

This fixes ARC STAR 9001053308

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 57af2f05ae84..3cab04255ae0 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -110,7 +110,7 @@
 #define ___DEF (_PAGE_PRESENT | _PAGE_CACHEABLE)
 
 /* Set of bits not changed in pte_modify */
-#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
+#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_SPECIAL)
 
 /* More Abbrevaited helpers */
 #define PAGE_U_NONE     __pgprot(___DEF)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
