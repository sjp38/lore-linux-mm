Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CA0AC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:32:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9282216B7
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:32:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9282216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690A76B0007; Mon,  5 Aug 2019 10:32:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640A46B0008; Mon,  5 Aug 2019 10:32:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52FF86B000A; Mon,  5 Aug 2019 10:32:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 039A76B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 10:32:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so51737611edc.6
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 07:32:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YaY4oukR15527mA8aWZhxDWIRhXe7wuB926WEDPC7JY=;
        b=SGakxXE3jc7vT1/oD+Bcp7CMzeOH/PrxE5ttMaYNK2Sqw4Q30fjsP293sV2JGu2rek
         4/sAaXaCr3ut1usN8NhwchUY+rGvyuXyzrIAxfmEIYkFaiw2Us/yAQnDF6eDs25MBznc
         7ZTTe402yhvI+JdzOODMpItsu2xCQ4YuG2k/kSFDJKx9TxSsrrqE5cb7sPEFk8M9G5w3
         4TgCVuw4t6Z5Wl0d/G/zwIk8KO4i+ZzyK0zgv2yTpbymi6o5HD/W3dood8Lfl/GXqL1r
         mA598evukp6fxZ+gwwDlqgxuJva0gb8WfOmMW6D3+5ccnkoD125ryqa5L5txkeVLwtTq
         Ugzw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUN2Zm8zHk0Clyt537z11Pu060EM6Yq4vsz9Fgkq/krAro59+JT
	gV9o81YQfV7QyE9pxi5B2owjh9YITOXfvLHnbl0gb+vMttozS+Z333Izbzc9H0SboBYrXUBwpP6
	rC3o5/ZVhbe34JcrVkWiKMvGJX8IVdc+By1+pfwT/ePKmap3sA6DinaQvPqiTcCE=
X-Received: by 2002:a05:6402:2cb:: with SMTP id b11mr131949427edx.281.1565015562575;
        Mon, 05 Aug 2019 07:32:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+jmW1Rb0ZiczsRLPATiBgJjPeuhhNoffSKHEbPWsOhxdixsfu+1QNOZFIU2A/CTvNjE/g
X-Received: by 2002:a05:6402:2cb:: with SMTP id b11mr131949325edx.281.1565015561498;
        Mon, 05 Aug 2019 07:32:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565015561; cv=none;
        d=google.com; s=arc-20160816;
        b=gb/AoJ1RqDBEGkUwqHZQTqtfYcGkePNS05GRFUNQ5pU1ukQn8h00wRXro/Qu7zCeYv
         cRF2GJVKkPpmGRTfkUOP8/juXbzWNmmlPArBYBAMDwWS2E03ai9pkchOX5xyLBKVagLz
         cQ11yiTxRQK8jMW7SX9X821dwCVwaJjHH3HDnQIrYgpEB0ipFR6BzUyz2cjaeZRlDOnB
         8FJ7lE2DyNEMVlHXnGclINbG7JNlsYodD182oNElaiB8gO6OA07LfaPiU4PQdLPMMuRZ
         QQ9eeyW7CXSYx1R45KXwvBVuPP780yp8fNkhOUSgKpx/sewwnG0r920dYih/XbJwtevj
         svwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YaY4oukR15527mA8aWZhxDWIRhXe7wuB926WEDPC7JY=;
        b=XOlj3r7nMiT68sePoZeD8ETGZYwt5ghsDXoSEl0AjPrbv1T57ugUBmGUXch+j2xDFC
         15vlDQ4M8fWC0gk4LjGWAB3lHfTdJ5TMfYpFO/WGcm2816f7Jgsgy8kehr9il814jWv3
         D2yyKFVjp/iXY7UJj95TDPhrbOdXedxday97T1+xfl4uJeF9x5+VAYFLC+PO4ywMqTpy
         r92uC6cNly70wBG/G4TNIws8NOi43CY8KZ+unGbdsPPE9V4eoSeUNXjHgXfrRoVDzZot
         gmNPiqDQsDivFeoB3M14UWiTVpcZP9v/SPI3QwP7kLhqfx9HRngtu9JsLWUL8vbgq8Jr
         kZ9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c15si30899877edc.361.2019.08.05.07.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 07:32:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F2405AF3E;
	Mon,  5 Aug 2019 14:32:40 +0000 (UTC)
Date: Mon, 5 Aug 2019 16:32:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190805143239.GS7597@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz>
 <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz>
 <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
 <20190729184850.GH9330@dhcp22.suse.cz>
 <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
 <20190802093507.GF6461@dhcp22.suse.cz>
 <CAHbLzkrjh7KEvdfXackaVy8oW5CU=UaBucERffxcUorgq1vdoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkrjh7KEvdfXackaVy8oW5CU=UaBucERffxcUorgq1vdoA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 11:56:28, Yang Shi wrote:
> On Fri, Aug 2, 2019 at 2:35 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 01-08-19 14:00:51, Yang Shi wrote:
> > > On Mon, Jul 29, 2019 at 11:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Mon 29-07-19 10:28:43, Yang Shi wrote:
> > > > [...]
> > > > > I don't worry too much about scale since the scale issue is not unique
> > > > > to background reclaim, direct reclaim may run into the same problem.
> > > >
> > > > Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
> > > > You can have thousands of memcgs and I do not think we really do want
> > > > to create one kswapd for each. Once we have a kswapd thread pool then we
> > > > get into a tricky land where a determinism/fairness would be non trivial
> > > > to achieve. Direct reclaim, on the other hand is bound by the workload
> > > > itself.
> > >
> > > Yes, I agree thread pool would introduce more latency than dedicated
> > > kswapd thread. But, it looks not that bad in our test. When memory
> > > allocation is fast, even though dedicated kswapd thread can't catch
> > > up. So, such background reclaim is best effort, not guaranteed.
> > >
> > > I don't quite get what you mean about fairness. Do you mean they may
> > > spend excessive cpu time then cause other processes starvation? I
> > > think this could be mitigated by properly organizing and setting
> > > groups. But, I agree this is tricky.
> >
> > No, I meant that the cost of reclaiming a unit of charges (e.g.
> > SWAP_CLUSTER_MAX) is not constant and depends on the state of the memory
> > on LRUs. Therefore any thread pool mechanism would lead to unfair
> > reclaim and non-deterministic behavior.
> 
> Yes, the cost depends on the state of pages, but I still don't quite
> understand what does "unfair" refer to in this context. Do you mean
> some cgroups may reclaim much more than others?

> Or the work may take too long so it can't not serve other cgroups in time?

exactly.
-- 
Michal Hocko
SUSE Labs

