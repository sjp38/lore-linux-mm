Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0428C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:57:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B70F21871
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:57:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ivq82QwW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B70F21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B1AC6B0003; Wed,  3 Jul 2019 01:57:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0642D8E0003; Wed,  3 Jul 2019 01:57:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92EE8E0001; Wed,  3 Jul 2019 01:57:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8A4C6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 01:57:29 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h3so1329966iob.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 22:57:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PTN5uwIluYymv/ulqvQOLWr4+wOTebEj5XIObY2vSeY=;
        b=BylDyMP7Lf9fQ/cP5QolJBIRkRbn1S5TVElj3ZYxOiODHJxYYwBAwojIUkNRMZO4Bj
         i/QGJ2jkHZy8r51T5NlA5hGSgeHCoD9pO3Clo3c2G+vldbMgKAr9Ymu7L9z69tk/GHkM
         8am7NIr4MONQvkdI/6abnRFXDyyAyJZkUBPYwrbkORct7WM27PzsDGikqtUkzOm+1dHW
         wvRiWQl4Ysotq8DigWflCW4UF+/wNx3PVtiEzhkqMVQ4cEuqSPUSlWrid/B4RmTst3JO
         ulffRkD+vLH3t3gFmnwIw2eg7g9etyaCafsbrGu8A1hONNCiDT1mk74wxzFViqRzqjIz
         IP5A==
X-Gm-Message-State: APjAAAXvDQeYMz8wX9hBfCTX2fdLXqrDEy+mb5X4w0HgzipL4WjeV6ff
	3NZA7/Gxn1/dOWW2JMt3lpDe7budRIPCS1bBtglbwybBYybX0QHu6kJLXdFNJHUfRmxclA62kAS
	sjJbSfSaljUzmOcMOKREp/O9DGf7RtPoeLCKPJLBO/2hlE0t3qdTSF9fH6YRlRPd8NA==
X-Received: by 2002:a5e:8f08:: with SMTP id c8mr23402491iok.52.1562133449553;
        Tue, 02 Jul 2019 22:57:29 -0700 (PDT)
X-Received: by 2002:a5e:8f08:: with SMTP id c8mr23402445iok.52.1562133448807;
        Tue, 02 Jul 2019 22:57:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562133448; cv=none;
        d=google.com; s=arc-20160816;
        b=digE2WlJs5MX1gjlsL/02cfTUmii/iaHM7XEvblbq+G0tb7/dcZL/UVChgl9u3dA/G
         o/N/p5vVuPJJ39Oz5DZpVXPzuY/KVMzgmM6i0BcCewXMchok++0S3+yEjhLNA9H7PVBz
         Vn/UCHaJ412ridWREbxOwSubQxe6to9GGfnhTRovnQr4oC6BHhzDhI3Vya7Yr72h00qE
         zbxVHHuaULifiytmPrl/iDc6uZ9fnU968+0wB34h9YRoSkMsD6thOlwD8tFyee4PMNq5
         V1AIW2TTFMypK8UeRYRx7Tt8v0NP4s0nMZgXjAqRtyPKXidIwwUA8v66klxPFDQAZnZh
         lH4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PTN5uwIluYymv/ulqvQOLWr4+wOTebEj5XIObY2vSeY=;
        b=zJBNMbcb7j3HLzz6ZjyJH8NkxFu0g9ylvtOJ9oxWfGIoqTmo048cCbeuOGhsTIz2H6
         +MChZvnEgl8hvo2OwcXyc2gerCcUBOCLzlrjHcEPm02AiwYekuF5/RB/oMiwVceiAYdI
         ZeMK6f1jVHQHKZtu3+2aUXTZV4JTEK4AQZ29qU2QMkTXPU6n1rqdhIIULbe8Uk6wGEsY
         QFD9V1a3fWqM4YuchV05hmkubeNQwlbaUyqu+0iDeFJN75ukm1MyXwyilBTxWzNCsrvW
         PweYPtqinbF9Aw8royfVqlxU7IGXexfUKX4Tdbzv5Nf+aLBXo49LGvtBuwF5E7bRrnZD
         Y6bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ivq82QwW;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y68sor746800iof.126.2019.07.02.22.57.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 22:57:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ivq82QwW;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PTN5uwIluYymv/ulqvQOLWr4+wOTebEj5XIObY2vSeY=;
        b=ivq82QwW1tBdSlDYTid675w54Gbz4CQCGJTmihhEtqYZBfXWihXITmK6S+OQZLda+m
         TiNO6mW83zAkPUhfhHjeosSE+H8TTzK7CcVGSGrCF+pF3ZxdcFzOMQdY0nYkGPAVDFRd
         e1kgz2aKBHB02Zbju5LVXeLHuMzg9HEwdiFSIdx9+mhao6rwXe7KFu20WIcB1ZNITXko
         nOjj+nGebTbbqf9A+NwYhGhCA+Wxo2P8BwyJwlhVaDMKQ8AvXsFU+IoST7N1xpJsWMcG
         HmI0fPFui78cE8Ge0Tp9f/K4iKgk2U+WHDKwCdLNXUs5lbYZxijD7x2Gmty3ODDv5WT8
         W3XA==
