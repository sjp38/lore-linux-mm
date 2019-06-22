Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1B19C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 02:56:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A7672070B
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 02:56:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mYbRmL5/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A7672070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E6796B0003; Fri, 21 Jun 2019 22:56:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 998338E0002; Fri, 21 Jun 2019 22:56:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 885C98E0001; Fri, 21 Jun 2019 22:56:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0F96B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 22:56:57 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id l62so8322592ywb.21
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:56:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/g9EiwqrPvEcGP2ni72jxssRku07PD+BBNFgfPzyheY=;
        b=hE1Hs/34ddNeKGyvUE2kaIO4sI0Pn4E8XXIDZlsQnLDkurc1AG2W++gFKQV6uPJrQb
         pbjsoGB8dJ/r2g0WNVGvyKKi4zv1uU5mNNCrrl+cIZImlfB+nxib3Y/JwAWlVOJx5IAP
         bFr85YlONIck0gIXG9M2Sr1GAAkrEedswrqWC2FFUs6bxywSowzSSZgQqFWi32XJFpzQ
         Zgochpefxc4Bq8zSeQwB+N9K0mObv15hEbxuNrkFSYR/X/tE8lnfhe9kMciTbDdLG2U6
         PyBuPitud4GoFrA4aVA8Yi/FhZFJSBnfndFhQcrMIJlZ/SR/eQKZLgapP8GwaXqcY+Az
         J5wA==
X-Gm-Message-State: APjAAAU+FermtIjrLqIzskE+zOFeh1KdLQy1B8/4p68GzzMK0DGQULDk
	neBFFSZGN0VBfgXY3UINciHhG1DLvd16gvqIM625vvWZvTml8C6WGA+uYXh6ug+8zLulqhXtelb
	RJLw/ngvchVpVQJibYsAnMqppttcnGvGh5xTqbcj25xQ7O+UAGZc2xrJww0HaCx6zAg==
X-Received: by 2002:a25:a08c:: with SMTP id y12mr70906411ybh.469.1561172217147;
        Fri, 21 Jun 2019 19:56:57 -0700 (PDT)
X-Received: by 2002:a25:a08c:: with SMTP id y12mr70906402ybh.469.1561172216300;
        Fri, 21 Jun 2019 19:56:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561172216; cv=none;
        d=google.com; s=arc-20160816;
        b=f66pWoksKRu7mJ7cw/c8ek9qIgPxB2NQQG/WJWU+V+nMMNVGe0VfrrsQfnRxmQF47Y
         WhKJQ4Ex+10r5wYqFZtbztDPaaRfb123NOanKTUDXyzVyl0Q4BkYYfJcbkTcfTT2eXCt
         Uc8X0E9kF2e6DgXCsusAoe3R25njexPK8/rf1uPoVm78eidKBrpGe+j4xOl2XwqvmZh/
         YtHdkk+Cv8u1osO6AyTqS/k1GTYVBG9sCwt594bmODT2ukA/bynMJK6G3IUidBfzNjg7
         5/gg8Ihxar/8huF6tGzWykzd+hXxf+zFpWHy0SabhEQlgPZWoD/I7ZXIQBT7qrRN7JXy
         exIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/g9EiwqrPvEcGP2ni72jxssRku07PD+BBNFgfPzyheY=;
        b=t6Bp0D8RDJZ/QEzcQeTiho/KPcKk8fbREL8EXDm2rLiuhrVew6Gju8Ufy02h9gQsZ4
         fHI/oEwfKKWAJKQwYOD84Lqjgv6eF/EnXQGtLYx6etUHUCo+N3yvFt8CkUrigKdjYtbQ
         KO9uCHlHNlNr4frAwolR9cKg3pgwImw73QoSb3RoRLs6Syc+hbbM0xCqY/rPitMGR5zK
         n8ljSHWmyNRQiIA3zr2Glts0Hyn2lJo6sNDRnPVDJWbBkq/LL35+fmgTUGigJEQcUPPl
         CwmDc8OWz97myWTPWeegXYPhGCI0M8W/Oe3H4xihb4r5Kh9dpoSi1uEuxkbw0N9g9eRm
         x+OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="mYbRmL5/";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o194sor2614763ywo.122.2019.06.21.19.56.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 19:56:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="mYbRmL5/";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/g9EiwqrPvEcGP2ni72jxssRku07PD+BBNFgfPzyheY=;
        b=mYbRmL5/P2mRzNOQSsSEJmGQWFcVIzmw0SVxH6/kO00xVRkQXvbGTzwNqSaOScTjWB
         NHe6cCqxuiNoFoCBP+2+JLyNbzb644qpJWhOw5dt+Ans39QxbhA4zcRsBusIzJ+hAKYY
         TfYxeV4uWgb7WwKWbr7iOeaRr3OL+RLTRvDA5oR5rHx6q+BH5Ydn/3NzL8zIkMA3Xb+Z
         kCyfe+Pt4VRUpawyN+ajT7qbUup5s/4CkWFzXb3Y1GXcvKBKGeqZ85/BNlzgJmwrvAkH
         4MAPxqyyRXjPUaM5bKehs6KgDYPv+ActooRkzqnEFYi+YsCj98tmxl7JeGUZyr2SrHF9
         KICw==
