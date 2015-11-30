Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DC5006B025E
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 01:39:43 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so174822780pac.3
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 22:39:43 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id di6si8295004pad.172.2015.11.29.22.39.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 29 Nov 2015 22:39:30 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 08/12] sparc: add pmd_[dirty|mkclean] for THP
Date: Mon, 30 Nov 2015 15:39:39 +0900
Message-Id: <1448865583-2446-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1448865583-2446-1-git-send-email-minchan@kernel.org>
References: <1448865583-2446-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>

MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent overwrite
of the contents since MADV_FREE syscall is called for THP page.

This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
support.

Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 arch/sparc/include/asm/pgtable_64.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index f5bfcd66aeb5..7a38d6a576c5 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -710,6 +710,15 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
