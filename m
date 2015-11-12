Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0D96B0257
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:32:51 -0500 (EST)
Received: by pasz6 with SMTP id z6so54057605pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:32:51 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id t13si17195704pas.21.2015.11.11.20.32.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:32:45 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 07/17] mm: mark stable page dirty in KSM
Date: Thu, 12 Nov 2015 13:33:03 +0900
Message-Id: <1447302793-5376-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1447302793-5376-1-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

The MADV_FREE patchset changes page reclaim to simply free a clean
anonymous page with no dirty ptes, instead of swapping it out; but
KSM uses clean write-protected ptes to reference the stable ksm page.
So be sure to mark that page dirty, so it's never mistakenly discarded.

[hughd: adjusted comments]
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/ksm.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 7ee101eaacdf..18d2b7afecff 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1053,6 +1053,12 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 			 */
 			set_page_stable_node(page, NULL);
 			mark_page_accessed(page);
+			/*
+			 * Page reclaim just frees a clean page with no dirty
+			 * ptes: make sure that the ksm page would be swapped.
+			 */
+			if (!PageDirty(page))
+				SetPageDirty(page);
 			err = 0;
 		} else if (pages_identical(page, kpage))
 			err = replace_page(vma, page, kpage, orig_pte);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
