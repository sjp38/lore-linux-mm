Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B404C6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 04:50:16 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t83so80571628oie.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 01:50:16 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 130si24569936its.84.2016.09.19.01.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 01:50:16 -0700 (PDT)
Date: Mon, 19 Sep 2016 10:50:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160919085009.GT5016@twins.programming.kicks-ass.net>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop>
 <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
 <20160913193829.GA5016@twins.programming.kicks-ass.net>
 <CANrsvROL43uYXsU7-kmFbHFgiKARBXYHNeqL71V9GxGzBYEdNA@mail.gmail.com>
 <20160914081117.GK5008@twins.programming.kicks-ass.net>
 <20160919024102.GF2279@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919024102.GF2279@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Mon, Sep 19, 2016 at 11:41:02AM +0900, Byungchul Park wrote:

> > But since these threads are independently scheduled there is no point in
> > transferring the point in time thread A does W to thread B. There is no
> > relation there.
> > 
> > B could have already executed the complete or it could not yet have
> > started execution at all or anything in between, entirely random.
> 
> Of course B could have already executed the complete or it could not yet
> have started execution at all or anything in between. But it's not entirely
> random.
> 
> It might be a random point since they are independently scheduled, but it's
> not entirely random. And it's a random point among valid points which lockdep
> needs to consider. For example,
> 
> 
> CONTEXT 1			CONTEXT 2(forked one)
> =========			=====================
> (a)				acquire F
> acquire A			acquire G
> acquire B			wait_for_completion Z
> acquire C
> (b)				acquire H
> fork 2				acquire I
> acquire D			acquire J
> complete Z			acquire K
> 

I'm hoping you left out the releases for brevity? Because calling fork()
with locks held is _really_ poor form.

> I can provide countless examples with which I can say you're wrong.
> In this case, all acquires between (a) and (b) must be ignored when
> generating dependencies with complete operation of Z.

I still don't get the point. Why does this matter?

Sure, A-C are irrelevant in this example, but I don't see how they're
differently irrelevant from a whole bunch of other prior state action.


Earlier you said the algorithm for selecting the dependency is the first
acquire observed in the completing thread after the
wait_for_completion(). Is this correct?


				W z

	A a
	for (i<0;i<many;i++) {
	  A x[i]
	  R x[i]
	}
	R a

	<IRQ>
	  A b
	  R b
	  C z
	</IRQ>

That would be 'a' in this case, but that isn't at all related. Its just
as irrelevant as your A-C. And we can pick @many as big as needed to
flush the prev held cyclic buffer (although I've no idea how that
matters either).

What we want here is to link z to b, no? That is the last, not the first
acquire, it also is independent of when W happened.

At the same time, picking the last is no guarantee either, since that
can equally miss dependencies. Suppose the IRQ handler did:

	<IRQ>
	  A c
	  R c
	  A b
	  R b
	  C z
	</IRQ>

instead. We'd miss the z depends on c relation, and since they're
independent lock sections, lockdep wouldn't make a b-c relation either.


Clearly I'm still missing stuff...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
