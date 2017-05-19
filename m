Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32BE0831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 06:30:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k91so41374210ioi.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 03:30:36 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id b94si22339128itd.99.2017.05.19.03.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 03:30:35 -0700 (PDT)
Date: Fri, 19 May 2017 12:30:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170519103025.zb5impbsek77ahwa@hirez.programming.kicks-ass.net>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170519080708.GG28017@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170519080708.GG28017@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Fri, May 19, 2017 at 05:07:08PM +0900, Byungchul Park wrote:
> On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> > Lockdep is a runtime locking correctness validator that detects and
> > reports a deadlock or its possibility by checking dependencies between
> > locks. It's useful since it does not report just an actual deadlock but
> > also the possibility of a deadlock that has not actually happened yet.
> > That enables problems to be fixed before they affect real systems.
> > 
> > However, this facility is only applicable to typical locks, such as
> > spinlocks and mutexes, which are normally released within the context in
> > which they were acquired. However, synchronization primitives like page
> > locks or completions, which are allowed to be released in any context,
> > also create dependencies and can cause a deadlock. So lockdep should
> > track these locks to do a better job. The 'crossrelease' implementation
> > makes these primitives also be tracked.
> 
> Excuse me but I have a question...
> 
> Only for maskable irq, can I assume that hardirq are prevented within
> hardirq context? I remember that nested interrupts were allowed in the
> past but not recommanded. But what about now? I'm curious about the
> overall direction of kernel and current status. It would be very
> appriciated if you answer it.

So you're right. In general enabling IRQs from hardirq context is
discouraged but allowed. However, if you were to do that with a lock
held that would instantly make lockdep report a deadlock, as the lock is
then both used from IRQ context and has IRQs enabled.

So from a locking perspective you can assume no nesting, but from a
state tracking pov we have to deal with the nesting I think (although it
is very rare).

You're asking this in relation to the rollback thing, right? I think we
should only save the state when hardirq_context goes from 0->1 and
restore on 1->0.

If you're asking this for another reason, please clarify.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
