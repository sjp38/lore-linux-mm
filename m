Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D6F9C41514
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:38:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92EC62147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:38:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LWHFsZXQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92EC62147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 427F86B0003; Mon,  5 Aug 2019 21:38:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D94C6B0005; Mon,  5 Aug 2019 21:38:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C8776B0006; Mon,  5 Aug 2019 21:38:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9F256B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:38:53 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w5so53883111pgs.5
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:38:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pl8UsF4L2ZgN2cVoUatHU9qNDymPWthAuYy0ZpUojvc=;
        b=NGuP30rlRh//Dsg84Hed+OrZn4kKsWVIhDZPKcj3Q0YUjUlS1/auyCVH9m8TA2cDPv
         feUc5mRcROC0ToURFREABQSm/+Gkk6mXwrVnqYtfI3I4S6lcRxUAA1MwxGtTHuMbfBQx
         v5ui0wBcFVjYxh9UTkNbvzhA3wEVy7Uxfe/PbzLO3/cnZfkdkLwRE9jyQPNWhJ2k4oRU
         wCCqbCS5CpMi1x2UpJ/HlO+t6r5O4ZGJ7bqks5WPlin0x6sQLn9D8duECjFmLp0M2vTv
         E/LNOMw3gzR36f9ByiRREt3XZmEPYX2eiGLuqU0VoNnZjU6dFCUZyjQ0GaH7mamocklA
         7ZBw==
X-Gm-Message-State: APjAAAUR9VUnj8Svk4SEvT3mvbyM19EQnTwAcjb1iChtSJ/aN2O//TnE
	dhyKtnol/erd4REoYgM4jEjzgZSc6Ws6Xmor4fkPr8/WRG+wvMNZ0vy3bHVF412d4bKefpAh5dn
	sI6B2f6KO5y/dbU5dZpA0Ek0RT0iUSmmSpYVwOqQhvBDPzuL/UK09ZG/YSRzUvCs=
X-Received: by 2002:a62:b408:: with SMTP id h8mr985515pfn.46.1565055533550;
        Mon, 05 Aug 2019 18:38:53 -0700 (PDT)
X-Received: by 2002:a62:b408:: with SMTP id h8mr985446pfn.46.1565055532596;
        Mon, 05 Aug 2019 18:38:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565055532; cv=none;
        d=google.com; s=arc-20160816;
        b=yt5u3qmTUq/JreD8/uNtn0KrEStdsjRZwrcYaIzeMAVOMgvZraZRwUJJ43/8bcIcTU
         9FfPB5wLM7QGrR4xEELF3S/Ix0xvHp2PUO3j9K1ceq1NxcVmXc4tMdkcvakn34UGFPDm
         KvZPPVUPdKzEBz/dJcr00pTEf2sVoaPTL8y5xQKk4nloXH5C6YlclqNo+A9I1raJZ1T9
         4QGzBAEKIWi/PVu8DbaCnO9uFofB42KrHiqu2M/TALUUEEmw6CY5eSevo5At2ZJzSKH3
         CiCtjmexFiTgB59ksrlBW4E8bwp+e+sITJbFB7+eGzbsBzxoqbZfxI/vSWJGqU2gMolj
         eJIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=pl8UsF4L2ZgN2cVoUatHU9qNDymPWthAuYy0ZpUojvc=;
        b=NFzfBv6d6BgjUbczNVHMv8RotzlVBakrzXDpGwIi3hIo6GxjJIAM1evH+pvpFKNujv
         IvU5dbsyUcdUPtTi2PIFmz/M52eOj4qke1vGeYY6whEM93Hhpq+c17CoVCIsVRf+Emns
         nljRKqnVKvVgpHT2PFvf3+IDZTavEgkHTFe1+8BbmXIbE7auT3fMTkmjn3MNTu7sXUMY
         Am8X8GZDWlyeXNErQc/RdNcgr8i8B+1f7GZZjnUWXpM9sSaJ8nMz/5qXtZ+BIx4w53Ab
         EoZNCP8glCjbC48O1sp44u4Aw4+yeDz8LXz5xZ6UIwRfwZqude6SRjl7gN86qRPgmPhp
         Ezdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LWHFsZXQ;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r27sor67294803pfg.42.2019.08.05.18.38.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 18:38:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LWHFsZXQ;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pl8UsF4L2ZgN2cVoUatHU9qNDymPWthAuYy0ZpUojvc=;
        b=LWHFsZXQeOtaAf0vU5ZLc/uArDplP5t2VWo/9efFUT1IM0+JY3EiW/byzmVHAkZxRd
         IAZBSUHc4bKMvF0PjTiQN6WDOgaa69V8P6AmKSOsNnmGu+gnDKQHbRrDLBNSiui/s49E
         aDXuIerm8fGsMSv7mOfIFaSVfvZAb+VXtfUBtCvOYAVwmzsKjGLnV0hkzr7Wi+eUHWXc
         9VuCF0PqMmZGa2T4HrHrkFj2TEcOMQ6/Iq1jkQmNtpQyYhBbHwyIB6A1xaoakgpxqdIu
         zgPPlIGpfrdUi/8CzM+k6XC7mMcJa7+6ZZO1LW5zvkpUQVjyFdkD/tj6tr5SJQbGqTzK
         JwOA==
