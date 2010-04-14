Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1760D6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 07:22:01 -0400 (EDT)
Date: Wed, 14 Apr 2010 07:20:15 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414112015.GO13327@think>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
 <20100413095815.GU25756@csn.ul.ie>
 <20100413111902.GY2493@dastard>
 <20100413193428.GI25756@csn.ul.ie>
 <20100413202021.GZ13327@think>
 <877hoa9wlv.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877hoa9wlv.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:06:36PM +0200, Andi Kleen wrote:
> Chris Mason <chris.mason@oracle.com> writes:
> >
> > Huh, 912 bytes...for select, really?  From poll.h:
> >
> > /* ~832 bytes of stack space used max in sys_select/sys_poll before allocating
> >    additional memory. */
> > #define MAX_STACK_ALLOC 832
> > #define FRONTEND_STACK_ALLOC    256
> > #define SELECT_STACK_ALLOC      FRONTEND_STACK_ALLOC
> > #define POLL_STACK_ALLOC        FRONTEND_STACK_ALLOC
> > #define WQUEUES_STACK_ALLOC     (MAX_STACK_ALLOC - FRONTEND_STACK_ALLOC)
> > #define N_INLINE_POLL_ENTRIES   (WQUEUES_STACK_ALLOC / sizeof(struct poll_table_entry))
> >
> > So, select is intentionally trying to use that much stack.  It should be using
> > GFP_NOFS if it really wants to suck down that much stack...
> 
> There are lots of other call chains which use multiple KB bytes by itself,
> so why not give select() that measly 832 bytes?
> 
> You think only file systems are allowed to use stack? :)

Grin, most definitely.

> 
> Basically if you cannot tolerate 1K (or more likely more) of stack
> used before your fs is called you're toast in lots of other situations
> anyways.

Well, on a 4K stack kernel, 832 bytes is a very large percentage for
just one function.

Direct reclaim is a problem because it splices parts of the kernel that
normally aren't connected together.  The people that code in select see
832 bytes and say that's teeny, I should have taken 3832 bytes.

But they don't realize their function can dive down into ecryptfs then
the filesystem then maybe loop and then perhaps raid6 on top of a
network block device.

> 
> > kernel had some sort of way to dynamically allocate ram, it could try
> > that too.
> 
> It does this for large inputs, but the whole point of the stack fast
> path is to avoid it for common cases when a small number of fds is
> only needed.
> 
> It's significantly slower to go to any external allocator.

Yeah, but since the call chain does eventually go into the allocator,
this function needs to be more stack friendly.

I do agree that we can't really solve this with noinline_for_stack pixie
dust, the long call chains are going to be a problem no matter what.

Reading through all the comments so far, I think the short summary is:

Cleaning pages in direct reclaim helps the VM because it is able to make
sure that lumpy reclaim finds adjacent pages.  This isn't a fast
operation, it has to wait for IO (infinitely slow compared to the CPU).

Will it be good enough for the VM if we add a hint to the bdi writeback
threads to work on a general area of the file?  The filesystem will get
writepages(), the VM will get the IO it needs started.

I know Mel mentioned before he wasn't interested in waiting for helper
threads, but I don't see how we can work without it.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
