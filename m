Date: Fri, 15 Nov 2002 08:58:27 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: get_user_pages rewrite rediffed against 2.5.47-mm1
Message-ID: <20021115085827.Z659@nightmaster.csn.tu-chemnitz.de>
References: <20021112205848.B5263@nightmaster.csn.tu-chemnitz.de> <3DD1642A.4A7C663C@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DD1642A.4A7C663C@digeo.com>; from akpm@digeo.com on Tue, Nov 12, 2002 at 12:27:22PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Tue, Nov 12, 2002 at 12:27:22PM -0800, Andrew Morton wrote:
> I think I see what you're doing now.  You've overloaded the callback,
> with an IS_ERR value of "page" to mean "something went wrong".
> 
> Would that be a correct interpretation?
> 
> If so, it would be better (ie: more Linus-friendly) to make that a
> separate callback.  One which is called outside the lock, and which
> has distinctly different semantics from the normal page walker.
 
Ok, did that. It also reduced code. I just thought it will
increase complexity, but it proved to reduce it.

> Some (all?) callers of walk_user_pages() may not even be interested
> in the error-time callout.  In fact it may be possible to just leave
> the state at time-of-error in the state structure (see below) and just
> return an error code to the caller of walk_user_pages()?
 
I fear that users forget the cleanup, if they have to repeat and
duplicate it. Until now they DO the cleanup themselves, after
using the structures, but not in case of error. Providing a
cleanup function factors out the cleanup nicely.

I envision the following usage:

setup(&page_walk,...); /* currently done explicitly on stack */
walk_user_pages(&page_walk);

/* Do fancy stuff with that pages */

cleanup(&page_walk); /* calling internal cleanup function 
                        and free the page array */

How does that sound?

> I suggest that it's time to fold all these arguments into a structure
> which is on the caller's stack, and pass the address of that around.
> This will simplify things, but one needs to be careful to think through
> the ownership rules of the various parts of that structure.

I'm working on this, but that means a new header file, a new *.c
file and exporting all the page walkers introduced by me to the
modules.

It sure will reduce stack usage although we recurse deeper.
That's a good think already.

> Please review your ERR_PTR handling.

Done. Had it otherwise before, but got confused about the code in
linux/err.h.

> Also, please rip everything which is appropriate out of mm/memory.c
> and create a new file in mm/ for it.

Everything regarding page walking, or should I cleanup more?
In fact mm/memory.c really looks like a mm/misc.c ;-)

> I cannot guarantee that we can get this merged up, frankly.  We need
> a *reason* for doing that.  The current code is "good enough" for
> current callers.

The current code sucks for char devices which have much IO
traffic via DMA. That might not be much, but the number is
increasing and I'm sure many drivers for measuring cards, which
will never make it into the kernel, would benefit from that.

All improvements in that direction have only been with block devices
in mind so far. I even don't see how I could improve the usage in
fs/dio.c, because it might sleep very long, so I can't use a page
walker for it (which needs the mmap_sem).

> So the best I can do is to get it under test, give
> Linus a heads-up that it's floating about while you get in there and
> start creating reasons for merging it - namely the clients down in
> device drivers.
>
> If we don't make it then we can definitely push it for 2.7.
> 
> How does that suit?

That sounds great! I'll create reasons. People with 4K-Stack will
love that, I think ;-)

And it will cleanup, shrink and correct every usage. I uncovered
already 2 Bugs on the go, so it's definitly worth it anyway.

Patch follows Saturday or Sunday morning. Its not complete, yet.

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
