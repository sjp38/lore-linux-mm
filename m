Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE9D96B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:21:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j8-v6so885705wrh.18
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 02:21:02 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 13-v6si3771360wmp.229.2018.06.27.02.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 02:21:01 -0700 (PDT)
Date: Wed, 27 Jun 2018 11:20:59 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 2/3] mm: workingset: make shadow_lru_isolate() use
 locking suffix
Message-ID: <20180627092059.temrhpvyc7ggcmxd@linutronix.de>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-3-bigeasy@linutronix.de>
 <20180624195753.2e277k5xhujypwre@esperanza>
 <20180626212534.sp4p76gcvldcai57@linutronix.de>
 <20180627085003.rz3dzzggjxps34wb@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180627085003.rz3dzzggjxps34wb@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On 2018-06-27 11:50:03 [+0300], Vladimir Davydov wrote:
> > it is not asymmetric because a later patch makes it use
> > spin_lock_irq(), too. If you use local_irq_disable() and a spin_lock()
> > (like you suggest in 3/3 as well) then you separate the locking
> > instruction. It works as expected on vanilla but break other locking
> > implementations like those on RT.
> 
> As I said earlier, I don't like patch 3 either, because I find the
> notion of list_lru::lock_irq flag abstruse since it doesn't make all
> code paths taking the lock disable irq: list_lru_add/del use spin_lock
> no matter whether the flag is set or not. That is, when you initialize a
> list_lru and pass lock_irq=true, you'll have to keep in mind that it
> only protects list_lru_walk, while list_lru_add/del must be called with
> irq disabled by the caller. Disabling irq before list_lru_walk
> explicitly looks much more straightforward IMO.

It helps to keep the locking annotation in one place. If it helps I
could add the _irqsave() suffix to list_lru_add/del like it is already
done in other places (in this file).

> As for RT, it wouldn't need mm/workingset altogether AFAIU. 
Why wouldn't it need it?

> Anyway, it's
> rather unusual to care about out-of-the-tree patches when changing the
> vanilla kernel code IMO. 
The plan is not stay out-of-tree forever. And I don't intend to make
impossible or hard to argue changes just for RT's sake. This is only to
keep the correct locking context/primitives in one place and not
scattered around.
The only reason for the separation is that most users don't disable
interrupts (one user does) and there a few places which already use
irqsave() because they can be called from both places. This
list_lru_walk() is the only which can't do so due to the callback it
invokes. I could also add a different function (say
list_lru_walk_one_irq()) which behaves like list_lru_walk_one() but does
spin_lock_irq() instead.

> Using local_irq_disable + spin_lock instead of
> spin_lock_irq is a typical pattern, and I don't see how changing this
> particular place would help RT.
It is not that typical. It is how the locking primitives work, yes, but
they are not so many places that do so and those that did got cleaned
up.

> > Also if the locking changes then the local_irq_disable() part will be
> > forgotten like you saw in 1/3 of this series.
> 
> If the locking changes, we'll have to revise all list_lru users anyway.
> Yeah, we missed it last time, but it didn't break anything, and it was
> finally found and fixed (by you, thanks BTW).
You are very welcome. But having the locking primitives in one place you
would have less things to worry about.

Sebastian
