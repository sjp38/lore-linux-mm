Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95863280251
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:32:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id i193so54157681oib.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:32:03 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id m2si2221832oia.110.2016.09.27.09.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 09:31:55 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id t83so21579721oie.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:31:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160927143426.GP2794@worktop>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net> <20160927143426.GP2794@worktop>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Sep 2016 09:31:54 -0700
Message-ID: <CA+55aFzqQkbHLHr+n+=ZsG=UzFCz1XywEYKCmbz+wmrX7g=67g@mail.gmail.com>
Subject: Re: page_waitqueue() considered harmful
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 7:34 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> Right, I never really liked that patch. In any case, the below seems to
> boot, although the lock_page_wait() thing did get my brain in a bit of a
> twist. Doing explicit loops with PG_contended inside wq->lock would be
> more obvious but results in much more code.
>
> We could muck about with PG_contended naming/placement if any of this
> shows benefit.
>
> It does boot on my x86_64 and builds a kernel, so it must be perfect ;-)

This patch looks very much like what I was thinking of. Except you
made that bit clearing more complicated than I would have done.

I see why you did it (it's hard to clear the bit when the wait-queue
that is associated with it can be associated with multiple pages), but
I think it would be perfectly fine to just not even try to make the
"contended" bit be an exact bit. You can literally leave it set
(giving us the existing behavior), but then when you hit the
__unlock_page() case, and you look up the page_waitqueue(), and find
that the waitqueue is empty, *then* you clear it.

So you'd end up going through the slow path one too many times per
page, but considering that right now we *always* go through that
slow-path, and the "one too many times" is "two times per IO rather
than just once", it really is not a performance issue. I'd rather go
for simple and robust.

I get a bit nervous when I see you being so careful in counting the
number of waiters that match the page key - if any of that code ever
gets it wrong (because two different pages that shared a waitqueue
happen to race at just the right time), and the bit gets cleared too
early, you will get some *very* hard-to-debug problems.

So I actually think your patch is a bit too clever.

But maybe there's a reason for that that I just don't see. My gut feel
is that your patch is good.

.. and hey, it booted and compiled the kernel, so as you say, it must
be perfect.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
