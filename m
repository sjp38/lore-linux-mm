Date: Tue, 13 Nov 2007 01:51:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/6] mm: speculative get page
Message-ID: <20071113005143.GF30650@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de> <20071111085004.GF19816@wotan.suse.de> <Pine.LNX.4.64.0711121216150.27479@schroedinger.engr.sgi.com> <20071113003525.GD30650@wotan.suse.de> <Pine.LNX.4.64.0711121636170.29328@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711121636170.29328@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 12, 2007 at 04:37:28PM -0800, Christoph Lameter wrote:
> On Tue, 13 Nov 2007, Nick Piggin wrote:
> 
> > > Good idea. That avoids another page bit.
> > 
> > Yeah, it's Hugh's good idea. It avoids smp_rmb() in the find_get_page
> > path as well, which will be helpful at least for things like powerpc
> > and ia64, if not x86. At one single atomic operation to lookup and take
> > a reference on a pagecache page, I think it is approaching the fastest
> > possible implementation ;)
> 
> Well I hope all locations that do get_page_unless_zero are aware that a 
> failure does not mean that the page is being freed.

Often it does mean the page will be freed soon anyway, so it fits quite well.
But no, nothing assumes the page will be freed. It is hard to imagine the use
of such knowledge would be (outside the page allocator).

You can't use it to assume the page is going to be free at any point T+now,
nor can you assume the pagecache coordinate which used to hold the page is
empty.


> > > Looks okay but I think you could remove the earlier performance check. We 
> > > already modified the page struct by obtaining the page lock so we hold it 
> > > exclusively. And the failure rate here is typicalyvery low.
> > 
> > It's up to you. Honestly, I don't have good test facilities for page
> > migration. If it's all the same to you, do you mind if we leave it like
> > this, and then you can change it in future?
> 
> Ok. Lee will likely get to that ;-).

OK good, thanks ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
