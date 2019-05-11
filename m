Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9936DC04A6B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:34:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F00A217D6
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:34:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ldjw+nnH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F00A217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06EAA6B000D; Fri, 10 May 2019 20:34:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01FFD6B000E; Fri, 10 May 2019 20:34:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E50E16B0010; Fri, 10 May 2019 20:34:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id C699E6B000D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 20:34:20 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id t141so12342585ywe.23
        for <linux-mm@kvack.org>; Fri, 10 May 2019 17:34:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UdR8JD8KNYcClfaFJdc0xlMZRTEn4yngxUY4SL7WlW0=;
        b=ki71jkanrY4A5H1tpsVJQ+FCLChUyTBm5gLsi8fArpUWeHM4C2zLpvMkuRjEsqONGP
         i37cebd4hCNIbcv+dOb+qCiDZFunsg3SA2cBCbK/1x0nEeewiTRj5rs2n7kXSKEQlgN0
         KWTosGusK6fkmpcbmDpa8fZCFN2aKBQXyaJzjO/zRRl2ek5ijLL9g2LhLBkcEpCmvkl5
         XDC6h4SlzDtvZKO9W0Ljl8O89e5pT4C7Q0iM538hme/eFwYv87I0v04ErBjUe+OGshE5
         flnSHo58fIWH6psSw7faZoTWGxWfnxl37lTspcAFP5dV8r2Xj0n24qK/WjdqgMJJKXDi
         DyYQ==
X-Gm-Message-State: APjAAAVMDItrW0TZf/8jHT9+mFizwTjzOYPNiRz6KxFFcf4nR54vBqkR
	PouJYu5YZAhysotyKL0jnCJxyoyo7AE/rpAbG2kS9YqLMVr7Ytd6tybu9tzHtHLB+jB4cNe/B9Q
	aDowYpfsBwPpfeJW/tSRuwSEQPzuUfQm2ZV1Yxcq05EMVTDbprqiWP1Qp8nXRpJH1pA==
X-Received: by 2002:a25:7653:: with SMTP id r80mr2729778ybc.514.1557534860606;
        Fri, 10 May 2019 17:34:20 -0700 (PDT)
X-Received: by 2002:a25:7653:: with SMTP id r80mr2729764ybc.514.1557534859969;
        Fri, 10 May 2019 17:34:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557534859; cv=none;
        d=google.com; s=arc-20160816;
        b=K5iplPtHsh1r+g0EHurIZA5PNW1KZEOEkDVuLAqziaWA3K37pNEj/SiBqU6gsjFDP5
         7/gorSkic1zgxYFelJb2U+dCM4Wg2N4mqVYpADYkd+IyMqoVPiW+DE1HWfJeESK+JaKd
         LhxQDiqpJQRrRK2AyjDyAtgYwI5IzZbxDmQ13X66TqSa/fJJari+IL6Xvqo+UdQkxU1N
         HQ4V47eUh8xbOI0Cd1oM2ryDpotSDq+uotkRHRXI/prTxBSj6xWeXpXzRRY9hOhRxdq9
         /Uidr4XdVYl2DnCfsGjjdAjtkOoI3XStHD4J8a1YJGxIuCfOpw4L0r6z3ZqtF8E2C+is
         cPeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UdR8JD8KNYcClfaFJdc0xlMZRTEn4yngxUY4SL7WlW0=;
        b=BnV/thve0W62aNrSPRAs0D81VS6mk9SCsWrHU5Y/MSf+24Xz8J6OakCCR4Orlyi8yN
         YeE/50d0MbSPgr+JRymFNt8z6LDOt2uHrkk+XXTFs2ZU7/WsCYCrTLlYBwgezvLxxGrM
         nNiJcljQBKnBeRE7CdriNkVMRmWnbXlBSP6/uKMzPwkWQSb3H2liH4FkwL1r2g2XzznS
         aVpZoX9t/kR+vWVUJ5vhbk9m6/rGNB0q88blgStEaZlSPk6Z09MB/vUdp4PSlHfpJRHO
         9Lxw9JoDfHkOkaf/rhceVEIykT5twFzF9AYYsRkLsxXfzFXwbV+yTh5/hxJbUxSyoEvr
         scVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ldjw+nnH;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w206sor2946181ywb.171.2019.05.10.17.34.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 17:34:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ldjw+nnH;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UdR8JD8KNYcClfaFJdc0xlMZRTEn4yngxUY4SL7WlW0=;
        b=ldjw+nnHKtK+fTb3weGK94cuP7qxL2t2RlNOFIukoBDh3zAGfoairpjWMbIy5l0awC
         Cme3/bk3ny+bZNg+Sk7MaNgjTzhXOTneCTyRQFxQFgkDjo+F43dfkwIAhr2ZDouf1ews
         ujrOSdkBOctfat+ir1VYjVQlB0jBB99jcYRj0lyEITB/Gf2XJgd3ff8voLr+y2opCB/C
         n4J26cguL50D8zOOjX+oxASqm3If2L17oo63Q8Jn+fD2R36iAm/rUY6vb5zRAUKQbHYH
         X5OWy/+DZyxzP1ozyftiL0Tx8uW2O7TiguDuR848V0mrs0l+HQDsrETH2rnVapR2eryN
         +1TQ==
