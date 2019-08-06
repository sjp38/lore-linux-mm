Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC97EC32751
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:05:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CE9420B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:05:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CE9420B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 380DC6B0006; Tue,  6 Aug 2019 03:05:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3097B6B0008; Tue,  6 Aug 2019 03:05:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D34B6B000A; Tue,  6 Aug 2019 03:05:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C154E6B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:05:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so53183818eds.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:05:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QNNpvMbhsCTXsIFvPRw2MAR0njF+UYn/YLDE7ZwwtO0=;
        b=uHbu00owtm+yEjnJt/tGHJY9HmG5/cHFi3uOfS/zXf7BbPHEYf3KLL9jjHE+Tz4SZ4
         U1jRt2IgcEiMAmw6+cQwzWjHif6ehx8aeG608V7ODgHlQZZFJnojtP7lnDtekZ2cXsn6
         gAEjO42rML5YxpqD9h7crRP0ILipjKcS2O5lynEtEPgWavep5SfrnsULTyCUDba4gQ7Q
         RdTjt1VhMfx6xDtWaCGKG7IGySxwpo0Jlj/cwjsTHUdtVVn1bylSggqJEP5GELO4DEzF
         zKBPa34dkkywecypj6BdVqnKWKUUnv7BCaE1ymiumQRfwelZwwFMvPuBXdJ5SgvQuO1U
         67bw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXRAXdcLYOLLcrUCprPMmQJbMD5TmaduzhdEITh7tXQagLPh3LL
	z04BQXbeauNx0Re6wONKwGyYWdLgRc1eik6/OhR6iDGfxo/+3E0P8czxqjy9RtKV/ZksUX6ggaJ
	U8f9uIdzbuch5YOf2ObIUZ8v73zAxgfpMxOq4ckF3cWNxAuX6OY7pC8htGB5YHec=
X-Received: by 2002:aa7:d30b:: with SMTP id p11mr2298045edq.23.1565075157346;
        Tue, 06 Aug 2019 00:05:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynVOcs5Vsxxzj1AogHWFO4Nd29vBdTPSf79p8ZanFDRstOBTFEuiN/YCYeLLFP78n/LfaS
X-Received: by 2002:aa7:d30b:: with SMTP id p11mr2297983edq.23.1565075156493;
        Tue, 06 Aug 2019 00:05:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565075156; cv=none;
        d=google.com; s=arc-20160816;
        b=ZysJ8UxjnWruqWijS1pWfnIarPcrnK5QTjgjwVJUZwNXNvFM6G45Y4O4YAlG2JHyqK
         Cg5I774UNnZ6RXqdQ3VSQSgwRn92vv4jFDIcDg6cRxlP11KZ4EumnWw30YLT/fyy/7mu
         m1ap4j5oN9h7UulbRUNb4YyZEvH3IbjPmcnUg13OSW2hG7NmewDD/29S0MPlcBh4LpYw
         8ijzNTEvJFl6PL98IA9EBLCyh1H9rrxubrVUlqdd2JkpE30CdHsanpz/tTwV4Nob1/AP
         N4gWHs8Odwq9wX7bwTXQSwMKKXMdWtaj82Lm2EvZyEhCI+0vWn79zkH9l/uAPVfdMMar
         LzfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QNNpvMbhsCTXsIFvPRw2MAR0njF+UYn/YLDE7ZwwtO0=;
        b=BCekbSjjdcdn3etB5HIVdaNrpYYvYkvAtzGyrekDC2WwAL6etnTdVYO2s26aIbEX/a
         03xG5+83dt/uKK4gGHsEJFn58T3rDko8EeYpDNgWfVIeS8uy+bPML+90lMo3LgLfiQlv
         fzk65t5p34nBaYzB/BajjRTQvkieVpp3mEx9KscZ0tSeyoa+gUAC1xqG5bvnT4NuGEN5
         AIho7MzFRXPO088VoB5xXxNIdT97yY0KTps1BgxBgLyEh26tCVotInEv6EYjYXgSAroR
         WUFa0Tm0cqd7G727Fc3HzQf5hv+4dpjpdpXGrU2+9Zi1YXvTD09oFqomGZdk3FuNrk3d
         0kRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m34si29990342edc.296.2019.08.06.00.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:05:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 048C9AE34;
	Tue,  6 Aug 2019 07:05:55 +0000 (UTC)
