Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABD66B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 05:31:03 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l72-v6so1339737lfl.20
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:31:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13-v6sor726371lfi.94.2018.06.28.02.31.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 02:31:01 -0700 (PDT)
Date: Thu, 28 Jun 2018 12:30:57 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 2/3] mm: workingset: make shadow_lru_isolate() use
 locking suffix
Message-ID: <20180628093057.4u7ncd42s2wu4oin@esperanza>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-3-bigeasy@linutronix.de>
 <20180624195753.2e277k5xhujypwre@esperanza>
 <20180626212534.sp4p76gcvldcai57@linutronix.de>
 <20180627085003.rz3dzzggjxps34wb@esperanza>
 <20180627092059.temrhpvyc7ggcmxd@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627092059.temrhpvyc7ggcmxd@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jun 27, 2018 at 11:20:59AM +0200, Sebastian Andrzej Siewior wrote:
> On 2018-06-27 11:50:03 [+0300], Vladimir Davydov wrote:
> > > it is not asymmetric because a later patch makes it use
> > > spin_lock_irq(), too. If you use local_irq_disable() and a spin_lock()
> > > (like you suggest in 3/3 as well) then you separate the locking
> > > instruction. It works as expected on vanilla but break other locking
> > > implementations like those on RT.
> > 
> > As I said earlier, I don't like patch 3 either, because I find the
> > notion of list_lru::lock_irq flag abstruse since it doesn't make all
> > code paths taking the lock disable irq: list_lru_add/del use spin_lock
> > no matter whether the flag is set or not. That is, when you initialize a
> > list_lru and pass lock_irq=true, you'll have to keep in mind that it
> > only protects list_lru_walk, while list_lru_add/del must be called with
> > irq disabled by the caller. Disabling irq before list_lru_walk
> > explicitly looks much more straightforward IMO.
> 
> It helps to keep the locking annotation in one place. If it helps I
> could add the _irqsave() suffix to list_lru_add/del like it is already
> done in other places (in this file).

AFAIK local_irqsave/restore don't come for free so using them just to
keep the code clean doesn't seem to be reasonable.

> 
> > As for RT, it wouldn't need mm/workingset altogether AFAIU. 
> Why wouldn't it need it?

I may be wrong, but AFAIU RT kernel doesn't do swapping.

> 
> > Anyway, it's
> > rather unusual to care about out-of-the-tree patches when changing the
> > vanilla kernel code IMO. 
> The plan is not stay out-of-tree forever. And I don't intend to make
> impossible or hard to argue changes just for RT's sake. This is only to
> keep the correct locking context/primitives in one place and not
> scattered around.
> The only reason for the separation is that most users don't disable
> interrupts (one user does) and there a few places which already use
> irqsave() because they can be called from both places. This
> list_lru_walk() is the only which can't do so due to the callback it
> invokes. I could also add a different function (say
> list_lru_walk_one_irq()) which behaves like list_lru_walk_one() but does
> spin_lock_irq() instead.

That would look better IMHO. I mean, passing the flag as an argument to
__list_lru_walk_one and introducing list_lru_shrink_walk_irq.

> 
> > Using local_irq_disable + spin_lock instead of
> > spin_lock_irq is a typical pattern, and I don't see how changing this
> > particular place would help RT.
> It is not that typical. It is how the locking primitives work, yes, but
> they are not so many places that do so and those that did got cleaned
> up.

Missed that. There used to be a lot of places like that in the past.
I guess things have changed.

> 
> > > Also if the locking changes then the local_irq_disable() part will be
> > > forgotten like you saw in 1/3 of this series.
> > 
> > If the locking changes, we'll have to revise all list_lru users anyway.
> > Yeah, we missed it last time, but it didn't break anything, and it was
> > finally found and fixed (by you, thanks BTW).
> You are very welcome. But having the locking primitives in one place you
> would have less things to worry about.
