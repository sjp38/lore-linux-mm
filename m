Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3DF8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 20:22:48 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id 51so4635437wrb.15
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 17:22:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69sor574226wmy.3.2018.12.17.17.22.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 17:22:47 -0800 (PST)
MIME-Version: 1.0
References: <20181214171508.7791-1-surenb@google.com> <20181214171508.7791-7-surenb@google.com>
 <20181217162713.GE2218@hirez.programming.kicks-ass.net>
In-Reply-To: <20181217162713.GE2218@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 17 Dec 2018 17:22:35 -0800
Message-ID: <CAJuCfpFp7v4oc9LL0TVMiYavOMOvDs5y=kQ8S7URtKojkWmH7Q@mail.gmail.com>
Subject: Re: [PATCH 6/6] psi: introduce psi monitor
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Mon, Dec 17, 2018 at 8:37 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Fri, Dec 14, 2018 at 09:15:08AM -0800, Suren Baghdasaryan wrote:
> > @@ -358,28 +526,23 @@ static void psi_update_work(struct work_struct *work)
> >  {
> >       struct delayed_work *dwork;
> >       struct psi_group *group;
> > +     u64 next_update;
> >
> >       dwork = to_delayed_work(work);
> >       group = container_of(dwork, struct psi_group, clock_work);
> >
> >       /*
> > +      * Periodically fold the per-cpu times and feed samples
> > +      * into the running averages.
> >        */
> >
> > +     psi_update(group);
> >
> > +     /* Calculate closest update time */
> > +     next_update = min(group->polling_next_update,
> > +                             group->avg_next_update);
> > +     schedule_delayed_work(dwork, min(PSI_FREQ,
> > +             nsecs_to_jiffies(next_update - sched_clock()) + 1));
>
> See, so I don't at _all_ like how there is no idle option..

Copy that. Will see what we can do to bring it back.
Thanks!

> >  }
>
>
> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>
