Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D051C76191
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 00:38:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4240F22C7E
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 00:38:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="seLQcuWQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4240F22C7E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C57556B0003; Fri, 26 Jul 2019 20:38:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C087C8E0003; Fri, 26 Jul 2019 20:38:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD1098E0002; Fri, 26 Jul 2019 20:38:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3786B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 20:38:55 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so34279526pfd.3
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 17:38:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vX3HX++H8FmKlfKaZ9xE3OKPlAYHgui3BNbzlA6WfOg=;
        b=KuQ3jmYdHFT5dn94V/rxtGXMgxjY4UvClAEWAO71CPbKY25faqLaXMaMi/bDs1KN/4
         87yU1huNXAt7prrmUIeKB1/WyvJJ47AdcPnOlByE60krDzgsp55qL3vGUKR26UNiwEHi
         LtrC6KlothUYCbXkpR9Nc4TxOOgsrsL10d5V7fVK3/C4sC0BHS0cRX5u2US9mXk3JBp9
         w3s5IVPJ7jmBSUGmehrTsh9hpLUipz6SsfSfC3RQsW0PypUPZHd5ajj0haeRCKjLmdF4
         ahIS+IYzK5igJcOzmLe+5Lotns4Swb4nl/9iNvXzIZZChwwT+30qX5djwyuH5kI2tc/1
         ZQrQ==
X-Gm-Message-State: APjAAAUSG0lepeS7T4aqIPvSu4qThMGZ42iO/2iDBj+YyRurhKrL23Q2
	xCQFraO/GWHkN9vmZmqn0FMnJIL3BLN5qIXWClw04c0vuw99db6qnrzG/Ok4MUn3OFATRQU4T0G
	QgQIKF1i0TM8Yf1MpgZKoCpkMGJa7xfdEn84PvRMTN7kwNmxqhOU6JaTpeZ24JLc9fQ==
X-Received: by 2002:a17:902:381:: with SMTP id d1mr96782396pld.331.1564187935114;
        Fri, 26 Jul 2019 17:38:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyASNMt/nLl4JUPw4zZ5V0D7ylrWVyimFVeSvQOCZpbpOgWxXpqwtmxLCN0ODcuM/jbsHDg
X-Received: by 2002:a17:902:381:: with SMTP id d1mr96782360pld.331.1564187934435;
        Fri, 26 Jul 2019 17:38:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564187934; cv=none;
        d=google.com; s=arc-20160816;
        b=fV0fvDklggifp70Kwr6xbMKGsuSUsVTTf2gRYoSfjuoKjZHL23kiveNEbvXR5yNCZR
         J6qG2DPhr1iUsP/rdCctfru2WiUyA5vDfSeGhXXKCvowPR/RFP6JgM6NSKW6dNVVcNJU
         IhyBA1rsrAAylf4B36qWIieCfIT6HrngeR8K9doD/qqv0B5d8pZDPs8g/cI+srdH3pPk
         yId2N/rPJC0p1vHkxM2rA/0GSOl1QTYHDns+aFDZg87hIBj9kFM5etBWb3g46JIEuIic
         c3eYP755TVFVLk6A42ZLqnGzUj9MVVr8svscm8LroqIDaN2uy6W/MlAEs/H1Jo96VzBF
         +LQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vX3HX++H8FmKlfKaZ9xE3OKPlAYHgui3BNbzlA6WfOg=;
        b=zieqGv1TIJKdZQ5czN+XBiqrYkslIFVrfuy38K1sI0uDtl6bHP8SyKFzOWTQqtMpo5
         +XivPVPmpP7+fYkJfhu6i280PgZwJrFIF31G130Y8OmQY4c9T1IuyM+soEOjO6q6OVnv
         ubq4VWZ39bMvfg0XBByLXjoezfSvwYQui694wa3jqBy+j8GV5QaC7YJVR7BsdLcLy5CE
         LUy3gZhT7P7plbXG9PiJ2wjdaYIDL0rqMLIX8tvdJ76DNeNUPHlBYpqWP0qmX8CGOG6u
         UJ8Uze6H1v134XGlTg5thgThQw2yDXOKfV4K6Te6BsIN9STFgXcaVu93U3KdrbHr5BhR
         H5sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=seLQcuWQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id br15si19593520pjb.13.2019.07.26.17.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 17:38:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=seLQcuWQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=vX3HX++H8FmKlfKaZ9xE3OKPlAYHgui3BNbzlA6WfOg=; b=seLQcuWQ9l+ahJ/jJ2TW3xmNh
	8Fd8u4bC+a2yPgf1X9h7DGdfz5aKukAwbQ56fEWeWFKaQX5/debmR9XWEoLpFFpNDpl9+sH0joFjQ
	JnacKLuSYm1Sg7A6gpvQYt6mK/aPakD1pHE/JlEp1zNtGDotoemVv3jHEX+NsYwmUKwth+cAUcTf3
	zOs8gNyo88rzJacIINOX4ZKDI+WyAEVwm+mE+5JRGRmjU+CFfSfTMl+mHFMzQp7Cw8+FreQcZz8AX
	4S4B6nECv/VkG2VAjx9OuCPO6Us+aG7MLIWXfT2aeTf2Ml+k9vwu7UR2hZB3A6zcEmoT5g0jDFkDp
	TUiPBSwDQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hrAjb-0007V1-Ak; Sat, 27 Jul 2019 00:38:51 +0000
