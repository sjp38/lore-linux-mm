Date: Tue, 9 Aug 2005 21:17:17 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
In-Reply-To: <200508100514.13672.phillips@arcor.de>
Message-ID: <Pine.LNX.4.61.0508092112050.16395@goblin.wat.veritas.com>
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de>
 <42F7F5AE.6070403@yahoo.com.au> <200508100514.13672.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Aug 2005, Daniel Phillips wrote:
> On Tuesday 09 August 2005 10:15, Nick Piggin wrote:
> > Daniel Phillips wrote:
> > > Why don't you pass the vma in zap_details?
> >
> > Possibly. I initially did it that way, but it ended up fattening
> > paths that don't use details.
> 
> It should not, it only affects, hmm, less than 10 places, each at the 
> beginning of a massive call chain, e.g., in madvise_dontneed:
> 
> -	zap_page_range(vma, start, end - start, NULL);
> +	zap_page_range(start, end - start, &(struct zap){ .vma = vma });
> 
> > And this way is less intrusive.
> 
> Nearly the same I think, and makes forward progress in controlling this 
> middle-aged belly roll of an internal API.

I much prefer how Nick has it, with vma passed separately as a regular
argument.  details is for packaging up some details only required in
unlikely circumstances, normally it's NULL and not filled in at all.

You can argue that (vma->vm_flags & VM_RESERVED) is precisely that
kind of detail.  But personally I find it rather odd that vma isn't
an explicit argument to zap_pte_range already - I find it very useful
when trying to shed light on the rmap.c:BUG, for example.

There might be a case for packaging repeated arguments into structures
(though several of these levels are inlined anyway), but that's some
other exercise entirely, shouldn't get in the way of removing Reserved.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
