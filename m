Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6801C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:59:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8597C20842
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:59:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Mit94bSq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8597C20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30E898E0003; Thu, 28 Feb 2019 03:59:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BD4C8E0001; Thu, 28 Feb 2019 03:59:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D6C28E0003; Thu, 28 Feb 2019 03:59:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A528A8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:59:18 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id n193so3733645lfb.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:59:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=egCQeAXTRB2JYiDyIxmRF2m38XvFo+Cg7v5CUmY+D9o=;
        b=KFX0YaVi9f7rr4WypSjqtbCqT32SVB+b1M/o1HT4XgPhX8Iz0LAqLap47LSbStCJuc
         Y+KqSGpCzOrjOxRYFU6MAe6AgnELHE6sF5J8WyuzXbYPMuftTc2q8Eag1SNqiewUxGyK
         EXUlfauwTSOZuIv0D3MHrg7I1/rgiIV4CoBfbwWi69DmrVqtwa1imAqhmC/tKEJMRKIs
         xtOboEQIFd0J7kBrjI8Hl4DSx59wNACTxT/k9z3oc0ZzqBpefpwNQyQvKq4llVXat6P+
         Ig2gM2RMwi72e93MeF2pCDGozU+ytXj+MQQ2oM+gyHfx5ON5rBg9AjXpCE1COk4ljQ1V
         n5Vw==
X-Gm-Message-State: AHQUAuZxX17ZzqKCyc85zNrAUv7UeRH5noNF19w/bqOYEBDuTBKlzQr1
	nxLnBg7sSdKt2UKI9++n0yW/S+YpWq1ddWkGQYZq4y+a15QM6brV9QZV8giNmMOhtox+NtXErbZ
	N28QVlXeEKiNyHfsoGFbCVl8Qh7L6axVmPHUDcpbmPyFz3ysLG6XLAbQdMmkarHrDwmBsG1WnpD
	acoQi5eh4EowsQucQtqrDpxW1f1C6Qt5cqC0mww4Vv229GSLPh5Yqzz3HeIexzvaJ6SSc4JhnG2
	6dh/M//iN5kBu2czSwUru0PzvLKajRh5E0isuh5mtxB2rok1qU/M23J5JRERfspYaPHFkD9wu7o
	Bg4gQ56q4uF3A3PdfEKGSHTM75llBkc89wN7T3IRvaMEM9FeaORskA4zaGjBBrdcANymnMNC/Ws
	4
X-Received: by 2002:a19:a211:: with SMTP id l17mr3424250lfe.144.1551344357714;
        Thu, 28 Feb 2019 00:59:17 -0800 (PST)
X-Received: by 2002:a19:a211:: with SMTP id l17mr3424202lfe.144.1551344356718;
        Thu, 28 Feb 2019 00:59:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551344356; cv=none;
        d=google.com; s=arc-20160816;
        b=amMsN+kmrK0OPzoXzwsIrxIOxbOLa8Crujp1iZp0KvfG3qJ9f19qJkG2K7hT7jldJT
         rcgXaDIcsQc30pdPKr7yM3V+uGr7c3gVdjysPkAYkE2hpKo8SwDVF7aDTjklmZtKATE+
         l5EOuEpRTaKelk8OqQzqOTcaLU5/p4haTTkZKW7JNBZdwjtzXr6Dmmd2CZurNGwBwyPc
         D8R7H8zaBxw5D1uN1qupt5C1JXoYZcG86zFBVm69X2BOiztkWSr0muYfZpqC+F8LKixI
         aMgC04ocYoaIrvsvDpbu4YkqOPIBC9D/yLdFI7hwL24Jmo6x7VqmIfm9L4pIURPnCIxW
         NTgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=egCQeAXTRB2JYiDyIxmRF2m38XvFo+Cg7v5CUmY+D9o=;
        b=RyLYAHQtuRNNdhWih7EeQB7rWUiVWOYOlvIpgKHr7O/oNpEDJ204mtcsAiG64ArdZD
         1SHoKMFrAVO1z9JCVponME8DsnAhUqlJ6Q0RtIhO6xgb6h/XwLOecg0c+SApGv8TWFMV
         YeQc1A6Rp/FFJ1jk7yzZWDkA2qiVRxCHv9KstAu1FHexrwSfd0B8ARjIQNfcbwkKGYj9
         +vDAWxkevKFss1T+mdOfCz48hVjttvmOLcW3ZvJB6DcFJT+ecEqxaa+LkG4GTcsimJnC
         FjRNXEJZ+2+F07duUPOEOJRb0Dk4wQYXkx9XR0PXzgYiHOscSKrDrQC8VxXsublV1QzU
         g3Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Mit94bSq;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h18sor11167825lja.11.2019.02.28.00.59.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 00:59:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Mit94bSq;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=egCQeAXTRB2JYiDyIxmRF2m38XvFo+Cg7v5CUmY+D9o=;
        b=Mit94bSqqhC0QxtoONUF2QAWD1t8Ea6h3VVbRPUisMTjkT669vFlsBJUYiYwOtW4x9
         o9FsIXLq293meu0rJW/MYRlGAlhT788JBdAvJCXt+19gzIWSMZHpLpsDkR73fASS2OKq
         8hWFFDlsDNsN4bGGNI7AeVI3hhy+VU37GzDBIixKUIWidOhMj07PzR+fCcqIyE45gJR8
         53MfAF6t/RGTiHkJgncmWxvsujlurtlRq4OOAQvSFL+qvGOismH5M6YEmUnqIo9xSvFW
         rQR79RwwdT7/9YC2LX9WH8H/7yrwfCUXDs90B2hfT89LCj9BJ4CA2OQ+wz63oVknOWtf
         ToJg==
