Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC4FDC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:07:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8284022ADA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:07:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BPeMjEKC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8284022ADA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2130D6B0003; Fri, 26 Jul 2019 06:07:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C5A76B0005; Fri, 26 Jul 2019 06:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B22D8E0002; Fri, 26 Jul 2019 06:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC55D6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:07:25 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h3so58213205iob.20
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:07:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4X7dJz0Q3o8b1ySlXDx7Q5cdcZy+ZQXi1CPIE/+w3pc=;
        b=dptVJ7DPh3PrRuGQ+VsrS41U+GSPnHvQc0qeC1h6czC5vlw9qcilJ1M6Owkl8XQkIo
         iYg7pvkoolSoIX6z6jljh0YpIcD77hVIjeoyworIuSqN+cxh92Gm+31P8RSHkSLgv2P1
         CkA7EUqyfbcknhyV241/Ugt0fBqm1w7Ufhq43lIz6ExBpOP5v0kN712iAN9MvMtPXbiu
         siWYXArinzf1O0i3aQE9IvSAezv4nSCyKmNdzf6veigh21uPfzmUaPS2jez8HSp20rrS
         DyqZMzNaJJ5w2A4ygaeemgT5W5nOkauBq78WwW/LpiIVyrQ0ktlj2vhnFWTKWX+yE33v
         hzxA==
X-Gm-Message-State: APjAAAUxBq1osYgmV47T8q2hTdLYlKONlg5efyQgXze92PfSeyEN5FRX
	2pFv4VLyllF63XvQ0H7itUh1uPAFIzB3Bc5VTeWb/waxazrP2iRauWkMbk8fPrZEaQYwYY2pegP
	20U0KcYDWmg8Vk/m2RuBdgvtYc+qxZwrb3Dku5SdP3XAjL2B/L5Km1AqVJsxNSrke0Q==
X-Received: by 2002:a6b:7109:: with SMTP id q9mr5147529iog.30.1564135645559;
        Fri, 26 Jul 2019 03:07:25 -0700 (PDT)
X-Received: by 2002:a6b:7109:: with SMTP id q9mr5147466iog.30.1564135644629;
        Fri, 26 Jul 2019 03:07:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564135644; cv=none;
        d=google.com; s=arc-20160816;
        b=ILuHB8lCvXzvBHqEYMaJwHwCyOi/kHIYirijSasxjQYIhu5a8M8tjh0tqNrO7fSw34
         5GW8vXI3sHbRtK+L2X79c0y4ER+uTy5CQAUffonY5BSbvO6swffTMN5i1IkUicCQZYRH
         sYJyTf4L4+qkcWx409Zlimg3zhhFdE8Hlo9j/ro5YKuPTVtEvN0X+CoUSUmlcSQYJgyS
         xkoYYvCGCCeUCiZbZdWv45zu/bYEjWFHfWh1zCn2cxetx0abyp8bMNUn1HFfVTMa3HjN
         waAnlIRjbTyIn59r6lXDEkpEAXF0eAOiBu2aDmD/ydOKpxpHh74bBj0sK+8BWXgYxABd
         +/hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4X7dJz0Q3o8b1ySlXDx7Q5cdcZy+ZQXi1CPIE/+w3pc=;
        b=z3cPyHvDP2tZfAjY3gGgMU6X9SPIK6bDCW+IaFy5o9OIXBfO4zbNlQxnuylRnHzVK8
         2eMbMixl5BwZh3JcMQWLgRmB5+ouFIQ3QpZxiLBU5ysWuV43e2ilQywQigLN4KHpqoMp
         oZIFZ/9oJCm2VzJ8x29B8lCBsAV59uVw0ubyYXMKhMS9oBzXIbsJXdR704dAByxl34rY
         r7RywxwIaAI8qSNOEgdjoACNlqfoUZR3ExwlkLWc7SqTxvkFy2zGcOpUnj+//gevsGju
         UHOBjorLbVU0oBmM2X03cZ9qWqI9jWoYZI7ys4pfRpHc2pkHV/9kf9252nPHYjtSSG+V
         IARA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BPeMjEKC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor37464910iol.1.2019.07.26.03.07.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 03:07:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BPeMjEKC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4X7dJz0Q3o8b1ySlXDx7Q5cdcZy+ZQXi1CPIE/+w3pc=;
        b=BPeMjEKCjXcf7yzyl5kXB+2uunNLhlruFEoIMtH6jXPb0G1yS8bwj7gCUH+AMh6iTz
         T3qterbmGgQOg9ratADOEX+7B9LiIxNIPpeSEAD2fbqON192EgGkKos/1k7nsJ8otH4N
         g7o6Vn/LgLtUgr4Ot+ipItOY9AWmSYoEjYl0Kxwgr1BJKK+1j9kC7Fxd+5PGOGIGa0uX
         2plECn0EheztbdsxuBdftu4uSzdJE7P+L63XgAHBCjxB3ltW3qR2+Ebu1NaxytMm8UeQ
         Eej+fPswJEF3txtbai6YjddL1yQ/hQSM+QS5GUjE5nzbEXnLTbTifExzIilDwYz1SwZj
         nQAQ==
