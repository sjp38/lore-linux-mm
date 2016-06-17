Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C25C66B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 22:30:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so137275771pfb.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 19:30:14 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id b72si9411346pfc.221.2016.06.16.19.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 19:30:14 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t190so5115818pfb.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 19:30:13 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 2/2] mm: rmap: call page_check_address() with sync enabled to avoid racy check
Date: Fri, 17 Jun 2016 11:30:04 +0900
Message-Id: <1466130604-20484-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1466130604-20484-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1466130604-20484-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

The previous patch addresses the race between split_huge_pmd_address() and
someone changing the pmd. The fix is only for splitting of normal thp
(i.e. pmd-mapped thp,) and for splitting of pte-mapped thp there still is
the similar race.

For splitting pte-mapped thp, the pte's conversion is done by
try_to_unmap_one(TTU_MIGRATION). This function checks page_check_address() to
get the target pte, but it can return NULL under some race, leading to
VM_BUG_ON() in freeze_page(). Fortunately, page_check_address() already has
an argument to decide whether we do a quick/racy check or not, so let's flip
it when called from freeze_page().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/rmap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git v4.6/mm/rmap.c v4.6_patched/mm/rmap.c
index 4282b56..c357fb36 100644
--- v4.6/mm/rmap.c
+++ v4.6_patched/mm/rmap.c
@@ -1424,7 +1424,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			goto out;
 	}
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
+	pte = page_check_address(page, mm, address, &ptl,
+				 PageTransCompound(page));
 	if (!pte)
 		goto out;
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