X-Google-Smtp-Source: APXvYqzMzoHGg899Vyb0ItflS72q8KkTnThgd/WORnQ3DVf4ygp5Lx6Lfya9tCIS3swbhrAwy7E449I3E1e5y2H8Xs0=
X-Received: by 2002:a0d:ff82:: with SMTP id p124mr7980895ywf.409.1557534859480;
 Fri, 10 May 2019 17:34:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190508202458.550808-1-guro@fb.com> <20190508202458.550808-8-guro@fb.com>
In-Reply-To: <20190508202458.550808-8-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 May 2019 17:34:08 -0700
Message-ID: <CALvZod5L=DXdcb87pbkxLoQnGxhH6W_nvJCoqEDdRTQ5h6R80g@mail.gmail.com>
Subject: Re: [PATCH v3 7/7] mm: fix /proc/kpagecgroup interface for slab pages
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
Date: Wed, May 8, 2019 at 1:40 PM
To: Andrew Morton, Shakeel Butt
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
<kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
Gushchin

> Switching to an indirect scheme of getting mem_cgroup pointer for
> !root slab pages broke /proc/kpagecgroup interface for them.
>
> Let's fix it by learning page_cgroup_ino() how to get memcg
> pointer for slab pages.
>
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  mm/memcontrol.c  |  5 ++++-
>  mm/slab.h        | 21 +++++++++++++++++++++
>  mm/slab_common.c |  1 +
>  3 files changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6e4d9ed16069..8114838759f6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -494,7 +494,10 @@ ino_t page_cgroup_ino(struct page *page)
>         unsigned long ino = 0;
>
>         rcu_read_lock();
> -       memcg = READ_ONCE(page->mem_cgroup);
> +       if (PageSlab(page))
> +               memcg = memcg_from_slab_page(page);
> +       else
> +               memcg = READ_ONCE(page->mem_cgroup);
>         while (memcg && !(memcg->css.flags & CSS_ONLINE))
>                 memcg = parent_mem_cgroup(memcg);
>         if (memcg)
> diff --git a/mm/slab.h b/mm/slab.h
> index acdc1810639d..cb684fbe2cc2 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -256,6 +256,22 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
>         return s->memcg_params.root_cache;
>  }
>

Can you please document the preconditions of this function? It seems
like it must be PageSlab() then why need to check PageTail and do
compound_head().


> +static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
> +{
> +       struct kmem_cache *s;
> +
> +       WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +       if (PageTail(page))
> +               page = compound_head(page);
> +
> +       s = READ_ONCE(page->slab_cache);
> +       if (s && !is_root_cache(s))
> +               return rcu_dereference(s->memcg_params.memcg);
> +
> +       return NULL;
> +}
> +
>  static __always_inline int memcg_charge_slab(struct page *page,
>                                              gfp_t gfp, int order,
>                                              struct kmem_cache *s)
> @@ -338,6 +354,11 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
>         return s;
>  }
>
> +static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
> +{
> +       return NULL;
> +}
> +
>  static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
>                                     struct kmem_cache *s)
>  {
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 36673a43ed31..0cfdad0a0aac 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -253,6 +253,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
>                 list_del(&s->memcg_params.kmem_caches_node);
>                 mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
>                         lockdep_is_held(&slab_mutex)));
> +               rcu_assign_pointer(s->memcg_params.memcg, NULL);
>         }
>  }
>  #else
> --
> 2.20.1
>