X-Google-Smtp-Source: APXvYqznza6sV+ZaE9zlB3w1qdTK2PGB3SEG5oNBF0BY5Cl2JzsKK/WmV9UV7hsb93MF/KrTH5UO3us8PO0srOrE094=
X-Received: by 2002:a5d:8702:: with SMTP id u2mr67995076iom.228.1564135644373;
 Fri, 26 Jul 2019 03:07:24 -0700 (PDT)
MIME-Version: 1.0
References: <1564062621-8105-1-git-send-email-laoar.shao@gmail.com> <20190726070939.GA2739@techsingularity.net>
In-Reply-To: <20190726070939.GA2739@techsingularity.net>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 26 Jul 2019 18:06:48 +0800
Message-ID: <CALOAHbA2sHSOpZXE6E+VjdJENa-WCZCo=-=YOqyVYAhkpf+Lrg@mail.gmail.com>
Subject: Re: [PATCH] mm/compaction: use proper zoneid for compaction_suitable()
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Arnd Bergmann <arnd@arndb.de>, 
	Paul Gortmaker <paul.gortmaker@windriver.com>, Rik van Riel <riel@redhat.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 3:09 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> On Thu, Jul 25, 2019 at 09:50:21AM -0400, Yafang Shao wrote:
> > By now there're three compaction paths,
> > - direct compaction
> > - kcompactd compcation
> > - proc triggered compaction
> > When we do compaction in all these paths, we will use compaction_suitable()
> > to check whether a zone is suitable to do compaction.
> >
> > There're some issues around the usage of compaction_suitable().
> > We don't use the proper zoneid in kcompactd_node_suitable() when try to
> > wakeup kcompactd. In the kcompactd compaction paths, we call
> > compaction_suitable() twice and the zoneid isn't proper in the second call.
> > For proc triggered compaction, the classzone_idx is always zero.
> >
> > In order to fix these issues, I change the type of classzone_idx in the
> > struct compact_control from const int to int and assign the proper zoneid
> > before calling compact_zone().
> >
>
> What is actually fixed by this?
>

Recently there's a page alloc failure on our server because the
compaction can't satisfy it.
This issue is unproducible, so I have to view the compaction code and
find out the possible solutions.
When I'm reading these compaction code, I find some  misuse of
compaction_suitable().
But after you point out, I find that I missed something.
The classzone_idx should represent the alloc request, otherwise we may
do unnecessary compaction on a zone.
Thanks a lot for your explaination.

Hi Andrew,

Pls. help drop this patch. Sorry about that.
I will think about it more.

> > This patch also fixes some comments in struct compact_control, as these
> > fields are not only for direct compactor but also for all other compactors.
> >
> > Fixes: ebff398017c6("mm, compaction: pass classzone_idx and alloc_flags to watermark checking")
> > Fixes: 698b1b30642f("mm, compaction: introduce kcompactd")
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Yafang Shao <shaoyafang@didiglobal.com>
> > ---
> >  mm/compaction.c | 12 +++++-------
> >  mm/internal.h   | 10 +++++-----
> >  2 files changed, 10 insertions(+), 12 deletions(-)
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index ac4ead0..984dea7 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -2425,6 +2425,7 @@ static void compact_node(int nid)
> >                       continue;
> >
> >               cc.zone = zone;
> > +             cc.classzone_idx = zoneid;
> >
> >               compact_zone(&cc, NULL);
> >
> > @@ -2508,7 +2509,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
> >                       continue;
> >
> >               if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
> > -                                     classzone_idx) == COMPACT_CONTINUE)
> > +                                     zoneid) == COMPACT_CONTINUE)
> >                       return true;
> >       }
> >
>
> This is a semantic change. The use of the classzone_idx here and not
> classzone_idx is so that the watermark check takes the lowmem reserves
> into account in the __zone_watermark_ok check. This means that
> compaction is more likely to proceed but not necessarily correct.
>
> > @@ -2526,7 +2527,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> >       struct compact_control cc = {
> >               .order = pgdat->kcompactd_max_order,
> >               .search_order = pgdat->kcompactd_max_order,
> > -             .classzone_idx = pgdat->kcompactd_classzone_idx,
> >               .mode = MIGRATE_SYNC_LIGHT,
> >               .ignore_skip_hint = false,
> >               .gfp_mask = GFP_KERNEL,
> > @@ -2535,7 +2535,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> >                                                       cc.classzone_idx);
> >       count_compact_event(KCOMPACTD_WAKE);
> >
> > -     for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
> > +     for (zoneid = 0; zoneid <= pgdat->kcompactd_classzone_idx; zoneid++) {
> >               int status;
> >
> >               zone = &pgdat->node_zones[zoneid];
>
> This variable can be updated by a wakeup while the loop is executing
> making the loop more difficult to reason about given the exit conditions
> can change.
>

Thanks for your point out.

But seems there're still issues event without my change ?
For example,
If we call wakeup_kcompactd() while the kcompactd is running,
we just modify the kcompactd_max_order and kcompactd_classzone_idx and
then return.
Then in another path, the wakeup_kcompactd() is called again,
so kcompactd_classzone_idx and kcompactd_max_order will be override,
that means the previous wakeup is missed.
Right ?


> Please explain what exactly this patch is fixing and why it should be
> done because it currently appears to be making a number of subtle
> changes without justification.
>
> --
> Mel Gorman
> SUSE Labs

