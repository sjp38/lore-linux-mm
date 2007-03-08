Date: Thu, 8 Mar 2007 13:19:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] mm: fix page_mkclean() vs non-linear vmas
Message-ID: <20070308121930.GB22781@wotan.suse.de>
References: <1173273562.6374.175.camel@twins> <20070307133649.GF18704@wotan.suse.de> <1173275532.6374.183.camel@twins> <1173278067.6374.188.camel@twins> <20070307150102.GH18704@wotan.suse.de> <1173286682.6374.191.camel@twins> <E1HPGg9-00039z-00@dorka.pomaz.szeredi.hu> <1173353824.9438.15.camel@twins> <E1HPH6v-0003CT-00@dorka.pomaz.szeredi.hu> <1173355903.9438.18.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1173355903.9438.18.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, jdike@addtoit.com, hugh@veritas.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 08, 2007 at 01:11:43PM +0100, Peter Zijlstra wrote:
> On Thu, 2007-03-08 at 12:48 +0100, Miklos Szeredi wrote:
> > > However this still leaves the non-linear reclaim (Nick pointed it out as
> > > a potential DoS and other people have corroborated this). I have no idea
> > > on that to do about that.
> > 
> > OK, but that is a completely different problem, not affecting
> > page_mkclean() or msync().
> > 
> > And it doesn't sound too hard to solve: when current algorithm doesn't
> > seem to be making progress, then it will have to be done the hard way,
> > searching for for all nonlinear ptes of a page to unmap.
> 
> Ah, you see, but that is when you've already lost.
> 
> The DoS is about the computational complexity of the reclaim, not if it
> will ever come out of it with free pages.

If we really want to, we could limit it to mlock for !root. This is
a reasonable way to solve the problem, and UML could fall back on
vma emulated version if they didn't want to use mlock memory...

Or we could limit the size/number of nonlinear vmas that could be
created.

But just quietly, I think there are probably a lot of other ways to
perform a local DoS anyway ;) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
