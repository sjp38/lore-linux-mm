Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECD77C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97074214C6
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:35:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MXsZIH74"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97074214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FDA06B0005; Mon,  5 Aug 2019 13:35:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AE666B0006; Mon,  5 Aug 2019 13:35:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB7B46B0007; Mon,  5 Aug 2019 13:35:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB8256B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:35:19 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id q26so92866703ioi.10
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:35:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2ylHX28kDsFtD8dDqhQ9lJwkyPUh7ky+fY53QW66arU=;
        b=Y0Bnl4D1D52rL85G9q6dAcsBWTE8ygew7UfVmI2pxSwI42SzlWotXRxNPAjSoWRBiR
         i+oJO2yVBHMT68qCUSynSX1gzQF3AwDH7ofktVN5FajjKIs5H1rnl7ix3WaYBWORvvT0
         QfQNy+3x/hfNgufnQt87ICNEcBdB2yuGuHhUz1kQ7M9TyqMP2uBSxsoPovaHkYhkk2jp
         esMdsCa3gzm8jtc47KgIHMSMYdedV551gDpzVL2F63h+X3kVPE+OAg8bczx+PMbnWYk6
         VeXZ/cB/XOCefwuiqWYCrdyq5j5R42NkiyMJBXKYJBLcFH8jFV4Z9sIDtpVgHzrEpeX8
         8iJw==
X-Gm-Message-State: APjAAAWWGizP4eFTlrQPOIjEEPMGHiFeucHaGZQ3qTfrsYF2jpXASkUj
	oSul6nkKy61dE/CXbcXTeEMRIJAvhrVpSG5R1r5lR1rQA1iyqazdfTMUU4lkDVoZB4LsuHBCFBC
	YWI6x4lKMgUKbkgJTL8i7dFQHOXyyZS45VgNdWpY/xug0WFUt71EIQNwG86d4w9Ywrw==
X-Received: by 2002:a5e:a712:: with SMTP id b18mr34865241iod.220.1565026519584;
        Mon, 05 Aug 2019 10:35:19 -0700 (PDT)
X-Received: by 2002:a5e:a712:: with SMTP id b18mr34865168iod.220.1565026518559;
        Mon, 05 Aug 2019 10:35:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565026518; cv=none;
        d=google.com; s=arc-20160816;
        b=pcFN56cu26E/8z9jx+bMKZnq0z2powYP4w0rneFJR9X394e0yZ7NOSa1IIHNCUBY6S
         SkPw1d4IkhJFephNOB5FR0ZtHEvI/AolihiELr23hs3TeCuX7+63qRcR+S+SXuGpkGEL
         g9jm/ca0WpSSSmqEmLT3I6KjuSExH04f+bZgDdxuszdme/FLNVHxk53d92azbY/Avup8
         jbXlPRySvHnne4rPbxXbCNg2mqlK2sPJcNLkA8OzjL5A9po1wga5mozDJpbn4ddKRCjH
         NxD3HggX/mnyBwBNrpyWv2dYgTZVzvtbY8irAbTfjkyZ092K5Jsc2KxL6VGSg1pBOvGd
         4Ykw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2ylHX28kDsFtD8dDqhQ9lJwkyPUh7ky+fY53QW66arU=;
        b=Mqcv+TTj09s+tzbUGIK+Vr9VdRIDzqqWHNxiraQwvHEFQSoaqemzreVbbAjDcQxh5S
         DGxGjLQ43xjSZRVQw7Ymp2TxqxIJRjxJ0YZEsssYTYP4cgiMpxF4T6IKVy88wb1FYYKd
         Vcj9TZopCdWg88UvV1Nk1lnEwgIUVW9QQ5sjANiQyaif4yVLfV0oftpHH3cUGw1B+2be
         iVkdT4AS1VYpw79wVZCY/C2QR15JtN2Izx9GVu47PSRns1TNwXe1b9cn5MlW3pADXFHg
         kWEkUMsbTt2/b9Q4HnlS/DP6vC10p9BQk1h94wL3ZYZ24OUD+ebLQMLXaAZpu8Jt1W1t
         jtBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MXsZIH74;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor47068642jai.10.2019.08.05.10.35.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 10:35:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MXsZIH74;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2ylHX28kDsFtD8dDqhQ9lJwkyPUh7ky+fY53QW66arU=;
        b=MXsZIH74B5Q/cl0qsNmmILDSFXHEL+ovfUHp+Zy75//dZbmMyTsCe0DjPgaXWYq59x
         49iGpFNh+p3YD4OvRJbH8S+uP0L/eBXnBh9AKLLiRIB2aZybCNoL85Hnl9SJe67kefLs
         adRR8GbBoQ8iIWJyTzuBpNdRbYj4aOg5DH2saIQX+BP0zTwlPZM8cARb1aCDQMMbzOfX
         qFWPgXhK9b/oqh/98WdDK3l5cEogzCDB81YAB4tZyD7n4AK+x0RBC6TnVjIWt+PO61/g
         CVpRh24fkfiM3vT4LHYtqWx2idgqVqBc4hKDUUCr0qEIgM7dS2090n8CcTxm3K2fnsyn
         LwAA==
