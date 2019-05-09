Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3780C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 872FA2175B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:06:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lQJMF1J3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 872FA2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 317B26B000A; Thu,  9 May 2019 12:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A0256B000C; Thu,  9 May 2019 12:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167B16B000D; Thu,  9 May 2019 12:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E55BC6B000A
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:06:12 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id v123so4515991ywf.16
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:06:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2bZRaBuaJVzOagPgAxGnwl37KeIxRpAUuki7qHiwS7w=;
        b=QiUrN2tmZCLktGO9W2LjJBkIcPn/iCbn2Nzl4UbnTPwG1Ih4uMJnoiI/2hm6mX3w6j
         bAJf8oZAAy9nBLVTQTN4zEzYtszBl+jAYxt5M9YkL1Yzptu5B/88BZczJ15gGsZXm8S6
         oOLGQjLWz49D5IgEOkOmFQAoENdzxH0+XH/6FIdStbrrCwr7BW4l/DPr/J7uRhIFP1Vv
         xBzNFodVBqRCb6NfSNYYksxfyi7Uat8oHCF+1VoRgdqt4JwZ2Dv8bAnERtThd2l2rUCy
         Mllr2MmBwFBp5cf/I0sVits2F29ymRWwXyXPLFN4UU2bM3/iUKqJKP/544UcUsx2w71P
         c+Tw==
X-Gm-Message-State: APjAAAXSyqRTQ6qZOL45lPs8d5nMZnV91AuKW4ZRlscCNb1wfBBU6QKV
	S4OlcQEGv05eLgSkz4n8k6U6t0tlrKtzgJA1D9pIU/Mnq+UDMb9z14UfHmZ/blk/z8ZBN65oiGF
	Qmgb7iNlE9Fl10BbzoF9ALgBfeWAIVQgodYEXzgOJtmTdg2IIKfvxdU+Kx/QK+eEokw==
X-Received: by 2002:a81:a683:: with SMTP id d125mr1913201ywh.421.1557417972552;
        Thu, 09 May 2019 09:06:12 -0700 (PDT)
X-Received: by 2002:a81:a683:: with SMTP id d125mr1913155ywh.421.1557417971803;
        Thu, 09 May 2019 09:06:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557417971; cv=none;
        d=google.com; s=arc-20160816;
        b=KdEx+uoPs2p3KDxoS7HBIuSktnOwoIVrJ0X/aHZGVY2SWR1wpEqFkYeUdZGPCYhj83
         BG34ar6Teym1Pecq/T+3y4owcOkR3yVOEEo6TEb1IfkwFY4hnLqOsmHqAjW7vW5YD82C
         sB+6fiha0Iwz1kdvzn6VhB4j5tDRJewdSjGR7huAZBtCkEDHIofX2qceWofYRjvcBQum
         oKr3R4knrozMDUpfFbX7wOOwGAblrwCOoo7ijtu4J7scqQ7M7Oh7hXGSRUQR1rUGsEjU
         kF//gev7/qdp7HWfcLSTxHg+J9s1Gre7vDVe1EEJK1V7liPEkZ770tUSxQGtsSKH4RGW
         OmyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2bZRaBuaJVzOagPgAxGnwl37KeIxRpAUuki7qHiwS7w=;
        b=zYScLq6T/3UUSCpTlEnoR5UwbwtsYEr0hsscYP2zyFP4XWD6YHv9VF4ksMdOEotNSa
         6aKvh0pWyEx9zHwvmgmyt0cHtUC8UTEQ07xgjL+M6Eg2SVRvMcSnqwVPwvdE01DP8RWo
         BAGQDKGEi+CaSpT6CV5kymDpmI+6Xx16+D7djPAqXah8Hc/UxeA3Qu4W5B6BZwxy2i8n
         4Goqo9uz7R/3x/kE+ubL/80RZ9D+etOpSglmWaxBn1/ITTOrmjFN6M50TgypdgL2kkvK
         UrNnc5/KqErbUbcRUE7UFx1UHoWVocszs4r0muXbFxvW3MArHBc1SMA2GknpOYU4bFYD
         Jjhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lQJMF1J3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p185sor1275657yba.121.2019.05.09.09.06.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 09:06:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lQJMF1J3;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2bZRaBuaJVzOagPgAxGnwl37KeIxRpAUuki7qHiwS7w=;
        b=lQJMF1J3Hq9E2jyZLMr011Qppcx+H+511s6SILzdH2F5jrBYvd7nkNxUY1FX0ESHU7
         EgKbptxzbUfCTPygnZGyReLUb6p9aZ5h7qv0WnVnKliRI4f8Lurl9Ge0Vs/nEGhf/jko
         JbCaUPv2yMdy3be/pvaZJp7d9vfwtZ5/67SB5faK9ry2CYsF92ymF5Dq6lJLWefmso/h
         1D1bPpKvuwR5vDBgRn24Uo/XG2Ix49bJ+Kw+A9NggKf4vPZougpgmSRsEstw0q4KVhn6
         WCWdjAJfCFckonpFRaVdI99ABUANiwAVNrk3EwUJS/3kNJTH/mlTAc2Ln+sA8c/Ma63n
         5Uig==
