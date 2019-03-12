Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD48C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:05:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C0FA206DF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:05:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mOW5+EKM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C0FA206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72038E0003; Tue, 12 Mar 2019 07:05:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E22028E0002; Tue, 12 Mar 2019 07:05:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D384C8E0003; Tue, 12 Mar 2019 07:05:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A88CD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:05:20 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id i24so1497730iol.21
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:05:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xH7u0SIa2NIqLp+XLrFdsgjL0uBSb7uHvpHDRDB7p5U=;
        b=Gf4lmTtgnP30BeKepE3ShhrvrUz/m0ITE+rmV12ZDUCDj0qkz/A0Yq+e+n6baei9fM
         eCRj/WRXOjSrlL+hOqqDJTysdmSc+vlR00AjQOk5synfSkFckMT5Sg4bJvwcnTRbJ1pR
         jNF6QovxPrWDx2qhdweoE2c9dTIbZeelO7+p2YznlwAVZ0kp/phvwq7xQZ9ZtDwH6lvV
         lD8aEKCDHUGq8a1599zPvEtjZT4Fjvm2BpFMifrNSjT3LztQ2DsMMIEZWkLPrfWW65J3
         aUt5OccT9wv0IF8xj6EOl5ttNNKuWmvQtH5HhojoomQ5Prir2oBNlEAVc37qxG7Sb02g
         YKOA==
X-Gm-Message-State: APjAAAU4XZKtYVwXvy1t+dBsXl/CKISPs9jJ2WsUOghj/Jtx/aRy8KIo
	SblOV5uMXeyIgoIE/Q6joLVo4j8HNLU8JVau88X7P/ow0NQWKs6YoEkDouavJHiCIDcKKOegeb3
	6xjKIUJHR16IIJdxc9C/56Y+c5KRO8qCTZ8wBNLvfruRekBNJQGJjU+bICz4KjAyWEuvns8bWh1
	m0IQ72Hdxvv0FxBSjBzryujnnmmtYmb7QtDrup6yYKpYfIo9XYTFy/37xjCgQHZUZJYKv4fpj7+
	lQwTWRU+CMeLiLd3zWLcPbqjomi8HhmQA9plfoCsCNw1hfGeD3sajFlGWobYtv4le4s1uPoCC4g
	KkXZyEdnc83hmKE3Ei2bmCGtDwbvhRx+gWdr2Y2a92idZpp2O9BXi7cAADpAaMGGlg72qmdj9L1
	E
X-Received: by 2002:a24:5a8d:: with SMTP id v135mr1618032ita.87.1552388720436;
        Tue, 12 Mar 2019 04:05:20 -0700 (PDT)
X-Received: by 2002:a24:5a8d:: with SMTP id v135mr1617976ita.87.1552388719297;
        Tue, 12 Mar 2019 04:05:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552388719; cv=none;
        d=google.com; s=arc-20160816;
        b=ocEvZalGIYq9fG7zLV1R3E1KoNNFGmTyxk+n7i/pcETTGZjPkgJseBiAxjOwIKcK2a
         wVwe1n3alG3VDhUIE0200UqJ7R6VsEAmfgSItXNeMxcUvRfoVQPKjIa6Dqlieh+Yr5ul
         VyFAKOwh9Q+iIIPNOMpJgfu/n0TGjkcgPheklyjyttNj2rP6/G2ayKuMLe8vK08pdAHD
         hP/ffCTvbumD9XlhxT4pmF/BwhHqZa91BPdxAk7y9hJBTPr5/UQwckNtwGJfF/lYk3IE
         4T8K8aujVtUSiV6Mp4kKt7H36hJvdSUb7zzWsEp/FsyjHUcUZT0P34FOPphARSDnMJqC
         0DwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xH7u0SIa2NIqLp+XLrFdsgjL0uBSb7uHvpHDRDB7p5U=;
        b=jtXT1mvE7ap5oMO7zvef+/Vqr1hCXLhGFlMdxfJGaFLBuPe8HC20V5VFEG6agyr1+O
         NJOauk/JBVGfFWhaZPwt90yVTb820NM4RNZC4tsJ5MzRZsb8Q8TnDAUCBo6FxOp9Hyo5
         8nNdtHAtfNK/1DTsMEf7fQvYrHWUG750WXY8hY+zWlIXR2Dny4yqqEPn4pU3mdjA2NcH
         CoWMgL3D7ChQSGWHJsBUBBSaIFpuv5QSsLtNtVnhrYwoEgBuJfAgn3uBG0WgxVmQUEoM
         kah+scokJMfcy3HDn++0vaV/REQ+Hl34QFm7kGliU/iMLAcu5kkZPx4VCCugOQPyPlcY
         qx+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mOW5+EKM;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2sor595914ios.3.2019.03.12.04.05.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 04:05:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mOW5+EKM;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xH7u0SIa2NIqLp+XLrFdsgjL0uBSb7uHvpHDRDB7p5U=;
        b=mOW5+EKMTy+WiyZtH8detQ3wUr/c7TNL1Qy/LragZbtl6h2wdtk49YpuBuEexJQlsa
         lj/VBzbcVbMX9yaYBUWfsQ0b2NhR9CXKz8alLTdwboeei/qmPJnXqLG8iXsTOscAjjtt
         BPWsJi0A6suM2TbTuXNmpBd6Phl7VhP5Bs3JpSRno1kE3EhPCbL3OmVCeuasv/g7wd6A
         qgANJkBulCV5vrq4nIXXatCsj+DHQvBUNkXsDgLx+iPRf1AM6GTmRBfwRN8ns3HckGyH
         hXZyUvVqNQA2PhtNZu6YCe372FG3VMhaerjz6N3zJZdaJkrIc9zUGliaB8LDWp7BE1c7
         AZEg==
