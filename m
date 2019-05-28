Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBD65C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7637820717
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:52:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PosD1hmu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7637820717
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1678E6B026E; Tue, 28 May 2019 07:52:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 109706B026F; Tue, 28 May 2019 07:52:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01EED6B0272; Tue, 28 May 2019 07:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id D55D06B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:52:07 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id l20so7870946vkl.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=i1aTFeYdC8ihQzpvWtoviM3ZNZ2tyKMHAXg6yp7ic20=;
        b=Y7eLIv4eQYcTFg9eDuv5bZaKtp9hQg7/YCyEnmdHyrMWmmbhIa9PgJVbdJR7IcCfTf
         k0043hy5agE2Vf7Bg6Xs6kNd/4oY8//8IIzcGXuKm8MIF7IZSaOnUehEB+Btg8KOFTgQ
         ldzVaB6BIH8xbguAQPuTdt1PePvARzrFjo0c+yx/ukmUXI3t7cKtBWvLMf4giOFjwjKv
         hfuO6yEUCeXXJmfNwS+hOVaqKfs1I/X1v61Ob1xL73xvBiNE9dcV+K0X5wgGLMTlMNKX
         E7qZa9qEX6L5MJldvfuwvYOBs52Pu39Zn2Q+cjPD3D095EBaYOcMBklSoQOjW3dp2l6F
         p0/w==
X-Gm-Message-State: APjAAAV5o4qsOGigzf6gg0oC+V66OWXgJF3o2jYU+1da/T796kVb/n+Y
	eop/F4l9RuX6h3zUlzdmkH5yiB32+wNAxBuo9u80ubXHczm0OmUXfzPla3XSbMJUcZDASXp4J8p
	SXSrYijRqTamDAScXSLQViQHo5QHL57Mz6cbuwFyWQkyG17R4p5f/8+u+KKNtCAWi0w==
X-Received: by 2002:ab0:3182:: with SMTP id d2mr3402843uan.62.1559044327586;
        Tue, 28 May 2019 04:52:07 -0700 (PDT)
X-Received: by 2002:ab0:3182:: with SMTP id d2mr3402807uan.62.1559044326865;
        Tue, 28 May 2019 04:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559044326; cv=none;
        d=google.com; s=arc-20160816;
        b=rv1eWjd5Af0DjQ/ymaNDZc4KrLLGj/7QYyB1dbFOPA3NmtFSSi0kEkK4up7Jzt09hQ
         JBgqLzY9nx5/JFR9lu8lsy5863FzTDmcxFElBhGfkGLN54pjBpniE1Ig5VeMPQBABy0V
         EEe+V+XoOwCZC6+dSW8moZvg7bynKWFl4rHx2GPV6yAcGzo0pu5VQwm70tWhsUuTqtAc
         v+f5wS1z2RY1opxtQNEioMtJKZQCEM3egqrKT8QCi28S6JzqU2zSfYeaeRRJfBqbid3m
         wu8SlLdSlc9jP+oDIxshNVu4yf69/bMElr4+1FOke5cZ9tKuFIKxJaDFHpR5Vw6Z4j8F
         NHlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=i1aTFeYdC8ihQzpvWtoviM3ZNZ2tyKMHAXg6yp7ic20=;
        b=m4LSbvRLi0pC3Vhj0miIAM20uEMNSrkT/zuSDBwKocVZoUSF/m94x/SRhWtY6HYwuF
         uXBPx0Qlcf+QgVyM1565E8JK7R11Lg1w22u3k93d7niLfrJBjYGoGy9FGr/Ux8PAAmZa
         h2e40nbhcvqzw/U5sfBCczKvd/BSiPmgkSPy7lL6WLdMZ+hBAT6J6uRRpbHJP/+Z4ED3
         FNBdYNM/RlroZY6FVmBhcNL6rek0r4N3HhkLbswAyH2OIkEK7Cc2DnIzKfbfTQLlk8xq
         35Zmux/yEVBUFennwh7ueMqNzr5kxK1J0RToA8e1IdUYNd3dfApfjp4v8xGrhNFLnhL8
         fxag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PosD1hmu;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y128sor5470832vsc.54.2019.05.28.04.52.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 04:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PosD1hmu;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i1aTFeYdC8ihQzpvWtoviM3ZNZ2tyKMHAXg6yp7ic20=;
        b=PosD1hmuB27HZrO906sYy0hewh4Vct55iIo0ByAp5WPqAr20vF5v6fG5Uxip/NrYLY
         QjNnEufZ8cZ02hvqUlK+kE3rzkvD77a6u2RqFou/IyqQ/DUV5A8SEpapg7REnhCFXf8f
         u9vjOMgPCoIbg724+0XcflX2NkQmUJFCsD+SMjVGC6JLL5Sstt5s7We8VUgj8MRjdTP7
         7LmPrujpPcmv4jaTkhKrCAJkq3XSFukprMN1b7c8kCdwOZ1tnM/O9Di7jnoUHqdDlfk1
         d/uI/EnpyQ1PHBBvLQ3TCqurKIo2lqu05a0yHDeZjxhFgubelY7FKKvZEfDq3rfs0RSv
         LrFw==
