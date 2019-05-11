Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AA4BC04A6B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:33:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D104A217D6
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:33:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="j/7AW9ND"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D104A217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774BF6B0007; Fri, 10 May 2019 20:33:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FDA06B0008; Fri, 10 May 2019 20:33:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ECC66B000A; Fri, 10 May 2019 20:33:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C13C6B0007
	for <linux-mm@kvack.org>; Fri, 10 May 2019 20:33:23 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 11so12826523ywt.12
        for <linux-mm@kvack.org>; Fri, 10 May 2019 17:33:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sgSVfGODZNyEEQFjqirGNZR/8hnjEjcwoRyIzV62s/U=;
        b=MBS14Icxy19EDvtjUYknQYMzK4UNveSqIxlK6eoJD0eGvJWNdz5UCZ56QJkec8DDom
         oR8th1+oaxflzRTr35Gx9e1CB98516/C/4mCSS1/Nw9/va5rtRfWM7BhbyLK2DQzP/Uy
         JV93WPUqv95E1N+lBR3NiFCU1NbtbnEdOmOUw0JhV3qaKvGpoYE1SZM2P2aD3JmTrA6v
         38rgP8iroDlJV7RIGiIuEudmoWK154qAaC+STdapEIFDisdd5VpMNMjNCjYL++lVzCgA
         Tb1wh/ayD12NcriO/vwiL0uJsCao0NLjOuBdTablvhEYRMe5x2sp50AtnnfmgcMfGR2R
         HB5g==
X-Gm-Message-State: APjAAAUrgnEJl/4fcjirVbQZ70fFh7vIeu9ct2yWBurKr9GIZ0QUmNNp
	k5ZKWuJWOO10uT/gax49Bozr0k8D2hK49A1H6IDT1edLUhbEDnAiDYJPdYzcZFcoeqMsQLY+oSM
	6zKyZOCVbzxPBNerS2i3ERVWhReUzDWr5GTf0YJ+6JzzYQEYYK/Fu4qdHhhFCKDZxDA==
X-Received: by 2002:a81:3a4b:: with SMTP id h72mr7453058ywa.157.1557534803007;
        Fri, 10 May 2019 17:33:23 -0700 (PDT)
X-Received: by 2002:a81:3a4b:: with SMTP id h72mr7453029ywa.157.1557534802380;
        Fri, 10 May 2019 17:33:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557534802; cv=none;
        d=google.com; s=arc-20160816;
        b=FHfg+uthrd1tnnGrwfSZZpGR4KKmF7QzBfZ1qtJJUKmO2hDnMuZiULSSXzNZC1XE/I
         noX2TM19GAelLBB+YQPYw65mzwmLDSqMam/pK099wVI4fSZPRIMyGrYVbIhwXGWCw95J
         oGLuRyzldd4iP2ykj29ueaeiKhHMFnLm2dQMZxjW+n7vC1UDN40oT4EeklRyInMRbqGk
         8U5pfKFqvNG3QdsOcOjPq3/KWuk+XiKZylb0FSJ2I7BjGthBhwYRI+OX9s3PrxFFDznS
         Ntgs4jucH1nB7T+sxeNJAPqt+QS4I4df57r9eXduZjXSjnLN/p1SkAnowvcQzN9yq668
         bjbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sgSVfGODZNyEEQFjqirGNZR/8hnjEjcwoRyIzV62s/U=;
        b=S2T/Q68QmbL/7MtTyNd596SFQYN1CZvuSJnWAlrhpr6aWnG0vMzzbDGFdLRBKQytGp
         sSXGbPuN/SnhEloB9oGX/gMKuPmY959uTUiKdtzGzPKd9+ZKFtFUp+DUQ/ERharfjQap
         cnOKNBXVcP4ePKStOK/3BXpvK5a2p59yW8aygxN+F7WBOO8nzQVsERjnWxxpLV9DGY6H
         6TjmOvis2GIq3YPI8hyEg5UOsCev9zcdr33YfJ/qRr/spEDZ4xi2ChLITfHvsS69DGyS
         htI2kL9xMOI91KsSFbLyfbcae73aZbgOSw74lN2dCKe0JERjsRoCdQkOT2+pTadCTpa/
         iLSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="j/7AW9ND";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f131sor1351323ybc.59.2019.05.10.17.33.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 17:33:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="j/7AW9ND";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sgSVfGODZNyEEQFjqirGNZR/8hnjEjcwoRyIzV62s/U=;
        b=j/7AW9ND/YCb7fpUlCIDu4CtWdaw+gNTEb78YjW42tti4DswHvmdv1fY/gad+Gof/S
         2fqgvpZh/3xg9lmvW05tWTyiMqY2v8WnbZfYnssAZHbwgVjL+jOs/rZFKhEnenFyB2yc
         EJ7HXgw6W38QUAkiBqABojxJ7MmmBj2K8BRP0LYmXvLycqiGDta26173/MSOtoyWhgV0
         oUGcrZRVVkUUk6zIVRTPJNuc2mp0lduQlMPk17IujjMLuipV518yH9q0ieS4q/sd1Tq9
         XEXksvzQ2RnJUPvzI4NKRtae7kbccTDP8QyAq8EaJ8rCO/aoTSXyUiBtYazqeZ8XK1nI
         bzOg==
