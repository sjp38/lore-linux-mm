Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9BEDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:36:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83DEF2171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:36:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M6VlN0FD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83DEF2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 256F48E0004; Thu, 28 Feb 2019 04:36:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22CC98E0001; Thu, 28 Feb 2019 04:36:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1451A8E0004; Thu, 28 Feb 2019 04:36:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E18228E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:36:15 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id y70so7442739itc.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:36:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Lbf9iBAembtNVXUoSFl1FHGTfKBuTmZnwlMrEQLyCYM=;
        b=iean6ZcO7LO3lYl+XPiKGZeekXSV9MdQTv28ym738cuSahId3FjUaHDJPTvZbdV5Ml
         Wuw6VCg/Pd28TgvRckKeIGZgwgrbKc4JA9uZQ2paRGhdwx544YkuTOQEFEhsmvvSJ3j8
         LAUVvT67ub57JUuu6BkwGvrTib2MpJ7wMBDO25sv1Yni38NCV1aW6oCQm59s7GF3gag6
         8rSJnZ/66eNpExTl8LMjCHYGstN/9x7moR5wYsYuC0e9o6EcDZ8dOPn5la5z/a9J2rlG
         ToRXUDmKjPszz4BtS8nnnt0u6KKIsbBQqcN8XitfqUpFd3bU12YyekjaiNN604gVRHYq
         J5Aw==
X-Gm-Message-State: APjAAAV77J42OBTfXjYAEKYHC0dXZVMvGNgBvBDs8Ov/+/xJXzvHa/gN
	bbfe8o5EmBAXHBT9qlXjr6czjFtNlddEYTSYbijLQ8g4myJlZcm9/9db+E8vNyhr5A6K/F+roZE
	T2FJ8a8mPNPTT044Vbrx0IZ5q6FeOnrjM1VSivK91nwCXfH2aMr5SP9e7EzRsFSbgT2o2zGshEw
	3sxnxQZBR1APeBFKrfayyCS7SKAnyLS+k9NZ3F7UTHLDWfNtajeifyzh/5pE9Mgo4d9Sp37J9Dv
	W0svWIwQdIbu6iOI5XwhbVc/z5ChTY7X5D6ePxabXbQ256cyv1nhsDaznEaRSzP1nzZhUqEwW25
	ZCopWFxu3fnM6WKxB7z56jtuLkcrRGs+nvFtco+hrIZIH2773/42hoIfVCuxyfQmc/VyCpwEsN3
	R
X-Received: by 2002:a24:a81:: with SMTP id 123mr2361732itw.43.1551346575691;
        Thu, 28 Feb 2019 01:36:15 -0800 (PST)
X-Received: by 2002:a24:a81:: with SMTP id 123mr2361712itw.43.1551346574938;
        Thu, 28 Feb 2019 01:36:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551346574; cv=none;
        d=google.com; s=arc-20160816;
        b=NKi0Px+/+kyjKm9iI1oPBbNt+s/nbeZrbtk/MHSu2wg5LK8wXLHNx/jDZf8Oq2W6Qi
         OH/o2dZRk0+HEdM4skid12dGwPZmsa+tZYCF58csP3KNTMBZ7z9XAVajh3d2hIcAckbu
         2aP2y2FYNh2CAQWzhmJs1M4+D/tXgdj/31eSd/b2pe2RFexbmPLcmas/xjao0lZ8rs4G
         oKxMwdxYWk6L8Qqrvum2p22qtu/5IQ/C8JnKOCOP03+GsGhEwFwVphWi+n4EzzKLocIz
         nX4tZqWNOQDanCpx8GQxiDnNTmkUJ16GXPKCcVgGCnome0vkeXUju4F5DowG+EX8QM6m
         p0YQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Lbf9iBAembtNVXUoSFl1FHGTfKBuTmZnwlMrEQLyCYM=;
        b=cqsOcb7ul61DXQWtalu5ZRTRiiQVhtVpgrZKYeAGIYFi0AkNQOMPJXIGV5oKnFVYBH
         ZroZ4bDP8Q5ZbXq4jOWsGPju+je85ucN+SbiIMEEWh46ItC4e6+zhvp3+BGoyozqCSbK
         +vYSrrgqH0R1O4441Jss7c6jg+2Kzzr/uFOH3uuBN4IEI3jI5HGkIT+CAj1Kg4Izwme8
         hbxCYuLTAfGh341a1wzgamhQDcPVGyHTWf0jIgp+DOKXjoW/UEjERLszH1EyINjRamqu
         HXN+C0ChPIVjXNfi3OhqQF0d4sOzcHHzlT83/lUF7TesQy+HxVlM6t33yCWavWdyOWT1
         7Gbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M6VlN0FD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11sor43343690jal.7.2019.02.28.01.36.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 01:36:14 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M6VlN0FD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Lbf9iBAembtNVXUoSFl1FHGTfKBuTmZnwlMrEQLyCYM=;
        b=M6VlN0FDCxzy9L9tvVrmsP4wKEV6kZv2zmBLCsXusXCxhwuBra9JRRtOUWEi+6dH5F
         5lmcd8ZCdeAgiX5uPa4Nn/gFjQKYOoQPKtXAcQZw8MDg05PcKcxIN2bAYM+S+E/jymqB
         3UwQqLqJRJQzWEtuQnB2U4Bt7cigsOy4HDw2to1J0hbP0UrRi15D3mypu4xnwKrPiV69
         aeHR2NFPIfapSKrnFChtoX50Q/Sqn8nbHAkxr6Y4/9ikXETjO1C5PVi95xbFfBslww7L
         kTCco0AACf668EW59kLxlvAFz0Y+RkfPXvJ83DnxlPiJsjnxDrGDN/SXEtsKacDsnrIh
         CzFA==
