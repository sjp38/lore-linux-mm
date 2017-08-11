Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2A16B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:06:40 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u87so6006811lfg.15
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:06:40 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id g86si392123ljg.449.2017.08.11.06.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 06:06:38 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id m86so15800497lfi.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:06:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170811094448.GJ20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis> <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis> <20170810131737.skdyy4qcxlikbyeh@tardis>
 <20170811034328.GH20323@X58A-UD3R> <20170811080329.3ehu7pp7lcm62ji6@tardis>
 <20170811085201.GI20323@X58A-UD3R> <20170811094448.GJ20323@X58A-UD3R>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Fri, 11 Aug 2017 22:06:37 +0900
Message-ID: <CANrsvRM4ijD0ym0HJySqjOfcCeUbGCc6bBppK43y5MqC5aB1gQ@mail.gmail.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring buffer overwrite
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Boqun Feng <boqun.feng@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Fri, Aug 11, 2017 at 6:44 PM, Byungchul Park <byungchul.park@lge.com> wrote:
> On Fri, Aug 11, 2017 at 05:52:02PM +0900, Byungchul Park wrote:
>> On Fri, Aug 11, 2017 at 04:03:29PM +0800, Boqun Feng wrote:
>> > Thanks for taking a look at it ;-)
>>
>> I rather appriciate it.
>>
>> > > > @@ -5005,7 +5003,7 @@ static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
>> > > >  static void commit_xhlocks(struct cross_lock *xlock)
>> > > >  {
>> > > >         unsigned int cur = current->xhlock_idx;
>> > > > -       unsigned int prev_hist_id = xhlock(cur).hist_id;
>> > > > +       unsigned int prev_hist_id = cur + 1;
>> > >
>> > > I should have named it another. Could you suggest a better one?
>> > >
>> >
>> > I think "prev" is fine, because I thought the "previous" means the
>> > xhlock item we visit _previously_.
>> >
>> > > >         unsigned int i;
>> > > >
>> > > >         if (!graph_lock())
>> > > > @@ -5030,7 +5028,7 @@ static void commit_xhlocks(struct cross_lock *xlock)
>> > > >                          * hist_id than the following one, which is impossible
>> > > >                          * otherwise.
>> > >
>> > > Or we need to modify the comment so that the word 'prev' does not make
>> > > readers confused. It was my mistake.
>> > >
>> >
>> > I think the comment needs some help, but before you do it, could you
>> > have another look at what Peter proposed previously? Note you have a
>> > same_context_xhlock() check in the commit_xhlocks(), so the your
>> > previous overwrite case actually could be detected, I think.
>>
>> What is the previous overwrite case?
>>
>> ppppppppppwwwwwwwwwwwwiiiiiiiii
>> iiiiiiiiiiiiiii................
>>
>> Do you mean this one? I missed the check of same_context_xhlock(). Yes,
>> peterz's suggestion also seems to work.
>>
>> > However, one thing may not be detected is this case:
>> >
>> >             ppppppppppppppppppppppppppppppppppwwwwwwww
>> > wrapped >   wwwwwww
>>
>> To be honest, I think your suggestion is more natual, with which this
>> case would be also covered.
>>
>> >
>> >     where p: process and w: worker.
>> >
>> > , because p and w are in the same task_irq_context(). I discussed this
>> > with Peter yesterday, and he has a good idea: unconditionally do a reset
>> > on the ring buffer whenever we do a crossrelease_hist_end(XHLOCK_PROC).
>
> Ah, ok. You meant 'whenever _process_ context exit'.
>
> I need more time to be sure, but anyway for now it seems to work with
> giving up some chances for remaining xhlocks.
>
> But, I am not sure if it's still true even in future and the code can be
> maintained easily. I think your approach is natural and neat enough for
> that purpose. What problem exists with yours?

Let me list up the possible approaches:

0. Byungchul's approach
1. Boqun's approach
2. Peterz's approach
3. Reset on process exit

I like Boqun's approach most but, _whatever_. It's ok if it solves the problem.
The last one is not bad when it is used for syscall exit, but we have to give
up valid dependencies unnecessarily in other cases. And I think Peterz's
approach should be modified a bit to make it work neatly, like:

crossrelease_hist_end(...)
{
...
       invalidate_xhlock(&xhlock(cur->xhlock_idx_max));

       for (c = 0; c < XHLOCK_CXT_NR; c++)
              if ((cur->xhlock_idx_max - cur->xhlock_idx_hist[c]) >=
MAX_XHLOCKS_NR)
                     invalidate_xhlock(&xhlock(cur->xhlock_idx_hist[c]));
...
}

And then Peterz's approach can also work, I think.

---
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
