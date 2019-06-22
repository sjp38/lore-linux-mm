Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C614C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 06:32:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B29B2205ED
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 06:32:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sG+GZBxk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B29B2205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06BEF6B0003; Sat, 22 Jun 2019 02:32:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01C118E0002; Sat, 22 Jun 2019 02:32:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4C938E0001; Sat, 22 Jun 2019 02:32:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3C1A6B0003
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 02:32:36 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u25so13735726iol.23
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 23:32:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MZOW7mZS47qV542PE7GqCKSpI+Y0I41Wm27n7Aq67bQ=;
        b=V9u+xMmDDoO4ZZDL21tXXbPNIqs9j3AYWjN7mHqImBncKWC8df/LhXlmeLd1kI3c9b
         PdfYLCOTEXV7gKFkMFqCvX7lu089L0cw6katroJR7YYfoPKyZ19Y9kW/T6bzlQ4jsRqk
         MPw18W61zIe1IZY0/WcBrawcOUNsgpsR+nNx6b3FTYbc7IMs+lOx+St+rwemy8t50P5Q
         mdlEgkoqqjBN5d4RbrN5FdH8grcR8y0doXMTZW45BzGO8E9QmgEiTlR/EZsBJJcRmaN0
         FydC/FU2/yF+tCZSzQx05KC0OvfFAEY5g3++THeG8J4BASQhTRE2itkYax5YNS1+Zl3b
         mc1A==
X-Gm-Message-State: APjAAAUlJqZfxAwo8mXlVjptEFi4L0gha9MOjOtwiDqZnWhrI3NH6Lk6
	cVcDr//ucZxDHG15jzjNa3tXYVtn3yD8VAlAVZO4HPFJt7zpQPzLIWB7lngZ+CL/Lvd7ci6QV+c
	0hX0+P07TU4l+Tw6bwyaMPPDJ0NIv/UtwA4kAuKtbaNi/sQRjBZunaL2lSDceM+Gvdg==
X-Received: by 2002:a02:3c07:: with SMTP id m7mr3984110jaa.64.1561185156440;
        Fri, 21 Jun 2019 23:32:36 -0700 (PDT)
X-Received: by 2002:a02:3c07:: with SMTP id m7mr3984022jaa.64.1561185155662;
        Fri, 21 Jun 2019 23:32:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561185155; cv=none;
        d=google.com; s=arc-20160816;
        b=WhwEmGzWHl6ntC9NQthacomO2JCBC9hjOfDwqDzJUm50MGG7li1C1wZVD4P2BtxmWr
         957t8qMnL7YZ9w3ct3eWMXj51rcLido0c1T/hXDXvYfGr8cEwJbVi3cdpijx+VCVvE+R
         UJkJkquN1FJami4bHnPpRmRwfiz1ujOw7Tmb4Ht1t+iq4gDXkUZAYtuHyWVGIsxHHZsQ
         r4409wVmybDx0IJVTPAVk2JWKI2VHM7TY6kWwTFR4eXoGBwGKVcOdKmsivFprLtvQ7Rq
         gnMEHSlyXuFS1xMy59cjAN9UUVfU9QJpp4Lo0K2nFfuXm0FKmzvXXnTq3PN2m8HfTSdU
         dUDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MZOW7mZS47qV542PE7GqCKSpI+Y0I41Wm27n7Aq67bQ=;
        b=edLcoqyhMf8piu7yfztLyBAqTQIvI+VvPFKrK/NMSwYKBolik+gMG8RKYpc/NofK8W
         fY1aYYLJjJ9Du8mf+m9/U4O4MY06fCxd5Tz92WviXYxQDXtHys8csY76StpqkPH6DJa3
         RZcvMH4W0lhFGGs+zqR35zeV+NzAdbSVokhRgniPsh1FsQ0Z/pcBbzCaUfy79tRHl23D
         zfUHEQiXhi+Z+CIswfKwyocjoixphdrj6YlSUoBZzIwgVdk+SkfighJDL097NF40V3Lf
         hJEKeLAkvhNxUwO7FTWdBn/63dKzB/RZ6g6Ag/xdzjdh29kF/C2QpStw47iealWC21tX
         ZqMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sG+GZBxk;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m187sor3905991ioa.46.2019.06.21.23.32.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 23:32:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sG+GZBxk;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MZOW7mZS47qV542PE7GqCKSpI+Y0I41Wm27n7Aq67bQ=;
        b=sG+GZBxkB4n3Y2FlrA0NAQETnsHs3+0NroO+eFKeWT1GXbFh2yIpqpqjFb78R/0qlL
         ARxwfSsLT/2CIB24JJLSz6nmXABEldlb/cFzDJSLnwYW1RdEzJJLHz7hHqTiD+HkPrHc
         2gd9MD2gv8D9YXZ3PeJcISFaL+kym7cTS2ZvZdKkT06JHQ6pAbYc9oG0HUesWGRlJTR8
         77BPfsrAObClEanqUj5Lk0XocWrI/SLBUtySbuxHWTJuOLipjHeIYPYi6e3s0OaYP0nd
         STS7c1GeQ3XGXxwDjEXx8YaCG1elMPUH0bJnBnB6Vx1cSdSm8at/oiChvAI6zxpnNi/6
         qczg==
