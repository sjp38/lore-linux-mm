Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF3B68E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:29:36 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id l16so5668037wre.6
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:29:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b125sor2388697wmd.19.2018.12.18.12.29.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 12:29:35 -0800 (PST)
MIME-Version: 1.0
References: <20181214171508.7791-1-surenb@google.com> <20181214171508.7791-7-surenb@google.com>
 <20181217162223.GD2218@hirez.programming.kicks-ass.net> <CAJuCfpHGsDnE-eAHY1QnX949stA3cvNA=078q1swqVnz95aJfg@mail.gmail.com>
 <20181218104622.GB15430@hirez.programming.kicks-ass.net> <20181218173000.GA4733@cmpxchg.org>
 <CAJuCfpGQKQ9oVKdVeLNQHY2+2XTjLXb6VHDcJKAUCtSxvd68wQ@mail.gmail.com> <CAJWu+oor7SzQVgo7SDKFcJS-BX+Oexj2_x_uWGsC8W=ErNGoNw@mail.gmail.com>
In-Reply-To: <CAJWu+oor7SzQVgo7SDKFcJS-BX+Oexj2_x_uWGsC8W=ErNGoNw@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 18 Dec 2018 12:29:23 -0800
Message-ID: <CAJuCfpEc3jbnd39cV5hx_DQjmBcvu8aBhcgJW5VP0oddOYYctA@mail.gmail.com>
Subject: Re: [PATCH 6/6] psi: introduce psi monitor
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Tue, Dec 18, 2018 at 11:18 AM Joel Fernandes <joelaf@google.com> wrote:
>
> On Tue, Dec 18, 2018 at 9:58 AM 'Suren Baghdasaryan' via kernel-team
> <kernel-team@android.com> wrote:
> >
> > Current design supports only whole percentages and if userspace needs
> > more granularity then it has to use usecs.
> > I agree that usecs cover % usecase and "threshold * win / 100" is
> > simple enough for userspace to calculate. I'm fine with changing to
> > usecs only.
>
> Suren, please avoid top-posting to LKML.

Sorry, did that by accident.

> Also I was going to say the same thing, just usecs only is better.

Thanks for the input.

> thanks,
>
>  - Joel


> > On Tue, Dec 18, 2018 at 9:30 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
> > >
> > > On Tue, Dec 18, 2018 at 11:46:22AM +0100, Peter Zijlstra wrote:
> > > > On Mon, Dec 17, 2018 at 05:21:05PM -0800, Suren Baghdasaryan wrote:
> > > > > On Mon, Dec 17, 2018 at 8:22 AM Peter Zijlstra <peterz@infradead.org> wrote:
> > > >
> > > > > > How well has this thing been fuzzed? Custom string parser, yay!
> > > > >
> > > > > Honestly, not much. Normal cases and some obvious corner cases. Will
> > > > > check if I can use some fuzzer to get more coverage or will write a
> > > > > script.
> > > > > I'm not thrilled about writing a custom parser, so if there is a
> > > > > better way to handle this please advise.
> > > >
> > > > The grammar seems fairly simple, something like:
> > > >
> > > >   some-full = "some" | "full" ;
> > > >   threshold-abs = integer ;
> > > >   threshold-pct = integer, { "%" } ;
> > > >   threshold = threshold-abs | threshold-pct ;
> > > >   window = integer ;
> > > >   trigger = some-full, space, threshold, space, window ;
> > > >
> > > > And that could even be expressed as two scanf formats:
> > > >
> > > >  "%4s %u%% %u" , "%4s %u %u"
> > > >
> > > > which then gets your something like:
> > > >
> > > >   char type[5];
> > > >
> > > >   if (sscanf(input, "%4s %u%% %u", &type, &pct, &window) == 3) {
> > > >       // do pct thing
> > > >   } else if (sscanf(intput, "%4s %u %u", &type, &thres, &window) == 3) {
> > > >       // do abs thing
> > > >   } else return -EFAIL;
> > > >
> > > >   if (!strcmp(type, "some")) {
> > > >       // some
> > > >   } else if (!strcmp(type, "full")) {
> > > >       // full
> > > >   } else return -EFAIL;
> > > >
> > > >   // do more
> > >
> > > We might want to drop the percentage notation.
> > >
> > > While it's somewhat convenient, it's also not unreasonable to ask
> > > userspace to do a simple "threshold * win / 100" themselves, and it
> > > would simplify the interface spec and the parser.
> > >
> > > Sure, psi outputs percentages, but only for fixed window sizes, so
> > > that actually saves us something, whereas this parser here needs to
> > > take a fractional anyway. The output is also in decimal notation,
> > > which is necessary for granularity. And I really don't think we want
> > > to add float parsing on top of this interface spec.
> > >
> > > So neither the convenience nor the symmetry argument are very
> > > compelling IMO. It might be better to just not go there.
> >
> > --
> > You received this message because you are subscribed to the Google Groups "kernel-team" group.
> > To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
> >
