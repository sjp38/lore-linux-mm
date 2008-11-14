Date: Fri, 14 Nov 2008 02:33:51 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2.6.28?] let GFP_NOFS go to swap again
Message-ID: <Pine.LNX.4.64.0811140232260.5027@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the past, GFP_NOFS (but of course not GFP_NOIO) was allowed to reclaim
by writing to swap.  That got partially broken in 2.6.23, when may_enter_fs
initialization was moved up before the allocation of swap, so its
PageSwapCache test was failing the first time around,

Fix it by setting may_enter_fs when add_to_swap() succeeds with
__GFP_IO.  In fact, check __GFP_IO before calling add_to_swap():
allocating swap we're not ready to use just increases disk seeking.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Perhaps this is too late for 2.6.28: your decision.

 mm/vmscan.c |    3 +++
 1 file changed, 3 insertions(+)

--- 2.6.28-rc4/mm/vmscan.c	2008-10-24 09:28:26.000000000 +0100
+++ linux/mm/vmscan.c	2008-11-12 11:52:44.000000000 +0000
@@ -623,6 +623,8 @@ static unsigned long shrink_page_list(st
 		 * Try to allocate it some swap space here.
 		 */
 		if (PageAnon(page) && !PageSwapCache(page)) {
+			if (!(sc->gfp_mask & __GFP_IO))
+				goto keep_locked;
 			switch (try_to_munlock(page)) {
 			case SWAP_FAIL:		/* shouldn't happen */
 			case SWAP_AGAIN:
@@ -634,6 +636,7 @@ static unsigned long shrink_page_list(st
 			}
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
+			may_enter_fs = 1;
 		}
 #endif /* CONFIG_SWAP */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
