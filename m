Date: Mon, 7 Aug 2006 18:05:19 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs
 invalidate race?
In-Reply-To: <44D74B98.3030305@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0608071752040.20812@blonde.wat.veritas.com>
References: <44CF3CB7.7030009@yahoo.com.au> <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
 <44D74B98.3030305@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Nick Piggin wrote:
> Hugh Dickins wrote:
> > 
> > Hmmm, page_mkwrite when called from do_wp_page would not expect to
> > be holding page lock: we don't want it called with in one case and
> > without in the other.  Maybe do_no_page needs to unlock_page before
> > calling page_mkwrite, lock_page after, and check page->mapping when
> > VM_NOPAGE_LOCKED??
> 
> That's pretty foul. I'll take a bit of a look. Is it really a problem
> to call in either state, if it is well documented? (we could even
> send a flag down if needed). I thought filesystem code loved this
> kind of spaghetti locking?

Agreed foul.  David's helpful mail reassures not an immediate problem,
but I'm pretty sure other future uses of page_mkwrite would need to
know if the page is held locked or not.  Yes, could be done by a flag,
though that's not pretty (gives the ->page_mkwrite implementation much
the same schizophrenia as I was disliking here in do_no_page).

> I don't think ->populate has ever particularly troubled itself with
> these kinds of theoretical races. I was really hoping to fix linear
> pagecache first before getting bogged down with nonlinear.

install_page has had mapping & i_size check for quite a while, but
perhaps by theoretical races you mean Andrea's invalidate case.
The nonlinear case is much less a concern than MAP_POPULATE
(though I don't know if anyone really uses that).

> After thinking about it a bit more, I think I've found my filemap_nopage
> wanting. Suppose i_size is shrunk and the page truncated before the
> first find_lock_page. OK, no we'll allocate a new page, add it to the
> pagecache, and do a ->readpage().

I've got a bit lost between merges against different trees,
I'll let you sort that one out.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
