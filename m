Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
	nonlinear)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070307130851.GE18704@wotan.suse.de>
References: <1173262002.6374.128.camel@twins>
	 <E1HOt96-0008V6-00@dorka.pomaz.szeredi.hu>
	 <20070307102106.GB5555@wotan.suse.de> <1173263085.6374.132.camel@twins>
	 <20070307103842.GD5555@wotan.suse.de> <1173264462.6374.140.camel@twins>
	 <20070307110035.GE5555@wotan.suse.de> <1173268086.6374.157.camel@twins>
	 <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins>
	 <20070307130851.GE18704@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 14:19:22 +0100
Message-Id: <1173273562.6374.175.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-07 at 14:08 +0100, Nick Piggin wrote:

> > > The thing is, I don't think anybody who uses these things cares
> > > about any of the 'problems' you want to fix, do they? We are
> > > interested in dirty pages only for the correctness issue, rather
> > > than performance. Same as reclaim.
> > 
> > If so, we can just stick to the dead slow but correct 'scan the full
> > vma' page_mkclean() and nobody would ever trigger it.
> 
> Not if we restricted it to root and mlocked tmpfs. But then why
> wouldn't you just do it with the much more efficient msync walk,
> so that if root does want to do writeout via these things, it does
> not blow up?

This is all used on ram based filesystems right, they all have
BDI_CAP_NO_WRITEBACK afaik, so page_mkclean will never get called
anyway. Mlock doesn't avoid getting page_mkclean called.

Those who use this on a 'real' filesystem will get hit in the face by a
linear scanning page_mkclean(), but AFAIK nobody does this anyway.

Restricting it to root for such filesystems is unwanted, that'd severely
handicap both UML and Oracle as I understand it (are there other users
of this feature around?)

msync() might never get called and then we're back with the old
behaviour where we can surprise the VM with a ton of dirty pages.

> > What is the DoS scenario wrt reclaim? We really ought to fix that if
> > real, those UML farms run on nothing but nonlinear reclaim I'd think.
> 
> I guess you can just increase the computational complexity of
> reclaim quite easily.

Right, on first glance it doesn't look to be too bad, but I should take
a closer look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
