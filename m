Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81826C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:11:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37C6920866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:11:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HVzDiOF7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37C6920866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F39626B0269; Wed, 12 Jun 2019 08:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0FC86B026C; Wed, 12 Jun 2019 08:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD7586B026D; Wed, 12 Jun 2019 08:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5BD56B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:11:26 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so9682033pla.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FtzE4Thitu+oCRZIQWiIw67zmtUw4+rU6GSw0OsJqek=;
        b=b2RsN+PXR5de8AbmRBrjNIzeDLfdzjDtUMW59rgIi3kbMgU/7kCd9DKZT4Ucp1w0bg
         mYuBKlulHnAPgEtBJ24gRsy1k/W3pZ7F3tVQ3rXK7rLMbkFqgOzMLfQb4dTgc6ekwU8X
         VZ8aTJh3+xAvXbgU00uOaZT3OyKXIP3VFi1MQrCgvTz7k2e527i/TVBgqKFOfoGY/nos
         4hkPw5w8oEVrUB8zzJ6jBmHqBDzfunqV+HKyWhwkuBEiz5FJ/gpUQcQgy8I0rOzkc6f8
         gsW3ZD1sN8fHHbqLqqHX2KPVfgK3QIn0IZ4rJG3UYJI5zIq77w0LYQiG+VVMDbUN4gKM
         wsPQ==
X-Gm-Message-State: APjAAAX8X1iTeZu6NGaSyZCl3KmqhTy069jafpddbOgrDtBxsMYExPWf
	gJhlthLqfkLnzy142a0WF6AZAwYccKxtNXxp/35azmfa4RBjexvH6IQxFtVa4F0J9UOin6+a+1x
	4K13FACz+XKaiTq0nh7FHNSAkwW5yqGjJLS9qTxjGR/CxX/2hpd0MokmdPUCEwCtrNw==
X-Received: by 2002:a65:620a:: with SMTP id d10mr24993521pgv.42.1560341486038;
        Wed, 12 Jun 2019 05:11:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaFYpVbTecv8f0LRGtL0hngvNfh0t/16Uz78p29wTjB5nuv9lplyvSdFjLQeix4PS7Uacx
X-Received: by 2002:a65:620a:: with SMTP id d10mr24993467pgv.42.1560341485166;
        Wed, 12 Jun 2019 05:11:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560341485; cv=none;
        d=google.com; s=arc-20160816;
        b=SZuu3o2BheNHAkwDy7TQlHhsAqjpDcjly9FqTmzdeNdHIcXlbTXhRIXvdwW4Bpsx2o
         bNhApx0knLssasNFy7uts1FfAcYuvvSruK7zLqeKTwSYjivlHjf9abAtNp59bxONZpRb
         7oLGyd0ClJlDUr4OBTTJaBtJy6iT4fBb7c/oYlnRv3fBY7+ye10xFA3I7RzRS1Db9Wx6
         QdNIJNhHrWVrNTghh7Z//dxm5x/RDC1dJvPRGjMuIQZFKH/hVcFkqHeDw8EeB0dolI7f
         uLowV3rRaQk+hc+GRl7kBAo4j7aITKUOv9KZozOzmbiAbZE2LmUdPNcqyZdnZN2qa8GY
         BFew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FtzE4Thitu+oCRZIQWiIw67zmtUw4+rU6GSw0OsJqek=;
        b=AgmVwYc+z4M/xvF7cEfYjys504znrlGm6Jnyz5Smn4q7yzS+ur3vud6kSsw4Xjg6ti
         2hUuXFW+ael9WIrMy4t6QpsFio10ymoxXZfqMrULza6/GU/UwD/8Q/XBi3G+1T5NKWB8
         D1S80qaiStla1u+LGbLhFVoCHSCGhvveCOkMXJDv2WhM1cReEc6vFHh54G3I8FfayDqZ
         rDfYWSbEcZ6yWIWPou2f/OPUSK+hERVmR2EIlKNqRS18VBOnZjplmXoBZr7NJg/zmFBv
         lDw/i9ywlJ/wFAlQIEP97FtFqWsn0vXW82k+Nwu8F9NeLTga0qkxrx+c4ccK4fLayh5/
         EWog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HVzDiOF7;
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 195si14780117pgb.327.2019.06.12.05.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 05:11:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HVzDiOF7;
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FtzE4Thitu+oCRZIQWiIw67zmtUw4+rU6GSw0OsJqek=; b=HVzDiOF7tENNW0oMxkkgJMas1
	A3Yn5kiw+tQwG9J5FUng0C7nSST4hyp8v3p18AHc5XwjtR6rAoFHNODTRx/v2fZRrLZlSdXubpHkO
	/yf6f47UsoARpMNaJna9cWEs6OSWNZDLcZhimsZOXGr3+tvZi0GfJTJ669IDU4/XmTMbwDPZkDLos
	LkW4qzLloWsxOYO77T/vfAsa9XmXmdlVIVcnfe/mZHLEYOok7gUbzJbkQhuYCWV6f2BXLYvXNJByE
	49az5xb9jJu4yw8HZj1I9aQBcwOdxtzvM/r1F0DMIfJCPxSuOTX6jM1XJNcjnvOhbZVMk4d/cCXtK
	lQGR+DnYw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hb264-0008NQ-37; Wed, 12 Jun 2019 12:11:20 +0000
Date: Wed, 12 Jun 2019 05:11:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190612121120.GA24966@infradead.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
 <20190608085425.GB32185@infradead.org>
 <20190611194431.GC29375@ziepe.ca>
 <20190612071234.GA20306@infradead.org>
 <20190612114125.GA3876@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612114125.GA3876@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 08:41:25AM -0300, Jason Gunthorpe wrote:
> > I like the idea.  A few nitpicks: Can we avoid having to store the
> > mm in struct mmu_notifier? I think we could just easily pass it as a
> > parameter to the helpers.
> 
> Yes, but I think any driver that needs to use this API will have to
> hold the 'struct mm_struct' and the 'struct mmu_notifier' together (ie
> ODP does this in ib_ucontext_per_mm), so if we put it in the notifier
> then it is trivially available everwhere it is needed, and the
> mmu_notifier code takes care of the lifetime for the driver.

True.  Well, maybe keep it for now at least.

> The entire purpose of the invlock is to avoid getting the write lock
> on mmap_sem as a fast path - if the driver wishes to use mmap_sem
> locking only then it should just do so directly and forget about the
> invlock.

May worry here is that there migh be cases where the driver needs
to expedite the action, in which case jumping straight to the write
lock.  But again we can probably skip this for now and see if it really
ends up being needed.

