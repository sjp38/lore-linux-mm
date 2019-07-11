Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20547C74A3F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:11:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6EEA20844
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:11:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CE43ad1Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6EEA20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ECD88E00A0; Wed, 10 Jul 2019 21:11:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19D378E0032; Wed, 10 Jul 2019 21:11:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08A5B8E00A0; Wed, 10 Jul 2019 21:11:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF5B68E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 21:11:28 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id q26so4930309ioi.10
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 18:11:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LcBu6w/+FzbQQROXAYV6iJJ5sTbMv13/BFmKdJjymAo=;
        b=N05qZgBgbs4DprSVZa1HnXZ3gg+GTykZoXVNKGh0/dikXzZAmPncGEIGrDxwSSQnvp
         AJMvY6HSklCTk6bTdzuGCtq3VwGfiYU1IU4qw0Flr5Flw+SO4VX0TqN25z6kxwdEKITU
         B2F0EJqOmx0Xu9QRVw9pVtByTI86+qZRPt1HEvAQoNSkJbuq7hfrkEhG4LTfBMnqSFZs
         /u6gMYcnmezRDUdFvnvsWs9A5hIyr72ijQKpTtEmTE6wsyWJWk3SfmKHvB1HWLk70BRP
         jFHN0QDFrEmOwo9h0VEBxSRD8XQ8/RfYwnpVyGE3iFiO6En/4UdbJ4VtyPelpvOpi4of
         UpIA==
X-Gm-Message-State: APjAAAWPITCwnsMHWVi/LigvPv7ha75fsm+Ix7d8weeWa9S9Nd9IwIdo
	a38ip/Dyssi0Yrmke4ILMGALi/09XxxoO3ldhG8/Vin4lax4Qi64GDTTtgCG/Vdxcqn0jpjH67C
	3mmDeROXu7DTOJuHS6/wPzq93rRuRY9hbnlJ+hrpOsRpkZKiw7zNcmza9PBJOdTXpaA==
X-Received: by 2002:a6b:dc08:: with SMTP id s8mr1245362ioc.209.1562807488583;
        Wed, 10 Jul 2019 18:11:28 -0700 (PDT)
X-Received: by 2002:a6b:dc08:: with SMTP id s8mr1245318ioc.209.1562807487783;
        Wed, 10 Jul 2019 18:11:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562807487; cv=none;
        d=google.com; s=arc-20160816;
        b=z3dg+pjx9bHijMaWK+m+3Ij/1O1bJDlyF2B3wLuINcqX0wSR8Nmr61JEPbvl9ymqsM
         Zqfp3Aov/Y4Vj+WIkqBpUOuN534usTxf5Ys9KIxyh9AgOyRyOH63Wotj+e0YTPQZr4P2
         HLwuJPGLJ74vDPKkdaOJdbNIf4V6my4NUQCNbeeSuVb+7PUXwPsq4VYVuNLrvc/pFMg0
         VnFTZADQRjQS/1Y8izogaOU/bOlJ+4jOb0g1Bz7amx9gx8S9mMuT4qPO22FTsgyAahhu
         irKbut1ooP7wrCK0tUkxUIC3MUBAp6EDW5VYQvWsMoprSgLVKt6oSQErF+yrmiYqRa9m
         RHAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LcBu6w/+FzbQQROXAYV6iJJ5sTbMv13/BFmKdJjymAo=;
        b=lD5Dss+z85kwxiOOy2v/krtvjYwi0OY454D0hingTQBL/c6ru7AX3uIGquY5sE8IO9
         KybCZVUkNXqQjWj11VlxPp1vOlvmtDwNFChqR6xE/FC15YBRx9L4rNYRLmeu1USf1xLt
         7gA6cP1KUxeDT6HQ7/O6EWh0BERjzy1SpRwG4m1viYttMcppMUZO+vAXSI5DEpX0zUZn
         Px0YiuqGV4landjmRY8b/w5vJE6RhdI07GZISX41E1tRDECgtBRcZz22ExoWtPS7LC50
         n+tCva87EHtNfc6xHmMd/wamImqMXNG1srIjZ8RocIknEl0atJPM0oCPBfLrmwPtw+1W
         AF/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CE43ad1Z;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16sor3400035ioa.124.2019.07.10.18.11.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 18:11:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CE43ad1Z;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LcBu6w/+FzbQQROXAYV6iJJ5sTbMv13/BFmKdJjymAo=;
        b=CE43ad1ZOAIIUAdELOrtv6oS/SMk3mbJhvoqLguM2l1nS+xIot+tlF/1cEdNnPJfgC
         jcYnoddGP7zQwbi/foYqT8JwGDra2XyhZ9qMz0Be7IRoVPPlMXBgZFlWZUMwbFePDpK1
         7L402UfLzATDW2HCcVKnGvsbNTjBaylt2Br4YdozX2hcdP0nprQbu4DEaqNnnVLnxaAk
         rNwPsnvchXtjJw8lyDVBS/c650zyemsaHwDE9PRhYceOZpfMGSRfqfTaXgHGX/jP9l4h
         qybA7+idLRtncKQNA8hN57KjDoe4Mth0OJzYcNTEuo9pkAV+gZtH4vNtgbFS3s+0UNzu
         Drwg==
