Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_SBL,URIBL_SBL_A autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50826C742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:58:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E162220874
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:58:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rNjy3Hgs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E162220874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC298E016F; Fri, 12 Jul 2019 19:58:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76BF98E0003; Fri, 12 Jul 2019 19:58:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 634FB8E016F; Fri, 12 Jul 2019 19:58:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44F2E8E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 19:58:40 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c79so8370047qkg.13
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 16:58:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MEY3MY0GRx1meGvznTKols94S0qbmIElEGry91ByzZE=;
        b=qWAv1eEkIYipbb+MhLhRy4/j1QsS6Qb6PeTiBhEZofYJOb6sbhPWrup/MPMi2dbt10
         h5wDbxqMZh+FTl12TrwrPTZPVbLNQHYGf6RLfh0SS1c9LAFwW7wMLzgQEzQBBgLlWExy
         Cd7f1ZaD35EF+B+ACFpg8unHIhrR0et7v4rpeRKgtuXkUIdkiqO94vIv+Oh1L9uRbIfS
         LsLWjDmGYG9dqbfjCs7jDNR3ttNA42vGiuNsbx9Lno93olsQ4ZfT1g9QP2DTuJhp4dfC
         VSLPEM99zwjyTYOqlshk0Omp6NITn3LXuyWJy+4oZeUrKB0ZhlRP4D2ZFP9outi35GER
         i0Ag==
X-Gm-Message-State: APjAAAUzDoKAdEml8gOGQjRrofRU2ySErweJHWQUl356xMARmSuRcGXV
	mbonWiwybJzHDvA2FccqYC/iDlN4Cpgv6lp2Lh47SwTqs4hpgpZmR7WkbvfAfcjH67tCEalXNl/
	Ia4apvPN+A7CVuXDLfAmyjly8uw8PTGiXrq/z8G66xQlk+wA8litmPKikX2mYi9cS2g==
X-Received: by 2002:ae9:dcc1:: with SMTP id q184mr8256242qkf.61.1562975919947;
        Fri, 12 Jul 2019 16:58:39 -0700 (PDT)
X-Received: by 2002:ae9:dcc1:: with SMTP id q184mr8256215qkf.61.1562975919067;
        Fri, 12 Jul 2019 16:58:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562975919; cv=none;
        d=google.com; s=arc-20160816;
        b=PFt3xFzbqeNONGN79TxM46T2ihuAASGOvQjw/yYxN5sBq0sZJmjnNhJqRV3Inx0d9A
         2iZBHGGNx8vzPwqnv3NVe0BQTAFJDg4bHSgQH9GohLOhO/CcANCBvB4I+a9T2wdRWOWZ
         DJEd26SyrqQSsqwDKj7gRIjDWQyuJA7Po7EZnC4GM+UAHmew37J8dg+UY+YNI9LipNDd
         OUmbuoyMlsfSDtYJo5zUUVhSH78UjI6G0+Y0jxTg/ckmwkgsiQgm5CHzVJG0h+Qe+V66
         ssJG2jxKxqPdusfbTzXZxDt6QqEzjFbGqN8nGSyq1XcP/OggRzxOvjuMmsXPM77zQTng
         x3rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MEY3MY0GRx1meGvznTKols94S0qbmIElEGry91ByzZE=;
        b=S+SQM+EAtqrZ+Uj6o4QDlVHqf3Cyqhi23wNkZRQqT54DlM9KjvwogPuayiREdoqs+X
         tmyb829aqeXWpkOKBr7aTqzv6wnr1czjQ2MKZDHxK14INutukllsda9IIpCiwxXJopoH
         q8BRunvdC+XHqtzl1l38R0j3rk/BqQsA2J73QmjNhkdOBCDsoXSb58Qiw1JU0aHVTCcB
         Ts2CteftU/NlcNuHubMe/C2Eksw0Kfks2k4bE007CxR2wAAJHsMnDu4hXcWp8RY2QCD7
         jnPFmqnw2V5Z7vkdRo7zRQgB/9cDzqIndLAHTHMMAxIwrzNzVYvi4GnZC+UfWkBbvej4
         yM5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rNjy3Hgs;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor6087318qki.54.2019.07.12.16.58.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 16:58:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rNjy3Hgs;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MEY3MY0GRx1meGvznTKols94S0qbmIElEGry91ByzZE=;
        b=rNjy3HgsJm/b9MwixMnKeZVUjelLOZ6SU5fSvGKJOat5SE+SgE1WzQHsRzKHhT4bx7
         QCIE/AKH8MWJMNAHb0JTfXL5PtysYHX7dyQ5KSGNl1SCMmB90tdvTNofoEGq78ED3AFH
         6HTAFZzMpI/MC/8ymACDzNAueX6povuPaOLbK5zMaR9zJecjF6ataNLIhSbPwV7iNPrH
         aDc4x1A5bs+G0nvFoNjxi2pzGo5fshQOKHllqr1XLy/Jeeg116tVmnU1IuA8yOoiKkeG
         W0lVB4Xo/KYPDIClw/pDpaATFiiJHQ3woSGq5hLuxjJgmwkeUEZNl0vu2+qfaIM98fng
         ccfw==