X-Google-Smtp-Source: APXvYqziveOhM5aNGo++tqUxS5XQXmXAHH/ek/mb/jgasaqofdw7uSl7LyXM4Lvz7mZ8iIPG7/VXfBvYqhiTJAbga5g=
X-Received: by 2002:a67:1485:: with SMTP id 127mr43387796vsu.77.1559044326244;
 Tue, 28 May 2019 04:52:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190528032632.GF6879@google.com> <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com> <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com> <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com> <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com> <20190528112840.GY1658@dhcp22.suse.cz> <20190528114436.GB30365@google.com>
In-Reply-To: <20190528114436.GB30365@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 28 May 2019 04:51:54 -0700
Message-ID: <CAKOZueu7ayjDoV904gFPRQu84_toxWAN5hBBe17x=g-MOBJ7uQ@mail.gmail.com>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 4:44 AM Minchan Kim <minchan@kernel.org> wrote:
>
> On Tue, May 28, 2019 at 01:28:40PM +0200, Michal Hocko wrote:
> > On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > > >
> > > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > > so map_anon wouldn't be helpful.
> > > > > > > >
> > > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > > e.g., Android memory map debugging commands.
> > > > > > >
> > > > > > > I agree it's the best we can get *generally*.
> > > > > > > Michal, any opinion?
> > > > > >
> > > > > > I am not really sure this is directly related. I think the primary
> > > > > > question that we have to sort out first is whether we want to have
> > > > > > the remote madvise call process or vma fd based. This is an important
> > > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > > so far unfortunately.
> > > > >
> > > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > > but thought it could be easily extended later for each address range
> > > > > operation as userspace getting smarter with more information.
> > > >
> > > > Never design user API based on a single usecase, please. The "easily
> > > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > > several times, the synchronization model has to be thought through
> > > > carefuly before a remote process address range operation can be
> > > > implemented.
> > >
> > > I agree with you that we shouldn't design API on single usecase but what
> > > you are concerning is actually not our usecase because we are resilient
> > > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > > Actually, many hints are already racy in that the upcoming pattern would
> > > be different with the behavior you thought at the moment.
> >
> > How come they are racy wrt address ranges? You would have to be in
> > multithreaded environment and then the onus of synchronization is on
> > threads. That model is quite clear. But we are talking about separate
>
> Think about MADV_FREE. Allocator would think the chunk is worth to mark
> "freeable" but soon, user of the allocator asked the chunk - ie, it's not
> freeable any longer once user start to use it.
>
> My point is that kinds of *hints* are always racy so any synchronization
> couldn't help a lot. That's why I want to restrict hints process_madvise
> supports as such kinds of non-destruptive one at next respin.

I think it's more natural for process_madvise to be a superset of
regular madvise. What's the harm? There are no security implications,
since anyone who could process_madvise could just ptrace anyway. I
also don't think limiting the hinting to non-destructive operations
guarantees safety (in a broad sense) either, since operating on the
wrong memory range can still cause unexpected system performance
issues even if there's no data loss.

More broadly, what I want to see is a family of process_* APIs that
provide a superset of the functionality that the existing intraprocess
APIs provide. I think this approach is elegant and generalizes easily.
I'm worried about prematurely limiting the interprocess memory APIs
and creating limitations that will last a long time in order to avoid
having to consider issues like VMA synchronization.

