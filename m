Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D94A5C5B578
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 01:17:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90CBD20881
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 01:17:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="E+IhI3EF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90CBD20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 256826B0003; Mon,  1 Jul 2019 21:17:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 207E98E0003; Mon,  1 Jul 2019 21:17:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CEB78E0002; Mon,  1 Jul 2019 21:17:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f78.google.com (mail-io1-f78.google.com [209.85.166.78])
	by kanga.kvack.org (Postfix) with ESMTP id E0BCA6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 21:17:07 -0400 (EDT)
Received: by mail-io1-f78.google.com with SMTP id u25so16899250iol.23
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 18:17:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bGcgCNZM2Fneaix4f2ZBOZNpZLRiuOjV16Tk5yHyGgI=;
        b=E4akBRZo+tJYc6WO6VPZERtc8xcp38b+iZ0EcaUVHYVCv9n2XJCiUf1u4Igi3lGflx
         7uMzVZ4Gx7V3+KZjel8wCC7tREHw/oQlK0NB7NTl+y1xbJIPsGUjBPenhX7X2fk5uLr/
         SYaYV/wJyJQhUGaeUjKwTRMrj7WNBgnSIIqk9t7/+G8DNPcTddcAShm7GxNxpNhQHBC3
         NhQ9CVgaD14If3M9WkOKmwYbYEA9mANo/mG1mXpQTuqYJzhAvH+eJKKoU5kN0HYuCyMN
         +QGzYv0VlhD8eyrDtOIIX5C0MLysAnnrSe5xirCHj7R+9tk6tdpP5KXsrYjird2eP1Ki
         64pA==
X-Gm-Message-State: APjAAAUr7KtIdrXfmEHek+MyvYJaypm3SvWmnokEN/VwvNpzjVGHzWl1
	5gjYiHnhejXwGbK1MjMBY/+UXmX/sNmXDT0Poq3nuyc05W39Tq8xUaEQ0E3G2MKWXC1IBgFg+OR
	u725puDIeend+wwoIXHvY2uyRw+XynTLwlfQJZ+xJI8+PZxx5Ubzr5mI+OEqRcm10vQ==
X-Received: by 2002:a6b:e608:: with SMTP id g8mr2014575ioh.88.1562030227629;
        Mon, 01 Jul 2019 18:17:07 -0700 (PDT)
X-Received: by 2002:a6b:e608:: with SMTP id g8mr2014542ioh.88.1562030227009;
        Mon, 01 Jul 2019 18:17:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562030227; cv=none;
        d=google.com; s=arc-20160816;
        b=Wwd29o/qug5Q049y29hq8/e7n5cL1Rxud3acga679BAS52BIuG0O1vIKpeFfM/IMcz
         SL77N6ZpGTaop1h8vVaDOnf8U7Af7J7EgIT3iofF+jOkgfCVCVWcXOcLAldbgzj8cXzu
         1aJRTPW78mNMd6iSr3WFJoVUHw5dQgKRa/LL+fAG2hKR6fBxfBzQ0iB5hNBD7ABeYP/w
         xWebwfs+F7iVZH63hU8B6cW6ApnAa6cMWSEu8ecG2bU2X2GFR9q7U/UBAPhxLrijiCHM
         VzKA72IoShtMdXy//x2iNa5Pa48GWQRwOrt0T2pYF80g/szpH0FCkFDNgvTg+Zl5aDUp
         kKgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bGcgCNZM2Fneaix4f2ZBOZNpZLRiuOjV16Tk5yHyGgI=;
        b=V+6tb1GmJgydlVlcEhlkBHRbM6zbZtZxeCaYuNLfHIeGbughFp+3Pzxr/Qxv764IhF
         ozpseQxUYVOx+Ua8TAwW7DxXJ3SqsR7PLx7QEcnPKdMa9CvjStWFL1JtkY44v92ycKG+
         vay+/5o0JKV1orjx/e9rW8njnadgGiUMxSiTAgQjN/Hsza1dsqZNMGF9kmbJ0KT8Ojxk
         OsnP491xnUILhnhibbShtKmunPC0KU/KMWgEJlbWMD3TW0wicJsoC9/Psjbs2d6Cx33u
         U1N0fttrlDcuikni8kMjvFi/JA051MYeOIWyoI4Xd9YDHuHdnpjOWMdQxOusUTxwDsgw
         SnYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=E+IhI3EF;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c128sor30940818jac.2.2019.07.01.18.17.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 18:17:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=E+IhI3EF;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bGcgCNZM2Fneaix4f2ZBOZNpZLRiuOjV16Tk5yHyGgI=;
        b=E+IhI3EFrprAxwYz5XL+dCV+y22CzQKMuhlzlsky6+02t5cScdlAo3mb1JWWpTE8JK
         qOiH8sX9JUtanurv+qeY6OyoQdYIumvOrbXWbMONgeUsy3svK67NSEEVHLTUEnq3T93Z
         WjZDPGzT/Sm2ne1EOi9XJQs5bBTlLyY4StGuUgRBRl43AIlvqC//mFi9EXC7VsIo0Kh3
         jrQZCZJrfABLTciTv3tMxTQGTBUVHUWqVv938g1y0Q16KV5JwOslf+zytRH6fcmtncNz
         r6/n3C1dVWSPxwTP7ZDAaOUFkZcs4oCQFhYFOT3zAF2OLakwlo+vH3fKStApBz3cwpI7
         acHg==