X-Google-Smtp-Source: APXvYqzfJAxA1OnUEHw9LW/32P82SS68sMs2IhsEUGFClYXA8MiJ6dqBpGqNgm00eqeVW9d9O6FQvg==
X-Received: by 2002:aa7:8a97:: with SMTP id a23mr936671pfc.117.1565055531996;
        Mon, 05 Aug 2019 18:38:51 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f19sm125035106pfk.180.2019.08.05.18.38.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 18:38:50 -0700 (PDT)
Date: Tue, 6 Aug 2019 10:38:46 +0900
From: Minchan Kim <minchan@kernel.org>
To: Henry Burns <henryburns@google.com>
Cc: Nitin Gupta <ngupta@vflare.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] mm/zsmalloc.c: Fix race condition in zs_destroy_pool
Message-ID: <20190806013846.GA71899@google.com>
References: <20190802015332.229322-1-henryburns@google.com>
 <20190802015332.229322-2-henryburns@google.com>
 <20190805042821.GA102749@google.com>
 <CAGQXPTiHtNJsBz8dGCvejtmvGgPNHBoQHSmbX4XkxJ5DTmUWGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGQXPTiHtNJsBz8dGCvejtmvGgPNHBoQHSmbX4XkxJ5DTmUWGg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 10:34:41AM -0700, Henry Burns wrote:
