Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 791B36B002E
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 17:33:18 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/2] s390: gup_huge_pmd() return 0 if pte changes
Date: Mon, 17 Oct 2011 23:32:51 +0200
Message-Id: <1318887172-5854-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1318887172-5854-1-git-send-email-aarcange@redhat.com>
References: <1316793432.9084.47.camel@twins>
 <1318887172-5854-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

s390 didn't return 0 in that case, if it's rolling back the *nr
pointer it should also return zero to avoid adding pages to the array
at the wrong offset.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/s390/mm/gup.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 668dda9..da33a02 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -93,16 +93,17 @@ static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 		*nr -= refs;
 		while (refs--)
 			put_page(head);
-	} else {
-		/*
-		 * Any tail page need their mapcount reference taken
-		 * before we return.
-		 */
-		while (refs--) {
-			if (PageTail(tail))
-				get_huge_page_tail(tail);
-			tail++;
-		}
+		return 0;
+	}
+
+	/*
+	 * Any tail page need their mapcount reference taken before we
+	 * return.
+	 */
+	while (refs--) {
+		if (PageTail(tail))
+			get_huge_page_tail(tail);
+		tail++;
 	}
 
 	return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
