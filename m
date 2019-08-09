Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0492BC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CF0A214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:37:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="X105Vy7W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CF0A214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E96F96B0003; Fri,  9 Aug 2019 15:37:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4EA16B0005; Fri,  9 Aug 2019 15:37:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0E8F6B0010; Fri,  9 Aug 2019 15:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A35906B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 15:37:48 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id b4so70881177otf.15
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 12:37:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=C1zjsaY/5X9pgLr5EhZ6Dhm4kHVCrretdr/qFF1Np8A=;
        b=reY7Zw3aQa41pdQfsOueYU7ab8ophASli/o4oU7afg9e22xwbhLVeY605VVau6vvqp
         CuXhSPBUmdWLUGxH+8aJWkyEbZD2+TnmWb+fDXzUf/6vrhbW1ayDXP5JjzS+o/rQzRnF
         5XdTvBv2W1ASWm+L4a/r7oyWXHTPomoeM1/CbooINt0XO9VfUWId34lOsxAjd02uBVKm
         2iU4ywy1xBpb0M9ZZCRPB8Fu3qPU7V0833aP2xinGLcRotnhM5NvUdjHl2pZ12nXAkWs
         SBCQ5b5XBXRn4lU07dv1QzCKIxWJgL24r0Uxil6D91fL5juheSVNfqRoG4xQaLV3UX+S
         liog==
X-Gm-Message-State: APjAAAXZ5dZwT8tnTXKjFT9EchR9sZKNqV8SisnCmkq6qPBvO8DKbseq
	b0gbw2hrzfAjWyIRulmnY8oVq5YNS5rEpALA+b1ryQrMSNW93uyh9HjW3pcC2XZgv1DnGa8jfBu
	ua2GxQPJHNwamfjf+kc1nu3GIW5rxKE1pLGvPEkgs9VgAcjjNksQDqoLXJuhLJg8Fiw==
X-Received: by 2002:a5d:9ad6:: with SMTP id x22mr22151457ion.136.1565379468259;
        Fri, 09 Aug 2019 12:37:48 -0700 (PDT)
X-Received: by 2002:a5d:9ad6:: with SMTP id x22mr22151412ion.136.1565379467460;
        Fri, 09 Aug 2019 12:37:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565379467; cv=none;
        d=google.com; s=arc-20160816;
        b=ldAhm+ioepzL22f3xnG3W+7XBJPrfshlPE/PrKoqu90jqUVREoEaftEzFCjX+1ckog
         WwNuCP+80JP/3DSR09OlQKPQXLj7dxj96o2wjsd6Aw1ekcG5K+esxR4nwhP9eJaKJL/X
         PdOoTJZuLJR38B+aRyfRBCOLjETLCR1EzBpfeJTrjj2wyacwPTJ5RYJLRdG6dfdWTi5+
         3NXYu9OD93JZ8P2iA+nM+GhWthMh2VY4AB0g8jnEswq/7BaY1Q0ce9ANFRZGS/gsjEyQ
         UnrWLGxtFFNQhehv2rQclo/23Kmx0XO1wK27QUqL5QjYqBQ2qZ3v0hQYCrow+Ph5DCqw
         9B0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=C1zjsaY/5X9pgLr5EhZ6Dhm4kHVCrretdr/qFF1Np8A=;
        b=o7Ci2wIGf5b9jpQovQS4IWO5ZpOds4ip0W+GtkP8vkqcybzOHMDiMs44kmn8CWPZqk
         Kax/1mnMfLquOCYYBVm+hOGeRuYnrJodixdG9/Pyn1gQFQorutXilCRJkpHOeKi15niI
         3imki4ihOGGqaP0Wx7efaqjS88yO5hKjAIjqHe7eArRshemXqIefnmGkRS1+hndljvBp
         uxx8GSFC4psfZS5+fMVMvwv6vKdUbGPTta5WsTyTn2LreKdQQFVN9VRiZuGvt2b3qo+g
         GiASbLNa/DGw53qH+DeAnD9BEAjZkg0iJIFua7D8KXzMChb6989AJmQ8oh/Adb7zp5+m
         fTOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X105Vy7W;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor6209033ioi.76.2019.08.09.12.37.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 12:37:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X105Vy7W;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=C1zjsaY/5X9pgLr5EhZ6Dhm4kHVCrretdr/qFF1Np8A=;
        b=X105Vy7WLgr+xjAhRSnBDjw59MKMCD365GQvxhqK6dp8ABjh/cjQpB3KFzaNKJ9Wzv
         s+9+ef5b8d7DO4yrNC64EBP3yAKa0uEdIfTJYw6h3+s5e6wTd68vJs7ms+KPRBYptCLj
         vOmGejQSRxKmWPYLYb8UH7ToALVnDOLSFHviqf8qcfPmF86+7p1LixIwk5fq3bJeJolf
         jum8pTfWhB1MU+uvUPq1YLGxopjiHs9/xwiaT5QIn0BTD3lwtP+z3VHcID6z1YCg82pd
         mn1yKVPubYd+coEN88FlVAvl0eCDGswavgrI1X9aSFv/BVexXGOZkw4kQNmoSJ7bSIbM
         0drw==
X-Google-Smtp-Source: APXvYqy68srnKh4SexgO3Zncd4I5Uo4xelzxCYMO2rib83tF2sFznKjEVLp+1sCN5vVoGDpHxbI8Y5IJEQ/a/J6++UE=
X-Received: by 2002:a5e:9e03:: with SMTP id i3mr5084310ioq.66.1565379466849;
 Fri, 09 Aug 2019 12:37:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190809164643.5978-1-henryburns@google.com>
