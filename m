Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 364F9C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:51:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D629620838
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:51:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pMiktFKk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D629620838
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58FD48E009A; Wed, 10 Jul 2019 17:51:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A838E0032; Wed, 10 Jul 2019 17:51:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BA388E009A; Wed, 10 Jul 2019 17:51:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0052F8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 17:51:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 21so2131362pfu.9
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:51:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4raB3IqyErqkg+JW+87rFy9oaXPi9i1d2UYtDB+hVu8=;
        b=YN+J0rU3XmaZ/rcbzyg302my+mwRbN+K28pqHAq+E0OkhTIhyepDwKgRie9Yqxv/HH
         CLU1nm/t4kIW78PfKtvVfa/d5z9qqFCaunxkoLLkuBWdpYn2iNn401uD7sD8OfACtRPk
         O+25+nRQQnW9VQ6pvP6GlXRTtv7dSQLcAtsqWoxRLrqrDyKAVDaF68bRE3+/QTnyBPCY
         VSAiAxSeQfNbhB0IRU9jelS99NWgvBiBXPzRjK77CMJ9X5YGvN/kApyuKWFBy7WLDfnP
         +cqO1vlq0oBARdaBjoAYm7g7/kaim+jNmc2GxIsr7M0o8WW1Hldb5aYtE6htaqeuskA1
         rTZQ==
X-Gm-Message-State: APjAAAU4RVipLd9EDUni4YpqB32L9TWo+QsHeMnKPUqAQ76hxgsUL7vL
	+ebsumC31TkBtiCCrq39glCPQFgIaq322AYvGUPVGVXB4FXN/ESXma4SlleMfDLtaVs3Tepr/7F
	hjNlZQz4pSXhrDLnMKqegSIR+ttCxZU1YmhiAgWgFE/g6stEO9BVe6zaAt8MaCDKj5w==
X-Received: by 2002:a65:5304:: with SMTP id m4mr501387pgq.126.1562795513603;
        Wed, 10 Jul 2019 14:51:53 -0700 (PDT)
X-Received: by 2002:a65:5304:: with SMTP id m4mr501334pgq.126.1562795512924;
        Wed, 10 Jul 2019 14:51:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562795512; cv=none;
        d=google.com; s=arc-20160816;
        b=AIOKi6MGdzRCuLZWk8wLTueOFtX2uo0QQvmwHMQAyXFN1LBFB4U5feoHNsaNN38j+j
         +6fM5KjVp1kl6hzZBcOhsb9HEZyr9CSXqX7eGoxnlBDMlBZx7xaCFD/sz72KNRJCVoqW
         JZQQv26lalPjP7iJkcnmx8WIzldTg4q8uIE8gburSD/AT9Y3/C+/ZRWh3uakgvMX/JXR
         4FcS5KM7w3zSY0EI40pgBYdOmatBnuL74bZ69mXWCvKOa5u/T0yqI5QdH8xiSV1laiVG
         VVQkjN9oPVqSv0tn06drFpvaENi3cRWf2XpLapz5zU+yjLyovc798v10QdA1X6/io3he
         DNxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4raB3IqyErqkg+JW+87rFy9oaXPi9i1d2UYtDB+hVu8=;
        b=cvkwB9yCrOTY8KtVpBzi4zwfn7GjDHk1rlmaI3ROfasJ0qzh4b0j9SlXebRYLW2CoF
         +rYm7/QH/RZCe6ByLsRy9mqJ1+jsMojrFSRaxpnXgU1lo4UiJsebd3bGo8wRsZYEcfXO
         +eExf46VYcsb5d6r5c29u4gFAuAupsY7v969nmAKlRJrXx+uELU0/5A4pndqkUUScMO4
         j+67BUm3r25RvpPKXuoXAqwBD0T7UogVpyU6dX3W3ZHR6wTIX5be60HWfkpCqBMZr8BI
         UTuzWGoajVbrZDoockPz1+7X4oLRkV50TIKamVc5CrM8tJ2Gjs5rTUYPNHEJJu2cWpXc
         5Ghw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pMiktFKk;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o39sor4539826pjb.10.2019.07.10.14.51.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 14:51:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pMiktFKk;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4raB3IqyErqkg+JW+87rFy9oaXPi9i1d2UYtDB+hVu8=;
        b=pMiktFKkY/frqdyoQe7sXxn6LL1Cu1eJU2aCdvxnAIjKEfBMVT2/a7GBTubBVbfWa+
         VrkYciVMRwRGNBsyxWRacUlQbz9KrF+YgOEQ71hxJjkKxT2GbmMOnuU6hw3Edpz1rbCX
         TVaEQ4RgH61os6AyO9go6PMGvQHfA26T17tshvtfCu+Y4EWNOD1RFFj6LJF3db0kSaGw
         8Y52qRyryah4clumr06EeeGgyEUDxNrK5Yj8CqCVoefgScQMSh511m0RPf+Ki7n+w5rf
         lcuyhHFh80YdhFGhsoBdDpij2xLcvg2j6MpWyUseC13csarlkuF/J5ijYVFflfpMRiG4
         GUig==
