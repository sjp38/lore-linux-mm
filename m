Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06B8F6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 13:12:53 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z190so59079252qkc.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 10:12:53 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id t207si7882550vke.160.2016.09.13.10.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 10:12:52 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id 16so168797387vko.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 10:12:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160913150554.GI2794@worktop>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com> <20160913150554.GI2794@worktop>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Wed, 14 Sep 2016 02:12:51 +0900
Message-ID: <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Sep 14, 2016 at 12:05 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
>
> So the idea is to add support for non-owner serialization primitives,
> like completions/semaphores, and so far I've not looked at the code yet.
> I did spend 2+ hours trying to decipher your documentation thing, but am
> still confused, that thing is exceedingly hard to parse/read.
>
> So the typical scenario would be something like:
>
> L a     L a
>         U a
> W b     C b
>
> where L := lock, U := unlock, W := wait_for_completion and C :=
> complete.
>
> On the left, the blocking thread we can easily observe the 'b depends on
> a' relation, since we block while holding a.

I think 'a depends on b' relation.

Why does b depend on a? b depends on a's what?

> On the right however that same relation is hard to see, since by the

Yes, there's no dependency on the right side of your example.

> time we would run complete, a has already been released.

I will change your example a little bit.

W b
~~~~~~~ <- serialized
        L a
        U a
        C b

(Remind crossrelease considers dependencies in only case that
lock sequence serialized is observable.)

There's a dependency in this case, like 'b depends on a' relation.
'C b' may not be hit, depending on the result of 'L a', that is,
acquired or not.

> I _think_ you propose to keep track of all prior held locks and then use
> the union of the held list on the block-chain with the prior held list
> from the complete context.

Almost right. Only thing we need to do to consider the union is to
connect two chains of two contexts by adding one dependency 'b -> a'.

> The document describes you have a prior held list, and that its a
> circular thing, but it then completely fails to specify what gets added
> and how its used.

Why does it fail? It keeps them in the form of hlock. This data is enough
to generate dependencies.

> Also, by it being a circular list (of indeterminate, but finite size),
> there is the possibility of missing dependencies if they got spooled out
> by recent activity.

Yes, right. They might be missed. It means just missing some chances to
check a deadlock. It's all. Better than do nothing.

Furthermore, It just only needs 10~50 entries on qemu-i386 4core since
it's optimized as far as possible so that it only considers essential ones
instead of all the prior held list. The number of entries might need to be
changed on a large system. It's future work.

> The document has an example in the section 'How cross release works'
> (the 3rd) that simply cannot be. It lists lock action _after_ acquire,

Could you tell me more? Why cannot it be?

> but you place the acquire in wait_for_completion. We _block_ there.
>
> Is this the general idea?
>
> If so, I cannot see how something like:
>
> W a     W b
> C b     C a

I didn't tell it works in this case. But it can be a future work. I'm not
sure but I don't think making it work is impossible at all. But anyway
current implementation cannot deal with this case.

> would work, somewhere in that document it states that this would be
> handled by the existing dependencies, but I cannot see how. The blocking

Nowhere I mentioned it can be handled.

However it will work if we can identify and add 'a -> b' and 'b -> a'
dependencies. It's fairly possible.

> thread (either one) has no held context, therefore the previously
> mentioned union of held and prev-held is empty.

Right, in current implementation.

> The alternative is not doing the union, but then you end up with endless
> pointless dependencies afaict.

That's a matter of whether or not we can identify additional dependencies.
I proposed the way to find certain and additional dependencies which original
lockdep missed. Of course there might be other dependencies which cannot
be identified with current implementation. It must be a future work.

> On the whole 'release context' thing you want to cast lockdep in, please
> consider something like:
>
> L a     L b
> L b     L a
> U a     U a
> U b     U b
>
> Note that the release order of locks is immaterial and can generate
> 'wrong' dependencies. Note how on both sides a is released under b,

Who said the release order is important? Wrong for what?

Using the way crossrelease works, AB-BA deadlock of course can be
detected, even though typical lock like 'a' and 'b' does not need to use
crossrelease feature at all.

On left side,
L a : queue a
L b : queue b
U a : add 'a -> b' (consider only locks having been tried since L a was held.)
U b : nop

On right side,
L b : queue b
L a : queue a
U a : nop
U b : add 'b -> a' (consider only locks having been tried since L b was held.)

AB-BA deadlock can be detected with dependencies 'a -> b' and 'b -> a'.
Fairly true dependencies can be generated with this concept, and never fail
to observe this kind of deadlock.

> failing to observe the stil obvious AB-BA deadlock.
>
> Note that lockdep doesn't model release or anything, it models
> blocked-on relations, like PI does.

As you said, current lockdep _implementation_ doesn't model it.
There are 2 parts roughly in lockdep.

1. detect(identify) dependency
2. check dependencies in graph to detect deadlock

Precisely, The first part doesn't model it. I think it's good for
optimized behavior. But it misses some dependencies.
So that's what I proposed to provide the chance to users
between more perfect detector and optimized behavior.

I think the second part works perfectly at the moment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
