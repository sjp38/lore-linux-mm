Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA6698E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 05:22:34 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so15753203pfk.12
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 02:22:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g23si16875pgb.229.2019.01.14.02.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 14 Jan 2019 02:22:33 -0800 (PST)
Date: Mon, 14 Jan 2019 11:21:37 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
Message-ID: <20190114102137.GB14054@worktop.programming.kicks-ass.net>
References: <20190110220718.261134-1-surenb@google.com>
 <20190110220718.261134-6-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190110220718.261134-6-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com

On Thu, Jan 10, 2019 at 02:07:18PM -0800, Suren Baghdasaryan wrote:
> +/*
> + * psi_update_work represents slowpath accounting part while
> + * psi_group_change represents hotpath part.
> + * There are two potential races between these path:
> + * 1. Changes to group->polling when slowpath checks for new stall, then
> + *    hotpath records new stall and then slowpath resets group->polling
> + *    flag. This leads to the exit from the polling mode while monitored
> + *    states are still changing.
> + * 2. Slowpath overwriting an immediate update scheduled from the hotpath
> + *    with a regular update further in the future and missing the
> + *    immediate update.
> + * Both races are handled with a retry cycle in the slowpath:
> + *
> + *    HOTPATH:                         |    SLOWPATH:
> + *                                     |
> + * A) times[cpu] += delta              | E) delta = times[*]
> + * B) start_poll = (delta[poll_mask] &&|    if delta[poll_mask]:
> + *      cmpxchg(g->polling, 0, 1) == 0)| F)   polling_until = now +
> + *                                     |              grace_period
> + *                                     |    if now > polling_until:
> + *    if start_poll:                   |      if g->polling:
> + * C)   mod_delayed_work(1)            | G)     g->polling = polling = 0
> + *    else if !delayed_work_pending(): | H)     goto SLOWPATH
> + * D)   schedule_delayed_work(PSI_FREQ)|    else:
> + *                                     |      if !g->polling:
> + *                                     | I)     g->polling = polling = 1
> + *                                     | J) if delta && first_pass:
> + *                                     |      next_avg = calculate_averages()
> + *                                     |      if polling:
> + *                                     |        next_poll = poll_triggers()
> + *                                     |    if (delta && first_pass) || polling:
> + *                                     | K)   mod_delayed_work(
> + *                                     |          min(next_avg, next_poll))
> + *                                     |      if !polling:
> + *                                     |        first_pass = false
> + *                                     | L)     goto SLOWPATH
> + *
> + * Race #1 is represented by (EABGD) sequence in which case slowpath
> + * deactivates polling mode because it misses new monitored stall and hotpath
> + * doesn't activate it because at (B) g->polling is not yet reset by slowpath
> + * in (G). This race is handled by the (H) retry, which in the race described
> + * above results in the new sequence of (EABGDHEIK) that reactivates polling
> + * mode.
> + *
> + * Race #2 is represented by polling==false && (JABCK) sequence which
> + * overwrites immediate update scheduled at (C) with a later (next_avg) update
> + * scheduled at (K). This race is handled by the (L) retry which results in the
> + * new sequence of polling==false && (JABCKLEIK) that reactivates polling mode
> + * and reschedules next polling update (next_poll).
> + *
> + * Note that retries can't result in an infinite loop because retry #1 happens
> + * only during polling reactivation and retry #2 happens only on the first
> + * pass. Constant reactivations are impossible because polling will stay active
> + * for at least grace_period. Worst case scenario involves two retries (HEJKLE)
> + */

I'm having a fairly hard time with this. There's a distinct lack of
memory ordering, and a suspicious mixing of atomic ops (cmpxchg) and
regular loads and stores (without READ_ONCE/WRITE_ONCE even).

Please clarify.

(also, you look to have a whole bunch of line-breaks that are really not
needed; concattenated the line would not be over 80 chars).
