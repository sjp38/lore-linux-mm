Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 204F78E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:39:27 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id e192so1578059wmg.4
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:39:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y140sor23373356wmd.12.2019.01.16.09.39.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 09:39:25 -0800 (PST)
MIME-Version: 1.0
References: <20190110220718.261134-1-surenb@google.com> <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com> <20190116132446.GF10803@hirez.programming.kicks-ass.net>
In-Reply-To: <20190116132446.GF10803@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 16 Jan 2019 09:39:13 -0800
Message-ID: <CAJuCfpEJW6Uq4GSGEGLKOM4K7ySHUeTGrSUGM1+EJSQ16d8SJg@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Wed, Jan 16, 2019 at 5:24 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Mon, Jan 14, 2019 at 11:30:12AM -0800, Suren Baghdasaryan wrote:
> > For memory ordering (which Johannes also pointed out) the critical point is:
> >
> > times[cpu] += delta           | if g->polling:
> > smp_wmb()                     |   g->polling = polling = 0
> > cmpxchg(g->polling, 0, 1)     |   smp_rmb()
> >                               |   delta = times[*] (through goto SLOWPATH)
> >
> > So that hotpath writes to times[] then g->polling and slowpath reads
> > g->polling then times[]. cmpxchg() implies a full barrier, so we can
> > drop smp_wmb(). Something like this:
> >
> > times[cpu] += delta           | if g->polling:
> > cmpxchg(g->polling, 0, 1)     |   g->polling = polling = 0
> >                               |   smp_rmb()
> >                               |   delta = times[*] (through goto SLOWPATH)
> >
> > Would that address your concern about ordering?
>
> cmpxchg() implies smp_mb() before and after, so the smp_wmb() on the
> left column is superfluous.

Should I keep it in the comments to make it obvious and add a note
about implicit barriers being the reason we don't call smp_mb() in the
code explicitly?

> The right hand column is actively wrong; because that reads like it
> wants to order a store (g->polling = 0) and a load (d = times[]), and
> therefore requires smp_mb().

Just to clarify, smp_mb() is needed only in the comments or do you
want an explicit smp_mb() in the code as well? As Johannes noted
get_recent_times() which is part of "delta = times[*]" operation
involves read_seqcount section that should act as implicit memory
barrier in the slowpath.

> Also, you probably want to use atomic_t for g->polling, because we
> (sadly) have architectures where regular stores and atomic ops don't
> work 'right'.

Oh, I see. Will do. Thanks!

> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>
