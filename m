Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB8BAC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:28:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78192206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:28:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="T9SNBetj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78192206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 114C28E0006; Thu,  1 Aug 2019 14:28:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09E7C8E0001; Thu,  1 Aug 2019 14:28:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA8958E0006; Thu,  1 Aug 2019 14:28:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E06B8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:28:44 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f16so35711258wrw.5
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:28:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0LASMwAA/tL/BAH/uT4ThFdb6tOVmHfjXl+JLumhDUs=;
        b=t64BRpRIWrOc2eEO9pp9aCZVesCzZcGR+SeoyAW5WoSEtc8L6jHmu9CBbHb6/Y+4/I
         +I+IT01B01QOyHgN3EAxZJ9H5I1uUVru9MxdTBY7BfKCedS7+gWKefwa/xKzqQqUo1D0
         6lGes+kmWd14GAGMZqrhaXD/tyBteUi0npTfZlI5q+Cvm28VNVgYTVK92fPN6IQVGAeV
         4QcWD0leRPUxhSEjVruOMFQ5hGRLz+AlAKFw4Y0+VfiVyPLFSDdRQaSHBOoTi7UI9MG1
         v5A1r3ZIxdWDQTbtV0wB1P6ceIs1ktV9aPEBwNpKUfUnSNhSRKmEjw4Hn2vamp4HFu9j
         ZLEg==
X-Gm-Message-State: APjAAAV6znjyddGPwG0/LmXSDacCFJGQniC/APLLvAqL6/3cAQ0qiekf
	zq+mYv41OLji5x/0rDUcg8fVeQlSA31K54QYiawNvv8qDTmOC+PoWvU6HtRkr0Uge5mwTZ4tYoF
	I3RCSKTpcIQz0vClqa/cY7V9enCeHBA2+NspFJSpyZe8N8InytvFYiHUpG6cS1yIeqA==
X-Received: by 2002:a05:6000:3:: with SMTP id h3mr27354256wrx.114.1564684124152;
        Thu, 01 Aug 2019 11:28:44 -0700 (PDT)
X-Received: by 2002:a05:6000:3:: with SMTP id h3mr27354180wrx.114.1564684122865;
        Thu, 01 Aug 2019 11:28:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564684122; cv=none;
        d=google.com; s=arc-20160816;
        b=TScj/7Oo7a/a0wuVKt1/0APp+8OQP0sN/85HUOX91HRxKYjFj7zJrx/RtkGZnGoR9a
         /909R5n2gvY7Yi0Kp4e5Z3R2ekzH4BrUXO9QbqgoD/9Q0VyFuOEGZxqcJ1Epm4+H2Iii
         SyBO1vm542cVDH04VmjIyrLQF1o0liF7Ah6FJF+sF+zNYkBK4hqpTkoyLMQVImC28Goq
         bUsRddX/mrbTGf3gS7ODYkrx/6bYmbCxSmBFVZfUtJjfR7NmwLz8NfMw12qd1OfyOdWJ
         UDsbWhIy2wG7WXrWVVhkTsivUSlvZs/h74qQHjLnaZ/X+n0QQS9EMKpoAGjajOBgEluD
         UpMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0LASMwAA/tL/BAH/uT4ThFdb6tOVmHfjXl+JLumhDUs=;
        b=RSsH+AY9wNaPOBfvdvojaQ6fPjoDn7cNxm06QDUdxAGwTj4kE8g473sRmCkI+EULcB
         fGjnetVsWi2S0y3Hz/803mEfnD1IqgA6V+yZ6mSfrWafkIOF+Au5pIcMBdlK4a3roNYx
         /bkXtw3o2etPlXQ1N4tpo7Eoh60pGgsr6reMQVWyGtRza+V1Hz7qvLnp3cWwXyH6a/bb
         gIyDFNbDk7enIWE3LSGpZk9jShk3XwlJnmjfDbLTOsPPviRWE1dkawbU76RzyqzYXH7G
         U7eEuSd4ZFL+0dhSWuhwGbkqBDFvsITddeoE4HnVZRl2fWDMtoGN+43H5kmmvIb9AL+2
         uOCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=T9SNBetj;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor57114695wrm.30.2019.08.01.11.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 11:28:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=T9SNBetj;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0LASMwAA/tL/BAH/uT4ThFdb6tOVmHfjXl+JLumhDUs=;
        b=T9SNBetjpP9aJmtLho0U4R1eQMvjfbE8ive2XLdxBpmHiR/lhyGZRF3woDGof8407y
         aTNpny9z7d3u6suklr4N8FS28ayUZIuEC1h8yJST1qoHX8vWCVzkefbjYJB5PKtbAsTS
         hQ32//bcAcSebAShg+dlMfH6TBtbJHEvyD9MrEvs2VC07K7yyBlmc9VqFguoYTPTTsuB
         v8dq8FtBZ4Le5ko2oQKgEi1mz1pTOlDqJ8eVXafDVRrupuPxgjJNiD46t8HThefgdM4B
         uXmKssFvph5ey1jB1r8+DIb0wv8SO9fPWdVSqjmp3o5QBnc/vB45lgHTj6PJU5OGG6oE
         VVhw==
