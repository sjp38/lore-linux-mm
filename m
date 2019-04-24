Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFD88C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 04:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5838218D2
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 04:54:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sbBZ1/eo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5838218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41AFB6B0007; Wed, 24 Apr 2019 00:54:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C98B6B0008; Wed, 24 Apr 2019 00:54:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B9786B000A; Wed, 24 Apr 2019 00:54:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id D200C6B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:54:46 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id w13so1667913wmc.6
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 21:54:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6SCJHenPmeZBgq84wCssWQ06ag129Nkv1xXgSAngMo4=;
        b=C1nguXfsG4VrR9i1yHzBUIYK9DUeUiuPuD1Yf5wakBqSyNCe8AQJEI0Pms5A/wdSrb
         Fzn48CFS2+SSU5XPxvyAyVCn5caZPgBJzptNwM95ylgijP8wKkun7nQmhqgbzQx4MFoQ
         GQV0IuIgCt9BhdqDkZqOBYDWZ7eLtQPEhjc9zhHrW4mKqTvXiUd3555Y0gOaR2LOeHnN
         8Kr0t5d4OuCpAtbF1p4KlfR8kHDHNMG3m7qwL+e7eRkU6O6gb/zBB+ZAdPJI4XlAk3bb
         tJs4xyOOgjMgNCQvDqaTfRO2u0MksNLUhbq26zWbOGT5fVc8RXpkmC9b4+76WSXd5YdH
         ByUw==
X-Gm-Message-State: APjAAAV5M0UiVUTMAorZjhU7TbgtLmkhMmw58kp11tmYCLnKQiOQ/M2v
	ePoO+83YkZqL8rRFwtMgJvfTijTSr7cxZ5TJ/F8EgBd/KIj+stYfqpppUXzBCGkF3B6QWFWqZp5
	ZjGHl21C0BouC7e1ypnD6sCnXe7nb5L9xYoh0lJ0akTWXnZ4aTyafbJCNhESKdvRYwQ==
X-Received: by 2002:a1c:a7c5:: with SMTP id q188mr4742888wme.126.1556081686180;
        Tue, 23 Apr 2019 21:54:46 -0700 (PDT)
X-Received: by 2002:a1c:a7c5:: with SMTP id q188mr4742841wme.126.1556081685284;
        Tue, 23 Apr 2019 21:54:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556081685; cv=none;
        d=google.com; s=arc-20160816;
        b=cabsCSO2Go8b2ik5Ix0jORr2u2tbNGi9H22F3BKYZcjYFo5AZSznXPUeyQx6ooOQiF
         swUgq4WRjGP+/GyKg3xDgqWIG9tovq0QLWQKHxISl++9jdSxcgWPZKrbS0FuDZvZxYBe
         Ig4ZD3aIC7z2vrOCoeFaAU9CS57PFrqwEf5mGeALMra6JHxoBVyPqv0PNfxAS5Xq09Gb
         cOAfU0fpW88yY3jpGPcpmkfWu8i0Zt5Myw/rNbAAvdcqqmGXslyXTUgIe6ySvZZC5e4g
         9HXrUEWyFYPsJkivaG8DYFG44b22WyWjW0qDNihwB5wZTyl7NaLprMvkH90/ZmQ9/nN0
         aKYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6SCJHenPmeZBgq84wCssWQ06ag129Nkv1xXgSAngMo4=;
        b=awtIvXHEtW4OHpNBs6OUD06XDTqWmRFa/cNKF+gvHE7BK+ekKjRhPpzmc146h0Ot8Y
         8bjQD6Fq3nqsJp7+Er62cqqvWADftEK+K7HUmtNCie0mNQ5kWCc7prRMHUlivvTs1uaE
         FVCMDfWtfbACclXlu488YjPOxZBcMGbbqdj2ubBir4YdbKPEmIkogcBzqPxMM3Hng8TW
         YqGKsXhaSL/2Dg/fPuNKAtud9dPtcviGoPKty2f9hfeykc7ekYQwqeCN5+vTswFCiiaN
         G7fC9dTSUuTVXj2wovFT5jnxKU2O8FPwPuiZVLMto/tUJ7DsvoZrcneTNVj43Hjz0AjG
         FmZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="sbBZ1/eo";
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n7sor7850698wru.28.2019.04.23.21.54.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 21:54:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="sbBZ1/eo";
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6SCJHenPmeZBgq84wCssWQ06ag129Nkv1xXgSAngMo4=;
        b=sbBZ1/eoUq7zcobXpSRUwda2pB49uestq+nwxHbCRyxnJuCd3G71CKzQ1jbTZ7Vs+6
         nyqWlmCTTkHtpyg9hshJwcCjIKwAMFnWa+fWBmWCmxwGxrJLjC2b5yV0RZ1POd/3/gyj
         UfZBvf3ImWApwJWf5RK4aTQN3rm67fQnbSKDW7qq9UtnG9yXSE+ObvxbXEs/VeMdGKw/
         jmEMZ7DE3RZZZ0aNcf1Z6TalqJ7QXKMVNcnIMA73fHksPuPGF7y/QA7z8BYpXOUrNey8
         QK/jNRnlQD3E7zg4ELir7CNmMJUF//55klVpu+jCJMcBwLvxxbj3b6RR0kFqKt6biT91
         os8g==
