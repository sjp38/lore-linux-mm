Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6A34C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 16:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 791262087C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 16:17:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YTMLQb4x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 791262087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 404546B0007; Sat,  3 Aug 2019 12:17:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B5326B0008; Sat,  3 Aug 2019 12:17:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A4BC6B000C; Sat,  3 Aug 2019 12:17:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9F1F6B0007
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 12:17:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 6so50345946pfz.10
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 09:17:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/X3WDI0mWhLkrrAZYpOBF14jsWJC/LWwN2nM68m2FXE=;
        b=q2Y01GK/ZVDyryWGcMkQygXk3erumgJIt5RQwjcBXrYEuk5UqsHySfIGltpc74Y4BE
         tQ/si0eQzC5kyA3iz7GRt10L0hHPk2wa4tDZI2asxhD3o7yp3Jg3K1DfOWzMWw9AyYt9
         wYu4FhbscT3QFONDYXoOuEGveIEkC++abg70qJlSF1LjAm+hELMPdsxVtrJN8d+sNA7E
         lqb078KLTLAYgi/FAL/UjsLkhL+Ki1DBGD63ZNipoSTHtbRHdKaUD6mXUemfCWy/q0fZ
         V8WbYBxMGJ9kjxsXKXI9Ac1Pu4P2iWOWqGFOkVoUI6korHhBdS8u/lHdAMJLK9Wv2YI3
         uj2A==
X-Gm-Message-State: APjAAAXVzATMKLfNeilazm1hwc7riMYn5Y80cSJpgf0WLAeeaW5FhUv4
	jisJhnZUdFaNcYhjJ/C6ySsfOnd6PSUbKkmut2ix64N5Eq2SuTRoII9WgAD24TUwQgu4kQ7louC
	B9Y//hrYboNS8qYdhnPyYOxry0BUIBci9JVuEuX2r5acn/sF4xrC/iEQst5MbMdvGmQ==
X-Received: by 2002:a17:90a:bd8c:: with SMTP id z12mr10072738pjr.60.1564849069420;
        Sat, 03 Aug 2019 09:17:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIexQR8KFuKicyntxDbgn7arElHcwzBF8LAhz+BwhozyyEVubkYy4d69xbZwft8/sWBGV9
X-Received: by 2002:a17:90a:bd8c:: with SMTP id z12mr10072695pjr.60.1564849068723;
        Sat, 03 Aug 2019 09:17:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564849068; cv=none;
        d=google.com; s=arc-20160816;
        b=TuoUUymKddqyHA0RpG9hLhwwz3mmvQlZ1isswIY8Q0hbqc5Q6IScu3qZrPHE9fZFcj
         qtXNj6iqXug9hH6+CeS/Sg46gEqACvB/yDMxDnpFGG7iZGLic5xdjtCHsbhYqMd9ZyRb
         vOHidFGZkZ1FEpmUFDzNup8Wpwz5r0L3zvr8oLMMjNzrHRvpg05gAEdIqwbyq7zNXroV
         QwGfIS9V7EMdIEBQzxofVN5KEd6kNeYJiCGLNGuT+psv86muk5r3BCvJdASbWcZo9qVW
         B0Fj9KfWQIsH7wzETZ3s5bSF7Sjhl3wzr+FEMiVTzq/2XzIQ3ZQyQnTelGXLOMsDkIGj
         zAKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/X3WDI0mWhLkrrAZYpOBF14jsWJC/LWwN2nM68m2FXE=;
        b=Z8pLN3ignzu8CI0JRwAGZy4ySU+wzjRBQbZOKQPMvb21FTxAkDGUGSvgvL70eXs5ep
         eRbF3RAXclw7p6JjbjkQCKpRfPtApJI03bXv6brrg1EV5bEXfFTkB13vueciBtL6Oxoa
         mihOw0DbQg3f0NDflBHZbokA4xManIsqYBKiMtRmEFjPSdGzhPUY7CW87B5N1Obf3rkR
         XY4+gUxuX3w1/0FS8aU7wFXp7Vw2T+cny2ozqvo9jNBbGlB+Jyb0/3umA2J4Uffr3dO3
         UMGmCapdG4hMktq5lEomZ/gJfjYt8QKjdLUAkDL39Qv4G65qH3/KWiwmTpdRA9T2wF3V
         +WFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YTMLQb4x;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 78si39946109pfz.268.2019.08.03.09.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 03 Aug 2019 09:17:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YTMLQb4x;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/X3WDI0mWhLkrrAZYpOBF14jsWJC/LWwN2nM68m2FXE=; b=YTMLQb4x9LXJC64dxUjr6v4Xk
	GMXQsTaDR1vmYROgRuPGQmcgEYe76/aACMQQWCtkZimsYaMoot1ZvwPQDm2Ihc2qq7OidsOSLkgi5
	5h4VKxOmA9p2bsT/wyW0eiE02ATnGIGZFQZ1DcJKqPFLLhndN++tne2fJkGXmLxkZ5sdM7ADQfEHj
	ZUnzIYOL2jqDrOkrkXILUmtHBpDlM7HqH5QWkJ6gkEmQSJSg1PFxAP5KxYT78scR0A+zv9wLYi74s
	ucUhUJiJLtSFE9BZiIREAP1CItRqGkb5o5/6a4VXeKUPosSTon4rRzJYDNgxMmGjhEAcUMcDZEnKr
	HD/miYdsw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htwj1-0007V1-Ge; Sat, 03 Aug 2019 16:17:43 +0000
Date: Sat, 3 Aug 2019 09:17:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-ID: <20190803161743.GB932@bombadil.infradead.org>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-3-tj@kernel.org>
 <20190803153908.GA932@bombadil.infradead.org>
 <20190803155349.GD136335@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190803155349.GD136335@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 03, 2019 at 08:53:49AM -0700, Tejun Heo wrote:
> Hey, Matthew.
> 
> On Sat, Aug 03, 2019 at 08:39:08AM -0700, Matthew Wilcox wrote:
> > On Sat, Aug 03, 2019 at 07:01:53AM -0700, Tejun Heo wrote:
> > > There currently is no way to universally identify and lookup a bdi
> > > without holding a reference and pointer to it.  This patch adds an
> > > non-recycling bdi->id and implements bdi_get_by_id() which looks up
> > > bdis by their ids.  This will be used by memcg foreign inode flushing.
> > > 
> > > I left bdi_list alone for simplicity and because while rb_tree does
> > > support rcu assignment it doesn't seem to guarantee lossless walk when
> > > walk is racing aginst tree rebalance operations.
> > 
> > This would seem like the perfect use for an allocating xarray.  That
> > does guarantee lossless walk under the RCU lock.  You could get rid of the
> > bdi_list too.
> 
> It definitely came to mind but there's a bunch of downsides to
> recycling IDs or using radix tree for non-compacting allocations.

Ah, I wasn't sure what would happen if you recycled an ID.  I agree, the
radix tree is pretty horrid for monotonically increasing IDs.  I'm still
working on the maple tree to replace it, but that's going slower than
I would like, so I can't in good conscience ask you to wait for it to
be ready.

