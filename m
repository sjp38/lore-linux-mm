Date: Wed, 7 Mar 2007 14:08:51 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307130851.GE18704@wotan.suse.de>
References: <1173262002.6374.128.camel@twins> <E1HOt96-0008V6-00@dorka.pomaz.szeredi.hu> <20070307102106.GB5555@wotan.suse.de> <1173263085.6374.132.camel@twins> <20070307103842.GD5555@wotan.suse.de> <1173264462.6374.140.camel@twins> <20070307110035.GE5555@wotan.suse.de> <1173268086.6374.157.camel@twins> <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1173271286.6374.166.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 01:41:26PM +0100, Peter Zijlstra wrote:
> On Wed, 2007-03-07 at 13:17 +0100, Nick Piggin wrote:
> 
> > > Tracking these ranges on a per-vma basis would avoid taking the mm wide
> > > mmap_sem and so would be cheaper than regular vmas.
> > > 
> > > Would that still be too expensive?
> > 
> > Well you can today remap N pages in a file, arbitrarily for
> > sizeof(pte_t)*tiny bit for the upper page tables + small constant
> > for the vma.
> > 
> > At best, you need an extra pointer to pte / vaddr, so you'd basically
> > double memory overhead.
> 
> I was hoping some form of range compression would gain something, but if
> its a fully random mapping, then yes a shadow page table would be needed
> (still looking into what a pte_chain is)
> 
> > > > > Well, now they don't, but it could be done or even exploited as a DoS.
> > > > 
> > > > But so could nonlinear page reclaim. I think we need to restrict nonlinear
> > > > mappings to root if we're worried about that.
> > > 
> > > Can't we just 'fix' it?
> > 
> > The thing is, I don't think anybody who uses these things cares
> > about any of the 'problems' you want to fix, do they? We are
> > interested in dirty pages only for the correctness issue, rather
> > than performance. Same as reclaim.
> 
> If so, we can just stick to the dead slow but correct 'scan the full
> vma' page_mkclean() and nobody would ever trigger it.

Not if we restricted it to root and mlocked tmpfs. But then why
wouldn't you just do it with the much more efficient msync walk,
so that if root does want to do writeout via these things, it does
not blow up?

> What is the DoS scenario wrt reclaim? We really ought to fix that if
> real, those UML farms run on nothing but nonlinear reclaim I'd think.

I guess you can just increase the computational complexity of
reclaim quite easily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
