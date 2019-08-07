Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B1DDC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:03:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE38C21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:03:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P0vLbZ2o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE38C21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 279546B0003; Tue,  6 Aug 2019 21:03:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22A616B0006; Tue,  6 Aug 2019 21:03:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F2136B0007; Tue,  6 Aug 2019 21:03:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D87266B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:03:45 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n19so51414430ota.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:03:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o7q9Ldtb0xrmlDmXW0fcFFYVPswO62v529sdZO8NY2c=;
        b=mMis4+qadzWBwM3TzI77/Wh19uJu04yb/ZLxvJj0JD3ur7ZyJ1Y+dztVKMQEAd0zQb
         jDyoWfKFi2ymp/0Zdu/WqAyAaoWkvLeMn4TrxfsKdik+Bitow6kCqpu1aCK80EEWp0ld
         U+75Id5IZK1bkb9oh4KtUCEModZ2qhghHSjtzSonbVG5RB2ecXLM7OD2MgfTOK+1sJlt
         ohvq4NEZON5/J8sSDmC8K8/K6FglhaNtst2JnZV8P3tp/fUYR1qNYo2oettF5aZ8z0S/
         zeNKtZmH6NoUaT8qA/65nsP+P9Lfj7aQig18GZVGRU1D9YabqUjQS6vTpeczRty/VfPm
         U9aQ==
X-Gm-Message-State: APjAAAUBHdvfIMc9/a3ecstBZs8JiAl09Fp8HGnINPBJPFSWRQ4Ou3xr
	BmvOllIyolWZfpApW6liKojbQjYhFQFC5MAUOMtx91XcQUdTgXnFcRN9weTCraT/KNqwguTvUYJ
	338bSBSeZI1+AOvvEiqaM0JvUr3cI6d8D/vUd2uG0OWeIEbJAjl4LgoA2ucRg+J5RZw==
X-Received: by 2002:a6b:fb0f:: with SMTP id h15mr6891810iog.266.1565139825616;
        Tue, 06 Aug 2019 18:03:45 -0700 (PDT)
X-Received: by 2002:a6b:fb0f:: with SMTP id h15mr6891772iog.266.1565139825011;
        Tue, 06 Aug 2019 18:03:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565139825; cv=none;
        d=google.com; s=arc-20160816;
        b=ujTdkkRCH/6HxJT3maXDRkHIHkUbPKED52aVCdD+Z5ecHcEx6Smp6pXZaTfEEaiEZr
         ia6b1nxmqIEIjADXgW5dNhiYoDrHSoF2n+XSFDchFHIb1JGpDXNKwEyQM/+MK16AMeIH
         1YyHlhhIWhBR1SRXD900ND/hi0KUoL5woAusxKp+oMcLcRewOtuo+9Xvuc5w5Mj6UVGw
         dxjRqDuI3SksvTUyk5paJUGxqtP22I3XWfRGOVcqQG7ylh95r7yTrpy2r8e3QhL/lJye
         QbFDPTUdCfT1KB2GqaqrcPlBWUmtoqXS6gDA4+UJgUssgAVe8Ve0jVEYzghbpTYG5Qfr
         769w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o7q9Ldtb0xrmlDmXW0fcFFYVPswO62v529sdZO8NY2c=;
        b=fBWJK3Oc5Gi1Zh4EI3bpEwNAN7fGX6vYyDUwqJd63bors+kP0o8V5xW9MbKM01Q4RE
         q1J4p2jvWn5eVvjVk6/9Ys5fBtzeVx01SJO3uOLrTYiTel108bs40Kuh0w6bHyb4T16C
         plvi4B1eGJ0tfrlIbebED+sbcPxHK6PAKpQec8166c0BQ8f5AqLMLD/6ynf9+0R9V4QN
         xB74MBp0aezqJVVmvddSZjncqd8BhL40/tUwNm3vjTY9A817yllcDl4X94Nz/qb4jHiD
         ++EPuLd8vBglEWQ/uiN9tZOvgYb+FnVMxmq0KZxA1gXEmMEB+y4LshTevyqh+CaeEl8O
         lr7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P0vLbZ2o;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor56074000jai.10.2019.08.06.18.03.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:03:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P0vLbZ2o;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o7q9Ldtb0xrmlDmXW0fcFFYVPswO62v529sdZO8NY2c=;
        b=P0vLbZ2o8+YLbFgZTjg+azBmoH2Q3WXZ/ZsQF/jNf3Vv/yA10iUdEjF9PYyfE4d3j5
         j5GsCufeDTIvBNIdnKkcQgmGXjWdGDHpVwPkFRkGgRwWmRZxYvrhBtMNC+x6/iFe8FIZ
         03JlUr6knh+OttbLxby9y/8t+USxSTbmXEWT35lQStcHe63Icr8gzKRGs95d6hIoyWnH
         ro+plkdrae+HNaJGkKJdBMsXrvwKzpcxDtcIioaw1UY3Uo0l9oX+R7QAiy8tdMtB68+D
         z1xqJ4CNDe5YBFJTY9V7CDUUoCFAg0NEVizsq48vgzjVDtPpOebxOQVtOzDr3YAVm1gW
         HsYw==
