Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBD366B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 04:11:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so14492068pfv.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 01:11:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id p63si32292512pfp.244.2016.09.14.01.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 01:11:21 -0700 (PDT)
Date: Wed, 14 Sep 2016 10:11:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160914081117.GK5008@twins.programming.kicks-ass.net>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop>
 <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
 <20160913193829.GA5016@twins.programming.kicks-ass.net>
 <CANrsvROL43uYXsU7-kmFbHFgiKARBXYHNeqL71V9GxGzBYEdNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANrsvROL43uYXsU7-kmFbHFgiKARBXYHNeqL71V9GxGzBYEdNA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <max.byungchul.park@gmail.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Sep 14, 2016 at 11:27:22AM +0900, Byungchul Park wrote:
> > Well, there is, its just not trivially observable. We must be able to
> > acquire a in order to complete b, therefore there is a dependency.
> 
> No. We cannot say there is a dependency unconditionally. There can
> be a dependency or not.
> 
> L a     L a
>         U a
> ~~~~~~~~~ what if serialized by something?

Well, there's no serialization in the example, so no what if.

> W b     C b
> 
> If something we don't recognize serializes locks, which ensures
> 'W b' happens after 'L a , U a' in the other context, then there's
> no dependency here.

Its not there.

> We should say 'b depends on a' in only case that the sequence
> 'W b and then L a and then C b, where last two ops are in same
> context' _actually_ happened at least once. Otherwise, it might
> add a false dependency.
> 
> It's same as how original lockdep works with typical locks. It adds
> a dependency only when a lock is actually hit.

But since these threads are independently scheduled there is no point in
transferring the point in time thread A does W to thread B. There is no
relation there.

B could have already executed the complete or it could not yet have
started execution at all or anything in between, entirely random.

> > What does that mean? Any why? This is a random point in time without
> > actual meaning.
> 
> It's not random point. We have to consider meaningful sequences among
> those which are globally observable. That's why we need to serialize
> those locks.

Serialize how? there is no serialization.

> For example,
> 
> W b
> L a
> U a
> C b
> 
> Once this sequence is observable globally, we can say 'It's possible to
> run in this sequence. Is this sequence problematic or not?'.
> 
> L a
> U a
> W b
> C b
> 
> If only this sequence can be observable, we should not assume
> this sequence can be changed. However once the former sequence
> happens, it has a possibility to hit the same sequence again later.
> So we can check deadlock possibility with the sequence,
> 
> _not randomly_.

I still don't get it.

> We need to connect between the crosslock and the first lock among
> locks having been acquired since the crosslock was held.

Which can be _any_ lock in the history of that thread. It could be
rq->lock from getting the thread scheduled.

> Others will be
> connected each other by original lockdep.
> 
> By the way, does my document miss this description? If so, sorry.
> I will check and update it.

I couldn't find anything useful, but then I could not understand most of
what was written, and I tried hard :-(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
