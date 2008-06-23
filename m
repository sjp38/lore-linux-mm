From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: strategies for nicely handling large amount of uc/wc allocations.
Date: Mon, 23 Jun 2008 16:57:51 +1000
References: <21d7e9970806222210s8fec8acybb2b5af17256d555@mail.gmail.com> <200806231603.49642.nickpiggin@yahoo.com.au> <21d7e9970806222318q5faa3007ga79531a7bb899303@mail.gmail.com>
In-Reply-To: <21d7e9970806222318q5faa3007ga79531a7bb899303@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806231657.51851.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 23 June 2008 16:18, Dave Airlie wrote:
> On Mon, Jun 23, 2008 at 4:03 PM, Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > On Monday 23 June 2008 15:10, Dave Airlie wrote:
> >> The issues I'm seeing with just doing my own pool of uncached pages
> >> like the ia64 uncached allocator, is how do I deal with swapping
> >> objects to disk and memory pressure.
> >
> > set_shrinker is the way to go for a first-pass approach.
> >
> >> considering GPU applications do a lot of memory allocations I can't
> >> really just ignore swap.
> >
> > It might be kind of nice to be able to use other things than
> > swap too. I've always wondered whether there is a problem with
> > having a userspace program allocate the memory and then register
> > it with the GPU allocator. This way you might be able to mmap a
> > file, or allocate anonymous memory or whatever you like. OTOH I
> > haven't thought through all the details this would require.
>
> We've thought about that a few times, but really I'd rather avoid have
> to have a userspace anything running
> in order to suspend/resume.

It wouldn't have to be running, it would just have to provide some
virtual memory area for get_user_pages to work on. Presumably does
not have to do anything when suspending and resuming?


> We are trying to move away from having 
> something like X controlling the world. Also a single program
> brings with it a single program VMs space issues, we have GPUs with
> 1GB of RAM, thats a lot of backing store to have in one apps VM space
> along with the objects in the GART.

I guess you could just ask for your own shmem inode from the kernel
and operate on that. It just seemed more flexible to pass in any
type of memory to register. But maybe it gets tricky as you have to
change the cache attributes.


> > Please start small and then we can see what works and what doesn't.
> > Start by not touching the VM at all, and just do what any other
> > driver would do and use .fault and/or ioctl+get_user_pages etc,
> > and set_shrinker to return pages back to the allocator.
>
> But this loses the requirement of using shmfs, which one of the
> current GPU driver is doing,
> and what I'd like to have re-used. but maybe that just isn't worth it
> at the moment.
>
> We've actually done a few prototypes at this stage outside shmfs, and
> the shmfs implementation (using cached pages) is quite neat.
> It would be nice to try and go down the same road for the uncached
> page required systems.

Well before you worry about swapping, you I guess you should at least
have an allocator that caches the UC pages and has a set_shrinker that
can be used to release unused pages under memory pressure? Do you have
that in yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
