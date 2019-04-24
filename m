Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36C51C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:41:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD7FA2175B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:41:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HSQGlCAB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD7FA2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DA276B0005; Wed, 24 Apr 2019 15:41:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68A676B0006; Wed, 24 Apr 2019 15:41:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 578A06B0007; Wed, 24 Apr 2019 15:41:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33E486B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:41:12 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id g128so4098090ywf.11
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:41:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Yniv5sy+5BQNRUjtlaSRpscFDyrU4/SisoLwlgAM2ng=;
        b=FeTN3RUtVnKXRn5Ucjj2941SS5oz5QbhOrr1LqLGn3tG4oif0eiBGA8Y75Lgf6V5nq
         8457iWwuk6M7uNfULhdHfMDx7ngYoQNKQqHjZsa2aWx/tH20+fXNrHClw9OgXsNSn3Nk
         qbq2BlzAbFae1RQ3pcXLJHpX8L1UGkI6/DEtGaQmco+/OsrhIep72dA/C6b+sth1AgA5
         7V9JPgvndUpFLr5Tt0iHcQwDrU0G2YlYmxNT+cHMoj/d/QmpX5F9eYsESIDSivJxi8qc
         FGYiFDEkWWGm9q7mAKTOeaHlkcByxe40MdsaltmruMGyTuFEMy0fIpGR16YT1ATkTknm
         adfA==
X-Gm-Message-State: APjAAAU4Kc6hs4/G0pufJKYNpsn5UpP2sTMSk/eu78WrMpE9ogUz+bQT
	Wpadu4A2byrZ2+Pb6z/QLU1t4JMlNhHqHFWQXhFpctV2VKyRaSswuKu01gSszLrGFx5uP4JYLOA
	12TsrH84kXYsoD3su+6g+KPwjCOUKOv4J2miEPIEUt8iMq+oikzrSW5mxrtmtRZKcCg==
X-Received: by 2002:a25:e89:: with SMTP id 131mr24946383ybo.416.1556134871824;
        Wed, 24 Apr 2019 12:41:11 -0700 (PDT)
X-Received: by 2002:a25:e89:: with SMTP id 131mr24946313ybo.416.1556134870768;
        Wed, 24 Apr 2019 12:41:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556134870; cv=none;
        d=google.com; s=arc-20160816;
        b=OUcMzvPPyEhvl9LF45CWTFiceW3O5mhk1LlOKnLKfpwvHRoZEjpkfU+o6ZZxGFpT1b
         aKixaOthmiJQKVIt8pTBam+kJ8Vr8XvImmtufwBD+5Tin/3LjoH07/BBKhvX0SgcJ3p+
         64u1rrIJdjAumlcplTRisQ7Z6VRYuPovY0syS44Ex4yC6rnNSTHFIUahGdM1+uQTiQjG
         zHdBwDx6Zk3XpTpUGphPlhezATVqtgjLdCmsf7djdA1Gw+V4l6nXmQlejaVulJ18c4BZ
         QchhycY+m9DoA0QZNp8fYiaTA7mcAsS9E3+UAPZ5Bd1mHogKnLGbdny0Hio0qxUlcl2/
         Ww8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Yniv5sy+5BQNRUjtlaSRpscFDyrU4/SisoLwlgAM2ng=;
        b=f/HnHQdCwKMTT9kZ0Gou6XqJ1pjtbrwFUMlsOU8FHKkXyMw5SpeoIPIfG7tDsHgOB/
         5J2qmL/AZ3WEChvONTctG2Jc44l9F5SGWjeC/FvaDTJ9YfW7m8yvvewyyW7GJY97AHFA
         zNXjYeJ/oEjmRyiq3ob1qYMZr1X8dVQkRJGDO2UU/JqBIFYxvYvAQITpo7COj+Glx2pv
         1nKAr9AaYVTJbS4IyfOkkN/SQbTDAWB8INWZ5fJ2nlysXLNcRVTPXz7jMtfKbmmJhtBC
         FJlhe+uU1zunuTKKK8FvNNXlvvsUDNyiguk/g3xYkmYtehW6EU85lZLEknJe88zfetl4
         un7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HSQGlCAB;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 21sor8789406ywg.189.2019.04.24.12.41.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 12:41:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HSQGlCAB;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Yniv5sy+5BQNRUjtlaSRpscFDyrU4/SisoLwlgAM2ng=;
        b=HSQGlCABvRIZPxZA8AOq9czRV7ZfXLMVbzQJ3+KvICA6fAiq4fTXLdIW4I9pcAK5Ar
         J+DJ/nbaXuY3mcsBwclwSQbl8CvBRvPVpIS3X80Q33eYOZKD7jYDyFucYjA3EpdqGupt
         K2FB85/z9856MjrPeLO6FF0Jm97fu+CWhTWj1Vdn3CGKACt4d1cJFkbwKCIGLs/yOjCd
         MngXQA1Gc0EtXw+FzBHSUypHSaaqwPOeSCyBaCn8Hus3JFZtQSJIdPAtrU1hGAOOuF+/
         g1VzjfOuDMEfuueQgSzVFMoHMKMeE5PDBn3VG6Wr6EjzwrAJY4zJq+5zS72iouyIgmNg
         XZwQ==
