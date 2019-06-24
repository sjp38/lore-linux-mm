Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71B65C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:31:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F4064205C9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:31:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CwIlQp4w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F4064205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F7EB6B0003; Mon, 24 Jun 2019 08:31:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A8278E0003; Mon, 24 Jun 2019 08:31:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36FAD8E0002; Mon, 24 Jun 2019 08:31:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15A656B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:31:30 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id b197so21657150iof.12
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:31:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SPpr63Rz4YJvRewRSPx1O8afMbQp5WdeiR1AEOsFoLo=;
        b=V6aeNbt9hppQahoy1Oh442bV5XmHzetvpGD5w+aGyxs1nk/Ay18E9wSEhYlyFLOF22
         3Ong5owP8+9BQT+DmGBq3P98aq8bSGvPmgvU/28+D/XUzg8ee/2had9v2LDSpIBECaz1
         qv5xmSDIYNjre695KDzkwRAxTqt0pdDBTsglB2ckFPepZosLGrHbNT3pLl7nlQfe0mtI
         EO78IQbEz+xtt9ZFVAdAIXoWWWbqE0vZQ6jUaRcd/45p8TtS7sgIWPGKg173v5gI0OEJ
         KReiIwcrnbBLOXcFEo11Vlk4RFZGRKsZMwlOdFrl8CzYJqSL8068sc8Sv2CYikpEjvfR
         rBtA==
X-Gm-Message-State: APjAAAUWe4dkecnlUEzSvUnZ5KJ/nJKmbLl4PbafQW2TSKaY0u+Ws7JU
	mh0DuhNfVnAdWiupzD48USKu6JCJB8Lm1CgJBlL8am90zev4E4xkRY2SgFDFj/sJls16mtkzolM
	/atDTXdRFFj6A6hVd0f/oKpHcNMP/ajJ7UIzxdBJtQzZwfjsH/RcYiUByja1PtqTDOQ==
X-Received: by 2002:a5d:8845:: with SMTP id t5mr7869414ios.37.1561379489775;
        Mon, 24 Jun 2019 05:31:29 -0700 (PDT)
X-Received: by 2002:a5d:8845:: with SMTP id t5mr7869329ios.37.1561379488716;
        Mon, 24 Jun 2019 05:31:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561379488; cv=none;
        d=google.com; s=arc-20160816;
        b=DCfg6Z8TXN7lzM6szoIuHU3b+t7fKVr7RPbAUNrwryUW/OpRN2JW2ohsMgAI32DvxW
         YpCJAg12fyquXEhF3bPN5MYkb+TDIQ/xq+w/LXcGWQc1r/UnMIPz1ceN6X7lgD+5SHwb
         rcSK2HAslizcHWdf0fVbLcSW+ZuZdg7YLpM+e5Cpp/mq89RA3kijWs5lLKtjkEbUq3bD
         44YbiFlTeQniOV2SijAKJlEviV/ltsJdqZiI/0VrWNabiEWxEx8/gU1vz0G01nK/aUcd
         JpkbxtNfOINua0EJqqq1l83Z7mfkjiqf2HzvObI1ii+3kF1zpdj5fFst2ySShZILMCSr
         Caig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SPpr63Rz4YJvRewRSPx1O8afMbQp5WdeiR1AEOsFoLo=;
        b=McCnecFi1tIZR6WlJ9fBI0UnHg/sfdX4xGCJMRSwJOZcaodPkYqfUVHU6K+JUlYQcl
         sCJ/1nyshFNGDeFuWTm/romZSnbJjnD28+BZuN/w54fe4sp0WT+BVF2A/yac5RR4ZFLo
         2YPwg/JKig8jTCiz82Ypc2WbI670hdIX24/kFEkOhJloJT6JLzBpLGCf8vVIk8EplIFL
         wMQYrXcNw/PGwNQ+CmpcO77lpn3WtvQs4ZeMjw0PBnFqHrCZN3s21WkXjEIr+deAkqh1
         OsmJCB43qXWRE7Rw9I064Tw4MbxXwU+RB7t2Cb5Pjh50DC/ts8alSuiN9KECIAYpc686
         klrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CwIlQp4w;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j128sor7474407iof.121.2019.06.24.05.31.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 05:31:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CwIlQp4w;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SPpr63Rz4YJvRewRSPx1O8afMbQp5WdeiR1AEOsFoLo=;
        b=CwIlQp4wsbdhZpJdnB3i/8eVegRvLVtuNue2CUIgC2zZhURu+4qjjtEppEAyeTgodz
         avzKVdzBfgCFDxQs+MMz9Re5NgK6X9xRhtC1pFTPjZ3sB5ejnKvIgj6NFTbcvjFD80nj
         dTFAUR9Y3dEmIjsKUuZjH4S/6NxEauWVrpJx8uCd5221CNYwzawb5BvxRTRGXJ8/bR44
         e51TESJ5T56ZaGYhQGe0w8HWdw/gqiN/rxwT8ASgjQN0pFyWh4V2oarEnZl+7b9YEI8K
         8AQmu1kQllZpUJrd13n31Ip0Ro9bw9bX5zpjEempiarbThkdvwInO7u/AaLeV1HZsceq
         Ni0g==
