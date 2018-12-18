Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B90DD8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 20:21:18 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id x3so4553834wru.22
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 17:21:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n188sor559117wmn.17.2018.12.17.17.21.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 17:21:17 -0800 (PST)
MIME-Version: 1.0
References: <20181214171508.7791-1-surenb@google.com> <20181214171508.7791-7-surenb@google.com>
 <20181217162223.GD2218@hirez.programming.kicks-ass.net>
In-Reply-To: <20181217162223.GD2218@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 17 Dec 2018 17:21:05 -0800
Message-ID: <CAJuCfpHGsDnE-eAHY1QnX949stA3cvNA=078q1swqVnz95aJfg@mail.gmail.com>
Subject: Re: [PATCH 6/6] psi: introduce psi monitor
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Mon, Dec 17, 2018 at 8:22 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Fri, Dec 14, 2018 at 09:15:08AM -0800, Suren Baghdasaryan wrote:
> > +ssize_t psi_trigger_parse(char *buf, size_t nbytes, enum psi_res res,
> > +     enum psi_states *state, u32 *threshold_us, u32 *win_sz_us)
> > +{
> > +     bool some;
> > +     bool threshold_pct;
> > +     u32 threshold;
> > +     u32 win_sz;
> > +     char *p;
> > +
> > +     p = strsep(&buf, " ");
> > +     if (p == NULL)
> > +             return -EINVAL;
> > +
> > +     /* parse type */
> > +     if (!strcmp(p, "some"))
> > +             some = true;
> > +     else if (!strcmp(p, "full"))
> > +             some = false;
> > +     else
> > +             return -EINVAL;
> > +
> > +     switch (res) {
> > +     case (PSI_IO):
> > +             *state = some ? PSI_IO_SOME : PSI_IO_FULL;
> > +             break;
> > +     case (PSI_MEM):
> > +             *state = some ? PSI_MEM_SOME : PSI_MEM_FULL;
> > +             break;
> > +     case (PSI_CPU):
> > +             if (!some)
> > +                     return -EINVAL;
> > +             *state = PSI_CPU_SOME;
> > +             break;
> > +     default:
> > +             return -EINVAL;
> > +     }
> > +
> > +     while (isspace(*buf))
> > +             buf++;
> > +
> > +     p = strsep(&buf, "%");
> > +     if (p == NULL)
> > +             return -EINVAL;
> > +
> > +     if (buf == NULL) {
> > +             /* % sign was not found, threshold is specified in us */
> > +             buf = p;
> > +             p = strsep(&buf, " ");
> > +             if (p == NULL)
> > +                     return -EINVAL;
> > +
> > +             threshold_pct = false;
> > +     } else
> > +             threshold_pct = true;
> > +
> > +     /* parse threshold */
> > +     if (kstrtouint(p, 0, &threshold))
> > +             return -EINVAL;
> > +
> > +     while (isspace(*buf))
> > +             buf++;
> > +
> > +     p = strsep(&buf, " ");
> > +     if (p == NULL)
> > +             return -EINVAL;
> > +
> > +     /* Parse window size */
> > +     if (kstrtouint(p, 0, &win_sz))
> > +             return -EINVAL;
> > +
> > +     /* Check window size */
> > +     if (win_sz < PSI_TRIG_MIN_WIN_US || win_sz > PSI_TRIG_MAX_WIN_US)
> > +             return -EINVAL;
> > +
> > +     if (threshold_pct)
> > +             threshold = (threshold * win_sz) / 100;
> > +
> > +     /* Check threshold */
> > +     if (threshold == 0 || threshold > win_sz)
> > +             return -EINVAL;
> > +
> > +     *threshold_us = threshold;
> > +     *win_sz_us = win_sz;
> > +
> > +     return 0;
> > +}
>
> How well has this thing been fuzzed? Custom string parser, yay!

Honestly, not much. Normal cases and some obvious corner cases. Will
check if I can use some fuzzer to get more coverage or will write a
script.
I'm not thrilled about writing a custom parser, so if there is a
better way to handle this please advise.

> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>
