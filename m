Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5618D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 01:51:07 -0400 (EDT)
Received: by pzk32 with SMTP id 32so1191034pzk.14
        for <linux-mm@kvack.org>; Sat, 23 Apr 2011 22:51:05 -0700 (PDT)
Date: Sun, 24 Apr 2011 14:50:58 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Check PageActive when evictable page and unevicetable
 page race happen
Message-ID: <20110424055058.GA1826@barrios-desktop>
References: <1303604751-4980-1-git-send-email-minchan.kim@gmail.com>
 <BANLkTimzg184ZWraBomJ8ex1-B4Ypj6D9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTimzg184ZWraBomJ8ex1-B4Ypj6D9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>

Hi KOSAKI,

On Sun, Apr 24, 2011 at 12:02:57PM +0900, KOSAKI Motohiro wrote:
> 2011/4/24 Minchan Kim <minchan.kim@gmail.com>:
> > In putback_lru_page, unevictable page can be changed into evictable
> > 's one while we move it among lru. So we have checked it again and
> > rescued it. But we don't check PageActive, again. It could add
> > active page into inactive list so we can see the BUG in isolate_lru_pages.
> > (But I didn't see any report because I think it's very subtle)
> >
> > It could happen in race that zap_pte_range's mark_page_accessed and
> > putback_lru_page. It's subtle but could be possible.
> >
> > Note:
> > While I review the code, I found it. So it's not real report.
> >
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/vmscan.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index b3a569f..c0cd1aa 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -562,7 +562,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
> >  void putback_lru_page(struct page *page)
> >  {
> >        int lru;
> > -       int active = !!TestClearPageActive(page);
> > +       int active;
> >        int was_unevictable = PageUnevictable(page);
> >
> >        VM_BUG_ON(PageLRU(page));
> > @@ -571,6 +571,7 @@ redo:
> >        ClearPageUnevictable(page);
> >
> >        if (page_evictable(page, NULL)) {
> > +               active = !!TestClearPageActive(page);
> >                /*
> >                 * For evictable pages, we can use the cache.
> >                 * In event of a race, worst case is we end up with an
> > @@ -584,6 +585,7 @@ redo:
> >                 * Put unevictable pages directly on zone's unevictable
> >                 * list.
> >                 */
> > +               ClearPageActive(page);
> >                lru = LRU_UNEVICTABLE;
> >                add_page_to_unevictable_list(page);
> 
> I think we forgot 'goto redo' case. following patch is better?
> 
> ------------------------------------------------
>         if (page_evictable(page, NULL)) {
>                 /*
>                  * For evictable pages, we can use the cache.
>                  * In event of a race, worst case is we end up with an
>                  * unevictable page on [in]active list.
>                  * We know how to handle that.
>                  */
>                 lru = active + page_lru_base_type(page);
> +              if (active)
> +                   SetPageActive(page);
>                 lru_cache_add_lru(page, lru);

PageActive is reset by lru_cache_add_lru so it's meaningless.
BTW, please ignore this patch. :)
 
I think LRU status of isolated page cannot be changed.
Thanks for the review. 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
