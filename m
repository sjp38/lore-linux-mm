Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EB3DC282E0
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 21:14:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C17C6208C0
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 21:14:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TN+lD0Yx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C17C6208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 367826B0003; Fri, 19 Apr 2019 17:14:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 317066B0006; Fri, 19 Apr 2019 17:14:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 254EF6B0007; Fri, 19 Apr 2019 17:14:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03DDF6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 17:14:42 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id i203so4912719ywa.5
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 14:14:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ep33f62HX3AzUBDcVwFjTp0Z/qGrzWSSxgy6irC3Dwc=;
        b=HXnqfyoa/0UaUahth1D+pWoeGNz9GbWik8S0oSZ0/L9eAcsB/ALmcQJUbYiXoqex7m
         jC36RMrd6QXAHkdBUVQ760KHqNr25NtuE4j1TOakr9ZHrfPCOud0KOhvXQZWd4nLmuPH
         rcfzxoQ3EJ4kt7Y9waRVXXJDlK9Su0rhfJ81s3K9KkjWA3SQcjtnDdDYyIr8nEnj2Trg
         EiSx2aGx7PwfQxnKyVEpwf4n87vSqEkxx1YstNbshoOcTAokNjt7pIXci039+Cya6Dyd
         ENQcrIUBn6JV1c5jXosWa6gkv1j1LmIyRf85r7IFaLMEJwKNNmnZOdxBPxpoDqB7wTe6
         c/Pw==
X-Gm-Message-State: APjAAAWw4e9/cObD+hi0Y8ncwrj2aad73Nr+4H3M50IG9twWjzFVjRva
	ekp+ZJKmd1orT10nxu1dKEQ6zVEIetfXpE1B/wG1gXSQ7TMlWF7zTMTvHkmxRxVWkyicc4eYd6q
	MLvqbH+x6WiHothvCjPAb7CxDamuZxM9GoZMMlLt2+gG6GWm01P6kAmjjHqfxsk7SEQ==
X-Received: by 2002:a0d:c445:: with SMTP id g66mr2765245ywd.61.1555708481744;
        Fri, 19 Apr 2019 14:14:41 -0700 (PDT)
X-Received: by 2002:a0d:c445:: with SMTP id g66mr2765200ywd.61.1555708481083;
        Fri, 19 Apr 2019 14:14:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555708481; cv=none;
        d=google.com; s=arc-20160816;
        b=M+BOHRC/bG1OeXU0JApo1sIxVt3MzM4dLKjbrbfDgwLwlCcgwEevrRci4lE6BOGHcA
         5/l7HWXnV5uwmqC/RB2DZDku9XjwN1t8faT5yMDyzCSKhVUX3HIeWtmPIuod9GwvmlZS
         sL3kIj3rVia6z2n7uMPnEiz1DeNQXouduyhKhEllDsGK9dO1ewncxm0zmpTfmrPX/m8F
         myTgJeGC4vHD6/u4fQaOccQ5b70sw40DAZO1D96xjlTtQJzHVUwcOwLlt7BnfHf9ihuF
         d8UoEfp6ks7kQJWLncCBTqE9wQGB90hRLp+xFYixhijqZJez6HBoTpi0IGgp9Nipe5Kc
         enjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ep33f62HX3AzUBDcVwFjTp0Z/qGrzWSSxgy6irC3Dwc=;
        b=IA7VZYTmImf40xiZ5VxnD1lYw+p1oKXpC95LUXI1FZt1twJyuL0J0ROOBjXUPx1Nef
         UWB0chc+QUm0mM9FcihSmbNov5GEpfxK0GsTlzZA10ADCJPOzJrZ1BDC94bqEo7l1bkz
         d5GiNHnDZdaoZUmR1XckWT9thNY9h+rb0IsGk2c6gi5zD4yIrx0N3eUFbcGLT1WcR0O1
         0jVqQQXXR8EM6WrPLoG7Bk1OcBRJFviPyFTYTPLyBBwT8afEYj5Dk7fRezIKjEU2+7TI
         YFwxyOr76ImgbgGdguNU5QU/FHAUM203aesxGq+G56nINR/kDdk3EG0lhtEQkk0Oya7+
         dv6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TN+lD0Yx;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor2760930ybp.132.2019.04.19.14.14.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 14:14:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TN+lD0Yx;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ep33f62HX3AzUBDcVwFjTp0Z/qGrzWSSxgy6irC3Dwc=;
        b=TN+lD0YxK8/Z39tQFNeng7o7MdFoxCJhCMdqBA3VkWcQCiVs/XYz7qebhQCkvh98UL
         QYtk4dk9C4miikKW7ebUyVThbhx3xOBfed7dosNc80MVG1HOVIEDJwbCgFx4BBOxXmuZ
         9BJC9skhYCCPRcDFlVoAk1wWJi5QPd3x7bV9nZrQOdhbYWEdfxh+qFEzSbhjh2zcF+Qk
         nEUxMY1lIEric7Sr22cPqLby1FKEYg8H2b/hKJaehzG2Bhsi5DI8SaX8kUlMXuKmwFZp
         2fucI4cAXY9cXKu/jqmNdiuJqUHmBHXRYYAbiFf+Wwhsg2U7d7P+0QNi3h2mwT28yPuy
         9j6Q==
