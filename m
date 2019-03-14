Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3943FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:44:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA86A2070D
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:44:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hQEo/pW7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA86A2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FB468E0003; Thu, 14 Mar 2019 05:44:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A9648E0001; Thu, 14 Mar 2019 05:44:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 572548E0003; Thu, 14 Mar 2019 05:44:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2765D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:44:15 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id 142so4196782itx.0
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:44:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4vVlXIGUUTwMipB8dwrJZqLuKEZoHvnjGk2ecgreUCA=;
        b=RkDq3mqgv9eSLsMDDkw6mo7YIKUDnUKzf8PeZqCUhGgi5wpKWoUsPY+moiydmMh5AP
         3IhR57BMLrOIgauw5u9DXhB5XFqbux1B03dSyioq03ooU6kNm+HzsEOkncZLgA2Njmfp
         KjWjVWIwTC6VebtGTvPLzDOjgz8rSni2BVCElh+8gepyyqEIgylPxz27Gqx0oUPwij8N
         BkHkkfVhsA/55k5XxKX5fdEqeMpp0vRgTSN7TT6rFGmVDBgv3P2v2/Z+arszr8qUbH3g
         06u7gbiPawfbWBm4DuVbGSxWSSTksvhsz+VPgus63SyA8XbRcu8ODZTWrmls17YssbPF
         SNvA==
X-Gm-Message-State: APjAAAV13VlhF0yot23p610JRFALQjI4Vuy9s6uZ2RU1sy34ymVLUsT1
	z9Dr05ydd+tDbxRLGlcA6VzzLwYUcFWBTkzCNvBsGbQN9yHn++OIZRpzG03efq9rB1YvvveLPcA
	KG8D5C/QesIgGTi9egGG5uA8DvMSt+6OAKadphUFffXJdKwsRW1KNl6Zni1HYogpM5Yn3B3Gf/W
	yAMHCZTszJ5/WA7WWBVnXYxhOJ0zi2zCKGrr2oj15H6wTTRzBrdLwOr+pigRICU29sR5iJDrKlF
	Sjs7qNF7l/cd4nRayhTrUjPC+k8ZBrDhkhf9Na1f1Y82UAwHLtgHINezolXyOMo5tgskPf1UaUE
	2Fj9nwst0DpsmDTBwArRlnEH+JZt/8C60dSsUhstVK+HZYXEfsdYpNkA+HNcsq0yU88sRqVKuXq
	5
X-Received: by 2002:a02:4904:: with SMTP id z4mr25427521jaa.46.1552556654934;
        Thu, 14 Mar 2019 02:44:14 -0700 (PDT)
X-Received: by 2002:a02:4904:: with SMTP id z4mr25427452jaa.46.1552556653682;
        Thu, 14 Mar 2019 02:44:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552556653; cv=none;
        d=google.com; s=arc-20160816;
        b=YbhLblfSLXqEZhE1OBs/UuRLiGjwSfFj9bZBqF3KScMJFHP761idnJBz/diAqdfJES
         RbU6+QHtWHs0rtlKvdKsbVKeNAJx55A0vwYKoSEHGuRFxrVjR9qjLHCBp+GxYk7la6lI
         EHzbESQxCwPlNCyCT3yG0c1zAl+G4jetnG0oqLZj6M09I1H9T/xjFrpuJ+7Ru0XgdZOq
         2PUSxkuCXa91DRTtlE56HBsd7e6FIbypHnMS0obOid3yPBijY87N+7agp3G1ds5VQnaO
         /AMJBzU0tX0R8sz5IVrbU1RJKt1fqJ/iQ+A8iJVedi0MnDOpkMEi4wd42yhv6O6aEtAN
         IWjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4vVlXIGUUTwMipB8dwrJZqLuKEZoHvnjGk2ecgreUCA=;
        b=0Sf54OhMCohSXd4I41k42HI/SMkDDz8oFgYnebM5/uvH3Wy15gWFh46Arn5vnVNflv
         n82HJXEGSIoFINVdHe15k4EO7+Aw+Hb3R3nYsvblbb8bOCXgFQ/ZvRnk3yk/DPZ3gG3G
         qM1skXKGV8aWJSBkFmmoZB4vd2BLwruvyLD1oL+6V+6hgVVrTFrXjyeqSlgiK/s2k69B
         ZRd8wl0L0NjiAy3t8KRE8l4U+tzit3ZP/7XPAuAOczP/dtZ4IQr++40CmE7CUkelpfAD
         w+kVqVOJ8Yy1ERTgcmLhhR7usmn1VqyfarZoIu3l8rHxHMfNcH2K27owhVRoBLlEF5C6
         69tA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="hQEo/pW7";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h12sor2586960itb.29.2019.03.14.02.44.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 02:44:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="hQEo/pW7";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4vVlXIGUUTwMipB8dwrJZqLuKEZoHvnjGk2ecgreUCA=;
        b=hQEo/pW7w4uMxxsCgSWGECb+BCkmaopXk7y0KbywQtoHEK+yiOOKXL0KtgzayxxNVu
         /PsQEOvyo1aXxS4gCjUMmlUAPMYsmT52uukPIm6pj3fUVYjQgG1FaX/7RXIIxY3xXinE
         ph74gUliHyHgKlCHHnkAHhwYA8jC0B2jEw3ieBt00ntKNAXfX/4Hppse4TDrctncx6Iz
         ul9MzFMXzhgKnURJPIYNWCuWT7KGs4xvX0/3f5AYAupyFdJ7N40VQ139j31ULJk0mKlL
         K5LGnR4crzpxQnzOkuZXidbTMOw/7VOQAYj+SQxSPkOcTjIAIIbDPpAiyRmgQMumqjvp
         bCIQ==
