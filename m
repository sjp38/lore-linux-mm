Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7302C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:52:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F93A215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:52:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nvZjGRpp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F93A215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02DFE6B0008; Wed, 12 Jun 2019 13:52:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F20A46B000A; Wed, 12 Jun 2019 13:52:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E36A86B000D; Wed, 12 Jun 2019 13:52:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B01756B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:52:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so11237263pfc.2
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:52:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=JMNn8UaGTOpyvj+ruZQU6xAEQkuuPXT/CSFoXKWYSTg=;
        b=Gd1ObFHhb15d6HonQfYDFP5ocoUiFO59kZbfJ9f6ESBWR/6rMuizSRyvUNQNuKMe7J
         3ZIEI9/DGq+nUaPtyqFHrWq3SH+Hrvbi6JHpSTb8nouy2pX+wgb+oS38X7HbXN7PNSo+
         9TbNuphCs9rpdTdJ/Vmt+4KzMM0DL1efIFdvnz5p2o4JOhQWZb4PDuEH/yzeSKGzNc7w
         BN8GIaJSkQdhIjKN1MjGt4rznjSPkc6hmrC2EgrxUir6RwiFN+4ELpcTe2LI5DnL+0RQ
         50IN8Wcojk7hSnlx8RPx7DJoRfICfMxHQMJlpsMHGtzvNSN5SDrH36S6662DgMQ0ZAXI
         C6Cw==
X-Gm-Message-State: APjAAAX3tmQ0OLcFJAaZoEtgBcsxaCooYWDekC1EAQl9oAO3J6f0+lTk
	YUV5ITg1LXlKAmheYTJ15QYlsr1+t3WikDCTk3nQSjpX9drrGvqWk4t5FBNdoj0vxYuQ+uJn/qR
	sufha+ke9jORaSFcejov4tVCoG10bwKhQuMuHFXhX1OXgVVPX33pba4J6TLPbrl3/5Q==
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr52345432plb.341.1560361922363;
        Wed, 12 Jun 2019 10:52:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylm+HgQpO3DWKno4Kvyvo4Lc9TIP3tylkDsfPySi9QtgEHyXuxWXe59LSx0H1ODunuHlU4
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr52345375plb.341.1560361921724;
        Wed, 12 Jun 2019 10:52:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560361921; cv=none;
        d=google.com; s=arc-20160816;
        b=bwvBfWG03rsTgh08zVzY/1LAhjQxPJMMeU0aKvrSkUeoiNzW3V2WqjYm16Q0w0NlqP
         mRZuDWC9DGlzp8l9hD8x+wZ+rugHXKevyN++xe14u87r7ppJuMit83/HyfDDm6bQEHID
         XUFycrt1w17J5CSG6wAPAZhguvv8i84jpgu3GKq1UMC3vzSrGxI20Lj2AWbHCIP6t6xp
         FtWUlC5z2x8CEP8AsL8GgIlQvMUtyrZ+qmQ2gKEXUQOW3hX4Mx/HC3fXBWqTHomw5jQ9
         1MigOSy3c+x7pAVWm8JsBdKmZxFMCbU8FMvBIkoEqDmqrYQRSbEEPmVSJFJeppjY2+Ee
         QOKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=JMNn8UaGTOpyvj+ruZQU6xAEQkuuPXT/CSFoXKWYSTg=;
        b=izEeRlgZQYpIWUgJsdkDVERM+td/YKToXQGhXB5ntgIB4FDS6vYGh5LhroRMTyZqog
         5gpsMmj30FRrFiW2NVEMJ4I3sOrBpQFCTkZrzdyMx0BmJozKk/u0qWv9zQpKSDrcS3ov
         H9nzUo1HH25U2kgezrYPSU/Pdmr5/wYi+8eJ5BwxSowKXcYlwqG1yN2xFi2JEJ+zUuRQ
         BGoHBNeo9DKVJLxoti0H1NatJ1wsQ/TBQLWVE7NjDMQow9rVeRusOExy2+neHTNY1EHP
         Sh7p0wQcoiKKUnGovTWn3bpnVP0nWYDaLZhNPfVlXK3ipYJ36rC+LIfaqie/0m7HNeFw
         +iow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nvZjGRpp;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x6si376677pfo.246.2019.06.12.10.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 10:52:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nvZjGRpp;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=JMNn8UaGTOpyvj+ruZQU6xAEQkuuPXT/CSFoXKWYSTg=; b=nvZjGRppi4S3cpkBc8m3JTdjYT
	FWvUaQjWBjaIvXGpfqmjKo+Q9hH5l0xcbBIV/CXd3TSGC61MPcEwsYCZsFfFXOuakydSmKugeufPf
	JNZaEvrbxhA/Z266bAXOLvQHdSveVg/oracJB21QFYlYZ/I+9z0DfQDjNc95GsKWzwE15QpwT5Kd7
	AmPiGw0s7bcI9sIYy5/s4A0h8bIilnzuUL1j0jXG/uJf27lvXKDtN8c1Y0lNyI/thm2y9JLKuR7KI
	aXpFuM+DYb8bDPtreaoucaSo64FMPAW4x2PsGTaKbEGv0eYRaqAeuJd73+Mr8atVnNZc1vEvsnkDw
	srPlKzPg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hb7Pj-0002AT-Un; Wed, 12 Jun 2019 17:51:59 +0000
Date: Wed, 12 Jun 2019 10:51:59 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: gorcunov@gmail.com, linux-mm@kvack.org,
	Laurent Dufour <ldufour@linux.ibm.com>,
	linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [RFC PATCH] binfmt_elf: Protect mm_struct access with mmap_sem
Message-ID: <20190612175159.GF32656@bombadil.infradead.org>
References: <20190612142811.24894-1-mkoutny@suse.com>
 <20190612170034.GE32656@bombadil.infradead.org>
 <20190612172914.GC9638@blackbody.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612172914.GC9638@blackbody.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 07:29:15PM +0200, Michal Koutný wrote:
> On Wed, Jun 12, 2019 at 10:00:34AM -0700, Matthew Wilcox <willy@infradead.org> wrote:
> > On Wed, Jun 12, 2019 at 04:28:11PM +0200, Michal Koutný wrote:
> > > -	/* N.B. passed_fileno might not be initialized? */
> > > +
> > 
> > Why did you delete this comment?
> The variable got removed in
>     d20894a23708 ("Remove a.out interpreter support in ELF loader")
> so it is not relevant anymore.

Better put that in the changelog for v2 then.  or even make it a
separate patch.