X-Google-Smtp-Source: APXvYqw09C+8WJZ3W4JuDqncLmQH3LJEkLKPBkrGvHXArDFJ2t8FuT9orNOg47B/bQ0/BmPySfAFJko6Ik98IXh9KG8=
X-Received: by 2002:a2e:3807:: with SMTP id f7mr4065194lja.9.1551344356215;
 Thu, 28 Feb 2019 00:59:16 -0800 (PST)
MIME-Version: 1.0
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 28 Feb 2019 14:29:04 +0530
Message-ID: <CAFqt6zYd=NPHKwQ2Pz-tQ4NF7YJ07UrfXVjSmtHi5eiqiPq=Bw@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, ktkhai@virtuozzo.com, 
	broonie@kernel.org, hannes@cmpxchg.org, Linux-MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 1:44 PM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> In the page alloc fast path, it may do node reclaim, which may cause
> latency spike.
> We should add tracepoint for this event, and also mesure the latency
> it causes.

Minor typo : mesure ->measure.

>
> So bellow two tracepoints are introduced,
>         mm_vmscan_node_reclaim_begin
>         mm_vmscan_node_reclaim_end
>
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                   | 13 +++++++++++-
>  2 files changed, 60 insertions(+), 1 deletion(-)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index a1cb913..9310d5b 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -465,6 +465,54 @@
>                 __entry->ratio,
>                 show_reclaim_flags(__entry->reclaim_flags))
>  );
> +
> +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
> +
> +       TP_PROTO(int nid, int order, int may_writepage,
> +               gfp_t gfp_flags, int zid),
> +
> +       TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
> +
> +       TP_STRUCT__entry(
> +               __field(int, nid)
> +               __field(int, order)
> +               __field(int, may_writepage)
> +               __field(gfp_t, gfp_flags)
> +               __field(int, zid)
> +       ),
> +
> +       TP_fast_assign(
> +               __entry->nid = nid;
> +               __entry->order = order;
> +               __entry->may_writepage = may_writepage;
> +               __entry->gfp_flags = gfp_flags;
> +               __entry->zid = zid;
> +       ),
> +
> +       TP_printk("nid=%d zid=%d order=%d may_writepage=%d gfp_flags=%s",
> +               __entry->nid,
> +               __entry->zid,
> +               __entry->order,
> +               __entry->may_writepage,
> +               show_gfp_flags(__entry->gfp_flags))
> +);
> +
> +TRACE_EVENT(mm_vmscan_node_reclaim_end,
> +
> +       TP_PROTO(int result),
> +
> +       TP_ARGS(result),
> +
> +       TP_STRUCT__entry(
> +               __field(int, result)
> +       ),
> +
> +       TP_fast_assign(
> +               __entry->result = result;
> +       ),
> +
> +       TP_printk("result=%d", __entry->result)
> +);
>  #endif /* _TRACE_VMSCAN_H */
>
>  /* This part must be outside protection */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ac4806f..01a0401 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4240,6 +4240,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>                 .may_swap = 1,
>                 .reclaim_idx = gfp_zone(gfp_mask),
>         };
> +       int result;

If it goes to v2, then
s/result/ret ?

> +
> +       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> +                                       sc.may_writepage,
> +                                       sc.gfp_mask,
> +                                       sc.reclaim_idx);
>
>         cond_resched();
>         fs_reclaim_acquire(sc.gfp_mask);
> @@ -4267,7 +4273,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>         current->flags &= ~PF_SWAPWRITE;
>         memalloc_noreclaim_restore(noreclaim_flag);
>         fs_reclaim_release(sc.gfp_mask);
> -       return sc.nr_reclaimed >= nr_pages;
> +
> +       result = sc.nr_reclaimed >= nr_pages;
> +
> +       trace_mm_vmscan_node_reclaim_end(result);
> +
> +       return result;
>  }
>
>  int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
> --
> 1.8.3.1
>

