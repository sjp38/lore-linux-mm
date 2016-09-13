Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 431006B0038
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 15:38:51 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q188so284650514oia.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 12:38:51 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id s65si209813iod.149.2016.09.13.12.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 12:38:37 -0700 (PDT)
Date: Tue, 13 Sep 2016 21:38:29 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160913193829.GA5016@twins.programming.kicks-ass.net>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop>
 <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <max.byungchul.park@gmail.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Sep 14, 2016 at 02:12:51AM +0900, Byungchul Park wrote:
> On Wed, Sep 14, 2016 at 12:05 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> >
> > So the idea is to add support for non-owner serialization primitives,
> > like completions/semaphores, and so far I've not looked at the code yet.
> > I did spend 2+ hours trying to decipher your documentation thing, but am
> > still confused, that thing is exceedingly hard to parse/read.
> >
> > So the typical scenario would be something like:
> >
> > L a     L a
> >         U a
> > W b     C b
> >
> > where L := lock, U := unlock, W := wait_for_completion and C :=
> > complete.
> >
> > On the left, the blocking thread we can easily observe the 'b depends on
> > a' relation, since we block while holding a.
> 
> I think 'a depends on b' relation.
> 
> Why does b depend on a? b depends on a's what?

b blocks while holding a. In any case, for the graph it doesn't matter,
its not a directed graph as such, all we care about is acyclic.

> > On the right however that same relation is hard to see, since by the
> 
> Yes, there's no dependency on the right side of your example.

Well, there is, its just not trivially observable. We must be able to
acquire a in order to complete b, therefore there is a dependency.

> > time we would run complete, a has already been released.
> 
> I will change your example a little bit.
> 
> W b
> ~~~~~~~ <- serialized
>         L a
>         U a
>         C b
> 
> (Remind crossrelease considers dependencies in only case that
> lock sequence serialized is observable.)

What does that mean? Any why? This is a random point in time without
actual meaning.

> There's a dependency in this case, like 'b depends on a' relation.
> 'C b' may not be hit, depending on the result of 'L a', that is,
> acquired or not.

With or without a random reference point, the dependency is there.

> > I _think_ you propose to keep track of all prior held locks and then use
> > the union of the held list on the block-chain with the prior held list
> > from the complete context.
> 
> Almost right. Only thing we need to do to consider the union is to
> connect two chains of two contexts by adding one dependency 'b -> a'.

Sure, but how do you arrive at which connection to make. The document is
entirely silent on this crucial point.

The union between the held-locks of the blocked and prev-held-locks of
the release should give a fair indication I think, but then, I've not
thought too hard on this yet.

> > The document describes you have a prior held list, and that its a
> > circular thing, but it then completely fails to specify what gets added
> > and how its used.
> 
> Why does it fail? It keeps them in the form of hlock. This data is enough
> to generate dependencies.

It fails to explain. It just barely mentions you keep them, it doesn't
mention how they're used or why.

> > Also, by it being a circular list (of indeterminate, but finite size),
> > there is the possibility of missing dependencies if they got spooled out
> > by recent activity.
> 
> Yes, right. They might be missed. It means just missing some chances to
> check a deadlock. It's all. Better than do nothing.

Sure, but you didn't specify. Again, the document is very ambiguous and
ill specified.

> > The document has an example in the section 'How cross release works'
> > (the 3rd) that simply cannot be. It lists lock action _after_ acquire,
> 
> Could you tell me more? Why cannot it be?

Once you block you cannot take more locks, that simply doesnt make
sense.

> > but you place the acquire in wait_for_completion. We _block_ there.
> >
> > Is this the general idea?
> >
> > If so, I cannot see how something like:
> >
> > W a     W b
> > C b     C a
> 
> I didn't tell it works in this case. But it can be a future work. I'm not
> sure but I don't think making it work is impossible at all. But anyway
> current implementation cannot deal with this case.

+4. 'crosslock a -> crosslock b' dependency
+
+   Creating this kind of dependency directly is unnecessary since it can
+   be covered by other kinds of dependencies.

Says something different, doesn't it?

> > On the whole 'release context' thing you want to cast lockdep in, please
> > consider something like:
> >
> > L a     L b
> > L b     L a
> > U a     U a
> > U b     U b
> >
> > Note that the release order of locks is immaterial and can generate
> > 'wrong' dependencies. Note how on both sides a is released under b,
> 
> Who said the release order is important? Wrong for what?

Well, again, you mention 'release context' without actually specifying
what you mean with that.

L a
L b
U b

and

L a
L b
U a

Here the unlocks obviously have different context. Without further
specification its simply impossible to tell what you mean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
