Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC8F1C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACBCB20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:09:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACBCB20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FE526B000D; Tue,  6 Aug 2019 07:09:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B0076B000E; Tue,  6 Aug 2019 07:09:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C5D06B0010; Tue,  6 Aug 2019 07:09:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F2B166B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:09:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so53609470edr.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:09:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WJsvB0Dt3/5NZNg0HtdNEp7H0G8m/s+uMoHvZClGhsQ=;
        b=Q44HIOkGJJcm9nljKI7AH5dgI8owSHWhUZ9tfRX/HLkpFxs5WbPpL2daaBYE8yeTo7
         WG/KD6ioVzpa7mDK0LCZQZiq6xhJ835/1ghMYhyZFTe/xtG+XGWwLudjP5NJmXM0NP7v
         0BGpAF+gsc7B+K2Hom72YxHjTJhLHtqVMZod8mr9PHIVtKnDm42cP9Zq8Fcdzl2Cwbn+
         cINQpUJzBriWeyl3QO+R6dWDeZR2Hl4w2cx/WUeIXVpsXNKjnlrismkrIX6nssKfWd5R
         0HZkyImC+YGCH3qIEiDPkcJjGj2Bs6ZKhLcW/fgacc0B/+hbmWuoT/sTZMGBb6OLSXDJ
         835A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWgxJzdmykTtMH80+cHSS4PNAkUIQhVOWETX7sqI1rATPRKnmZy
	v1VecX8mWqBf8+u/8h0klWEuuXe7FDMz2XNCks3y5Pl8FM8xYzZBTn3NnNnPptT1MQgTu97+kCF
	YJA7PoaPdleMEPikMvFfwpSNVE5HJQoW0jdzaJ+5eNFk7qldhXnfqhC7DwEDPMLA=
X-Received: by 2002:a17:906:398:: with SMTP id b24mr2591968eja.78.1565089748560;
        Tue, 06 Aug 2019 04:09:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcff0maVE85FNWmdNw83p8wHDYJpQpyWkG5aHeLzDdLwsoeubYILbyaSknzr2IuWXqbPvL
X-Received: by 2002:a17:906:398:: with SMTP id b24mr2591908eja.78.1565089747737;
        Tue, 06 Aug 2019 04:09:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565089747; cv=none;
        d=google.com; s=arc-20160816;
        b=q07mn0JrnSnCiEQiSWef8lgmjR1SmaeOBn4y2TIxMxKTmGVvWub5Q3ZsiIVkag7O/Q
         abc/Amc9OwNocQfyESFAWanOTAib80aDlAhOgybyDI8EL25qSVBjVY3K7WOffN7++Sht
         Du2769wIhbSmzoxHAHzuFQzVY/wMfJb3b4dYBW5Scw4yntyrXTBucKaoYgyUt5RHFf3N
         3lKQ0lcIG/R89CY1nc2FZiLBEt+5D0w9JeaXRwIbtJ7PgG3zmAi92yP0lXLAYi1zg0Ql
         2eBf/miXDH7LHFAk2h64Gy556LMnvaehtz4xuyoIQ/wK0T4v/wq8J8RQJ/N1psgreS7D
         YAvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WJsvB0Dt3/5NZNg0HtdNEp7H0G8m/s+uMoHvZClGhsQ=;
        b=rWCG+R+mcllG0jg2na5Rrz7nzJoCiUIJJ39StsfziXDfQrqJJnnIEy/MCfO5/JpIcW
         I6H8d89tESj5ImEuia9dv0YqObJiNcS9l3iWv8MCeKDjeBnJHrbhIZnh+Fr5Bkqcvr1K
         nrzVRX7h1vXZDIQPQvvMysNzlemvnm4NoGQMAO04MSMXherVZ4rAXYa+G5bTR0a18FAr
         9HnPRbLcLt6+CfYo90yyc6Qt25Fc+GAefP23L2UhqoX1eBLPwesz85uC9HaLEAMJ66XD
         r8/COhSdG6psgl9fL08KyueoclfjoqmhoQmBH7rWPZSRwnf3sg4oK4WSK6gQOel0Ifdc
         Im9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a22si26193283eje.295.2019.08.06.04.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 04:09:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 24C0FB62A;
	Tue,  6 Aug 2019 11:09:07 +0000 (UTC)
Date: Tue, 6 Aug 2019 13:09:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806110905.GU11812@dhcp22.suse.cz>
References: <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
 <20190806095028.GG2739@techsingularity.net>
 <CALOAHbAwSevM9rpReKzJUhwoZrz_FdbBzSgRtkUfWe9BMGxWJA@mail.gmail.com>
 <20190806102845.GP11812@dhcp22.suse.cz>
 <CALOAHbCJg4DqdgKpr8LWqc636ig=phCZWUduEmwYFUtw5gq=tw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbCJg4DqdgKpr8LWqc636ig=phCZWUduEmwYFUtw5gq=tw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 18:59:52, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 6:28 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 06-08-19 17:54:02, Yafang Shao wrote:
> > > On Tue, Aug 6, 2019 at 5:50 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> > > >
> > > > On Tue, Aug 06, 2019 at 11:25:31AM +0200, Michal Hocko wrote:
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
> > > > >               .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> > > > >               .may_swap = 1,
> > > > >               .reclaim_idx = gfp_zone(gfp_mask),
> > > > > +             .may_shrinkslab = 1;
> > > > >       };
> > > > >
> > > > >       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > > > >
> > > > > shrink_node path already does shrink slab when the flag allows that. In
> > > > > other words get us back to before 1c30844d2dfe because that has clearly
> > > > > changed the long term node reclaim behavior just recently.
> > > >
> > > > I'd be fine with this change. It was not intentional to significantly
> > > > change the behaviour of node reclaim in that patch.
> > > >
> > >
> > > But if we do it like this, there will be bug in the knob vm.min_slab_ratio.
> > > Right ?
> >
> > Yes, and the answer for that is a question why do we even care? Which
> > real life workload does suffer from the of min_slab_ratio misbehavior.
> > Also it is much more preferred to fix an obvious bug/omission which
> > lack of may_shrinkslab in node reclaim seem to be than a larger rewrite
> > with a harder to see changes.
> >
> 
> Fixing the bug in min_slab_ratio doesn't  require much change, as it
> just introduce a new bit in scan_control which doesn't require more
> space
> and a if-branch in shrink_node() which doesn't take much cpu cycles
> neither, and it will not take much maintaince neither as no_pagecache
> is 0 by default and then we don't need to worry about what if we
> forget it.

You are still missing my point, I am afraid. I am not saying your change
is wrong or complex. I am saying that there is an established behavior
(even when wrong) that node-reclaim dependent loads might depend on.
Your testing doesn't really suggest you have done much testing beyond
the targeted one which is quite artificial to say the least.

Maybe there are workloads which do depend on proper min_slab_ratio
behavior but it would be much more preferable to hear from them rather
than change the behavior based on the code inspection and a
microbenchmark.

Is my thinking more clear now?

-- 
Michal Hocko
SUSE Labs

