Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01894C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:10:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDF8720818
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:10:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDF8720818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5448C6B0003; Thu, 11 Apr 2019 11:10:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CB186B0005; Thu, 11 Apr 2019 11:10:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 393AC6B000E; Thu, 11 Apr 2019 11:10:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD2F06B0003
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:10:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 41so3285650edr.19
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:10:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZQN5UuZwjZUo319JRK6GMshEdkEs0+6Ov1fNMjkTmG4=;
        b=NA0HBGfWq5oI/lVc5lwUhNzC2kw0BWwzOppWTHhGkPwuttQG7RM9kuspo5F2H5nM0C
         xQPMFLQfOxa2OzWACHobD/jHpGxACB1zcrHY0EIQwpwwxa6jWA/nHXqs38cV1RNUTODV
         ZsWJV2o+/rzcEXT1D73CE8rmjbOuHnVmPD5puFA67rlRHexnjFynKfvJUQBRJ0qxyvNm
         zYckepUDdussj3B1CIIR9X1NoTiI++GR7ZG+/DtM6Vkg1YDwNGx8wUSMdn1fR53hnieW
         xBW+52pg2Z6LVgVxCC15p/x/JACDMnxifAPXXSOP1K4+fF3d2FNZAsZCFaONZwilBpPT
         AMTQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUohYSDOPk3g5uHE7Xco0aT3szrH3hs2Ce9Hep1gJguNeMAvjbS
	Mt+U01CnajNk3K6SUzjfEn8NDmyF6bDfs2OI8d84CKvXq9oAvLka8AbvgR3eUTY91+fFTzIXifM
	6L1ooMADlNp0c+cdVAIx5Jv9gqjA9vFnE+CzMMMGbVI2AENSy2StEpfaQ2bvGcH4=
X-Received: by 2002:a50:b618:: with SMTP id b24mr32195969ede.9.1554995442462;
        Thu, 11 Apr 2019 08:10:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJZ2tA/du7U3T+5H1AnJBdwMyoUcsysYETAz81csUFisU1hl0/CuXzDTPPy5J71L21+/7q
X-Received: by 2002:a50:b618:: with SMTP id b24mr32195909ede.9.1554995441686;
        Thu, 11 Apr 2019 08:10:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554995441; cv=none;
        d=google.com; s=arc-20160816;
        b=SpMR5xkJiNQNDLm9hrClkIsNqqJKcLpkg3V/n232WNzTxPgWyC1nujaUfKsuwZBAZp
         sGOg7Vp+qAhRFi2PzhCk3FmmlKwkur5ADPJZoOWpNWLvQSM3/LX0sdZwX9zWe5pR0LF9
         meYP/bl6fTQNAaHJPVcs4LGpOFlooteudAbZU7zREfDDruhOKRf2L9M+gn6sP2IM7y9P
         RTY42Hf8ZThtUxkVJiTJLV0oo97Kb9DXxHUwJGAQkqr4GRKtNHJ2e3yQgRqlbnd1DEjU
         cOCTXC9gH7xFk5iMUiSmU9Kwz2GIwHw8xL5FeDVU/v7FoVQCCVCOguTe2AuQlNuljHf7
         DvSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZQN5UuZwjZUo319JRK6GMshEdkEs0+6Ov1fNMjkTmG4=;
        b=BuxjXU0s0M0SSvzZiAmoWT8t0b+8y5H3njPSbqXHquPuH5nom3Grb6JAUSmT2G+7XT
         ywg3au0z/idfgjv+Pq2uyv6NCK0TCrSXe+1epwMRJA/vmTsX5+uUPEUUGTo6y/PKX2Qz
         U8AozJ6ZeQtc3Lig8i9toK8R7sHSuQVNPkmQ7kDBPXctaEmvBcm5wANkUUDBn2lhieb9
         so0XhCXWnjdWlIHgoemHvTcaIHpL8a71Egv+AwhjMjuXYVuKNN9gG3QTXAVK7hc1nfTN
         Y4qUedmrrsR8fCceY6daPna58yP+Zp3XUefNCbnqMWze4irouZIvHguvceKRiiOXShTB
         WFqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si4239849edf.59.2019.04.11.08.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 08:10:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D3DA9B65A;
	Thu, 11 Apr 2019 15:10:40 +0000 (UTC)
Date: Thu, 11 Apr 2019 17:10:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
Message-ID: <20190411151039.GY10383@dhcp22.suse.cz>
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz>
 <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz>
 <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 21:54:22, Yafang Shao wrote:
> On Thu, Apr 11, 2019 at 9:39 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> > > On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > > > The current item 'pgscan' is for pages in the memcg,
> > > > > which indicates how many pages owned by this memcg are scanned.
> > > > > While these pages may not scanned by the taskes in this memcg, even for
> > > > > PGSCAN_DIRECT.
> > > > >
> > > > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > > > under memory pressure or not.
> > > > > So this new item allocstall is added into memory.stat.
> > > >
> > > > We do have memcg events for that purpose and those can even tell whether
> > > > the pressure is a result of high or hard limit. Why is this not
> > > > sufficient?
> > > >
> > >
> > > The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> > > memcg neither.
> > > They all reflect the memory status of a memcg, rather than tasks
> > > activity in this memcg.
> >
> > I do not follow. Can you give me an example when does this matter? I
> 
> For example, the tasks in this memcg may encounter direct page reclaim
> due to system memory pressure,
> meaning it is stalling in page alloc slow path.
> At the same time, maybe there's no memory pressure in this memcg, I
> mean, it could succussfully charge memcg.

And that is exactly what those events aim for. They are measuring
_where_ the memory pressure comes from.

Can you please try to explain what do you want to achieve again?
-- 
Michal Hocko
SUSE Labs

