Date: Wed, 27 Jul 2005 12:10:14 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
In-Reply-To: <20050727012944.6ce7bb9a.pj@sgi.com>
Message-ID: <Pine.LNX.4.58.0507271054240.30974@skynet>
References: <1121101013.15095.19.camel@localhost> <42D2AE0F.8020809@austin.ibm.com>
 <20050711195540.681182d0.pj@sgi.com> <Pine.LNX.4.58.0507121353470.32323@skynet>
 <20050712132940.148a9490.pj@sgi.com> <Pine.LNX.4.58.0507130815420.1174@skynet>
 <20050714040613.10b244ee.pj@sgi.com> <Pine.LNX.4.58.0507181328480.2899@skynet>
 <20050727012944.6ce7bb9a.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jul 2005, Paul Jackson wrote:

> Mel wrote:
> > That makes sense to me. Taking into account other threads, attached are
> > patches 01 and 02 from Joels patchset with the different namings and
> > comments. The main changes are the renaming of __GFP_USERRCLM to
> > __GFP_USER to be neutral and comments explaining how the RCLM flags are
> > tied together.
>
> Ok - gaining.
>
> One thing still confuses me here.  What would it mean to have a gfp
> flag with both (__GFP_USER|__GFP_KERNRCLM) bits set?  Is this a valid
> gfp flag, or is it just in pfn's that both bits can be set (meaning
> FALLBACK)?
>

I would consider that combination a bug because it does not make sense.
The side-effect is that the allocation type starts as a fallback which
will work, but does not make sense.

> If both bits can be set at the same time in a gfp flag, then I don't
> think either of the following two comments are accurate:
>

They can't, but it is not enforced

> +#define __GFP_USER     0x40000u /* Easily reclaimable userspace page */
> +#define __GFP_KERNRCLM 0x80000u /* Kernel page that is easily reclaimable */
>
> Just looking at the GFP_USER bit and seeing it is set doesn't tell me
> for sure it's a userspace page request.  It might be a reclaimable
> kernel page that we had to fallback on, right?  Similarly for the
> __GFP_KERNRCLM bit.
>

No, the bit is set by the caller. The caller should only have this bit set
if the allocation is a userspace allocation that can be reclaimed. That
said, I have since found that setting the __GFP_USERRCLM bit on GFP_USER
and GFP_HIGHUSER is not the correct thing to do as GFP_USER and
GFP_HIGHUSER can be for allocations that are not reclaimable.

> And if both bits can be set in a gfp flag at the same time, then the
> test that _I_ need, for my two flavors of cpuset allocation is not
> possible, because I need to distinguish FALLBACK allocations for
> USER space requests from FALLBACK allocations for KERNEL space
> requests (USER space memory placement is confined more tightly).
>

If you have to be sure the two bits are not set, then a check can be made
and BUG() called

> Continuing this line of inquiry, what does it mean if neither bit
> is set in a gfp flag?  I guess that's a valid gfp flag, and it means
> that the request is for non-reclaimable kernel memory.  Is that
> right?  If so, fine and this detail doesn't impact my intended use.
>

That is correct

> But the overloading of both bits set to mean FALLBACK,

The reason the fallback bits are needed at all is to flag regions of
physical memory to be used for any time of allocation. i.e. Try to place
allocations in the right place, but failing that, use a fallback region,
failing that, use anywhere at all.

> in the gfp
> flag, if that's what you intend here, does seem to make the apparent
> flagging userspace requests useless to my purposes, because I want
> to treat userspace FALLBACK requests differently than kernelspace
> FALLBACKs.  For me, they are still userspace and kernel space.  For
> you, they are both FALLBACKs.  If my train of thought here hasn't
> gone off the rails, this would mean that I would still need my own
> GFP USER flag, and that I would encourage you to reinstate the
> RCLM tag on your __GFP_USER* flag, to distinguish it from mine.

I am not convinced we need the separate flag yet. Does it make a
difference that both flags should never be specified for an allocation?

We are using the same bit right now for different reasons. In our case, it
determines where the page, in physical memory, the allocated page comes
from. In your case, it determines if the page should be allocated at all

> That, or perhaps it works to _not_ encode the fallback case in the
> gfp flags using the USER|KERN bits both set, but rather have a
> separate bit for the FALLBACK case.  I can appreciate that in pfn's
> you have to encode this tightly for performance, but I'd be surprised
> if you have to do so in gfp flags for performance.
>

Bits are per 2^(MAX_ORDER-1) number of pages, not every page frame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
