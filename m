Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DF26C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:38:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 669382075C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:38:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 669382075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03F548E0003; Tue, 12 Mar 2019 09:38:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F31218E0002; Tue, 12 Mar 2019 09:38:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E492C8E0003; Tue, 12 Mar 2019 09:38:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0688E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:38:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j5so1101008edt.17
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:38:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QmDFKBE+xLlrM0c7pAqRwIGfEpJzAy6/UODZOWHAE+E=;
        b=rFqLXM/tkcAvptxNb6/fR+FDD+sLqd/cesQagfQBpoHgD+ezsYQ+p4SbOctag9Hovg
         TTPUKm/vLQwvGi8m5BUadkuAL6uWFTWzjEwUPya1UX5OqAP3yEvm5N/beyKAHf242SNl
         mIOsfHiNJSq8q4RVabLMr+ZsBroQILrxCde8MQI+MvuiwHFC7RKpHfjpSVbMKWM9K6WR
         V0nfn0UhnD+jOGY9Y9DcypLAkOd9f+aDd/Ano+MnW6D/7xYS8IZtvakhlCnrDOqmF5Rl
         2U0NHFSkTu6GzeB9nixa/D9uGqse+8eGYMOBZ9NSqbZdSKjyO/cmB3o0E2L2f23IyvrX
         iZxA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUQi89eT8d7Miri4dFX3jRCEKjWcPe2H9sD04i+L0JFqACf6P5D
	0xLZoCHKNpd9vhbSu3TmQwe+uqB1NNUSCrXvPP0ThqPxZVqGFfJkUQhiyI20oTXjfW+3LivLc0u
	apbjI4aE+agihwr6YBVOmwDaXdluW6T/+TI45X2GOyPl3/64Y0e5KmMRS+vVRlmo=
X-Received: by 2002:aa7:c70a:: with SMTP id i10mr3552184edq.280.1552397899174;
        Tue, 12 Mar 2019 06:38:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyk9DkQK5uMmONBbbh+LNbE1rIcqSBsg5fVr/KYOHbgDvL8o3FM1kfzdO2z3+ExGT2/eUdK
X-Received: by 2002:aa7:c70a:: with SMTP id i10mr3552132edq.280.1552397898180;
        Tue, 12 Mar 2019 06:38:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552397898; cv=none;
        d=google.com; s=arc-20160816;
        b=pll4Xo1KyItLDwH644Y4W/VIMgJXkivTbNydAydkeT5ECEa/NqiVc8LFmr9+NF7ZnG
         xbwDM3sfrs+Bj47gB8/YEntBhlIo73Ew7fAvQprpdV6rlQK49A7o7N8KQw95pYi9Mrc2
         1XXfBjcTmkpb0k9UHmvGIU5MizIyMm3wd1c47taLwKBumw/TR719ZT+Ep4XFqfsM/8Mb
         IlX3G6wINPjzZ8HxZ3dFoEdH5kS39jSUu4JjJ98eY1Lzm06hVGjetdGk5r7SUQQHNz6Q
         XkN7AmTxVJIBWNCfBOV/+orK4Z6YRREDJuu9zaZqfF5oKOcHXnkN+Krk3XrPjjDVWzzz
         vaSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QmDFKBE+xLlrM0c7pAqRwIGfEpJzAy6/UODZOWHAE+E=;
        b=fD18EQTrKuAWuk8RTNZTPxcnaPBSYz0fhMti9rFZLCWWuPkGYjsD9LFq5pJu+lghJK
         MH9F1ADL+Rd7bOq76c7cb64E3sYERmIPCr6+9XDLGLX6KVyJhXRYZt/4FStAqUO1zwIv
         Gw2rGOSTZR7ohyWkRH3EOuLhW6zWJ8bSvbztmgUD+zozPSZg64r/I70389TpFXN5DGsI
         U0jVId9Brzs/glHc6/xZtCHzk7Ydh5f788ZIi9Ov1wQKmup6YNycop/yjL/OUzk0vJC8
         +/D0upGmi2PHRxGJWy481ZRP/sjUVIU4WriXjoYEml7zHqwmuj+U3+NmLxyzVsNYLGY6
         uR1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25si363349ejt.245.2019.03.12.06.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 06:38:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A54D5ABCF;
	Tue, 12 Mar 2019 13:38:17 +0000 (UTC)
Date: Tue, 12 Mar 2019 14:38:16 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: vmscan: show zone type in kswapd tracepoints
Message-ID: <20190312133816.GR5721@dhcp22.suse.cz>
References: <1551425934-28068-1-git-send-email-laoar.shao@gmail.com>
 <20190311084743.GX5232@dhcp22.suse.cz>
 <CALOAHbDHM1mJ3X9x3vFpDagd81T+hrb7_xdqM12x6JQXuHqwxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbDHM1mJ3X9x3vFpDagd81T+hrb7_xdqM12x6JQXuHqwxA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 19:04:43, Yafang Shao wrote:
> On Mon, Mar 11, 2019 at 4:47 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 01-03-19 15:38:54, Yafang Shao wrote:
> > > If we want to know the zone type, we have to check whether
> > > CONFIG_ZONE_DMA, CONFIG_ZONE_DMA32 and CONFIG_HIGHMEM are set or not,
> > > that's not so convenient.
> > >
> > > We'd better show the zone type directly.
> >
> > I do agree that zone number is quite PITA to process in general but do
> > we really need this information in the first place? Why do we even care?
> >
> 
> Sometimes we want to know this event occurs in which zone, then we can
> get the information of this zone,
> for example via /proc/zoneinfo.
> It could give us more information for debugging.

Could you be more specific please?

> > Zones are an MM internal implementation details and the more we export
> > to the userspace the more we are going to argue about breaking userspace
> > when touching them. So I would rather not export that information unless
> > it is terribly useful.
> >
> 
> I 'm not sure whether zone type is  terribly useful or not, but the
> 'zid' is useless at all.
> 
> I don't agree that Zones are MM internal.
> We can get the zone type in many ways, for example /proc/zoneinfo.
> 
> If we show this event occurs in which zone, we'd better show the zone type,
> or we should drop this 'zid'.

Yes, I am suggesting the later. If somebody really needs it then I would
like to see a _specific_ usecase. Then we can add the proper name.
-- 
Michal Hocko
SUSE Labs