X-Google-Smtp-Source: APXvYqxU2FO4D03Bonf/ZZELd4cfkZT2F6rpo69EGUgTyzSwY6vPlPXacS+XvNL9OVjozme5Yqz/cp9a0cwLEM3xGGU=
X-Received: by 2002:a25:a2c1:: with SMTP id c1mr6893225ybn.496.1557534801871;
 Fri, 10 May 2019 17:33:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190508202458.550808-1-guro@fb.com> <20190508202458.550808-4-guro@fb.com>
In-Reply-To: <20190508202458.550808-4-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 May 2019 17:33:10 -0700
Message-ID: <CALvZod4nvTnxvb2UKxvRiYMH9NRcuhat5FwvPDOFMCzZ+aeLxQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/7] mm: introduce __memcg_kmem_uncharge_memcg()
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Date: Wed, May 8, 2019 at 1:30 PM
To: Andrew Morton, Shakeel Butt
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
<kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
Gushchin

> Let's separate the page counter modification code out of
> __memcg_kmem_uncharge() in a way similar to what
> __memcg_kmem_charge() and __memcg_kmem_charge_memcg() work.
>
> This will allow to reuse this code later using a new
> memcg_kmem_uncharge_memcg() wrapper, which calls
> __memcg_kmem_unchare_memcg() if memcg_kmem_enabled()

__memcg_kmem_uncharge_memcg()

> check is passed.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>


> ---
>  include/linux/memcontrol.h | 10 ++++++++++
>  mm/memcontrol.c            | 25 +++++++++++++++++--------
>  2 files changed, 27 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 36bdfe8e5965..deb209510902 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1298,6 +1298,8 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
>  void __memcg_kmem_uncharge(struct page *page, int order);
>  int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>                               struct mem_cgroup *memcg);
> +void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
> +                                unsigned int nr_pages);
>
>  extern struct static_key_false memcg_kmem_enabled_key;
>  extern struct workqueue_struct *memcg_kmem_cache_wq;
> @@ -1339,6 +1341,14 @@ static inline int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp,
>                 return __memcg_kmem_charge_memcg(page, gfp, order, memcg);
>         return 0;
>  }
> +
> +static inline void memcg_kmem_uncharge_memcg(struct page *page, int order,
> +                                            struct mem_cgroup *memcg)
> +{
> +       if (memcg_kmem_enabled())
> +               __memcg_kmem_uncharge_memcg(memcg, 1 << order);
> +}
> +
>  /*
>   * helper for accessing a memcg's index. It will be used as an index in the
>   * child cache array in kmem_cache, and also to derive its name. This function
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 48a8f1c35176..b2c39f187cbb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2750,6 +2750,22 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
>         css_put(&memcg->css);
>         return ret;
>  }
> +
> +/**
> + * __memcg_kmem_uncharge_memcg: uncharge a kmem page
> + * @memcg: memcg to uncharge
> + * @nr_pages: number of pages to uncharge
> + */
> +void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
> +                                unsigned int nr_pages)
> +{
> +       if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +               page_counter_uncharge(&memcg->kmem, nr_pages);
> +
> +       page_counter_uncharge(&memcg->memory, nr_pages);
> +       if (do_memsw_account())
> +               page_counter_uncharge(&memcg->memsw, nr_pages);
> +}
>  /**
>   * __memcg_kmem_uncharge: uncharge a kmem page
>   * @page: page to uncharge
> @@ -2764,14 +2780,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
>                 return;
>
>         VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
> -
> -       if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> -               page_counter_uncharge(&memcg->kmem, nr_pages);
> -
> -       page_counter_uncharge(&memcg->memory, nr_pages);
> -       if (do_memsw_account())
> -               page_counter_uncharge(&memcg->memsw, nr_pages);
> -
> +       __memcg_kmem_uncharge_memcg(memcg, nr_pages);
>         page->mem_cgroup = NULL;
>
>         /* slab pages do not have PageKmemcg flag set */
> --
> 2.20.1
>