X-Google-Smtp-Source: APXvYqxiDS7i6zrRpAvp6PN+3FDeC6l+K7xng+7XfVuSoKGBXYDZTwXnxbR0h+nfB5dfKiTVZzbg6OCWEKD+cFlaX5k=
X-Received: by 2002:a02:8663:: with SMTP id e90mr153691969jai.98.1565026518071;
 Mon, 05 Aug 2019 10:35:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190802015332.229322-1-henryburns@google.com>
 <20190802015332.229322-2-henryburns@google.com> <20190805042821.GA102749@google.com>
In-Reply-To: <20190805042821.GA102749@google.com>
From: Henry Burns <henryburns@google.com>
Date: Mon, 5 Aug 2019 10:34:41 -0700
Message-ID: <CAGQXPTiHtNJsBz8dGCvejtmvGgPNHBoQHSmbX4XkxJ5DTmUWGg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/zsmalloc.c: Fix race condition in zs_destroy_pool
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, 
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 4, 2019 at 9:28 PM Minchan Kim <minchan@kernel.org> wrote:
>
> Hi Henry,
>
> On Thu, Aug 01, 2019 at 06:53:32PM -0700, Henry Burns wrote:
> > In zs_destroy_pool() we call flush_work(&pool->free_work). However, we
> > have no guarantee that migration isn't happening in the background
> > at that time.
> >
> > Since migration can't directly free pages, it relies on free_work
> > being scheduled to free the pages.  But there's nothing preventing an
> > in-progress migrate from queuing the work *after*
> > zs_unregister_migration() has called flush_work().  Which would mean
> > pages still pointing at the inode when we free it.
>
> We already unregister shrinker so there is no upcoming async free call
> via shrinker so the only concern is zs_compact API direct call from
> the user. Is that what what you desribe from the description?

What I am describing is a call to zsmalloc_aops->migratepage() by
kcompactd (which can call schedule work in either
zs_page_migrate() or zs_page_putback should the zspage become empty).

