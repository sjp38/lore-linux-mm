Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F3C4C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 06:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3397920643
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 06:34:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3397920643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96BE26B0005; Fri, 12 Apr 2019 02:34:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91CB46B000A; Fri, 12 Apr 2019 02:34:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80CE96B000C; Fri, 12 Apr 2019 02:34:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33B6F6B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:34:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h22so3028240edh.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 23:34:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BFF9UjgncrSMB2s0VVNx5QE68aR3aSdM3dRD1d+GqnQ=;
        b=LHaUp7tuiZJakQtvwV35pbJlZKNTBTZW9YmXq6hSLXEYKinV7iCVJ3vs3JVXJfXElz
         VI5iMNttbsRH13ZBpa9KC3sZJbts4+iiHPpBwGZF3HbiWKA1h+Xk92ob+Yo0nxirIqLN
         Gz5iKIDWb3yMpX9tU5F4/yBWvHpOLlUyHKEpCHwfX994cV0gnrYSAU8FcO/96U9iHfS3
         ax72qEiETdn44XtvBafV1m8gHD5tw669iMp6ZaE8rKKFuN4XTa1dOBqsfSDFEheKsKrE
         7ELbRcoIHSXWLjKKDRo3Pnvg290qO6VojiZgsxS+3AO+S53gSddPLdrAsgyK5aoYZbtX
         LNfQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWtLml263t+LvwRNjxdY6QvwaCN7oZfgK1XrguInSHvoWbOJEtB
	knemAJs2U1Xu+T8TaLPUgNCMxw2OVuC68/EgjIx1bZMypXCik9uhBTXRPd2JDNS3TmHEubQe6jB
	xEHH9MUwrXjwva9geK3NhwgxTEuBC5kvsh6y32Kk0/Kad4HdVcdWfSqlNySW1gBk=
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr8844296ejb.5.1555050860642;
        Thu, 11 Apr 2019 23:34:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQchHb/pCQ5QBmLZx3BXwJsB+s1sOdwvTeTCuCbo6fwEBEMK2lkzyM71IDg0LOrbhk4ovd
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr8844245ejb.5.1555050859389;
        Thu, 11 Apr 2019 23:34:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555050859; cv=none;
        d=google.com; s=arc-20160816;
        b=vwj5FXwyyUbBNYJtJK0MI2LZmYjMfeurew9wbkbTTa+W0pJGJYvsQ0AQgAbx9hNzE/
         jONYI/cSU0M7XrofQURsZErTNj7U1iFGLpiA0L9rm3nEC5EdjORv+ngMx+Fhaw2Vi4BX
         oCIZRY+IktAzHNORrPOMTyNpb48jJoGnwzvO2hdCjKjCuzvXMoBwG3b/pG0apZyeeFEE
         I6GayZkorEA5VqmV9HAtUnarwSwGnXismS+XV54rxdHds8+X6d7hIA/IfORkGHBaU2OR
         k/i/RdaCGXxZ8bQMMYlF8LoolVPUPQlFFLtdMAZK1+rresKCvBcvrPHSd9JmS2Xy/8C4
         kVFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BFF9UjgncrSMB2s0VVNx5QE68aR3aSdM3dRD1d+GqnQ=;
        b=PGdvV6AvxG0OG5bASvVC3nLppnFrqvyl0iALs4yoI0QY/oJVtCOPgI91bUe7BtvITP
         /H2G6yc69ildfDkragPu5zoadNZcguqtlqoRwKZTScUh37E/9m+njmFCiezqbFElL7Il
         ZJGEkLdgxxi7/02+xvg3KmP4vrtQuMDOxo2TyBbbnd/kgtvxxeyYcj8DpkK4aIIV3lJ1
         ROfszaaY1aSAdGij9uYvdhVyTgFSzHgtQFZ0EBc0GLLqfwA0A6y6MQfzYjvM+jDPsPHj
         AhoBJ8qavApRHmd/jxVjNgVE7Lm1cLp8BDSFVJyLm77OfCjYprH1sSqakLLJu4sdWWJd
         3/qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a22si268835edt.230.2019.04.11.23.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 23:34:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56C92ACBA;
	Fri, 12 Apr 2019 06:34:18 +0000 (UTC)
Date: Fri, 12 Apr 2019 08:34:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
Message-ID: <20190412063417.GA13373@dhcp22.suse.cz>
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz>
 <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz>
 <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
 <20190411151039.GY10383@dhcp22.suse.cz>
 <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-04-19 09:32:55, Yafang Shao wrote:
> On Thu, Apr 11, 2019 at 11:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 11-04-19 21:54:22, Yafang Shao wrote:
> > > On Thu, Apr 11, 2019 at 9:39 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> > > > > On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > > > > > The current item 'pgscan' is for pages in the memcg,
> > > > > > > which indicates how many pages owned by this memcg are scanned.
> > > > > > > While these pages may not scanned by the taskes in this memcg, even for
> > > > > > > PGSCAN_DIRECT.
> > > > > > >
> > > > > > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > > > > > under memory pressure or not.
> > > > > > > So this new item allocstall is added into memory.stat.
> > > > > >
> > > > > > We do have memcg events for that purpose and those can even tell whether
> > > > > > the pressure is a result of high or hard limit. Why is this not
> > > > > > sufficient?
> > > > > >
> > > > >
> > > > > The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> > > > > memcg neither.
> > > > > They all reflect the memory status of a memcg, rather than tasks
> > > > > activity in this memcg.
> > > >
> > > > I do not follow. Can you give me an example when does this matter? I
> > >
> > > For example, the tasks in this memcg may encounter direct page reclaim
> > > due to system memory pressure,
> > > meaning it is stalling in page alloc slow path.
> > > At the same time, maybe there's no memory pressure in this memcg, I
> > > mean, it could succussfully charge memcg.
> >
> > And that is exactly what those events aim for. They are measuring
> > _where_ the memory pressure comes from.
> >
> > Can you please try to explain what do you want to achieve again?
> 
> To know the impact of this memory pressure.
> The current events can tell us the source of this pressure, but can't
> tell us the impact of this pressure.

Can you give me a more specific example how you are going to use this
counter in a real life please?
-- 
Michal Hocko
SUSE Labs

