Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A892DC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 19:53:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47199205C9
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 19:53:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VV9Ppa9u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47199205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C15F46B0003; Tue,  6 Aug 2019 15:53:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA02F6B0006; Tue,  6 Aug 2019 15:53:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A65E96B0007; Tue,  6 Aug 2019 15:53:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 748466B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 15:53:44 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a8so50390556oti.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 12:53:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EqsW5OxmHQog0ub+PR7AiYisz4NBU3NrkElZBQlr6Eg=;
        b=Iwmb2Ay6vSX1vtYQDJh8d0NOxvp8u81lCs9vwElEnPhrIWbQ9YZ7K/7QeQs4WP+JJN
         AT8z8ufk4ot+RAQOinG/TTHbfXtIg0MAm5F8ZucFL8KiITumyv5PNWpZsEmwOomyaSyW
         Jvv/lUdPfgUxv/0va3FGj4cJUJh1x68vXQG0vPx9wkc3ywbPIlYKAvm0bWKLMXvnq+uO
         jn1UXYaqkuyoR8ef0YmW2WLuh07rKx0gdOxR5nHN2nHkyaO1gxykUBcd42+KG3PBv0PU
         99bthWgScVAW1ZT2olRIZQFViSFN1/SJRDhrLyaHwNfHX+C71bUohlqNQ5sUeInlcup/
         LDXQ==
X-Gm-Message-State: APjAAAVj2Mo/rz6aNC7pLcOOmzXAmKobwil5EEbloQfQ1Jxm0nvv+czY
	TG5tJS0pvnZK8OSUrlWmXH9JJcO85edHUrGWmuTx0xZCGJwDlm1ruEFfgrbVttYJgIvsefL//tv
	OabdHLZz/OmWoYG7LIWX3EdJvEqMa5nj7MY09nVclO4EVGIp4sRF1tugh8iUIz7dlCg==
X-Received: by 2002:a02:cc76:: with SMTP id j22mr6099728jaq.9.1565121223862;
        Tue, 06 Aug 2019 12:53:43 -0700 (PDT)
X-Received: by 2002:a02:cc76:: with SMTP id j22mr6099664jaq.9.1565121222818;
        Tue, 06 Aug 2019 12:53:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565121222; cv=none;
        d=google.com; s=arc-20160816;
        b=jsNjhfus3MlWgSt/GpmJ7A7iL8Gnn5alA1fJLnG51kvkWuMNmXpVgN8rnFwritRQpm
         W1Q4Tk4lyf2lI9GjCgX5n3iUIah0EYiaMdab5N4wQQxT5rnJCeiw0tVo/doWEJZJyLbS
         UU3gFeFCH7VltiJOS0yhAeqGqqPxUMe0qg/UyIV+c2+jCeexk8frTrbx5+HlOHXCFSZ0
         yE76UsXDTwxSGBN3ukBYhowV7xx4cShZKMKQLYESMuslLBzil3VHMiw301nebGwO9lqt
         /8UJnpd5+g/Wd/JM+wDvIjlFhNXqEnUMmvPfdWbOAJELmHR9UYJPDgfmBUeHIR8n/KgT
         bP6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EqsW5OxmHQog0ub+PR7AiYisz4NBU3NrkElZBQlr6Eg=;
        b=iRHrbg1ITuDLVdadxCLBFcjnNbds0XyMMLWnLEj7VvwE9LuXuSjD/vQIl63ZP/CoSz
         UXofo9SXjZGfWQ+GD6yl3Fv0xfpngs2fCBKl0p57owUgoQnWx6YnNkdiG2oiFHWM02xD
         wWfVLy1bPMDp0ElepEjzjL4+5sCFYl40d8MqqhuH36WE9UCaSJpHU8qlfkIzQKkxeYOI
         HBc6iBbAbQbCZ6db8S4EzVQC8IPaF/JwhlyI64IL3LUCLk2Wo85rHNA3HH3QKM6LDB+/
         Yek4/zaGTPAuBHSDFkpNff6qwZ1EEJGDqM9MFCk0U+etUKJzUZxMjJqheRyunqYcTF5J
         jeuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VV9Ppa9u;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b144sor59544284iof.53.2019.08.06.12.53.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 12:53:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VV9Ppa9u;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EqsW5OxmHQog0ub+PR7AiYisz4NBU3NrkElZBQlr6Eg=;
        b=VV9Ppa9ubKevm1FzmVSanYWoYM0w7rLwWRQmH965qhyVf1qatFwRlusXKU/hTIjN/F
         IGToUS+l7tA+5npP8+46S8ldh8waArpKKeXjxGZU+wRX1VNMT5mlsXobnrk4Q2YVf4Nh
         axRqXmQ7WKuzDsjRxzbt4No6hSL7FTZTTLuX2Xt1B2jqW3czAGvb8xcvf/jlPpjgMWlQ
         vebcyyCW8t1ZXr0E1jPM/vjquO5UdIrsBzFiTlo8s3XwrDwxy/ywQSTgWL65/Tu1q03U
         pwfVuJS1FaZZIrMlUKIbHjF/TkZ6S0nQ5eI1C8MAYjQjRqV4FxZo7NCvMcm13Iqn0pnK
         Wvwg==