While we are migrating a page, we remove it from the class. Suppose
zs_free() loses a race with migration. We would schedule
async_free_zspage() to handle freeing that zspage, however we have no
guarantee that migration has finished
by the time we finish flush_work(&pool->work). In that case we then
call iput(inode), and now we have a page
pointing to a non-existent inode. (At which point something like
kcompactd would potentially BUG() if it tries to get a page
(from the inode) that doesn't exist anymore)


>
> If so, can't we add a flag to indicate destroy of the pool and
> global counter to indicate how many of zs_compact was nested?
>
> So, zs_unregister_migration in zs_destroy_pool can set the flag to
> prevent upcoming zs_compact call and wait until the global counter
> will be zero. Once it's done, finally flush the work.
>
> My point is it's not a per-class granuarity but global.

We could have a pool level counter of isolated pages, and wait for
that to finish before starting flush_work(&pool->work); However,
that would require an atomic_long in zs_pool, and we would have to eat
the cost of any contention over that lock. Still, it might be
preferable to a per-class granularity.

>
> Thanks.
>
> >
> > Since we know at destroy time all objects should be free, no new
> > migrations can come in (since zs_page_isolate() fails for fully-free
> > zspages).  This means it is sufficient to track a "# isolated zspages"
> > count by class, and have the destroy logic ensure all such pages have
> > drained before proceeding.  Keeping that state under the class
> > spinlock keeps the logic straightforward.
> >
> > Signed-off-by: Henry Burns <henryburns@google.com>
> > ---
> >  mm/zsmalloc.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++---
> >  1 file changed, 65 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index efa660a87787..1f16ed4d6a13 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -53,6 +53,7 @@
> >  #include <linux/zpool.h>
> >  #include <linux/mount.h>
> >  #include <linux/migrate.h>
> > +#include <linux/wait.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/fs.h>
> >
> > @@ -206,6 +207,10 @@ struct size_class {
> >       int objs_per_zspage;
> >       /* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> >       int pages_per_zspage;
> > +#ifdef CONFIG_COMPACTION
> > +     /* Number of zspages currently isolated by compaction */
> > +     int isolated;
> > +#endif
> >
> >       unsigned int index;
> >       struct zs_size_stat stats;
> > @@ -267,6 +272,8 @@ struct zs_pool {
> >  #ifdef CONFIG_COMPACTION
> >       struct inode *inode;
> >       struct work_struct free_work;
> > +     /* A workqueue for when migration races with async_free_zspage() */
> > +     struct wait_queue_head migration_wait;
> >  #endif
> >  };
> >
> > @@ -1917,6 +1924,21 @@ static void putback_zspage_deferred(struct zs_pool *pool,
> >
> >  }
> >
> > +static inline void zs_class_dec_isolated(struct zs_pool *pool,
> > +                                      struct size_class *class)
> > +{
> > +     assert_spin_locked(&class->lock);
> > +     VM_BUG_ON(class->isolated <= 0);
> > +     class->isolated--;
> > +     /*
> > +      * There's no possibility of racing, since wait_for_isolated_drain()
> > +      * checks the isolated count under &class->lock after enqueuing
> > +      * on migration_wait.
> > +      */
> > +     if (class->isolated == 0 && waitqueue_active(&pool->migration_wait))
> > +             wake_up_all(&pool->migration_wait);
> > +}
> > +
> >  static void replace_sub_page(struct size_class *class, struct zspage *zspage,
> >                               struct page *newpage, struct page *oldpage)
> >  {
> > @@ -1986,6 +2008,7 @@ static bool zs_page_isolate(struct page *page, isolate_mode_t mode)
> >        */
> >       if (!list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
> >               get_zspage_mapping(zspage, &class_idx, &fullness);
> > +             class->isolated++;
> >               remove_zspage(class, zspage, fullness);
> >       }
> >
> > @@ -2085,8 +2108,14 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> >        * Page migration is done so let's putback isolated zspage to
> >        * the list if @page is final isolated subpage in the zspage.
> >        */
> > -     if (!is_zspage_isolated(zspage))
> > +     if (!is_zspage_isolated(zspage)) {
> > +             /*
> > +              * We still hold the class lock while all of this is happening,
> > +              * so we cannot race with zs_destroy_pool()
> > +              */
> >               putback_zspage_deferred(pool, class, zspage);
> > +             zs_class_dec_isolated(pool, class);
> > +     }
> >
> >       reset_page(page);
> >       put_page(page);
> > @@ -2131,9 +2160,11 @@ static void zs_page_putback(struct page *page)
> >
> >       spin_lock(&class->lock);
> >       dec_zspage_isolation(zspage);
> > -     if (!is_zspage_isolated(zspage))
> > -             putback_zspage_deferred(pool, class, zspage);
> >
> > +     if (!is_zspage_isolated(zspage)) {
> > +             putback_zspage_deferred(pool, class, zspage);
> > +             zs_class_dec_isolated(pool, class);
> > +     }
> >       spin_unlock(&class->lock);
> >  }
> >
> > @@ -2156,8 +2187,36 @@ static int zs_register_migration(struct zs_pool *pool)
> >       return 0;
> >  }
> >
> > +static bool class_isolated_are_drained(struct size_class *class)
> > +{
> > +     bool ret;
> > +
> > +     spin_lock(&class->lock);
> > +     ret = class->isolated == 0;
> > +     spin_unlock(&class->lock);
> > +     return ret;
> > +}
> > +
> > +/* Function for resolving migration */
> > +static void wait_for_isolated_drain(struct zs_pool *pool)
> > +{
> > +     int i;
> > +
> > +     /*
> > +      * We're in the process of destroying the pool, so there are no
> > +      * active allocations. zs_page_isolate() fails for completely free
> > +      * zspages, so we need only wait for each size_class's isolated
> > +      * count to hit zero.
> > +      */
> > +     for (i = 0; i < ZS_SIZE_CLASSES; i++) {
> > +             wait_event(pool->migration_wait,
> > +                        class_isolated_are_drained(pool->size_class[i]));
> > +     }
> > +}
> > +
> >  static void zs_unregister_migration(struct zs_pool *pool)
> >  {
> > +     wait_for_isolated_drain(pool); /* This can block */
> >       flush_work(&pool->free_work);
> >       iput(pool->inode);
> >  }
> > @@ -2401,6 +2460,8 @@ struct zs_pool *zs_create_pool(const char *name)
> >       if (!pool->name)
> >               goto err;
> >
> > +     init_waitqueue_head(&pool->migration_wait);
> > +
> >       if (create_cache(pool))
> >               goto err;
> >
> > @@ -2466,6 +2527,7 @@ struct zs_pool *zs_create_pool(const char *name)
> >               class->index = i;
> >               class->pages_per_zspage = pages_per_zspage;
> >               class->objs_per_zspage = objs_per_zspage;
> > +             class->isolated = 0;
> >               spin_lock_init(&class->lock);
> >               pool->size_class[i] = class;
> >               for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
> > --
> > 2.22.0.770.g0f2c4a37fd-goog
> >

