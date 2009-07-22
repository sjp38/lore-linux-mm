Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5936B005C
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 05:08:39 -0400 (EDT)
Date: Wed, 22 Jul 2009 11:07:19 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/4] mm: introduce page_lru_type()
Message-ID: <20090722090719.GA1971@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-2-git-send-email-hannes@cmpxchg.org> <28c262360907211852m7aa0fd6eic69e4ce29f09e5b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360907211852m7aa0fd6eic69e4ce29f09e5b8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Minchan,

On Wed, Jul 22, 2009 at 10:52:21AM +0900, Minchan Kim wrote:
> Hi.
> 
> On Tue, Jul 21, 2009 at 5:56 PM, Johannes Weiner<hannes@cmpxchg.org> wrote:
> > Instead of abusing page_is_file_cache() for LRU list index arithmetic,
> > add another helper with a more appropriate name and convert the
> > non-boolean users of page_is_file_cache() accordingly.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> > A include/linux/mm_inline.h | A  19 +++++++++++++++++--
> > A mm/swap.c A  A  A  A  A  A  A  A  | A  A 4 ++--
> > A mm/vmscan.c A  A  A  A  A  A  A  | A  A 6 +++---
> > A 3 files changed, 22 insertions(+), 7 deletions(-)
> >
> > diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> > index 7fbb972..ec975f2 100644
> > --- a/include/linux/mm_inline.h
> > +++ b/include/linux/mm_inline.h
> > @@ -60,6 +60,21 @@ del_page_from_lru(struct zone *zone, struct page *page)
> > A }
> >
> > A /**
> > + * page_lru_type - which LRU list type should a page be on?
> > + * @page: the page to test
> > + *
> > + * Used for LRU list index arithmetic.
> > + *
> > + * Returns the base LRU type - file or anon - @page should be on.
> > + */
> > +static enum lru_list page_lru_type(struct page *page)
> > +{
> > + A  A  A  if (page_is_file_cache(page))
> > + A  A  A  A  A  A  A  return LRU_INACTIVE_FILE;
> > + A  A  A  return LRU_INACTIVE_ANON;
> > +}
> 
> page_lru_type function's semantics is general but this function only
> considers INACTIVE case.
> So we always have to check PageActive to know exact lru type.
> 
> Why do we need double check(ex, page_lru_type and PageActive) to know
> exact lru type ?
> 
> It wouldn't be better to check it all at once ?

page_lru() does that for you already.

But look at the users of page_lru_type(), they know the active bit
when they want to find out the base type, see check_move_unevictable
e.g.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