X-Google-Smtp-Source: APXvYqweZrD+zILYGdfGDFSodB430IV2ssIGLyfSySK91X9eI9OCm0enlDb2HZZMq2Dl6OiaG9Agp2/SSX2hbrTSMcs=
X-Received: by 2002:a25:6708:: with SMTP id b8mr2579929ybc.377.1557417970993;
 Thu, 09 May 2019 09:06:10 -0700 (PDT)
MIME-Version: 1.0
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz> <20190429105939.11962-1-jslaby@suse.cz>
 <20190509122526.ck25wscwanooxa3t@esperanza>
In-Reply-To: <20190509122526.ck25wscwanooxa3t@esperanza>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 9 May 2019 09:05:59 -0700
Message-ID: <CALvZod5MseXtY_BTHegdqBphCein20ou=zbvYymBJ9_zTUdWmg@mail.gmail.com>
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Jiri Slaby <jslaby@suse.cz>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>, Cgroups <cgroups@vger.kernel.org>, 
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 9, 2019 at 5:25 AM Vladimir Davydov <vdavydov.dev@gmail.com> wrote:
>
> On Mon, Apr 29, 2019 at 12:59:39PM +0200, Jiri Slaby wrote:
> > We have a single node system with node 0 disabled:
> >   Scanning NUMA topology in Northbridge 24
> >   Number of physical nodes 2
> >   Skipping disabled node 0
> >   Node 1 MemBase 0000000000000000 Limit 00000000fbff0000
> >   NODE_DATA(1) allocated [mem 0xfbfda000-0xfbfeffff]
> >
> > This causes crashes in memcg when system boots:
> >   BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> >   #PF error: [normal kernel read fault]
> > ...
> >   RIP: 0010:list_lru_add+0x94/0x170
> > ...
> >   Call Trace:
> >    d_lru_add+0x44/0x50
> >    dput.part.34+0xfc/0x110
> >    __fput+0x108/0x230
> >    task_work_run+0x9f/0xc0
> >    exit_to_usermode_loop+0xf5/0x100
> >
> > It is reproducible as far as 4.12. I did not try older kernels. You have
> > to have a new enough systemd, e.g. 241 (the reason is unknown -- was not
> > investigated). Cannot be reproduced with systemd 234.
> >
> > The system crashes because the size of lru array is never updated in
> > memcg_update_all_list_lrus and the reads are past the zero-sized array,
> > causing dereferences of random memory.
> >
> > The root cause are list_lru_memcg_aware checks in the list_lru code.
> > The test in list_lru_memcg_aware is broken: it assumes node 0 is always
> > present, but it is not true on some systems as can be seen above.
> >
> > So fix this by checking the first online node instead of node 0.
> >
> > Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: <cgroups@vger.kernel.org>
> > Cc: <linux-mm@kvack.org>
> > Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> > ---
> >  mm/list_lru.c | 6 +-----
> >  1 file changed, 1 insertion(+), 5 deletions(-)
> >
> > diff --git a/mm/list_lru.c b/mm/list_lru.c
> > index 0730bf8ff39f..7689910f1a91 100644
> > --- a/mm/list_lru.c
> > +++ b/mm/list_lru.c
> > @@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
> >
> >  static inline bool list_lru_memcg_aware(struct list_lru *lru)
> >  {
> > -     /*
> > -      * This needs node 0 to be always present, even
> > -      * in the systems supporting sparse numa ids.
> > -      */
> > -     return !!lru->node[0].memcg_lrus;
> > +     return !!lru->node[first_online_node].memcg_lrus;
> >  }
> >
> >  static inline struct list_lru_one *
>
> Yep, I didn't expect node 0 could ever be unavailable, my bad.
> The patch looks fine to me:
>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
>
> However, I tend to agree with Michal that (ab)using node[0].memcg_lrus
> to check if a list_lru is memcg aware looks confusing. I guess we could
> simply add a bool flag to list_lru instead. Something like this, may be:
>

I think the bool flag approach is much better. No assumption on the
node initialization.

If we go with bool approach then add

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index aa5efd9351eb..d5ceb2839a2d 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -54,6 +54,7 @@ struct list_lru {
>  #ifdef CONFIG_MEMCG_KMEM
>         struct list_head        list;
>         int                     shrinker_id;
> +       bool                    memcg_aware;
>  #endif
>  };
>
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 0730bf8ff39f..8e605e40a4c6 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
>
>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>  {
> -       /*
> -        * This needs node 0 to be always present, even
> -        * in the systems supporting sparse numa ids.
> -        */
> -       return !!lru->node[0].memcg_lrus;
> +       return lru->memcg_aware;
>  }
>
>  static inline struct list_lru_one *
> @@ -451,6 +447,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
>  {
>         int i;
>
> +       lru->memcg_aware = memcg_aware;
>         if (!memcg_aware)
>                 return 0;
>

