Date: Tue, 22 Apr 2008 06:52:05 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-ID: <20080422045205.GH21993@wotan.suse.de>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2008 at 10:46:47AM -0700, Christoph Lameter wrote:
> On Mon, 14 Apr 2008, KAMEZAWA Hiroyuki wrote:
> 
> > Then, "page" is not Uptodate when it reaches (*).
> 
> Yes. Strange situation.
> 
> > But, migrate_page() call path is
> > ==
> >    buffer_migrate_page()
> > 	-> lock all buffers on old pages.
> > 	-> move buffers to newpage.
> > 	-> migrate_page_copy(page, newpage)
> > 		-> set_page_dirty().
> > 	-> unlock all buffers().
> > ==
> > static void migrate_page_copy(struct page *newpage, struct page *page)
> > {
> >         copy_highpage(newpage, page);
> > <snip>
> >         if (PageUptodate(page))
> >                 SetPageUptodate(newpage);
> 
> Hmmm... I guess BUG_ON(!PageUptodate) would be better here?
> 
> > <snip>
> >         if (PageDirty(page)) {
> >                 clear_page_dirty_for_io(page);
> >                 set_page_dirty(newpage);------------------------(**)
> >         }
> > 
> > ==
> > Then, Uptodate() is copied before set_page_dirty(). 
> > So, "page" is not Uptodate and Dirty when it reaches (**)
> 
> The page will be marked uptodate before we reach ** so its okay in 
> general. If a page is not uptodate then we should not be getting here.
> 
> An !uptodate page is not migratable. Maybe we need to add better checking?

Why is an !uptodate page not migrateable, and where are you testing to
prevent that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