Date: Tue, 6 Aug 2019 09:05:54 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190806070554.GA11812@dhcp22.suse.cz>
References: <20190729091738.GF9330@dhcp22.suse.cz>
 <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz>
 <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
 <20190729184850.GH9330@dhcp22.suse.cz>
 <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
 <20190802093507.GF6461@dhcp22.suse.cz>
 <CAHbLzkrjh7KEvdfXackaVy8oW5CU=UaBucERffxcUorgq1vdoA@mail.gmail.com>
 <20190805143239.GS7597@dhcp22.suse.cz>
 <CAHbLzkpD+kawkR42mWpxvZHvSZNhYEsibiMYzx+3q0rTBS6L9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkpD+kawkR42mWpxvZHvSZNhYEsibiMYzx+3q0rTBS6L9g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 20:28:40, Yang Shi wrote:
> On Mon, Aug 5, 2019 at 7:32 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 02-08-19 11:56:28, Yang Shi wrote:
> > > On Fri, Aug 2, 2019 at 2:35 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Thu 01-08-19 14:00:51, Yang Shi wrote:
> > > > > On Mon, Jul 29, 2019 at 11:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Mon 29-07-19 10:28:43, Yang Shi wrote:
> > > > > > [...]
> > > > > > > I don't worry too much about scale since the scale issue is not unique
> > > > > > > to background reclaim, direct reclaim may run into the same problem.
> > > > > >
> > > > > > Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
> > > > > > You can have thousands of memcgs and I do not think we really do want
> > > > > > to create one kswapd for each. Once we have a kswapd thread pool then we
> > > > > > get into a tricky land where a determinism/fairness would be non trivial
> > > > > > to achieve. Direct reclaim, on the other hand is bound by the workload
> > > > > > itself.
> > > > >
> > > > > Yes, I agree thread pool would introduce more latency than dedicated
> > > > > kswapd thread. But, it looks not that bad in our test. When memory
> > > > > allocation is fast, even though dedicated kswapd thread can't catch
> > > > > up. So, such background reclaim is best effort, not guaranteed.
> > > > >
> > > > > I don't quite get what you mean about fairness. Do you mean they may
> > > > > spend excessive cpu time then cause other processes starvation? I
> > > > > think this could be mitigated by properly organizing and setting
> > > > > groups. But, I agree this is tricky.
> > > >
> > > > No, I meant that the cost of reclaiming a unit of charges (e.g.
> > > > SWAP_CLUSTER_MAX) is not constant and depends on the state of the memory
> > > > on LRUs. Therefore any thread pool mechanism would lead to unfair
> > > > reclaim and non-deterministic behavior.
> > >
> > > Yes, the cost depends on the state of pages, but I still don't quite
> > > understand what does "unfair" refer to in this context. Do you mean
> > > some cgroups may reclaim much more than others?
> >
> > > Or the work may take too long so it can't not serve other cgroups in time?
> >
> > exactly.
> 
> Actually, I'm not very concerned by this. In our design each memcg has
> its dedicated work (memcg->wmark_work), so the reclaim work for
> different memcgs could be run in parallel since they are *different*
> work in fact although they run the same function. And, We could queue
> them to a dedicated unbound workqueue which may have maximum 512 or
> scale with nr cpus active works. Although the system may have
> thousands of online memcgs, I'm supposed it should be rare to have all
> of them trigger reclaim at the same time.

I do believe that it might work for your particular usecase but I do not
think this is robust enough for the upstream kernel, I am afraid.

As I've said I am open to discuss an opt-in per memcg pro-active reclaim
(a kernel thread that belongs to the memcg) but it has to be a dedicated
worker bound by all the cgroup resource restrictions.

-- 
Michal Hocko
SUSE Labs

