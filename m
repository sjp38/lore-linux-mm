Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17110C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFD0A2089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:35:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n0OHWqXe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFD0A2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D9F76B000D; Tue,  6 Aug 2019 07:35:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 489D16B000E; Tue,  6 Aug 2019 07:35:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 351456B0010; Tue,  6 Aug 2019 07:35:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9D56B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:35:18 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id i16so34528642oie.1
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:35:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=g7uMPvg5GtFcBZDsCTSW0/ygIwWmVJGwGpp1PepWeI4=;
        b=p3cOnD8+Zmkh8buIC2a6k3s8+fIuhtOxGEvJMuOIuFd9SWcPwsL5AKdCHwuYTdA9ah
         y39TQNQg93eUW2QOeoii9QTwC8tdx1wnpK/fnb4heVVLA8JMxdCrO//XFJkQp9wTScv2
         5KuwfQpN3rpoiPHN0tFvQvvUZJC6ITPWeqHGV1xjcfQPYvg4HWI5uHa8BbqZkduW9lCI
         RlQij3JWNlxxqhVFcpkkaf+amuHbl+Md1bL4m16pYv+JnVGZy1/Pg3uaHI/xBRYgpF2U
         T5QKG3AYMN5DCMTLvDqYm7BeumkoCrCmpySgB7PkBhACMF21btBFoX06B6cicl3+Mnwm
         KraQ==
X-Gm-Message-State: APjAAAW180L5GLXRYdvxRPZ4bnk1UlRV8ljzxqOcz7wAO4MnZJISXzRq
	EzXuP2c0jrmLjmn1Rio7RfKl0MHeNxlNq33ErBBRp3ZlL4VmYuSiGLWXeQ8agDbRsioZvLcOKXD
	ivCYfbn4dDN4OSwCoAN/oDcqX2YAVNKRr72l3XAQEfpMfxJeRDHauzWl0uRzU0L29fg==
X-Received: by 2002:a6b:6516:: with SMTP id z22mr3025653iob.7.1565091317688;
        Tue, 06 Aug 2019 04:35:17 -0700 (PDT)
X-Received: by 2002:a6b:6516:: with SMTP id z22mr3025613iob.7.1565091316988;
        Tue, 06 Aug 2019 04:35:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565091316; cv=none;
        d=google.com; s=arc-20160816;
        b=Fswhwp/654iUDoVqJIc1bqV5b75a58V7ckAqBi/NUDs0FRhoz6gqygyjPwzTsHapPb
         Hei+VWxfgbKN5QgrVK+rlz0zthyiy/JNV5PGaepUXWppKh/Hj8ezH3BFJyOK3bXAU5fJ
         F0V/ajM6rU22fwvh59Gw2pltUaJTT+quNUcAQlDR8N/5iLuwS7Hfty4u8G2HFm3XZVim
         CGaIIEX4Fjd3V7DoS4tVUnI3plAayQ6RBN1n6DYmbGrMtv0WEGSFafivS9y2Vig8RpP6
         w5Cf1JbHA0WppQKgcblIVJMLzxljePtglWgpUR2PCumimpZO+ha2fsLzoUD9B0BDQI0l
         v80w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=g7uMPvg5GtFcBZDsCTSW0/ygIwWmVJGwGpp1PepWeI4=;
        b=DYFNKd2n39WUyPkUE9uwI55mMZXmSId2fTSQWE9AudO47KTjp4Xe1wq8ZwaD7lK02L
         Ucjy/tb8vQNa0dtj/m8wHn+hrYv0QvfqmpMks5aHtzbb466WSjNXxoJ5wTYEiN2jgrRd
         RzqkFF+pctx/cydlawHKeqg5bM8ldCJwgL8lVSazbKm8howuVONdT0fD6nMXeyQE1Oco
         4uaIKi9ibWXoLtlCa9a+6qtDFoqg9Y+9fc4CWYzbWvaBTKqYKf1aiu0U1p4tTtPFJcS8
         NMUJEdCQDllTHDIf2hnSiq25Ksy67Tr1p/ReA/Ee99iWrTdUADM//nHbIuSVdYTcGUoQ
         4IAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n0OHWqXe;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor58405345ioo.94.2019.08.06.04.35.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:35:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n0OHWqXe;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=g7uMPvg5GtFcBZDsCTSW0/ygIwWmVJGwGpp1PepWeI4=;
        b=n0OHWqXe49WvcDNicMYxwO6SWqdhG/Vd3p4sUn09wrnxG3voAqnyJTXIFWCugmHlMV
         PSNkUsM0wZ4CmivauF84zcvdRSUkp8/d+7EHpid8JSvH+ctMXBqoF8AL7V3tfZjnYd3g
         7z/bHV4zdN5AijM7KOyvgTp3zzDZ/59O6ppby3M8FOGX/SkRzxMB9yg+LcnUixyPAAkT
         pNYJ+ynNrLH3JX4zQaRao85jyR2p0Jbul0bWs3vmCExJJnHZhczVMQmTCbcRqxk+6ScF
         o7gSwwuD7pWxQzaAwgjgqqIBzVl23VVEAg+3WvXt1R8/QYRA7jWQb90uGD2aUA4UCZsR
         NH1A==
