Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id F14716B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 04:50:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8-v6so397109lfb.6
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 01:50:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l28-v6sor251774ljb.75.2018.06.27.01.50.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 01:50:06 -0700 (PDT)
Date: Wed, 27 Jun 2018 11:50:03 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 2/3] mm: workingset: make shadow_lru_isolate() use
 locking suffix
Message-ID: <20180627085003.rz3dzzggjxps34wb@esperanza>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-3-bigeasy@linutronix.de>
 <20180624195753.2e277k5xhujypwre@esperanza>
 <20180626212534.sp4p76gcvldcai57@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626212534.sp4p76gcvldcai57@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 26, 2018 at 11:25:34PM +0200, Sebastian Andrzej Siewior wrote:
> On 2018-06-24 22:57:53 [+0300], Vladimir Davydov wrote:
> > On Fri, Jun 22, 2018 at 05:12:20PM +0200, Sebastian Andrzej Siewior wrote:
> > > shadow_lru_isolate() disables interrupts and acquires a lock. It could
> > > use spin_lock_irq() instead. It also uses local_irq_enable() while it
> > > could use spin_unlock_irq()/xa_unlock_irq().
> > > 
> > > Use proper suffix for lock/unlock in order to enable/disable interrupts
> > > during release/acquire of a lock.
> > > 
> > > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> > 
> > I don't like when a spin lock is locked with local_irq_disabled +
> > spin_lock and unlocked with spin_unlock_irq - it looks asymmetric.
> > IMHO the code is pretty easy to follow as it is - local_irq_disable in
> > scan_shadow_nodes matches local_irq_enable in shadow_lru_isolate.
> 
> it is not asymmetric because a later patch makes it use
> spin_lock_irq(), too. If you use local_irq_disable() and a spin_lock()
> (like you suggest in 3/3 as well) then you separate the locking
> instruction. It works as expected on vanilla but break other locking
> implementations like those on RT.

As I said earlier, I don't like patch 3 either, because I find the
notion of list_lru::lock_irq flag abstruse since it doesn't make all
code paths taking the lock disable irq: list_lru_add/del use spin_lock
no matter whether the flag is set or not. That is, when you initialize a
list_lru and pass lock_irq=true, you'll have to keep in mind that it
only protects list_lru_walk, while list_lru_add/del must be called with
irq disabled by the caller. Disabling irq before list_lru_walk
explicitly looks much more straightforward IMO.

As for RT, it wouldn't need mm/workingset altogether AFAIU. Anyway, it's
rather unusual to care about out-of-the-tree patches when changing the
vanilla kernel code IMO. Using local_irq_disable + spin_lock instead of
spin_lock_irq is a typical pattern, and I don't see how changing this
particular place would help RT.

> Also if the locking changes then the local_irq_disable() part will be
> forgotten like you saw in 1/3 of this series.

If the locking changes, we'll have to revise all list_lru users anyway.
Yeah, we missed it last time, but it didn't break anything, and it was
finally found and fixed (by you, thanks BTW).
