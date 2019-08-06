Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E098EC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 06:45:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A3992147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 06:45:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vwx75LS0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A3992147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1B306B0003; Tue,  6 Aug 2019 02:45:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCCBA6B0005; Tue,  6 Aug 2019 02:45:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE26E6B0006; Tue,  6 Aug 2019 02:45:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8577D6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 02:45:24 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id u200so33856585oia.23
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 23:45:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=36e/1sUB4YgKWexraSJxOxkz/8H8qnqa2weRNpG9VTQ=;
        b=i9R9cAQHxg0sty0w+vRLqTb4hgpNYMXo/rk4YkO8/xfhXaT8jvt6Ymm9sQqevodLcq
         ZXjGZwHEchoIgSR14EnEBwE/kd1rfsQ6UGa/KK/f7+RemUiU2OBOdFYRy1rAWNCdiN8K
         AKICsqs4pwC4tnHAGBf0+JKpn6FlbNmUGsNfgMENUlprBMUjmCU6Re5DhZ539qEYsD87
         vp2jqzR+jHQeYpfOnGuvgv4HpCUONcdl4hT9FkPUQpZV6CiqPRCp35kSc16y3iJvI9PU
         6UPnVpk4b5nlnlgQqROw+EHU1t5ZG3Zmr3Id/S5Rc7LogsnHPoojxkrYuCR6WrYqpZap
         cdUQ==
X-Gm-Message-State: APjAAAUCQhrjad2sbdsHkpFfx+/alVGtcFY7KE1aiDzZP9/UqDIf6E28
	ORoDsIBRYOT0sZoUrMBtmWXU1iR+u3vF/f3ma+icnj9sN/XBYLW3giy1QK3QV7OJpLPjsxSGHaX
	TnsaX0buXisBodzyt4v69sCXDf+eyVZqkfF5JHkG7Ux3rFSkuKCtmQx60L1P8Zrh1dw==
X-Received: by 2002:a05:6602:c7:: with SMTP id z7mr2099171ioe.130.1565073923746;
        Mon, 05 Aug 2019 23:45:23 -0700 (PDT)
X-Received: by 2002:a05:6602:c7:: with SMTP id z7mr2099128ioe.130.1565073923028;
        Mon, 05 Aug 2019 23:45:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565073923; cv=none;
        d=google.com; s=arc-20160816;
        b=Fk4xQJnykyFUUJVoRdJnPbTukdl+MgQOiVUYlGpXG1aZSmAw0wv7A63aVgi5bJ/HZL
         hTvempeO3bbyC1IxRAAdW5W1VVakUznK+P3gyqHw0M+1GUVQ8rz7Yy51ItpI2WvDhYLL
         U4OGfre4zuWU4ZsaFgbL+7COwgRgM5I58gj02shPNOrfE7A/B/q6FEBpP7s6sk0inPAz
         tXY1wA6uVKYe2J1TvpD/xPyClmGAxJEHd8Si7klIchUIjnVsOlHFRURijKueOtRbxJpP
         MZ5L44IAYzw8iXQzDyGo1uP+GophS2LOZumIyGGXnMFC3PwDGsoAKCwpSrpPrlnNIiDp
         V28g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=36e/1sUB4YgKWexraSJxOxkz/8H8qnqa2weRNpG9VTQ=;
        b=e5wUthvgMb33zFlDOvG21Dnm6V5vJbQqK2wQ8zhmARKve3fmRwYr08oTm7n1V8SD+d
         Enk5k74evP3OScOhvstUeeVCiatS2UibDW+ltIfRbdTwC2SZT/nDekOndEbhn6O6pMYa
         MKluf28fEhkRAxYSLY3tlmrEE4MdFhEamgw/VzR8WpFixFg8K1DK6y0HZXStk8oy19GL
         Zwzi9/RiuDKaFt0u3uSjnZF5je2JR1Oq5u5aX7vmLjmuxcua9ZpebKXzJ0pDMRrx8FFq
         xoOhESQPL4a3ERf6eP2dznEV/Z45ZCQGs3/vStMbR9A46sL/5+XQuPUva66CG0PjWjXM
         TJ+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vwx75LS0;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor199293459jae.3.2019.08.05.23.45.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 23:45:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vwx75LS0;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=36e/1sUB4YgKWexraSJxOxkz/8H8qnqa2weRNpG9VTQ=;
        b=Vwx75LS0qZMBozqQ7UCELroQEiAqSShwszCu0MWoJZma7Ivh6Ucc/D6XcTK3OshEeW
         eRWErRhT05AywLjn9pXZYLHIDKbC7aNsHLvNaPX2RnzVl0aKHKyul3QJUY6fsCXHYktG
         UokcsLPRp61Uem9KgI6u1MA0/0kbJOLTRVu/0BFS2yT9zIhVgYnK89zhTrCBr9ygGBU7
         3PoLzknZ6PhZ8UQTwzNu2tFl/nVAuAD3E6/Mz8gDLFKkS2SIhhkHXts+SUaiYUKoHMV+
         w7zPFl7yyYHrhlOipk62RD+3L15EZ33R6jGGucVloWOH3Ij4/hcBn2LaX17YKuPIOfGs
         kvTw==
