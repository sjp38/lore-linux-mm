Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7384D6B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 10:37:54 -0400 (EDT)
Date: Sun, 31 May 2009 07:38:26 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090531073826.567d1dc3@infradead.org>
In-Reply-To: <1243679973.6645.131.camel@laptop>
References: <20090522073436.GA3612@elte.hu>
	<20090522113809.GB13971@oblivion.subreption.com>
	<20090522143914.2019dd47@lxorguk.ukuu.org.uk>
	<20090522180351.GC13971@oblivion.subreption.com>
	<20090522192158.28fe412e@lxorguk.ukuu.org.uk>
	<20090522234031.GH13971@oblivion.subreption.com>
	<20090523090910.3d6c2e85@lxorguk.ukuu.org.uk>
	<20090523085653.0ad217f8@infradead.org>
	<1243539361.6645.80.camel@laptop>
	<20090529073217.08eb20e1@infradead.org>
	<20090530054856.GG29711@oblivion.subreption.com>
	<1243679973.6645.131.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Sat, 30 May 2009 12:39:33 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> > > So if you zero on free, the next allocation will reuse the zeroed
> > > page. And due to LIFO that is not too far out "often", which
> > > makes it likely the page is still in L2 cache.
> > 
> > Thanks for pointing this out clearly, Arjan.
> 
> Thing is, the time between allocation and use is typically orders of
> magnitude less than between free and use. 
> 
> 
> Really, get a life, go fix real bugs. Don't make our kernel slower 

the "make it slower" is an assumption on your part.
I'm not convinced. Would like to see data!

You're balancing a few things in your assumption
* The %age of pages that get zeroed on free, but not used in time and
  get flushed from L2 before they are used
* The %age of pages that today doesn't get zeroed 
versus
* The %age of the page that you are not going to read if you zero on use
  but does wipe a portion of L1 cache

add to that
* Reading a just allocated page is much more rare than writing to it.
  It's just zeros after all ;-)
  it is unclear (and cpu dependent) if writing makes it matter if the
  old (zero) data is in the cache or not, reducing the value of your
  "but it's now in the cache" value argument.
* My assumption is that allocations are more latency sensitive than
  free. After all, on allocate, you're going to use it, while on free
  you're done with what you wanted to do, and performance of that on
  average is assumed by me to matter less.
* We "need" to zero-on-allocate while holding the mmap semaphore,
  on free we clearly don't. We know this gives lock contention in 
  highly threaded workloads... and zero-on-free gets rid of that
  entirely.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
