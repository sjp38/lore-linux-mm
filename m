Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFEC0C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:18:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79BB2218FF
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:18:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nBSEOeFp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79BB2218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EFF66B0003; Tue,  2 Jul 2019 18:18:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A1DF8E0003; Tue,  2 Jul 2019 18:18:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED0598E0001; Tue,  2 Jul 2019 18:18:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF41E6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:18:24 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h3so250110iob.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:18:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ytW0OWDzeMr1hdoz0EslmLVkCowQp/51ALwoyHUI2GI=;
        b=mbPjP9ZI+i9w3HDHJcYdYzxWyE/F5DPP1d81bcNJeLjyqJHQ4WpQoIcLWPoYN9D+cR
         Er8vX5BGdVWEp0J8cXHwFsTtL5UhY0IWXns4Gx7iINwshuXTKhGYBQ/Fc632b5BdJd2J
         wO5qOl2sQ2LSjJ86/9z1FId4ZkmRulSut0gE3jrFzoLkdexWNwqvx8EiZOpqrehuydZu
         VlqnpEql6V1THULk60r+opToKRdWbbbYyR273S58FtPI3e440WknvWWB1qROD6aCXOQL
         rqSgZ9rGrespvoW5Bkw8Mtc+ETX3DjcszwxbVcso41+yAvP02yUwt6V3NMBShH/BhQfS
         UsrA==
X-Gm-Message-State: APjAAAWCprG9T8t8Juj5dU9b9sPx4LuGAuSmLrrcciZ4w90EJ4ejndkJ
	HM+RzzKyrHHqz/a5LduAxBCt7jBVqZ50a5WgMJEYcRa8dGGzXw6GeG2PzVdzdgBsDuU/k9HbHUX
	6wi95nQUZuYVA/CrcsbFOUqUq9a4HuXs3M6+97QxL/qZu2q58GU4/aablELLbjRPcXQ==
X-Received: by 2002:a02:16c5:: with SMTP id a188mr39290237jaa.86.1562105904585;
        Tue, 02 Jul 2019 15:18:24 -0700 (PDT)
X-Received: by 2002:a02:16c5:: with SMTP id a188mr39290147jaa.86.1562105903803;
        Tue, 02 Jul 2019 15:18:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562105903; cv=none;
        d=google.com; s=arc-20160816;
        b=oj/Qfl/dgSycmepRT9T65GZNMEJSB9zNAQum/jB/wmzPNoCryYOhgH59rbquOzxF/Y
         dFL5k6PuvGj1RJnvxpMntPfsOaGeYjFxpT9nR3nli0gq5hgeu3XF2z1P7lqLdoAddPeW
         c0uNhQI4bPjyJWjR2E9sOSc1DaK3rHxELSHfpg3tdxgX7zdEaSZZeNzvWRwJHWg2NEyP
         BH9HbedaD9zuHI9m1koXsixZVffBzpieQjtVW6IrPyHRZQRKD2Fp0SRSWD7+KQAK0/Dq
         FSeCO74GoKWG4zK7kbytmG9Km6ruN4KuW0cyQKBvmsUjfKWTiezjLvBMyL2S9+PzEVzY
         mbOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ytW0OWDzeMr1hdoz0EslmLVkCowQp/51ALwoyHUI2GI=;
        b=JKonUv7R9aRPd7cEHahInkTWDf1rhSUSfxyrHwLUMFTZfM7iqW2VDv1qkGcrluixtk
         ryX8kvz7QJ+epvfyZvdrV8Mn+OPhq7KZwPg6f9Q2O6UwebLApQJ1CtR854+AdR19lenD
         vsqa0Pi4fhvmQs4a+XNbThwD36DlofcGX0rc27w5/mSun89nwR3lZgQgTL8z79Klt/SK
         QDDxtszGkAUNnG0IJOatmjnF6ddOUsIzhRTP0JtjRMntO4/W5i/GJrh6kOBWYWyyGS7z
         H9PRlrKJbDrF92MoMhywC8Rg2wcFJY+lZPrHsUfSQO+b6OAgtOn/yi45puCnaUZIIppa
         3wQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nBSEOeFp;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor177235ioo.100.2019.07.02.15.18.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 15:18:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nBSEOeFp;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ytW0OWDzeMr1hdoz0EslmLVkCowQp/51ALwoyHUI2GI=;
        b=nBSEOeFp5wxsOc5nTyqZmSBLDUrnq1nUlE9LRL00bMxxQ1nC9cUrMJLQwOr63l7q1w
         o9YaaR5F4rYdFz2pUixfzkhj1Ip79oCTaPKe4HDDH0qjCAseTf5T7zRHqKjKVe4JBP52
         Nplnas64U+BD2r13HOt+d293Y7bvus/A0EwtMJ7gGxdYEIT2HQybaKmQ179ennlf2XSZ
         P6EnWzAwK0ddqKUQA6tNNS7uAB8KzxJBrrkpcaJmxWRhWrpG32OQ0nZ8w3cWEqUEqfgU
         pvwbgy6SkYP+RNRrBBdfM5woWRI2kb/sMj2nIfV0U8gXMGhqsq8dX9zL6WqQBWSM/+X8
         SLSQ==