X-Google-Smtp-Source: APXvYqzibcmNc6irCdm4z0qZ52fVr6viFGg+wKizHjtQFy3h9HVHWtfW8bHtuYLCJ205/due8OlEJJauU0g+fgS7Q80=
X-Received: by 2002:a02:c95a:: with SMTP id u26mr2436869jao.15.1565073922677;
 Mon, 05 Aug 2019 23:45:22 -0700 (PDT)
MIME-Version: 1.0
References: <1564538401-21353-1-git-send-email-laoar.shao@gmail.com> <20190805214219.fxida5zojihauo7d@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20190805214219.fxida5zojihauo7d@ca-dmjordan1.us.oracle.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 14:44:46 +0800
Message-ID: <CALOAHbAZ_+9KPhZohZ_=Wej000yY=KGYn0uX5Z6z-ny55=goSA@mail.gmail.com>
Subject: Re: [PATCH RESEND] mm/vmscan: shrink slab in node reclaim
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Yafang Shao <shaoyafang@didiglobal.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 5:44 AM Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
>
> Hi Yafang,
>
> On Tue, Jul 30, 2019 at 10:00:01PM -0400, Yafang Shao wrote:
> > In the node reclaim, may_shrinkslab is 0 by default,
> > hence shrink_slab will never be performed in it.
> > While shrik_slab should be performed if the relcaimable slab is over
> > min slab limit.
>
> Nice catch, I think this needs
>
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
>

Thanks. I will add it.

> > If reclaimable pagecache is less than min_unmapped_pages while
> > reclaimable slab is greater than min_slab_pages, we only shrink slab.
> > Otherwise the min_unmapped_pages will be useless under this condition.
> > A new bitmask no_pagecache is introduced in scan_control for this
> > purpose, which is 0 by default.
> > Once __node_reclaim() is called, either the reclaimable pagecache is
> > greater than min_unmapped_pages or reclaimable slab is greater than
> > min_slab_pages, that is ensured in function node_reclaim(). So wen can
> > remove the if statement in __node_reclaim().
>
> Why is the if statement there to begin with then, if the condition has
> already been checked in node_reclaim?

In node_reclaim it is
if (condition_pagecache || condition_slab)
     will_do___node_reclaim();

After scan_control::no_pagecache is introuduced, we don't need the if
statement in
___node_reclaim() any more.

> Looks like it came in with
> 0ff38490c836 ("[PATCH] zone_reclaim: dynamic slab reclaim"), but it's not
> obvious to me why.  Maybe Christoph remembers.
>

> I found this part of the changelog kind of hard to parse.  This instead instead
> of above block?
>
>     Add scan_control::no_pagecache so shrink_node can decide to reclaim page
>     cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
>     shrink_node will do at least one of the two because otherwise node_reclaim
>     returns early.
>
> Maybe start the next paragraph with
>
>   __node_reclaim can detect when enough slab has been reclaimed because...
>

That's better. I appreciate your improvement on the changlog. I will update it.

> > sc.reclaim_state.reclaimed_slab will tell us how many pages are
> > reclaimed in shrink slab.
> ...
>
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 47aa215..1e410ef 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -91,6 +91,9 @@ struct scan_control {
> >       /* e.g. boosted watermark reclaim leaves slabs alone */
> >       unsigned int may_shrinkslab:1;
> >
> > +     /* in node relcaim mode, we may shrink slab only */
>
>                    reclaim

Thanks. I will correct it.

>
> > @@ -4268,6 +4273,10 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >               .may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
> >               .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> >               .may_swap = 1,
> > +             .may_shrinkslab = (node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
> > +                                pgdat->min_slab_pages),
> > +             .no_pagecache = !(node_pagecache_reclaimable(pgdat) >
> > +                               pgdat->min_unmapped_pages),
>
> It's less awkward to do away with the ! and invert the condition.

Sure.

Thanks
Yafang

