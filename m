Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 288486B002F
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 16:40:54 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/4] powerpc: get_hugepte() don't put_page() the wrong page
Date: Sun, 16 Oct 2011 22:40:37 +0200
Message-Id: <1318797639-26962-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1316793432.9084.47.camel@twins>
References: <1316793432.9084.47.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

"page" may have changed to point to the next hugepage after the loop
completed, The references have been taken on the head page, so the
put_page must happen there too.

This is a longstanding issue pre-thp inclusion.

It's totally unclear how these page_cache_add_speculative and
pte_val(pte) != pte_val(*ptep) checks are necessary across all the
powerpc gup_fast code, when x86 doesn't need any of that: there's no way
the page can be freed with irq disabled so we're guaranteed the
atomic_inc will happen on a page with page_count > 0 (so not needing the
speculative check). The pte check is also meaningless on x86: no need to
rollback on x86 if the pte changed, because the pte can still change a
CPU tick after the check succeeded and it won't be rolled back in that
case. The important thing is we got a reference on a valid page that was
mapped there a CPU tick ago. So not knowing the soft tlb refill code of
ppc64 in great detail I'm not removing the "speculative" page_count
increase and the pte checks across all the code, but unless there's a
strong reason for it they should be later cleaned up too.

If a pte can change from huge to non-huge (like it could happen with
THP) passing a pte_t *ptep to gup_hugepte() would also require to repeat
the is_hugepd in gup_hugepte(), but that shouldn't happen with hugetlbfs
only so I'm not altering that.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 0b9a5c1..b649c28 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -429,7 +429,7 @@ static noinline int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long add
 	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
 		/* Could be optimized better */
 		while (*nr) {
-			put_page(page);
+			put_page(head);
 			(*nr)--;
 		}
 	}
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
