Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2143C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:39:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80C90206BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:39:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nPiC2umv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80C90206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EDED8E0003; Wed, 13 Mar 2019 04:39:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19C258E0001; Wed, 13 Mar 2019 04:39:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B3908E0003; Wed, 13 Mar 2019 04:39:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4E6E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 04:39:14 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e1so918132iod.23
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4z+1Xm51hw88YabG5VaHi9SJ7Y/7Pom9XdSwVwq4FwA=;
        b=O1/V75I2Zfyr+W94RWVIO+75xgzBq4s1UiA4ftaUUDW8HH/X4/UdfsYkHpmsKDMsA6
         KpheQy+kngDELeaC6PzarFSTP7uVqlNnTK7a7DYkIBG/6x7x6TCgSQOVH0MUc8vmRxyX
         LGc6NMHLDOLDlk2uXd7qy6etPuxib3KNT/Di/oNbdSV9mIff90ubdhAP3od8qT3uzV7h
         JhjmWBKUup3ipbXw7Di4D19iYwz99GxVxbW0K5rVho9nvlPj+i8TUpQO7tzV6peaFcP7
         UhfqQnLvMWcKnU5UMuDvh64vlJKRs7hhFIBtNIFDQ+rx9ohfd2xVdPeo27+Vajw6q8go
         7g2g==
X-Gm-Message-State: APjAAAX8wGAdaQo8gortnar+eEGaBF4pYAaEA23j5vvyN3v2ZX/xfbOu
	wQWDzQKsf+lxmX4cMvFi0cAMnNz/bzq/TngYqtJdPZC50YXRFZ5y95Cfp9EiT9C6dxsosqk0jE5
	W0IXvdZjZXIoVYZRfRwtv5I9hNAb9tK1v6K66YavKwvjyBpIQZ0747DGlDDWY36PKCA==
X-Received: by 2002:a24:c141:: with SMTP id e62mr1061080itg.4.1552466354620;
        Wed, 13 Mar 2019 01:39:14 -0700 (PDT)
X-Received: by 2002:a24:c141:: with SMTP id e62mr1061051itg.4.1552466353648;
        Wed, 13 Mar 2019 01:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552466353; cv=none;
        d=google.com; s=arc-20160816;
        b=R1CQMvMIrrwA7/Gb1tn5TNtkgwhKTg1LJ+fRF1gNIHMqy0oUzlwHrviLJtoNVik18o
         q+8TOZrn3nuNxdUMGtyJggLo+WaL0sTAtzIPCpFWc35xCyJ1dUJ8+Yja09WUNNUm7f/d
         GHi/PzsN3+CEtvfPDxqYHenAd2n9PI6IykAvobQtVif/O3DP8xw+9IUycW13rzOqE3k6
         au7sMtk3KS09Y/oyv0I8lCpB4tRM7zVxvolwvS+nlw0xJR6dbsNJxWhvQXfYOZqjo6H5
         F2AYOrCh6N3vZeeMz3CmRMtad6CvweRZsDUtD7DuWrrBe38xp5dT7ng/luOE7xyvTohp
         pPwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4z+1Xm51hw88YabG5VaHi9SJ7Y/7Pom9XdSwVwq4FwA=;
        b=lZsoKz2l5KU4qotq5iSOD/o8t6V6jUwNxDvx7N2Qz/SI0Ztkjxh6o92FZGKgqfvpEZ
         VOOIgH6eqHE6DBGzAmWM4rkoe7/N1RVKgFC4Dlrr29FAGnF5k1ok1gjQhte9xWDVCQKQ
         rcoLaZOKFa9gupdM0JRd7LDim5IKcpfNQeq495W2/HSO61lrrvcSCQ92dFEQZ0Ncixq2
         /Tkr/bPYriT2ctYAUuDXWPZYja0Vr1/BsTXFdyzvciurfdwu7rKlkiB1Ok6kTO5XR3Ho
         wB633NtYVy92964h0pf9aUBUDa8MY/hXO2gjXZ6sJ4c7ichZIkpuKzbZP5wiiRixvJ6e
         QQ+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nPiC2umv;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q24sor5682489ion.147.2019.03.13.01.39.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 01:39:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nPiC2umv;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4z+1Xm51hw88YabG5VaHi9SJ7Y/7Pom9XdSwVwq4FwA=;
        b=nPiC2umvzlvJfrIzc3OOXfz2Ba4skeyUyvEXD/zRQ7T6vD4H28uk0m/uzDkWau1enC
         i51dm4HpS/GTtaffqhkdLhd33EBWASe7Wbpl9TRapHWWKZUFEmOC6gXy7Db4l6n3i8WC
         lGxrdre29vAxwYdTig+sPFNPkiK23mCPQtX6F3C3pM1570WuIxAPOB7asZFyGRk0bc9x
         d0kTDSS+96d2AMa6CCYoJOCApe9CcZwVXjvgxYQrrZFwRKDo3RVVzXwD2mxJoZu0xSUT
         HWSfavzrB20Ald+MqbAT1XT+eew5oQz+zHS9K+1fCEhvUNVF0NWQXDWq2ckD4mdMPppJ
         7rTA==
X-Google-Smtp-Source: APXvYqxOZIR3JQ9Rd3c/ZGGzbpowwZ5pm3/X2tep6LbGA6Xudd9Mpl+IQs3B4HYyxnpRc0FX2cvebSO+bYbHiGxDkH4=
X-Received: by 2002:a6b:5d17:: with SMTP id r23mr11303368iob.295.1552466353352;
 Wed, 13 Mar 2019 01:39:13 -0700 (PDT)
MIME-Version: 1.0
References: <1552451813-10833-1-git-send-email-laoar.shao@gmail.com> <20190313080354.GH5721@dhcp22.suse.cz>
In-Reply-To: <20190313080354.GH5721@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 13 Mar 2019 16:38:37 +0800
Message-ID: <CALOAHbCk2cF9caBHfTi53TGozvHpXZQRSALMbM0NMEB1WmwSGA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: drop zone id from kswapd tracepoints
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 4:03 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 13-03-19 12:36:53, Yafang Shao wrote:
> > The zid is meaningless to the user.
>
> This is quite bold statement. We do not know whether that is useful.
> Quite likely not. I would go with
>
> "It is not clear how is the zone id useful in kswapd tracepoints and the
> id itself is not really easy to process because it depends on the
> configuration (available zones). Let's drop the id for now. If somebody
> really needs that information the the zone name should be used instead."
>

Thanks for your improvements on the commit log :-)

> > If we really want to expose it, we'd better expose the zone type
> > (i.e. ZONE_NORMAL) intead of this number.
> > Per discussion with Michal, seems this zid is not so userful in kswapd
> > tracepoints, so we'd better drop it to avoid making noise.
> >
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> > ---
> >  include/trace/events/vmscan.h | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index a1cb913..d3f029f 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -73,7 +73,9 @@
> >               __entry->order  = order;
> >       ),
> >
> > -     TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
> > +     TP_printk("nid=%d order=%d",
> > +             __entry->nid,
> > +             __entry->order)
> >  );
> >
> >  TRACE_EVENT(mm_vmscan_wakeup_kswapd,
> > @@ -96,9 +98,8 @@
> >               __entry->gfp_flags      = gfp_flags;
> >       ),
> >
> > -     TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
> > +     TP_printk("nid=%d order=%d gfp_flags=%s",
> >               __entry->nid,
> > -             __entry->zid,
> >               __entry->order,
> >               show_gfp_flags(__entry->gfp_flags))
> >  );
> > --
> > 1.8.3.1
>
> --
> Michal Hocko
> SUSE Labs