X-Google-Smtp-Source: APXvYqxv1u3H9ygt4AZH9qpNsjBSq/NfXcClQxIBs/Dob2wUtNxoudJC/96BrFm+ew0Zx5DOFe/D9zIl/Nygshyc5hM=
X-Received: by 2002:a0d:f804:: with SMTP id i4mr28081368ywf.345.1556134869972;
 Wed, 24 Apr 2019 12:41:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190423213133.3551969-1-guro@fb.com> <20190423213133.3551969-5-guro@fb.com>
 <CALvZod6A43nQgkYj38K4h_ZYLSmYp0xJwO7n44kGJx2Ut7-EVg@mail.gmail.com> <20190424191706.GA26707@tower.DHCP.thefacebook.com>
In-Reply-To: <20190424191706.GA26707@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 24 Apr 2019 12:40:59 -0700
Message-ID: <CALvZod7sG+sD76dQmMhXa92=zpXz=wdUcsR9ah7YRj13g=YT+g@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] mm: unify SLAB and SLUB page accounting
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 12:17 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Wed, Apr 24, 2019 at 10:23:45AM -0700, Shakeel Butt wrote:
> > Hi Roman,
> >
> > On Tue, Apr 23, 2019 at 9:30 PM Roman Gushchin <guro@fb.com> wrote:
> > >
> > > Currently the page accounting code is duplicated in SLAB and SLUB
> > > internals. Let's move it into new (un)charge_slab_page helpers
> > > in the slab_common.c file. These helpers will be responsible
> > > for statistics (global and memcg-aware) and memcg charging.
> > > So they are replacing direct memcg_(un)charge_slab() calls.
> > >
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > ---
> > >  mm/slab.c | 19 +++----------------
> > >  mm/slab.h | 22 ++++++++++++++++++++++
> > >  mm/slub.c | 14 ++------------
> > >  3 files changed, 27 insertions(+), 28 deletions(-)
> > >
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > index 14466a73d057..53e6b2687102 100644
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -1389,7 +1389,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
> > >                                                                 int nodeid)
> > >  {
> > >         struct page *page;
> > > -       int nr_pages;
> > >
> > >         flags |= cachep->allocflags;
> > >
> > > @@ -1399,17 +1398,11 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
> > >                 return NULL;
> > >         }
> > >
> > > -       if (memcg_charge_slab(page, flags, cachep->gfporder, cachep)) {
> > > +       if (charge_slab_page(page, flags, cachep->gfporder, cachep)) {
> > >                 __free_pages(page, cachep->gfporder);
> > >                 return NULL;
> > >         }
> > >
> > > -       nr_pages = (1 << cachep->gfporder);
> > > -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> > > -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr_pages);
> > > -       else
> > > -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, nr_pages);
> > > -
> > >         __SetPageSlab(page);
> > >         /* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
> > >         if (sk_memalloc_socks() && page_is_pfmemalloc(page))
> > > @@ -1424,12 +1417,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
> > >  static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
> > >  {
> > >         int order = cachep->gfporder;
> > > -       unsigned long nr_freed = (1 << order);
> > > -
> > > -       if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> > > -               mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, -nr_freed);
> > > -       else
> > > -               mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, -nr_freed);
> > >
> > >         BUG_ON(!PageSlab(page));
> > >         __ClearPageSlabPfmemalloc(page);
> > > @@ -1438,8 +1425,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
> > >         page->mapping = NULL;
> > >
> > >         if (current->reclaim_state)
> > > -               current->reclaim_state->reclaimed_slab += nr_freed;
> > > -       memcg_uncharge_slab(page, order, cachep);
> > > +               current->reclaim_state->reclaimed_slab += 1 << order;
> > > +       uncharge_slab_page(page, order, cachep);
> > >         __free_pages(page, order);
> > >  }
> > >
> > > diff --git a/mm/slab.h b/mm/slab.h
> > > index 4a261c97c138..0f5c5444acf1 100644
> > > --- a/mm/slab.h
> > > +++ b/mm/slab.h
> > > @@ -205,6 +205,12 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
> > >  void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
> > >  int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
> > >
> > > +static inline int cache_vmstat_idx(struct kmem_cache *s)
> > > +{
> > > +       return (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> > > +               NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> > > +}
> > > +
> > >  #ifdef CONFIG_MEMCG_KMEM
> > >
> > >  /* List of all root caches. */
> > > @@ -352,6 +358,22 @@ static inline void memcg_link_cache(struct kmem_cache *s,
> > >
> > >  #endif /* CONFIG_MEMCG_KMEM */
> > >
> > > +static __always_inline int charge_slab_page(struct page *page,
> > > +                                           gfp_t gfp, int order,
> > > +                                           struct kmem_cache *s)
> > > +{
> > > +       memcg_charge_slab(page, gfp, order, s);
> >
> > This does not seem right. Why the return of memcg_charge_slab is ignored?
>
> Hi Shakeel!
>
> Right, it's a bug. It's actually fixed later in the patchset
> (in "mm: rework non-root kmem_cache lifecycle management"),
> so the final result looks correct to me. Anyway, I'll fix it.
>
> How does everything else look to you?
>
> Thank you!

I caught this during quick glance. Another high level issue I found is
breakage of /proc/kpagecgroup for the slab pages which is easy to fix.

At the moment I am kind of stuck on some other stuff but will get back
to this in a week or so.

Shakeel

