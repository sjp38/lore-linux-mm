Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF5F8C10F0E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 02:19:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E0BC20652
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 02:19:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="egV7tTkp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E0BC20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AF2E6B0007; Mon, 15 Apr 2019 22:19:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15FA36B0008; Mon, 15 Apr 2019 22:19:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0797E6B000A; Mon, 15 Apr 2019 22:19:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1DB76B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 22:19:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y17so12434703plr.15
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 19:19:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UCqn4xJsfn6LSF38geTP0GiT3GQOfaOQ+QhzCgzo1co=;
        b=lsUD+RevePLKLIk3qrQCNdY5gL5LYwX733mfCCRIbLdixlGUwoa5Yzu+OhAu+ls3hA
         kTv0pkihznI10/h8GhksIAgLz2aNLtUKEXxwQZCyAjx7+3VjIuO9aY8iJu9IE7Tq4LpJ
         eSbyELZFoR5H8QIfdbFGu0Z6R9rPSDXIkAPypk1ssU/N4CZiFwPPuxPYqobDuvnCcfX6
         H/WqiESeIjGHSVZANPThRFUFKR8HaQvxjATuxjEdFHrjU1BpKoVdAWwV/r3jEZRLNkz3
         p6SvVw2TukM0JaqEgW2EWId0lUIA39/wUMRcQ3sd9ZVo4iAYEL6TObVO3UoP6oHsWXSX
         /F0A==
X-Gm-Message-State: APjAAAV/e7+3cK1SFcbWEBB+TSuchSTcavhRKHcxHagqvBbkxSP8CZkV
	t1o36+9X2hxlWXoCFm+apU77xKVdPZzFUWvP3PeCVJxBd2nhlNBKkDX+54H8lpe/xoMX7hB6cnj
	UTFIjKfW2VJmmMCMQd49V1dPJjLIwcx3fqt2ObLCDnN4duv3o979z8G0dc/u/+/ZGew==
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr79939996plb.155.1555381144472;
        Mon, 15 Apr 2019 19:19:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrZ7yzexTilVH4LQA23E7J+VmDvuyirMxNw0fg0bCSFGzyNSyVCkOFAQrOW18PqHTRONer
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr79939944plb.155.1555381143699;
        Mon, 15 Apr 2019 19:19:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555381143; cv=none;
        d=google.com; s=arc-20160816;
        b=k6DO5mlbViSqBcBjPXyDOsyE2YkVEs6SSmBeAYDfIHMgNM0a6XrbBx72FXBsusUC4N
         /Omf0JLjOXaIrKP25Hr1geC3xLgrAniCkopDR2EXqyniS8aXtpaQ6I6H9+wcELmuG9Qp
         BnzLO7+r3jxns1E+pmV0EbX1+UGzg+upbDR7SizHuporIONlfYPAzyu1bC6s8Fr33IPp
         cHv6md9G7wIENqlktiRIhjvhr3Mj2IP7xpT8T/jcQ6GY9Pb/caOnYMKmo+m6I6ekKvmY
         dyyoDPWxgDjijsoS+Gh9lZfHoYG3YQmHDM5+nbPeXtf0Gv1BVJ8VjGt9gRv51GaMxbkh
         lTEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UCqn4xJsfn6LSF38geTP0GiT3GQOfaOQ+QhzCgzo1co=;
        b=mS/c3/GfLg/GHid9536amZEwW45ccbhfhy7nkxB292Tjz1FHhY3JxiCxG/Y0NkSznH
         uwxJNh0923Tl7duIfpf1oCRrleGq72ig9zuQwmaa9aJJ/rx8VTRBykNH8oCOOmnrIdjM
         YDVi1UV3mZ4TdgUVX0P9HvFugNme/CwqhHRyh7Tg8DvniuHDAWtQttUbpUDyUbh4hwsT
         pEdEt/Fj1/gwLIsEYknUnu2LwFwmRCiPdDEu/L1ETyYK+JKH8H5L74+CykGEMtfC0Fo8
         sEbarJsHAxlur8pB88c/6bA57KfHETzWG+LbXOI0iOn1+vUuOluxWQxFiwm/PBpDfI76
         jYJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=egV7tTkp;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d17si46228612pgg.367.2019.04.15.19.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Apr 2019 19:19:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=egV7tTkp;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UCqn4xJsfn6LSF38geTP0GiT3GQOfaOQ+QhzCgzo1co=; b=egV7tTkpiN9UWTV3PXo4mGfLW
	tbeL71ZPBs4HFrlSAHPfvTx5o1bsD58ovucaD2v+AGmrP7XvuU7izDvOhAY3sqSPXU42U8Gb3pycu
	wXJ3K6Vbk/xXJ/HQYyn/Gwpw5kM8HAqi3pC7vlMBhzuPKGe5T9e9FP5ZkfxJ25pivvxM5iwZqz9jd
	ZHZ6gy1YHEIcLju7XgZkwVQMjQCOOBqM9z3F+MXW/gnUI1bRcGIBJr83/OlHMDhbi4wTOaFHLYIRc
	meSEFn5Bbi+peV/JaPozGSUudMpsq8SkY17MhfLYr+A6jeSyE/r2AzgFz9MxL4aYdkeFilGuP/jN3
	YBRDv9a/A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hGDgS-0004Ef-Gw; Tue, 16 Apr 2019 02:18:52 +0000
