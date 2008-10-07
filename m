Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <48EB7E59.7070308@linux-foundation.org>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <48EB6D2C.30806@linux-foundation.org> <1223391655.13453.344.camel@calx>
	 <48EB7E59.7070308@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 07 Oct 2008 10:58:19 -0500
Message-Id: <1223395099.13453.363.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-07 at 10:20 -0500, Christoph Lameter wrote:
> Matt Mackall wrote:
> 
> > We can't dynamically determine whether a pointer points to a kmalloced
> > object or not. kmem_cache_alloc objects have no header and live on the
> > same pages as kmalloced ones.
> 
> Could you do a heuristic check? Assume that this is a kmalloc object and then
> verify the values in the small control block? If the values are out of line
> then this cannot be a kmalloc'ed object.

The control block is two bytes, so it doesn't have a lot of redundancy.
Best we can do is check that it doesn't claim the object runs off the
page. Or, for simplicity, isn't bigger than a page. On 32-bit x86,
that's equivalent to checking the top 5 bits of ->units are clear.

But it makes more sense to just do the check in SLUB. First, SLUB can
actually do the check reliably. Second, someone adding a bogus ksize
call to a random piece of kernel code is more likely to be using SLUB
when they do it. And third, it doesn't negatively impact SLOB's size.
In other words, SLUB is effectively SLOB's debugging switch when it
comes to external problems.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
