Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58E91C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 049D2216B7
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:00:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="laFq03IX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 049D2216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A23F66B0003; Tue,  6 Aug 2019 07:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D42C6B0008; Tue,  6 Aug 2019 07:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8746C6B000A; Tue,  6 Aug 2019 07:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC6F6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:00:30 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id w5so48896534otg.0
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Lte5NgersUVcgVFcVHiVd6oPpWOW9UDRBaJvV3Xi/h4=;
        b=tSM/5No+PKfxZy+5LtLvMGMt3Ssb2u0K51WYlcXpmmg82SNEaz0cmRiqcXcaKQRj+h
         FQmOUq2i/yWNqYT0oIE+v5/flLDM0rJrHfkDg91c+ibJzI7dP2pJSx9VGYlvRVfBurWV
         QzqQIJjobFIs2LPLs/zBdQ93OWMSpUKj0t0+ZxiuDR72QiDJgRIYNJ3wKZCtsZ5y4NDJ
         ec7mDXBvOfmNbmdOLSS1FtXEC4gTPylv8l0gYiqRfN5mT1OpFST1RiC0z2XiOqSmqrEX
         K3S3U1yFhccMli+cocynCMJwKb0riqjxkvCBBYUfcU0Zh9ItvzHhzPcx8/GTzh8OzgeV
         dbEQ==
X-Gm-Message-State: APjAAAUfDRfb2MyCuCu1UGNG4llJJBGXPD6EWXXA8nIJQvyA2PywaLEQ
	uP7lRsEVvjVxg0BRVB0u1Zra39YG0T8gbDOh4KTp51StDZXKKC5w2fQc0Ub9++IehqfwasALXtd
	u1KzrzetKL0+/6zdIR38tdlQCrRLEEepAvcV3UkDM2/PLf+jjYTVZ1VxlQVZDbUlUUw==
X-Received: by 2002:a5d:9c12:: with SMTP id 18mr3025281ioe.48.1565089229856;
        Tue, 06 Aug 2019 04:00:29 -0700 (PDT)
X-Received: by 2002:a5d:9c12:: with SMTP id 18mr3025244ioe.48.1565089229245;
        Tue, 06 Aug 2019 04:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565089229; cv=none;
        d=google.com; s=arc-20160816;
        b=OyX18dRNxHfnR3iKhAAVNQZETNg5Rvr/u2Nd5XahzOQK57mKGF75c13gc9XUtRPsIv
         8fWyI74MCV4d2kUHXRyk9j5WHVIaTJLsOw1f+0RG0eBW70yn9wADl8XCmEjpveP4l62u
         9vjO95AYLe2ke3fXc0BS5QTKph55NnSBLTcimu15QS0PbX0K6joerRAldSjfqw7mpWR3
         4SNMp/Pjfia3HOLBu/yII39jGiZO4kaLNl2ZV+kgbTid/w+r8a/w9zzMcqtnzobvcKc2
         oGfEO4qJbFfcXjGKy/gtNLYlEtkQWKKCsMCWHnXWrdu4T4FfXgWd0myD60AdBKmi49kA
         MWNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Lte5NgersUVcgVFcVHiVd6oPpWOW9UDRBaJvV3Xi/h4=;
        b=JtG6NO8kHnYyrbuBtrDSDZN6zIyAkNmCKL3U3RKmVeYuGIvehGij/7eXOuIRCIz3U1
         wgkND1YkUEK2+q1yaoOGCPtip6pbyi5ZS3tXfInD3YxLZfLJQ/3HpBTgJ8OMSkap1t8N
         KSa+UU7m8VzWk7mKqPxb3Zh2m1dp3GNxIRv5oZJEOZAHNS7RRvpJPYlWx0ugoYP+9uTN
         abzf5fliUxSt1wwlsTZTWhfpwWYQjF9D8B0SPeRa6yCeKc5A2mp1XYcElIKtY60sWEvK
         Z3RuGV8jbM5S4O/B0ILhmFKkRanBOV1GWXFHoxuTXbz+AErQBUWMgAwjadWAa5lCorms
         i8Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=laFq03IX;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor60609533ion.88.2019.08.06.04.00.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:00:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=laFq03IX;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Lte5NgersUVcgVFcVHiVd6oPpWOW9UDRBaJvV3Xi/h4=;
        b=laFq03IXRElZmF/AxobuKenGZRYB5pqzImbXP1bBxCyyGWXDjGg2o70lxFYg1neC1m
         s2DKHHPMQTExZDwhogCt0LauMAXBhagrIW32mwa+BuOYPIacWt/PIQgnQHjko/paGmfu
         UA5QEJppOSWsa+qiHrgg2rVIdUhQSFByjflUohgaKd3X4wwGBRuwWc5Dw3CV4KE51l4O
         Uko5qoz09usr37cpZHTuUC7mTg1uR0gjPr5Fb3akEoSjLmLhL/0dkwFrImzcHwYPg8KH
         o7FCr5Kkwp02qY+/cm/ZVfs0Opypi/aEULhL/38VlaTFBoa6P4aluDob7GPA+bkfsGxU
         /Adg==
