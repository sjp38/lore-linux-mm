Date: Mon, 31 Jul 2006 19:34:27 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2/2] mm: lockless pagecache
In-Reply-To: <44CE2365.6040605@shadowen.org>
Message-ID: <Pine.LNX.4.64.0607311923020.11821@blonde.wat.veritas.com>
References: <20060726063941.GB32107@wotan.suse.de> <44CE2365.6040605@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 31 Jul 2006, Andy Whitcroft wrote:
> > Index: linux-2.6/mm/filemap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/filemap.c
> > +++ linux-2.6/mm/filemap.c
> > @@ -613,11 +613,22 @@ struct page *find_trylock_page(struct ad
> ....
> 
> This one has me puzzled.  This seem to no longer lock the page at all when
> returning it.  It seems the semantics of this has changed wildly. Also
> find_lock_page below still seems to lock the page, the semantic seems
> maintained there?  I think I am expecting to find a TestSetPageLocked()
> in the new version too?

Whereas find_get_page, which should be the centre-piece of the patch,
is unchanged and using read_lock_irq(&mapping->tree_lock) as before.

It looks like the code seen in find_trylock_page is actually what should
be in find_get_page.  It doesn't matter too much what find_trylock_page
does, since it's deprecated and nothing in tree now uses it; but it ought
to TestSetPageLocked and page_cache_release somewhere, to suit remaining
out-of-tree users.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
