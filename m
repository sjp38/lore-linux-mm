Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A649C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C3F120651
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:54:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nBma88nj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C3F120651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 944006B0003; Tue,  6 Aug 2019 05:54:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F45D6B0266; Tue,  6 Aug 2019 05:54:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80B0D6B0269; Tue,  6 Aug 2019 05:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 564A36B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:54:39 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id a198so34274194oii.15
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:54:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=E2nYpRWoZfi17mqK++Pz2Kq39+1vUJ/P0pqzl9qRd5g=;
        b=c43L9ZvVOJiqDNXquZ14BPjC4Vh6tEiE4Qnyai9Jv8ZdCuCOSkO/GW582QkYoJE3bp
         vIq3qP4Op2y/Snfiug5ITI1jkOmoEh58YefNBwCL5y4NrlGF+SjTbWNmZHtq0j3cahRv
         CFGtCrzpzfRTt+ar0XJIKUb1lRPOMjyTFBJLCSNuI8Lq0tAxQ7l7KWMQwKNNvu7L/FZc
         sCKyExm3t8HfuaKSWC0K0+jgiFf2BPmUkzl65xE7hd8QHyxz3n3+L1QEl8MYuG9fY6Kb
         OL533NFBA7wbRDvSjkX7H+Xb64hvw/VHUQV4/c7p6ZZEB6Be08VpYm5chOqYlCJJxuqs
         BgwA==
X-Gm-Message-State: APjAAAUwmT3OutzlkEBXqloxr7gWAsHefVELrIJ+bOqsjt+/37J8vMdX
	TXJM9vbzTkvg/xpceqX0OMMGokMFbNXlEY9T6jEKucJmg7YaNQqAxxRqnPqCc54qAPKq+VGFRKr
	eG6bjHXSEibB8dt+/OxKp599acPYRMxKzBYeQPpTe8sOEceIJ4VghKNmfVt/6HkqtLA==
X-Received: by 2002:a5e:8210:: with SMTP id l16mr2749009iom.240.1565085279042;
        Tue, 06 Aug 2019 02:54:39 -0700 (PDT)
X-Received: by 2002:a5e:8210:: with SMTP id l16mr2748983iom.240.1565085278529;
        Tue, 06 Aug 2019 02:54:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565085278; cv=none;
        d=google.com; s=arc-20160816;
        b=cpRQ3k78wNZiuDQnO9aN+F8tF1nIShG08WVfAaYP60lmNro9fHLbpS3+YhBp0VAbNS
         ykIP08K+cxG4ukfeA2nc5Ek3f/a4gDqYh14+6cSysPYGK5mzTO3TlVfVOWJ661CgM5S0
         H3jk4j17nxaTKYUsyZnKeqG6rRAbjtrYB4CGbSfu8NZmh2oxuf1kLuFx80W3ilPOE6hP
         uuLI5Hxb8V8bL2g5OHdh6dyoAR0/ik15JgoxDIBTOu2gNlCvQqkAunnFC5K5ZDJyx/h6
         WG+mCDS9VxZWKJfyzpK/Frh5kBEfkONpJcPALAaHAgKnuE81YYJkjePh27BIm4wgHEHV
         JEPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=E2nYpRWoZfi17mqK++Pz2Kq39+1vUJ/P0pqzl9qRd5g=;
        b=yyMte5GCC/qZ8t7JPBYdk6m3XwdeExC6TOIalI0KYjE3BaUK7zJkgmDWVNTV1Ldm6d
         YroXByKVEy+HUFZMdz3l9/frmHveeW/ImOyMS/4mJQt1REocXcYjLJn0opR3yS3ctsrF
         ptYiWIKVcA5C85RfE23uF00p4HcKtuanvDPIzOFgBlHbGVHE6sWx2TL8ei+Glj8orz4U
         h3hy+Ntxg8HPbBNFICYbETEaXI4LxTY2krZqcGhfd7kaKBYrjfyZ80mmb6YgcGXtd3LP
         S0l36ux2JED9lGOQKThSJuheaRQ2paYD1OUjoyQHFHVoExlQsS5I7s8xjpPzVkcXps9K
         0pfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nBma88nj;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor57129026iot.14.2019.08.06.02.54.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 02:54:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nBma88nj;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=E2nYpRWoZfi17mqK++Pz2Kq39+1vUJ/P0pqzl9qRd5g=;
        b=nBma88njB6OybqqwcqJkPwygntHaXFdQ+zIDHkzf2mCdxIYaY2ExO6nSl6XhU+064z
         YNgMtkmE0JYGA5ozgc+tC6UctFjb3qA99sNvIrDpmFhuCq1sSTQ0IJtMHExCU2YBwZ5Q
         MzSxA3OP1gu842ChmzZXqZXgFaYXidfttKxO3htiGypHr/oN/wlt0tYGwOhlNXIUC6zR
         HSVX6MElbfTISE8E7Vw7RXshKFARJmoSjnrrGIH/mcoYUL5JseSKwjPRFn6jpp42u6o6
         dop1Hfq422Kcex9dY+9JMKOgha3sFCZMhLQ4pAUNH9fapcAFVUMrZYGcDCSRvsA75gt4
         QYpQ==
X-Google-Smtp-Source: APXvYqxFPD4kjdyDGkjTZ93eUZaH5mTBC6Bpyqi9iFvwnsDI7cC3P5ra+IEXOdobaLRvhm3FVTylyZTUc3B1bogeFic=
X-Received: by 2002:a5d:8702:: with SMTP id u2mr2812865iom.228.1565085278311;
 Tue, 06 Aug 2019 02:54:38 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz> <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz> <20190806095028.GG2739@techsingularity.net>
In-Reply-To: <20190806095028.GG2739@techsingularity.net>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 17:54:02 +0800
Message-ID: <CALOAHbAwSevM9rpReKzJUhwoZrz_FdbBzSgRtkUfWe9BMGxWJA@mail.gmail.com>
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

On Tue, Aug 6, 2019 at 5:50 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> On Tue, Aug 06, 2019 at 11:25:31AM +0200, Michal Hocko wrote:
> > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > >
> > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > get back to the original behavior by setting may_shrink_slab in that
> > > > path as well?
> > >
> > > You mean do it as the commit 0ff38490c836 did  before ?
> > > I haven't check in which commit the shrink_slab() is removed from
> >
> > What I've had in mind was essentially this:
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 7889f583ced9..8011288a80e2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >               .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> >               .may_swap = 1,
> >               .reclaim_idx = gfp_zone(gfp_mask),
> > +             .may_shrinkslab = 1;
> >       };
> >
> >       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> >
> > shrink_node path already does shrink slab when the flag allows that. In
> > other words get us back to before 1c30844d2dfe because that has clearly
> > changed the long term node reclaim behavior just recently.
>
> I'd be fine with this change. It was not intentional to significantly
> change the behaviour of node reclaim in that patch.
>

But if we do it like this, there will be bug in the knob vm.min_slab_ratio.
Right ?

Thanks
Yafang

