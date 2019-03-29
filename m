Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 282CBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8E412082F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bna4qE8U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8E412082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6548B6B000C; Fri, 29 Mar 2019 04:49:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DC136B000D; Fri, 29 Mar 2019 04:49:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47CE26B000E; Fri, 29 Mar 2019 04:49:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C77C6B000C
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:49:10 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id e124so1496244ita.4
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:49:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=H6ZdwQueb0j8nZ9Wyj4P/4Ao5T12rKfCiN5J+my2VQs=;
        b=Hbk9ccIGI0I08eciaOZn6o/eD7p66Vvym3qpZ+9qfbwVRzY/JP1EVqjjfBeuCyvR41
         /oQifAh3AhHP6YL3aUQ67BgXFlKtGYTeJ2kWHwyzxUmhkeaiZEJslZug+PTBaQAMsd5r
         xpcmQPcfnxSz+nZSDWkc4+EmdIehlhDDALCwdA+l2AeUS6viaGgvgoVCfWwmG/N2sR6a
         DGl51QWrixWQoGb+T5fzR+3looFB27oQuRhrMpkGv+s8OeiGVrAbfzzqOaSATj08ICsc
         UVs1bhwHijPSUamSNrHCAXVCusRf1itWVLXMxK9zjDEaYpntybp0dmAYW5UmJa/wp0PR
         VoAg==
X-Gm-Message-State: APjAAAVOAjcxCelqr2oU91yGy1CiLKhnChDgOj+bq5HK8QvrqAKE2Yd4
	chg1ig50hl7NjvoKHISoz642GfSa0jNy0apQOBlcMWfy9uJ+ubpqKxW7wrbz75tXv0Wh7T72FXh
	IQQySeLQW+xHVbAVilq1DfpLuV6guBcVKhmpsE1euwGfPhYex7mGeaLNjevRv4Sb7VQ==
X-Received: by 2002:a05:660c:683:: with SMTP id n3mr3624542itk.70.1553849349841;
        Fri, 29 Mar 2019 01:49:09 -0700 (PDT)
X-Received: by 2002:a05:660c:683:: with SMTP id n3mr3624516itk.70.1553849349013;
        Fri, 29 Mar 2019 01:49:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553849349; cv=none;
        d=google.com; s=arc-20160816;
        b=nIHiLRQj/SgZ7dm4NmKrntVmWU2BFtwxfTwjk7QZRKGS9fGfcz8FTA2OFuu110pTSq
         MGVykzL6TV63dExD1jWKMabuNeQk1scHq/ZGq/4zpyV6bWygoHUTKK+FPWmYYUlEQVSR
         tNCN6Vfq3VR4nTmI9ZMY0G88XnziM/wNQwmDjm0ezsY2qlG3C3hS5c/UtQQnGHl0hZp9
         oTrcaIo8dvNucDYmr9UTL96vfgI8XZT75h/P/urf4DjQqqmffZrBjXIOKZV1RMjYKuoD
         NrUUPQoWO0Dgl7QYojIFrGTalU7yHIa7Ip0Re7+aM2C/giB1ggs0YSh0KCPqEq7Itp79
         hU7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=H6ZdwQueb0j8nZ9Wyj4P/4Ao5T12rKfCiN5J+my2VQs=;
        b=vTHLPd17AhJrhJYJpeCYYomieP8+5dc3alT2ZZWoa+MBEIA1tZeKgt5GZr6rfxBCm7
         VP+JU/gmlNIru3nTZ6+ZD/dM629r018HzFvXuIOT3+5udw+ZoMZeMuvdbWTDe5N2T0/3
         mMdJiSpVR19vyEzJi3I+Fval2hJYpqVLkv8Djlrn6WOwa/ztDvw6vrH8qNiOEW9Brf+Z
         iWgncwGLmeFS0oB7PJsFPgqFqr7EdwUyrgMmDbr2nt5CxyKG0Ay0JXzsswWuYbJ710NV
         UFTlJsMOFQtdUEW7j+D175eIRvR0Y1UKx88c1s03UOD2PM2Y+RCty4c2NTeMdRsmCkbI
         7mUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bna4qE8U;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n129sor3818239jaa.12.2019.03.29.01.49.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 01:49:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bna4qE8U;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=H6ZdwQueb0j8nZ9Wyj4P/4Ao5T12rKfCiN5J+my2VQs=;
        b=bna4qE8UnwEK+uBn2eB5kPQJRUT658u8avJGwds9/Vf8BEGlCqtlwq4hEjZCi9RFFX
         vYkdznV/WzKt7dtV+LMkx/AtaKrVPVUgA7RMW2uu2+H6YZvq7/yPw4aPk738LZAQ52TQ
         V+f8dnz+EKLAgMHumph+a8E0T3lXtwxzd1vipBOPg15idmOlDDAyNp9unyi/HUWIRafQ
         MZtI4CKpUh5+R5bum1QEOTge775OjNhIQnCyb6zwcfsDl7WxkmjBXg37+33pyiAuYxBX
         sa/KPi8vjIH0LKIPdqnMQtFNTATCr5teN/Sii4t97pJN16v1wanOza4IDPBxNLvwox9a
         Nieg==
