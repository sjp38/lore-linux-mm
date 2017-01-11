Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7409D6B0033
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 20:33:56 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 127so767735888pfg.5
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 17:33:56 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q145si683467pfq.40.2017.01.10.17.33.54
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 17:33:55 -0800 (PST)
Date: Wed, 11 Jan 2017 10:29:00 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170111012900.GU2279@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
 <20170110200850.GE3092@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110200850.GE3092@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Jan 10, 2017 at 09:08:50PM +0100, Peter Zijlstra wrote:
> But I still feel this document is very hard to read and presents things
> backwards.

I admit it. I think I need to modify the document more.. I will try it.

> 
> > +Let's take a look at more complicated example.
> > +
> > +   TASK X			   TASK Y
> > +   ------			   ------
> > +   acquire B
> > +
> > +   release B
> > +
> > +   acquire C
> > +
> > +   release C
> > +   (1)
> > +   fork Y
> > +				   acquire AX
> > +   acquire D
> > +   /* A dependency 'AX -> D' exists */
> > +				   acquire F
> > +   release D
> > +				   acquire G
> > +				   /* A dependency 'F -> G' exists */
> > +   acquire E
> > +   /* A dependency 'AX -> E' exists */
> > +				   acquire H
> > +				   /* A dependency 'G -> H' exists */
> > +   release E
> > +				   release H
> > +   release AX held by Y
> > +				   release G
> > +
> > +				   release F
> > +
> > +   where AX, B, C,..., H are different lock classes, and a suffix 'X' is
> > +   added on crosslocks.
> > +
> > +Does a dependency 'AX -> B' exist? Nope.
> 
> I think the above without the "fork Y" line is a much more interesting
> example, because then the answer becomes: maybe.

Sure. The dependency 'AX -> B' might exist in that case. Then we can
add the dependency once we detect it, in other words, once we prove it's
a true dependency. But we cannot add it before we prove it, though it
might be a true one, because it might not be a true one.

> This all boils down to the asynchonous nature of the primitive. There is
> no well defined point other than what is observed (as I think you tried
> to point out in our earlier exchanges).

Exactly.

> The "acquire AX" point is entirely random wrt any action in other
> threads, _however_ the time between "acquire" and "release" of any
> 'lock' is the only time we can be certain of things.
> 
> > +==============
> > +Implementation
> > +==============
> > +
> > +Data structures
> > +---------------
> > +
> > +Crossrelease feature introduces two main data structures.
> > +
> > +1. pend_lock
> 
> I'm not sure 'pending' is the right name here, but I'll consider that
> more when I review the code patches.

Thank you.

> > +
> > +   This is an array embedded in task_struct, for keeping locks queued so
> > +   that real dependencies can be added using them at commit step. Since
> > +   it's local data, it can be accessed locklessly in the owner context.
> > +   The array is filled at acquire step and consumed at commit step. And
> > +   it's managed in circular manner.
> > +
> > +2. cross_lock
> > +
> > +   This is a global linked list, for keeping all crosslocks in progress.
> > +   The list grows at acquire step and is shrunk at release step.
> 
> FWIW, this is a perfect example of why I say the document is written
> backwards. At this point there is no demonstrated need or use for this
> list.

I will consider that more.

> OK, so commit adds multiple dependencies, that makes more sense.
> Previously I understood commit to only add a single dependency, which
> does not make sense (except in the special case where there is but one).
> 
> I dislike how I have to reconstruct this from an example instead of
> first having had the rules stated though.

So do I.

> 
> > +    *
> > +    * In pend_lock: D, E
> > +    * In graph: 'B -> C', 'C -> D',
> > +    *           'AX -> D', 'AX -> E'
> > +    */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
