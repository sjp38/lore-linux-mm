Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72082C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:41:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11D1B20868
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:41:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gCA2Zddj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11D1B20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58CC16B0005; Fri, 24 May 2019 02:41:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53E736B0006; Fri, 24 May 2019 02:41:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42C9B6B0007; Fri, 24 May 2019 02:41:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 076506B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 02:41:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so343214pld.15
        for <linux-mm@kvack.org>; Thu, 23 May 2019 23:41:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MboJlUX6ud6Y8h1xvMwj2zi3GdAiWghHA9DcE9E0NzM=;
        b=sOS29JZVqaOXRmNqkOVOJsnae7R6GBgQqP83K38i4ReFLeYO8U7x1OcZf9lXH2W+VB
         J8e0cARF50G0u7rKG+00sSX6MhS9gvnGvcV1KpfYEcXMomQ8ZXYnTqpr8MAVj0N89mGF
         wSfZifN6+pwKnIYvLOlnHG34GKutOz76Ghbvuraf4LGAz9UrNZZvICYP4MMzxBakK0CY
         hsfdqF9SqCzQphSPEy36bSoGsIb54nJnH2SvA5ThjyDj4RwVHVVCL6tn/kTcjJtbJy5N
         ARFcSPA0pSbbo+6Ih+c+il6zFdFYHV5mw2tmf36EuWf/23cPZnyZzAJDxVmvOusNZ6Ft
         +VwQ==
X-Gm-Message-State: APjAAAVvG6aGPsiVrDLJ0KebsmL6K3tKVTc92N8thkGVK2qAXR+Hp4qa
	LXvruSQYJ+HhozmU45U3fPeB8W2ojeQvr9RKgEYC2wRZsprAV3ukOnNerjTahhRgSK6glbEp7zY
	vKodG+yhkqG7g9Obz6O6yORiSatjjh5hogZ5PYxKpOiWp5qpQ86s5upK4KhuAMwFJpA==
X-Received: by 2002:a17:90a:2e87:: with SMTP id r7mr6632441pjd.112.1558680061575;
        Thu, 23 May 2019 23:41:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymHwM4lD3s+YvkPWD0RFRJ7WdC9fyKJS3LYNdsyRPkcDyTh7PAbaxxw9stD8vw4iT1+874
X-Received: by 2002:a17:90a:2e87:: with SMTP id r7mr6632409pjd.112.1558680060955;
        Thu, 23 May 2019 23:41:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558680060; cv=none;
        d=google.com; s=arc-20160816;
        b=o0F/xvMbfrZzpTBvu23sRlHRaoyvr5IsVG0NYNUeVTeeqGk3A2pG8EGpqC6Z4vv//a
         5ZHPMrFAdPi9n0r2TWwPeDWM/3I6MrzXh4IX9rruTlEU8DnDliDja7JYQbT2o8ZOJFIy
         jIZ1l0bz8ZxhX3737V8NFgEcoE3V5dpWHDfVJTPz1eEDHRbSU7/8lfgPgZxT2bxEWXYQ
         2HJBJ7P6bUREMxArXS7lrdSi0EYfG+nT2J/hi454yXX+zdmu8b5X8n++7sSL945gjwbA
         n4G8cX4APoWkHzJTKhljDRlK5ho/gMVTEFmkIkktwyQIWAWp4ZNKf+2khEIKjkT2KK4x
         oKPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MboJlUX6ud6Y8h1xvMwj2zi3GdAiWghHA9DcE9E0NzM=;
        b=DVfJeV6Bf2ifqr5AG3BZxtNJLhLezOLjU4b1zGpKxfB/4Ll97Mm5fkZiIxtiRkeOJy
         r9bOi9ZGQ+GYbHHGMgI/B110noQO/gtAk2OHmMzweB2mou0a9LUR0/1Nk/emUCn0rnbi
         pnsXdo7v45jw+D2MvvuXCmgfajxrU2QMrtkZqTRr4XvtYmNgBU821+NoHZ+kHBt4P51N
         +gGyEmGed39q08NVNh7dBtZNwgoIY0ccO4EktYJOPFXJ7PHfo+ykKmXMJ8Bp65vpkYQr
         SSOdZ0eC7v9xnFZID4B76HY0zD85jJMK6aKQppzUqOPSUxJpdev+Akt/jQBc9+srxYrY
         Gg4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gCA2Zddj;
       spf=pass (google.com: best guess record for domain of batv+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x2si404632pgk.223.2019.05.23.23.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 23:41:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gCA2Zddj;
       spf=pass (google.com: best guess record for domain of batv+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MboJlUX6ud6Y8h1xvMwj2zi3GdAiWghHA9DcE9E0NzM=; b=gCA2ZddjLB5JYDteejHRuh95u
	wJtaMuKOt5ACv/IoDR4+kaisQNbxEfqFZy7k1OXAn1DibvkRaXx+6ppZxoi/sgG+aZCL/GCx+GaXT
	xYn1+r+DqaVdoo9xeLPjTM1sWHV6skEExwJRIQwTSreXcRSJ0noVHx3MlPRSUPg81/AxHUivOym9w
	3uSlGykT8z6X9n9lodjYzb4NpCAUUqgt5J70gjw2mlp42t5mvX0r7bpW08CB9ZOYsPp42p76e2ZHC
	cObH1wCHfyOxmPP/jgAmUasX014LH9QR7Dq1g24+bAB9ecrOGc5a5i7RdtUcfpguWkQRROfWnpeMw
	BqaRnYRLQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hU3sp-0000NM-Do; Fri, 24 May 2019 06:40:51 +0000
Date: Thu, 23 May 2019 23:40:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org, akpm@linux-foundation.org
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190524064051.GA28855@infradead.org>
References: <20190522174852.GA23038@redhat.com>
 <20190522235737.GD15389@ziepe.ca>
 <20190523150432.GA5104@redhat.com>
 <20190523154149.GB12159@ziepe.ca>
 <20190523155207.GC5104@redhat.com>
 <20190523163429.GC12159@ziepe.ca>
 <20190523173302.GD5104@redhat.com>
 <20190523175546.GE12159@ziepe.ca>
 <20190523182458.GA3571@redhat.com>
 <20190523191038.GG12159@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523191038.GG12159@ziepe.ca>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 04:10:38PM -0300, Jason Gunthorpe wrote:
> 
> On Thu, May 23, 2019 at 02:24:58PM -0400, Jerome Glisse wrote:
> > I can not take mmap_sem in range_register, the READ_ONCE is fine and
> > they are no race as we do take a reference on the hmm struct thus
> 
> Of course there are use after free races with a READ_ONCE scheme, I
> shouldn't have to explain this.
> 
> If you cannot take the read mmap sem (why not?), then please use my
> version and push the update to the driver through -mm..

I think it would really help if we queue up these changes in a git tree
that can be pulled into the driver trees.  Given that you've been
doing so much work to actually make it usable I'd nominate rdma for the
"lead" tree.