X-Google-Smtp-Source: APXvYqyFsZhA0IhViffXOZFqdLrMFCMf21DHnSf2mNgh8stQQdxvczDrKM6E8PyYl/BEQl5rfOWprt8vX0wPZo5bDUI=
X-Received: by 2002:a5e:8a46:: with SMTP id o6mr2798601iom.36.1565089228987;
 Tue, 06 Aug 2019 04:00:28 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz> <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz> <20190806095028.GG2739@techsingularity.net>
 <CALOAHbAwSevM9rpReKzJUhwoZrz_FdbBzSgRtkUfWe9BMGxWJA@mail.gmail.com> <20190806102845.GP11812@dhcp22.suse.cz>
In-Reply-To: <20190806102845.GP11812@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 18:59:52 +0800
Message-ID: <CALOAHbCJg4DqdgKpr8LWqc636ig=phCZWUduEmwYFUtw5gq=tw@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Christoph Lameter <cl@linux.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 6:28 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 17:54:02, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 5:50 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> > >
> > > On Tue, Aug 06, 2019 at 11:25:31AM +0200, Michal Hocko wrote:
> > > > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > [...]
> > > > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > > > >
> > > > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > > > get back to the original behavior by setting may_shrink_slab in that
> > > > > > path as well?
> > > > >
> > > > > You mean do it as the commit 0ff38490c836 did  before ?
> > > > > I haven't check in which commit the shrink_slab() is removed from
> > > >
> > > > What I've had in mind was essentially this:
> > > >
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index 7889f583ced9..8011288a80e2 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> > > >               .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> > > >               .may_swap = 1,
> > > >               .reclaim_idx = gfp_zone(gfp_mask),
> > > > +             .may_shrinkslab = 1;
> > > >       };
> > > >
> > > >       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > > >
> > > > shrink_node path already does shrink slab when the flag allows that. In
> > > > other words get us back to before 1c30844d2dfe because that has clearly
> > > > changed the long term node reclaim behavior just recently.
> > >
> > > I'd be fine with this change. It was not intentional to significantly
> > > change the behaviour of node reclaim in that patch.
> > >
> >
> > But if we do it like this, there will be bug in the knob vm.min_slab_ratio.
> > Right ?
>
> Yes, and the answer for that is a question why do we even care? Which
> real life workload does suffer from the of min_slab_ratio misbehavior.
> Also it is much more preferred to fix an obvious bug/omission which
> lack of may_shrinkslab in node reclaim seem to be than a larger rewrite
> with a harder to see changes.
>

Fixing the bug in min_slab_ratio doesn't  require much change, as it
just introduce a new bit in scan_control which doesn't require more
space
and a if-branch in shrink_node() which doesn't take much cpu cycles
neither, and it will not take much maintaince neither as no_pagecache
is 0 by default and then we don't need to worry about what if we
forget it.

> Really, I wouldn't be opposing normally but node_reclaim is an odd ball
> rarely used and changing its behavior based on some trivial testing
> doesn't sound very convincing to me.
>

Well.  I'm not insist if Andrew prefer your change.

Thanks
Yafang

