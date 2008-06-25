In-reply-to: <20080625131117.GA28136@2ka.mipt.ru> (message from Evgeniy
	Polyakov on Wed, 25 Jun 2008 17:11:17 +0400)
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu> <20080625131117.GA28136@2ka.mipt.ru>
Message-Id: <E1KBV7H-0005nv-Gl@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 25 Jun 2008 15:32:55 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> > I haven't done an audit of all code that checks the PG_uptodate flags,
> > but I suspect, that this change won't have any harmful effects.  Most
> > code checks page->mapping to see if the page was truncated or
> > invalidated, before using it, and retries the find/read on the page if
> > it wasn't.  The page_cache_pipe_buf_confirm() code is an exception in
> > this regard.
> 
> What about writing path, when page is written after some previous write?

page->mapping should be checked in the write paths as well.

> Like __block_prepare_write()?

That's called with the page locked and page->mapping verified.

> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> > ---
> >  mm/truncate.c |    1 -
> >  1 file changed, 1 deletion(-)
> > 
> > Index: linux-2.6/mm/truncate.c
> > ===================================================================
> > --- linux-2.6.orig/mm/truncate.c	2008-06-24 20:49:25.000000000 +0200
> > +++ linux-2.6/mm/truncate.c	2008-06-24 23:28:32.000000000 +0200
> > @@ -356,7 +356,6 @@ invalidate_complete_page2(struct address
> >  	BUG_ON(PagePrivate(page));
> >  	__remove_from_page_cache(page);
> >  	write_unlock_irq(&mapping->tree_lock);
> > -	ClearPageUptodate(page);
> >  	page_cache_release(page);	/* pagecache ref */
> >  	return 1;
> >  failed:
> 
> Don't do that, add new function instead which will do exactly that, if
> you do need exactly this behaviour.

I don't see any point in doing that.

> Also why isn't invalidate_complete_page() enough, if you want to have
> that page to be half invalidated?

I want the page fully invalidated, and I also want splice and nfs
exporting to work as for other filesystems.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