X-Google-Smtp-Source: APXvYqxFuhE0Kf5yAADli3a4wL8we59okF0BtHIRD++QuwlaOJlXqbkRZzRIR+nIVbqVOcPqNt3u2NLWkIRfajq57vw=
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr61725056ywh.308.1561172215649;
 Fri, 21 Jun 2019 19:56:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190621173005.31514-1-longman@redhat.com>
In-Reply-To: <20190621173005.31514-1-longman@redhat.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 21 Jun 2019 19:56:44 -0700
Message-ID: <CALvZod51uMXsS+1DpyG+=1nC-6pYNc8C6yOwQUdiRLD0yrp4ZA@mail.gmail.com>
Subject: Re: [PATCH-next] mm, memcg: Add ":deact" tag for reparented kmem
 caches in memcg_slabinfo
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 10:30 AM Waiman Long <longman@redhat.com> wrote:
>
> With Roman's kmem cache reparent patch, multiple kmem caches of the same
> type can be seen attached to the same memcg id. All of them, except
> maybe one, are reparent'ed kmem caches. It can be useful to tag those
> reparented caches by adding a new slab flag "SLAB_DEACTIVATED" to those
> kmem caches that will be reparent'ed if it cannot be destroyed completely.
>
> For the reparent'ed memcg kmem caches, the tag ":deact" will now be
> shown in <debugfs>/memcg_slabinfo.
>
> Signed-off-by: Waiman Long <longman@redhat.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  include/linux/slab.h |  4 ++++
>  mm/slab.c            |  1 +
>  mm/slab_common.c     | 14 ++++++++------
>  mm/slub.c            |  1 +
>  4 files changed, 14 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index fecf40b7be69..19ab1380f875 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -116,6 +116,10 @@
>  /* Objects are reclaimable */
>  #define SLAB_RECLAIM_ACCOUNT   ((slab_flags_t __force)0x00020000U)
>  #define SLAB_TEMPORARY         SLAB_RECLAIM_ACCOUNT    /* Objects are short-lived */
> +
> +/* Slab deactivation flag */
> +#define SLAB_DEACTIVATED       ((slab_flags_t __force)0x10000000U)
> +
>  /*
>   * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
>   *
> diff --git a/mm/slab.c b/mm/slab.c
> index a2e93adf1df0..e8c7743fc283 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2245,6 +2245,7 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
>  #ifdef CONFIG_MEMCG
>  void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
>  {
> +       cachep->flags |= SLAB_DEACTIVATED;
>         __kmem_cache_shrink(cachep);
>  }
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 146d8eaa639c..85cf0c374303 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1533,7 +1533,7 @@ static int memcg_slabinfo_show(struct seq_file *m, void *unused)
>         struct slabinfo sinfo;
>
>         mutex_lock(&slab_mutex);
> -       seq_puts(m, "# <name> <css_id[:dead]> <active_objs> <num_objs>");
> +       seq_puts(m, "# <name> <css_id[:dead|deact]> <active_objs> <num_objs>");
>         seq_puts(m, " <active_slabs> <num_slabs>\n");
>         list_for_each_entry(s, &slab_root_caches, root_caches_node) {
>                 /*
> @@ -1544,22 +1544,24 @@ static int memcg_slabinfo_show(struct seq_file *m, void *unused)
>
>                 memset(&sinfo, 0, sizeof(sinfo));
>                 get_slabinfo(s, &sinfo);
> -               seq_printf(m, "%-17s root      %6lu %6lu %6lu %6lu\n",
> +               seq_printf(m, "%-17s root       %6lu %6lu %6lu %6lu\n",
>                            cache_name(s), sinfo.active_objs, sinfo.num_objs,
>                            sinfo.active_slabs, sinfo.num_slabs);
>
>                 for_each_memcg_cache(c, s) {
>                         struct cgroup_subsys_state *css;
> -                       char *dead = "";
> +                       char *status = "";
>
>                         css = &c->memcg_params.memcg->css;
>                         if (!(css->flags & CSS_ONLINE))
> -                               dead = ":dead";
> +                               status = ":dead";
> +                       else if (c->flags & SLAB_DEACTIVATED)
> +                               status = ":deact";
>
>                         memset(&sinfo, 0, sizeof(sinfo));
>                         get_slabinfo(c, &sinfo);
> -                       seq_printf(m, "%-17s %4d%5s %6lu %6lu %6lu %6lu\n",
> -                                  cache_name(c), css->id, dead,
> +                       seq_printf(m, "%-17s %4d%-6s %6lu %6lu %6lu %6lu\n",
> +                                  cache_name(c), css->id, status,
>                                    sinfo.active_objs, sinfo.num_objs,
>                                    sinfo.active_slabs, sinfo.num_slabs);
>                 }
> diff --git a/mm/slub.c b/mm/slub.c
> index a384228ff6d3..c965b4413658 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4057,6 +4057,7 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
>          */
>         slub_set_cpu_partial(s, 0);
>         s->min_partial = 0;
> +       s->flags |= SLAB_DEACTIVATED;
>  }
>  #endif /* CONFIG_MEMCG */
>
> --
> 2.18.1
>

