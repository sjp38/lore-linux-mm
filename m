Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E780C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:30:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E12FD2083D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:30:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E5znePB7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E12FD2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FDBE8E0006; Tue, 12 Mar 2019 12:30:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AD3C8E0002; Tue, 12 Mar 2019 12:30:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A15C8E0006; Tue, 12 Mar 2019 12:30:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4C98E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:30:35 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id q141so2709377itc.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:30:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lFIgb7ff40bY7X5nCfm1fQ0F0XRSiXuRUY1WM002qKY=;
        b=DbsCyywQqMNrPJ1RXCqeKOhH+S3GzBk9H62WB3CjK6kp7os5N8w0lZ/UEOThVe1oxK
         k2qSB7rQxhFC19c2gGzPKjetaE6OSRXzo7iPMKjbgpyJFyCmjNZ6NPg/uTBm+YQe+S2d
         shNupRS5IN4nmSjYZbwvNFVQ8f5yvHa87UNJQ2NjbKRTJUvZGaaqWpOVEuvZhEIeXRLz
         C/bLInsuCXhGXLCnX3xo0R6pZiPvwba36Fxfdd1d2DK+1+OuveQ7FaiBvwt5zQfmv5q+
         6G98ANx/LA4h1IFV8VMgBYJ5F9ergQ+FA1740SDtpuK3rc6NGfNCqQdXwtkEKw23F/B4
         cmyw==
X-Gm-Message-State: APjAAAUwORWptC1sjt+yT1Z2YfncWova2MiTZAD5jVigrZrr8HtrE8Ci
	tMsRisO5o7SOaEFfse7UScwey0JQZi5dalK9wlQmdML3U+L+xkPrkhzfPQIoiQSW2fp2enwRdN7
	BWxjZbWfwV5AM8SFhxPIbUdbpa4w5JlhNowJ4RCbckluvswWMGgCD1QV5Vmr2QYk8et+BZT/UvP
	7ybz0fsIx2io6uJQQYWozeHqosMUh8sXa31e3cQvFyr3og/IgDUQfb+nHBxmHLF4504va9quZIC
	htwxNAmiSu/p8rnfXm0IsdBL5tZwr0eDoKtck/vDhGrgCpVwh0PRD81Tz/u1uDMvSssYs9BbBb8
	UGnBXhp1XM5NY2tipuGLp1FM+FMW2UDkbcxbl7ruCgxx8Hjb9/116hTP7WO2G8P71DPkl86N9i2
	s
X-Received: by 2002:a24:29c8:: with SMTP id p191mr2389973itp.115.1552408235035;
        Tue, 12 Mar 2019 09:30:35 -0700 (PDT)
X-Received: by 2002:a24:29c8:: with SMTP id p191mr2389930itp.115.1552408234064;
        Tue, 12 Mar 2019 09:30:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552408234; cv=none;
        d=google.com; s=arc-20160816;
        b=XsjfZh+5Q+gjc1kDJdefWdgMSpPUFcf1Fo8F/d5AwGFu8QlZ/vwQqtMsW3LjCjYndz
         osIpO21GGqYVE1gLFuZBfpu2Yfj0cL3d7OXHkOoisvE8ui8afcO3DPyd2pFBShjcW4d1
         2Xz1uWorjGTcgAsQpgOooTk4o0SFAWqnKM9oaVShVAITK7coVNYBBHKqOM/1sBy9ZZFC
         3YhjDS6/UNKTrYO8ubjvXESUCK5Fm79YQMxIM4lSmQxuMfNZ8nAqDooRlMg6bdt9ewaV
         VqHb7rXrWVzOHrZ3zg3FHPxvtzZ/uc512GJ0mFXi524mtLSXMZ5zg3/B+hvbhAs0fBXM
         hgsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lFIgb7ff40bY7X5nCfm1fQ0F0XRSiXuRUY1WM002qKY=;
        b=DdKhsAiPbQHMvNE6eN3CV6VFmp+FK29vxB0rurXYAMG37TIcYZflUDI4P1qFlEU4h8
         KzyotMaCOhGwnKYy2r0+JeH0wvhnMLWjO/3CohbHlRxJsXwuf5JTVYBgCotNgsJOybbc
         DcNvqmKhgqwab50Q9I5wfwuJ/5FSC8mxiOIY2Ttq0IAMfoQog8XTHvGriOyARbI2mKMh
         CfaW9ROVQxLvdvA5zu9+kf37IHktuNzWjTnPDSqJvoUV6IeZaVdZkzZLC2HPcaYbjh4S
         wc9GGv3gWSrdepVzHJ3o1EqJMniEHB9t6wQtdfAnz8Bf1jUR7IrGIF0kJH7xwaprTfU6
         zjHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E5znePB7;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d124sor4613194itc.15.2019.03.12.09.30.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 09:30:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E5znePB7;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lFIgb7ff40bY7X5nCfm1fQ0F0XRSiXuRUY1WM002qKY=;
        b=E5znePB79i74DcKgLsllHPgGhvqjM0gOF4kFLD8MvTx2/Yj/eoJjkbmRIwZn19hxWV
         B1tqrtS6wR2Q2Zf204TnhiPNjFwxt6EwMG9183F7yndUc5gnk6k+cx5U7Pd6qRY129Va
         TLMdBlwoLlh+tP4+XEJDUlVOSCzBeAji3lHjxHyRb/SjGntgWto15u/HkCc4jElmUwig
         6DD4sI02ppjm6/oYWSoPePMZd2idcjanXxYZrnoUOIMvINWmn+EDxqxPBjWpp4zNzwQZ
         rNCZ/czKwMyHZet1/q/sOHI9/6wB7R38ch0bLmAurM4ibuFVyKKiLciTERIBIx+pmxbD
         H2qg==