X-Google-Smtp-Source: APXvYqy9+kiHmRflh8OpzHvRs+hG+ROhQZ/f4EvcwaHKhafdBLyGzNwPBg4eGLPj9bIBZUTqVMFT/U4BWiFzxr5MIK4=
X-Received: by 2002:ae9:ee14:: with SMTP id i20mr7576396qkg.428.1562975918804;
 Fri, 12 Jul 2019 16:58:38 -0700 (PDT)
MIME-Version: 1.0
References: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com> <20190711181017.d8fc41678fc7a754264c6bdf@linux-foundation.org>
In-Reply-To: <20190711181017.d8fc41678fc7a754264c6bdf@linux-foundation.org>
From: Yang Shi <shy828301@gmail.com>
Date: Fri, 12 Jul 2019 16:58:28 -0700
Message-ID: <CAHbLzkqw+LJC-CrpJpZBfoer9jNRAcfZz+YTLP1qqa_x7R8y1w@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yafang Shao <laoar.shao@gmail.com>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 6:10 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
>
> Can we please get some review of this one?  It has been in -mm since
> May 22, no issues that I've heard of.
>
>
> From: Yafang Shao <laoar.shao@gmail.com>
> Subject: mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
>
> We can use the exposed cgroup_ino to trace specified cgroup.
>
> For example,
> step 1, get the inode of the specified cgroup
>         $ ls -di /tmp/cgroupv2/foo
> step 2, set this inode into tracepoint filter to trace this cgroup only
>         (assume the inode is 11)
>         $ cd /sys/kernel/debug/tracing/events/vmscan/
>         $ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_begin/filter
>         $ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_end/filter
>
> The reason I made this change is to trace a specific container.

I'm wondering how useful this is. You could filter events by cgroup
with bpftrace easily. For example:

# bpftrace -e 'tracepoint:syscalls:sys_enter_openat /cgroup ==
cgroupid("/sys/fs/cgroup/unified/mycg")/ { printf("%s\n",
str(args->filename)); }':


