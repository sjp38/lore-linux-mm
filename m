Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74A9FC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:25:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27531216B7
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:25:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OWoEZJcf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27531216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FADE6B0005; Mon,  5 Aug 2019 15:25:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AC1B6B0006; Mon,  5 Aug 2019 15:25:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89A4B6B0007; Mon,  5 Aug 2019 15:25:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7746B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 15:25:11 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id s17so24205686ybg.15
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 12:25:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jBhZHZxcR0OIAcxY7/57CQdVnxqW0BKtiYJig9O330A=;
        b=Xyk8tqCDksY/A8w5lJPgVQcj3+mu4Y3T8i4m3dAYo4xDGBBxe/wvhypCvcuhXf0JWv
         V62GUw2PMc6ZUMcSNKFxJiulZdvsYiD9FmSAiuKRj4asJui4E11TLB+z9JLyGKZe0Oy5
         RWDG46XyCIkTqCSOY2oVypJJ1b2JspbxAI+vM1CGQvDhdAna1nRSbd+MMeP7Np4QTTEr
         Q87uPC/sos7fu1GtplLTnVz47MAOVxl1xYMnLZYPhswJJa4Tk9AotKbHU6W+4Xi6OYgD
         Vp1KpIMhbCyP2f4k8Yajdf1bpUdsCdQRL7dJbTl/oCdnES3ZALN0XoGB/wOigE+eQhyN
         MOzQ==
X-Gm-Message-State: APjAAAXE8nlarzBxVb2Q3VGbt1yRTv7vjOWiYN2XZnojk3RIr1CmJfyo
	X4t5mhB7mlM1dXxlV/XvI5H7Tv0XnEXNozIwEjA93j+Paus702XGKg/2biY0etuvm7GQ2Uvhzui
	ZfFP3/spEHyHm/3DRElVAQKjTCfRSSSwk7h1NTLtib0FZKP+kkGvLTd7Il60F3AmWrw==
X-Received: by 2002:a25:bbc6:: with SMTP id c6mr58241384ybk.302.1565033111120;
        Mon, 05 Aug 2019 12:25:11 -0700 (PDT)
X-Received: by 2002:a25:bbc6:: with SMTP id c6mr58241340ybk.302.1565033110289;
        Mon, 05 Aug 2019 12:25:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565033110; cv=none;
        d=google.com; s=arc-20160816;
        b=kjDLVaD5EOtB2epq/jwi2akzYdxuZdyWvqxlV2U9rOxByw2z3T9fbVEFdXPnOby5uz
         TvQqZmMdapmE8lVIGxCXJQ/6b/TOZdGwT9DToNvxwVeCyw2/haZNALxdEMETl8uCc6dB
         0JXk/+k4/vUCCprCa9ZCDEMxHVKF+A+27CGmsu2u744nA0uD3s8wCH9r5kbp5pFKEJLb
         JExr1n8QC9Pc6qC8e5EkZuuNg8+2tbLcgojUlFLpLmzTP5jANIkqgH+oZencCSNN625r
         V3r1n3I6DO/bZt9Mfa1slqaVJiwoMycqrAsVIpw5cvtHAjzaEvkjOl7xEymeMu5xLF+U
         XbHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jBhZHZxcR0OIAcxY7/57CQdVnxqW0BKtiYJig9O330A=;
        b=AHZlV/zGleO+DeaxfInrRpN47UDd52jssG8d8W9Z81rxnsHBdEqwULji/UA5ApbU3p
         8NnywpsnoI+EnhI8hBKoS9mx0XRvJBEdkBf3743De0Ywt1/C65dhMdsXZVO2I7xu5yOY
         njXQPcJkxyBJXP0j/rV93YwNPNNtcS7GF/QIoX/7m/st7TUAwpP0JyXJty/vZZQ8sY4D
         vau/t2Mo0w+9Ute35ht0M76b/mBgHUW4M5ZA6MhGJemHVV88iYIBdq/Y3sp/n0ULlJpC
         13o8k/MQFsGN2cEOdpH3+ihfNqAZUr4U6eRgKuypAfWBUnRGMuH44GA+UMKzBOB3ehNg
         3QWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OWoEZJcf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x125sor34426789ywa.28.2019.08.05.12.25.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 12:25:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OWoEZJcf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jBhZHZxcR0OIAcxY7/57CQdVnxqW0BKtiYJig9O330A=;
        b=OWoEZJcfzeB9SYxPFawo056U4q1al2l7k+0gU3JECGIOX5fJ9AIdUCnznZLyUznYRF
         Tt203xpJn7adxpO28UHjqgDOoQm2q85rp40ZFW+XF8uvBcrlSXeStp3k0U3tihqqdSZG
         HqAu/l+qBcDLyzGHEVoJraaaC6fsenAwxprN829u8nILdwy08WqWvqliXoPBXr2Y/7JM
         b7Nf9zKAJdeZoKdGBMxeicWw3wXpN10PUPyvRrn6Hzdwvuh0Ss0RCTr5DRAAeRPt0GnF
         uzYpyuws4/j/4HUokCCBpgk9/3CI8BxdwHhbi3hJWUq/6jl9NtTOOd8QPD+zqw5w5f6u
         nx+w==
