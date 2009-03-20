Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9986B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 20:54:58 -0400 (EDT)
Date: Thu, 19 Mar 2009 17:49:27 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
In-Reply-To: <604427e00903191734l42376eebsee018e8243b4d6f5@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.0903191741280.3030@localhost.localdomain>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>  <20090318151157.85109100.akpm@linux-foundation.org>  <alpine.LFD.2.00.0903181522570.3082@localhost.localdomain> <604427e00903191734l42376eebsee018e8243b4d6f5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>



On Thu, 19 Mar 2009, Ying Han wrote:
> >
> > Ying Han - since you're all set up for testing this and have reproduced it
> > on multiple kernels, can you try it on a few more kernel versions? It
> > would be interesting to both go further back in time (say 2.6.15-ish),
> > _and_ check something like 2.6.21 which had the exact dirty accounting
> > fix. Maybe it's not really an old bug - maybe we re-introduced a bug that
> > was fixed for a while.
> 
> I tried 2.6.24 for couple of hours and the problem not happening yet. While
> the same test on 2.6.25, the problem happen right away.

Ok, so 2.6.25 is known bad. Can you test 2.6.24 a lot more, because we 
should not decide that it's bug-free without a _lot_ of testing.

But if it's a bug that has gone away and then re-appeared, it at least 
explains how 2.6.21 (which got a fair amount of mmap testing) didn't have 
lots of reports of mmap corruption.

That said, I can think of nothing obvious in between 2.6.24 and .25 that 
would have re-introduced it. But if some heavy testing really does confirm 
that 2.6.24 doesn't have the problem, that is a good first step to trying 
to narrow down where things started going wrong.

That said, it could _easily_ be some timing-related pattern. One of the 
things in between 2.6.24 and .25 is

 - 8bc3be2751b4f74ab90a446da1912fd8204d53f7: "writeback: speed up 
   writeback of big dirty files"

which is that exact kind of "change the timing patterns, but don't change 
anything fundamental" thing.

Which is why I'd like you to continue testing 2.6.24 just to be _really_ 
sure that it really doesn't happen there.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