X-Google-Smtp-Source: APXvYqweUbWZD1AYGdvU7fmlc//2ygm4OyFUT2sT8YLocP/dIa+DgeNXPueNq3IZMDBFiLToCtAqmFh43FtBmqfwndc=
X-Received: by 2002:a6b:c3cc:: with SMTP id t195mr7892691iof.11.1552388718871;
 Tue, 12 Mar 2019 04:05:18 -0700 (PDT)
MIME-Version: 1.0
References: <1551425934-28068-1-git-send-email-laoar.shao@gmail.com> <20190311084743.GX5232@dhcp22.suse.cz>
In-Reply-To: <20190311084743.GX5232@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 12 Mar 2019 19:04:43 +0800
Message-ID: <CALOAHbDHM1mJ3X9x3vFpDagd81T+hrb7_xdqM12x6JQXuHqwxA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: show zone type in kswapd tracepoints
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 4:47 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 01-03-19 15:38:54, Yafang Shao wrote:
> > If we want to know the zone type, we have to check whether
> > CONFIG_ZONE_DMA, CONFIG_ZONE_DMA32 and CONFIG_HIGHMEM are set or not,
> > that's not so convenient.
> >
> > We'd better show the zone type directly.
>
> I do agree that zone number is quite PITA to process in general but do
> we really need this information in the first place? Why do we even care?
>

Sometimes we want to know this event occurs in which zone, then we can
get the information of this zone,
for example via /proc/zoneinfo.
It could give us more information for debugging.


> Zones are an MM internal implementation details and the more we export
> to the userspace the more we are going to argue about breaking userspace
> when touching them. So I would rather not export that information unless
> it is terribly useful.
>

I 'm not sure whether zone type is  terribly useful or not, but the
'zid' is useless at all.

I don't agree that Zones are MM internal.
We can get the zone type in many ways, for example /proc/zoneinfo.

If we show this event occurs in which zone, we'd better show the zone type,
or we should drop this 'zid'.


> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  include/trace/events/vmscan.h | 9 ++++++---
> >  1 file changed, 6 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index a1cb913..4c8880b 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -73,7 +73,10 @@
> >               __entry->order  = order;
> >       ),
> >
> > -     TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
> > +     TP_printk("nid=%d zid=%-8s order=%d",
> > +             __entry->nid,
> > +             __print_symbolic(__entry->zid, ZONE_TYPE),
> > +             __entry->order)
> >  );
> >
> >  TRACE_EVENT(mm_vmscan_wakeup_kswapd,
> > @@ -96,9 +99,9 @@
> >               __entry->gfp_flags      = gfp_flags;
> >       ),
> >
> > -     TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
> > +     TP_printk("nid=%d zid=%-8s order=%d gfp_flags=%s",
> >               __entry->nid,
> > -             __entry->zid,
> > +             __print_symbolic(__entry->zid, ZONE_TYPE),
> >               __entry->order,
> >               show_gfp_flags(__entry->gfp_flags))
> >  );
> > --
> > 1.8.3.1
> >
>
> --
> Michal Hocko
> SUSE Labs

