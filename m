Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 98FA76B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 01:38:25 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id td3so136091241pab.2
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 22:38:25 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i76si39262357pfj.182.2016.04.03.22.38.23
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 22:38:24 -0700 (PDT)
Date: Mon, 4 Apr 2016 14:38:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: mm/hwpoison: fix wrong num_poisoned_pages account
Message-ID: <20160404053830.GA7042@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "bfields@fieldses.org" <bfields@fieldses.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "aquini@redhat.com" <aquini@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, "rknize@motorola.com" <rknize@motorola.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>


Forking new thread,

Hello Naoya,

On Mon, Apr 04, 2016 at 04:45:12AM +0000, Naoya Horiguchi wrote:
> On Mon, Apr 04, 2016 at 10:39:17AM +0900, Minchan Kim wrote:
> > On Fri, Apr 01, 2016 at 02:58:21PM +0200, Vlastimil Babka wrote:
> > > On 03/30/2016 09:12 AM, Minchan Kim wrote:
> > > >Procedure of page migration is as follows:
> > > >
> > > >First of all, it should isolate a page from LRU and try to
> > > >migrate the page. If it is successful, it releases the page
> > > >for freeing. Otherwise, it should put the page back to LRU
> > > >list.
> > > >
> > > >For LRU pages, we have used putback_lru_page for both freeing
> > > >and putback to LRU list. It's okay because put_page is aware of
> > > >LRU list so if it releases last refcount of the page, it removes
> > > >the page from LRU list. However, It makes unnecessary operations
> > > >(e.g., lru_cache_add, pagevec and flags operations. It would be
> > > >not significant but no worth to do) and harder to support new
> > > >non-lru page migration because put_page isn't aware of non-lru
> > > >page's data structure.
> > > >
> > > >To solve the problem, we can add new hook in put_page with
> > > >PageMovable flags check but it can increase overhead in
> > > >hot path and needs new locking scheme to stabilize the flag check
> > > >with put_page.
> > > >
> > > >So, this patch cleans it up to divide two semantic(ie, put and putback).
> > > >If migration is successful, use put_page instead of putback_lru_page and
> > > >use putback_lru_page only on failure. That makes code more readable
> > > >and doesn't add overhead in put_page.
> > > >
> > > >Comment from Vlastimil
> > > >"Yeah, and compaction (perhaps also other migration users) has to drain
> > > >the lru pvec... Getting rid of this stuff is worth even by itself."
> > > >
> > > >Cc: Mel Gorman <mgorman@suse.de>
> > > >Cc: Hugh Dickins <hughd@google.com>
> > > >Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > > >Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > 
> > > [...]
> > > 
> > > >@@ -974,28 +986,28 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
> > > >  		list_del(&page->lru);
> > > >  		dec_zone_page_state(page, NR_ISOLATED_ANON +
> > > >  				page_is_file_cache(page));
> > > >-		/* Soft-offlined page shouldn't go through lru cache list */
> > > >+	}
> > > >+
> > > >+	/*
> > > >+	 * If migration is successful, drop the reference grabbed during
> > > >+	 * isolation. Otherwise, restore the page to LRU list unless we
> > > >+	 * want to retry.
> > > >+	 */
> > > >+	if (rc == MIGRATEPAGE_SUCCESS) {
> > > >+		put_page(page);
> > > >  		if (reason == MR_MEMORY_FAILURE) {
> > > >-			put_page(page);
> > > >  			if (!test_set_page_hwpoison(page))
> > > >  				num_poisoned_pages_inc();
> > > >-		} else
> > > >+		}
> > > 
> > > Hmm, I didn't notice it previously, or it's due to rebasing, but it
> > > seems that you restricted the memory failure handling (i.e. setting
> > > hwpoison) to MIGRATE_SUCCESS, while previously it was done for all
> > > non-EAGAIN results. I think that goes against the intention of
> > > hwpoison, which is IIRC to catch and kill the poor process that
> > > still uses the page?
> > 
> > That's why I Cc'ed Naoya Horiguchi to catch things I might make
> > mistake.
> > 
> > Thanks for catching it, Vlastimil.
> > It was my mistake. But in this chance, I looked over hwpoison code and
> > I saw other places which increases num_poisoned_pages are successful
> > migration, already freed page and successful invalidated page.
> > IOW, they are already successful isolated page so I guess it should
> > increase the count when only successful migration is done?
> 
> Yes, that's right. When exiting with migration's failure, we shouldn't call
> test_set_page_hwpoison or num_poisoned_pages_inc, so current code checking
> (rc != -EAGAIN) is simply incorrect. Your change fixes the bug in memory
> error handling. Great!

Thanks for confirming, Naoya.
I will send it as separate patch with Ccing -stable.

> 
> > And when I read memory_failure, it bails out without killing if it
> > encounters HWPoisoned page so I think it's not for catching and
> > kill the poor proces.
> >
> > > 
> > > Also (but not your fault) the put_page() preceding
> > > test_set_page_hwpoison(page)) IMHO deserves a comment saying which
> > > pin we are releasing and which one we still have (hopefully? if I
> > > read description of da1b13ccfbebe right) otherwise it looks like
> > > doing something with a page that we just potentially freed.
> >
> > Yes, while I read the code, I had same question. I think the releasing
> > refcount is for get_any_page.
> 
> As the other callers of page migration do, soft_offline_page expects the
> migration source page to be freed at this put_page() (no pin remains.)
> The refcount released here is from isolate_lru_page() in __soft_offline_page().
> (the pin by get_any_page is released by put_hwpoison_page just after it.)
> 
> .. yes, doing something just after freeing page looks weird, but that's
> how PageHWPoison flag works. IOW, many other page flags are maintained
> only during one "allocate-free" life span, but PageHWPoison still does
> its job beyond it.

Got it. Thanks for the clarification.

> 
> As for commenting, this put_page() is called in any MIGRATEPAGE_SUCCESS
> case (regardless of callers), so what we can say here is "we free the
> source page here, bypassing LRU list" or something?

Naoya, I wrote up the patch but hard to say I write up correct description.
Could you review this?

Thankks.
