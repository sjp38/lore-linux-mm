From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: strategies for nicely handling large amount of uc/wc allocations.
Date: Mon, 23 Jun 2008 16:03:49 +1000
References: <21d7e9970806222210s8fec8acybb2b5af17256d555@mail.gmail.com>
In-Reply-To: <21d7e9970806222210s8fec8acybb2b5af17256d555@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806231603.49642.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 23 June 2008 15:10, Dave Airlie wrote:

> The issues I'm seeing with just doing my own pool of uncached pages
> like the ia64 uncached allocator, is how do I deal with swapping
> objects to disk and memory pressure.

set_shrinker is the way to go for a first-pass approach.


> considering GPU applications do a lot of memory allocations I can't
> really just ignore swap.

It might be kind of nice to be able to use other things than
swap too. I've always wondered whether there is a problem with
having a userspace program allocate the memory and then register
it with the GPU allocator. This way you might be able to mmap a
file, or allocate anonymous memory or whatever you like. OTOH I
haven't thought through all the details this would require.


> I think ideally I'd like a zone for these sort of pages to become a
> first class member of the VM, so that I can set a VMA to have an
> uncached/wc bit,
> then it sets a GFP uncached bit, and alloc_page goes and fetch
> suitable pages from either the highmem zone, or from a resizeable
> piece of normal zone.

I doubt the performance requirements would justify putting them
into the allocator, and they don't seem to really fit the concept
of a zone.

Please start small and then we can see what works and what doesn't.
Start by not touching the VM at all, and just do what any other
driver would do and use .fault and/or ioctl+get_user_pages etc,
and set_shrinker to return pages back to the allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
