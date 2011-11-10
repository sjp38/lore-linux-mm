Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 41CFF6B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 21:23:22 -0500 (EST)
Received: by vcbfo11 with SMTP id fo11so1208626vcb.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 18:23:19 -0800 (PST)
Date: Thu, 10 Nov 2011 11:23:06 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 5/5]thp: split huge page if head page is isolated
Message-ID: <20111110022306.GA8082@barrios-laptop.redhat.com>
References: <20111029000624.GA1261@barrios-laptop.redhat.com>
 <1320024088.22361.176.camel@sli10-conroe>
 <20111031082317.GA21440@barrios-laptop.redhat.com>
 <1320051813.22361.182.camel@sli10-conroe>
 <1320203876.22361.192.camel@sli10-conroe>
 <20111108085952.GA15142@barrios-laptop.redhat.com>
 <1320816475.22361.216.camel@sli10-conroe>
 <20111109062807.GA15525@barrios-laptop.redhat.com>
 <1320822509.22361.217.camel@sli10-conroe>
 <1320890830.22361.226.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1320890830.22361.226.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

So long contents.
Let's remove it.

On Thu, Nov 10, 2011 at 10:07:10AM +0800, Shaohua Li wrote:

<snip>

> > > Coudn't we make both sides good?
> > > 
> > > Here is my quick patch.
> > > How about this?
> > > It doesn't split THPs in page_list but still reclaims non-THPs so
> > > I think it doesn't changed old behavior a lot.
> > I like this idea, will do some test soon.
> hmm, this doesn't work as expected. The putback_lru_page() messes lru.
> This isn't a problem if the page will be written since
> rotate_reclaimable_page() will fix the order. I got worse data than my
> v2 patch, eg, more thp_fallbacks, mess lru order, more pages are
> scanned. We could add something like putback_lru_page_tail, but I'm not

Hmm, It's not LRU mess problem. but it's just guessing and you might be right
because you have a workload and can test it.

My guessing is that cull_mlocked reset synchronus page reclaim.
Could you test this patch, again?

And, if the problem cause by LRU mess, I think it is valuable with adding putback_lru_page_tail
because thp added lru_add_page_tail, too.

Thanks!

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b55699c..e2c84c2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -767,6 +767,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_dirty = 0;
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
+	bool split_thp = false;
+	bool swapout_thp = false;
 
 	cond_resched();
 
@@ -784,6 +786,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!trylock_page(page))
 			goto keep;
 
+		/*
+		 * If we already swap out a THP, we don't want to
+		 * split THPs any more. Let's wait until dirty a thp page
+		 * to be written into swap device
+		 */
+		if (unlikely(swapout_thp && PageTransHuge(page)))
+			goto pass_thp;
+
 		VM_BUG_ON(PageActive(page));
 		VM_BUG_ON(page_zone(page) != zone);
 
@@ -838,6 +848,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
+			if (unlikely(PageTransHuge(page)))
+				if (unlikely(split_huge_page_list(page,
+					page_list)))
+				    goto activate_locked;
+				else
+					split_thp = true;
 			if (!add_to_swap(page))
 				goto activate_locked;
 			may_enter_fs = 1;
@@ -880,6 +896,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			case PAGE_ACTIVATE:
 				goto activate_locked;
 			case PAGE_SUCCESS:
+				if (split_thp)
+					swapout_thp = true;
 				if (PageWriteback(page))
 					goto keep_lumpy;
 				if (PageDirty(page))
@@ -962,6 +980,10 @@ free_it:
 		list_add(&page->lru, &free_pages);
 		continue;
 
+pass_thp:
+		unlock_page(page);
+		putback_lru_page(page);
+		continue;
 cull_mlocked:
 		if (PageSwapCache(page))
 			try_to_free_swap(page);

> convinced it's worthy(even with it, we still will mess lru a little). So
> I'm back to use the v2 patch if no better solution, it's still much
> better than current code.
> 
> Thanks,
> Shaohua
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
