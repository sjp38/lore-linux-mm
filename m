Received: by fk-out-0910.google.com with SMTP id z22so2199274fkz.6
        for <linux-mm@kvack.org>; Sun, 22 Jun 2008 23:18:19 -0700 (PDT)
Message-ID: <21d7e9970806222318q5faa3007ga79531a7bb899303@mail.gmail.com>
Date: Mon, 23 Jun 2008 16:18:18 +1000
From: "Dave Airlie" <airlied@gmail.com>
Subject: Re: strategies for nicely handling large amount of uc/wc allocations.
In-Reply-To: <200806231603.49642.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <21d7e9970806222210s8fec8acybb2b5af17256d555@mail.gmail.com>
	 <200806231603.49642.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 23, 2008 at 4:03 PM, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> On Monday 23 June 2008 15:10, Dave Airlie wrote:
>
>> The issues I'm seeing with just doing my own pool of uncached pages
>> like the ia64 uncached allocator, is how do I deal with swapping
>> objects to disk and memory pressure.
>
> set_shrinker is the way to go for a first-pass approach.
>
>
>> considering GPU applications do a lot of memory allocations I can't
>> really just ignore swap.
>
> It might be kind of nice to be able to use other things than
> swap too. I've always wondered whether there is a problem with
> having a userspace program allocate the memory and then register
> it with the GPU allocator. This way you might be able to mmap a
> file, or allocate anonymous memory or whatever you like. OTOH I
> haven't thought through all the details this would require.

We've thought about that a few times, but really I'd rather avoid have
to have a userspace anything running
in order to suspend/resume. We are trying to move away from having
something like X controlling the world. Also a single program
brings with it a single program VMs space issues, we have GPUs with
1GB of RAM, thats a lot of backing store to have in one apps VM space
along with the objects in the GART.

>
>
>> I think ideally I'd like a zone for these sort of pages to become a
>> first class member of the VM, so that I can set a VMA to have an
>> uncached/wc bit,
>> then it sets a GFP uncached bit, and alloc_page goes and fetch
>> suitable pages from either the highmem zone, or from a resizeable
>> piece of normal zone.
>
> I doubt the performance requirements would justify putting them
> into the allocator, and they don't seem to really fit the concept
> of a zone.
>
> Please start small and then we can see what works and what doesn't.
> Start by not touching the VM at all, and just do what any other
> driver would do and use .fault and/or ioctl+get_user_pages etc,
> and set_shrinker to return pages back to the allocator.

But this loses the requirement of using shmfs, which one of the
current GPU driver is doing,
and what I'd like to have re-used. but maybe that just isn't worth it
at the moment.

We've actually done a few prototypes at this stage outside shmfs, and
the shmfs implementation (using cached pages) is quite neat.
It would be nice to try and go down the same road for the uncached
page required systems.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
