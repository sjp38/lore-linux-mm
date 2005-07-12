Date: Tue, 12 Jul 2005 14:05:37 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
In-Reply-To: <20050711195540.681182d0.pj@sgi.com>
Message-ID: <Pine.LNX.4.58.0507121353470.32323@skynet>
References: <1121101013.15095.19.camel@localhost> <42D2AE0F.8020809@austin.ibm.com>
 <20050711195540.681182d0.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Joel Schopp <jschopp@austin.ibm.com>, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jul 2005, Paul Jackson wrote:

> Joel wrote:
> > I wouldn't mind  changing __GFP_USERRCLM to __GFP_USERALLOC
> > or some neutral name we could share.
>
> A neutral term would be good.

I agree as having two flags for essentially the same thing is just
a waste. I guess there will be some discussion on what the other
fragmentation flags should be called.

For consistency, we might want to rethink the name of KERNRCLM. I am still
happy with the name as it says "this kernel allocation is something that
will be reclaimed shortly or can be reclaimed on demand" but others might
feel differently.

> Dave wrote:
> > The nice part about using __GFP_USER as the name is that it describes
> > how it's going to be used rather than how the kernel is going to treat
> > it.
>
> Yup - agreed.  Though, in real life, that's hidden beneath the (no
> underscore) GFP_USER flag, so it's only a few kernel memory hackers
> we will be confusing, not the horde of driver writers.
>
> One question.  I've not actually read the memory fragmentation
> avoidance patch, so this might be a stupid question.  That
> notwithstanding, do you really need two flags, one KERN and one USER?

There are two GFP flags to determine three types of allocation

__GFP_USERRCLM => Allocation is a user page or a disk buffer page
__GFP_KERNRCLM => Kernel reclaimable allocation or one that is short-lived

Neither flag set implies a normal kernel allocation that is not expected
to be reclaimed.

Joel, when merging the patches, there is one hack you need to watch out
for. It is important for performance reasons but it is 100% obvious
either.

gfp_flags & (__GFP_KERNRCLM | __GFP_USERRCLM) >> __GFP_TYPE_SHIFT gives
the type of allocation as ALLOC_USERRCLM, ALLOC_KERNRCLM, ALLOC_KERNNORCLM
or ALLOC_FALLBACK. Th ALLOC_* values are used to index into the array of
freelists in the struct zone.

If the USER flag is shared, it means that your patches will be adding the
__GFP_KERNRCLM flag which reverses the values. This means you will also
need to update the values of ALLOC_* to keep the __GFP_TYPE_SHIFT hack
working. Older patches used a switch statement on the flags but it takes a
surprising length of time in a critical path.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
