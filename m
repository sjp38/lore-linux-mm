Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id EEF636B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 09:33:57 -0400 (EDT)
Message-ID: <201205011333.q41DXsK7026759@farm-0013.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Sun, 29 Apr 2012 15:04:51 -0400
Subject: Re: [PATCH] hugetlb: avoid gratuitous BUG_ON in hugetlb_fault() ->
 hugetlb_cow()
In-Reply-To: <20120501131413.GA11435@suse.de>
References: <201204291936.q3TJa4Mv008924@farm-0027.internal.tilera.com>
 <alpine.LSU.2.00.1204301308090.2829@eggly.anvils>
 <20120501131413.GA11435@suse.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 66aebce747eaf added code to avoid a race condition by
elevating the page refcount in hugetlb_fault() while calling
hugetlb_cow().  However, one code path in hugetlb_cow() includes
an assertion that the page count is 1, whereas it may now also
have the value 2 in this path.  Consensus is that this BUG_ON
has served its purpose, so rather than extending it to cover both
cases, we just remove it.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 mm/hugetlb.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index cd65cb1..baaad5d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2498,7 +2498,6 @@ retry_avoidcopy:
 		if (outside_reserve) {
 			BUG_ON(huge_pte_none(pte));
 			if (unmap_ref_private(mm, vma, old_page, address)) {
-				BUG_ON(page_count(old_page) != 1);
 				BUG_ON(huge_pte_none(pte));
 				spin_lock(&mm->page_table_lock);
 				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
