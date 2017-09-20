Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB056B02D0
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 18:37:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a7so6855954pfj.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:37:37 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z3si991plo.317.2017.09.20.15.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 15:37:35 -0700 (PDT)
Date: Wed, 20 Sep 2017 15:37:33 -0700
From: Shaohua Li <shli@kernel.org>
Subject: Re: MADV_FREE is broken
Message-ID: <20170920223733.2cwkb52wh2bozori@kernel.org>
References: <20170920090147.5iqdkctmw7ujlmt3@shodan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920090147.5iqdkctmw7ujlmt3@shodan.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Savkov <asavkov@redhat.com>
Cc: Shaohua Li <shli@fb.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 20, 2017 at 11:01:47AM +0200, Artem Savkov wrote:
> Hi All,
> 
> We recently started noticing madvise09[1] test from ltp failing strangely. The
> test does the following: maps 32 pages, sets MADV_FREE for the range it got,
> dirties 2 of the pages, creates memory pressure and check that nondirty pages
> are free. The test hanged while accessing the last 4 pages(29-32) of madvised
> range at line 121 [2]. Any other process (gdb/cat) accessing those pages
> would also hang as would rebooting the machine. It doesn't trigger any debug
> warnings or kasan.
> 
> The issue bisected to "802a3a92ad7a mm: reclaim MADV_FREE pages" (so 4.12 and
> up are affected).
> 
> I did some poking around and found out that the "bad" pages had SwapBacked flag
> set in shrink_page_list() which confused it a lot. It looks like
> mark_page_lazyfree() only calls lru_lazyfree_fn() when the pagevec is full
> (that is in batches of 14) and never drains the rest (so last four in madvise09
> case).
> 
> The patch below greatly reduces the failure rate, but doesn't fix it
> completely, it still shows up with the same symptoms (hanging trying to access
> last 4 pages) after a bunch of retries.
> 
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise09.c
> [2] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise09.c#L121
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 21261ff0466f..a0b868e8b7d2 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -453,6 +453,7 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
>  
>  	tlb_start_vma(tlb, vma);
>  	walk_page_range(addr, end, &free_walk);
> +	lru_add_drain();
>  	tlb_end_vma(tlb, vma);
>  }

Looks there is a race between clear pte dirty bit and clear SwapBacked bit.
draining the vect helps a little, but not sufficient. If SwapBacked is set, we
could add the page to swapcache, but since we the page isn't dirty, we don't
write the page out. This could cause data corruption. There is another place we
wrongly clear SwapBacked bit. Below is a test patch which seems to fix the
issue, please give a try.


diff --git a/mm/swap.c b/mm/swap.c
index 62d96b8..5c58257 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -575,7 +575,7 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 			    void *arg)
 {
 	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
-	    !PageUnevictable(page)) {
+	    !PageSwapCache(page) && !PageUnevictable(page)) {
 		bool active = PageActive(page);
 
 		del_page_from_lru_list(page, lruvec,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13d711d..be1c98e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -980,6 +980,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		bool new_added_swapcache = false;
 
 		cond_resched();
 
@@ -1165,6 +1166,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 				/* Adding to swap updated mapping */
 				mapping = page_mapping(page);
+				new_added_swapcache = true;
 			}
 		} else if (unlikely(PageTransHuge(page))) {
 			/* Split file THP */
@@ -1185,6 +1187,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				nr_unmap_fail++;
 				goto activate_locked;
 			}
+			/* race with MADV_FREE */
+			if (PageAnon(page) && !PageDirty(page) &&
+			    PageSwapBacked(page) && new_added_swapcache)
+				set_page_dirty(page);
 		}
 
 		if (PageDirty(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
