Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE733440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:23:34 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id y70so18286986vky.5
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:23:34 -0700 (PDT)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id j12si2005369vkc.276.2017.07.13.04.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 04:23:34 -0700 (PDT)
Received: by mail-vk0-x241.google.com with SMTP id p193so3517227vkd.2
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:23:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170713111209.ji6w3trt45icpuf6@hirez.programming.kicks-ass.net>
References: <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop> <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R> <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R> <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
 <20170713100953.GI20323@X58A-UD3R> <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
 <20170713111209.ji6w3trt45icpuf6@hirez.programming.kicks-ass.net>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Thu, 13 Jul 2017 20:23:33 +0900
Message-ID: <CANrsvRMZ=i+L1sQzPiMVzpTOduNnTw_gKqcNkBVWPdpDs5fQZA@mail.gmail.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring buffer overwrite
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 8:12 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Jul 13, 2017 at 12:29:05PM +0200, Peter Zijlstra wrote:
>> On Thu, Jul 13, 2017 at 07:09:53PM +0900, Byungchul Park wrote:
>> > On Thu, Jul 13, 2017 at 11:50:52AM +0200, Peter Zijlstra wrote:
>> > >   wait_for_completion(&C);
>> > >     atomic_inc_return();
>> > >
>> > >                                   mutex_lock(A1);
>> > >                                   mutex_unlock(A1);
>> > >
>> > >
>> > >                                   <IRQ>
>> > >                                     spin_lock(B1);
>> > >                                     spin_unlock(B1);
>> > >
>> > >                                     ...
>> > >
>> > >                                     spin_lock(B64);
>> > >                                     spin_unlock(B64);
>> > >                                   </IRQ>
>> > >
>> > >
>
> Also consider the alternative:
>
>                                         <IRQ>
>                                           spin_lock(D);
>                                           spin_unlock(D);
>
>                                           complete(&C);
>                                         </IRQ>
>
> in which case the context test will also not work.

Context tests are done on xhlock with the release context, _not_
acquisition context. For example, spin_lock(D) and complete(&C) are
in the same context, so the test would pass in this example.

So it works.


-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
