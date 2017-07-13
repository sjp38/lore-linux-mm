Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2475B440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:19:16 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id o190so18458022vka.10
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:19:16 -0700 (PDT)
Received: from mail-vk0-x244.google.com (mail-vk0-x244.google.com. [2607:f8b0:400c:c05::244])
        by mx.google.com with ESMTPS id u200si1860115vkb.167.2017.07.13.04.19.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 04:19:15 -0700 (PDT)
Received: by mail-vk0-x244.google.com with SMTP id c15so3508629vkf.0
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:19:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop> <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R> <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R> <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
 <20170713100953.GI20323@X58A-UD3R> <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Thu, 13 Jul 2017 20:19:14 +0900
Message-ID: <CANrsvRNAeL=Xdrbg5k56o5pC_p05LN7=rSrXLTHBJiXXFXk5Mw@mail.gmail.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring buffer overwrite
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 7:29 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Jul 13, 2017 at 07:09:53PM +0900, Byungchul Park wrote:
>> On Thu, Jul 13, 2017 at 11:50:52AM +0200, Peter Zijlstra wrote:
>> >     wait_for_completion(&C);
>> >       atomic_inc_return();
>> >
>> >                                     mutex_lock(A1);
>> >                                     mutex_unlock(A1);
>> >
>> >
>> >                                     <IRQ>
>> >                                       spin_lock(B1);
>> >                                       spin_unlock(B1);
>> >
>> >                                       ...
>> >
>> >                                       spin_lock(B64);
>> >                                       spin_unlock(B64);
>> >                                     </IRQ>
>> >
>> >
>> >                                     mutex_lock(A2);
>> >                                     mutex_unlock(A2);
>> >
>> >                                     complete(&C);
>> >
>> >
>> > That gives:
>> >
>> >     xhist[ 0] = A1
>>
>> We have to rollback here later on irq_exit.
>>
>> The followings are ones for irq context.
>>
>> >     xhist[ 1] = B1
>> >     ...
>> >     xhist[63] = B63
>> >
>> > then we wrap and have:
>> >
>> >     xhist[0] = B64
>> >
>> > then we rewind to 1 and invalidate to arrive at:
>> >
>>
>> Now, whether xhist[0] has been overwritten or not is important. If yes,
>> xhist[0] should be NULL, _not_ xhist[1], which is one for irq context so
>> not interest at all.
>>
>> >     xhist[ 0] = B64
>> >     xhist[ 1] = NULL   <-- idx
>>
>> Therefore, it should be,
>>
>>       xhist[ 0] = NULL <- invalidate, cannot use it any more
>>       --- <- on returning back from irq context, start from here
>>       xhist[ 1] = B1 <-- obsolete history of irq
>
> Ah, so you rely on the same_context_xhlock() ? That doesn't work for
> hist (formerly work).

As I mentioned in cover-letter, I applied the rollback mechanism into work
(of workqueue) as well. So it works even for hist.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
