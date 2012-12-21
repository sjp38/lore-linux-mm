Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 61D526B0093
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 20:09:05 -0500 (EST)
Date: Fri, 21 Dec 2012 10:09:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: compare MIGRATE_ISOLATE selectively
Message-ID: <20121221010902.GD2686@blaptop>
References: <1355981152-2505-1-git-send-email-minchan@kernel.org>
 <xa1tfw30hgfb.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1tfw30hgfb.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2012 at 04:49:44PM +0100, Michal Nazarewicz wrote:
> On Thu, Dec 20 2012, Minchan Kim wrote:
> > diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> > index a92061e..4ada4ef 100644
> > --- a/include/linux/page-isolation.h
> > +++ b/include/linux/page-isolation.h
> > @@ -1,6 +1,25 @@
> >  #ifndef __LINUX_PAGEISOLATION_H
> >  #define __LINUX_PAGEISOLATION_H
> >  
> > +#ifdef CONFIG_MEMORY_ISOLATION
> > +static inline bool page_isolated_pageblock(struct page *page)
> > +{
> > +	return get_pageblock_migratetype(page) == MIGRATE_ISOLATE;
> > +}
> > +static inline bool mt_isolated_pageblock(int migratetype)
> > +{
> > +	return migratetype == MIGRATE_ISOLATE;
> > +}
> 
> Perhaps a??is_migrate_isolatea?? to match already existing a??is_migrate_cmaa???

Good poking. In fact, while I made this patch, I was very tempted by renaming
is_migrate_cma to cma_pageblock.

        is_migrate_cma(mt)

I don't know who start to use "mt" instead of "migratetype" but anyway, it's
not a good idea.

        is_migrate_cma(migratetype)

It's very clear for me because migratetype is per pageblock, we can know the
function works per pageblock unit.

> Especially as the a??mt_isolated_pageblocka?? sound confusing to me, it
> implies that it works on pageblocks which it does not.

-ENOPARSE.

migratetype works on pageblock.
I admit mt is really dirty but I used page_alloc.c already has lots of mt, SIGH.

How about this?

1. Let's change all "mt" with "migratetype" again.
2. use is_migrate_isolate and is_migrate_cma for "migratetype".
3. use is_migrate_isolate_page instead of page_isolated_pageblock for "page".

Okay?

> 
> > +#else
> > +static inline bool page_isolated_pageblock(struct page *page)
> > +{
> > +	return false;
> > +}
> > +static inline bool mt_isolated_pageblock(int migratetype)
> > +{
> > +	return false;
> > +}
> > +#endif
> >  
> >  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >  			 bool skip_hwpoisoned_pages);
> -- 
> Best regards,                                         _     _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
> ..o | Computer Science,  MichaA? a??mina86a?? Nazarewicz    (o o)
> ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--





-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
