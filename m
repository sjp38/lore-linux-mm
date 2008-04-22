Date: Tue, 22 Apr 2008 16:56:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080422045205.GH21993@wotan.suse.de>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080422045205.GH21993@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2008 06:52:05 +0200
Nick Piggin <npiggin@suse.de> wrote:
> > I guess BUG_ON(!PageUptodate) would be better here?
> > 
> > > <snip>
> > >         if (PageDirty(page)) {
> > >                 clear_page_dirty_for_io(page);
> > >                 set_page_dirty(newpage);------------------------(**)
> > >         }
> > > 
> > > ==
> > > Then, Uptodate() is copied before set_page_dirty(). 
> > > So, "page" is not Uptodate and Dirty when it reaches (**)
> > 
> > The page will be marked uptodate before we reach ** so its okay in 
> > general. If a page is not uptodate then we should not be getting here.
> > 
> > An !uptodate page is not migratable. Maybe we need to add better checking?
> 
> Why is an !uptodate page not migrateable, and where are you testing to
> prevent that?
> 

I'm sorry if I don't understand correctly, in usual, can I consider
!PageUptodate() page is under I/O or some unstable state ?
If so, migration is danger.
And set_page_dirty() shown WARNING when I migrated a dirty and not-up-to-date
page. To avoid WARNING, a not-up-to-date page should not be migratable.


I tested PageUptodate() in
==
static int unmap_and_move(new_page_t get_new_page, unsigned long private,
                        struct page *page, int force)
{
    <snip>
        if (TestSetPageLocked(page)) {
                if (!force)
                        goto move_newpage;
                lock_page(page);
        }
      (*) here
....
}
==
and the page never becomes Uptodate.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