X-Google-Smtp-Source: APXvYqwBBwXRA2xJcuG7FSTjOiKfMXmkSt9uttUFKGDIkknV+eIWIcBpxOKHmkhjU9BiyBByxx0pOLNOMy5nTlfTNp0=
X-Received: by 2002:a02:aa8f:: with SMTP id u15mr37908229jai.39.1562105903431;
 Tue, 02 Jul 2019 15:18:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190702005122.41036-1-henryburns@google.com> <CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
 <CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com> <20190702141930.e31bf1c07a77514d976ef6e2@linux-foundation.org>
In-Reply-To: <20190702141930.e31bf1c07a77514d976ef6e2@linux-foundation.org>
From: Henry Burns <henryburns@google.com>
Date: Tue, 2 Jul 2019 15:17:47 -0700
Message-ID: <CAGQXPTiONoPARFTep-kzECtggS+zo2pCivbvPEakRF+qqq9SWA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Vitaly Wool <vitalywool@gmail.com>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 2:19 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 1 Jul 2019 18:16:30 -0700 Henry Burns <henryburns@google.com> wrote:
>
> > Cc: Vitaly Wool <vitalywool@gmail.com>, Vitaly Vul <vitaly.vul@sony.com>
>
> Are these the same person?
I Think it's the same person, but i wasn't sure which email to include
because one was
in the list of maintainers and I had contacted the other earlier.
>
> > Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
> > Date: Mon, 1 Jul 2019 18:16:30 -0700
> >
> > On Mon, Jul 1, 2019 at 6:00 PM Shakeel Butt <shakeelb@google.com> wrote:
> > >
> > > On Mon, Jul 1, 2019 at 5:51 PM Henry Burns <henryburns@google.com> wrote:
> > > >
> > > > __SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
> > > > lock the page. Following zsmalloc.c's example we call trylock_page() and
> > > > unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
> > > > passed in locked, as documentation.
>
> The changelog still doesn't mention that this bug triggers a
> VM_BUG_ON_PAGE().  It should do so.  I did this:
>
> : __SetPageMovable() expects its page to be locked, but z3fold.c doesn't
> : lock the page.  This triggers the VM_BUG_ON_PAGE(!PageLocked(page), page)
> : in __SetPageMovable().
> :
> : Following zsmalloc.c's example we call trylock_page() and unlock_page().
> : Also make z3fold_page_migrate() assert that newpage is passed in locked,
> : as per the documentation.
>
> I'll add a cc:stable to this fix.
>
> > > > Signed-off-by: Henry Burns <henryburns@google.com>
> > > > Suggested-by: Vitaly Wool <vitalywool@gmail.com>
> > > > ---
> > > >  Changelog since v1:
> > > >  - Added an if statement around WARN_ON(trylock_page(page)) to avoid
> > > >    unlocking a page locked by a someone else.
> > > >
> > > >  mm/z3fold.c | 6 +++++-
> > > >  1 file changed, 5 insertions(+), 1 deletion(-)
> > > >
> > > > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > > > index e174d1549734..6341435b9610 100644
> > > > --- a/mm/z3fold.c
> > > > +++ b/mm/z3fold.c
> > > > @@ -918,7 +918,10 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
> > > >                 set_bit(PAGE_HEADLESS, &page->private);
> > > >                 goto headless;
> > > >         }
> > > > -       __SetPageMovable(page, pool->inode->i_mapping);
> > > > +       if (!WARN_ON(!trylock_page(page))) {
> > > > +               __SetPageMovable(page, pool->inode->i_mapping);
> > > > +               unlock_page(page);
> > > > +       }
> > >
> > > Can you please comment why lock_page() is not used here?
>
> Shakeel asked "please comment" (ie, please add a code comment), not
> "please comment on".  Subtle ;)
>
> > Since z3fold_alloc can be called in atomic or non atomic context,
> > calling lock_page() could trigger a number of
> > warnings about might_sleep() being called in atomic context. WARN_ON
> > should avoid the problem described
> > above as well, and in any weird condition where someone else has the
> > page lock, we can avoid calling
> > __SetPageMovable().
>
> I think this will suffice:
>
> --- a/mm/z3fold.c~mm-z3foldc-lock-z3fold-page-before-__setpagemovable-fix
> +++ a/mm/z3fold.c
> @@ -919,6 +919,9 @@ retry:
>                 set_bit(PAGE_HEADLESS, &page->private);
>                 goto headless;
>         }
> +       /*
> +        * z3fold_alloc() can be called from atomic contexts, hence the trylock
> +        */
>         if (!WARN_ON(!trylock_page(page))) {
>                 __SetPageMovable(page, pool->inode->i_mapping);
>                 unlock_page(page);
>
> However this code would be more effective if z3fold_alloc() were to be
> told when it is running in non-atomic context so it can perform a
> sleeping lock_page() in that case.  That's an improvement to consider
> for later, please.
>

z3fold_alloc() can tell when its called in atomic context, new patch incoming!
I'm thinking something like this:

> > > > +       if (can_sleep) {
> > > > +               lock_page(page);
> > > > +               __SetPageMovable(page, pool->inode->i_mapping);
> > > > +               unlock_page(page);
> > > > +       } else {
> > > > +               if (!WARN_ON(!trylock_page(page))) {
> > > > +                       __SetPageMovable(page, pool->inode->i_mapping);
> > > > +                       unlock_page(page);
> > > > +               } else {
> > > > +                       pr_err("Newly allocated z3fold page is locked\n");
> > > > +                       WARN_ON(1);
> > > > +               }
> > > > +       }

