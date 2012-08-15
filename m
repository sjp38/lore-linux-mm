Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 462386B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 19:18:17 -0400 (EDT)
Date: Thu, 16 Aug 2012 08:20:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] cma: support MIGRATE_DISCARD
Message-ID: <20120815232023.GA15225@bbox>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org>
 <1344934627-8473-3-git-send-email-minchan@kernel.org>
 <xa1t7gt1pnck.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1t7gt1pnck.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Michal,

On Tue, Aug 14, 2012 at 04:19:55PM +0200, Michal Nazarewicz wrote:
> Minchan Kim <minchan@kernel.org> writes:
> > This patch introudes MIGRATE_DISCARD mode in migration.
> > It drop clean cache pages instead of migration so that
> > migration latency could be reduced. Of course, it could
> > evict code pages but latency of big contiguous memory
> > is more important than some background application's slow down
> > in mobile embedded enviroment.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> This looks good to me.
> 
> > ---
> >  include/linux/migrate_mode.h |   11 +++++++---
> >  mm/migrate.c                 |   50 +++++++++++++++++++++++++++++++++---------
> >  mm/page_alloc.c              |    2 +-
> >  3 files changed, 49 insertions(+), 14 deletions(-)
> >
> > diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> > index ebf3d89..04ca19c 100644
> > --- a/include/linux/migrate_mode.h
> > +++ b/include/linux/migrate_mode.h
> > @@ -6,11 +6,16 @@
> >   *	on most operations but not ->writepage as the potential stall time
> >   *	is too significant
> >   * MIGRATE_SYNC will block when migrating pages
> > + * MIGRTATE_DISCARD will discard clean cache page instead of migration
> > + *
> > + * MIGRATE_ASYNC, MIGRATE_SYNC_LIGHT, MIGRATE_SYNC shouldn't be used
> > + * together as OR flag.
> >   */
> >  enum migrate_mode {
> > -	MIGRATE_ASYNC,
> > -	MIGRATE_SYNC_LIGHT,
> > -	MIGRATE_SYNC,
> > +	MIGRATE_ASYNC = 1 << 0,
> > +	MIGRATE_SYNC_LIGHT = 1 << 1,
> > +	MIGRATE_SYNC = 1 << 2,
> > +	MIGRATE_DISCARD = 1 << 3,
> >  };
> 
> Since CMA is the only user of MIGRATE_DISCARD it may be worth it to
> guard it inside an #ifdef, eg:
> 
> #ifdef CONFIG_CMA
> 	MIGRATE_DISCARD = 1 << 3,
> #define is_migrate_discard(mode) (((mode) & MIGRATE_DISCARD) == MIGRATE_DISCARD)

The mode bit can be used with other bits like MIGRATE_SYNC|MIGRATE_DISCARD.
So it is correct that (mode & MIGRATE_DISCARD).

Anyway, I don't want to fold it into only CMA because I think we can
have a pontential users in mm.
For example, memory-hotplug case. No enough free memory in the system
but lots of page cache page as a migration source, then we can remove
page cache page instead of migration and it might be better than failing
memory-hotremove.

In summary, I want to open it for potential usecases in future if anyone
doesn't oppose strongly.

> #endif
> 
>   
> >  #endif		/* MIGRATE_MODE_H_INCLUDED */
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 77ed2d7..8119a59 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -685,9 +685,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  	int remap_swapcache = 1;
> >  	struct mem_cgroup *mem;
> >  	struct anon_vma *anon_vma = NULL;
> > +	enum ttu_flags ttu_flags;
> > +	bool discard_mode = false;
> > +	bool file = false;
> >  
> >  	if (!trylock_page(page)) {
> > -		if (!force || mode == MIGRATE_ASYNC)
> > +		if (!force || mode & MIGRATE_ASYNC)

It's not wrong technically but for readability, NP.

> 
> +		if (!force || (mode & MIGRATE_ASYNC))
> 
> >  			goto out;
> >  
> >  		/*
> 
> 
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
