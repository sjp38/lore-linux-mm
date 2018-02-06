Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8561E6B0003
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 19:07:12 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x11so189798pgr.9
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 16:07:12 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id b11-v6si680746plr.8.2018.02.05.16.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 16:07:11 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm: thp: fix potential clearing to referenced flag in page_idle_clear_pte_refs_one()
Date: Tue,  6 Feb 2018 08:06:36 +0800
Message-Id: <1517875596-76350-1-git-send-email-yang.shi@linux.alibaba.com>
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

So, here just break pvmw walk once referenced PTE is found if the page
is a part of THP.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Reported-by: Gang Deng <gavin.dg@linux.alibaba.com>
---
 mm/page_idle.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/page_idle.c b/mm/page_idle.c
index 0a49374..da6024f 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -67,6 +67,14 @@ static bool page_idle_clear_pte_refs_one(struct page *page,
 		if (pvmw.pte) {
 			referenced = ptep_clear_young_notify(vma, addr,
 					pvmw.pte);
+			/*
+			 * For PTE-mapped THP, one sub page is referenced,
+			 * the whole THP is referenced.
+			 */
+			if (referenced && PageTransCompound(pvmw.page)) {
+				page_vma_mapped_walk_done(&pvmw);
+				break;
+			}
 		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
 			referenced = pmdp_clear_young_notify(vma, addr,
 					pvmw.pmd);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
