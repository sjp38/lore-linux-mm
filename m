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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BE05C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:55:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ED9C2238E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:55:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d9WtcMuR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ED9C2238E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05CCD6B0003; Tue, 23 Jul 2019 01:55:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E398E0003; Tue, 23 Jul 2019 01:55:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E65B58E0001; Tue, 23 Jul 2019 01:55:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3A916B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:55:48 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s83so46014122iod.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:55:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Cc2JunjbxK2/sCbui2fdN9TXKrF81+v+bF4kJyQDgdk=;
        b=kERGp06IcDZtVTom8IKXlqrKKWi4GrFTAgvb90JZGLkAvklDW6G+rksYCFK3iZaXF4
         lq/HyzBou5Txz8wsVjz+eZ0J03BEdxlQXNBJXAvDOrmb/Sp/nnL/0FQ3lEtRMglG4omt
         IpeKaxZ2xSng1XkUG70XnICh8McPW28in2Inz5wyYwv7YjMcq3tflQS0ifVOZ50Iobmc
         c+zzy5n7JnjYw2az24JgCV/qvJGylZFecG/2WYhLeta74mucfeU5aDiOGMsFtp/drNOV
         pSZIJq7IH/zm17QjgmApiZG+ouYhCc99d5cCmKyK0nkoBSBV3AJicrwTu6uCiluqrikE
         dtxQ==
X-Gm-Message-State: APjAAAUgLr2LJFaoLtrVpzdh/1hGOKUNwZrSUVFMF71v4GwrnT9Ayx/v
	WVHqI4fgZsRAsQJ0W0unW0+v0aiBQH/hFhcEwcWzDFjlC9S/4X8G6PsRVIBpr4K9kBlmEWlUo+6
	aUFpDXW0o6OF0IE3eslepGmsReV2zoES+OLNna9BM+8CniHUzm8hqumV+SgVBoT8P5w==
X-Received: by 2002:a5d:915a:: with SMTP id y26mr69853705ioq.207.1563861348489;
        Mon, 22 Jul 2019 22:55:48 -0700 (PDT)
X-Received: by 2002:a5d:915a:: with SMTP id y26mr69853671ioq.207.1563861347954;
        Mon, 22 Jul 2019 22:55:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563861347; cv=none;
        d=google.com; s=arc-20160816;
        b=foXSJNlAQsCcCvhT0IvFCOY4yY47SCQ1tRj2iLOQnyJhUB2kn7UH79RCC0hjZQrl/c
         G9dRcgzJ6IxPQgTRzgBgQrn7sYJOnO59MhFwUvfMMPU17Lk7bItLBJ68m3fOfVIii/rW
         AHRmFSMUihkJ4czG91MCR2QUW4tfg3ccGqyu2CnqaixuT/j5I8i2TU0BlqtfBKG/Kfgz
         3O3yyHSxgFSb24mUJbPqNwJmtP9SsOyHfT+FZokK4n3WupDpq1DWkMO+C5Vr0CoV4dXo
         V4OYq7IXJ49TmVr7jZlT2OxD4bXImgHa2KD+stOCjqw0MidWGv25/7BaNFlOXB0i76Ry
         YF+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Cc2JunjbxK2/sCbui2fdN9TXKrF81+v+bF4kJyQDgdk=;
        b=jg3vzRg5pddpxnrZAK1+azFZlcJS1O+WquWfDJhOHY3/0wwx3KA6FqmcVKhOae+lOl
         +p0o1IKW/Tr6XKwr0ZZ+Sadi3wR7A6suJqedg/Vq1Xd69z28wQw9uztRi2wtVnfrVwqY
         dcXWlvET5+5ZTzeLoH0ZcHY2sPlq91wYDlf1PFBNBvjbA1Eo9dNEldiVpmBSZbD+JGUA
         T1Lu2U89836hPa3R+tWEq2FlHFtdjIfwVcka5FGGemhifcpyzEENMqhwvzrJ6Bl5l4TK
         NXPSlz3wnfigW8e8BEebdjlZg8GcBj7ZkFJX/m5k40WVq+PcYQr7R5CmZQaR6oGw0R7s
         AxRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d9WtcMuR;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor27680636iol.96.2019.07.22.22.55.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 22:55:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d9WtcMuR;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Cc2JunjbxK2/sCbui2fdN9TXKrF81+v+bF4kJyQDgdk=;
        b=d9WtcMuR/UYPJYeriVWihQi/QxtlGJMlbp5C2YSwhn7U3ygXMSk+X4Un/PgJZI2SaP
         3FV37kcIO0Tgr50Ze4589oTXlIIVMMwpjsSe2UBpIctETf7FWxzL5FfAKYJBm9efbJib
         QTg/s49s7P+8xS1sEkMnt/xiaBtSqxJBXo97NyjmocUSsXwqAsa0nmAi7HqPEyUtqUGU
         JF9ACY4xNg5GIiNtheaMn++uqILDe8K8kqgeBCcuwJ/N2HMMvUiXsDuQ9/MpDEmmOU+S
         656pvnOrND+6NsBOuLn+bKsdFqLwuao7RnNblRhNC7/WTmUoTZUeD8V90rFGOzBmXnTE
         ppVw==
