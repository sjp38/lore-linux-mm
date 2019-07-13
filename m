Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88380C742A7
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 06:47:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10F5A204FD
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 06:47:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BrTpUYGA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10F5A204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C7278E0008; Sat, 13 Jul 2019 02:47:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 576FE8E0003; Sat, 13 Jul 2019 02:47:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 466EB8E0008; Sat, 13 Jul 2019 02:47:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26EE98E0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 02:47:26 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f22so13340352ioh.22
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 23:47:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nuQyNCCWePIm/spcnKfaXHChZmxELZW2uvFUgri+k+0=;
        b=mtT0Wt+aHZwLYSdfLf8m4zKA2gFAKMeBxqwtu1X82QTVd5L5S27q/IeJRmxuAFW/Wu
         /nKnCSEYKaKh/dge3giJeWAYTqpkvBvfkZ3KyWiC3+ejGKgbf5wRcSI2owAodjknYRlG
         U1qXXoJ4Pq5IW46a6XxbBP+6+CpjWQpG5lil1D6IOYTX80G2dUJ2HJsiypC7Dg7UqGJJ
         V7L36qVjIDjvv8V1O11Te3QqG8en8WqeA7XN/WRmMIbDiPeWEb7L7AB90MHnHm8vg6NY
         5wTxJB64mvFbSO4D8deBXbc7xw3Bj7b1pWKM++Hz5OPHeqrSn//sS3Q1t9jBhQqcScWB
         t/wg==
X-Gm-Message-State: APjAAAVz3AgRsaG3pCdtkD+Gs5fi4xwOw1FUCKRzqcgqMUp6KYuNMhjj
	K/aw/tGQ/1l7UDalCwtkFFJB4ystawvDUxTYM6lsE9GR3jG24Q+EP3xk7kDACybNU55nkFaO1T4
	3JEyMQovRoopm+ocL7Q4REU34k6/vRztR0qjnmbIQC2KibNT8CW1CHa7KJlzAYz3Knw==
X-Received: by 2002:a02:cc76:: with SMTP id j22mr16309035jaq.9.1563000445880;
        Fri, 12 Jul 2019 23:47:25 -0700 (PDT)
X-Received: by 2002:a02:cc76:: with SMTP id j22mr16308943jaq.9.1563000444095;
        Fri, 12 Jul 2019 23:47:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563000444; cv=none;
        d=google.com; s=arc-20160816;
        b=JnVBAQ0nc+ABP+dGOYU/PwDZjYACUYMpOhSgeNvbPV+M+ZCzwu7SNsSrDjzSko4auv
         7TXUh/cjugmd2nglUZ2FMGxnCGEWwgYXH5wdNiw2SKfbrkW21hjWfgQD/gNNkXJUiS/t
         o5DPjx2TatEUygGNrPQYw6Tdcd7U6hjBO7TKu3p/MLKg8TkVDSRaSDrncrRtqNCCJRAf
         WZ9S0tpD2gCISTUvLOKWk259uHFAyKJyaFfoeZxaBHdPnZp8r5vMfYzT0hbxcLeYQ3MG
         haaFYLcaXNlXMXH1nfGEcSI5Vm8MDSzYlCNw4xxJbzCMNUKJ9azfJXzjrAKa9SlZjpbc
         KDNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nuQyNCCWePIm/spcnKfaXHChZmxELZW2uvFUgri+k+0=;
        b=YsQGQpFKKxLtdSkGdE+naemb/nxQHqpy1IOE3B80hYZaotgkAFB5wPBe8nZSycmXpz
         OxjeOsKxyncEfOyZX2W7F/a0X7xQTiz6YeQzCSwP11OlEv1Lnk9bcp04JCMIbYrUsocK
         CN8beMGbr2d8s/8TeUTFJllGNw2R1t1i8ByjvK9MC8r6U7tbW1ASK7SWyPTRC3vAq5qY
         i9ojT57MziJ1h/sTm/NUtm5jNuzXKdLf9Lh8UgpQCtZx5k+eeChjRA271G34+oVZ3U+6
         p2A+d7JWbIw7rXdLNAZb554achZBtHMWxWgzcrHJsR8GeSjKGgTR8MjX9CNrq2+SHNU9
         OQ0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BrTpUYGA;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q70sor8644883iod.105.2019.07.12.23.47.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 23:47:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BrTpUYGA;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nuQyNCCWePIm/spcnKfaXHChZmxELZW2uvFUgri+k+0=;
        b=BrTpUYGAoqwDpl474yCj9aS30NJ5BLzZYCuc2rxScIbCiiLpyt13cM0IlNB5yP8qmo
         f514liZ3Ge+1btHPXtW+4d0GE9tIMaOCZe+IbICO+2ueM991yVuHDUhj537eRxTywQ09
         xRoD8YzVGOk5A0CYSHUzSKc3J37a3b+ULuxguTBTgB4M0V/8BEtYf8S/KMR0XOLXxuww
         w2ju5jLJ7EUsE0/hrphoptRj7oz++71hxuGZktPRHl7NqaslWKkZWD5/broxkw5YRThm
         G1TpotxUPpv9Wx9AU5JYxeVjV+Wlsu+H2Z1oVaoXiXfaJb7j4cUXa0p0l+Z5Ytg7Krfb
         3z+Q==
