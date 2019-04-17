Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 900C0C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 04:08:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D02320693
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 04:08:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CON7p5qb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D02320693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF4AC6B0281; Wed, 17 Apr 2019 00:08:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA3A96B0282; Wed, 17 Apr 2019 00:08:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6CBF6B0283; Wed, 17 Apr 2019 00:08:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 727076B0281
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 00:08:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id cs14so14708293plb.5
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 21:08:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Em4HpOp3QfI9scdNSfMBzQDhJV4iaM3Bd30fC2vkXHU=;
        b=ShcEqmfgSOT891xifkZ/ZA5H96eA52QyJzFr6prOfP8cVv1iaAgspVcL3kOywn9bic
         EfRBqhthHVSnWkxiP7DMKjtcg3IYEu3HqwXVKgohOoIkDx0liC+szB83RP1fQUnmaXch
         /TqrgKH6+1dyp4cihc+tnBO2ufqmBzTQogVKcIuLKKTxoLAuJ/WoOHf3v3P8poDhpFcY
         0RA4g8JlnZiCEdkckvXyUW06GBraMVFsn0kcGYJ2p2WfG0GzOOFib7haFMWVpTWqHhuC
         pGex/CbFOt+FH9a08jmitlbjSH/NVQO1aOV2eGrPdCeIAUBJszUHqEDsFAlL7KDBC5nh
         SyOg==
X-Gm-Message-State: APjAAAWJ7GnE2QvYN93hWfFrdsq2HDr5cM6pZrzpt9w3JevGtIx6jdrt
	mYfxeOnh94Zk5OVgWFl8s63sOoWWGD4f/fYB9yMR64Hunt+Vwp6jg/mKCGqHF+DSxrlzHUHnhFC
	6+0OUvCqqJVGgfRVDUzN/YFgOUGG7VN8XjyKpP+dbb1PR+9rVQLFR2e14IubCL9aQxw==
X-Received: by 2002:a17:902:a583:: with SMTP id az3mr87099778plb.205.1555474116021;
        Tue, 16 Apr 2019 21:08:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIAoenWJcbGN8+6v/SYM/nFBceWPIm+67/HfAV1PHbPJMo4180YqtAiorov3aqgp70kV7Y
X-Received: by 2002:a17:902:a583:: with SMTP id az3mr87099727plb.205.1555474115337;
        Tue, 16 Apr 2019 21:08:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555474115; cv=none;
        d=google.com; s=arc-20160816;
        b=ptZqqM1NY+Nkdx3oREfOarGX2z88aY4rQ1aczHqful8Er7fiQdGbjPKuIF79kYB7er
         wuUvcXqguqy2/mOEwbIlTPfYOpz/rYhv7bYFPKMPR7OvRDwl6E0ZBi9fP1UtiQdOwyup
         UrZhd48rb2603AyaGHpAG1bOj7houlCEGRuV+iPgTQcRbEqzDNTk3CLSFof+T49+l/S2
         Qp19mQ94NlD0IaYVfMIhfkMF/bXRfAokS9IbvZf9xXb+EjIeNkZPbF55dd/0vCYZ7uxl
         qH89YQxyBwiyx+kUT3RDx3gB/nuyEHZrBvIeSbdyw7hYSq/SFDND1U0eKKba8LlqoELY
         RWFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Em4HpOp3QfI9scdNSfMBzQDhJV4iaM3Bd30fC2vkXHU=;
        b=CT+RBKipSPB/8DBFFaCMenU0zDO9iOzBqL7iwUk4yQGzbRBSKB4n31b/W6TCCgKTW/
         rqHy6L382kW1l80NnrjM06atqr3I4IgvG3kqtO5dd8z+oRVLCEeal4y+tBJBA7NlHJ/H
         D/HSHtcaV74JXaKdnWu9qlTCu4MUwDbmtpKMGTA2Uyj9llfpY6025Jizbvw60AFQE6pz
         g9VWKrQ0sgMw8DVGT6+dtBWeSP/Kfb+e6iCG55c7Of52XBQAHFXZgI5BiaGDIsWoxYdY
         E12y32IkLZl40oDuXP47ieSw87Ctp78VnKIF8zNTa5QhXPLnkLTaK/NNDLG+tae5djs/
         l8mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CON7p5qb;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k11si49757260pga.257.2019.04.16.21.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 21:08:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CON7p5qb;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Em4HpOp3QfI9scdNSfMBzQDhJV4iaM3Bd30fC2vkXHU=; b=CON7p5qb8+GWuIuaXABny5e1b
	78XtNR3iadVEg2rNXkBrCWv715s3AtTYJMLTdNT0QCRRdQ9fJWPSUQukE+LPNMhSr/fd10/w9l/Hv
	Wz0AxaKBh/AeKrFFkj2x+XQBZjkfhjM5PcwIXKXslLN6KOny76URhvSqY42AecAmCwEZLapoJKSgv
	sQQ45ZOYF0EGWTc/Ld4hZS8RUtZF2g6iRfTWKYYjcDEpKnjk8HRF+FkF9VvkYRZtxqji86Hy8FSOT
	VDOBV85w1wdqy2/Y2Sw9nkmwjNCMyg4hUXDTwK39ZKai6BMQFvhoilI0BHoa+dcfib0I2PptYbriB
	QVwqb5ZiQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hGbry-0002lh-TV; Wed, 17 Apr 2019 04:08:22 +0000
