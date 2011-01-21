Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDAF8D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:32:53 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/7] check hugepage swap entry in get_user_pages_fast()
Date: Fri, 21 Jan 2011 15:28:55 +0900
Message-Id: <1295591340-1862-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

When the hugepage associated with a given address is HWPOISONed
or under page migration, get_user_pages_fast() need to fall back
to slow path in order to make the page fault fail (when HWPOISONed)
or to wait for migration completion (when under migration.)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/mm/gup.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git v2.6.38-rc1/arch/x86/mm/gup.c v2.6.38-rc1/arch/x86/mm/gup.c
index dbe34b9..93b74dd 100644
--- v2.6.38-rc1/arch/x86/mm/gup.c
+++ v2.6.38-rc1/arch/x86/mm/gup.c
@@ -176,6 +176,15 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		 */
 		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
+		/*
+		 * PMD can be in swap entry style when the hugepage
+		 * pointed to by it is hwpoisoned or under migration.
+		 * Because the swap entry format has no flag showing
+		 * the page size, pmd_large() cannot detect it.
+		 * So then we just fall back to the slow path.
+		 */
+		if (unlikely(!pmd_present(pmd)))
+			return 0;
 		if (unlikely(pmd_large(pmd))) {
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
 				return 0;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
