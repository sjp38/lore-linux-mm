Date: Mon, 8 Oct 2007 13:05:27 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 5/7] shmem_getpage return page locked
In-Reply-To: <200710071801.59947.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710081237250.5786@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0710062145160.16223@blonde.wat.veritas.com>
 <200710071801.59947.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Oct 2007, Nick Piggin wrote:
> On Sunday 07 October 2007 06:46, Hugh Dickins wrote:
> > In the new aops, write_begin is supposed to return the page locked:
> > though I've seen no ill effects, that's been overlooked in the case
> > of shmem_write_begin, and should be fixed.  Then shmem_write_end must
> > unlock the page: do so _after_ updating i_size, as we found to be
> > important in other filesystems (though since shmem pages don't go
> > the usual writeback route, they never suffered from that corruption).
> 
> I guess my thinking on this is that write_begin doesn't actually _have_
> to return the page locked, it just has to return the page in a state where
> it may be written into.

Ah, I hadn't appreciated that you were being intentionally permissive
on that: I'm not sure whether that's a good idea or not.  Were there
any other filesystems than tmpfs in which the write_begin did not
return with the page locked?

> Generic callers obviously cannot assume that the page *isn't* locked,
> but I can't think it would be too helpful for them to be able to assume
> the page is locked (they already have a ref, which prevents reclaim;
> and i_mutex, which prevents truncate).

Well, we found before that __mpage_writepage is liable to erase data
just written at end of file, unless i_size was raised while still
holding the page lock held across the writing.  tmpfs doesn't go
that way, but most(?) filesystems do.

> However, this does make tmpfs apis a little simpler and in general is more
> like other filesystems, so I have absolutely no problems with it.

I do feel more comfortable with tmpfs doing that like the
majority.  It's true that it was happy to write without holding
the page lock when it went its own way, but now that it's using
write_begin and write_end with generic code above and between
them, I feel safer doing the common thing.

> I think the other patches are pretty fine too, and really like that you were
> able to remove shmem_file_write!

Thanks, I was pleased with the diffstat.  I'm hoping that in due
course you'll find good reason to come up with a replacement for the
readpage aop, one that doesn't demand the struct page be passed in:
then I can remove shmem_file_read too, and the nastiest part of
shmem_getpage, where it sometimes has to memcpy from swapcache
page to the page passed in; maybe more.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