X-Google-Smtp-Source: APXvYqzpotPnFgfn8F3Q6TpCTjeRegyu0pJeMseHXkiht1BvBEBtrWB5K160JbdnR1FiaSX66t4gclal9uiAjRoVwZs=
X-Received: by 2002:a17:90a:380d:: with SMTP id w13mr620824pjb.138.1562795512264;
 Wed, 10 Jul 2019 14:51:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190710213238.91835-1-henryburns@google.com> <CALvZod7kMX5Xika8nqywyXHuBKqTfSPP7uZ1-OU2M4kmHLiuUw@mail.gmail.com>
In-Reply-To: <CALvZod7kMX5Xika8nqywyXHuBKqTfSPP7uZ1-OU2M4kmHLiuUw@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Wed, 10 Jul 2019 14:51:16 -0700
Message-ID: <CAGQXPTip1aMtChuKAYtYOti1QcZQOz4=Jy0w9O478KTMoT1c0A@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: remove z3fold_migration trylock
To: Shakeel Butt <shakeelb@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Jonathan Adams <jwadams@google.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Snild Dolkow <snild@sony.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > z3fold_page_migrate() will never succeed because it attempts to acquire a
> > lock that has already been taken by migrate.c in __unmap_and_move().
> >
> > __unmap_and_move() migrate.c
> >   trylock_page(oldpage)
> >   move_to_new_page(oldpage_newpage)
> >     a_ops->migrate_page(oldpage, newpage)
> >       z3fold_page_migrate(oldpage, newpage)
> >         trylock_page(oldpage)
> >
> >
> > Signed-off-by: Henry Burns <henryburns@google.com>
>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
>
> Please add the Fixes tag as well.
Fixes: 1f862989b04a ("mm/z3fold.c: support page migration")
>
> > ---
> >  mm/z3fold.c | 6 ------
> >  1 file changed, 6 deletions(-)
> >
> > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > index 985732c8b025..9fe9330ab8ae 100644
> > --- a/mm/z3fold.c
> > +++ b/mm/z3fold.c
> > @@ -1335,16 +1335,11 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
> >         zhdr = page_address(page);
> >         pool = zhdr_to_pool(zhdr);
> >
> > -       if (!trylock_page(page))
> > -               return -EAGAIN;
> > -
> >         if (!z3fold_page_trylock(zhdr)) {
> > -               unlock_page(page);
> >                 return -EAGAIN;
> >         }
> >         if (zhdr->mapped_count != 0) {
> >                 z3fold_page_unlock(zhdr);
> > -               unlock_page(page);
> >                 return -EBUSY;
> >         }
> >         new_zhdr = page_address(newpage);
> > @@ -1376,7 +1371,6 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
> >         queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
> >
> >         page_mapcount_reset(page);
> > -       unlock_page(page);
> >         put_page(page);
> >         return 0;
> >  }
> > --
> > 2.22.0.410.gd8fdbe21b5-goog
> >