X-Google-Smtp-Source: APXvYqw0hLPMEX9jIddSYlobWm97lxnCMrN3UzvEPdsz1bgNzG5ceqsVWvCDfNYcEO0CgHwY3C0t1vHdF46ysxkYSUA=
X-Received: by 2002:a5e:9e0a:: with SMTP id i10mr22901107ioq.44.1561185155210;
 Fri, 21 Jun 2019 23:32:35 -0700 (PDT)
MIME-Version: 1.0
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
 <1561112086-6169-3-git-send-email-laoar.shao@gmail.com> <20190621203014.fff2b968b6f9c2e23ebf4eef@linux-foundation.org>
In-Reply-To: <20190621203014.fff2b968b6f9c2e23ebf4eef@linux-foundation.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 22 Jun 2019 14:31:53 +0800
Message-ID: <CALOAHbAxMafczF8-T=B-gxiJt2ytDg+b3CojR-OypSr3oonvDA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/vmscan: calculate reclaimed slab caches in all
 reclaim paths
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 22, 2019 at 11:30 AM Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Fri, 21 Jun 2019 18:14:46 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
>
> > There're six different reclaim paths by now,
> > - kswapd reclaim path
> > - node reclaim path
> > - hibernate preallocate memory reclaim path
> > - direct reclaim path
> > - memcg reclaim path
> > - memcg softlimit reclaim path
> >
> > The slab caches reclaimed in these paths are only calculated in the above
> > three paths.
> >
> > There're some drawbacks if we don't calculate the reclaimed slab caches.
> > - The sc->nr_reclaimed isn't correct if there're some slab caches
> >   relcaimed in this path.
> > - The slab caches may be reclaimed thoroughly if there're lots of
> >   reclaimable slab caches and few page caches.
> >   Let's take an easy example for this case.
> >   If one memcg is full of slab caches and the limit of it is 512M, in
> >   other words there're approximately 512M slab caches in this memcg.
> >   Then the limit of the memcg is reached and the memcg reclaim begins,
> >   and then in this memcg reclaim path it will continuesly reclaim the
> >   slab caches until the sc->priority drops to 0.
> >   After this reclaim stops, you will find there're few slab caches left,
> >   which is less than 20M in my test case.
> >   While after this patch applied the number is greater than 300M and
> >   the sc->priority only drops to 3.
>
> I got a bit exhausted checking that none of these six callsites can
> scribble on some caller's value of current->reclaim_state.
>
> How about we do it at runtime?
>

