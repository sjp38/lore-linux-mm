Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19B9B6B0253
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 22:44:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so183054129pfj.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 19:44:10 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id ex11si14254713pad.209.2016.09.18.19.44.08
        for <linux-mm@kvack.org>;
        Sun, 18 Sep 2016 19:44:09 -0700 (PDT)
Date: Mon, 19 Sep 2016 11:41:02 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160919024102.GF2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop>
 <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
 <20160913193829.GA5016@twins.programming.kicks-ass.net>
 <CANrsvROL43uYXsU7-kmFbHFgiKARBXYHNeqL71V9GxGzBYEdNA@mail.gmail.com>
 <20160914081117.GK5008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914081117.GK5008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Sep 14, 2016 at 10:11:17AM +0200, Peter Zijlstra wrote:
> On Wed, Sep 14, 2016 at 11:27:22AM +0900, Byungchul Park wrote:
> > > Well, there is, its just not trivially observable. We must be able to
> > > acquire a in order to complete b, therefore there is a dependency.
> > 
> > No. We cannot say there is a dependency unconditionally. There can
> > be a dependency or not.
> > 
> > L a     L a
> >         U a
> > ~~~~~~~~~ what if serialized by something?
> 
> Well, there's no serialization in the example, so no what if.

It was a korean traditional holliday for a week so I'm late.

I mean we cannot _ensure_ there's no serialization while lockdep works.
In _the_ case you suggested, you'are right if only those code exists.
But it's meaningless.

> > W b     C b
> > 
> > If something we don't recognize serializes locks, which ensures
> > 'W b' happens after 'L a , U a' in the other context, then there's
> > no dependency here.
> 
> Its not there.
> 
> > We should say 'b depends on a' in only case that the sequence
> > 'W b and then L a and then C b, where last two ops are in same
> > context' _actually_ happened at least once. Otherwise, it might
> > add a false dependency.
> > 
> > It's same as how original lockdep works with typical locks. It adds
> > a dependency only when a lock is actually hit.
> 
> But since these threads are independently scheduled there is no point in
> transferring the point in time thread A does W to thread B. There is no
> relation there.
> 
> B could have already executed the complete or it could not yet have
> started execution at all or anything in between, entirely random.

Of course B could have already executed the complete or it could not yet
have started execution at all or anything in between. But it's not entirely
random.

It might be a random point since they are independently scheduled, but it's
not entirely random. And it's a random point among valid points which lockdep
needs to consider. For example,


CONTEXT 1			CONTEXT 2(forked one)
=========			=====================
(a)				acquire F
acquire A			acquire G
acquire B			wait_for_completion Z
acquire C
(b)				acquire H
fork 2				acquire I
acquire D			acquire J
complete Z			acquire K


I can provide countless examples with which I can say you're wrong.
In this case, all acquires between (a) and (b) must be ignored when
generating dependencies with complete operation of Z. It's never random.

Ideally, it would be of course the best to consider all points (not random
points) after (b) which are valid points which lockdep needs to work with.
But I think it's impossible to parse and identify all synchronizations and
forks in kernel code, furthermore, new synchronization interface can be
introduced in future.

So IMHO it would be the second best to consider random points among valid
points, which anyway actually happened so it's guarrented that it has a
depenency with Z.

It's similar to how lockdep works for typical lock e.g. spin lock. Current
lockdep builds dependecy graph based on call paths which actually happened
in each context, which might be different from each run. Even current
lockdep doesn't parse all code and identify dependencies but works based on
actual call paths in runtime which can be random but will eventually cover
it almost (not perfect).

> > > What does that mean? Any why? This is a random point in time without
> > > actual meaning.
> > 
> > It's not random point. We have to consider meaningful sequences among
> > those which are globally observable. That's why we need to serialize
> > those locks.
> 
> Serialize how? there is no serialization.

I mean I did it in my crossrelease implementation.

> 
> > For example,
> > 
> > W b
> > L a
> > U a
> > C b
> > 
> > Once this sequence is observable globally, we can say 'It's possible to
> > run in this sequence. Is this sequence problematic or not?'.
> > 
> > L a
> > U a
> > W b
> > C b
> > 
> > If only this sequence can be observable, we should not assume
> > this sequence can be changed. However once the former sequence
> > happens, it has a possibility to hit the same sequence again later.
> > So we can check deadlock possibility with the sequence,
> > 
> > _not randomly_.
> 
> I still don't get it.
> 
> > We need to connect between the crosslock and the first lock among
> > locks having been acquired since the crosslock was held.
> 
> Which can be _any_ lock in the history of that thread. It could be
> rq->lock from getting the thread scheduled.

I think I already answered it. Right?

> 
> > Others will be
> > connected each other by original lockdep.
> > 
> > By the way, does my document miss this description? If so, sorry.
> > I will check and update it.
> 
> I couldn't find anything useful, but then I could not understand most of
> what was written, and I tried hard :-(

Thank you for trying it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
