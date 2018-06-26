Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2466B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 17:25:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t83-v6so1429328wmt.3
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 14:25:37 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z12-v6si2629655wrt.209.2018.06.26.14.25.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 14:25:36 -0700 (PDT)
Date: Tue, 26 Jun 2018 23:25:34 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 2/3] mm: workingset: make shadow_lru_isolate() use
 locking suffix
Message-ID: <20180626212534.sp4p76gcvldcai57@linutronix.de>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-3-bigeasy@linutronix.de>
 <20180624195753.2e277k5xhujypwre@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180624195753.2e277k5xhujypwre@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On 2018-06-24 22:57:53 [+0300], Vladimir Davydov wrote:
> On Fri, Jun 22, 2018 at 05:12:20PM +0200, Sebastian Andrzej Siewior wrote:
> > shadow_lru_isolate() disables interrupts and acquires a lock. It could
> > use spin_lock_irq() instead. It also uses local_irq_enable() while it
> > could use spin_unlock_irq()/xa_unlock_irq().
> > 
> > Use proper suffix for lock/unlock in order to enable/disable interrupts
> > during release/acquire of a lock.
> > 
> > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> I don't like when a spin lock is locked with local_irq_disabled +
> spin_lock and unlocked with spin_unlock_irq - it looks asymmetric.
> IMHO the code is pretty easy to follow as it is - local_irq_disable in
> scan_shadow_nodes matches local_irq_enable in shadow_lru_isolate.

it is not asymmetric because a later patch makes it use spin_lock_irq(),
too. If you use local_irq_disable() and a spin_lock() (like you suggest
in 3/3 as well) then you separate the locking instruction. It works as
expected on vanilla but break other locking implementations like those
on RT. Also if the locking changes then the local_irq_disable() part
will be forgotten like you saw in 1/3 of this series.

Sebastian
