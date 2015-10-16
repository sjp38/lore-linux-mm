Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 29B3682F65
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 16:02:37 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so22811648wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:02:36 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id ce5si8352112wjb.106.2015.10.16.13.02.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 13:02:36 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ARM: thp: fix unterminated ifdef in header file
Date: Fri, 16 Oct 2015 22:02:04 +0200
Message-ID: <5446974.UXhT00HeJk@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

A recent change accidentally removed one line more than it should
have, causing the build to fail with ARM LPAE:

In file included from /git/arm-soc/arch/arm/include/asm/pgtable.h:31:0,
                 from /git/arm-soc/include/linux/mm.h:55,
                 from /git/arm-soc/arch/arm/kernel/asm-offsets.c:15:
/git/arm-soc/arch/arm/include/asm/pgtable-3level.h:20:0: error: unterminated #ifndef
 #ifndef _ASM_PGTABLE_3LEVEL_H

This puts the line back where it was.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f054144a1b23 ("arm, thp: remove infrastructure for handling splitting PMDs")
---
I noticed this on today's linux-next. It's likely that someone else did too
and already submitted a patch, so mine can be ignored. Otherwise please fold
into the original patch.

diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index d42f81f13618..dc46398bc3a5 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -231,6 +231,7 @@ static inline pte_t pte_mkspecial(pte_t pte)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !pmd_table(pmd))
+#endif
 
 #define PMD_BIT_FUNC(fn,op) \
 static inline pmd_t pmd_##fn(pmd_t pmd) { pmd_val(pmd) op; return pmd; }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
