Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA14500
	for <linux-mm@kvack.org>; Mon, 29 Jun 1998 07:43:58 -0400
Date: Mon, 29 Jun 1998 11:35:15 +0100
Message-Id: <199806291035.LAA00733@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
In-Reply-To: <m1emwcf97d.fsf@flinx.npwt.net>
References: <Pine.HPP.3.96.980617035608.29950A-100000@ixion.honeywell.com>
	<199806221138.MAA00852@dax.dcs.ed.ac.uk>
	<358F4FBE.821B333C@ricochet.net>
	<m11zsgrvnf.fsf@flinx.npwt.net>
	<199806241154.MAA03544@dax.dcs.ed.ac.uk>
	<m11zse6ecw.fsf@flinx.npwt.net>
	<199806251100.MAA00835@dax.dcs.ed.ac.uk>
	<m1emwcf97d.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

In article <m1emwcf97d.fsf@flinx.npwt.net>, ebiederm+eric@npwt.net (Eric
W. Biederman) writes:

>>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:
ST> The ideal solution IMHO would be something which does write-through
ST> from the page cache to the buffer cache and write-back from the buffer
ST> cache to disk; in other words, when you write to a page, buffers are
ST> generated to map that dirty data (without copying) there and then.
ST> The IO is then left to the buffer cache, as currently happens, but the
ST> buffer is deleted after IO (just like other temporary buffer_heads
ST> behave right now).  That leaves the IO buffering to the buffer cache
ST> and the caching to the page cache, which is the distinction that the
ST> the current scheme approaches but does not quite achieve.

> Unless I have missed something write-back from the page cache is
> important, because then when you delete a file you haven't written yet
> you can completely avoid I/O.   For short lived files this should be a
> performance win.

We already do bforget() to deal with this in the buffer cache.  Having
the outstanding IO labelled in the buffer cache will not result in
redundant writes in this case.

>>> This functionality is essentially what is implemented with brw_page,
>>> and I have written the generic_page_write that does essentially
>>> this.  There is no data copying however.  The fun angle is mapped
>>> pages need to be unmapped (or at least read only mapped) for a write
>>> to be successful.

ST> Indeed; however, it might be a reasonable compromise to do a copy out
ST> from the page cache to the buffer cache in this situation (we already
ST> have a copy in there, so this would not hurt performance relative to
ST> the current system).  

> Agreed.  But it takes more work to write.

On reflection, it's not an issue.  Mapped pages do not have to be
unmapped at all.  We can continue to share between cache and buffers as
long as we want.  Later modifications to the data in the cache page will
update the buffer contents, true, but that's irrelevant as we will still
be writing valid file contents to disk when the IO arrives.  Those
semantics are just fine.

--Stephen
