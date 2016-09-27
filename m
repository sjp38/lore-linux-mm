Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7C8828024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:49:06 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e20so45636724itc.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:49:06 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id r190si11949819itg.88.2016.09.27.09.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 09:49:05 -0700 (PDT)
Date: Tue, 27 Sep 2016 18:49:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927164903.GO5016@twins.programming.kicks-ass.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160927143426.GP2794@worktop>
 <CA+55aFzqQkbHLHr+n+=ZsG=UzFCz1XywEYKCmbz+wmrX7g=67g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzqQkbHLHr+n+=ZsG=UzFCz1XywEYKCmbz+wmrX7g=67g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 09:31:54AM -0700, Linus Torvalds wrote:
> On Tue, Sep 27, 2016 at 7:34 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > Right, I never really liked that patch. In any case, the below seems to
> > boot, although the lock_page_wait() thing did get my brain in a bit of a
> > twist. Doing explicit loops with PG_contended inside wq->lock would be
> > more obvious but results in much more code.
> >
> > We could muck about with PG_contended naming/placement if any of this
> > shows benefit.
> >
> > It does boot on my x86_64 and builds a kernel, so it must be perfect ;-)
> 
> This patch looks very much like what I was thinking of. Except you
> made that bit clearing more complicated than I would have done.
> 
> I see why you did it (it's hard to clear the bit when the wait-queue
> that is associated with it can be associated with multiple pages), but
> I think it would be perfectly fine to just not even try to make the
> "contended" bit be an exact bit. You can literally leave it set
> (giving us the existing behavior), but then when you hit the
> __unlock_page() case, and you look up the page_waitqueue(), and find
> that the waitqueue is empty, *then* you clear it.
> 
> So you'd end up going through the slow path one too many times per
> page, but considering that right now we *always* go through that
> slow-path, and the "one too many times" is "two times per IO rather
> than just once", it really is not a performance issue. I'd rather go
> for simple and robust.

My clear already does that same thing, once we find nobody to wake up we
clear, this means we did the waitqueue lookup once in vain. But yes it
allows the bit to be cleared while there are still waiters (for other
bits) on the waitqueue.

The other benefit of doing what you suggest (and Nick does) is that you
can then indeed use the bit for other waitqueue users like PG_writeback.
I never really got that part of the patch as it wasn't spelled out, but
it does make sense now that I understand the intent.

And assuming collisions are rare, that works just fine.

> I get a bit nervous when I see you being so careful in counting the
> number of waiters that match the page key - if any of that code ever
> gets it wrong (because two different pages that shared a waitqueue
> happen to race at just the right time), and the bit gets cleared too
> early, you will get some *very* hard-to-debug problems.

Right, so I don't care about the actual number, just it being 0 or not.
Maybe I should've returned bool.

But yes, its a tad more tricky than I'd liked, mostly because I was
lazy. Doing the SetPageContended under the wq->lock would've made things
more obvious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