Date: Fri, 26 Jul 2019 17:38:51 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Henriques <lhenriques@suse.com>,
	Christoph Hellwig <hch@lst.de>,
	Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH] mm: Make kvfree safe to call
Message-ID: <20190727003851.GJ30641@bombadil.infradead.org>
References: <20190726210137.23395-1-willy@infradead.org>
 <CAKgT0UcMND12oZ1869howDjcbvRj+KwabaMuRk8bmLZPWbJWcg@mail.gmail.com>
 <e4b0d323ed0bc159d863945251cf3f4c4064526c.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e4b0d323ed0bc159d863945251cf3f4c4064526c.camel@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 05:25:03PM -0400, Jeff Layton wrote:
> On Fri, 2019-07-26 at 14:10 -0700, Alexander Duyck wrote:
> > On Fri, Jul 26, 2019 at 2:01 PM Matthew Wilcox <willy@infradead.org> wrote:
> > > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> > > 
> > > Since vfree() can sleep, calling kvfree() from contexts where sleeping
> > > is not permitted (eg holding a spinlock) is a bit of a lottery whether
> > > it'll work.  Introduce kvfree_safe() for situations where we know we can
> > > sleep, but make kvfree() safe by default.
> > > 
> > > Reported-by: Jeff Layton <jlayton@kernel.org>
> > > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > > Cc: Luis Henriques <lhenriques@suse.com>
> > > Cc: Christoph Hellwig <hch@lst.de>
> > > Cc: Carlos Maiolino <cmaiolino@redhat.com>
> > > Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> > 
> > So you say you are adding kvfree_safe() in the patch description, but
> > it looks like you are introducing kvfree_fast() below. Did something
> > change and the patch description wasn't updated, or is this just the
> > wrong description for this patch?

Oops, bad description.  Thanks, I'll fix it for v2.

> > > +/**
> > > + * kvfree_fast() - Free memory.
> > > + * @addr: Pointer to allocated memory.
> > > + *
> > > + * kvfree_fast frees memory allocated by any of vmalloc(), kmalloc() or
> > > + * kvmalloc().  It is slightly more efficient to use kfree() or vfree() if
> > > + * you are certain that you know which one to use.
> > > + *
> > > + * Context: Either preemptible task context or not-NMI interrupt.  Must not
> > > + * hold a spinlock as it can sleep.
> > > + */
> > > +void kvfree_fast(const void *addr)
> > > +{
> > > +       might_sleep();
> > > +
> 
>     might_sleep_if(!in_interrupt());
> 
> That's what vfree does anyway, so we might as well exempt the case where
> you are.

True, but if we are in interrupt, then we may as well call kvfree() since
it'll do the same thing, and this way the rules are clearer.

> > > +       if (is_vmalloc_addr(addr))
> > > +               vfree(addr);
> > > +       else
> > > +               kfree(addr);
> > > +}
> > > +EXPORT_SYMBOL(kvfree_fast);
> > > +
> 
> That said -- is this really useful?
> 
> The only way to know that this is safe is to know what sort of
> allocation it is, and in that case you can just call kfree or vfree as
> appropriate.

It's safe if you know you're not holding any spinlocks, for example ...