X-Google-Smtp-Source: APXvYqxCyfhRoZSDfKmwBKfZg3OsZxUorGwWmdSV053GQ4r2VUwQkKogIpWAvAo/RQ7ew9VUEomYoVDikh1zrfY+AWE=
X-Received: by 2002:a5d:915a:: with SMTP id y26mr69853657ioq.207.1563861347689;
 Mon, 22 Jul 2019 22:55:47 -0700 (PDT)
MIME-Version: 1.0
References: <1563789275-9639-1-git-send-email-laoar.shao@gmail.com> <20190723053645.GA4656@dhcp22.suse.cz>
In-Reply-To: <20190723053645.GA4656@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 23 Jul 2019 13:55:11 +0800
Message-ID: <CALOAHbD3yoqhGGiWsx6Giqkuffb=_sOWV3Vjm2MLjiBKD_+5GA@mail.gmail.com>
Subject: Re: [PATCH] mm/compaction: clear total_{migrate,free}_scanned before
 scanning a new zone
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 1:36 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Mon 22-07-19 05:54:35, Yafang Shao wrote:
> > total_{migrate,free}_scanned will be added to COMPACTMIGRATE_SCANNED and
> > COMPACTFREE_SCANNED in compact_zone(). We should clear them before scanning
> > a new zone.
> > In the proc triggered compaction, we forgot clearing them.
>
> Wouldn't it be more robust to move zeroying to compact_zone so that none
> of the three current callers has to duplicate (and forget) to do that?
>

Seems that is better.
I will post an update.

Thanks
Yafang

> > Fixes: 7f354a548d1c ("mm, compaction: add vmstats for kcompactd work")
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Yafang Shao <shaoyafang@didiglobal.com>
> > ---
> >  mm/compaction.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 9e1b9ac..a109b45 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -2405,8 +2405,6 @@ static void compact_node(int nid)
> >       struct zone *zone;
> >       struct compact_control cc = {
> >               .order = -1,
> > -             .total_migrate_scanned = 0,
> > -             .total_free_scanned = 0,
> >               .mode = MIGRATE_SYNC,
> >               .ignore_skip_hint = true,
> >               .whole_zone = true,
> > @@ -2422,6 +2420,8 @@ static void compact_node(int nid)
> >
> >               cc.nr_freepages = 0;
> >               cc.nr_migratepages = 0;
> > +             cc.total_migrate_scanned = 0;
> > +             cc.total_free_scanned = 0;
> >               cc.zone = zone;
> >               INIT_LIST_HEAD(&cc.freepages);
> >               INIT_LIST_HEAD(&cc.migratepages);
> > --
> > 1.8.3.1
>
> --
> Michal Hocko
> SUSE Labs

