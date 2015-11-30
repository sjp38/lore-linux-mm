Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BB7F36B025F
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 01:39:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so174826014pad.1
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 22:39:45 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id hp4si7845885pad.113.2015.11.29.22.39.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 29 Nov 2015 22:39:30 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 06/12] mm: mark stable page dirty in KSM
Date: Mon, 30 Nov 2015 15:39:37 +0900
Message-Id: <1448865583-2446-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1448865583-2446-1-git-send-email-minchan@kernel.org>
References: <1448865583-2446-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>

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
index 30cb0f753e19..5e967536c38e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1015,6 +1015,12 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
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
