Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86DF0C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 19:54:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 361C82133F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 19:54:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 361C82133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A85496B0005; Fri,  5 Jul 2019 15:54:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A373B8E0003; Fri,  5 Jul 2019 15:54:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FF008E0001; Fri,  5 Jul 2019 15:54:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB126B0005
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 15:54:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so6000608ede.0
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 12:54:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ye0jSKBw5fBEDLkJONy0PqwWKbwuDwy6BtS2vl1KTSc=;
        b=oPn8SMvy5fNix1FAZJnqYk73zc32SPNnahjqghDjsirXgqO4S89xIiK5h9KPdE9dcd
         8ZOmt5I7KT62XVycU64nO+TOrW/JPyfGD7viWtk1EGHEyYLwcsmqQ7GFkEKoTWvNX7v8
         C/PhGrWFMnz+VT3KXtavhlQmWBTW7RZEkOQYElQacDEyiMaO6tMrdfu+RC8dqVC9fzfq
         sNqB+em6u8o6xp3ldsxUSGihNk/jUgg8DY60mImJYGlFUirSyUVYb/YmZEKqp4S7moPC
         Mfnz2GawMtUMAcTlAR46pGkAuQEITGom+CTEw7+g9rJQflLzNKZhWPUt1u8lPQAkmv9+
         sgTQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUqEAsU21SFBYJHu55gs5+6gN+Ihrx/kWrbLjluecusy0PghvV1
	ncb1afBZQOw+bVIcq3F27er0Hyin7I45esH9H3XmNX8Q1tY3hTYxIQRu6jrxWV50jWe9K3/MPr4
	WgpNXM5VcTEv2eXFUU2QA6JIRBUKEUiF9pMfI0MoJkL+XvcLkhoQmPuriF1Bw9R0=
X-Received: by 2002:aa7:d985:: with SMTP id u5mr6388539eds.222.1562356462670;
        Fri, 05 Jul 2019 12:54:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzb+4x93/AE7rZFiLFSG+T+Cu/vrCpEWnKkg0/Ou0f3Xr8C2zm6h0ZIz2kkQMsbbjpJHw5a
X-Received: by 2002:aa7:d985:: with SMTP id u5mr6388474eds.222.1562356461676;
        Fri, 05 Jul 2019 12:54:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562356461; cv=none;
        d=google.com; s=arc-20160816;
        b=U4yYP/WP6HnxOy3wQswxXozgHjWTtL4jEbwxrgRBj0BCiPekE2e89f1V5aYXAn+Ee9
         OD9TY3Tp6e9Q9IYv3CmC++FRdfT4Hc/XEx7HAcAe5R9NeA4qnWHH+HsXnxDrlaj2xT9o
         5lln2XNnNAswAugapJ2AXbXdXlLMYXLIvdevEbUswHrP3TSMtXLgqWeO+Sd7EvX19Abe
         VlaG/CFMzaVxNOcr51pBz/WsZC94U7g10/k5wUSENkW+lYWPEftFBGBXGQTUPM4xlCST
         AGJG2X7ufQjDrtsRxSB34PT9HWNrvtZeNEIsqjw82kBQJBw/j/rQyPHjLxJhztMCNBWX
         zxTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ye0jSKBw5fBEDLkJONy0PqwWKbwuDwy6BtS2vl1KTSc=;
        b=1IBF3QvW3fzBZVvalDf00onC99LF54F/gAVwq9436NuZrQyLmgqkOWn+/0/yobTr9J
         JJwkne01Mtm2cdxZkYXKGbEC3ZJ9SXEUqQ2OqufJYAH6sXXu4g8Ejc+LWqA4Bz1WEZrQ
         QTX5no5pA95zVQBKWp1Frgo5/YYDk7fty5eAWA4Xh2Cdu6NtBYo0cjylbZLZGNVRNOXP
         +LQWJiYc8MXjoSuj0YKdU3WbnlJdxgDNmokfLGuiJe3Tao8lF1n83SXWKD41uBIoCx4O
         bQVZMjv2/6Z+oEizbGPqQ34rrO8T7b2obRaP1dxTmKZmYjbuQGsy1iCJMRwPESoIK9+I
         auhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si3848276eda.130.2019.07.05.12.54.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 12:54:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7F17BAFBD;
	Fri,  5 Jul 2019 19:54:20 +0000 (UTC)
Date: Fri, 5 Jul 2019 21:54:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190705195419.GM8231@dhcp22.suse.cz>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz>
 <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705111043.GJ8231@dhcp22.suse.cz>
 <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 05-07-19 22:33:04, Yafang Shao wrote:
> On Fri, Jul 5, 2019 at 7:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> > > On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> > > > Why cannot you move over to v2 and have to stick with v1?
> > > Because the interfaces between cgroup v1 and cgroup v2 are changed too
> > > much, which is unacceptable by our customer.
> >
> > Could you be more specific about obstacles with respect to interfaces
> > please?
> >
> 
> Lots of applications will be changed.
> Kubernetes, Docker and some other applications which are using cgroup v1,
> that will be a trouble, because they are not maintained by us.

Do they actually have to change or they can simply use v2? I mean, how
many of them really do rely on having tasks in intermediate nodes or
rely on per-thread cgroups? Those should be the most visibile changes in
the interface except for control files naming. If it is purely about the
naming then it should be quite trivial to update, no?

Brian has already answered the xfs part I believe. I am not really
familiar with that topic so I cannot comment anyway.

> Do you know which companies  besides facebook are using cgroup v2  in
> their product enviroment?

I do not really know who those users are but it has been made a wider
decision that v2 is going to be a rework of a new interface and the the
v1 will be preserved and maintain for ever for backward compatibility.
If there are usecases which cannot use v2 because of some fundamental
reasons then we really want to hear about those. And if v2 really is not
usable we can think of adding features to v1 of course.
-- 
Michal Hocko
SUSE Labs