X-Google-Smtp-Source: APXvYqwrUa6Oi+X8F0H0Stxcr3/U+LJMZpjTMuRxm492IxbAhmYPiTDZlVVq2uCbUCKoLEB5RfyGtZGwd4X+hrd4hI4=
X-Received: by 2002:a5d:8702:: with SMTP id u2mr3212395iom.228.1565091316701;
 Tue, 06 Aug 2019 04:35:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190806073525.GC11812@dhcp22.suse.cz> <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz> <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz> <20190806095028.GG2739@techsingularity.net>
 <CALOAHbAwSevM9rpReKzJUhwoZrz_FdbBzSgRtkUfWe9BMGxWJA@mail.gmail.com>
 <20190806102845.GP11812@dhcp22.suse.cz> <CALOAHbCJg4DqdgKpr8LWqc636ig=phCZWUduEmwYFUtw5gq=tw@mail.gmail.com>
 <20190806110905.GU11812@dhcp22.suse.cz>
In-Reply-To: <20190806110905.GU11812@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 19:34:40 +0800
Message-ID: <CALOAHbAjN=bfCAc-TTBQazqg9GhiwQf2S5varJ2L=KaS-dVb+w@mail.gmail.com>
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

On Tue, Aug 6, 2019 at 7:09 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 18:59:52, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 6:28 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 06-08-19 17:54:02, Yafang Shao wrote:
> > > > On Tue, Aug 6, 2019 at 5:50 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> > > > >
> > > > > On Tue, Aug 06, 2019 at 11:25:31AM +0200, Michal Hocko wrote:
> > > > > > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > > > > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > [...]
> > > > > > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > > > > > >
> > > > > > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > > > > > get back to the original behavior by setting may_shrink_slab in that
> > > > > > > > path as well?
> > > > > > >
> > > > > > > You mean do it as the commit 0ff38490c836 did  before ?
> > > > > > > I haven't check in which commit the shrink_slab() is removed from
> > > > > >
> > > > > > What I've had in mind was essentially this:
> > > > > >
> > > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > > index 7889f583ced9..8011288a80e2 100644
> > > > > > --- a/mm/vmscan.c
> > > > > > +++ b/mm/vmscan.c
> > > > > > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> > > > > >               .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> > > > > >               .may_swap = 1,
> > > > > >               .reclaim_idx = gfp_zone(gfp_mask),
> > > > > > +             .may_shrinkslab = 1;
> > > > > >       };
> > > > > >
> > > > > >       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > > > > >
> > > > > > shrink_node path already does shrink slab when the flag allows that. In
> > > > > > other words get us back to before 1c30844d2dfe because that has clearly
> > > > > > changed the long term node reclaim behavior just recently.
> > > > >
> > > > > I'd be fine with this change. It was not intentional to significantly
> > > > > change the behaviour of node reclaim in that patch.
> > > > >
> > > >
> > > > But if we do it like this, there will be bug in the knob vm.min_slab_ratio.
> > > > Right ?
> > >
> > > Yes, and the answer for that is a question why do we even care? Which
> > > real life workload does suffer from the of min_slab_ratio misbehavior.
> > > Also it is much more preferred to fix an obvious bug/omission which
> > > lack of may_shrinkslab in node reclaim seem to be than a larger rewrite
> > > with a harder to see changes.
> > >
> >
> > Fixing the bug in min_slab_ratio doesn't  require much change, as it
> > just introduce a new bit in scan_control which doesn't require more
> > space
> > and a if-branch in shrink_node() which doesn't take much cpu cycles
> > neither, and it will not take much maintaince neither as no_pagecache
> > is 0 by default and then we don't need to worry about what if we
> > forget it.
>
> You are still missing my point, I am afraid. I am not saying your change
> is wrong or complex. I am saying that there is an established behavior
> (even when wrong) that node-reclaim dependent loads might depend on.
> Your testing doesn't really suggest you have done much testing beyond
> the targeted one which is quite artificial to say the least.
>
> Maybe there are workloads which do depend on proper min_slab_ratio
> behavior but it would be much more preferable to hear from them rather
> than change the behavior based on the code inspection and a
> microbenchmark.
>
> Is my thinking more clear now?
>

Thanks for your clarification.
I get your point now.

Thanks
Yafang

