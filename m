Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3268E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 14:30:26 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id 51so39762wrb.15
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:30:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor49420335wro.6.2019.01.14.11.30.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 11:30:24 -0800 (PST)
MIME-Version: 1.0
References: <20190110220718.261134-1-surenb@google.com> <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
In-Reply-To: <20190114102137.GB14054@worktop.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 14 Jan 2019 11:30:12 -0800
Message-ID: <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Mon, Jan 14, 2019 at 2:22 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Thu, Jan 10, 2019 at 02:07:18PM -0800, Suren Baghdasaryan wrote:
> > +/*
> > + * psi_update_work represents slowpath accounting part while
> > + * psi_group_change represents hotpath part.
> > + * There are two potential races between these path:
> > + * 1. Changes to group->polling when slowpath checks for new stall, then
> > + *    hotpath records new stall and then slowpath resets group->polling
> > + *    flag. This leads to the exit from the polling mode while monitored
> > + *    states are still changing.
> > + * 2. Slowpath overwriting an immediate update scheduled from the hotpath
> > + *    with a regular update further in the future and missing the
> > + *    immediate update.
> > + * Both races are handled with a retry cycle in the slowpath:
> > + *
> > + *    HOTPATH:                         |    SLOWPATH:
> > + *                                     |
> > + * A) times[cpu] += delta              | E) delta = times[*]
> > + * B) start_poll = (delta[poll_mask] &&|    if delta[poll_mask]:
> > + *      cmpxchg(g->polling, 0, 1) == 0)| F)   polling_until = now +
> > + *                                     |              grace_period
> > + *                                     |    if now > polling_until:
> > + *    if start_poll:                   |      if g->polling:
> > + * C)   mod_delayed_work(1)            | G)     g->polling = polling = 0
> > + *    else if !delayed_work_pending(): | H)     goto SLOWPATH
> > + * D)   schedule_delayed_work(PSI_FREQ)|    else:
> > + *                                     |      if !g->polling:
> > + *                                     | I)     g->polling = polling = 1
> > + *                                     | J) if delta && first_pass:
> > + *                                     |      next_avg = calculate_averages()
> > + *                                     |      if polling:
> > + *                                     |        next_poll = poll_triggers()
> > + *                                     |    if (delta && first_pass) || polling:
> > + *                                     | K)   mod_delayed_work(
> > + *                                     |          min(next_avg, next_poll))
> > + *                                     |      if !polling:
> > + *                                     |        first_pass = false
> > + *                                     | L)     goto SLOWPATH
> > + *
> > + * Race #1 is represented by (EABGD) sequence in which case slowpath
> > + * deactivates polling mode because it misses new monitored stall and hotpath
> > + * doesn't activate it because at (B) g->polling is not yet reset by slowpath
> > + * in (G). This race is handled by the (H) retry, which in the race described
> > + * above results in the new sequence of (EABGDHEIK) that reactivates polling
> > + * mode.
> > + *
> > + * Race #2 is represented by polling==false && (JABCK) sequence which
> > + * overwrites immediate update scheduled at (C) with a later (next_avg) update
> > + * scheduled at (K). This race is handled by the (L) retry which results in the
> > + * new sequence of polling==false && (JABCKLEIK) that reactivates polling mode
> > + * and reschedules next polling update (next_poll).
> > + *
> > + * Note that retries can't result in an infinite loop because retry #1 happens
> > + * only during polling reactivation and retry #2 happens only on the first
> > + * pass. Constant reactivations are impossible because polling will stay active
> > + * for at least grace_period. Worst case scenario involves two retries (HEJKLE)
> > + */
>
> I'm having a fairly hard time with this. There's a distinct lack of
> memory ordering, and a suspicious mixing of atomic ops (cmpxchg) and
> regular loads and stores (without READ_ONCE/WRITE_ONCE even).
>
> Please clarify.

Thanks for the feedback.
I do mix atomic and regular loads with g->polling only because the
slowpath is the only one that resets it back to 0, so
cmpxchg(g->polling, 1, 0) == 1 at (G) would always return 1.
Setting g->polling back to 1 at (I) indeed needs an atomic operation
but at that point it does not matter whether hotpath or slowpath sets
it. In either case we will schedule a polling update.
Am I missing anything?

For memory ordering (which Johannes also pointed out) the critical point is:

times[cpu] += delta           | if g->polling:
smp_wmb()                     |   g->polling = polling = 0
cmpxchg(g->polling, 0, 1)     |   smp_rmb()
                              |   delta = times[*] (through goto SLOWPATH)

So that hotpath writes to times[] then g->polling and slowpath reads
g->polling then times[]. cmpxchg() implies a full barrier, so we can
drop smp_wmb(). Something like this:

times[cpu] += delta           | if g->polling:
cmpxchg(g->polling, 0, 1)     |   g->polling = polling = 0
                              |   smp_rmb()
                              |   delta = times[*] (through goto SLOWPATH)

Would that address your concern about ordering?

> (also, you look to have a whole bunch of line-breaks that are really not
> needed; concattenated the line would not be over 80 chars).

Will try to minimize line-breaks.


> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>