X-Google-Smtp-Source: APXvYqw/84za4ZDlLy2/xrONZkNxmyNLE8qxggABKrVdIJVmZgqLu3hLxS7GqQFtUlmyMRJBXbj2RlWBwkU2EA2vBUc=
X-Received: by 2002:a24:b34f:: with SMTP id z15mr1417610iti.97.1552556652374;
 Thu, 14 Mar 2019 02:44:12 -0700 (PDT)
MIME-Version: 1.0
References: <1551421452-5385-1-git-send-email-laoar.shao@gmail.com> <1551421452-5385-2-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1551421452-5385-2-git-send-email-laoar.shao@gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 14 Mar 2019 17:43:36 +0800
Message-ID: <CALOAHbCf-HU4NJ3hp9Cozuy03aVqbOpzNi7+QWNU0AC1Q2tOMA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: drop may_writepage and classzone_idx from
 direct reclaim begin template
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 1, 2019 at 2:24 PM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> There are three tracepoints using this template, which are
> mm_vmscan_direct_reclaim_begin,
> mm_vmscan_memcg_reclaim_begin,
> mm_vmscan_memcg_softlimit_reclaim_begin.
>
> Regarding mm_vmscan_direct_reclaim_begin,
> sc.may_writepage is !laptop_mode, that's a static setting, and
> reclaim_idx is derived from gfp_mask which is already show in this
> tracepoint.
>
> Regarding mm_vmscan_memcg_reclaim_begin,
> may_writepage is !laptop_mode too, and reclaim_idx is (MAX_NR_ZONES-1),
> which are both static value.
>
> mm_vmscan_memcg_softlimit_reclaim_begin is the same with
> mm_vmscan_memcg_reclaim_begin.
>
> So we can drop them all.
>
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  include/trace/events/vmscan.h | 26 ++++++++++----------------
>  mm/vmscan.c                   | 14 +++-----------
>  2 files changed, 13 insertions(+), 27 deletions(-)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index a1cb913..153d90c 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -105,51 +105,45 @@
>
>  DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
>
> -       TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> +       TP_PROTO(int order, gfp_t gfp_flags),
>
> -       TP_ARGS(order, may_writepage, gfp_flags, classzone_idx),
> +       TP_ARGS(order, gfp_flags),
>
>         TP_STRUCT__entry(
>                 __field(        int,    order           )
> -               __field(        int,    may_writepage   )
>                 __field(        gfp_t,  gfp_flags       )
> -               __field(        int,    classzone_idx   )
>         ),
>
>         TP_fast_assign(
>                 __entry->order          = order;
> -               __entry->may_writepage  = may_writepage;
>                 __entry->gfp_flags      = gfp_flags;
> -               __entry->classzone_idx  = classzone_idx;
>         ),
>
> -       TP_printk("order=%d may_writepage=%d gfp_flags=%s classzone_idx=%d",
> +       TP_printk("order=%d gfp_flags=%s",
>                 __entry->order,
> -               __entry->may_writepage,
> -               show_gfp_flags(__entry->gfp_flags),
> -               __entry->classzone_idx)
> +               show_gfp_flags(__entry->gfp_flags))
>  );
>
>  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
>
> -       TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> +       TP_PROTO(int order, gfp_t gfp_flags),
>
> -       TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
> +       TP_ARGS(order, gfp_flags)
>  );
>
>  #ifdef CONFIG_MEMCG
>  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
>
> -       TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> +       TP_PROTO(int order, gfp_t gfp_flags),
>
> -       TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
> +       TP_ARGS(order, gfp_flags)
>  );
>
>  DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
>
> -       TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
> +       TP_PROTO(int order, gfp_t gfp_flags),
>
> -       TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
> +       TP_ARGS(order, gfp_flags)
>  );
>  #endif /* CONFIG_MEMCG */
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ac4806f..cdc0305 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3304,10 +3304,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>         if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>                 return 1;
>
> -       trace_mm_vmscan_direct_reclaim_begin(order,
> -                               sc.may_writepage,
> -                               sc.gfp_mask,
> -                               sc.reclaim_idx);
> +       trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
>
>         nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>
> @@ -3338,9 +3335,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>                         (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>
>         trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
> -                                                     sc.may_writepage,
> -                                                     sc.gfp_mask,
> -                                                     sc.reclaim_idx);
> +                                                     sc.gfp_mask);
>
>         /*
>          * NOTE: Although we can get the priority field, using it
> @@ -3389,10 +3384,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>
>         zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
>
> -       trace_mm_vmscan_memcg_reclaim_begin(0,
> -                                           sc.may_writepage,
> -                                           sc.gfp_mask,
> -                                           sc.reclaim_idx);
> +       trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
>
>         psi_memstall_enter(&pflags);
>         noreclaim_flag = memalloc_noreclaim_save();
> --
> 1.8.3.1
>

Hi Vlastimil, Michal,

Any comments on this patch ?

Thanks
Yafang

