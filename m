Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0BBF46B006E
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 06:11:51 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so4903193pab.32
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 03:11:51 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ua2si7392487pab.145.2014.10.20.03.11.47
        for <linux-mm@kvack.org>;
        Mon, 20 Oct 2014 03:11:49 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v17 3/7] sparc: add pmd_[dirty|mkclean] for THP
Date: Mon, 20 Oct 2014 19:12:00 +0900
Message-Id: <1413799924-17946-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1413799924-17946-1-git-send-email-minchan@kernel.org>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, sparclinux@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
overwrite of the contents since MADV_FREE syscall is called for
THP page.

This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
support.

Acked-by: David S. Miller <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/sparc/include/asm/pgtable_64.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 3770bf5c6e1b..b80a309d7e00 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -666,6 +666,13 @@ static inline unsigned long pmd_young(pmd_t pmd)
 	return pte_young(pte);
 }
 
+static inline int pmd_dirty(pmd_t pmd)
+{
+	pte_t pte = __pte(pmd_val(pmd));
+
+	return pte_dirty(pte);
+}
+
 static inline unsigned long pmd_write(pmd_t pmd)
 {
 	pte_t pte = __pte(pmd_val(pmd));
@@ -723,6 +730,15 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
 	return __pmd(pte_val(pte));
 }
 
+static inline pmd_t pmd_mkclean(pmd_t pmd)
+{
+	pte_t pte = __pte(pmd_val(pmd));
+
+	pte = pte_mkclean(pte);
+
+	return __pmd(pte_val(pte));
+}
+
 static inline pmd_t pmd_mkyoung(pmd_t pmd)
 {
 	pte_t pte = __pte(pmd_val(pmd));
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
