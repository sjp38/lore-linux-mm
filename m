Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EA51C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:25:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F6A521BF6
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:25:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FbkIwlIl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F6A521BF6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C6D36B000A; Tue, 23 Jul 2019 04:25:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 877898E0003; Tue, 23 Jul 2019 04:25:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 765D88E0002; Tue, 23 Jul 2019 04:25:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57DED6B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:25:04 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f22so46397517ioj.9
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:25:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QvEjpb8VOGWRfWV86Nfrv4SSQrXAdSVN2AFcK7xH6a8=;
        b=ERDPqyUwi7etjDSLFQPq/ZZRK6AisGdgTUDxpnqhhVnxCHMV8kda0NYUAQn1hSctLT
         OkDT2d+eDEbajELwNcpzCOQ8uhjGMOOjOLvYNUc/Ze14ecr+456sLtUtIt2immYtOCm+
         Xd1PGJHkz1yDhY13wh7jnJF/AQO8Uwm6h8oZ3NQjv7g1WqeZfgWIl65yw/KjYtAKebJH
         AJLBsdwKJLaMqPrmxzyerb3fKQe5af3J68gjGM/x3tY1T5QPZs90XAYg2TmCb/ZcKl0O
         VveBgIF2VwYuWEOocub65XG6E8Qz4eEbTUwsCMcPznBsnlNaYk6SeaRBJ07xPDjzjfQo
         3Bqw==
X-Gm-Message-State: APjAAAWVXrGc5ktIhUonLAgJ3jrup8mpaTlGUH4k12SJ2vb09OPL0Oxx
	YQXd0PxnbyMQLFwk6RDhqjiMleHeSFvpCmoaiws4DGN0Fy6JyFp3eN6EJYi5+7O3dzewpz46oNE
	OrgGS+eKjM8SK+TAhEZYofOsw8ZFwXx80AWyjO8JfVwihWwL5SldwiTlnS71tJBSBSQ==
X-Received: by 2002:a02:3904:: with SMTP id l4mr77203895jaa.81.1563870304071;
        Tue, 23 Jul 2019 01:25:04 -0700 (PDT)
X-Received: by 2002:a02:3904:: with SMTP id l4mr77203864jaa.81.1563870303492;
        Tue, 23 Jul 2019 01:25:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563870303; cv=none;
        d=google.com; s=arc-20160816;
        b=sgbiYdMRQTrD8DxW0eVapgFCwqbmFi32+Fd3VUC9gA1NhALrBcrqcyOi3focWpb8FT
         Q3VAkZiW9dK9Cfphug5gFEnEIvt44JgKnIe0FVwwk3zXEXJU8Kc/3CbyRyNdYDy4o8sq
         YjHWDnd50Mf2soIbYTASEuu8be8MViPyg6YkyTyxs1Z/rw9tsE9Xtwq5SN28k0zuiaiW
         J8vSDbt2To2t9qAUU02sDXyMVtk8DzHYfkqPSUfePMMa9bfSLU3mFQn3RPpQvlq6W9nd
         OxMIBku58V7cFynZZZOG8vfwic7E61poHuMHuXU1UWwTyoAQkOBxKWcqoAONVevBCODs
         zLqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QvEjpb8VOGWRfWV86Nfrv4SSQrXAdSVN2AFcK7xH6a8=;
        b=ADWTCDKq1ljkDG8rxYpKAOWKmUXLfRLCb9otuRLEIwFC9TjSUso1VK+aFwiovtctDW
         EONmM25gVD7AWhAXtjZ4Sdhowrv5wT1ygRWojnPLyY3NmK2PzKSPmSofcJAR6011IJda
         ctDUIk9p9E8/xFD/1wSVZzWO1adjVVOtGIkgst1ernUsA9QsOftVU/jBTUB8V5/FhQmA
         imY9/zM94EuwxuDcwrqn97Dnqh3Wt6x4GocKOMYiZe7Z6x2ZaTADr6SuMuvktYw5Bo6B
         G3Yxz2cps6Ao+KXkYt9b2/NmCCUo7uKPMXbWJl5O+6QP6WKy3Q91+f4UyTW4TJ+WZtae
         IY5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FbkIwlIl;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor28905808ion.28.2019.07.23.01.25.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 01:25:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FbkIwlIl;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QvEjpb8VOGWRfWV86Nfrv4SSQrXAdSVN2AFcK7xH6a8=;
        b=FbkIwlIlS1TYUcHILFMb5YLK00mcGuAH729yUplJEqQZK6NnQTF/h6WI1TbgE9HeEn
         eQZO7eUePNnQGS3hXyPg9/zCgKS8zpmhBErkEx+qReti8weQDHG3Xp0q+8zscNj4Aq94
         i/7XmZ/n5hgdYGTpo7CSAoRa6ERTbdkjKiGwnMt6R4zrJZfB/t/obd1iRRSDlEqlWirk
         +ZtyTq1Ol3Aq/jDy4KOn28d2D2oPTuofxm6F9EKTQjJ++hbLOtCMedY6w1MmmTJtHJdx
         DN7HdehDoQy2KPbqLouF0NhNBQ02A4usNRkqruZdiz35ULWDd2DozzIKKZf7EtLwTaKC
         cTPA==