X-Google-Smtp-Source: APXvYqzzRRoLQ/iwtSYDaVnzcrtwVXuwp5QgcZHgye+aPx74hyJiluyLSnlXGdUbEJVyyXkuGfMBiHN27U1sgRs1Bts=
X-Received: by 2002:a24:c043:: with SMTP id u64mr2567877itf.59.1552408233779;
 Tue, 12 Mar 2019 09:30:33 -0700 (PDT)
MIME-Version: 1.0
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
 <1551501538-4092-2-git-send-email-laoar.shao@gmail.com> <20190312161803.GC5721@dhcp22.suse.cz>
In-Reply-To: <20190312161803.GC5721@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 13 Mar 2019 00:29:57 +0800
Message-ID: <CALOAHbBR119mzbkkQ5fmGQ5Bqxu2O4EFgq89gVRXqXN+USzDEA@mail.gmail.com>
Subject: Re: [PATCH] mm: compaction: some tracepoints should be defined only
 when CONFIG_COMPACTION is set
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

On Wed, Mar 13, 2019 at 12:18 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sat 02-03-19 12:38:58, Yafang Shao wrote:
> > Only mm_compaction_isolate_{free, migrate}pages may be used when
> > CONFIG_COMPACTION is not set.
> > All others are used only when CONFIG_COMPACTION is set.
>
> Why is this an improvement?
>

After this change, if CONFIG_COMPACTION is not set, the tracepoints
that only work when CONFIG_COMPACTION is set will not be exposed to
the usespace.
Without this change, they will always be expose in debugfs no matter
CONFIG_COMPACTION is set or not.

That's an improvement.

> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  include/trace/events/compaction.h | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> > index 6074eff..3e42078 100644
> > --- a/include/trace/events/compaction.h
> > +++ b/include/trace/events/compaction.h
> > @@ -64,6 +64,7 @@
> >       TP_ARGS(start_pfn, end_pfn, nr_scanned, nr_taken)
> >  );
> >
> > +#ifdef CONFIG_COMPACTION
> >  TRACE_EVENT(mm_compaction_migratepages,
> >
> >       TP_PROTO(unsigned long nr_all,
> > @@ -132,7 +133,6 @@
> >               __entry->sync ? "sync" : "async")
> >  );
> >
> > -#ifdef CONFIG_COMPACTION
> >  TRACE_EVENT(mm_compaction_end,
> >       TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
> >               unsigned long free_pfn, unsigned long zone_end, bool sync,
> > @@ -166,7 +166,6 @@
> >               __entry->sync ? "sync" : "async",
> >               __print_symbolic(__entry->status, COMPACTION_STATUS))
> >  );
> > -#endif
> >
> >  TRACE_EVENT(mm_compaction_try_to_compact_pages,
> >
> > @@ -195,7 +194,6 @@
> >               __entry->prio)
> >  );
> >
> > -#ifdef CONFIG_COMPACTION
> >  DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
> >
> >       TP_PROTO(struct zone *zone,
> > @@ -296,7 +294,6 @@
> >
> >       TP_ARGS(zone, order)
> >  );
> > -#endif
> >
> >  TRACE_EVENT(mm_compaction_kcompactd_sleep,
> >
> > @@ -352,6 +349,7 @@
> >
> >       TP_ARGS(nid, order, classzone_idx)
> >  );
> > +#endif
> >
> >  #endif /* _TRACE_COMPACTION_H */
> >
> > --
> > 1.8.3.1
> >
>
> --
> Michal Hocko
> SUSE Labs

