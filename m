Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E21D0C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:36:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9842C2089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:36:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HFLpYnHK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9842C2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48A6E6B0010; Tue,  6 Aug 2019 07:36:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 413D06B0266; Tue,  6 Aug 2019 07:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DC876B0269; Tue,  6 Aug 2019 07:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0069C6B0010
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:36:07 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q22so48983496otl.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:36:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5tZJDELsqz39FZhOvV0SDhYEOYZmBHyKh9I/Mpg3gfY=;
        b=Dx7yNno5b4zJYfLnzYzDp7zBjH8/U1StWZchfVN2ryrFGDySKLaXfeNT3qE/WW6Aib
         6QdalvHnMAF6KGsZlkwwqUY+eWoUa1CHbMmPpv7dTGh3oxVdJvjI50fg3Cl7pkbiWEes
         5rBDTkvH/TJYBy4IFU0jgrUk9b5X4arOc5ARqTO6oVetAlzkacZYdXvcEhrYRB71peuY
         qLao7YS2eKG+ES9AO1nzPRRHyfk52y5CJvp5ZIpa1oJ0d37y++uKe1wJFQK7c8oWezSc
         4vpAVOI3SKWPd7N6GalEZtd3TkwLaJyXyXvzYEFJu/pmyd9LmYsnF05jSjAd/SKhBuWd
         cAOA==
X-Gm-Message-State: APjAAAWHNC8nMWpCgvGVLCMqe34ohcOXGHVLzb1FiaH8XujIJ5+TK8PU
	I7lpqne4mgAcjB9AvnlGFzHPUf9g9EXUID2xZwsVtTemDkRNmC+1mtgotpolsJYQ9rVNjjd8xj4
	v/MBlMkiSe8dWgI1h9pgDhPIjXDp9+hE6eekmgDT9Felz0aZ6OsAYgYlXKneAMHWrBQ==
X-Received: by 2002:a02:9991:: with SMTP id a17mr3665608jal.1.1565091366689;
        Tue, 06 Aug 2019 04:36:06 -0700 (PDT)
X-Received: by 2002:a02:9991:: with SMTP id a17mr3665555jal.1.1565091365962;
        Tue, 06 Aug 2019 04:36:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565091365; cv=none;
        d=google.com; s=arc-20160816;
        b=tFshpSGMB2KGW8zmZmyfUsv2U5IBUV5wBs06aPLKuv/lvGt6NDnNzvFeuEAB9Bw9oU
         6A/ex8+Hq7FsGnlJyYc3cwTtBvHVW4KtAx+TDX0dDNnFoioCTD6E8I3wMtBM9KEfgwSq
         0NRkY7VWD9OY3BZ68LAEHtzbf2zMXTmi3a+UY1kdM5V/1KnV/nO2KZwPNNezK3SIfdZ9
         hhAkuKINz84Igse5byblicKaF4cC0mKh9eTMfzVXWPi8uJ5cCUg4JQ9EuWWK1YTdZ1La
         s3wWKtBPzDbStVevKwh6SHxMfXzpXjw5DjaH7exkGjs00RYUvq6bckes5Y8LFFVQ4l6X
         9Y5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5tZJDELsqz39FZhOvV0SDhYEOYZmBHyKh9I/Mpg3gfY=;
        b=FUyjYvU4xZsDpoqk6AHdvDgR/TrGeoD76VfR2RZg+EeTBKhdjwL9e/p7X4NP5Cuyqq
         GgC/oTtmFEBdqrQVu2httNjVYFZV++ct7FLygMTX8/zl/UdH1mJoYufDSrU3ESdAEeN1
         EboPCHJdJsipHElH33GuaOXeE/HCi3UnAXP3Egi8SNa7iPv1edMotPujH8dJlOMMAI9B
         ZocBeP89fOUTMNVSDLkYovpiCrTt/ofgolJQp8vyokB2SnOkFjNszMnMZSaNGdDPOYJV
         pr+AUcS88f0vPXtxLdEuoj41vxFUX4U1coIaw+eKE3NHz4g0z0W6anTiQz4CydWfZcLP
         ykMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HFLpYnHK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 131sor52227864jac.14.2019.08.06.04.36.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:36:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HFLpYnHK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5tZJDELsqz39FZhOvV0SDhYEOYZmBHyKh9I/Mpg3gfY=;
        b=HFLpYnHKLLKiwlD9DhK3qF/D5vQiZJOzKRB4y8QjNyh3DSMpRBQARbmMsxLWcgYMF6
         ghwximNCXxpTw1WoQ5S5h19O8kz3vGoP8mhwIs54maSXq0NieE5TNI33/VBN2D5iFy7X
         s0C+N1FEbp++mjRrVcBWlWtzLBY4hvF/CpltSXK8YV9dySU6lCXvP2weOvNRY3lUIXVQ
         fkbrIQwpjPVJ3TZSDV4YY+z49WiLQnKiiQ8XEXFBIe4I9YpWve+nERqWHDv2Tui3jxXv
         zCJ8Uhp+W3h+66gloPnIxedk8kTSfgH0SKyHrcEvPI75hQEIISVS/L3lIrIP5JyuireR
         vXBQ==
X-Google-Smtp-Source: APXvYqwA8uPjEPAtYtzTRMqCqgOtRSQ94OHN0JFqhWFVqqVDFVEkG4jrwZGmfoZvwHKZOkvzh9g5Ij7GkQ6/TXHboE4=
X-Received: by 2002:a02:230a:: with SMTP id u10mr3627660jau.117.1565091365740;
 Tue, 06 Aug 2019 04:36:05 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz> <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz> <CALOAHbAzRC9m8bw8ounK5GF2Ss-yxvzAvRw10HNj-Y78iEx2Qg@mail.gmail.com>
 <20190806111459.GH2739@techsingularity.net>
In-Reply-To: <20190806111459.GH2739@techsingularity.net>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 19:35:29 +0800
Message-ID: <CALOAHbCxBdGtTo9SneNtnDKWDNEZ-TcisE9OM9OagkfSuB8WTQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Christoph Lameter <cl@linux.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 7:15 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> On Tue, Aug 06, 2019 at 05:32:54PM +0800, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 5:25 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > [...]
> > > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > > >
> > > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > > get back to the original behavior by setting may_shrink_slab in that
> > > > > path as well?
> > > >
> > > > You mean do it as the commit 0ff38490c836 did  before ?
> > > > I haven't check in which commit the shrink_slab() is removed from
> > >
> > > What I've had in mind was essentially this:
> > >
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 7889f583ced9..8011288a80e2 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> > >                 .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> > >                 .may_swap = 1,
> > >                 .reclaim_idx = gfp_zone(gfp_mask),
> > > +               .may_shrinkslab = 1;
> > >         };
> > >
> > >         trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > >
> > > shrink_node path already does shrink slab when the flag allows that. In
> > > other words get us back to before 1c30844d2dfe because that has clearly
> > > changed the long term node reclaim behavior just recently.
> > > --
> >
> > If we do it like this, then vm.min_slab_ratio will not take effect if
> > there're enough relcaimable page cache.
> > Seems there're bugs in the original behavior as well.
> >
>
> Typically that would be done as a separate patch with a standalone
> justification for it. The first patch should simply restore expected
> behaviour with a Fixes: tag noting that the change in behaviour was
> unintentional.
>

Sure, I will do it.

Thanks
Yafang

