Date: Tue, 7 Oct 2008 16:34:57 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH next 1/3] slub defrag: unpin writeback pages
In-Reply-To: <48EB62F9.9040409@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0810071606530.32764@blonde.site>
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
 <48EB62F9.9040409@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Oct 2008, Christoph Lameter wrote:
> Hugh Dickins wrote:
> 
> > That PageWriteback test should be made while PageLocked in trigger_write(),
> > just as it is in try_to_free_buffers() - if there are complex reasons why
> > that's not actually necessary, I'd rather not have to think through them.
> > A preliminary check before taking the lock?  No, it's not that important.
> 
> The writeback check in kick_buffers() is a performance optimization. If the
> page is under writeback then there is no point in trying to kick out the page.
> That will only succeed after writeback is complete.

I think it's more than a performance optimization: I may have missed
somewhere, but the only place I can find which calls ->writepage without
checking PageWriteback first, while holding PageLock across the calls,
is mm/page-writeback.c write_one_page() - which seems to be for internal
use by filesystems, which could make the check themselves - but every
existing caller passes wait arg 1 to wait for PageWriteback to clear.

I wrote that while running a test, my version of fs/buffer.c with
the PageWriteback test removed from trigger_write(): that's now hit
kernel BUG at fs/buffer.c:1757! which is BUG_ON(PageWriteback(page))
in __block_write_full_page().  Fair enough, though what I'd been
looking forward to was the 
	if (!test_clear_page_writeback(page))
		BUG();
in mm/filemap.c end_page_writeback().

> 
> If a page is under writeback then try_to_free_buffers() will fail immediately.
> So no need to check under pagelock.

What I meant was that try_to_free_buffers() is already checking it
under pagelock, so let's be symmetrical and check it under pagelock
in trigger_write(), rather than moving the test within kick_buffers().

> > --- 2.6.27-rc7-mmotm/fs/buffer.c	2008-09-26 13:18:50.000000000 +0100
> > +++ linux/fs/buffer.c	2008-10-03 19:43:44.000000000 +0100
> > @@ -3354,13 +3354,16 @@ static void trigger_write(struct page *p
> >  		.for_reclaim = 0
> >  	};
> >  
> > +	if (PageWriteback(page))
> > +		goto unlock;
> > +
> 
> Is that necessary? Wont writepage do the appropriate thing?

Some might, but in general no: my BUG came below blkdev_writepage().

> >  /*
> > @@ -3420,7 +3423,7 @@ static void kick_buffers(struct kmem_cac
> >  	for (i = 0; i < nr; i++) {
> >  		page = v[i];
> >  
> > -		if (!page || PageWriteback(page))
> > +		if (!page)
> >  			continue;
> 
> Thats just an optimization. No need to lock a page if its under writeback
> which would make try_to_free_buffers() fail.

My first version of the patch did go on to say
-		if (trylock_page(page)) {
+		if (!PageWriteback(page) && trylock_page(page)) {

But since the cacheline is already dirty (from get_page_unless_zero),
and it's only a trylock, and we (almost certainly) need to repeat the
PageWriteback test once we've got the lock, and it does not hit this
case often enough for you to have noticed the missing put_page() bug,
I decided to save icache instead by just removing your optimization.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
