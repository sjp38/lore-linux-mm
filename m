Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C666CC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:39:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8164B20880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:39:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lkbaa7lY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8164B20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 182576B0003; Wed,  7 Aug 2019 02:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1323D6B0006; Wed,  7 Aug 2019 02:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3BEB6B0007; Wed,  7 Aug 2019 02:39:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA0DF6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:39:06 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q11so50033830pll.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YjFjhTuT30+WR+0Rz31alBwUHp7i7H4qDnAY2b1b5AI=;
        b=bt3LaQFHOZS/aKy+b9tSDP4/cmJpgAkgYqTINRhzDNHaEUbdZ9W71TbgkbITQPNGKt
         kDYCw1WcP3BhxFAwDMc6cfRNW+NZyFYjfOc4Bq2yyW99qIEgYvL/sRI++dldbWNXLp6L
         nspojpf4yG13BZVPl0KO3CRSQtTFLobByIR0lABjhsyITcsSDKr+xsVncLzw1/2yLu2i
         9rCIcMtfL8fp0ih76AyF9SITpWrP96VSGIiIX8pMOHrb1eqBz+q4rZSYXBEi/RAx7yQF
         ptBgi3ttmZ+4fuQnWHyZDFlCfIPQ9L81W55a8n0hQrjpi4Qbopf6KFuNoQFQyC4BH8+I
         VfSA==
X-Gm-Message-State: APjAAAUN6PBfAkEMgOWHSgjTfN9xwaG4O/vTzh7V20pcplQ4CWaC4re4
	F3qJ6YMkoXcIOt8pinAxOowI3GyGXWZbMgvBWrAsWWOE5nUIRxozvk+uc35Fwl389BIP9Trln3e
	ubTv8NTPOtjmeSEn0sbTKkzhLO6a53ogPwrjfqrsTA0scIhK+LWs0b7dwKMQQm6jXkA==
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr6912009pln.216.1565159946378;
        Tue, 06 Aug 2019 23:39:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx50rqzn3twVn4m/Lt56+jn3UfjsOFdLQavdo56KCG50CJxKzetZ7AuKtSfz9x7RvnsYHhM
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr6911955pln.216.1565159945560;
        Tue, 06 Aug 2019 23:39:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565159945; cv=none;
        d=google.com; s=arc-20160816;
        b=ECzr8aDCJhOJ9nDJBdPPsVmPR1mnAk29QwPNJrrYCl8OQsUUu9T5hQPoYtVW26N3lz
         oFQM231WfhzR7S3I8StmfHCIOOKX0v3VGjLO4Jl5wEOxI9RW3ORoYOp7Q0tNTVoto/wl
         MSwat15WoBIfQUI+mkt7xsCky0vWZuIiRzETeK4B4MEtYLQpsWlDhCUbXGcWLbk8Sq2N
         +IhV5JmGiuta4a8xkVZzfES/tlRyzog/4MyxNP5A4jCicQzmDSdqf84YPuTIuoEdRtJS
         Vq3Q/wZUdTaovWbSxqV7idK9jPDlRLOOCR3fKa50nVf9zYBvOowj6b7jepv0GkzzEpVY
         SfCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YjFjhTuT30+WR+0Rz31alBwUHp7i7H4qDnAY2b1b5AI=;
        b=fV3RKSiSpxUhTvhdRhCheRdASbn9qc2IwZgONx5HZj7ozboMqJrCt4haLDkP1jjXF0
         nDKsNIOp8GKuIXMyKs0rqUzgukacGWV5E//2hdSZHc2ZlYtkvXcULkgqK+7G9g4ZUa7E
         00UpAHwWygtPQFcDoR4MzdWczNIuXB5HzjUFDLuhwDg+Dxcikwr2lgat7Aw8e03WO331
         GHSCGEIcmRnm0rIWIXKPqUTl0l9BYrJGNnD63TBBabvwvOoDjii0lrrieNkSWprS5g4Q
         1ryFXZs7Sdi5IFxyIog2OTsnLnlv4shSsDOQgEK4gDFsyMqp0pOZRl+3P8uI4SIgOzrW
         7qYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lkbaa7lY;
       spf=pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f186si19824932pgc.438.2019.08.06.23.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 23:39:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lkbaa7lY;
       spf=pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YjFjhTuT30+WR+0Rz31alBwUHp7i7H4qDnAY2b1b5AI=; b=lkbaa7lYSH9aLDmp/+lta95zh
	cYv/jqthqjDqOT8fXUYm4bNPNrq4LjLu6duEzAr59c4Q1saRdKjHYv5jAPsO+PfbXKgcSoHlWfJ39
	Rmqo6lqvIEC5Egr/Muv2q81fQn4uh44OXRwLrfp3VxeEfEtOOc1+einn9Ek0W4a5SHXoxkmANfoSR
	Rfs2qdAj4xYSMwCRG5vXvq5dgRhD6sg2od0wq3nFWZZHqZKonyo7j210O9TxiD+QMo5QZbXcmulkf
	dv2uo2wVom57gdYdI76kbqD+6evjX+MYPgnUq6CAzlYA/w3YpamFdjf4YXV888k7fABQQNXnpyrBZ
	0VuUHFHYw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvFb6-0007II-Js; Wed, 07 Aug 2019 06:38:56 +0000
Date: Tue, 6 Aug 2019 23:38:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas@shipmail.org>,
	Dave Airlie <airlied@gmail.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>
Subject: Re: drm pull for v5.3-rc1
Message-ID: <20190807063856.GB6002@infradead.org>
References: <CAPM=9tzJQ+26n_Df1eBPG1A=tXf4xNuVEjbG3aZj-aqYQ9nnAg@mail.gmail.com>
 <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:50:42AM -0700, Linus Torvalds wrote:
> 
> In fact, I do note that a lot of the users don't actually use the
> "void *private" argument at all - they just want the walker - and just
> pass in a NULL private pointer. So we have things like this:
> 
> > +       if (walk_page_range(&init_mm, va, va + size, &set_nocache_walk_ops,
> > +                       NULL)) {
> 
> and in a perfect world we'd have arguments with default values so that
> we could skip those entirely for when people just don't need it.
> 
> I'm not a huge fan of C++ because of a lot of the complexity (and some
> really bad decisions), but many of the _syntactic_ things in C++ would
> be nice to use. This one doesn't seem to be one that the gcc people
> have picked up as an extension ;(
> 
> Yes, yes, we could do it with a macro, I guess.
> 
>    #define walk_page_range(mm, start,end, ops, ...) \
>        __walk_page_range(mm, start, end, (NULL , ## __VA_ARGS__))
> 
> but I'm not sure it's worthwhile.

Given that is is just a single argument I'm not to worried.  A simpler
and a more complex variant seems more useful if we can skip a few
arguments IMHO.