X-Google-Smtp-Source: APXvYqwbgLFf5avyfY4bGK3hiMtuwj8CfiZ6ZLA9AqRf9sj9+g1IlduT8W65aYNaFmEQjTCba85hLjflncTP0fKwN40=
X-Received: by 2002:a02:13ca:: with SMTP id 193mr34566242jaz.117.1553849348697;
 Fri, 29 Mar 2019 01:49:08 -0700 (PDT)
MIME-Version: 1.0
References: <1553848599-6124-1-git-send-email-laoar.shao@gmail.com> <60f6a5fd-e4d3-b615-6f41-cc7dd16d183c@suse.cz>
In-Reply-To: <60f6a5fd-e4d3-b615-6f41-cc7dd16d183c@suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 29 Mar 2019 16:48:32 +0800
Message-ID: <CALOAHbC7PqQ7UMm5Az=BAz9_hppYMWgNvxhq7EhqOkX0rWuQCA@mail.gmail.com>
Subject: Re: [PATCH] mm/compaction: fix missed direct_compaction setting for
 non-direct compaction
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, mgorman@techsingularity.net, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 4:45 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 3/29/19 9:36 AM, Yafang Shao wrote:
> > direct_compaction is not initialized for kcompactd or manually triggered
> > compaction (via /proc or /sys).
>
> It doesn't need to, this style of initialization does guarantee that any
> field not explicitly mentioned is initialized to 0/NULL/false... and
> this pattern is used all over the kernel.
>

Hmm.
You mean the gcc will set the local variable to 0 ?
Are there any reference to this behavior ?

Thanks
Yafang

> > That may cause unexpected behavior in __compact_finished(), so we should
> > set direct_compaction to false explicitly for these compactions.
>
> It's not necessary.
>
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > ---
> >  mm/compaction.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 98f99f4..ba2b711 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -2400,13 +2400,12 @@ static void compact_node(int nid)
> >               .total_free_scanned = 0,
> >               .mode = MIGRATE_SYNC,
> >               .ignore_skip_hint = true,
> > +             .direct_compaction = false,
> >               .whole_zone = true,
> >               .gfp_mask = GFP_KERNEL,
> >       };
> >
> > -
> >       for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> > -
> >               zone = &pgdat->node_zones[zoneid];
> >               if (!populated_zone(zone))
> >                       continue;
> > @@ -2522,8 +2521,10 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> >               .classzone_idx = pgdat->kcompactd_classzone_idx,
> >               .mode = MIGRATE_SYNC_LIGHT,
> >               .ignore_skip_hint = false,
> > +             .direct_compaction = false,
> >               .gfp_mask = GFP_KERNEL,
> >       };
> > +
> >       trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
> >                                                       cc.classzone_idx);
> >       count_compact_event(KCOMPACTD_WAKE);
> >
>

