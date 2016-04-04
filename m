Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C6D776B0005
	for <linux-mm@kvack.org>; Sun,  3 Apr 2016 21:39:26 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id e128so111133074pfe.3
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 18:39:26 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h9si18573514pap.227.2016.04.03.18.39.25
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 18:39:25 -0700 (PDT)
Date: Mon, 4 Apr 2016 10:39:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
Message-ID: <20160404013917.GC6543@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
 <56FE706D.7080507@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56FE706D.7080507@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Fri, Apr 01, 2016 at 02:58:21PM +0200, Vlastimil Babka wrote:
> On 03/30/2016 09:12 AM, Minchan Kim wrote:
> >Procedure of page migration is as follows:
> >
> >First of all, it should isolate a page from LRU and try to
> >migrate the page. If it is successful, it releases the page
> >for freeing. Otherwise, it should put the page back to LRU
> >list.
> >
> >For LRU pages, we have used putback_lru_page for both freeing
> >and putback to LRU list. It's okay because put_page is aware of
> >LRU list so if it releases last refcount of the page, it removes
> >the page from LRU list. However, It makes unnecessary operations
> >(e.g., lru_cache_add, pagevec and flags operations. It would be
> >not significant but no worth to do) and harder to support new
> >non-lru page migration because put_page isn't aware of non-lru
> >page's data structure.
> >
> >To solve the problem, we can add new hook in put_page with
> >PageMovable flags check but it can increase overhead in
> >hot path and needs new locking scheme to stabilize the flag check
> >with put_page.
> >
> >So, this patch cleans it up to divide two semantic(ie, put and putback).
> >If migration is successful, use put_page instead of putback_lru_page and
> >use putback_lru_page only on failure. That makes code more readable
> >and doesn't add overhead in put_page.
> >
> >Comment from Vlastimil
> >"Yeah, and compaction (perhaps also other migration users) has to drain
> >the lru pvec... Getting rid of this stuff is worth even by itself."
> >
> >Cc: Mel Gorman <mgorman@suse.de>
> >Cc: Hugh Dickins <hughd@google.com>
> >Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> [...]
> 
> >@@ -974,28 +986,28 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
> >  		list_del(&page->lru);
> >  		dec_zone_page_state(page, NR_ISOLATED_ANON +
> >  				page_is_file_cache(page));
> >-		/* Soft-offlined page shouldn't go through lru cache list */
> >+	}
> >+
> >+	/*
> >+	 * If migration is successful, drop the reference grabbed during
> >+	 * isolation. Otherwise, restore the page to LRU list unless we
> >+	 * want to retry.
> >+	 */
> >+	if (rc == MIGRATEPAGE_SUCCESS) {
> >+		put_page(page);
> >  		if (reason == MR_MEMORY_FAILURE) {
> >-			put_page(page);
> >  			if (!test_set_page_hwpoison(page))
> >  				num_poisoned_pages_inc();
> >-		} else
> >+		}
> 
> Hmm, I didn't notice it previously, or it's due to rebasing, but it
> seems that you restricted the memory failure handling (i.e. setting
> hwpoison) to MIGRATE_SUCCESS, while previously it was done for all
> non-EAGAIN results. I think that goes against the intention of
> hwpoison, which is IIRC to catch and kill the poor process that
> still uses the page?

That's why I Cc'ed Naoya Horiguchi to catch things I might make
mistake.

Thanks for catching it, Vlastimil.
It was my mistake. But in this chance, I looked over hwpoison code and
I saw other places which increases num_poisoned_pages are successful
migration, already freed page and successful invalidated page.
IOW, they are already successful isolated page so I guess it should
increase the count when only successful migration is done?
And when I read memory_failure, it bails out without killing if it
encounters HWPoisoned page so I think it's not for catching and
kill the poor proces.

> 
> Also (but not your fault) the put_page() preceding
> test_set_page_hwpoison(page)) IMHO deserves a comment saying which
> pin we are releasing and which one we still have (hopefully? if I
> read description of da1b13ccfbebe right) otherwise it looks like
> doing something with a page that we just potentially freed.

Yes, while I read the code, I had same question. I think the releasing
refcount is for get_any_page.

Naoya, could you answer above two questions?

Thanks.

> 
> >+	} else {
> >+		if (rc != -EAGAIN)
> >  			putback_lru_page(page);
> >+		if (put_new_page)
> >+			put_new_page(newpage, private);
> >+		else
> >+			put_page(newpage);
> >  	}
> >
> >-	/*
> >-	 * If migration was not successful and there's a freeing callback, use
> >-	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
> >-	 * during isolation.
> >-	 */
> >-	if (put_new_page)
> >-		put_new_page(newpage, private);
> >-	else if (unlikely(__is_movable_balloon_page(newpage))) {
> >-		/* drop our reference, page already in the balloon */
> >-		put_page(newpage);
> >-	} else
> >-		putback_lru_page(newpage);
> >-
> >  	if (result) {
> >  		if (rc)
> >  			*result = rc;
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
