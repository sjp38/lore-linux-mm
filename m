Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A50506B025E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 21:40:38 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m186so97773845ioa.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 18:40:38 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 193si36322076iti.82.2016.09.20.18.40.35
        for <linux-mm@kvack.org>;
        Tue, 20 Sep 2016 18:40:37 -0700 (PDT)
Date: Wed, 21 Sep 2016 10:37:30 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160921013730.GN2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop>
 <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
 <20160913193829.GA5016@twins.programming.kicks-ass.net>
 <CANrsvROL43uYXsU7-kmFbHFgiKARBXYHNeqL71V9GxGzBYEdNA@mail.gmail.com>
 <20160914081117.GK5008@twins.programming.kicks-ass.net>
 <20160919024102.GF2279@X58A-UD3R>
 <20160919085009.GT5016@twins.programming.kicks-ass.net>
 <20160920055038.GL2279@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160920055038.GL2279@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Sep 20, 2016 at 02:50:38PM +0900, Byungchul Park wrote:
> On Mon, Sep 19, 2016 at 10:50:09AM +0200, Peter Zijlstra wrote:
> > On Mon, Sep 19, 2016 at 11:41:02AM +0900, Byungchul Park wrote:
> > 
> > > > But since these threads are independently scheduled there is no point in
> > > > transferring the point in time thread A does W to thread B. There is no
> > > > relation there.
> > > > 
> > > > B could have already executed the complete or it could not yet have
> > > > started execution at all or anything in between, entirely random.
> > > 
> > > Of course B could have already executed the complete or it could not yet
> > > have started execution at all or anything in between. But it's not entirely
> > > random.
> > > 
> > > It might be a random point since they are independently scheduled, but it's
> > > not entirely random. And it's a random point among valid points which lockdep
> > > needs to consider. For example,
> > > 
> > > 
> > > CONTEXT 1			CONTEXT 2(forked one)
> > > =========			=====================
> > > (a)				acquire F
> > > acquire A			acquire G
> > > acquire B			wait_for_completion Z
> > > acquire C
> > > (b)				acquire H
> > > fork 2				acquire I
> > > acquire D			acquire J
> > > complete Z			acquire K
> > > 
> > 
> > I'm hoping you left out the releases for brevity? Because calling fork()
> > with locks held is _really_ poor form.
> 
> Exactly. Sorry. I shouldn't have omitted releases.
> 
> > 
> > > I can provide countless examples with which I can say you're wrong.
> > > In this case, all acquires between (a) and (b) must be ignored when
> > > generating dependencies with complete operation of Z.
> > 
> > I still don't get the point. Why does this matter?
> > 
> > Sure, A-C are irrelevant in this example, but I don't see how they're
> > differently irrelevant from a whole bunch of other prior state action.
> > 
> > 
> > Earlier you said the algorithm for selecting the dependency is the first
> > acquire observed in the completing thread after the
> > wait_for_completion(). Is this correct?
> 
> Sorry for insufficient description.
> 
> held_locks of left context will be,
> 
> time 1: a
> time 2: a, x[0]
> time 3: a, x[1]
> ...
> time n: b
> 
> Between time 1 and time (n-1), 'a' will be the first among held_locks. At
> time n, 'b' will be the fist among held_locks. So 'a' and 'b' should be
> connected to 'z' if we ignore IRQ context. (I will explain it soon.)
> 
> Acquire x[i] is also valid one but crossrelease doesn't take it into
> account since original lockdep will cover using 'a -> x[i]'. So only

... since lockdep will cover 'z -> x[i]' using 'z -> a' and 'a -> x[i]' ...

> connections we need are 'z -> a' and 'z -> b'.
> 
> > 
> > 
> > 				W z
> > 
> > 	A a
> > 	for (i<0;i<many;i++) {
> > 	  A x[i]
> > 	  R x[i]
> > 	}
> > 	R a
> > 
> > 	<IRQ>
> > 	  A b
> > 	  R b
> > 	  C z
> > 	</IRQ>
> 
> My crossrelease implementation distinguishes each IRQ from normal context
> or other IRQs in different timeline, even though they might share
> held_locks. So in this example, precisely speaking, there are two different
> contexts. One is normal context and the other is IRQ context. So only 'A b'
> is related with 'W z' in this example.
> 
> > 
> > That would be 'a' in this case, but that isn't at all related. Its just
> > as irrelevant as your A-C. And we can pick @many as big as needed to
> > flush the prev held cyclic buffer (although I've no idea how that
> > matters either).
> 
> I designed crossrelease so that x[i] is not added into ring buffer because
> adding 'z -> a' is sufficient and x[i] doesn't need to be taken into
> account in this case.
> 
> > 
> > What we want here is to link z to b, no? That is the last, not the first
> 
> Exactly right. Only 'z -> b' must be added under considering IRQ context.
> That is the first among held_locks in the IRQ context.
> 
> > acquire, it also is independent of when W happened.
> 
> If the IRQ is really random, then it can happen before W z and it can also
> happen after W z. We cannot determine the time. Then we need to consider all
> combination and possibility. It's a key point. We have to consider
> dependencies for all possibility.

                       possibilities.

> 
> However, we don't know what synchronizes the flow. So it must be based on
                   ^^^
                 generally

> what actually happened, to identify true dependencies.
> 
> > 
> > At the same time, picking the last is no guarantee either, since that
> > can equally miss dependencies. Suppose the IRQ handler did:
> > 
> > 	<IRQ>
> > 	  A c
> > 	  R c
> > 	  A b
> > 	  R b
> > 	  C z
> > 	</IRQ>
> > 
> 
> time 1: c (in held_locks)
> time 2: b (in held_locks)
> 
> So 'c' and 'b' can be the first among held_locks at each moment.
                 ^^^^^^
                   are

> So 'z -> b' and 'z -> c' will be added.
> 
> > instead. We'd miss the z depends on c relation, and since they're
> > independent lock sections, lockdep wouldn't make a b-c relation either.
> > 
> > 
> > Clearly I'm still missing stuff...
> 
> Sorry for insufficient description. I tried to describ crossrelease in as
> much detail as possible, really.
> 
> The reason why I consider only the first among valid locks in held_locks is
> simple. For example,
> 
> Context 1
> A a -> A b -> A crosslock -> R a -> R b

I meant,

Context 1
=========
A a
A b
A crosslock
R a
R b

> 
> Context 2
> A c -> A d -> R d -> R the crosslock -> R c

Context 2
=========
A c
A d
R d
R the crosslock
R c

> 
> If 'A c' after 'A crosslock' is possible, then 'A crosslock' does not only
> depends on 'A c' but also 'A d'. But all dependencies we need to add is only
> 'crosslock -> c' because 'crosslock -> d' will be covered by 'crosslock ->
> c' and 'a -> b'. Here, 'a -> b' is added by original lockdep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