In-Reply-To: <20190809164643.5978-1-henryburns@google.com>
From: Henry Burns <henryburns@google.com>
Date: Fri, 9 Aug 2019 12:37:11 -0700
Message-ID: <CAGQXPThn2e8KPmeuH5urEz5e9unUL0CDRJDrEWuGezzboOo3wQ@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix race between migration and destruction
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, henrywolfeburns@gmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've just CC'd a personal email here so that I can respond to any
replies after today.

On Fri, Aug 9, 2019 at 9:46 AM Henry Burns <henryburns@google.com> wrote:
>
> In z3fold_destroy_pool() we call destroy_workqueue(&pool->compact_wq).
> However, we have no guarantee that migration isn't happening in the
> background at that time.
>
> Migration directly calls queue_work_on(pool->compact_wq), if destruction
> wins that race we are using a destroyed workqueue.
>
> Signed-off-by: Henry Burns <henryburns@google.com>
> ---
>  mm/z3fold.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 51 insertions(+)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 78447cecfffa..e136d97ce56e 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -40,6 +40,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/slab.h>
>  #include <linux/spinlock.h>
> +#include <linux/wait.h>
>  #include <linux/zpool.h>
>
>  /*
> @@ -161,8 +162,10 @@ struct z3fold_pool {
>         const struct zpool_ops *zpool_ops;
>         struct workqueue_struct *compact_wq;
>         struct workqueue_struct *release_wq;
> +       struct wait_queue_head isolate_wait;
>         struct work_struct work;
>         struct inode *inode;
> +       int isolated_pages;
>  };
>
>  /*
> @@ -772,6 +775,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
>                 goto out_c;
>         spin_lock_init(&pool->lock);
>         spin_lock_init(&pool->stale_lock);
> +       init_waitqueue_head(&pool->isolate_wait);
>         pool->unbuddied = __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
>         if (!pool->unbuddied)
>                 goto out_pool;
> @@ -811,6 +815,15 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
>         return NULL;
>  }
>
> +static bool pool_isolated_are_drained(struct z3fold_pool *pool)
> +{
> +       bool ret;
> +
> +       spin_lock(&pool->lock);
> +       ret = pool->isolated_pages == 0;
> +       spin_unlock(&pool->lock);
> +       return ret;
> +}
>  /**
>   * z3fold_destroy_pool() - destroys an existing z3fold pool
>   * @pool:      the z3fold pool to be destroyed
> @@ -821,6 +834,13 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
>  {
>         kmem_cache_destroy(pool->c_handle);
>
> +       /*
> +        * We need to ensure that no pages are being migrated while we destroy
> +        * these workqueues, as migration can queue work on either of the
> +        * workqueues.
> +        */
> +       wait_event(pool->isolate_wait, !pool_isolated_are_drained(pool));
> +
>         /*
>          * We need to destroy pool->compact_wq before pool->release_wq,
>          * as any pending work on pool->compact_wq will call
> @@ -1317,6 +1337,28 @@ static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
>         return atomic64_read(&pool->pages_nr);
>  }
>
> +/*
> + * z3fold_dec_isolated() expects to be called while pool->lock is held.
> + */
> +static void z3fold_dec_isolated(struct z3fold_pool *pool)
> +{
> +       assert_spin_locked(&pool->lock);
> +       VM_BUG_ON(pool->isolated_pages <= 0);
> +       pool->isolated_pages--;
> +
> +       /*
> +        * If we have no more isolated pages, we have to see if
> +        * z3fold_destroy_pool() is waiting for a signal.
> +        */
> +       if (pool->isolated_pages == 0 && waitqueue_active(&pool->isolate_wait))
> +               wake_up_all(&pool->isolate_wait);
> +}
> +
> +static void z3fold_inc_isolated(struct z3fold_pool *pool)
> +{
> +       pool->isolated_pages++;
> +}
> +
>  static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
>  {
>         struct z3fold_header *zhdr;
> @@ -1343,6 +1385,7 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
>                 spin_lock(&pool->lock);
>                 if (!list_empty(&page->lru))
>                         list_del(&page->lru);
> +               z3fold_inc_isolated(pool);
>                 spin_unlock(&pool->lock);
>                 z3fold_page_unlock(zhdr);
>                 return true;
> @@ -1417,6 +1460,10 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
>
>         queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
>
> +       spin_lock(&pool->lock);
> +       z3fold_dec_isolated(pool);
> +       spin_unlock(&pool->lock);
> +
>         page_mapcount_reset(page);
>         put_page(page);
>         return 0;
> @@ -1436,10 +1483,14 @@ static void z3fold_page_putback(struct page *page)
>         INIT_LIST_HEAD(&page->lru);
>         if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
>                 atomic64_dec(&pool->pages_nr);
> +               spin_lock(&pool->lock);
> +               z3fold_dec_isolated(pool);
> +               spin_unlock(&pool->lock);
>                 return;
>         }
>         spin_lock(&pool->lock);
>         list_add(&page->lru, &pool->lru);
> +       z3fold_dec_isolated(pool);
>         spin_unlock(&pool->lock);
>         z3fold_page_unlock(zhdr);
>  }
> --
> 2.22.0.770.g0f2c4a37fd-goog
>