Date: Tue, 16 Apr 2019 21:08:22 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Kees Cook <keescook@chromium.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Biggers <ebiggers@kernel.org>, Rik van Riel <riel@surriel.com>,
	linux-crypto <linux-crypto@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH] crypto: testmgr - allocate buffers with __GFP_COMP
Message-ID: <20190417040822.GB7751@bombadil.infradead.org>
References: <20190411192607.GD225654@gmail.com>
 <20190411192827.72551-1-ebiggers@kernel.org>
 <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
 <20190415022412.GA29714@bombadil.infradead.org>
 <20190415024615.f765e7oagw26ezam@gondor.apana.org.au>
 <20190416021852.GA18616@bombadil.infradead.org>
 <CAGXu5jKaVB=bTJCBWhsxAny7-OkzXQ+8KCd5O+_-7hKcJFiqKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKaVB=bTJCBWhsxAny7-OkzXQ+8KCd5O+_-7hKcJFiqKw@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 10:14:51PM -0500, Kees Cook wrote:
> On Mon, Apr 15, 2019 at 9:18 PM Matthew Wilcox <willy@infradead.org> wrote:
> > I agree; if the crypto code is never going to try to go from the address of
> > a byte in the allocation back to the head page, then there's no need to
> > specify GFP_COMP.
> >
> > But that leaves us in the awkward situation where
> > HARDENED_USERCOPY_PAGESPAN does need to be able to figure out whether
> > 'ptr + n - 1' lies within the same allocation as ptr.  Without using
> > a compound page, there's no indication in the VM structures that these
> > two pages were allocated as part of the same allocation.
> >
> > We could force all multi-page allocations to be compound pages if
> > HARDENED_USERCOPY_PAGESPAN is enabled, but I worry that could break
> > something.  We could make it catch fewer problems by succeeding if the
> > page is not compound.  I don't know, these all seem like bad choices
> > to me.
> 
> If GFP_COMP is _not_ the correct signal about adjacent pages being
> part of the same allocation, then I agree: we need to drop this check
> entirely from PAGESPAN. Is there anything else that indicates this
> property? (Or where might we be able to store that info?)

As far as I know, the page allocator does not store size information
anywhere, unless you use GFP_COMP.  That's why you have to pass
the 'order' to free_pages() and __free_pages().  It's also why
alloc_pages_exact() works (follow all the way into split_page()).

> There are other pagespan checks, though, so those could stay. But I'd
> really love to gain page allocator allocation size checking ...

I think that's a great idea, but I'm not sure how you'll be able to
do that.

