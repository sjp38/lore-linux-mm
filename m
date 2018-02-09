Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD8BA6B0279
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 16:41:14 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id g24so3005167plj.4
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 13:41:14 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id y6si1858308pgr.220.2018.02.09.13.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 13:41:13 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH v3] mm: thp: fix potential clearing to referenced flag in page_idle_clear_pte_refs_one()
Date: Sat, 10 Feb 2018 05:40:51 +0800
Message-Id: <1518212451-87134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org
Cc: gavin.dg@linux.alibaba.com, yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

For PTE-mapped THP, the compound THP has not been split to normal 4K
pages yet, the whole THP is considered referenced if any one of sub
page is referenced.

When walking PTE-mapped THP by pvmw, all relevant PTEs will be checked
to retrieve referenced bit. But, the current code just returns the
result of the last PTE. If the last PTE has not referenced, the
referenced flag will be cleared.

Just set referenced when ptep{pmdp}_clear_young_notify() returns true.

Reported-by: Gang Deng <gavin.dg@linux.alibaba.com>
Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v3: Fixed the insane "||" stuff pointed out by Andrew

v2: adopted the suggestion from Kirill. Not use "||=" style to keep checkpatch
quiet, otherwise it reports ERROR: spaces required around that '||'

 mm/page_idle.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/page_idle.c b/mm/page_idle.c
index 0a49374..e412a63 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -65,11 +65,15 @@ static bool page_idle_clear_pte_refs_one(struct page *page,
 	while (page_vma_mapped_walk(&pvmw)) {
 		addr = pvmw.address;
 		if (pvmw.pte) {
-			referenced = ptep_clear_young_notify(vma, addr,
-					pvmw.pte);
+			/*
+			 * For PTE-mapped THP, one sub page is referenced,
+			 * the whole THP is referenced.
+			 */
+			if (ptep_clear_young_notify(vma, addr, pvmw.pte))
+				referenced = true;
 		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
-			referenced = pmdp_clear_young_notify(vma, addr,
-					pvmw.pmd);
+			if (pmdp_clear_young_notify(vma, addr, pvmw.pmd))
+				referenced = true;
 		} else {
 			/* unexpected pmd-mapped page? */
 			WARN_ON_ONCE(1);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