X-Google-Smtp-Source: APXvYqyN/NV/RdaUqJ4Cw6ivKuwHLkZE29oXG/lYctkt9LNUUwhaGULtS9fnlWD8Xz3dAOScg12AObmcKyKLuAvKnrg=
X-Received: by 2002:a6b:8dcf:: with SMTP id p198mr5666129iod.46.1562133448460;
 Tue, 02 Jul 2019 22:57:28 -0700 (PDT)
MIME-Version: 1.0
References: <1562116978-19539-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod68TeAJ_CRgZ0fwh6HhHOwrZ9B4kwMHK+kycPmhR4O46w@mail.gmail.com>
 <CALOAHbBOKxZKfZSf3-JhNOvM_m9gmYbMT+kNTBCdedOg4=kmLw@mail.gmail.com> <CALvZod5JOdYbdvePsYqjtHd=Kma9jZ_CYO5e+7Ma+z0Yszd5iA@mail.gmail.com>
In-Reply-To: <CALvZod5JOdYbdvePsYqjtHd=Kma9jZ_CYO5e+7Ma+z0Yszd5iA@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 3 Jul 2019 13:56:52 +0800
Message-ID: <CALOAHbA6Ar3_4W5fy_pO-Zd-tYunbtVPrXOSShQBOtn3NZhvNw@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: fix wrong statistics in memory.stat
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 3, 2019 at 1:17 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Tue, Jul 2, 2019 at 9:28 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> > On Wed, Jul 3, 2019 at 11:50 AM Shakeel Butt <shakeelb@google.com> wrote:
> > >
> > > +Johannes Weiner
> > >
> > > On Tue, Jul 2, 2019 at 6:23 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> > > >
> > > > When we calculate total statistics for memcg1_stats and memcg1_events, we
> > > > use the the index 'i' in the for loop as the events index.
> > > > Actually we should use memcg1_stats[i] and memcg1_events[i] as the
> > > > events index.
> > > >
> > > > Fixes: 8de7ecc6483b ("memcg: reduce memcg tree traversals for stats collection")
> > >
> > > Actually it fixes 42a300353577 ("mm: memcontrol: fix recursive
> > > statistics correctness & scalabilty").
> > >
> >
> > Hi Shakeel,
> >
> > In 8de7ecc6483b, this code was changed from memcg_page_state(mi,
> > memcg1_stats[i]) to acc.stat[i].
> >
> > -               for_each_mem_cgroup_tree(mi, memcg)
> > -                       val += memcg_page_state(mi, memcg1_stats[i]) *
> > -                       PAGE_SIZE;
> > -               seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
> > +               seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> > +                          (u64)acc.stat[i] * PAGE_SIZE);
> >
> > In 42a300353577, this code was changed from acc.vmstats[i] to
> > memcg_events(memcg, i).
> > -                          (u64)acc.vmstats[i] * PAGE_SIZE);
> > +                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
> >
> > So seems this issue was introduced in 8de7ecc6483b, isn't it ?
> >
> >
>
> That's the reason I said 8de7ecc6483b made it subtle but not wrong.
> Check accumulate_memcg_tree() in 8de7ecc6483b, the memcg_page_state()
> and memcg_events() are called with correct index but saved at 'i'
> index in acc array.
>

Got it. Thanks for your explanation and review.

Thanks
Yafang

>
> > > > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > > > Cc: Shakeel Butt <shakeelb@google.com>
> > > > Cc: Michal Hocko <mhocko@suse.com>
> > > > Cc: Yafang Shao <shaoyafang@didiglobal.com>
> > > > ---
> > > >  mm/memcontrol.c | 5 +++--
> > > >  1 file changed, 3 insertions(+), 2 deletions(-)
> > > >
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index 3ee806b..2ad94d0 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -3528,12 +3528,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
> > > >                 if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
> > > >                         continue;
> > > >                 seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> > > > -                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
> > > > +                          (u64)memcg_page_state(memcg, memcg1_stats[i]) *
> > > > +                          PAGE_SIZE);
> > >
> > > It seems like I made the above very subtle in 8de7ecc6483b and
> > > Johannes missed this subtlety in 42a300353577 (and I missed it in the
> > > review).
> > >
> > > >         }
> > > >
> > > >         for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
> > > >                 seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
> > > > -                          (u64)memcg_events(memcg, i));
> > > > +                          (u64)memcg_events(memcg, memcg1_events[i]));
> > > >
> > > >         for (i = 0; i < NR_LRU_LISTS; i++)
> > > >                 seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
> > > > --
> > > > 1.8.3.1
> > > >
> > >
> > > Reviewed-by: Shakeel Butt <shakeelb@google.com>

