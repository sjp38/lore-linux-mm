Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E5BBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:49:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3457218FC
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:49:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IswxzmgI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3457218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963F96B026B; Wed, 24 Apr 2019 10:49:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 910C56B026F; Wed, 24 Apr 2019 10:49:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FFFE6B0270; Wed, 24 Apr 2019 10:49:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 365476B026B
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:49:48 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id j5so4238884wrw.23
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:49:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VEczXuKv6Quy6JBmvR+06hO4NY3fHEDgv6Ho0d2mWwk=;
        b=Xu9xHXw0sjkux8iGjOPTwH04VZGOP3kVHsjwX0EixktPJKTkEQDc7pXINsc4BrU7KM
         INIEyJYz8oUoeAm4ZYFCpu3LT/jgzyELUMdG9LG+roSf/JKnXcKqqLkRqL1qoL8ju7IZ
         dHTwrCMy5z86FWTATOi1ozkt8wEqFKDD6IEjYEDijh+tFOj0RwpPP2J/oLhNMG+VG3RL
         /by1UJ+Z0HcAhBklYTJwbbMK3GRtxiFdCjUULnShMi2j2L3emIbwRxhAgqxTf3h9V+lb
         riMGXHtjX1T0S19ZRqQMFDbHliJSX/XpCfvZsoEO8KK5PfXovkX8LefefuzguvlsrBPK
         xutQ==
X-Gm-Message-State: APjAAAU1+knHUn1f93vLWPKy6hxtuKG4Xqgbm+o5wLYxRAo3EpGbKrqE
	6/ewMUQ2POS2xaT/NfDvSN2mWyUwupXDS1g/dIlRGh5Az6DYTMA8HcEG1RnPqyqddOPFBMhvyG4
	zPomiWzi32LnyhU2iBqM3Ob/q59NTwT+8A8HqU1iNUJS66bJut9x0WUhIKfW9hN0Trw==
X-Received: by 2002:a5d:56c6:: with SMTP id m6mr21047233wrw.211.1556117387658;
        Wed, 24 Apr 2019 07:49:47 -0700 (PDT)
X-Received: by 2002:a5d:56c6:: with SMTP id m6mr21047155wrw.211.1556117386437;
        Wed, 24 Apr 2019 07:49:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117386; cv=none;
        d=google.com; s=arc-20160816;
        b=rkWS8iKTc8twJKMMIp/KaK/1Fof2bkmbzqlRz9ZUSoNeVHuC/75PDBdmRLDMLp86GI
         YSRjzJXeOvhgOpDLwhywZ+zVqHo86RqVe6EVMj4ORMfNM7B30s9SuxrOZe4awqJTQZHY
         FEZNXk720LHfKrLlOJY3JEwGy99L0GpQH/bY9J0yurPn2tUe8oEbdqJv8wS0hiYjCjUL
         aIvZiTCJTMJkdhGtPJtBSaGMyNercuqiNhQmWPMt48otf5adz/nhy1f8vPkBsCvHCcbN
         k4hDsnK9muPoJGt1Wid1qljlkIW2lJYvtKFcHtmkjF2OCYsxVddrcsnp2itI0PuBMW4x
         PVYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VEczXuKv6Quy6JBmvR+06hO4NY3fHEDgv6Ho0d2mWwk=;
        b=Kau93jzuEmtzV/yIso2rdDkpOdzmR1GZIjuoRMB/1/i3BjPxynpXGCgSrpKt8pY5Ts
         bEqHHyuHQD2CCUydoM+/y2Y8EpBxOI/mT6flvzQAxGgolP/aXcwtE/lv8H9FX7oihJRX
         cOIHqyMv+bJuTs2LI2mAGeIdUtRaI/ojfF+aPOxDJ8BEIPEMK357ieOA7L6t913kZnGM
         MaR9tY7Bcd+RaWEnrlapG3KhgNKgmZSmFbkG8pSa7BPN72fbbSOVUnKQV7EpnWDR1fz0
         iQ1IThJnbWyvTr5xpS8kHGifF5pxb29vO2vpVtI2utgYYDDGINJF6bxNbXwA0HIui/sx
         waMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IswxzmgI;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f9sor10303508wro.20.2019.04.24.07.49.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 07:49:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IswxzmgI;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VEczXuKv6Quy6JBmvR+06hO4NY3fHEDgv6Ho0d2mWwk=;
        b=IswxzmgI0ShNbykD7kndvpLF85H2h6GXvadS1FzOPjjd+yKC51HBOObG/WxulZ15RW
         NA5hz8iZ0gufEo9n115kG6hQX8eWwuQcXxLvJHbXaqp8qbV08wniVPauvZWfarXX35lL
         1LbxPqvT/kxCQ3nS4egL/wP+DS5BYAehdfMSyiRyRiYagdZ2UqxN/95kMEIh+mHnDtHn
         RRPa0eD771DNjlNyLEpJ1i1RoAKjRVDvjEncUeBmJFM2sGNGJhoBdy6nD/T5Niy472UY
         u6Ol+LvfqYx6sENQyl/oEz0fNQ7ag4f3rbZyl6dBfB8TszMKn3g8yxudMgYrHD73MYGD
         7mDQ==
X-Google-Smtp-Source: APXvYqzbLKD7e6vF/Xd0n0gKbXO3rKSTqPXWRzpQJzk6js86LohvFP/CQTzlMu2/0wXgu7Nokw/jSf7DnkSx6pM3570=
X-Received: by 2002:adf:f310:: with SMTP id i16mr8261598wro.291.1556117385543;
 Wed, 24 Apr 2019 07:49:45 -0700 (PDT)