X-Google-Smtp-Source: APXvYqy7+tj0nUROT403yhSxQDTNTeUEt7vFZMtJl4pXCrWO7ZosVUwEvdbmELi2qgFA1B4FJn4qM+P2QDcjSMHtJI4=
X-Received: by 2002:a05:6638:3d6:: with SMTP id r22mr31783750jaq.71.1562030226625;
 Mon, 01 Jul 2019 18:17:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190702005122.41036-1-henryburns@google.com> <CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
In-Reply-To: <CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Mon, 1 Jul 2019 18:16:30 -0700
Message-ID: <CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Shakeel Butt <shakeelb@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 1, 2019 at 6:00 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Mon, Jul 1, 2019 at 5:51 PM Henry Burns <henryburns@google.com> wrote:
> >
> > __SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
> > lock the page. Following zsmalloc.c's example we call trylock_page() and
> > unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
> > passed in locked, as documentation.
> >
> > Signed-off-by: Henry Burns <henryburns@google.com>
> > Suggested-by: Vitaly Wool <vitalywool@gmail.com>
> > ---
> >  Changelog since v1:
> >  - Added an if statement around WARN_ON(trylock_page(page)) to avoid
> >    unlocking a page locked by a someone else.
> >
> >  mm/z3fold.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > index e174d1549734..6341435b9610 100644
> > --- a/mm/z3fold.c
> > +++ b/mm/z3fold.c
> > @@ -918,7 +918,10 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
> >                 set_bit(PAGE_HEADLESS, &page->private);
> >                 goto headless;
> >         }
> > -       __SetPageMovable(page, pool->inode->i_mapping);
> > +       if (!WARN_ON(!trylock_page(page))) {
> > +               __SetPageMovable(page, pool->inode->i_mapping);
> > +               unlock_page(page);
> > +       }
>
> Can you please comment why lock_page() is not used here?
Since z3fold_alloc can be called in atomic or non atomic context,
calling lock_page() could trigger a number of
warnings about might_sleep() being called in atomic context. WARN_ON
should avoid the problem described
above as well, and in any weird condition where someone else has the
page lock, we can avoid calling
__SetPageMovable().
>
> >         z3fold_page_lock(zhdr);
> >
> >  found:
> > @@ -1325,6 +1328,7 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
> >
> >         VM_BUG_ON_PAGE(!PageMovable(page), page);
> >         VM_BUG_ON_PAGE(!PageIsolated(page), page);
> > +       VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> >
> >         zhdr = page_address(page);
> >         pool = zhdr_to_pool(zhdr);
> > --
> > 2.22.0.410.gd8fdbe21b5-goog
> >

