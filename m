Date: Sat, 18 Oct 2008 03:53:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081018015323.GA11149@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810172300280.30871@blonde.site> <alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org> <Pine.LNX.4.64.0810180045370.8995@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810180045370.8995@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 18, 2008 at 01:13:16AM +0100, Hugh Dickins wrote:
> On Fri, 17 Oct 2008, Linus Torvalds wrote:
> > would be more obvious in the place where we actually fetch that "anon_vma" 
> > pointer again and actually derefernce it.
> > 
> > HOWEVER:
> > 
> >  - there are potentially multiple places that do that, and putting it in 
> >    the anon_vma_prepare() thing not only matches things with the 
> >    smp_wmb(), making that whole pairing much more obvious, but it also 
> >    means that we're guaranteed that any anon_vma user will have done the 
> >    smp_read_barrier_depends(), since they all have to do that prepare 
> >    thing anyway.
> 
> No, it's not so that any anon_vma user would have done the
> smp_read_barrier_depends() placed in anon_vma_prepare().
> 
> Anyone faulting in a page would have done it (swapoff? that
> assumes it's been done, let's not worry about it right now).
> 
> But they're doing it to make the page's ptes accessible to
> memory reclaim, and the CPU doing memory reclaim will not
> (unless by coincidence) have done that anon_vma_prepare() -
> it's just reading the links which the faulters are providing.

Yes, that's a very important flaw you point out with the fix. Good
spotting.

Actually another thing I was staying awake thinking about was the
pairwise consistency problem. "Apparently" Linux is supposed to
support arbitrary pairwise consistency.

This means.
CPU0
anon_vma.initialized = 1;
smp_wmb()
vma->anon_vma = anon_vma;

CPU1
if (vma->anon_vma)
  page->anon_vma = vma->anon_vma;

CPU2
if (page->anon_vma) {
  smp_read_barrier_depends();
  assert(page->anon_vma.initialized);
}

The assertion may trigger because the store from CPU0 may not have
propograted to CPU2 before the stores from CPU1.

But after thinking about this a bit more, I think Linux would be
broken all over the map under such ordering schemes. I think we'd
have to mandate causal consistency. Are there any architectures we
run on where this is not guaranteed? (I think recent clarifications
to x86 ordering give us CC on that architecture).

powerpc, ia64, alpha, sparc, arm, mips? (cced linux-arch)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
