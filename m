Received: from post.mail.nl.demon.net (post-10.mail.nl.demon.net [194.159.73.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA16792
	for <linux-mm@kvack.org>; Fri, 28 May 1999 18:21:01 -0400
Date: Fri, 28 May 1999 23:33:33 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <14159.137.169623.500547@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.03.9905282326100.19045-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 1999, Stephen C. Tweedie wrote:

> In short, I think the real answer as far as the VM is concerned is
> indeed to use clustering, not just for IO (we already do that for
> mmap paging and for sequential reads), but for pageout too.  I
> really believe that the best unit in which to do pageout is
> whatever unit we did the pagein in in the first place.

Proper I/O and swap clustering isn't difficult. Just take
a look at the FreeBSD sources to see how simple it is (and
how much simpler it can be because the disk_seek:disk_transfer
ratio has changed).

> This has a lot of really nice properties.  If we record sequential
> accesses when setting up data in the first place, then we can
> automatically optimise for that when doing the pageout again.  For swap,
> it reduces fragmentation: we can allocate in multi-page chunks and keep
> that allocation persistent.

Since we keep pages in the page cache after swapping them out,
we can implement this optimization very cheaply.

> There are very few places where doing such clustering falls short of
> what we'd get by increasing the page size.  COW is one: retaining
> per-page COW granularity is an easy way to fragment swap, but increasing
> the COW chunk size changes the semantics unless we actually export a
> larger pagesize to user space

If we're still COWing a task, it's probably sharing memory with
other _resident_ tasks as well so the I/O point becomes moot in
most cases (hopefully -- correct me if I'm wrong!).

> Finally, there's one other thing worth considering: if we use a larger
> chunk size for dividing up memory (say, set the buddy heap up in a basic
> unit of 32k or more), then the slab allocator is actually a very good
> way of getting page allocations out of that.  
> 
> If we did in fact use the 4k minipage for all kernel get_free_page()
> allocations as usual, but used the larger 32k buddy heap pages for all
> VM allocations, then 8K kernel allocations (eg. stack allocations and
> large NFS packets) become trivial to deal with.

It will also nicely solve the page colouring problem, giving
a 10 to 20% speed increase on at least my Intel Neptune chip
set. And similar increases for the number crunching folks...

It seems like an excellent idea to me, although I really
would like to keep the 4kB space efficiency for user VM.
(could be useful for low-memory machines like our company
web server)

regards,

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
