Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 971DDC5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:19:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34F75218BC
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:19:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mTmZs1yo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34F75218BC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABB396B0003; Tue,  2 Jul 2019 17:19:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A42E18E0003; Tue,  2 Jul 2019 17:19:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BBFD8E0001; Tue,  2 Jul 2019 17:19:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 523A86B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 17:19:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c17so31353pfb.21
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 14:19:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fFnP/4ko1bTRM65ZZce3YMyBsH4542HegdeVnSUHtDs=;
        b=fmgExb1QIGiI0t3Rk2MbAopTwXKZra2XTlkGCQPnhaoB+qZNhgRhV6y0GhAEyylHIO
         zB/rPYqlHUbx3B/hwPbsaO0LaAdvaeazfG5k42D288H4trz8poKPwD8gwGIwSWIvanl8
         97jEhgNSCgs2NWcTtfsCZSCe4B87VtkX0OOy1ugbGKmJDJdOJf//S4qTVOctQhY2Lb3m
         nwlmIpleJVBaCEXn/5NX1mdPV46DoHpzKafFF3yI9/XPfbGYOx/Aom3rhFjsJHDeOdkp
         rxXnXTmIFOnEMzyx8RBnJ/osCXHVwNdYrqobpcHoK+AOlJVvWecIlkKRti5x193ZTWC7
         sg8Q==
X-Gm-Message-State: APjAAAURUn6vvbK5NQLhgJFzlIHDI1ZRIq/oubIUesztrFoUUYiwWxXh
	990HtUl2BGo3QO4O4oSWznaa9TNG+KAju0Qkpxry0tJnAK0rWY9Qhed1J3E01NhJvVOzVGhZq2B
	nQmkRtoK3aoq9Vu7a9OzEVxHBOPD9+ADiDZwJZCtbK2ByAhn46TDTPF28i4M4xt2V2Q==
X-Received: by 2002:a17:90a:2041:: with SMTP id n59mr7650410pjc.6.1562102372911;
        Tue, 02 Jul 2019 14:19:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjM/P9/SVCd8dx5aVgGeUlK+3WdUY+3DukFwpJLopAuiFGMwhrdfHWqWD7QUgTJKLftFnN
X-Received: by 2002:a17:90a:2041:: with SMTP id n59mr7650355pjc.6.1562102372095;
        Tue, 02 Jul 2019 14:19:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562102372; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/lE7XOFU0ph45Ibf9o6/ZvyCEB2ziTzVwmIiwfWT1BX/fPSiOExUgDmcSNL1bo4Me
         j3uzmC4U6hKq1SgPdkAZOjsZbwSj6vZ7UxwLvJmeschsJRkLQU2+ANWl5GKW3JgmwI9p
         L2dVB6ZTo7U91bzCONtxH8/wYAbyQSECEd0ObPIeRnoUU4MBmrx62mV/zbE6GweTCSLT
         CEAo6tujd3xvulvOJH2j+lNt/YuHToNxoTpf1zRB2yE6BAvOtEX2vOzqhbFKCzhL4yIn
         T65cRmjfXBdgP2CRrwmp9p1yF6lGmhKrHuj8CMzPp35hy/LDmj9RCMGo4mWp92zyzh++
         KN4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fFnP/4ko1bTRM65ZZce3YMyBsH4542HegdeVnSUHtDs=;
        b=bA1GKQ8Ne4a0F0zcqdmNKBMvbfO62VgnS+eCSR3Ksie93pZtlPKUMF449UpVegOIPW
         4jq4tJQQS+bFsaP4aLgDPwY3U/q1QapMwukkgLVtNX67IbC3jepd6nJj5o9gAmMqVujX
         gcDs1n1O/ap2sGLb0Uwe/NZnXcdEjIh0t63tWJR1hy6FoXFD91mVgsN1bn7nOYS9Bvgn
         WSZyX16N/Ra/NcrewjruGS16iuePRu33BfriUQwef6EyaNFrInfrXed3RXKOoTR2aqWz
         3ryuOpqo3FMoSWqtpjrLB5l/kG2ii4tHlKHEzOm6NaSqXH/E3tTB30y20cGXswsI3qlb
         BpSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mTmZs1yo;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q7si284229pgp.245.2019.07.02.14.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 14:19:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mTmZs1yo;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5E86B218BA;
	Tue,  2 Jul 2019 21:19:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562102371;
	bh=Tlj2RrGNaOqOZ+7sngsROh+dPsr/HURv8KYaqPdX2Tc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=mTmZs1yoM8R9sJY0ieO8eIQJr3f8HYOWvQ3AMF5RJaDSv2pSaZaihzF+/IR3zRzS1
	 c1Lo86AgdvNT8xO+Z6NMAKkcwx8Bv9Q2MIOWKOkhIYBQdrBruYLu3rZABrPfWQySrt
	 4Gaz5KQ1vRA5wuFWuTaH2vEnRIcEeE+JF2BKSBmI=
