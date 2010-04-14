Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 965CA6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 09:24:13 -0400 (EDT)
Date: Wed, 14 Apr 2010 14:23:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414132349.GL25756@csn.ul.ie>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com> <20100413095815.GU25756@csn.ul.ie> <20100413111902.GY2493@dastard> <20100413193428.GI25756@csn.ul.ie> <20100413202021.GZ13327@think> <877hoa9wlv.fsf@basil.nowhere.org> <20100414112015.GO13327@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100414112015.GO13327@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 07:20:15AM -0400, Chris Mason wrote:
> On Wed, Apr 14, 2010 at 12:06:36PM +0200, Andi Kleen wrote:
> > Chris Mason <chris.mason@oracle.com> writes:
> > >
> > > Huh, 912 bytes...for select, really?  From poll.h:
> > >
> > > /* ~832 bytes of stack space used max in sys_select/sys_poll before allocating
> > >    additional memory. */
> > > #define MAX_STACK_ALLOC 832
> > > #define FRONTEND_STACK_ALLOC    256
> > > #define SELECT_STACK_ALLOC      FRONTEND_STACK_ALLOC
> > > #define POLL_STACK_ALLOC        FRONTEND_STACK_ALLOC
> > > #define WQUEUES_STACK_ALLOC     (MAX_STACK_ALLOC - FRONTEND_STACK_ALLOC)
> > > #define N_INLINE_POLL_ENTRIES   (WQUEUES_STACK_ALLOC / sizeof(struct poll_table_entry))
> > >
> > > So, select is intentionally trying to use that much stack.  It should be using
> > > GFP_NOFS if it really wants to suck down that much stack...
> > 
> > There are lots of other call chains which use multiple KB bytes by itself,
> > so why not give select() that measly 832 bytes?
> > 
> > You think only file systems are allowed to use stack? :)
> 
> Grin, most definitely.
> 
> > 
> > Basically if you cannot tolerate 1K (or more likely more) of stack
> > used before your fs is called you're toast in lots of other situations
> > anyways.
> 
> Well, on a 4K stack kernel, 832 bytes is a very large percentage for
> just one function.
> 
> Direct reclaim is a problem because it splices parts of the kernel that
> normally aren't connected together.  The people that code in select see
> 832 bytes and say that's teeny, I should have taken 3832 bytes.
> 

Even without direct reclaim, I doubt stack usage is often at the top of
peoples minds except for truly criminal large usages of it. Direct
reclaim splicing is somewhat of a problem but it's separate to stack
consumption overall.

> But they don't realize their function can dive down into ecryptfs then
> the filesystem then maybe loop and then perhaps raid6 on top of a
> network block device.
> 
> > 
> > > kernel had some sort of way to dynamically allocate ram, it could try
> > > that too.
> > 
> > It does this for large inputs, but the whole point of the stack fast
> > path is to avoid it for common cases when a small number of fds is
> > only needed.
> > 
> > It's significantly slower to go to any external allocator.
> 
> Yeah, but since the call chain does eventually go into the allocator,
> this function needs to be more stack friendly.
> 
> I do agree that we can't really solve this with noinline_for_stack pixie
> dust, the long call chains are going to be a problem no matter what.
> 
> Reading through all the comments so far, I think the short summary is:
> 
> Cleaning pages in direct reclaim helps the VM because it is able to make
> sure that lumpy reclaim finds adjacent pages.  This isn't a fast
> operation, it has to wait for IO (infinitely slow compared to the CPU).
> 
> Will it be good enough for the VM if we add a hint to the bdi writeback
> threads to work on a general area of the file?  The filesystem will get
> writepages(), the VM will get the IO it needs started.
> 

Bear in mind that the context of lumpy reclaim that the VM doesn't care
about where the data is on the file or filesystem. It's only concerned
about where the data is located in memory. There *may* be a correlation
between location-of-data-in-file and location-of-data-in-memory but only
if readahead was a factor and readahead happened to hit at a time the page
allocator broke up a contiguous block of memory.

> I know Mel mentioned before he wasn't interested in waiting for helper
> threads, but I don't see how we can work without it.
> 

I'm not against the idea as such. It would have advantages in that the
thread could reorder the IO for better seeks for example and lumpy
reclaim is already potentially waiting a long time so another delay
won't hurt. I would worry that it's just hiding the stack usage by
moving it to another thread and that there would be communication cost
between a direct reclaimer and this writeback thread. The main gain
would be in hiding the "splicing" effect between subsystems that direct
reclaim can have.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