>
> Sometimes there're lots of containers on one host.  Some of them are
> not important at all, so we don't care whether them are under memory
> pressure.  While some of them are important, so we want't to know if
> these containers are doing memcg reclaim and how long this relaim
> takes.
>
> Without this change, we don't know the memcg reclaim happend in which
> container.
>
> Link: http://lkml.kernel.org/r/1557649528-11676-1-git-send-email-laoar.shao@gmail.com
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: <shaoyafang@didiglobal.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  include/trace/events/vmscan.h |   71 ++++++++++++++++++++++++++------
>  mm/vmscan.c                   |   18 +++++---
>  2 files changed, 72 insertions(+), 17 deletions(-)
>
> --- a/include/trace/events/vmscan.h~mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints
> +++ a/include/trace/events/vmscan.h
> @@ -127,18 +127,43 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_be
>  );
>
>  #ifdef CONFIG_MEMCG
> -DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
> +DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_begin_template,
>
> -       TP_PROTO(int order, gfp_t gfp_flags),
> +       TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
>
> -       TP_ARGS(order, gfp_flags)
> +       TP_ARGS(cgroup_ino, order, gfp_flags),
> +
> +       TP_STRUCT__entry(
> +               __field(unsigned int, cgroup_ino)
> +               __field(int, order)
> +               __field(gfp_t, gfp_flags)
> +       ),
> +
> +       TP_fast_assign(
> +               __entry->cgroup_ino     = cgroup_ino;
> +               __entry->order          = order;
> +               __entry->gfp_flags      = gfp_flags;
> +       ),
> +
> +       TP_printk("cgroup_ino=%u order=%d gfp_flags=%s",
> +               __entry->cgroup_ino, __entry->order,
> +               show_gfp_flags(__entry->gfp_flags))
>  );
>
> -DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
> +DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
> +            mm_vmscan_memcg_reclaim_begin,
>
> -       TP_PROTO(int order, gfp_t gfp_flags),
> +       TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
>
> -       TP_ARGS(order, gfp_flags)
> +       TP_ARGS(cgroup_ino, order, gfp_flags)
> +);
> +
> +DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
> +            mm_vmscan_memcg_softlimit_reclaim_begin,
> +
> +       TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
> +
> +       TP_ARGS(cgroup_ino, order, gfp_flags)
>  );
>  #endif /* CONFIG_MEMCG */
>
> @@ -167,18 +192,40 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_en
>  );
>
>  #ifdef CONFIG_MEMCG
> -DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_reclaim_end,
> +DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_end_template,
>
> -       TP_PROTO(unsigned long nr_reclaimed),
> +       TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
>
> -       TP_ARGS(nr_reclaimed)
> +       TP_ARGS(cgroup_ino, nr_reclaimed),
> +
> +       TP_STRUCT__entry(
> +               __field(unsigned int, cgroup_ino)
> +               __field(unsigned long, nr_reclaimed)
> +       ),
> +
> +       TP_fast_assign(
> +               __entry->cgroup_ino     = cgroup_ino;
> +               __entry->nr_reclaimed   = nr_reclaimed;
> +       ),
> +
> +       TP_printk("cgroup_ino=%u nr_reclaimed=%lu",
> +               __entry->cgroup_ino, __entry->nr_reclaimed)
>  );
>
> -DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_reclaim_end,
> +DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
> +            mm_vmscan_memcg_reclaim_end,
>
> -       TP_PROTO(unsigned long nr_reclaimed),
> +       TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
>
> -       TP_ARGS(nr_reclaimed)
> +       TP_ARGS(cgroup_ino, nr_reclaimed)
> +);
> +
> +DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
> +            mm_vmscan_memcg_softlimit_reclaim_end,
> +
> +       TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
> +
> +       TP_ARGS(cgroup_ino, nr_reclaimed)
>  );
>  #endif /* CONFIG_MEMCG */
>
> --- a/mm/vmscan.c~mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints
> +++ a/mm/vmscan.c
> @@ -3191,8 +3191,10 @@ unsigned long mem_cgroup_shrink_node(str
>         sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                         (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>
> -       trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
> -                                                     sc.gfp_mask);
> +       trace_mm_vmscan_memcg_softlimit_reclaim_begin(
> +                                       cgroup_ino(memcg->css.cgroup),
> +                                       sc.order,
> +                                       sc.gfp_mask);
>
>         /*
>          * NOTE: Although we can get the priority field, using it
> @@ -3203,7 +3205,9 @@ unsigned long mem_cgroup_shrink_node(str
>          */
>         shrink_node_memcg(pgdat, memcg, &sc, &lru_pages);
>
> -       trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
> +       trace_mm_vmscan_memcg_softlimit_reclaim_end(
> +                                       cgroup_ino(memcg->css.cgroup),
> +                                       sc.nr_reclaimed);
>
>         *nr_scanned = sc.nr_scanned;
>         return sc.nr_reclaimed;
> @@ -3241,7 +3245,9 @@ unsigned long try_to_free_mem_cgroup_pag
>
>         zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
>
> -       trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
> +       trace_mm_vmscan_memcg_reclaim_begin(
> +                               cgroup_ino(memcg->css.cgroup),
> +                               0, sc.gfp_mask);
>
>         psi_memstall_enter(&pflags);
>         noreclaim_flag = memalloc_noreclaim_save();
> @@ -3251,7 +3257,9 @@ unsigned long try_to_free_mem_cgroup_pag
>         memalloc_noreclaim_restore(noreclaim_flag);
>         psi_memstall_leave(&pflags);
>
> -       trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
> +       trace_mm_vmscan_memcg_reclaim_end(
> +                               cgroup_ino(memcg->css.cgroup),
> +                               nr_reclaimed);
>
>         return nr_reclaimed;
>  }
> _
>

