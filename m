Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id A18D98E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 20:10:14 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id o5so296058wmf.9
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 17:10:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor1358774wrx.26.2018.12.17.17.10.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 17:10:13 -0800 (PST)
MIME-Version: 1.0
References: <20181214171508.7791-1-surenb@google.com> <20181214171508.7791-4-surenb@google.com>
 <20181217145754.GB2218@hirez.programming.kicks-ass.net>
In-Reply-To: <20181217145754.GB2218@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 17 Dec 2018 17:10:01 -0800
Message-ID: <CAJuCfpFtqd=RDDW_U5HFXuAZzNh6F+Enrjz3P4jZg=hvyH9RwQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] psi: eliminate lazy clock mode
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Mon, Dec 17, 2018 at 6:58 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Fri, Dec 14, 2018 at 09:15:05AM -0800, Suren Baghdasaryan wrote:
> > Eliminate the idle mode and keep the worker doing 2s update intervals
> > at all times.
>
> That sounds like a bad deal.. esp. so for battery powered devices like
> say Andoird.
>
> In general the push has been to always idle everything, see NOHZ and
> NOHZ_FULL and all the work that's being put into getting rid of any and
> all period work.

Thanks for the feedback Peter! The removal of idle mode is unfortunate
but so far we could not find an elegant solution to handle 3 states
(IDLE / REGULAR / POLLING) without additional synchronization inside
the hotpath. The issue, as I remember it, was that while scheduling a
regular update inside psi_group_change() (IDLE to REGULAR transition)
we might override an earlier update being scheduled inside
psi_update_work(). I think we can solve that by using
mod_delayed_work_on() inside psi_update_work() but I might be missing
some other race. I'll discuss this again with Johannes and see if we
can synchronize all states using only atomic operations on clock_mode.

> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>
