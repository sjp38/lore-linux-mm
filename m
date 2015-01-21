Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id A6B906B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:13:42 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id ar1so9213435iec.6
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:13:42 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id qo12si5087451igb.38.2015.01.20.22.13.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 22:13:41 -0800 (PST)
From: Shiraz Hashim <shashim@codeaurora.org>
Subject: [PATCH] mm: pagewalk: call pte_hole() for VM_PFNMAP during walk_page_range
Date: Wed, 21 Jan 2015 11:43:13 +0530
Message-Id: <1421820793-28883-1-git-send-email-shashim@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, Shiraz Hashim <shashim@codeaurora.org>

walk_page_range silently skips vma having VM_PFNMAP set,
which leads to undesirable behaviour at client end (who
called walk_page_range). For example for pagemap_read,
when no callbacks are called against VM_PFNMAP vma,
pagemap_read may prepare pagemap data for next virtual
address range at wrong index.

Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>
---
The fix is revised, based upon the suggestion here at
http://www.spinics.net/lists/linux-mm/msg83058.html

 mm/pagewalk.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index ad83195..b264bda 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -199,7 +199,10 @@ int walk_page_range(unsigned long addr, unsigned long end,
 			 */
 			if ((vma->vm_start <= addr) &&
 			    (vma->vm_flags & VM_PFNMAP)) {
-				next = vma->vm_end;
+				if (walk->pte_hole)
+					err = walk->pte_hole(addr, next, walk);
+				if (err)
+					break;
 				pgd = pgd_offset(walk->mm, next);
 				continue;
 			}
-- 
Shiraz Hashim

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
