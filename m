Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3878D6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:09:36 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so22384734pac.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 04:09:36 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ze3si1693005pac.193.2016.01.21.04.09.35
        for <linux-mm@kvack.org>;
        Thu, 21 Jan 2016 04:09:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/3] thp: limit number of object to scan on deferred_split_scan()
Date: Thu, 21 Jan 2016 15:09:23 +0300
Message-Id: <1453378163-133609-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20160121012237.GE7119@redhat.com>
 <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If we have a lot of pages in queue to be split, deferred_split_scan()
can spend unreasonable amount of time under spinlock with disabled
interrupts.

Let's cap number of pages to split on scan by sc->nr_to_scan.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 36f98459f854..298dbc001b07 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3478,17 +3478,19 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	int split = 0;
 
 	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	list_splice_init(&pgdata->split_queue, &list);
-
 	/* Take pin on all head pages to avoid freeing them under us */
 	list_for_each_safe(pos, next, &list) {
 		page = list_entry((void *)pos, struct page, mapping);
 		page = compound_head(page);
-		/* race with put_compound_page() */
-		if (!get_page_unless_zero(page)) {
+		if (get_page_unless_zero(page)) {
+			list_move(page_deferred_list(page), &list);
+		} else {
+			/* We lost race with put_compound_page() */
 			list_del_init(page_deferred_list(page));
 			pgdata->split_queue_len--;
 		}
+		if (!--sc->nr_to_scan)
+			break;
 	}
 	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