X-Google-Smtp-Source: APXvYqwP8W9joct14TvJoGQu1QeSZbbs3jHQ7fURiorHFky435pvPWJhgSP+s96y780vcjdoFGt8mEO4Ajd7ZHl7V9g=
X-Received: by 2002:a25:4147:: with SMTP id o68mr5056203yba.148.1555708480546;
 Fri, 19 Apr 2019 14:14:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190418214224.61900-1-shakeelb@google.com> <20190419200733.GB31878@tower.DHCP.thefacebook.com>
In-Reply-To: <20190419200733.GB31878@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 19 Apr 2019 14:14:29 -0700
Message-ID: <CALvZod4N7XJ5Zxd-0pO0_tpnnmGHyY=6PMVcvCg49virdp=6SA@mail.gmail.com>
Subject: Re: [PATCH] memcg: refill_stock for kmem uncharging too
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 1:07 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Thu, Apr 18, 2019 at 02:42:24PM -0700, Shakeel Butt wrote:
> > The commit 475d0487a2ad ("mm: memcontrol: use per-cpu stocks for socket
> > memory uncharging") added refill_stock() for skmem uncharging path to
> > optimize workloads having high network traffic. Do the same for the kmem
> > uncharging as well. However bypass the refill for offlined memcgs to not
> > cause zombie apocalypse.
> >
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> Hello, Shakeel!
>
> > ---
> >  mm/memcontrol.c | 17 ++++++++---------
> >  1 file changed, 8 insertions(+), 9 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 2535e54e7989..7b8de091f572 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -178,6 +178,7 @@ struct mem_cgroup_event {
> >
> >  static void mem_cgroup_threshold(struct mem_cgroup *memcg);
> >  static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
> > +static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages);
> >
> >  /* Stuffs for move charges at task migration. */
> >  /*
> > @@ -2097,10 +2098,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
> >       struct mem_cgroup *old = stock->cached;
> >
> >       if (stock->nr_pages) {
> > -             page_counter_uncharge(&old->memory, stock->nr_pages);
> > -             if (do_memsw_account())
> > -                     page_counter_uncharge(&old->memsw, stock->nr_pages);
> > -             css_put_many(&old->css, stock->nr_pages);
> > +             cancel_charge(old, stock->nr_pages);
> >               stock->nr_pages = 0;
> >       }
> >       stock->cached = NULL;
> > @@ -2133,6 +2131,11 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
> >       struct memcg_stock_pcp *stock;
> >       unsigned long flags;
> >
> > +     if (unlikely(!mem_cgroup_online(memcg))) {
> > +             cancel_charge(memcg, nr_pages);
> > +             return;
> > +     }
>
> I'm slightly concerned about this part. Do we really need it?
> The number of "zombies" which we can pin is limited by the number of CPUs,
> and it will drop fast if there is any load on the machine.
>
> If we skip offline memcgs, it can slow down charging/uncharging of skmem,
> which might be a problem, if the socket is in active use by an other cgroup.
> Honestly, I'd drop this part.
>

Sure, I will wait for comments from others and then send the v2 without this.

Shakeel

