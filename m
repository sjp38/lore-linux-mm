Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C1EBC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:39:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B211B2189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:39:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NqaumRs/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B211B2189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43D6B8E0008; Wed,  3 Jul 2019 12:39:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C6D78E0001; Wed,  3 Jul 2019 12:39:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 290A68E0008; Wed,  3 Jul 2019 12:39:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0910F8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 12:39:50 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v11so3185565iop.7
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 09:39:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kbDcTo4F8dXvZfSLbaTtza62bmr8qH9H1r6LEOl+lHU=;
        b=s70natkDluykVBjS86aMV8dUKzUPBEP7ebhkcK+kWhdgyRNXHf/rDKtwOjPUVqhdOX
         kCICgKq4P+RuyRZg4zviSwH9vobkdjNjgT629bMSCKe9cwEJJ5lSAqq9EG3RTflYawL1
         5YnMR0twiTD2eHzlX8zgiSC84IWP8mxHwOmKQiQ61awkl6TXsoWJcuwRX5uc7ozYSEsc
         bK2debNBu0XqUeWHTP6CrjiWyLLWVXsNwDFQsnOHTzAbc4F7mqo+RVWdAt3f3aPICiqG
         MMJY0ly5JcgRA/KWQHLvyuN5ODjCWh0/8faFKulnnJJuYpbaAa3i41b4sFGG5gIkjxOk
         hPyg==
X-Gm-Message-State: APjAAAWi0p7Hurm2PFn7mHfPAKsIzYUqXrNgcCD+4mnM+/Z8ZaTzOA0Y
	K6JEkIyjUtlKHsxVgwULjulHr7n7J7FB4HWgfUOcw/ytpmg4HFNY5k5xEE1J/Tp5/DJBetIZ77M
	c6EjN1mtthEbzaHZE7HBdr0jYN5v1m3OuQ9DBHA6MBPh1sJ7jqNif40VMMN04zaDlYg==
X-Received: by 2002:a6b:d81a:: with SMTP id y26mr9029809iob.126.1562171989798;
        Wed, 03 Jul 2019 09:39:49 -0700 (PDT)
X-Received: by 2002:a6b:d81a:: with SMTP id y26mr9029757iob.126.1562171989164;
        Wed, 03 Jul 2019 09:39:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562171989; cv=none;
        d=google.com; s=arc-20160816;
        b=vuw5pAGGCQbmTtWmKEbmitx8j8Y1hKLg62R9ayne6crEvIrk32vyPD15OQwINu5kWR
         v3n7wH7fbTE8SsCJaahazveNaXgJluaipf4iuZxZexXu01KZL27sclzFJYJ4fYKxGmMq
         ogKES+5Qnzj8dADFVE799kRldrBwwzVmUb5F+7Q0Xil8ZS9VLG8JuU9OOqpbrzYiKT26
         o1diF2q+8P9Bz74Zx9FQcAkVAFEONE52YuxQIsoqI9pDwD+lrNNhlwvLilpaZ/I1wuM/
         iHkqpQan2+OQbb6HsOxOGwa6pQs8qrTRo4PDj9PaesMjHLJcjgmUktT+Kt3X6Xc1g1Df
         dQMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kbDcTo4F8dXvZfSLbaTtza62bmr8qH9H1r6LEOl+lHU=;
        b=By6eDXl9MxrJBPTsiyMKt0XuwH74GV3T7oqWHSPY3y2ohBuLlO7e6ZYvLKvEZNjCLQ
         F2rk4cUo8cjVfIrljy+iek795xoJ0gzQBStV4Ocy+5ZHyH5JruarBcbeULmBZ/4ePdeL
         /ck3nE0rqqaSmWVorgDhUdU5bNm+u+3PJYx1P0m2412WrY9h8e3y4YsErw3HN1ZU1i38
         yflWOpnO0TgKmY41AMt9uFqLdHK0QgDtOPELLuRCLhLsf4DZDigDMJCvVJCsca+VJaJ6
         OpQs65xLQc/u0qjGMPxfgWxmm2DIF/uY1mv92NsxYrEoX89Ku6LHvJcj+h4bpURic0Pv
         mNDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="NqaumRs/";
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor2062055iog.11.2019.07.03.09.39.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 09:39:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="NqaumRs/";
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kbDcTo4F8dXvZfSLbaTtza62bmr8qH9H1r6LEOl+lHU=;
        b=NqaumRs/9r4N+LLQZVW7EKfaaKJYqiFXNQS0FREyFBH2dA5dQe+xDeHSF8h0f4HvVD
         ZpP8PimJIp+5sU4npv4xahYwMV9fygG58x2bwWCGYHMgA8d9jsiTXdEjgjXy50uJ8PsW
         TEbw48ERxWv8d1V3mw3vCrwh3vLxHeL0fTrQR+MYMu9XRa8KDsArTcgvh9andjUd2RP+
         5woe4LfbhzoeKMgNBcJVBChrKTb8DDZ1RbCyrhk++x3Je98AMpNOduXga2w48ITbLxqT
         5lCWRmkcHTJKIQBXr5u7Wu9Iwq41eXIyXnTqbszIjP3xokx9W176FvHXk2RhCqMaUmCV
         qGzw==
