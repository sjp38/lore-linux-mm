Date: Mon, 14 Apr 2008 10:46:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Apr 2008, KAMEZAWA Hiroyuki wrote:

> Then, "page" is not Uptodate when it reaches (*).

Yes. Strange situation.

> But, migrate_page() call path is
> ==
>    buffer_migrate_page()
> 	-> lock all buffers on old pages.
> 	-> move buffers to newpage.
> 	-> migrate_page_copy(page, newpage)
> 		-> set_page_dirty().
> 	-> unlock all buffers().
> ==
> static void migrate_page_copy(struct page *newpage, struct page *page)
> {
>         copy_highpage(newpage, page);
> <snip>
>         if (PageUptodate(page))
>                 SetPageUptodate(newpage);

Hmmm... I guess BUG_ON(!PageUptodate) would be better here?

> <snip>
>         if (PageDirty(page)) {
>                 clear_page_dirty_for_io(page);
>                 set_page_dirty(newpage);------------------------(**)
>         }
> 
> ==
> Then, Uptodate() is copied before set_page_dirty(). 
> So, "page" is not Uptodate and Dirty when it reaches (**)

The page will be marked uptodate before we reach ** so its okay in 
general. If a page is not uptodate then we should not be getting here.

An !uptodate page is not migratable. Maybe we need to add better checking?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