Date: Tue, 2 Jul 2019 14:19:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Henry Burns <henryburns@google.com>
Cc: Shakeel Butt <shakeelb@google.com>, Vitaly Wool <vitalywool@gmail.com>,
 Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>,
 Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before
 __SetPageMovable()
Message-Id: <20190702141930.e31bf1c07a77514d976ef6e2@linux-foundation.org>
In-Reply-To: <CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com>
References: <20190702005122.41036-1-henryburns@google.com>
	<CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
	<CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jul 2019 18:16:30 -0700 Henry Burns <henryburns@google.com> wrote:

> Cc: Vitaly Wool <vitalywool@gmail.com>, Vitaly Vul <vitaly.vul@sony.com>

Are these the same person?

> Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
> Date: Mon, 1 Jul 2019 18:16:30 -0700
> 
> On Mon, Jul 1, 2019 at 6:00 PM Shakeel Butt <shakeelb@google.com> wrote:
> >
> > On Mon, Jul 1, 2019 at 5:51 PM Henry Burns <henryburns@google.com> wrote:
> > >
> > > __SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
> > > lock the page. Following zsmalloc.c's example we call trylock_page() and
> > > unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
> > > passed in locked, as documentation.

The changelog still doesn't mention that this bug triggers a
VM_BUG_ON_PAGE().  It should do so.  I did this:

: __SetPageMovable() expects its page to be locked, but z3fold.c doesn't
: lock the page.  This triggers the VM_BUG_ON_PAGE(!PageLocked(page), page)
: in __SetPageMovable().
:
: Following zsmalloc.c's example we call trylock_page() and unlock_page(). 
: Also make z3fold_page_migrate() assert that newpage is passed in locked,
: as per the documentation.

I'll add a cc:stable to this fix.

> > > Signed-off-by: Henry Burns <henryburns@google.com>
> > > Suggested-by: Vitaly Wool <vitalywool@gmail.com>
> > > ---
> > >  Changelog since v1:
> > >  - Added an if statement around WARN_ON(trylock_page(page)) to avoid
> > >    unlocking a page locked by a someone else.
> > >
> > >  mm/z3fold.c | 6 +++++-
> > >  1 file changed, 5 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > > index e174d1549734..6341435b9610 100644
> > > --- a/mm/z3fold.c
> > > +++ b/mm/z3fold.c
> > > @@ -918,7 +918,10 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
> > >                 set_bit(PAGE_HEADLESS, &page->private);
> > >                 goto headless;
> > >         }
> > > -       __SetPageMovable(page, pool->inode->i_mapping);
> > > +       if (!WARN_ON(!trylock_page(page))) {
> > > +               __SetPageMovable(page, pool->inode->i_mapping);
> > > +               unlock_page(page);
> > > +       }
> >
> > Can you please comment why lock_page() is not used here?

Shakeel asked "please comment" (ie, please add a code comment), not
"please comment on".  Subtle ;)

> Since z3fold_alloc can be called in atomic or non atomic context,
> calling lock_page() could trigger a number of
> warnings about might_sleep() being called in atomic context. WARN_ON
> should avoid the problem described
> above as well, and in any weird condition where someone else has the
> page lock, we can avoid calling
> __SetPageMovable().

I think this will suffice:

--- a/mm/z3fold.c~mm-z3foldc-lock-z3fold-page-before-__setpagemovable-fix
+++ a/mm/z3fold.c
@@ -919,6 +919,9 @@ retry:
 		set_bit(PAGE_HEADLESS, &page->private);
 		goto headless;
 	}
+	/*
+	 * z3fold_alloc() can be called from atomic contexts, hence the trylock
+	 */
 	if (!WARN_ON(!trylock_page(page))) {
 		__SetPageMovable(page, pool->inode->i_mapping);
 		unlock_page(page);

However this code would be more effective if z3fold_alloc() were to be
told when it is running in non-atomic context so it can perform a
sleeping lock_page() in that case.  That's an improvement to consider
for later, please.

