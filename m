Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3D5AC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:33:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90DFB20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:33:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZLr0lrZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90DFB20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 201136B0281; Tue,  6 Aug 2019 05:33:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18C066B0282; Tue,  6 Aug 2019 05:33:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 052626B0283; Tue,  6 Aug 2019 05:33:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC7E06B0281
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:33:31 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a17so48670011otd.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:33:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ne/CvbOnBLgfS9/yNTYOkRPiZmiUfD2bjxFIFlqe8wA=;
        b=FkZTPKXmmY9gzS+U0P5uojXy8niqhq2UcmGF16TSE63FtNlOtNV758WEarZcA+DljO
         unN6bZc7T5Ip7JZ+KZoF06BrupUneQmGXTxC9AMduDvkpfQ3YHrCuCvoo3IrNWboJpAd
         i8LiEiDiIxzvD9oHhswtohoefX74+ABpDYgvD0sBtbLcQfhLAPPhjTJOpKl7WWyI/QaV
         XikVZIwemcIDOASDJyusN0KbMRbQ5kTWOglXglIdpJ60iLpjhqCjWNZG6ZJ6lbOdrKMQ
         FsfHPy49Ji1ww4Wijbr0x4b1Z2HLEIpw+liONkw2ZqWCA8C3wyLLjVPMXbhuTh0PNjgM
         NIgg==
X-Gm-Message-State: APjAAAWC6p6LOo8uO4RdJbr2iL5L28j1DZJX0oRGgqdfgcZtwnjcRNOh
	GgPDHkt+6fzjboqrteS8FI/O2k3BL797mE8SEUy9dlwEwTB1QZ4VMJr3Zss+ihnL5fEzaXZoVJG
	3njrgo3BueckQ+s6lpmZmNUMoCc9aH4lsftSlbQx3vNMJ2APeg0RFt1MOBSQ/1r7+Kg==
X-Received: by 2002:a6b:7d49:: with SMTP id d9mr2657798ioq.50.1565084011570;
        Tue, 06 Aug 2019 02:33:31 -0700 (PDT)
X-Received: by 2002:a6b:7d49:: with SMTP id d9mr2657744ioq.50.1565084010745;
        Tue, 06 Aug 2019 02:33:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565084010; cv=none;
        d=google.com; s=arc-20160816;
        b=Ic21lk8ApRQ8vW6NFqu3D+xkW+D74isIyFloNwXjJwjbI38ooN/R91Hw+sm406l3oX
         beOmdYCMjW0PA+NO84oQSKHZzlmqwnukgW95Fy5uEWxjBfUJoFusopv9gRkxkSaAO2h0
         4q+UWbuBV7mvNqJt/AHw1Ssk99ng5wbg436yKW6NhtnnJ9zcMGp3OQY8q7PyxuSedvB2
         KTzKt/qSLjzxPttK8QgTrbIBWee7t204gSFwX8eMwQCziOye+dGv7dLQRLKOHEwyw2QI
         bsfy2JrZ6Fja9jEzCLp8RCI4UNlsTX7UxbuCi9dF9OlyDMZbTxf77If7ygsGvMAJ4wfF
         Zk+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ne/CvbOnBLgfS9/yNTYOkRPiZmiUfD2bjxFIFlqe8wA=;
        b=Q0WyBLPfhNfWZlxk3oukK8Qlr4TDCoZoJzBAP/sGsPqtGAYfxXT+XN9XkxnhSHAXVx
         BMxlsMw9c9uvEW5atA32CJoREHv5kKp+natIEoqBLdUQ4f1eJTPyVPs5a5Dc9UAosnXS
         Sa0aMvXhZ51mU48t6n0EJlvFVuP1x7FsarvCPtLNe9SSqj8+Fcp834DtuxBrPEXB9GyI
         0HYayOPY4s3MwAz1I2xowwyJicuY2zo6dUT1g3eVZRHgSIicEL61//YDvw9Fhrb/kHqJ
         n0Tzb4i3R/SJIbDFnZUTBeFskbAWDkd5IYfimuxAxckIRDMgpzjB8NMSu7g/ZgOKJazU
         Tnmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZLr0lrZo;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26sor64279011jaf.1.2019.08.06.02.33.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 02:33:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZLr0lrZo;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ne/CvbOnBLgfS9/yNTYOkRPiZmiUfD2bjxFIFlqe8wA=;
        b=ZLr0lrZoRDnWCAW7vuJlaS1M16eS6AP3Eqf/ON/ftkGlK62IgTSOJANaaQnABKI8hV
         GNOQnaWB1Xp+Cazi58qXpCa5JisbwWoW9YmPHD91Ckmaab1W7tH2nuRvBLD2zIHZu7e3
         caU3P4b9tTExn6sfiYX/AG8WOwPiR5tN09GLCc9d4QLb28++RFzg4E2AY65q2N41+4/T
         eFBdVmLBMiM8xKlaqo4swE4/0TCGi+pnjZ/Zu3Y4sPK+z8kbNIj9Rzh5xKIUzcwy1R9b
         LJ1KcKEFq80pyVBc8Kw2SOtV6/R/aI32mjJM+opYSzv9gULoNt10xc4Z1qoQd6v84uBv
         r5cg==
X-Google-Smtp-Source: APXvYqx3T9wRQ5ZAh3QMlR+IMwtLMVjPEa9eTZ2g3iOAdondtGN5zwQNW6hoYWiYVoK4l4hmUCFE3TbrUaWkZO6sZg0=
X-Received: by 2002:a02:1a86:: with SMTP id 128mr3193268jai.95.1565084010515;
 Tue, 06 Aug 2019 02:33:30 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz> <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
In-Reply-To: <20190806092531.GN11812@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 17:32:54 +0800
Message-ID: <CALOAHbAzRC9m8bw8ounK5GF2Ss-yxvzAvRw10HNj-Y78iEx2Qg@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Daniel Jordan <daniel.m.jordan@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Christoph Lameter <cl@linux.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 5:25 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > > As you said, the direct reclaim path set it to 1, but the
> > > > __node_reclaim() forgot to process may_shrink_slab.
> > >
> > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > get back to the original behavior by setting may_shrink_slab in that
> > > path as well?
> >
> > You mean do it as the commit 0ff38490c836 did  before ?
> > I haven't check in which commit the shrink_slab() is removed from
>
> What I've had in mind was essentially this:
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7889f583ced9..8011288a80e2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>                 .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
>                 .may_swap = 1,
>                 .reclaim_idx = gfp_zone(gfp_mask),
> +               .may_shrinkslab = 1;
>         };
>
>         trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
>
> shrink_node path already does shrink slab when the flag allows that. In
> other words get us back to before 1c30844d2dfe because that has clearly
> changed the long term node reclaim behavior just recently.
> --

If we do it like this, then vm.min_slab_ratio will not take effect if
there're enough relcaimable page cache.
Seems there're bugs in the original behavior as well.

Thanks
Yafang