X-Google-Smtp-Source: APXvYqzUm/MfzCeqAeImu38R/S9t7BBxWojU2TR11JcHGZLjTFjwFAN0OpE8zqy6wcQCeI4Mq7nTtprUXFW+TAWnwqU=
X-Received: by 2002:a05:6638:81:: with SMTP id v1mr7203634jao.72.1565139824762;
 Tue, 06 Aug 2019 18:03:44 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz> <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz> <CALOAHbAzRC9m8bw8ounK5GF2Ss-yxvzAvRw10HNj-Y78iEx2Qg@mail.gmail.com>
 <20190806111459.GH2739@techsingularity.net> <CALOAHbCxBdGtTo9SneNtnDKWDNEZ-TcisE9OM9OagkfSuB8WTQ@mail.gmail.com>
 <20190806155904.rwd7tmbbpmif4edh@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20190806155904.rwd7tmbbpmif4edh@ca-dmjordan1.us.oracle.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 7 Aug 2019 09:03:08 +0800
Message-ID: <CALOAHbBPSJx4ZmsEDt6LfbVSPW1CfYTrbQvGas_SDWVd_v0wEw@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Christoph Lameter <cl@linux.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 11:59 PM Daniel Jordan
<daniel.m.jordan@oracle.com> wrote:
>
> On Tue, Aug 06, 2019 at 07:35:29PM +0800, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 7:15 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> > >
> > > On Tue, Aug 06, 2019 at 05:32:54PM +0800, Yafang Shao wrote:
> > > > On Tue, Aug 6, 2019 at 5:25 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > > > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > [...]
> > > > > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > > > > >
> > > > > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > > > > get back to the original behavior by setting may_shrink_slab in that
> > > > > > > path as well?
> > > > > >
> > > > > > You mean do it as the commit 0ff38490c836 did  before ?
> > > > > > I haven't check in which commit the shrink_slab() is removed from
> > > > >
> > > > > What I've had in mind was essentially this:
> > > > >
> > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > index 7889f583ced9..8011288a80e2 100644
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > > > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> > > > >                 .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> > > > >                 .may_swap = 1,
> > > > >                 .reclaim_idx = gfp_zone(gfp_mask),
> > > > > +               .may_shrinkslab = 1;
> > > > >         };
> > > > >
> > > > >         trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > > > >
> > > > > shrink_node path already does shrink slab when the flag allows that. In
> > > > > other words get us back to before 1c30844d2dfe because that has clearly
> > > > > changed the long term node reclaim behavior just recently.
> > > > > --
> > > >
> > > > If we do it like this, then vm.min_slab_ratio will not take effect if
> > > > there're enough relcaimable page cache.
> > > > Seems there're bugs in the original behavior as well.
> > > >
> > >
> > > Typically that would be done as a separate patch with a standalone
> > > justification for it. The first patch should simply restore expected
> > > behaviour with a Fixes: tag noting that the change in behaviour was
> > > unintentional.
> > >
> >
> > Sure, I will do it.
>
> Do you plan to send the second patch?  If not I think we should at least update
> the documentation for the admittedly obscure vm.min_slab_ratio to reflect its
> effect on node reclaim, which is currently none.

I don't have a explicit plan when to post the second patch because I'm
not sure when it will be ready.
If your workload depends on vm.min_slab_ratio, you could post a fix
for it if you would like to. I will appreciate it.

I don't think it is a good idea to document it, because this is not a
limitation, while it is really a issue.

Thanks
Yafang

