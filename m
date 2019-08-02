Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F17C41514
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 18:56:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55BF120B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 18:56:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fogrInpc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55BF120B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0706C6B0007; Fri,  2 Aug 2019 14:56:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 022026B0008; Fri,  2 Aug 2019 14:56:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E51CB6B000A; Fri,  2 Aug 2019 14:56:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C03A56B0007
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 14:56:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k125so65281430qkc.12
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 11:56:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LNGLxw2KweTcYpa9QkuGXi/8Vq8kU4lq6/m0y6hK/fE=;
        b=VRck7h2jE8+iYMm4pPvJyaaVbDXugtE0vpWtCSrMZFOFviwV5eyk2Dj3aP0ithsKC9
         4JHzz5/Rl2XfRiBvM4QnvIvHuUUPu3PfNJxsmd54mcHklulSgqfry5698wY2oIaBfgsb
         SQx1+h9QJYuK7jHSYAuItWW0SJTeBdR6HzMZEhoxPcRCHcLGkkdiolCIzkAINE90Y/UR
         h5b8hdErKn7xMXr+Qak/eTti4BAz99j7/co0XH3VwyDooGJW+hyAPpsQu//7lEk2omkC
         xzVkKgcElQ3Oiot/oAywnH1T10fabZ/CPivr5IIj84NYYp+WZ5mjaem6d1F9rbCuiz+K
         MJjQ==
X-Gm-Message-State: APjAAAXnEGe9AuR2hzdXfypyBBkIyU0v/Gf9T8pztQhEaqY9AH+OzcKV
	LZXbGCM2xnx7CcX4sRyLVKXc7JFOHHuvHZV6tTFGWOc5YdwXd0DGdRH8P1lSdKJdgF5pJH2w9eK
	BHPK0jPa8KuIFws+KSNfOZY6650BADB8M8sbs7vja/90vf8cX7ISZ4eu+/hRI88+jJg==
X-Received: by 2002:ae9:d610:: with SMTP id r16mr86448564qkk.16.1564772204441;
        Fri, 02 Aug 2019 11:56:44 -0700 (PDT)
X-Received: by 2002:ae9:d610:: with SMTP id r16mr86448536qkk.16.1564772203796;
        Fri, 02 Aug 2019 11:56:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564772203; cv=none;
        d=google.com; s=arc-20160816;
        b=D+Zojdhp0svaJ1r020aRj1YWbnhHPbuKOxSS2E4FB34M4/tLOeFoWb+XUXOnz44urc
         SdZVCgRJXjyOlWrBjjwyDyAmgtxyUM0Pr2up2I6ZwmlhUtfucny83v/pS1iY8lbTkpBE
         PfNvj9rd4iWsnf2dCnXQrDMi02MXgoRqZRN3aHE0yVXmr1OPxGlyM5NvXEG5LvMKfFoa
         x3IhzGZTT6F/Jnvd/xOEmgXMi0s5i3GaijWrQWLiJAEjgENjrvePZxp5FWek1gBhbENT
         ZwGVGpYRhzVDzAVc7T6KhhG6mKejAqCMx9SYNXIl4L48wGmI9gcQWv/BYLZtikt/86U4
         rzlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LNGLxw2KweTcYpa9QkuGXi/8Vq8kU4lq6/m0y6hK/fE=;
        b=fys8uFzO9tM/qJ8a8V+4W5wSPzSp2cWNEH1nsn1dSPs6fr3lkUa1AgYCzEJLSv2Erg
         kz1SK58plovtGAQMlhu6itxCQWgvYaougD9n4b5oMz9bS7FMO3BjclRaDGcJuJdp7FPA
         +tdAuIxwiw9UeXdH/p5YRtHq2dCqBgLCoRVQOyJNU9aMIVdFgqIRqJPV+71DfILpNB4T
         rP6YfJRGuSOW4i+1Scto/9k/7TCga4wuDiOBbuaOjRaCMaSN0pMSyxkytS4sKsudUaZE
         FP7b4PFctNqwHnrTR0HXorNRL3RqsiHE8MQQhMnrDs2XGQO4PhjoxVedpolPC26IBHNW
         9JZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fogrInpc;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor42263219qkk.145.2019.08.02.11.56.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 11:56:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fogrInpc;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LNGLxw2KweTcYpa9QkuGXi/8Vq8kU4lq6/m0y6hK/fE=;
        b=fogrInpcFGgIcmhYnky/AvbQZYcNngP+1NA9vPDvAgWGannmX09ril8r2t0m6Nwbft
         K5MBntXA2r9jHfX8pjMZi3i26BE93k7hIQrNguBwsdAymi9vBbJcyBqo/sx/2u1X/ocF
         lGHvHeCQB8ECPOIva3qKiFKVT8eTETQ8UKgkvKZgE2LgyA/Rb76xad1uMMFrxzKBevNz
         aE0q89Sx/MZ7Lls1mTv/sIlA6uhCbD5eQd5IONPxNJzTnO78Jc4wJ11ejOlDCtCj4Jum
         OHArxueuGJ7QZ8uKaxVGAW4487eIjLOS6nbsK7utF1UXM2Q3w3YWfP9h37W3pSnlydZh
         FJiA==
