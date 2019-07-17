Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 513EFC76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:02:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 219BE2184E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:02:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KV6HAxQG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 219BE2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7CA46B0269; Wed, 17 Jul 2019 14:02:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2DB38E0005; Wed, 17 Jul 2019 14:02:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A436A8E0003; Wed, 17 Jul 2019 14:02:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8540F6B0269
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:02:37 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id h203so19232858ywb.9
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 11:02:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yDzRsEyxIuuSai2DRMs+IGwIO+YipV0U+XFpyiaB7ek=;
        b=sH2WoFpyjX8cX/4tohFk0H9fT5QdEpBsToHhSODoRX6JanM5TT8wOmVOdKrXZInNNh
         dIFSCktNXqfPQlJxNcxhrSnaG7/WhagVsLnF7lNdbuQ6k+emUhptP+WSj4yfYLJLU/r1
         QgO8XJFIs9ytol+jTQ03UvMXSP2A1JetM4Cu3TK9EKPkVDV0p9RqYQFxWbjvu0s4+bwb
         voEkerh0J7g3Z79Hlc7Y95jfBPB0/DKnBkULMIuWL87QhGOQ0MnPqub8psSfAqEHVsgm
         Cts6pkd+X4LrGy8PuYZ1PsSndbHmlkv3tsos+1DbpF75xVbgSIls18LvbEu9qdvQUYZz
         e0Cg==
X-Gm-Message-State: APjAAAWD8G1TGWIv3EK4xxHg48oD8n8bv4ttrGm2nW6Y1r27itBCYksc
	dJc86vBRZd4VaRSwk89OL/zOMdqyBgcxs3pVkxpU23KU5HueG0mF8wy9eppJez4i+NkFE1qROIz
	LTj/j8bmeJdQ6bOf9QeQusXJdoTzCdN2BcKVrKjMl+c9xOAnTbVoXExTFTqBro4rVEw==
X-Received: by 2002:a5b:b41:: with SMTP id b1mr19498360ybr.277.1563386557268;
        Wed, 17 Jul 2019 11:02:37 -0700 (PDT)
X-Received: by 2002:a5b:b41:: with SMTP id b1mr19498304ybr.277.1563386556693;
        Wed, 17 Jul 2019 11:02:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563386556; cv=none;
        d=google.com; s=arc-20160816;
        b=SUOvW+5r/BOE9gw7Z8ofm0EIzh6OXW3hTXshGAc1RbT7dm5hkeKWPBSqNq2MX6Pble
         plOGtZe36Hccfv6luwu/WZ/jHAZWDefZQy8UfZdI7mYw/JA1gPoZY05tRTmVGsuQtTo6
         QloRQ67WpBI5YyhnX7Up/bj2cHweULIm/TJ/9TTDJIxVIw9Tfq5VSxgeX3/mJJ7kqIQ9
         pVOgYORtZhVxJGskygEPLNgq7Fh3tMFbxP2aVvvRr3m+Pe+GbF/ZzfzuZpy2n3Wd73zl
         mo5oaPVTWq7sIVzgNt/Yr7jJT5h4Oq52Q39hAqdzIgl2i2JOrqDEhUkPzvVSYDxB7Pk5
         T3Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yDzRsEyxIuuSai2DRMs+IGwIO+YipV0U+XFpyiaB7ek=;
        b=Es1V1hp6pkp/iIRgq0NU8EfKkoqHYTjYVIsjrUa0j13DO9ykOm2g5lWmLHq5OLOx6t
         YKMFqWU7f1a1CJ5Jr2LwLQMceysLCekk6gFiPf43BXpOvPNG6RsOu56hLM/KzeZiyjba
         0O4zPiZ2s52QisMayLNtM7CI7q4d29vXWndpqMfb6foVhUMsc6l5fUPq9GPPcKun/cBS
         +pw4gTGShLfYK0tFBQVL+JJD/JwftfqRlIhdYG6nCIXgVyEHyonbRLBDhJL6YGxAt2WQ
         O8xo7K98ZPJnL2RMHWOzH5Hp7/QHU9U82pBnYusg3G3HSyNVsd6kADoglmKEGknzEPKh
         g7cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KV6HAxQG;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i66sor2555390ywb.134.2019.07.17.11.02.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 11:02:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KV6HAxQG;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yDzRsEyxIuuSai2DRMs+IGwIO+YipV0U+XFpyiaB7ek=;
        b=KV6HAxQGdn6bho66u6GdESZdwwdD5tjW0fDv1ZWRFWmhV9jQO5H7q5tBN4YlahuMN8
         xHlxAttU7druDTETF9Oi1KMdYnaRSqBOoIn64k5cuiuYGQ4v+oGTISwXQraV6l5MxKnI
         /pXA0Z9KuUVxOjF1INofKw1JWFWI5GKL38xdnoah2mPGzZqrDlZuiPgsshkxn9SkE9RD
         4/C90o3L6ZPqIEBmWavIP7H2Mp3oautWncUe1weerJg8VfUv4DDUnoCeZp8rfQMjLfkU
         gDyKAi9AdYmM2rxLhZ3O2qlqNqvnSp+ODNOPhS3edwqcT+5bAxOtHefqfQAih6cPsWOx
         zMog==
X-Google-Smtp-Source: APXvYqx8Dv3M/w0Y+tfgf5v5o8BgqNuNH2nvV6nFlb9tCRft8Hoq2fYaYtrbULzBbF+h70b2g7Pn/ZHWVRQWxxJXD1U=
X-Received: by 2002:a0d:c345:: with SMTP id f66mr23890145ywd.10.1563386555880;
 Wed, 17 Jul 2019 11:02:35 -0700 (PDT)
MIME-Version: 1.0
References: <1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 17 Jul 2019 11:02:24 -0700
Message-ID: <CALvZod7CJ6W5RGRVzyc8J=dWgOHeHGFT+43NWGQjATvEqRjkMg@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: check if mem cgroup is disabled or not before
 calling memcg slab shrinker
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@suse.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, Roman Gushchin <guro@fb.com>, 
	Hugh Dickins <hughd@google.com>, Qian Cai <cai@lca.pw>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	stable@vger.kernel.org, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 10:45 AM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> Shakeel Butt reported premature oom on kernel with
> "cgroup_disable=memory" since mem_cgroup_is_root() returns false even
> though memcg is actually NULL.  The drop_caches is also broken.
>
> It is because commit aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab()
> calls in shrink_node()") removed the !memcg check before
> !mem_cgroup_is_root().  And, surprisingly root memcg is allocated even
> though memory cgroup is disabled by kernel boot parameter.
>
> Add mem_cgroup_disabled() check to make reclaimer work as expected.
>
> Fixes: aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab() calls in shrink_node()")
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org  4.19+
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/vmscan.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f8e3dcd..c10dc02 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -684,7 +684,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>         unsigned long ret, freed = 0;
>         struct shrinker *shrinker;
>
> -       if (!mem_cgroup_is_root(memcg))
> +       /*
> +        * The root memcg might be allocated even though memcg is disabled
> +        * via "cgroup_disable=memory" boot parameter.  This could make
> +        * mem_cgroup_is_root() return false, then just run memcg slab
> +        * shrink, but skip global shrink.  This may result in premature
> +        * oom.
> +        */
> +       if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
>                 return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>
>         if (!down_read_trylock(&shrinker_rwsem))
> --
> 1.8.3.1
>