X-Google-Smtp-Source: APXvYqwnos6OGaU1t/0EF7NmK7rTGbuKtLIyuF2T+0asFy12QGoDJbHajjGoGvCWuXqFmhChXww3TjnzJIWrINziPIk=
X-Received: by 2002:a5d:9282:: with SMTP id s2mr9035239iom.36.1561379488232;
 Mon, 24 Jun 2019 05:31:28 -0700 (PDT)
MIME-Version: 1.0
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
 <1561112086-6169-3-git-send-email-laoar.shao@gmail.com> <d919ea73-daea-8a77-da0a-d1dc6089fd92@virtuozzo.com>
In-Reply-To: <d919ea73-daea-8a77-da0a-d1dc6089fd92@virtuozzo.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 24 Jun 2019 20:30:12 +0800
Message-ID: <CALOAHbCYgky01_LZF+JGq-ooQY-W=S9SE6yc_MmsmnqG5mmmVg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/vmscan: calculate reclaimed slab caches in all
 reclaim paths
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 4:53 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> On 21.06.2019 13:14, Yafang Shao wrote:
> > There're six different reclaim paths by now,
> > - kswapd reclaim path
> > - node reclaim path
> > - hibernate preallocate memory reclaim path
> > - direct reclaim path
> > - memcg reclaim path
> > - memcg softlimit reclaim path
> >
> > The slab caches reclaimed in these paths are only calculated in the above
> > three paths.
> >
> > There're some drawbacks if we don't calculate the reclaimed slab caches.
> > - The sc->nr_reclaimed isn't correct if there're some slab caches
> >   relcaimed in this path.
> > - The slab caches may be reclaimed thoroughly if there're lots of
> >   reclaimable slab caches and few page caches.
> >   Let's take an easy example for this case.
> >   If one memcg is full of slab caches and the limit of it is 512M, in
> >   other words there're approximately 512M slab caches in this memcg.
> >   Then the limit of the memcg is reached and the memcg reclaim begins,
> >   and then in this memcg reclaim path it will continuesly reclaim the
> >   slab caches until the sc->priority drops to 0.
> >   After this reclaim stops, you will find there're few slab caches left,
> >   which is less than 20M in my test case.
> >   While after this patch applied the number is greater than 300M and
> >   the sc->priority only drops to 3.
> >
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  mm/vmscan.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 18a66e5..d6c3fc8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -3164,11 +3164,13 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> >       if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
> >               return 1;
> >
> > +     current->reclaim_state = &sc.reclaim_state;
> >       trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
> >
> >       nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> >
> >       trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
> > +     current->reclaim_state = NULL;
>
> Shouldn't we remove reclaim_state assignment from __perform_reclaim() after this?
>

Oh yes. We should remove it. Thanks for pointing out.
I will post a fix soon.

Thanks
Yafang

> >       return nr_reclaimed;
> >  }
> > @@ -3191,6 +3193,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
> >       };
> >       unsigned long lru_pages;
> >
> > +     current->reclaim_state = &sc.reclaim_state;
> >       sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> >                       (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> >
> > @@ -3212,7 +3215,9 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
> >                                       cgroup_ino(memcg->css.cgroup),
> >                                       sc.nr_reclaimed);
> >
> > +     current->reclaim_state = NULL;
> >       *nr_scanned = sc.nr_scanned;
> > +
> >       return sc.nr_reclaimed;
> >  }
> >
> > @@ -3239,6 +3244,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> >               .may_shrinkslab = 1,
> >       };
> >
> > +     current->reclaim_state = &sc.reclaim_state;
> >       /*
> >        * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
> >        * take care of from where we get pages. So the node where we start the
> > @@ -3263,6 +3269,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> >       trace_mm_vmscan_memcg_reclaim_end(
> >                               cgroup_ino(memcg->css.cgroup),
> >                               nr_reclaimed);
> > +     current->reclaim_state = NULL;
> >
> >       return nr_reclaimed;
> >  }
> >
>