> On Sun, Aug 4, 2019 at 9:28 PM Minchan Kim <minchan@kernel.org> wrote:
> >
> > Hi Henry,
> >
> > On Thu, Aug 01, 2019 at 06:53:32PM -0700, Henry Burns wrote:
> > > In zs_destroy_pool() we call flush_work(&pool->free_work). However, we
> > > have no guarantee that migration isn't happening in the background
> > > at that time.
> > >
> > > Since migration can't directly free pages, it relies on free_work
> > > being scheduled to free the pages.  But there's nothing preventing an
> > > in-progress migrate from queuing the work *after*
> > > zs_unregister_migration() has called flush_work().  Which would mean
> > > pages still pointing at the inode when we free it.
> >
> > We already unregister shrinker so there is no upcoming async free call
> > via shrinker so the only concern is zs_compact API direct call from
> > the user. Is that what what you desribe from the description?
> 
> What I am describing is a call to zsmalloc_aops->migratepage() by
> kcompactd (which can call schedule work in either
> zs_page_migrate() or zs_page_putback should the zspage become empty).
> 
> While we are migrating a page, we remove it from the class. Suppose
> zs_free() loses a race with migration. We would schedule
> async_free_zspage() to handle freeing that zspage, however we have no
> guarantee that migration has finished
> by the time we finish flush_work(&pool->work). In that case we then
> call iput(inode), and now we have a page
> pointing to a non-existent inode. (At which point something like
> kcompactd would potentially BUG() if it tries to get a page
> (from the inode) that doesn't exist anymore)
> 

True.
I totally got mixed up internal migration and external migration. :-/

> 
> >
> > If so, can't we add a flag to indicate destroy of the pool and
> > global counter to indicate how many of zs_compact was nested?
> >
> > So, zs_unregister_migration in zs_destroy_pool can set the flag to
> > prevent upcoming zs_compact call and wait until the global counter
> > will be zero. Once it's done, finally flush the work.
> >
> > My point is it's not a per-class granuarity but global.
> 
> We could have a pool level counter of isolated pages, and wait for
> that to finish before starting flush_work(&pool->work); However,
> that would require an atomic_long in zs_pool, and we would have to eat
> the cost of any contention over that lock. Still, it might be
> preferable to a per-class granularity.

That would be better for performance-wise but how it's significant?
Migration is not already hot path so adding a atomic variable in that path
wouldn't make noticible slow.

Rather than performance, my worry is maintainance so prefer simple and
not fragile.

> 
> >
> > Thanks.
> >
> > >
> > > Since we know at destroy time all objects should be free, no new
> > > migrations can come in (since zs_page_isolate() fails for fully-free
> > > zspages).  This means it is sufficient to track a "# isolated zspages"
> > > count by class, and have the destroy logic ensure all such pages have
> > > drained before proceeding.  Keeping that state under the class
> > > spinlock keeps the logic straightforward.
> > >
> > > Signed-off-by: Henry Burns <henryburns@google.com>
> > > ---
> > >  mm/zsmalloc.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++---
> > >  1 file changed, 65 insertions(+), 3 deletions(-)
> > >
> > > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > > index efa660a87787..1f16ed4d6a13 100644
> > > --- a/mm/zsmalloc.c
> > > +++ b/mm/zsmalloc.c
> > > @@ -53,6 +53,7 @@
> > >  #include <linux/zpool.h>
> > >  #include <linux/mount.h>
> > >  #include <linux/migrate.h>
> > > +#include <linux/wait.h>
> > >  #include <linux/pagemap.h>
> > >  #include <linux/fs.h>
> > >
> > > @@ -206,6 +207,10 @@ struct size_class {
> > >       int objs_per_zspage;
> > >       /* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> > >       int pages_per_zspage;
> > > +#ifdef CONFIG_COMPACTION
> > > +     /* Number of zspages currently isolated by compaction */
> > > +     int isolated;
> > > +#endif
> > >
> > >       unsigned int index;
> > >       struct zs_size_stat stats;
> > > @@ -267,6 +272,8 @@ struct zs_pool {
> > >  #ifdef CONFIG_COMPACTION
> > >       struct inode *inode;
> > >       struct work_struct free_work;
> > > +     /* A workqueue for when migration races with async_free_zspage() */
> > > +     struct wait_queue_head migration_wait;
> > >  #endif
> > >  };
> > >
> > > @@ -1917,6 +1924,21 @@ static void putback_zspage_deferred(struct zs_pool *pool,
> > >
> > >  }
> > >
> > > +static inline void zs_class_dec_isolated(struct zs_pool *pool,
> > > +                                      struct size_class *class)
> > > +{
> > > +     assert_spin_locked(&class->lock);
> > > +     VM_BUG_ON(class->isolated <= 0);
> > > +     class->isolated--;
> > > +     /*
> > > +      * There's no possibility of racing, since wait_for_isolated_drain()
> > > +      * checks the isolated count under &class->lock after enqueuing
> > > +      * on migration_wait.
> > > +      */
> > > +     if (class->isolated == 0 && waitqueue_active(&pool->migration_wait))
> > > +             wake_up_all(&pool->migration_wait);
> > > +}
> > > +
> > >  static void replace_sub_page(struct size_class *class, struct zspage *zspage,
> > >                               struct page *newpage, struct page *oldpage)
> > >  {
> > > @@ -1986,6 +2008,7 @@ static bool zs_page_isolate(struct page *page, isolate_mode_t mode)
> > >        */
> > >       if (!list_empty(&zspage->list) && !is_zspage_isolated(zspage)) {
> > >               get_zspage_mapping(zspage, &class_idx, &fullness);
> > > +             class->isolated++;
> > >               remove_zspage(class, zspage, fullness);
> > >       }
> > >
> > > @@ -2085,8 +2108,14 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> > >        * Page migration is done so let's putback isolated zspage to
> > >        * the list if @page is final isolated subpage in the zspage.
> > >        */
> > > -     if (!is_zspage_isolated(zspage))
> > > +     if (!is_zspage_isolated(zspage)) {
> > > +             /*
> > > +              * We still hold the class lock while all of this is happening,
> > > +              * so we cannot race with zs_destroy_pool()
> > > +              */
> > >               putback_zspage_deferred(pool, class, zspage);
> > > +             zs_class_dec_isolated(pool, class);
> > > +     }
> > >
> > >       reset_page(page);
> > >       put_page(page);
> > > @@ -2131,9 +2160,11 @@ static void zs_page_putback(struct page *page)
> > >
> > >       spin_lock(&class->lock);
> > >       dec_zspage_isolation(zspage);
> > > -     if (!is_zspage_isolated(zspage))
> > > -             putback_zspage_deferred(pool, class, zspage);
> > >
> > > +     if (!is_zspage_isolated(zspage)) {
> > > +             putback_zspage_deferred(pool, class, zspage);
> > > +             zs_class_dec_isolated(pool, class);
> > > +     }
> > >       spin_unlock(&class->lock);
> > >  }
> > >
> > > @@ -2156,8 +2187,36 @@ static int zs_register_migration(struct zs_pool *pool)
> > >       return 0;
> > >  }
> > >
> > > +static bool class_isolated_are_drained(struct size_class *class)
> > > +{
> > > +     bool ret;
> > > +
> > > +     spin_lock(&class->lock);
> > > +     ret = class->isolated == 0;
> > > +     spin_unlock(&class->lock);
> > > +     return ret;
> > > +}
> > > +
> > > +/* Function for resolving migration */
> > > +static void wait_for_isolated_drain(struct zs_pool *pool)
> > > +{
> > > +     int i;
> > > +
> > > +     /*
> > > +      * We're in the process of destroying the pool, so there are no
> > > +      * active allocations. zs_page_isolate() fails for completely free
> > > +      * zspages, so we need only wait for each size_class's isolated
> > > +      * count to hit zero.
> > > +      */
> > > +     for (i = 0; i < ZS_SIZE_CLASSES; i++) {
> > > +             wait_event(pool->migration_wait,
> > > +                        class_isolated_are_drained(pool->size_class[i]));
> > > +     }
> > > +}
> > > +
> > >  static void zs_unregister_migration(struct zs_pool *pool)
> > >  {
> > > +     wait_for_isolated_drain(pool); /* This can block */
> > >       flush_work(&pool->free_work);
> > >       iput(pool->inode);
> > >  }
> > > @@ -2401,6 +2460,8 @@ struct zs_pool *zs_create_pool(const char *name)
> > >       if (!pool->name)
> > >               goto err;
> > >
> > > +     init_waitqueue_head(&pool->migration_wait);
> > > +
> > >       if (create_cache(pool))
> > >               goto err;
> > >
> > > @@ -2466,6 +2527,7 @@ struct zs_pool *zs_create_pool(const char *name)
> > >               class->index = i;
> > >               class->pages_per_zspage = pages_per_zspage;
> > >               class->objs_per_zspage = objs_per_zspage;
> > > +             class->isolated = 0;
> > >               spin_lock_init(&class->lock);
> > >               pool->size_class[i] = class;
> > >               for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
> > > --
> > > 2.22.0.770.g0f2c4a37fd-goog
> > >

