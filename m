Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6012A6B026A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:08:50 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q20so117206726ioi.0
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 12:08:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 17si3198555pfb.89.2017.01.10.12.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 12:08:49 -0800 (PST)
Date: Tue, 10 Jan 2017 21:08:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170110200850.GE3092@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481260331-360-16-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com


First off my sincere apologies for being so horribly slow with this :/

I did spend some time thinking about this thing during the Christmas
holidays, but have not yet managed to write a coherent text on it like I
promised I'd do.

That said; I think I now mostly understand what and why.

But I still feel this document is very hard to read and presents things
backwards.

> +Let's take a look at more complicated example.
> +
> +   TASK X			   TASK Y
> +   ------			   ------
> +   acquire B
> +
> +   release B
> +
> +   acquire C
> +
> +   release C
> +   (1)
> +   fork Y
> +				   acquire AX
> +   acquire D
> +   /* A dependency 'AX -> D' exists */
> +				   acquire F
> +   release D
> +				   acquire G
> +				   /* A dependency 'F -> G' exists */
> +   acquire E
> +   /* A dependency 'AX -> E' exists */
> +				   acquire H
> +				   /* A dependency 'G -> H' exists */
> +   release E
> +				   release H
> +   release AX held by Y
> +				   release G
> +
> +				   release F
> +
> +   where AX, B, C,..., H are different lock classes, and a suffix 'X' is
> +   added on crosslocks.
> +
> +Does a dependency 'AX -> B' exist? Nope.

I think the above without the "fork Y" line is a much more interesting
example, because then the answer becomes: maybe.

This all boils down to the asynchonous nature of the primitive. There is
no well defined point other than what is observed (as I think you tried
to point out in our earlier exchanges).

The "acquire AX" point is entirely random wrt any action in other
threads, _however_ the time between "acquire" and "release" of any
'lock' is the only time we can be certain of things.

> +==============
> +Implementation
> +==============
> +
> +Data structures
> +---------------
> +
> +Crossrelease feature introduces two main data structures.
> +
> +1. pend_lock

I'm not sure 'pending' is the right name here, but I'll consider that
more when I review the code patches.

> +
> +   This is an array embedded in task_struct, for keeping locks queued so
> +   that real dependencies can be added using them at commit step. Since
> +   it's local data, it can be accessed locklessly in the owner context.
> +   The array is filled at acquire step and consumed at commit step. And
> +   it's managed in circular manner.
> +
> +2. cross_lock
> +
> +   This is a global linked list, for keeping all crosslocks in progress.
> +   The list grows at acquire step and is shrunk at release step.

FWIW, this is a perfect example of why I say the document is written
backwards. At this point there is no demonstrated need or use for this
list.

> +
> +CONCLUSION
> +
> +Crossrelease feature introduces two main data structures.
> +
> +1. A pend_lock array for queueing typical locks in circular manner.
> +2. A cross_lock linked list for managing crosslocks in progress.
> +
> +
> +How crossrelease works
> +----------------------
> +
> +Let's take a look at how crossrelease feature works step by step,
> +starting from how lockdep works without crossrelease feaure.
> +

> +
> +Let's look at how commit works for crosslocks.
> +
> +   AX's RELEASE CONTEXT		   AX's ACQUIRE CONTEXT
> +   --------------------		   --------------------
> +				   acquire AX
> +				   /*
> +				    * 1. Mark AX as started
> +				    *
> +				    * (No queuing for crosslocks)
> +				    *
> +				    * In pend_lock: Empty
> +				    * In graph: Empty
> +				    */
> +
> +   (serialized by some means e.g. barrier)
> +
> +   acquire D
> +   /*
> +    * (No marking for typical locks)
> +    *
> +    * 1. Queue D
> +    *
> +    * In pend_lock: D
> +    * In graph: Empty
> +    */
> +				   acquire B
> +				   /*
> +				    * (No marking for typical locks)
> +				    *
> +				    * 1. Queue B
> +				    *
> +				    * In pend_lock: B
> +				    * In graph: Empty
> +				    */
> +   release D
> +   /*
> +    * (No commit for typical locks)
> +    *
> +    * In pend_lock: D
> +    * In graph: Empty
> +    */
> +				   acquire C
> +				   /*
> +				    * (No marking for typical locks)
> +				    *
> +				    * 1. Add 'B -> C' of TT type
> +				    * 2. Queue C
> +				    *
> +				    * In pend_lock: B, C
> +				    * In graph: 'B -> C'
> +				    */
> +   acquire E
> +   /*
> +    * (No marking for typical locks)
> +    *
> +    * 1. Queue E
> +    *
> +    * In pend_lock: D, E
> +    * In graph: 'B -> C'
> +    */
> +				   acquire D
> +				   /*
> +				    * (No marking for typical locks)
> +				    *
> +				    * 1. Add 'C -> D' of TT type
> +				    * 2. Queue D
> +				    *
> +				    * In pend_lock: B, C, D
> +				    * In graph: 'B -> C', 'C -> D'
> +				    */
> +   release E
> +   /*
> +    * (No commit for typical locks)
> +    *
> +    * In pend_lock: D, E
> +    * In graph: 'B -> C', 'C -> D'
> +    */
> +				   release D
> +				   /*
> +				    * (No commit for typical locks)
> +				    *
> +				    * In pend_lock: B, C, D
> +				    * In graph: 'B -> C', 'C -> D'
> +				    */
> +   release AX
> +   /*
> +    * 1. Commit AX (= Add 'AX -> ?')
> +    *   a. What queued since AX was marked: D, E
> +    *   b. Add 'AX -> D' of CT type
> +    *   c. Add 'AX -> E' of CT type

OK, so commit adds multiple dependencies, that makes more sense.
Previously I understood commit to only add a single dependency, which
does not make sense (except in the special case where there is but one).

I dislike how I have to reconstruct this from an example instead of
first having had the rules stated though.

> +    *
> +    * In pend_lock: D, E
> +    * In graph: 'B -> C', 'C -> D',
> +    *           'AX -> D', 'AX -> E'
> +    */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