X-Google-Smtp-Source: APXvYqwGQCv5e5nmshyNJ8XAD2cUDUk6K8bPpgw9/9JXm+muci1WWufxcyJggbxtLD8kkMUD8Sto5nylRRC0AJTSJcc=
X-Received: by 2002:a5d:8702:: with SMTP id u2mr15252893iom.228.1563000443512;
 Fri, 12 Jul 2019 23:47:23 -0700 (PDT)
MIME-Version: 1.0
References: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com>
 <20190711181017.d8fc41678fc7a754264c6bdf@linux-foundation.org> <CAHbLzkqw+LJC-CrpJpZBfoer9jNRAcfZz+YTLP1qqa_x7R8y1w@mail.gmail.com>
In-Reply-To: <CAHbLzkqw+LJC-CrpJpZBfoer9jNRAcfZz+YTLP1qqa_x7R8y1w@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 13 Jul 2019 14:46:47 +0800
Message-ID: <CALOAHbAq_y2Dng9xxWe4NdNrHa35CpQkrjiYjYHck2Hz8jGssQ@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
To: Yang Shi <shy828301@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Linux MM <linux-mm@kvack.org>, Yafang Shao <shaoyafang@didiglobal.com>, 
	Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 13, 2019 at 7:58 AM Yang Shi <shy828301@gmail.com> wrote:
>
> On Thu, Jul 11, 2019 at 6:10 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> >
> > Can we please get some review of this one?  It has been in -mm since
> > May 22, no issues that I've heard of.
> >
> >
> > From: Yafang Shao <laoar.shao@gmail.com>
> > Subject: mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
> >
> > We can use the exposed cgroup_ino to trace specified cgroup.
> >
> > For example,
> > step 1, get the inode of the specified cgroup
> >         $ ls -di /tmp/cgroupv2/foo
> > step 2, set this inode into tracepoint filter to trace this cgroup only
> >         (assume the inode is 11)
> >         $ cd /sys/kernel/debug/tracing/events/vmscan/
> >         $ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_begin/filter
> >         $ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_end/filter
> >
> > The reason I made this change is to trace a specific container.
>
> I'm wondering how useful this is. You could filter events by cgroup
> with bpftrace easily. For example:
>
> # bpftrace -e 'tracepoint:syscalls:sys_enter_openat /cgroup ==
> cgroupid("/sys/fs/cgroup/unified/mycg")/ { printf("%s\n",
> str(args->filename)); }':
>

Seems the bpftrace get the cgroupid from the current task and then
compare the task-cgroupid with the speficied cgroupid?
While in the memcg reclaim, the pages in a memcg may be reclaimed by a
process in other memcgs, i.e. the parent memcg,
so we can't use the process's memcg as the filter.

The way to use bpftrace here is using kprobe to do it, I guess.
But as the tracepoint is already there, we can make little change to enhance it.

Thanks
Yafang

