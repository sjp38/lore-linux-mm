Date: Sat, 18 Oct 2008 07:49:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081018054916.GB26472@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810172300280.30871@blonde.site> <alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org> <Pine.LNX.4.64.0810180045370.8995@blonde.site> <20081018015323.GA11149@wotan.suse.de> <18681.20241.347889.843669@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18681.20241.347889.843669@cargo.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 18, 2008 at 01:50:57PM +1100, Paul Mackerras wrote:
> Nick Piggin writes:
> 
> > But after thinking about this a bit more, I think Linux would be
> > broken all over the map under such ordering schemes. I think we'd
> > have to mandate causal consistency. Are there any architectures we
> > run on where this is not guaranteed? (I think recent clarifications
> > to x86 ordering give us CC on that architecture).
> > 
> > powerpc, ia64, alpha, sparc, arm, mips? (cced linux-arch)
> 
> Not sure what you mean by causal consistency, but I assume it's the

I think it can be called transitive. Basically (assumememory starts off zeroed)
CPU0
x := 1

CPU1
if (x == 1) {
  fence
  y := 1
}

CPU2
if (y == 1) {
  fence
  assert(x == 1)
}


As opposed to pairwise, which only provides an ordering of visibility between
any given two CPUs (so the store to y might be propogated to CPU2 after the
store to x, regardless of the fences).

Apparently pairwise ordering is more interesting than just a theoretical
thing, and not just restricted to Alpha's funny caches. It can allow for
arbitrary network propogating stores / cache coherency between CPUs. x86's
publically documented memory model supposedly could allow for such ordering
up until a year or so ago (when they clarified and strengthened it).


> same as saying that barriers give cumulative ordering, as described on
> page 413 of the Power Architecture V2.05 document at:
> 
> http://www.power.org/resources/reading/PowerISA_V2.05.pdf
> 
> The ordering provided by sync, lwsync and eieio is cumulative (see
> pages 446 and 448), so we should be OK on powerpc AFAICS.  (The
> cumulative property of eieio only applies to accesses to normal system
> memory, but that should be OK since we use sync when we want barriers
> that affect non-cacheable accesses as well as cacheable.)

The section on cumulative ordering sounds like it might do the trick. But
I haven't really worked through exactly what it is saying ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
