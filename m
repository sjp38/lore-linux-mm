Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA15806
	for <linux-mm@kvack.org>; Fri, 28 May 1999 16:46:17 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14159.137.169623.500547@dukat.scot.redhat.com>
Date: Fri, 28 May 1999 21:46:01 +0100 (BST)
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <E10n8Ic-0003h9-00@the-village.bc.nu>
References: <Pine.LNX.4.03.9905252213400.25857-100000@mirkwood.nl.linux.org>
	<E10n8Ic-0003h9-00@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@nl.linux.org>, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 27 May 1999 23:06:48 +0100 (BST), Alan Cox
<alan@lxorguk.ukuu.org.uk> said:

>> A larger page size is no compensation for the lack of a decent
>> read-{ahead,back,anywhere} I/O clustering algorithm in the OS.

> It isnt compensating for that. If you have 4Gig of memory and a high
> performance I/O controller the constant cost per page for VM
> management begins to dominate the equation. Its also a win for other
> CPU related reasons (reduced tlb misses and the like), and with 4Gig
> of RAM the argument is a larger page size isnt a problem.

That's still only half of the issue.  Remember, there isn't any one
block size in the kernel.

We can happily use 1k or 2k blocks in the buffer cache.  We use 8k
chunks for stacks.  Nothing is forcing us to use the hardware page size
for all of our operations.  

In short, I think the real answer as far as the VM is concerned is
indeed to use clustering,  not just for IO (we already do that for
mmap paging and for sequential reads), but for pageout too.  I really
believe that the best unit in which to do pageout is whatever unit we
did the pagein in in the first place.

This has a lot of really nice properties.  If we record sequential
accesses when setting up data in the first place, then we can
automatically optimise for that when doing the pageout again.  For swap,
it reduces fragmentation: we can allocate in multi-page chunks and keep
that allocation persistent.

There are very few places where doing such clustering falls short of
what we'd get by increasing the page size.  COW is one: retaining
per-page COW granularity is an easy way to fragment swap, but increasing
the COW chunk size changes the semantics unless we actually export a
larger pagesize to user space (because we end up destroying the VM
backing store sharing for pages which haven't actually been touched by
the user).

Finally, there's one other thing worth considering: if we use a larger
chunk size for dividing up memory (say, set the buddy heap up in a basic
unit of 32k or more), then the slab allocator is actually a very good
way of getting page allocations out of that.  

If we did in fact use the 4k minipage for all kernel get_free_page()
allocations as usual, but used the larger 32k buddy heap pages for all
VM allocations, then 8K kernel allocations (eg. stack allocations and
large NFS packets) become trivial to deal with.

The biggest problem we have had with these multi-page allocations up to
now is fragmentation in the VM.  If we populate the _entire_ VM in
multiples of 8k or more then we can never see such fragmentation at all.
8k might actually be a reasonable pagesize even on low memory machines:
we found in 2.2 that the increased size of the kernel was compensated
for by more efficient swapping so that things still went faster in low
memory than under 2.2, and large pages may well have the same tradeoff.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