X-Google-Smtp-Source: APXvYqzYxCbc7dr941jU8as06MAJUPnoVZotdMadT7POHu58kTI4st9fGq6gaB6kR9fcMe5wuEPbkeh6/gNB7Q+65cM=
X-Received: by 2002:a37:7643:: with SMTP id r64mr89399970qkc.467.1564772202629;
 Fri, 02 Aug 2019 11:56:42 -0700 (PDT)
MIME-Version: 1.0
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz> <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz> <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
 <20190729184850.GH9330@dhcp22.suse.cz> <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
 <20190802093507.GF6461@dhcp22.suse.cz>
In-Reply-To: <20190802093507.GF6461@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Fri, 2 Aug 2019 11:56:28 -0700
Message-ID: <CAHbLzkrjh7KEvdfXackaVy8oW5CU=UaBucERffxcUorgq1vdoA@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 2, 2019 at 2:35 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 01-08-19 14:00:51, Yang Shi wrote:
> > On Mon, Jul 29, 2019 at 11:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Mon 29-07-19 10:28:43, Yang Shi wrote:
> > > [...]
> > > > I don't worry too much about scale since the scale issue is not unique
> > > > to background reclaim, direct reclaim may run into the same problem.
> > >
> > > Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
> > > You can have thousands of memcgs and I do not think we really do want
> > > to create one kswapd for each. Once we have a kswapd thread pool then we
> > > get into a tricky land where a determinism/fairness would be non trivial
> > > to achieve. Direct reclaim, on the other hand is bound by the workload
> > > itself.
> >
> > Yes, I agree thread pool would introduce more latency than dedicated
> > kswapd thread. But, it looks not that bad in our test. When memory
> > allocation is fast, even though dedicated kswapd thread can't catch
> > up. So, such background reclaim is best effort, not guaranteed.
> >
> > I don't quite get what you mean about fairness. Do you mean they may
> > spend excessive cpu time then cause other processes starvation? I
> > think this could be mitigated by properly organizing and setting
> > groups. But, I agree this is tricky.
>
> No, I meant that the cost of reclaiming a unit of charges (e.g.
> SWAP_CLUSTER_MAX) is not constant and depends on the state of the memory
> on LRUs. Therefore any thread pool mechanism would lead to unfair
> reclaim and non-deterministic behavior.

Yes, the cost depends on the state of pages, but I still don't quite
understand what does "unfair" refer to in this context. Do you mean
some cgroups may reclaim much more than others? Or the work may take
too long so it can't not serve other cgroups in time?

>
> I can imagine a middle ground where the background reclaim would have to
> be an opt-in feature and a dedicated kernel thread would be assigned to
> the particular memcg (hierarchy).

Yes, it is opt-in by defining a proper "water mark". As long as "water
mark" is defined (0, 100), the "kswapd" work would be queued once the
usage is greater than "water mark", then it would exit once the usage
is under "water mark". If "water mark" is 0, it will never queue any
background reclaim work.

We did use dedicated kernel thread for each cgroup, but it turns out
it is also tricky and error prone to manage the kernel thread,
workqueue sounds much more simple and less error prone.

> --
> Michal Hocko
> SUSE Labs