X-Google-Smtp-Source: APXvYqxbDkA1SdB4BSUlDwh2X+zCd0WZTNLSo8tmRckemDIdGtE48knQ4mlRNXjwS7YqcsgBexfZZdY7HIiqIwx86rc=
X-Received: by 2002:a0d:cb42:: with SMTP id n63mr37267027ywd.205.1565033109503;
 Mon, 05 Aug 2019 12:25:09 -0700 (PDT)
MIME-Version: 1.0
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz> <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz> <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
 <20190729184850.GH9330@dhcp22.suse.cz> <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
 <20190802093507.GF6461@dhcp22.suse.cz> <CAHbLzkrjh7KEvdfXackaVy8oW5CU=UaBucERffxcUorgq1vdoA@mail.gmail.com>
 <20190805143239.GS7597@dhcp22.suse.cz>
In-Reply-To: <20190805143239.GS7597@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 5 Aug 2019 12:24:58 -0700
Message-ID: <CALvZod5upYA2UgUSWJjrL7K=zifhwwvK5M_gUakPhf2fP-3HxA@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <shy828301@gmail.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 5, 2019 at 7:32 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 02-08-19 11:56:28, Yang Shi wrote:
> > On Fri, Aug 2, 2019 at 2:35 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 01-08-19 14:00:51, Yang Shi wrote:
> > > > On Mon, Jul 29, 2019 at 11:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Mon 29-07-19 10:28:43, Yang Shi wrote:
> > > > > [...]
> > > > > > I don't worry too much about scale since the scale issue is not unique
> > > > > > to background reclaim, direct reclaim may run into the same problem.
> > > > >
> > > > > Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
> > > > > You can have thousands of memcgs and I do not think we really do want
> > > > > to create one kswapd for each. Once we have a kswapd thread pool then we
> > > > > get into a tricky land where a determinism/fairness would be non trivial
> > > > > to achieve. Direct reclaim, on the other hand is bound by the workload
> > > > > itself.
> > > >
> > > > Yes, I agree thread pool would introduce more latency than dedicated
> > > > kswapd thread. But, it looks not that bad in our test. When memory
> > > > allocation is fast, even though dedicated kswapd thread can't catch
> > > > up. So, such background reclaim is best effort, not guaranteed.
> > > >
> > > > I don't quite get what you mean about fairness. Do you mean they may
> > > > spend excessive cpu time then cause other processes starvation? I
> > > > think this could be mitigated by properly organizing and setting
> > > > groups. But, I agree this is tricky.
> > >
> > > No, I meant that the cost of reclaiming a unit of charges (e.g.
> > > SWAP_CLUSTER_MAX) is not constant and depends on the state of the memory
> > > on LRUs. Therefore any thread pool mechanism would lead to unfair
> > > reclaim and non-deterministic behavior.
> >
> > Yes, the cost depends on the state of pages, but I still don't quite
> > understand what does "unfair" refer to in this context. Do you mean
> > some cgroups may reclaim much more than others?
>
> > Or the work may take too long so it can't not serve other cgroups in time?
>
> exactly.
>

How about allowing the users to implement their own user space kswapd?
A memcg interface similar to MADV_PAGEOUT. Users can register for
MEMCG_HIGH notification (it needs some modification) and on receiving
the notification, the uswapd (User's kswapd) will trigger reclaim
through memory.pageout (or memory.try_to_free_pages). One can argue
why not just use MADV_PAGEOUT? In real workload, a job can be a
combination of different sub-jobs and most probably may not know the
importance of the memory layout of the tasks of the sub-jobs. So, a
memcg level interface makes more sense there.

Shakeel

