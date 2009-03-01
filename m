Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 928AA6B00A2
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 05:37:44 -0500 (EST)
Date: Sun, 1 Mar 2009 19:37:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for mmotm] remove pagevec_swap_free()
In-Reply-To: <Pine.LNX.4.64.0902252022460.19132@blonde.anvils>
References: <20090225192550.GA5645@cmpxchg.org> <Pine.LNX.4.64.0902252022460.19132@blonde.anvils>
Message-Id: <20090301190227.6FDB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wed, 25 Feb 2009, Johannes Weiner wrote:
> 
> > The pagevec_swap_free() at the end of shrink_active_list() was
> > introduced in 68a22394 "vmscan: free swap space on swap-in/activation"
> > when shrink_active_list() was still rotating referenced active pages.
> > 
> > In 7e9cd48 "vmscan: fix pagecache reclaim referenced bit check" this
> > was changed, the rotating removed but the pagevec_swap_free() after
> > the rotation loop was forgotten, applying now to the pagevec of the
> > deactivation loop instead.
> > 
> > Now swap space is freed for deactivated pages.  And only for those
> > that happen to be on the pagevec after the deactivation loop.
> > 
> > Complete 7e9cd48 and remove the rest of the swap freeing.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> 
> Nice observation.  I was going to object that the original code was
> indifferent to whether it was freeing swap from active or inactive,
> they all got lumped into the same pvec.  But that was just an oversight
> in the original code: you're right that if it was our intention to free
> swap from inactive pages here (when vm_swap_full), then we'd be freeing
> it from them in the loop above (where the buffer_heads_over_limit
> pagevec_strip is done).
> 
> Once upon a time (early 2007), testing an earlier incarnation of that
> code, I did find almost nothing being freed by that pagevec_swap_free
> anyway: other vm_swap_full frees were being effective, effective
> enough to render this one rather pointless, even when it was operating
> as intended.  But I never got around to checking on that in 2008's
> splitLRU patches, and a lot changed in between: I may be misleading.
>
> If Rik agrees (I think these do need his Ack), note that there are
> no other users of pagevec_swap_free, so you'd do well to remove it
> from mm/swap.c and include/linux/pagevec.h - I can well imagine us
> wanting to bring it back some time, but can easily look it up when
> and if we do need it again in the future.

Yup, removing is better.


==========
Subject: [PATCH] remove pagevec_swap_free()

pagevec_swap_free() is unused. 
then it can be removed.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>
---
 include/linux/pagevec.h |    1 -
 mm/swap.c               |   23 -----------------------
 2 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 7b2886f..bab82f4 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -24,7 +24,6 @@ void __pagevec_release(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
 void pagevec_strip(struct pagevec *pvec);
-void pagevec_swap_free(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
diff --git a/mm/swap.c b/mm/swap.c
index eee08df..d33e499 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -471,29 +471,6 @@ void pagevec_strip(struct pagevec *pvec)
 }
 
 /**
- * pagevec_swap_free - try to free swap space from the pages in a pagevec
- * @pvec: pagevec with swapcache pages to free the swap space of
- *
- * The caller needs to hold an extra reference to each page and
- * not hold the page lock on the pages.  This function uses a
- * trylock on the page lock so it may not always free the swap
- * space associated with a page.
- */
-void pagevec_swap_free(struct pagevec *pvec)
-{
-	int i;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-
-		if (PageSwapCache(page) && trylock_page(page)) {
-			try_to_free_swap(page);
-			unlock_page(page);
-		}
-	}
-}
-
-/**
  * pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
  * @mapping:	The address_space to search
-- 
1.6.0.6



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
