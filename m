Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 31B216B0039
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 02:52:42 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so4454091pdj.7
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 23:52:41 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id xx7si4839390pac.35.2014.07.17.23.52.39
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 23:52:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v13 2/8] x86: add pmd_[dirty|mkclean] for THP
Date: Fri, 18 Jul 2014 15:53:00 +0900
Message-Id: <1405666386-15095-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1405666386-15095-1-git-send-email-minchan@kernel.org>
References: <1405666386-15095-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
overwrite of the contents since MADV_FREE syscall is called for
THP page.

This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
support.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/x86/include/asm/pgtable.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0ec056012618..329865799653 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -104,6 +104,11 @@ static inline int pmd_young(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_ACCESSED;
 }
 
+static inline int pmd_dirty(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_DIRTY;
+}
+
 static inline int pte_write(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_RW;
@@ -267,6 +272,11 @@ static inline pmd_t pmd_mkold(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
 }
 
+static inline pmd_t pmd_mkclean(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_DIRTY);
+}
+
 static inline pmd_t pmd_wrprotect(pmd_t pmd)
 {
 	return pmd_clear_flags(pmd, _PAGE_RW);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
