Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C923E6B01AD
	for <linux-mm@kvack.org>; Thu, 27 May 2010 11:56:08 -0400 (EDT)
Date: Thu, 27 May 2010 10:52:52 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100527143754.GR22536@laptop>
Message-ID: <alpine.DEB.2.00.1005271037060.7221@router.home>
References: <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop> <alpine.DEB.2.00.1005250859050.28941@router.home> <20100525143409.GP5087@laptop> <alpine.DEB.2.00.1005250938300.29543@router.home>
 <20100525151129.GS5087@laptop> <alpine.DEB.2.00.1005251022220.30395@router.home> <20100525153759.GA20853@laptop> <alpine.DEB.2.00.1005270919510.5762@router.home> <20100527143754.GR22536@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010, Nick Piggin wrote:

> > I am just amazed at the tosses and turns by you. Didnt you write SLQB on
> > the basis of SLUB? And then it was abandoned? If you really believe ths
>
> Sure I hoped it would be able to conclusively beat SLAB, and I'd
> thought it might be a good idea. I stopped pushing it because I
> realized that incremental improvements to SLAB would likely be a
> far better idea.

It looked to me as if there was a major conceptual issue with the linked
lists used for objects that impacted performance plus unresolved issues
with crashes on boot. I did not see you work on SLAB improvements. Seemed
that other things had higher priority. The work on slab allocators in
general is not well funded, not high priority and is a side issue. The
time that I can spend on this is also limited.

> > and want to get this done then please invest some time in SLAB to get it
> > cleaned up. I have some doubt that you are aware of the difficulties that
> > you will encounter.
>
> I am working on it. We'll see.

I think we agreee on one thing regardless of SLAB or SLUB as a base: It
would be good to put the best approaches together to form a superior slab
allocator. I just think its much easier to do give a mature and clean code
base in SLUB. If we both work on this then this may coalesce at some
point.

The main gripes with SLAB

- Code base difficult to maintain. Has grown over almost 2 decades.
- Alien caches need to be kept under control. Various hacky ways
  are implemented to bypass that problem.
- Locking issues because of long hold times of per node lock. SLUB
  has locking on per page level. This is important for high number of
  threads per node. Westmere has already 12. EX 24 and it way grow
  from there.
- Debugging features and recovery mechanisms.
- Off or on page slab metadata causes space wastage, complex allocation
  and locking and alignment issues. SLED replaces that metadata structure
  with a bitfield in the page struct. This may also save access to
  additional cacheline and maybe allow freeing of objects to a slab page
  without taking locks.
- Variable and function naming is confusing.
- OS noise caused by periodic cache cleaning (which requires scans over
  all caches of all slabs on every processor).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