X-Google-Smtp-Source: APXvYqxZ8k/sKZA2poWNiV7NWAtsrXvBBFZShZPZzId1RHlYEx7sXnUvVJA3UN3eJkSwIn0ylcyGqg4/4KI8dQ3n8VA=
X-Received: by 2002:a5d:5343:: with SMTP id t3mr6097845wrv.49.1556081684213;
 Tue, 23 Apr 2019 21:54:44 -0700 (PDT)
MIME-Version: 1.0
References: <CAA25o9TV7B5Cej_=snuBcBnNFpfixBEQduTwQZOH0fh5iyXd=A@mail.gmail.com>
 <CAJuCfpHGcDM8c19g_AxWa4FSx++YbTSE70CGW4TiKvrdAg3R+w@mail.gmail.com>
In-Reply-To: <CAJuCfpHGcDM8c19g_AxWa4FSx++YbTSE70CGW4TiKvrdAg3R+w@mail.gmail.com>
From: Luigi Semenzato <semenzato@google.com>
Date: Tue, 23 Apr 2019 21:54:31 -0700
Message-ID: <CAA25o9Rzcqts7oCpwyRq2yBALkHQVwgzgFDVYv08Z0UUhY+qhw@mail.gmail.com>
Subject: Re: PSI vs. CPU overhead for client computing
To: Suren Baghdasaryan <surenb@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you very much Suren.

On Tue, Apr 23, 2019 at 3:04 PM Suren Baghdasaryan <surenb@google.com> wrote:
>
> Hi Luigi,
>
> On Tue, Apr 23, 2019 at 11:58 AM Luigi Semenzato <semenzato@google.com> wrote:
> >
> > I and others are working on improving system behavior under memory
> > pressure on Chrome OS.  We use zram, which swaps to a
> > statically-configured compressed RAM disk.  One challenge that we have
> > is that the footprint of our workloads is highly variable.  With zram,
> > we have to set the size of the swap partition at boot time.  When the
> > (logical) swap partition is full, we're left with some amount of RAM
> > usable by file and anonymous pages (we can ignore the rest).  We don't
> > get to control this amount dynamically.  Thus if the workload fits
> > nicely in it, everything works well.  If it doesn't, then the rate of
> > anonymous page faults can be quite high, causing large CPU overhead
> > for compression/decompression (as well as for other parts of the MM).
> >
> > In Chrome OS and Android, we have the luxury that we can reduce
> > pressure by terminating processes (tab discard in Chrome OS, app kill
> > in Android---which incidentally also runs in parallel with Chrome OS
> > on some chromebooks).  To help decide when to reduce pressure, we
> > would like to have a reliable and device-independent measure of MM CPU
> > overhead.  I have looked into PSI and have a few questions.  I am also
> > looking for alternative suggestions.
> >
> > PSI measures the times spent when some and all tasks are blocked by
> > memory allocation.  In some experiments, this doesn't seem to
> > correlate too well with CPU overhead (which instead correlates fairly
> > well with page fault rates).  Could this be because it includes
> > pressure from file page faults?
>
> This might be caused by thrashing (see:
> https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1114).
>
> >  Is there some way of interpreting PSI
> > numbers so that the pressure from file pages is ignored?
>
> I don't think so but I might be wrong. Notice here
> https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1111
> you could probably use delayacct to distinguish file thrashing,
> however remember that PSI takes into account the number of CPUs and
> the number of currently non-idle tasks in its pressure calculations,
> so the raw delay numbers might not be very useful here.

OK.

> > What is the purpose of "some" and "full" in the PSI measurements?  The
> > chrome browser is a multi-process app and there is a lot of IPC.  When
> > process A is blocked on memory allocation, it cannot respond to IPC
> > from process B, thus effectively both processes are blocked on
> > allocation, but we don't see that.
>
> I don't think PSI would account such an indirect stall when A is
> waiting for B and B is blocked on memory access. B's stall will be
> accounted for but I don't think A's blocked time will go into PSI
> calculations. The process inter-dependencies are probably out of scope
> for PSI.

Right, that's what I was also saying.  It would be near impossible to
figure it out.  It may also be that statistically it doesn't matter,
as long as the workload characteristics don't change dramatically.
Which unfortunately they might...

> > Also, there are situations in
> > which some "uninteresting" process keep running.  So it's not clear we
> > can rely on "full".  Or maybe I am misunderstanding?  "Some" may be a
> > better measure, but again it doesn't measure indirect blockage.
>
> Johannes explains the SOME and FULL calculations here:
> https://elixir.bootlin.com/linux/v5.1-rc6/source/kernel/sched/psi.c#L76
> and includes couple examples with the last one showing FULL>0 and some
> tasks still running.

Thank you, yes, those are good explanation.  I am still not sure how
to use this in our case.

I thought about using the page fault rate as a proxy for the
allocation overhead.  Unfortunately it is difficult to figure out the
baseline, because: 1. it is device-dependent (that's not
insurmountable: we could compute a per-device baseline offline); 2.
the CPUs can go in and out of turbo mode, or temperature-throttling,
and the notion of a constant "baseline" fails miserably.

> > The kernel contains various cpustat measurements, including some
> > slightly esoteric ones such as CPUTIME_GUEST and CPUTIME_GUEST_NICE.
> > Would adding a CPUTIME_MEM be out of the question?

Any opinion on CPUTIME_MEM?

Thanks again!

> > Thanks!
> >
>
> Just my 2 cents and Johannes being the author might have more to say here.

