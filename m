Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA26637
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 11:53:38 -0400
Date: Thu, 25 Jun 1998 12:00:56 +0100
Message-Id: <199806251100.MAA00835@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
In-Reply-To: <m11zse6ecw.fsf@flinx.npwt.net>
References: <Pine.HPP.3.96.980617035608.29950A-100000@ixion.honeywell.com>
	<199806221138.MAA00852@dax.dcs.ed.ac.uk>
	<358F4FBE.821B333C@ricochet.net>
	<m11zsgrvnf.fsf@flinx.npwt.net>
	<199806241154.MAA03544@dax.dcs.ed.ac.uk>
	<m11zse6ecw.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[CC:ed to linux-mm, who also have a great deal of interest in this
stuff.]

On 24 Jun 1998 09:53:03 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

ST> However, there's a lot of overlap, so I'd like to look at what we can do
ST> with this for 2.3.  In particular, I'd like 2.3's standard file writing
ST> mechanism to work essentially as write-through from the page cache,

> The current system is write-through.  I hope you mean write back.

The current system is write-through from the buffer cache.  The data
is copied into the page cache only if there is already a page mapping
that data.  That is really ugly, using the buffer cache both as an IO
buffer and as a data cache.  THAT is what we need to fix.

The ideal solution IMHO would be something which does write-through
from the page cache to the buffer cache and write-back from the buffer
cache to disk; in other words, when you write to a page, buffers are
generated to map that dirty data (without copying) there and then.
The IO is then left to the buffer cache, as currently happens, but the
buffer is deleted after IO (just like other temporary buffer_heads
behave right now).  That leaves the IO buffering to the buffer cache
and the caching to the page cache, which is the distinction that the
the current scheme approaches but does not quite achieve.

> This functionality is essentially what is implemented with brw_page,
> and I have written the generic_page_write that does essentially
> this.  There is no data copying however.  The fun angle is mapped
> pages need to be unmapped (or at least read only mapped) for a write
> to be successful.

Indeed; however, it might be a reasonable compromise to do a copy out
from the page cache to the buffer cache in this situation (we already
have a copy in there, so this would not hurt performance relative to
the current system).  

Doing COW at the page cache level is something we can implement later;
there are other reasons for it to be desirable anyway.  For example,
it lets you convert all read(2) and write(2) requests on whole pages
into mmap()s, transparently, giving automatic zero-copy IO to user
space.

> I should have a working patch this weekend (the code compiles now, I
> just need to make sure it works) and we can discuss it more when that
> has been released.

Excellent.  I look forward to seeing it.

--Stephen