X-Google-Smtp-Source: APXvYqybCB5BDcyXY3P/JYm8gcoVA+lDTlGOQ4vb6+mqPsr6hdf34Nl8ot/Sp6gQU3Z0ZWQZflFsp4odS+wYr+fRx1Q=
X-Received: by 2002:a5e:9e0a:: with SMTP id i10mr1313690ioq.44.1562807487552;
 Wed, 10 Jul 2019 18:11:27 -0700 (PDT)
MIME-Version: 1.0
References: <1562750823-2762-1-git-send-email-laoar.shao@gmail.com> <20190710203811.GA16153@cmpxchg.org>
In-Reply-To: <20190710203811.GA16153@cmpxchg.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 11 Jul 2019 09:10:51 +0800
Message-ID: <CALOAHbDgjk4vYOO2xkkzewdmjAn7qps8KwYbeYJRcrNMh293Aw@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: make the local VM stats consistent with
 total stats
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 4:38 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Wed, Jul 10, 2019 at 05:27:03AM -0400, Yafang Shao wrote:
> > After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> > the local VM stats is not consistent with total VM stats.
> >
> > Bellow is one example on my server (with 8 CPUs),
> >       inactive_file 3567570944
> >       total_inactive_file 3568029696
> >
> > We can find that the deviation is very great, that is because the 'val' in
> > __mod_memcg_state() is in pages while the effective value
> > in memcg_stat_show() is in bytes.
> > So the maximum of this deviation between local VM stats and total VM
> > stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> > great value.
> >
> > We should make the local VM stats consistent with the total stats.
> > Although the deviation between local VM events and total events are not
> > great, I think we'd better make them consistent with each other as well.
>
> Ha - the local stats are not percpu-fuzzy enough... But I guess that
> is a valid complaint.
>
> > ---
> >  mm/memcontrol.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index ba9138a..a9448c3 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -691,12 +691,12 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
> >       if (mem_cgroup_disabled())
> >               return;
> >
> > -     __this_cpu_add(memcg->vmstats_local->stat[idx], val);
> >
> >       x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
> >       if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
> >               struct mem_cgroup *mi;
> >
> > +             __this_cpu_add(memcg->vmstats_local->stat[idx], x);
> >               for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> >                       atomic_long_add(x, &mi->vmstats[idx]);
> >               x = 0;
> > @@ -773,12 +773,12 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
> >       if (mem_cgroup_disabled())
> >               return;
> >
> > -     __this_cpu_add(memcg->vmstats_local->events[idx], count);
> >
> >       x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
> >       if (unlikely(x > MEMCG_CHARGE_BATCH)) {
> >               struct mem_cgroup *mi;
> >
> > +             __this_cpu_add(memcg->vmstats_local->events[idx], x);
> >               for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> >                       atomic_long_add(x, &mi->vmevents[idx]);
> >               x = 0;
>
> Please also update __mod_lruvec_state() to keep this behavior the same
> across counters, to make sure we won't have any surprises when
> switching between them.
>
> And please add comments explaining that we batch local counters to
> keep them in sync with the hierarchical ones. Because it does look a
> little odd without explanation.

Sure, I will do it.

Thanks
Yafang