That's good.
Thanks for your improvement.

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/vmscan.c: add checks for incorrect handling of current->reclaim_state
>
> Six sites are presently altering current->reclaim_state.  There is a risk
> that one function stomps on a caller's value.  Use a helper function to
> catch such errors.
>
> Cc: Yafang Shao <laoar.shao@gmail.com>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/vmscan.c |   37 ++++++++++++++++++++++++-------------
>  1 file changed, 24 insertions(+), 13 deletions(-)
>
> --- a/mm/vmscan.c~mm-vmscanc-add-checks-for-incorrect-handling-of-current-reclaim_state
> +++ a/mm/vmscan.c
> @@ -177,6 +177,18 @@ unsigned long vm_total_pages;
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>
> +static void set_task_reclaim_state(struct task_struct *task,
> +                                  struct reclaim_state *rs)
> +{
> +       /* Check for an overwrite */
> +       WARN_ON_ONCE(rs && task->reclaim_state);
> +
> +       /* Check for the nulling of an already-nulled member */
> +       WARN_ON_ONCE(!rs && !task->reclaim_state);
> +
> +       task->reclaim_state = rs;
> +}
> +
>  #ifdef CONFIG_MEMCG_KMEM
>
>  /*
> @@ -3194,13 +3206,13 @@ unsigned long try_to_free_pages(struct z
>         if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>                 return 1;
>
> -       current->reclaim_state = &sc.reclaim_state;
> +       set_task_reclaim_state(current, &sc.reclaim_state);
>         trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
>
>         nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>
>         trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
> -       current->reclaim_state = NULL;
> +       set_task_reclaim_state(current, NULL);
>
>         return nr_reclaimed;
>  }
> @@ -3223,7 +3235,7 @@ unsigned long mem_cgroup_shrink_node(str
>         };
>         unsigned long lru_pages;
>
> -       current->reclaim_state = &sc.reclaim_state;
> +       set_task_reclaim_state(current, &sc.reclaim_state);
>         sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                         (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>
> @@ -3245,7 +3257,7 @@ unsigned long mem_cgroup_shrink_node(str
>                                         cgroup_ino(memcg->css.cgroup),
>                                         sc.nr_reclaimed);
>
> -       current->reclaim_state = NULL;
> +       set_task_reclaim_state(current, NULL);
>         *nr_scanned = sc.nr_scanned;
>
>         return sc.nr_reclaimed;
> @@ -3274,7 +3286,7 @@ unsigned long try_to_free_mem_cgroup_pag
>                 .may_shrinkslab = 1,
>         };
>
> -       current->reclaim_state = &sc.reclaim_state;
> +       set_task_reclaim_state(current, &sc.reclaim_state);
>         /*
>          * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
>          * take care zof from where we get pages. So the node where we start the
> @@ -3299,7 +3311,7 @@ unsigned long try_to_free_mem_cgroup_pag
>         trace_mm_vmscan_memcg_reclaim_end(
>                                 cgroup_ino(memcg->css.cgroup),
>                                 nr_reclaimed);
> -       current->reclaim_state = NULL;
> +       set_task_reclaim_state(current, NULL);
>
>         return nr_reclaimed;
>  }
> @@ -3501,7 +3513,7 @@ static int balance_pgdat(pg_data_t *pgda
>                 .may_unmap = 1,
>         };
>
> -       current->reclaim_state = &sc.reclaim_state;
> +       set_task_reclaim_state(current, &sc.reclaim_state);
>         psi_memstall_enter(&pflags);
>         __fs_reclaim_acquire();
>
> @@ -3683,7 +3695,7 @@ out:
>         snapshot_refaults(NULL, pgdat);
>         __fs_reclaim_release();
>         psi_memstall_leave(&pflags);
> -       current->reclaim_state = NULL;
> +       set_task_reclaim_state(current, NULL);
>
>         /*
>          * Return the order kswapd stopped reclaiming at as
> @@ -3945,17 +3957,16 @@ unsigned long shrink_all_memory(unsigned
>                 .hibernation_mode = 1,
>         };
>         struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
> -       struct task_struct *p = current;
>         unsigned long nr_reclaimed;
>         unsigned int noreclaim_flag;
>
>         fs_reclaim_acquire(sc.gfp_mask);
>         noreclaim_flag = memalloc_noreclaim_save();
> -       p->reclaim_state = &sc.reclaim_state;
> +       set_task_reclaim_state(current, &sc.reclaim_state);
>
>         nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>
> -       p->reclaim_state = NULL;
> +       set_task_reclaim_state(current, NULL);
>         memalloc_noreclaim_restore(noreclaim_flag);
>         fs_reclaim_release(sc.gfp_mask);
>
> @@ -4144,7 +4155,7 @@ static int __node_reclaim(struct pglist_
>          */
>         noreclaim_flag = memalloc_noreclaim_save();
>         p->flags |= PF_SWAPWRITE;
> -       p->reclaim_state = &sc.reclaim_state;
> +       set_task_reclaim_state(p, &sc.reclaim_state);
>
>         if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
>                 /*
> @@ -4156,7 +4167,7 @@ static int __node_reclaim(struct pglist_
>                 } while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
>         }
>
> -       p->reclaim_state = NULL;
> +       set_task_reclaim_state(p, NULL);
>         current->flags &= ~PF_SWAPWRITE;
>         memalloc_noreclaim_restore(noreclaim_flag);
>         fs_reclaim_release(sc.gfp_mask);
> _
>

