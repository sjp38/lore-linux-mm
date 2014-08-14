Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D9AF06B003B
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 21:53:30 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so667602pdb.19
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 18:53:30 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id g2si2785126pdl.128.2014.08.13.18.53.27
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 18:53:29 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v14 7/8] arm64: add pmd_[dirty|mkclean] for THP
Date: Thu, 14 Aug 2014 10:53:31 +0900
Message-Id: <1407981212-17818-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1407981212-17818-1-git-send-email-minchan@kernel.org>
References: <1407981212-17818-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Steve Capper <steve.capper@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>

MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
overwrite of the contents since MADV_FREE syscall is called for
THP page.

This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
support.

Cc: Will Deacon <will.deacon@arm.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org
Cc: Steve Capper <steve.capper@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Steve Capper <steve.capper@linaro.org>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index ffe1ba0506d1..efb1b2fc4d39 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -259,10 +259,12 @@ static inline pmd_t pte_pmd(pte_t pte)
 #endif
 
 #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
+#define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
 #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
 #define pmd_mksplitting(pmd)	pte_pmd(pte_mkspecial(pmd_pte(pmd)))
 #define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
 #define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
+#define pmd_mkclean(pmd)	pte_pmd(pte_mkclean(pmd_pte(pmd)))
 #define pmd_mkdirty(pmd)	pte_pmd(pte_mkdirty(pmd_pte(pmd)))
 #define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
 #define pmd_mknotpresent(pmd)	(__pmd(pmd_val(pmd) & ~PMD_TYPE_MASK))
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