X-Google-Smtp-Source: AHgI3IZ1Fnpduc8pyB5r7nzmFUI8CVCE4UemaWlVQLPPb7xrgdvBM/GpbM9sfMxvsLtl7eLrQ7X+5TWkiC/o8OxQY+g=
X-Received: by 2002:a02:13ca:: with SMTP id 193mr4074878jaz.117.1551346574678;
 Thu, 28 Feb 2019 01:36:14 -0800 (PST)
MIME-Version: 1.0
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com> <CAFqt6zYd=NPHKwQ2Pz-tQ4NF7YJ07UrfXVjSmtHi5eiqiPq=Bw@mail.gmail.com>
In-Reply-To: <CAFqt6zYd=NPHKwQ2Pz-tQ4NF7YJ07UrfXVjSmtHi5eiqiPq=Bw@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 28 Feb 2019 17:35:38 +0800
Message-ID: <CALOAHbDNTmPZSPhNDoBHQfma4iOKOAXgU5=D1LZap_90APFPKg@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, ktkhai@virtuozzo.com, 
	broonie@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 4:59 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> On Thu, Feb 28, 2019 at 1:44 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> > In the page alloc fast path, it may do node reclaim, which may cause
> > latency spike.
> > We should add tracepoint for this event, and also mesure the latency
> > it causes.
>
> Minor typo : mesure ->measure.
>

Thanks for your correction.

> >
> > So bellow two tracepoints are introduced,
> >         mm_vmscan_node_reclaim_begin
> >         mm_vmscan_node_reclaim_end
> >
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
> >  mm/vmscan.c                   | 13 +++++++++++-
> >  2 files changed, 60 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index a1cb913..9310d5b 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -465,6 +465,54 @@
> >                 __entry->ratio,
> >                 show_reclaim_flags(__entry->reclaim_flags))
> >  );
> > +
> > +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
> > +
> > +       TP_PROTO(int nid, int order, int may_writepage,
> > +               gfp_t gfp_flags, int zid),
> > +
> > +       TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
> > +
> > +       TP_STRUCT__entry(
> > +               __field(int, nid)
> > +               __field(int, order)
> > +               __field(int, may_writepage)
> > +               __field(gfp_t, gfp_flags)
> > +               __field(int, zid)
> > +       ),
> > +
> > +       TP_fast_assign(
> > +               __entry->nid = nid;
> > +               __entry->order = order;
> > +               __entry->may_writepage = may_writepage;
> > +               __entry->gfp_flags = gfp_flags;
> > +               __entry->zid = zid;
> > +       ),
> > +
> > +       TP_printk("nid=%d zid=%d order=%d may_writepage=%d gfp_flags=%s",
> > +               __entry->nid,
> > +               __entry->zid,
> > +               __entry->order,
> > +               __entry->may_writepage,
> > +               show_gfp_flags(__entry->gfp_flags))
> > +);
> > +
> > +TRACE_EVENT(mm_vmscan_node_reclaim_end,
> > +
> > +       TP_PROTO(int result),
> > +
> > +       TP_ARGS(result),
> > +
> > +       TP_STRUCT__entry(
> > +               __field(int, result)
> > +       ),
> > +
> > +       TP_fast_assign(
> > +               __entry->result = result;
> > +       ),
> > +
> > +       TP_printk("result=%d", __entry->result)
> > +);
> >  #endif /* _TRACE_VMSCAN_H */
> >
> >  /* This part must be outside protection */
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ac4806f..01a0401 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -4240,6 +4240,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >                 .may_swap = 1,
> >                 .reclaim_idx = gfp_zone(gfp_mask),
> >         };
> > +       int result;
>
> If it goes to v2, then
> s/result/ret ?
>

Sure. Will change it.

> > +
> > +       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > +                                       sc.may_writepage,
> > +                                       sc.gfp_mask,
> > +                                       sc.reclaim_idx);
> >
> >         cond_resched();
> >         fs_reclaim_acquire(sc.gfp_mask);
> > @@ -4267,7 +4273,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >         current->flags &= ~PF_SWAPWRITE;
> >         memalloc_noreclaim_restore(noreclaim_flag);
> >         fs_reclaim_release(sc.gfp_mask);
> > -       return sc.nr_reclaimed >= nr_pages;
> > +
> > +       result = sc.nr_reclaimed >= nr_pages;
> > +
> > +       trace_mm_vmscan_node_reclaim_end(result);
> > +
> > +       return result;
> >  }
> >
> >  int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
> > --
> > 1.8.3.1
> >

Thanks
Yafang

