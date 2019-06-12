Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C06C1C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80F28205ED
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:12:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LZFWfvDw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80F28205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 198E26B0003; Wed, 12 Jun 2019 03:12:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14A766B0005; Wed, 12 Jun 2019 03:12:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 038636B0006; Wed, 12 Jun 2019 03:12:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0F276B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:12:40 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d19so9309423pls.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 00:12:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gHyPffJSXLCM57JngMARDMldvmmJZW1qdq4MDpyHoRk=;
        b=ufPwcq5vURcU+rpvz0i5ESlba/kJw1tOtwwP9vu/Y/imZ+Im6/hHzdlE7GMR601sR3
         XzxT4cG8GCIz9OQKohzI1QWLempy0vKDiYcyLKf4U9aohSJQjuvVS/aMdQdc0esBchFx
         evZzUpC5JbfoeDtWCW0+QoUjCifK/YtGbobWwehlyddrqIXCa+FzegiTBiCpILJ1Fwh6
         D2rCqUz90rneeXt/kuBgQV9jHdpj2u42Q0Urw2cmOLb2hwnWyKO/+HWnFUOu3wkm2JIX
         lijwDXCHsZnJGpv69BViTovLnbov8Kb8dUCqw42v6fqDJjB5BWJcwP/8c7to+RbaTs/B
         eS9Q==
X-Gm-Message-State: APjAAAXccibJGTHacSg7PDG9fx7wzz9c66IklgX5OkbHMbzw0iinhiH1
	zOmj4byTDZOD/auxDo7wVCaJloGzOHipU5LM7uQ/iI6z1EEOLakvQDONCylQvmHMfKoZj+OI/vr
	dExz1LN6/9V9tVUM6epIUHcXGJoI5BbJTtg6zV00LYv1iUqR+p8vBTpaqXSDcsG9I6Q==
X-Received: by 2002:aa7:8e50:: with SMTP id d16mr77402412pfr.65.1560323560377;
        Wed, 12 Jun 2019 00:12:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrd+ci4f4K2FrKI6mIfaEB7irnMMCMWUd8J6nNTAEFm7lQEyucm4pmUA2UFXWTLdtIS6tK
X-Received: by 2002:aa7:8e50:: with SMTP id d16mr77402343pfr.65.1560323559400;
        Wed, 12 Jun 2019 00:12:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560323559; cv=none;
        d=google.com; s=arc-20160816;
        b=GrWcsWhZmK6AInwUjA28JiQIgCAzXNq90bjqv8mY4Be65ykDDQWb9sOmETxjRAx7nE
         hM7sWeVZ31J7zdC1tNjQQGdKO+bOkbb5ITVlhxz2KTVnkrGMRmYJdCUifMKffvzYaNwT
         HR1SjDeVL1RuI5PYqIdpatwJbL1Mn9kaiVNck8UIM5l56mu84/2VT7GBxAjrn4jVwLLX
         mOJQs+59wL7//z8WnHq5JOVYmf4GUqcn2Uk/+/ydEUHKoOBODnE5BBY39PW1pvZDRVSr
         Gv7REVWbVN40vRqzlCyRf/ZVs+VNA/T358S5t313SHg2Gh8RW3QvdXvGyk1z8KTJJ+di
         Fu9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gHyPffJSXLCM57JngMARDMldvmmJZW1qdq4MDpyHoRk=;
        b=v6L6yRfv76ZZMnNOeuV4/ug0Xe6AKqVIwpQwLSL5MZ/LRXiFlw//FpAcspsbeYGJQG
         3HeHFbHrwfq0HbaIVv9h7zjVCxRVc8bxSAOR3zRVY5Aq54KUJkC3u29kj7Hefn2fIszs
         3gpNjpgT/WXOA9KAtLxNceZHn9uWjreqm2qtMxYxHB+oxM6bjw2CVjRIV0u/q0YTpoLy
         KCYUKG9RrqJWy5bS8Tl9blsdwZj4Q/sD5zCgE0+ZF0qPXGj3HPIKbhE98qAMNMHt8fxK
         n19E3k/ljFG60gP7aaeVlYavDtQKLuta/eZ5UW/4Tl9vW+wrvhMARL4v+P0TQuA9teis
         fFbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LZFWfvDw;
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w188si3496185pfd.283.2019.06.12.00.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 00:12:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LZFWfvDw;
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=gHyPffJSXLCM57JngMARDMldvmmJZW1qdq4MDpyHoRk=; b=LZFWfvDwFrroFnYyekMIs/UyE
	bnMyL5wiF6a4qOXH5Y6D53f6fcxweVVJulxgbYu1K/IdrKLLafhSvY4xRz/tsyEb1jMuRSPbF8Rnl
	2jgdlWDjFI2AFrwtJTWCwY7ypwwqq20Wfwdyjg6YBYwVPLrqZcVIAuIDcFv3wcwesz87rKWLcwF6Q
	uIyxuROlw9E3tQxn18S6MXz8HOLuV0akpHIPz5eAdK34NQGGATa54Jl7DFM8Z4t77COuq4Y8dcdsL
	IybD7Zm7ngdxABfUQaFBZFD1S2V2tOJ6I6k+Q28wmxvewZONusKYFagqQ8kY+0GS9kfk6C3OEwpSE
	VocdDksgg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1haxQw-0000fi-5q; Wed, 12 Jun 2019 07:12:34 +0000
Date: Wed, 12 Jun 2019 00:12:34 -0700
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
Message-ID: <20190612071234.GA20306@infradead.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
 <20190608085425.GB32185@infradead.org>
 <20190611194431.GC29375@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611194431.GC29375@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:44:31PM -0300, Jason Gunthorpe wrote:
> On Sat, Jun 08, 2019 at 01:54:25AM -0700, Christoph Hellwig wrote:
> > FYI, I very much disagree with the direction this is moving.
> > 
> > struct hmm_mirror literally is a trivial duplication of the
> > mmu_notifiers.  All these drivers should just use the mmu_notifiers
> > directly for the mirroring part instead of building a thing wrapper
> > that adds nothing but helping to manage the lifetime of struct hmm,
> > which shouldn't exist to start with.
> 
> Christoph: What do you think about this sketch below?
> 
> It would replace the hmm_range/mirror/etc with a different way to
> build the same locking scheme using some optional helpers linked to
> the mmu notifier?
> 
> (just a sketch, still needs a lot more thinking)

I like the idea.  A few nitpicks:  Can we avoid having to store
the mm in struct mmu_notifier?  I think we could just easily pass
it as a parameter to the helpers.  The write lock case of
mm_invlock_start_write_and_lock is probably worth factoring into
separate helper? I can see cases where drivers want to just use
it directly if they need to force getting the lock without the chance
of a long wait.

