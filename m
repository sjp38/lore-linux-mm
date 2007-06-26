Date: Tue, 26 Jun 2007 13:06:40 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC] fsblock
Message-ID: <20070626030640.GM989688@sgi.com>
References: <20070624014528.GA17609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070624014528.GA17609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 24, 2007 at 03:45:28AM +0200, Nick Piggin wrote:
> 
> I'm announcing "fsblock" now because it is quite intrusive and so I'd
> like to get some thoughts about significantly changing this core part
> of the kernel.

Can you rename it to something other than shorthand for
"filesystem block"? e.g. When you say:

> - In line with the above item, filesystem block allocation is performed

What are we actually talking aout here? filesystem block allocation
is something a filesystem does to allocate blocks on disk, not
allocate a mapping structure in memory.

Realistically, this is not about "filesystem blocks", this is
about file offset to disk blocks. i.e. it's a mapping.

>   Probably better would be to
>   move towards offset,length rather than page based fs APIs where everything
>   can be batched up nicely and this sort of non-trivial locking can be more
>   optimal.

If we are going to turn over the API completely like this, can
we seriously look at moving to this sort of interface at the same
time?

With a offset/len interface, we can start to track contiguous
ranges of blocks rather than persisting with a structure per
filesystem block. If you want to save memory, thet's where
we need to go.

XFS uses "iomaps" for this purpose - it's basically:

	- start offset into file
	- start block on disk
	- length of mapping
	- state 

With special "disk blocks" for indicating delayed allocation
blocks (-1) and unwritten extents (-2). Worst case we end up
with is an iomap per filesystem block.

If we allow iomaps to be split and combined along with range
locking, we can parallelise read and write access to each
file on an iomap basis, etc. There's plenty of goodness that
comes from indexing by range....

FWIW, I really see little point in making all the filesystems
work with fsblocks if the plan is to change the API again in
a major way a year down the track. Let's get all the changes
we think are necessary in one basket first, and then work out
a coherent plan to implement them ;)

> - Large block support. I can mount and run an 8K block size minix3 fs on
>   my 4K page system and it didn't require anything special in the fs. We
>   can go up to about 32MB blocks now, and gigabyte+ blocks would only
>   require  one more bit in the fsblock flags. fsblock_superpage blocks
>   are > PAGE_CACHE_SIZE, midpage ==, and subpage <.

My 2c worth - this is a damn complex way of introducing large block
size support. It has all the problems I pointed out that it would
have (locking issues, vmap overhead, every filesystem needs needs
major changes and it's not very efficient) and it's going to take
quite some time to stabilise.

If this is the only real feature that fsblocks are going to give us,
then I think this is a waste of time. If we are going to replace
buffer heads, lets do it with something that is completely
independent of filesystem block size and not introduce something
that is just a bufferhead on steroids.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