X-Google-Smtp-Source: APXvYqzQyMYWqIT3Qfzpzptk3frJruzBTwW4rOb6aZvmElpX2SgWPwSUu0Enx4gwy/J+gJai0zJoUGBZgjWzPFk+Uh8=
X-Received: by 2002:a5d:81c6:: with SMTP id t6mr15956036iol.86.1562171988733;
 Wed, 03 Jul 2019 09:39:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190702005122.41036-1-henryburns@google.com> <CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
 <CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com>
 <20190702141930.e31bf1c07a77514d976ef6e2@linux-foundation.org>
 <CAGQXPTiONoPARFTep-kzECtggS+zo2pCivbvPEakRF+qqq9SWA@mail.gmail.com>
 <20190702152409.21c6c3787d125d61fb47840a@linux-foundation.org> <CAMJBoFOhXP36L6pZEA-7p24mJweDGe9iYb2fo1nNCxadYHcPzQ@mail.gmail.com>
In-Reply-To: <CAMJBoFOhXP36L6pZEA-7p24mJweDGe9iYb2fo1nNCxadYHcPzQ@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Wed, 3 Jul 2019 09:39:12 -0700
Message-ID: <CAGQXPTgRC23SHoKZTctkJsEJORu7GHDYNz_+9HaDu9ntffrzig@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 10:54 PM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> On Wed, Jul 3, 2019 at 12:24 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Tue, 2 Jul 2019 15:17:47 -0700 Henry Burns <henryburns@google.com> wrote:
> >
> > > > > > > +       if (can_sleep) {
> > > > > > > +               lock_page(page);
> > > > > > > +               __SetPageMovable(page, pool->inode->i_mapping);
> > > > > > > +               unlock_page(page);
> > > > > > > +       } else {
> > > > > > > +               if (!WARN_ON(!trylock_page(page))) {
> > > > > > > +                       __SetPageMovable(page, pool->inode->i_mapping);
> > > > > > > +                       unlock_page(page);
> > > > > > > +               } else {
> > > > > > > +                       pr_err("Newly allocated z3fold page is locked\n");
> > > > > > > +                       WARN_ON(1);
> >
> > The WARN_ON will have already warned in this case.
> >
> > But the whole idea of warning in this case may be undesirable.  We KNOW
> > that the warning will sometimes trigger (yes?).  So what's the point in
> > scaring users?
>
> Well, normally a newly allocated page that we own should not be locked
> by someone else so this is worth a warning IMO. With that said, the
> else branch here appears to be redundant.
The else branch has been removed, and I think it's possible (albeit unlikely)
that the trylock could fail due to either compaction or kstaled
(In which case the page just won't be movable).

Also Vitaly, do you have a preference between the two emails? I'm not sure which
one to include.