>
> >
> > Sometimes there're lots of containers on one host.  Some of them are
> > not important at all, so we don't care whether them are under memory
> > pressure.  While some of them are important, so we want't to know if
> > these containers are doing memcg reclaim and how long this relaim
> > takes.
> >
> > Without this change, we don't know the memcg reclaim happend in which
> > container.
> >
> > Link: http://lkml.kernel.org/r/1557649528-11676-1-git-send-email-laoar.shao@gmail.com
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: <shaoyafang@didiglobal.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >
> >  include/trace/events/vmscan.h |   71 ++++++++++++++++++++++++++------
> >  mm/vmscan.c                   |   18 +++++---
> >  2 files changed, 72 insertions(+), 17 deletions(-)
> >
> > --- a/include/trace/events/vmscan.h~mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints
> > +++ a/include/trace/events/vmscan.h
> > @@ -127,18 +127,43 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_be
> >  );
> >
> >  #ifdef CONFIG_MEMCG
> > -DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
> > +DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_begin_template,
> >
> > -       TP_PROTO(int order, gfp_t gfp_flags),
> > +       TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
> >
> > -       TP_ARGS(order, gfp_flags)
> > +       TP_ARGS(cgroup_ino, order, gfp_flags),
> > +
> > +       TP_STRUCT__entry(
> > +               __field(unsigned int, cgroup_ino)
> > +               __field(int, order)
> > +               __field(gfp_t, gfp_flags)
> > +       ),
> > +
> > +       TP_fast_assign(
> > +               __entry->cgroup_ino     = cgroup_ino;
> > +               __entry->order          = order;
> > +               __entry->gfp_flags      = gfp_flags;
> > +       ),
> > +
> > +       TP_printk("cgroup_ino=%u order=%d gfp_flags=%s",
> > +               __entry->cgroup_ino, __entry->order,
> > +               show_gfp_flags(__entry->gfp_flags))
> >  );
> >
> > -DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
> > +DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
> > +            mm_vmscan_memcg_reclaim_begin,
> >
> > -       TP_PROTO(int order, gfp_t gfp_flags),
> > +       TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
> >
> > -       TP_ARGS(order, gfp_flags)
> > +       TP_ARGS(cgroup_ino, order, gfp_flags)
> > +);
> > +
> > +DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
> > +            mm_vmscan_memcg_softlimit_reclaim_begin,
> > +
> > +       TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
> > +
> > +       TP_ARGS(cgroup_ino, order, gfp_flags)
> >  );
> >  #endif /* CONFIG_MEMCG */
> >
> > @@ -167,18 +192,40 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_en
> >  );
> >
> >  #ifdef CONFIG_MEMCG
> > -DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_reclaim_end,
> > +DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_end_template,
> >
> > -       TP_PROTO(unsigned long nr_reclaimed),
> > +       TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
> >
> > -       TP_ARGS(nr_reclaimed)
> > +       TP_ARGS(cgroup_ino, nr_reclaimed),
> > +
> > +       TP_STRUCT__entry(
> > +               __field(unsigned int, cgroup_ino)
> > +               __field(unsigned long, nr_reclaimed)
> > +       ),
> > +
> > +       TP_fast_assign(
> > +               __entry->cgroup_ino     = cgroup_ino;
> > +               __entry->nr_reclaimed   = nr_reclaimed;
> > +       ),
> > +
> > +       TP_printk("cgroup_ino=%u nr_reclaimed=%lu",
> > +               __entry->cgroup_ino, __entry->nr_reclaimed)
> >  );
> >
> > -DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_reclaim_end,
> > +DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
> > +            mm_vmscan_memcg_reclaim_end,
> >
> > -       TP_PROTO(unsigned long nr_reclaimed),
> > +       TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
> >
> > -       TP_ARGS(nr_reclaimed)
> > +       TP_ARGS(cgroup_ino, nr_reclaimed)
> > +);
> > +
> > +DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
> > +            mm_vmscan_memcg_softlimit_reclaim_end,
> > +
> > +       TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
> > +
> > +       TP_ARGS(cgroup_ino, nr_reclaimed)
> >  );
> >  #endif /* CONFIG_MEMCG */
> >
> > --- a/mm/vmscan.c~mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints
> > +++ a/mm/vmscan.c
> > @@ -3191,8 +3191,10 @@ unsigned long mem_cgroup_shrink_node(str
> >         sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> >                         (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> >
> > -       trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
> > -                                                     sc.gfp_mask);
> > +       trace_mm_vmscan_memcg_softlimit_reclaim_begin(
> > +                                       cgroup_ino(memcg->css.cgroup),
> > +                                       sc.order,
> > +                                       sc.gfp_mask);
> >
> >         /*
> >          * NOTE: Although we can get the priority field, using it
> > @@ -3203,7 +3205,9 @@ unsigned long mem_cgroup_shrink_node(str
> >          */
> >         shrink_node_memcg(pgdat, memcg, &sc, &lru_pages);
> >
> > -       trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
> > +       trace_mm_vmscan_memcg_softlimit_reclaim_end(
> > +                                       cgroup_ino(memcg->css.cgroup),
> > +                                       sc.nr_reclaimed);
> >
> >         *nr_scanned = sc.nr_scanned;
> >         return sc.nr_reclaimed;
> > @@ -3241,7 +3245,9 @@ unsigned long try_to_free_mem_cgroup_pag
> >
> >         zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
> >
> > -       trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
> > +       trace_mm_vmscan_memcg_reclaim_begin(
> > +                               cgroup_ino(memcg->css.cgroup),
> > +                               0, sc.gfp_mask);
> >
> >         psi_memstall_enter(&pflags);
> >         noreclaim_flag = memalloc_noreclaim_save();
> > @@ -3251,7 +3257,9 @@ unsigned long try_to_free_mem_cgroup_pag
> >         memalloc_noreclaim_restore(noreclaim_flag);
> >         psi_memstall_leave(&pflags);
> >
> > -       trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
> > +       trace_mm_vmscan_memcg_reclaim_end(
> > +                               cgroup_ino(memcg->css.cgroup),
> > +                               nr_reclaimed);
> >
> >         return nr_reclaimed;
> >  }
> > _
> >

