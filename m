Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7CC446B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 03:05:50 -0500 (EST)
Date: Thu, 8 Dec 2011 09:05:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Question about __zone_watermark_ok: why there is a "+ 1" in
 computing free_pages?
Message-ID: <20111208080547.GA5631@tiehlicka.suse.cz>
References: <CAKXJSOHu+sQ1NeMsRvFyp2GYoB6g+50boUu=-QvbxxjcqgOAVA@mail.gmail.com>
 <20111205161443.GA20663@tiehlicka.suse.cz>
 <CAKXJSOErX_E9Oq0SHoRepJHy3Mb5ZkPYMJNbS6Z9DuQZXHO6sQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKXJSOErX_E9Oq0SHoRepJHy3Mb5ZkPYMJNbS6Z9DuQZXHO6sQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Thu 08-12-11 10:38:39, Wang Sheng-Hui wrote:
> Sorry, Michal.
> 
> 2011/12/6 Michal Hocko <mhocko@suse.cz>
> 
> > On Fri 25-11-11 09:21:35, Wang Sheng-Hui wrote:
> > > In line 1459, we have "free_pages -= (1 << order) + 1;".
> > > Suppose allocating one 0-order page, here we'll get
> > >     free_pages -= 1 + 1
> > > I wonder why there is a "+ 1"?
> >
> > Good spot. Check the patch bellow.
> > ---
> > From 38a1cf351b111e8791d2db538c8b0b912f5df8b8 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Mon, 5 Dec 2011 17:04:23 +0100
> > Subject: [PATCH] mm: fix off-by-two in __zone_watermark_ok
> >
> > 88f5acf8 [mm: page allocator: adjust the per-cpu counter threshold when
> > memory is low] changed the form how free_pages is calculated but it
> > forgot that we used to do free_pages - ((1 << order) - 1) so we ended up
> > with off-by-two when calculating free_pages.
> >
> > Spotted-by: Wang Sheng-Hui <shhuiw@gmail.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9dd443d..8a2f1b6 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1457,7 +1457,7 @@ static bool __zone_watermark_ok(struct zone *z, int
> > order, unsigned long mark,
> >        long min = mark;
> >        int o;
> >
> > -       free_pages -= (1 << order) + 1;
> > +       free_pages -= (1 << order) - 1;
> >
> 
> I don't understand why there is additional "-1".
> Use 0-order allocation as example:
>       0-order page ---- one 4K page
> free_pages should subtract 1. Here, free_pages will subtract 0?

Check out all the conditions for free_pages...

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