X-Google-Smtp-Source: APXvYqytNEQRHhDgLnZhvVouGpdBq2X63wEu+gHSTSv/O/F/wJL6CllQdNI0cLECF87DxXkAq35STZhiCQHW+1ecIxQ=
X-Received: by 2002:a5d:8702:: with SMTP id u2mr50058963iom.228.1563870303256;
 Tue, 23 Jul 2019 01:25:03 -0700 (PDT)
MIME-Version: 1.0
References: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com> <20190723081218.GD4552@dhcp22.suse.cz>
In-Reply-To: <20190723081218.GD4552@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 23 Jul 2019 16:24:27 +0800
Message-ID: <CALOAHbCmE+hznGdZB9SyPdqN9WV8hvfMMqxZSN5vXHnn4oarzw@mail.gmail.com>
Subject: Re: [PATCH] mm/compaction: introduce a helper compact_zone_counters_init()
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Mel Gorman <mgorman@techsingularity.net>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 4:12 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Tue 23-07-19 04:08:15, Yafang Shao wrote:
> > This is the follow-up of the
> > commit "mm/compaction.c: clear total_{migrate,free}_scanned before scanning a new zone".
> >
> > These counters are used to track activities during compacting a zone,
> > and they will be set to zero before compacting a new zone in all compact
> > paths. Move all these common settings into compact_zone() for better
> > management. A new helper compact_zone_counters_init() is introduced for
> > this purpose.
>
> The helper seems excessive a bit because we have a single call site but
> other than that this is an improvement to the current fragile and
> duplicated code.
>

Understood.

> I would just get rid of the helper and squash it to your previous patch
> which Andrew already took to the mm tree.
>

I appreciate it.

Thanks
Yafang

> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Yafang Shao <shaoyafang@didiglobal.com>
> > ---
> >  mm/compaction.c | 28 ++++++++++++++--------------
> >  1 file changed, 14 insertions(+), 14 deletions(-)
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index a109b45..356348b 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -2065,6 +2065,19 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> >       return false;
> >  }
> >
> > +
> > +/*
> > + * Bellow counters are used to track activities during compacting a zone.
> > + * Before compacting a new zone, we should init these counters first.
> > + */
> > +static void compact_zone_counters_init(struct compact_control *cc)
> > +{
> > +     cc->total_migrate_scanned = 0;
> > +     cc->total_free_scanned = 0;
> > +     cc->nr_migratepages = 0;
> > +     cc->nr_freepages = 0;
> > +}
> > +
> >  static enum compact_result
> >  compact_zone(struct compact_control *cc, struct capture_control *capc)
> >  {
> > @@ -2075,6 +2088,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> >       const bool sync = cc->mode != MIGRATE_ASYNC;
> >       bool update_cached;
> >
> > +     compact_zone_counters_init(cc);
> >       cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
> >       ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
> >                                                       cc->classzone_idx);
> > @@ -2278,10 +2292,6 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
> >  {
> >       enum compact_result ret;
> >       struct compact_control cc = {
> > -             .nr_freepages = 0,
> > -             .nr_migratepages = 0,
> > -             .total_migrate_scanned = 0,
> > -             .total_free_scanned = 0,
> >               .order = order,
> >               .search_order = order,
> >               .gfp_mask = gfp_mask,
> > @@ -2418,10 +2428,6 @@ static void compact_node(int nid)
> >               if (!populated_zone(zone))
> >                       continue;
> >
> > -             cc.nr_freepages = 0;
> > -             cc.nr_migratepages = 0;
> > -             cc.total_migrate_scanned = 0;
> > -             cc.total_free_scanned = 0;
> >               cc.zone = zone;
> >               INIT_LIST_HEAD(&cc.freepages);
> >               INIT_LIST_HEAD(&cc.migratepages);
> > @@ -2526,8 +2532,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> >       struct compact_control cc = {
> >               .order = pgdat->kcompactd_max_order,
> >               .search_order = pgdat->kcompactd_max_order,
> > -             .total_migrate_scanned = 0,
> > -             .total_free_scanned = 0,
> >               .classzone_idx = pgdat->kcompactd_classzone_idx,
> >               .mode = MIGRATE_SYNC_LIGHT,
> >               .ignore_skip_hint = false,
> > @@ -2551,10 +2555,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> >                                                       COMPACT_CONTINUE)
> >                       continue;
> >
> > -             cc.nr_freepages = 0;
> > -             cc.nr_migratepages = 0;
> > -             cc.total_migrate_scanned = 0;
> > -             cc.total_free_scanned = 0;
> >               cc.zone = zone;
> >               INIT_LIST_HEAD(&cc.freepages);
> >               INIT_LIST_HEAD(&cc.migratepages);
> > --
> > 1.8.3.1
>
> --
> Michal Hocko
> SUSE Labs