X-Google-Smtp-Source: APXvYqwwLAAeLEryd1T7Fj/e7qjG8GzcaLSq1KsTk2lQtSKu8Wn++OZ/kBVzpBstbZZetXSWgB410s/9UQ4SvZCq298=
X-Received: by 2002:a05:6602:cc:: with SMTP id z12mr5424136ioe.86.1565121222227;
 Tue, 06 Aug 2019 12:53:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190802015332.229322-1-henryburns@google.com>
 <20190802015332.229322-2-henryburns@google.com> <20190805042821.GA102749@google.com>
 <CAGQXPTiHtNJsBz8dGCvejtmvGgPNHBoQHSmbX4XkxJ5DTmUWGg@mail.gmail.com> <20190806013846.GA71899@google.com>
In-Reply-To: <20190806013846.GA71899@google.com>
From: Henry Burns <henryburns@google.com>
Date: Tue, 6 Aug 2019 12:53:06 -0700
Message-ID: <CAGQXPThXpTwnV+VM2qSyJyRv9LzKhVStCE5SORWBrwddBr2OCw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/zsmalloc.c: Fix race condition in zs_destroy_pool
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, 
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, henrywolfeburns@gmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By the way, I will lose access to this email in 3 days, so I've cc'd a
personal email.


On Mon, Aug 5, 2019 at 6:38 PM Minchan Kim <minchan@kernel.org> wrote:
> On Mon, Aug 05, 2019 at 10:34:41AM -0700, Henry Burns wrote:
> > On Sun, Aug 4, 2019 at 9:28 PM Minchan Kim <minchan@kernel.org> wrote:
> > > On Thu, Aug 01, 2019 at 06:53:32PM -0700, Henry Burns wrote:
> > > > In zs_destroy_pool() we call flush_work(&pool->free_work). However, we
> > > > have no guarantee that migration isn't happening in the background
> > > > at that time.
> > > >
> > > > Since migration can't directly free pages, it relies on free_work
> > > > being scheduled to free the pages.  But there's nothing preventing an
> > > > in-progress migrate from queuing the work *after*
> > > > zs_unregister_migration() has called flush_work().  Which would mean
> > > > pages still pointing at the inode when we free it.
> > >
> > > We already unregister shrinker so there is no upcoming async free call
> > > via shrinker so the only concern is zs_compact API direct call from
> > > the user. Is that what what you desribe from the description?
> >
> > What I am describing is a call to zsmalloc_aops->migratepage() by
> > kcompactd (which can call schedule work in either
> > zs_page_migrate() or zs_page_putback should the zspage become empty).
> >
> > While we are migrating a page, we remove it from the class. Suppose
> > zs_free() loses a race with migration. We would schedule
> > async_free_zspage() to handle freeing that zspage, however we have no
> > guarantee that migration has finished
> > by the time we finish flush_work(&pool->work). In that case we then
> > call iput(inode), and now we have a page
> > pointing to a non-existent inode. (At which point something like
> > kcompactd would potentially BUG() if it tries to get a page
> > (from the inode) that doesn't exist anymore)
> >
>
> True.
> I totally got mixed up internal migration and external migration. :-/
>
> >
> > >
> > > If so, can't we add a flag to indicate destroy of the pool and
> > > global counter to indicate how many of zs_compact was nested?
> > >
> > > So, zs_unregister_migration in zs_destroy_pool can set the flag to
> > > prevent upcoming zs_compact call and wait until the global counter
> > > will be zero. Once it's done, finally flush the work.
> > >
> > > My point is it's not a per-class granuarity but global.
> >
> > We could have a pool level counter of isolated pages, and wait for
> > that to finish before starting flush_work(&pool->work); However,
> > that would require an atomic_long in zs_pool, and we would have to eat
> > the cost of any contention over that lock. Still, it might be
> > preferable to a per-class granularity.
>
> That would be better for performance-wise but how it's significant?
> Migration is not already hot path so adding a atomic variable in that path
> wouldn't make noticible slow.
>
> Rather than performance, my worry is maintainance so prefer simple and
> not fragile.

It sounds to me like you are saying that the current approach is fine, does this
match up with your understanding?

>
> >
> > >
> > > Thanks.
> > >
> > > >
> > > > Since we know at destroy time all objects should be free, no new
> > > > migrations can come in (since zs_page_isolate() fails for fully-free
> > > > zspages).  This means it is sufficient to track a "# isolated zspages"
> > > > count by class, and have the destroy logic ensure all such pages have
> > > > drained before proceeding.  Keeping that state under the class
> > > > spinlock keeps the logic straightforward.
> > > >
> > > > Signed-off-by: Henry Burns <henryburns@google.com>
> > > > ---
> > > >  mm/zsmalloc.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++---
> > > >  1 file changed, 65 insertions(+), 3 deletions(-)
> > > >
> > > > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > > > index efa660a87787..1f16ed4d6a13 100644
> > > > --- a/mm/zsmalloc.c
> > > > +++ b/mm/zsmalloc.c
> > > > @@ -53,6 +53,7 @@
> > > >  #include <linux/zpool.h>
> > > >  #include <linux/mount.h>
> > > >  #include <linux/migrate.h>
> > > > +#include <linux/wait.h>
> > > >  #include <linux/pagemap.h>
> > > >  #include <linux/fs.h>
> > > >
> > > > @@ -206,6 +207,10 @@ struct size_class {
> > > >       int objs_per_zspage;
> > > >       /* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> > > >       int pages_per_zspage;
> > > > +#ifdef CONFIG_COMPACTION
> > > > +     /* Number of zspages currently isolated by compaction */
> > > > +     int isolated;
> > > > +#endif
> > > >
> > > >       unsigned int index;
> > > >       struct zs_size_stat stats;
> > > > @@ -267,6 +272,8 @@ struct zs_pool {
> > > >  #ifdef CONFIG_COMPACTION
> > > >       struct inode *inode;
> > > >       struct work_struct free_work;
> > > > +     /* A workqueue for when migration races with async_free_zspage() */
> > > > +     struct wait_queue_head migration_wait;
> > > >  #endif
> > > >  };
> > > >
> > > > @@ -1917,6 +1924,21 @@ static void putback_zspage_deferred(struct zs_pool *pool,
> > > >
> > > >  }
> > > >
> > > > +static inline void zs_class_dec_isolated(struct zs_pool *pool,
> > > > +                                      struct size_class *class)
> > > > +{
> > > > +     assert_spin_locked(&class->lock);
> > > > +     VM_BUG_ON(class->isolated <= 0);
> > > > +     class->isolated--;
> > > > +     /*
> > > > +      * There's no possibility of racing, since wait_for_isolated_drain()
> > > > +      * checks the isolated count under &class->lock after enqueuing
> > > > +      * on migration_wait.
> > > > +      */
> > > > +     if (class->isolated == 0 && waitqueue_active(&pool->migration_wait))
> > > > +             wake_up_all(&pool->migration_wait);
> > > > +}
> > > > +
> > > >  static void replace_sub_page(struct size_class *class, struct zspage *zspage,
> > > >                               struct page *newpage, struct page *oldpage)
> > > >  {
> > > > @@ -1986,6 +2008,7 @@ static bool zs_page_isolate(struct page *page, isolate_mode_t mode)
> > > >        */
> > > >       if (!list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
> > > >               get_zspage_mapping(zspage, &class_idx, &fullness);
> > > > +             class->isolated++;
> > > >               remove_zspage(class, zspage, fullness);
> > > >       }
> > > >
> > > > @@ -2085,8 +2108,14 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> > > >        * Page migration is done so let's putback isolated zspage to
> > > >        * the list if @page is final isolated subpage in the zspage.
> > > >        */
> > > > -     if (!is_zspage_isolated(zspage))
> > > > +     if (!is_zspage_isolated(zspage)) {
> > > > +             /*
> > > > +              * We still hold the class lock while all of this is happening,
> > > > +              * so we cannot race with zs_destroy_pool()
> > > > +              */
> > > >               putback_zspage_deferred(pool, class, zspage);
> > > > +             zs_class_dec_isolated(pool, class);
> > > > +     }
> > > >
> > > >       reset_page(page);
> > > >       put_page(page);
> > > > @@ -2131,9 +2160,11 @@ static void zs_page_putback(struct page *page)
> > > >
> > > >       spin_lock(&class->lock);
> > > >       dec_zspage_isolation(zspage);
> > > > -     if (!is_zspage_isolated(zspage))
> > > > -             putback_zspage_deferred(pool, class, zspage);
> > > >
> > > > +     if (!is_zspage_isolated(zspage)) {
> > > > +             putback_zspage_deferred(pool, class, zspage);
> > > > +             zs_class_dec_isolated(pool, class);
> > > > +     }
> > > >       spin_unlock(&class->lock);
> > > >  }
> > > >
> > > > @@ -2156,8 +2187,36 @@ static int zs_register_migration(struct zs_pool *pool)
> > > >       return 0;
> > > >  }
> > > >
> > > > +static bool class_isolated_are_drained(struct size_class *class)
> > > > +{
> > > > +     bool ret;
> > > > +
> > > > +     spin_lock(&class->lock);
> > > > +     ret = class->isolated == 0;
> > > > +     spin_unlock(&class->lock);
> > > > +     return ret;
> > > > +}
> > > > +
> > > > +/* Function for resolving migration */
> > > > +static void wait_for_isolated_drain(struct zs_pool *pool)
> > > > +{
> > > > +     int i;
> > > > +
> > > > +     /*
> > > > +      * We're in the process of destroying the pool, so there are no
> > > > +      * active allocations. zs_page_isolate() fails for completely free
> > > > +      * zspages, so we need only wait for each size_class's isolated
> > > > +      * count to hit zero.
> > > > +      */
> > > > +     for (i = 0; i < ZS_SIZE_CLASSES; i++) {
> > > > +             wait_event(pool->migration_wait,
> > > > +                        class_isolated_are_drained(pool->size_class[i]));
> > > > +     }
> > > > +}
> > > > +
> > > >  static void zs_unregister_migration(struct zs_pool *pool)
> > > >  {
> > > > +     wait_for_isolated_drain(pool); /* This can block */
> > > >       flush_work(&pool->free_work);
> > > >       iput(pool->inode);
> > > >  }
> > > > @@ -2401,6 +2460,8 @@ struct zs_pool *zs_create_pool(const char *name)
> > > >       if (!pool->name)
> > > >               goto err;
> > > >
> > > > +     init_waitqueue_head(&pool->migration_wait);
> > > > +
> > > >       if (create_cache(pool))
> > > >               goto err;
> > > >
> > > > @@ -2466,6 +2527,7 @@ struct zs_pool *zs_create_pool(const char *name)
> > > >               class->index = i;
> > > >               class->pages_per_zspage = pages_per_zspage;
> > > >               class->objs_per_zspage = objs_per_zspage;
> > > > +             class->isolated = 0;
> > > >               spin_lock_init(&class->lock);
> > > >               pool->size_class[i] = class;
> > > >               for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
> > > > --
> > > > 2.22.0.770.g0f2c4a37fd-goog
> > > >