Date: Mon, 15 Apr 2019 19:18:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Kees Cook <keescook@chromium.org>, Eric Biggers <ebiggers@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	linux-crypto <linux-crypto@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH] crypto: testmgr - allocate buffers with __GFP_COMP
Message-ID: <20190416021852.GA18616@bombadil.infradead.org>
References: <20190411192607.GD225654@gmail.com>
 <20190411192827.72551-1-ebiggers@kernel.org>
 <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
 <20190415022412.GA29714@bombadil.infradead.org>
 <20190415024615.f765e7oagw26ezam@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190415024615.f765e7oagw26ezam@gondor.apana.org.au>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 10:46:15AM +0800, Herbert Xu wrote:
> On Sun, Apr 14, 2019 at 07:24:12PM -0700, Matthew Wilcox wrote:
> > On Thu, Apr 11, 2019 at 01:32:32PM -0700, Kees Cook wrote:
> > > > @@ -156,7 +156,8 @@ static int __testmgr_alloc_buf(char *buf[XBUFSIZE], int order)
> > > >         int i;
> > > >
> > > >         for (i = 0; i < XBUFSIZE; i++) {
> > > > -               buf[i] = (char *)__get_free_pages(GFP_KERNEL, order);
> > > > +               buf[i] = (char *)__get_free_pages(GFP_KERNEL | __GFP_COMP,
> > > > +                                                 order);
> > > 
> > > Is there a reason __GFP_COMP isn't automatically included in all page
> > > allocations? (Or rather, it seems like the exception is when things
> > > should NOT be considered part of the same allocation, so something
> > > like __GFP_SINGLE should exist?.)
> > 
> > The question is not whether or not things should be considered part of the
> > same allocation.  The question is whether the allocation is of a compound
> > page or of N consecutive pages.  Now you're asking what the difference is,
> > and it's whether you need to be able to be able to call compound_head(),
> > compound_order(), PageTail() or use a compound_dtor.  If you don't, then
> > you can save some time at allocation & free by not specifying __GFP_COMP.
> 
> Thanks for clarifying Matthew.
> 
> Eric, this means that we should not use __GFP_COMP here just to
> silent what is clearly a broken warning.

I agree; if the crypto code is never going to try to go from the address of
a byte in the allocation back to the head page, then there's no need to
specify GFP_COMP.

But that leaves us in the awkward situation where
HARDENED_USERCOPY_PAGESPAN does need to be able to figure out whether
'ptr + n - 1' lies within the same allocation as ptr.  Without using
a compound page, there's no indication in the VM structures that these
two pages were allocated as part of the same allocation.

We could force all multi-page allocations to be compound pages if
HARDENED_USERCOPY_PAGESPAN is enabled, but I worry that could break
something.  We could make it catch fewer problems by succeeding if the
page is not compound.  I don't know, these all seem like bad choices
to me.