X-Google-Smtp-Source: APXvYqy4P6VCuqoeuVUZ2KjNmm94cVgmTRIX91RWIsWFdz3OKNqiO12BvCI7yWcc++1AFK4h3az4ABTYL1GOqRxeFXo=
X-Received: by 2002:a5d:46cf:: with SMTP id g15mr4809916wrs.93.1564684122173;
 Thu, 01 Aug 2019 11:28:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190730013310.162367-1-surenb@google.com> <20190730081122.GH31381@hirez.programming.kicks-ass.net>
 <CAJuCfpH7NpuYKv-B9-27SpQSKhkzraw0LZzpik7_cyNMYcqB2Q@mail.gmail.com> <20190801095112.GA31381@hirez.programming.kicks-ass.net>
In-Reply-To: <20190801095112.GA31381@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 1 Aug 2019 11:28:30 -0700
Message-ID: <CAJuCfpHGpsU4bVcRxpc3wOybAOtiTKAsB=BNAtZcGnt10j5gbA@mail.gmail.com>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, Dennis Zhou <dennis@kernel.org>, 
	Dennis Zhou <dennisszhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>, 
	Nick Kralevich <nnk@google.com>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter,
Thanks for sharing your thoughts. I understand your point and I tend
to agree with it. I originally designed this using watchdog as the
example of a critical system health signal and in the context of
mobile device memory pressure is critical but I agree that there are
more important things in life. I checked and your proposal to change
it to FIFO-1 should still work for our purposes. Will test to make
sure and reply to your patch. Couple clarifications in-line.

On Thu, Aug 1, 2019 at 2:51 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Tue, Jul 30, 2019 at 10:44:51AM -0700, Suren Baghdasaryan wrote:
> > On Tue, Jul 30, 2019 at 1:11 AM Peter Zijlstra <peterz@infradead.org> wrote:
> > >
> > > On Mon, Jul 29, 2019 at 06:33:10PM -0700, Suren Baghdasaryan wrote:
> > > > When a process creates a new trigger by writing into /proc/pressure/*
> > > > files, permissions to write such a file should be used to determine whether
> > > > the process is allowed to do so or not. Current implementation would also
> > > > require such a process to have setsched capability. Setting of psi trigger
> > > > thread's scheduling policy is an implementation detail and should not be
> > > > exposed to the user level. Remove the permission check by using _nocheck
> > > > version of the function.
> > > >
> > > > Suggested-by: Nick Kralevich <nnk@google.com>
> > > > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > > > ---
> > > >  kernel/sched/psi.c | 2 +-
> > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > >
> > > > diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> > > > index 7acc632c3b82..ed9a1d573cb1 100644
> > > > --- a/kernel/sched/psi.c
> > > > +++ b/kernel/sched/psi.c
> > > > @@ -1061,7 +1061,7 @@ struct psi_trigger *psi_trigger_create(struct psi_group *group,
> > > >                       mutex_unlock(&group->trigger_lock);
> > > >                       return ERR_CAST(kworker);
> > > >               }
> > > > -             sched_setscheduler(kworker->task, SCHED_FIFO, &param);
> > > > +             sched_setscheduler_nocheck(kworker->task, SCHED_FIFO, &param);
> > >
> > > ARGGH, wtf is there a FIFO-99!! thread here at all !?
> >
> > We need psi poll_kworker to be an rt-priority thread so that psi
>
> There is a giant difference between 'needs to be higher than OTHER' and
> FIFO-99.
>
> > notifications are delivered to the userspace without delay even when
> > the CPUs are very congested. Otherwise it's easy to delay psi
> > notifications by running a simple CPU hogger executing "chrt -f 50 dd
> > if=/dev/zero of=/dev/null". Because these notifications are
>
> So what; at that point that's exactly what you're asking for. Using RT
> is for those who know what they're doing.
>
> > time-critical for reacting to memory shortages we can't allow for such
> > delays.
>
> Furthermore, actual RT programs will have pre-allocated and locked any
> memory they rely on. They don't give a crap about your pressure
> nonsense.
>

This signal is used not to protect other RT tasks but to monitor
overall system memory health for the sake of system responsiveness.

> > Notice that this kworker is created only if userspace creates a psi
> > trigger. So unless you are using psi triggers you will never see this
> > kthread created.
>
> By marking it FIFO-99 you're in effect saying that your stupid
> statistics gathering is more important than your life. It will preempt
> the task that's in control of the band-saw emergency break, it will
> preempt the task that's adjusting the electromagnetic field containing
> this plasma flow.
>
> That's insane.

IMHO an opt-in feature stops being "stupid" as soon as the user opted
in to use it, therefore explicitly indicating interest in it. However
I assume you are using "stupid" here to indicate that it's "less
important" rather than it's "useless".

> I'm going to queue a patch to reduce this to FIFO-1, that will preempt
> regular OTHER tasks but will not perturb (much) actual RT bits.
>

Thanks for posting the fix.

> --
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

