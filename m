Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id E645B6B5990
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:20:05 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id t62-v6so5405599wmg.6
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 10:20:05 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w6si4175573wrs.346.2018.11.30.10.20.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 10:20:04 -0800 (PST)
Date: Fri, 30 Nov 2018 19:19:57 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181130181956.eewrlaabtceekzyu@linutronix.de>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: He Zhe <zhe.he@windriver.com>
Cc: catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org

On 2018-11-24 22:26:46 [+0800], He Zhe wrote:
> On latest v4.19.1-rt3, both of the call traces can be reproduced with kmemleak
> enabied. And none can be reproduced with kmemleak disabled.
okay. So it needs attention.

> On latest mainline tree, none can be reproduced no matter kmemleak is enabled
> or disabled.
> 
> I don't get why kfree from a preempt-disabled section should cause a warning
> without kmemleak, since kfree can't sleep.

it might. It will acquire a sleeping lock if it has go down to the
memory allocator to actually give memory back.

> If I understand correctly, the call trace above is caused by trying to schedule
> after preemption is disabled, which cannot be reached in mainline kernel. So
> we might need to turn to use raw lock to keep preemption disabled.

The buddy-allocator runs with spin locks so it is okay on !RT. So you
can use kfree() with disabled preemption or disabled interrupts.
I don't think that we want to use raw-locks in the buddy-allocator.

> >From what I reached above, this is RT-only and happens on v4.18 and v4.19.
> 
> The call trace above is caused by grabbing kmemleak_lock and then getting
> scheduled and then re-grabbing kmemleak_lock. Using raw lock can also solve
> this problem.

But this is a reader / writer lock. And if I understand the other part
of the thread then it needs multiple readers.
Couldn't we just get rid of that kfree() or move it somewhere else?
I mean if the free() memory on CPU-down and allocate it again CPU-up
then we could skip that, rigth? Just allocate it and don't free it
because the CPU will likely get up again.

> Thanks,
> Zhe

Sebastian
