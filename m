Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A53AB6B0253
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:09:38 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id yy13so22353710pab.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 04:09:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ze3si1693005pac.193.2016.01.21.04.09.35
        for <linux-mm@kvack.org>;
        Thu, 21 Jan 2016 04:09:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/3] thp: change deferred_split_count() to return number of THP in queue
Date: Thu, 21 Jan 2016 15:09:22 +0300
Message-Id: <1453378163-133609-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20160121012237.GE7119@redhat.com>
 <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've got meaning of shrinker::count_objects() wrong: it should return
number of potentially freeable objects, which is not necessary correlate
with freeable memory.

Returning 256 per THP in queue is not reasonable:
shrinker::scan_objects() never called with nr_to_scan > 128 in my setup.

Let's return 1 per THP and correct scan_object accordingly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 769ea8db5771..36f98459f854 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3465,12 +3465,7 @@ static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	/*
-	 * Split a page from split_queue will free up at least one page,
-	 * at most HPAGE_PMD_NR - 1. We don't track exact number.
-	 * Let's use HPAGE_PMD_NR / 2 as ballpark.
-	 */
-	return ACCESS_ONCE(pgdata->split_queue_len) * HPAGE_PMD_NR / 2;
+	return ACCESS_ONCE(pgdata->split_queue_len);
 }
 
 static unsigned long deferred_split_scan(struct shrinker *shrink,
@@ -3511,7 +3506,7 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	list_splice_tail(&list, &pgdata->split_queue);
 	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 
-	return split * HPAGE_PMD_NR / 2;
+	return split;
 }
 
 static struct shrinker deferred_split_shrinker = {
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