MIME-Version: 1.0
References: <CAA25o9TV7B5Cej_=snuBcBnNFpfixBEQduTwQZOH0fh5iyXd=A@mail.gmail.com>
 <CAJuCfpHGcDM8c19g_AxWa4FSx++YbTSE70CGW4TiKvrdAg3R+w@mail.gmail.com> <CAA25o9Rzcqts7oCpwyRq2yBALkHQVwgzgFDVYv08Z0UUhY+qhw@mail.gmail.com>
In-Reply-To: <CAA25o9Rzcqts7oCpwyRq2yBALkHQVwgzgFDVYv08Z0UUhY+qhw@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 24 Apr 2019 07:49:34 -0700
Message-ID: <CAJuCfpHMEVHYpodjsote2Gp0y_G1=Hi66xzdhXfOgtcMMiiL9g@mail.gmail.com>
Subject: Re: PSI vs. CPU overhead for client computing
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 9:54 PM Luigi Semenzato <semenzato@google.com> wrote:
>
> Thank you very much Suren.
>
> On Tue, Apr 23, 2019 at 3:04 PM Suren Baghdasaryan <surenb@google.com> wrote:
> >
> > Hi Luigi,
> >
> > On Tue, Apr 23, 2019 at 11:58 AM Luigi Semenzato <semenzato@google.com> wrote:
> > >
> > > I and others are working on improving system behavior under memory
> > > pressure on Chrome OS.  We use zram, which swaps to a
> > > statically-configured compressed RAM disk.  One challenge that we have
> > > is that the footprint of our workloads is highly variable.  With zram,
> > > we have to set the size of the swap partition at boot time.  When the
> > > (logical) swap partition is full, we're left with some amount of RAM
> > > usable by file and anonymous pages (we can ignore the rest).  We don't
> > > get to control this amount dynamically.  Thus if the workload fits
> > > nicely in it, everything works well.  If it doesn't, then the rate of
> > > anonymous page faults can be quite high, causing large CPU overhead
> > > for compression/decompression (as well as for other parts of the MM).
> > >
> > > In Chrome OS and Android, we have the luxury that we can reduce
> > > pressure by terminating processes (tab discard in Chrome OS, app kill
> > > in Android---which incidentally also runs in parallel with Chrome OS
> > > on some chromebooks).  To help decide when to reduce pressure, we
> > > would like to have a reliable and device-independent measure of MM CPU
> > > overhead.  I have looked into PSI and have a few questions.  I am also
> > > looking for alternative suggestions.
> > >
> > > PSI measures the times spent when some and all tasks are blocked by
> > > memory allocation.  In some experiments, this doesn't seem to
> > > correlate too well with CPU overhead (which instead correlates fairly
> > > well with page fault rates).  Could this be because it includes
> > > pressure from file page faults?
> >
> > This might be caused by thrashing (see:
> > https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1114).
> >
> > >  Is there some way of interpreting PSI
> > > numbers so that the pressure from file pages is ignored?
> >
> > I don't think so but I might be wrong. Notice here
> > https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1111
> > you could probably use delayacct to distinguish file thrashing,
> > however remember that PSI takes into account the number of CPUs and
> > the number of currently non-idle tasks in its pressure calculations,
> > so the raw delay numbers might not be very useful here.
>
> OK.
>
> > > What is the purpose of "some" and "full" in the PSI measurements?  The
> > > chrome browser is a multi-process app and there is a lot of IPC.  When
> > > process A is blocked on memory allocation, it cannot respond to IPC
> > > from process B, thus effectively both processes are blocked on
> > > allocation, but we don't see that.
> >
> > I don't think PSI would account such an indirect stall when A is
> > waiting for B and B is blocked on memory access. B's stall will be
> > accounted for but I don't think A's blocked time will go into PSI
> > calculations. The process inter-dependencies are probably out of scope
> > for PSI.
>
> Right, that's what I was also saying.  It would be near impossible to
> figure it out.  It may also be that statistically it doesn't matter,
> as long as the workload characteristics don't change dramatically.
> Which unfortunately they might...
>
> > > Also, there are situations in
> > > which some "uninteresting" process keep running.  So it's not clear we
> > > can rely on "full".  Or maybe I am misunderstanding?  "Some" may be a
> > > better measure, but again it doesn't measure indirect blockage.
> >
> > Johannes explains the SOME and FULL calculations here:
> > https://elixir.bootlin.com/linux/v5.1-rc6/source/kernel/sched/psi.c#L76
> > and includes couple examples with the last one showing FULL>0 and some
> > tasks still running.
>
> Thank you, yes, those are good explanation.  I am still not sure how
> to use this in our case.
>
> I thought about using the page fault rate as a proxy for the
> allocation overhead.  Unfortunately it is difficult to figure out the
> baseline, because: 1. it is device-dependent (that's not
> insurmountable: we could compute a per-device baseline offline); 2.
> the CPUs can go in and out of turbo mode, or temperature-throttling,
> and the notion of a constant "baseline" fails miserably.
>
> > > The kernel contains various cpustat measurements, including some
> > > slightly esoteric ones such as CPUTIME_GUEST and CPUTIME_GUEST_NICE.
> > > Would adding a CPUTIME_MEM be out of the question?
>
> Any opinion on CPUTIME_MEM?

I guess some description of how you plan to calculate it would be
helpful. A simple raw delay counter might not be very useful, that's
why PSI performs more elaborate calculations.
Maybe posting a small RFC patch with code would get more attention and
you can collect more feedback.

> Thanks again!
>
> > > Thanks!
> > >
> >
> > Just my 2 cents and Johannes being the author might have more to say here.

