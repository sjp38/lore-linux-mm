Date: Mon, 31 Aug 1998 22:34:45 +0100
Message-Id: <199808312134.WAA09812@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: State of things?
In-Reply-To: <Pine.LNX.3.96.980825212725.475e-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.95.980824233056.8914A-100000@as200.spellcast.com>
	<Pine.LNX.3.96.980825212725.475e-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 25 Aug 1998 21:34:35 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

>> Okay, I'm back in Toronto from sunny California, and I'm wondering if
>> someone would be so kind as to enlighten me about the current state of mm
>> in 2.1/plans for 2.3...

Just to add a bit to Rik's summary:

> Well:
> - the fragmentation problems have been hidden fairly well by
>   making the dcache better prunable and by allocating less
>   inodes on small systems

Seems *much* better now.  I'm basically satisfied by the fragmentation
behaviour in 2.1 now.  I am still unhappy with the page cache aging,
however, and I found a new way to kill it today: if you have a heavily
swapping box with a lot of process data pages, then you can end up with
lots of pages in the swap cache and the cache balancing goes crazy.  The
machine is still usable but the large swapping processes freeze until
killed. 

This is just another example of how the current aging code fails to
adapt to memory conditions (a large ramdisk will kill it in much the
same way).  Other than that, vm looks pretty good.

> - some swap count 'overflow' has been fixed by Stephen
>   (there was a leak on 127+ users of one page) -- has this been
>   merged?

Now merged, along with the 2GB swap stuff.

> - Stephen implemented swap partitions of up to 2 GB -- not yet merged
> - Bill Hawes did an awful lot of debugging, he fixed several
>   (all?) cases of "found a writable swap cache page"

Bill and I had a lot of success with this, but we still have one
outstanding case --- mmap (MAP_SHARED) of /proc/N/mem simply doesn't
work, and never did.  I'm also following up one or two other cases which
may or may not be examples of this.  Dosemu is the main trigger for this
one.

> - I updated some documentation and am busy writing more (for 2.2,
>   documentation has my priority)
> - I am working on proper Out-of-VM process killing code (which
>   might even work by now :-)

I'll be testing this this week.

> - DaveM is working on a fast hashing scheme for VMAs (read the
>   "2.1 makes Electric Fence 22x slower" thread on linux-kernel)

Still slower than the AVL tree stuff by a significant margin; Bruno
Haible is currently reworking the AVL bits back in.

> - Eric has been busy coding SHMfs and doing dirty pages in the
>   page cache -- scheduled for 2.3 integrations
> - Linus has announced a definite code freeze (at 2.1.115)

That about sums it up.  Apart from the bad worst-case behaviour of page
cache aging, the AVL stuff and the known dosemu mmap bug, things look
pretty good for 2.2.  Best of all, all three of these issues have easy
fixes.  The page cache aging is easy to back out if we decide that we
have to.  The AVL stuff is already written, it just needs to be
remerged.  The worst is the mmap() thing, and if it comes to it, we can
fix by disabling MAP_SHARED maps of /proc/N/mem.  Implementing anonymous
shared pages is a more complete fix (I have an implementation of that
running but not debugged, so it's a question of how big a fix we can get
into the 2.2 code freeze more than anything else).

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
