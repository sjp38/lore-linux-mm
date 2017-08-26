Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5743C6810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 22:54:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d66so1885746oib.2
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 19:54:29 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id p186si6491036oih.151.2017.08.25.19.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 19:54:28 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id k77so12294125oib.2
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 19:54:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com> <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com> <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Aug 2017 19:54:27 -0700
Message-ID: <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in wake_up_page_bit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 25, 2017 at 5:31 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> It made it way more fragile and complicated, having to rewrite things
> so carefully. A simple slab cache would likely be a lot cleaner and
> simpler.

It also turns out that despite all the interfaces, we only really ever
wait on two different bits: PG_locked and PG_writeback. Nothing else.

Even the add_page_wait_queue() thing, which looks oh-so-generic,
really only waits on PG_locked.

And the PG_writeback case never really cares for the "locked" case, so
this incredibly generic interface that allows you to wait on any bit
you want, and has the whole exclusive wait support for getting
exclusive access to the bit really only has three cases:

 - wait for locked exclusive (wake up first waiter when unlocked)

 - wait for locked (wake up all waiters when unlocked)

 - wait for writeback (wake up all waiters when no longer under writeback)

and those last two could probably even share the same queue.

But even without sharing the same queue, we could just do a per-page
allocation for the three queues - and probably that stupiud
add_page_wait_queue() waitqueue too. So no "per-page and per-bit"
thing, just a per-page thing.

I'll try writing that up.

Simplify, simplify, simplify.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
