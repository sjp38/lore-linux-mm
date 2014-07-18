Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 55A076B004D
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 02:52:55 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so4859489pac.31
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 23:52:55 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id n7si2411802pdl.272.2014.07.17.23.52.52
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 23:52:54 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v13 7/8] arm64: add pmd_[dirty|mkclean] for THP
Date: Fri, 18 Jul 2014 15:53:05 +0900
Message-Id: <1405666386-15095-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1405666386-15095-1-git-send-email-minchan@kernel.org>
References: <1405666386-15095-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
overwrite of the contents since MADV_FREE syscall is called for
THP page.

This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
support.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Steve Capper <steve.capper@linaro.org>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index e0ccceb317d9..41dfe3c7260c 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -240,10 +240,12 @@ static inline pmd_t pte_pmd(pte_t pte)
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
