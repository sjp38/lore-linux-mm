Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B1F3C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:14:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 556E82080A
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:14:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sb30mItZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 556E82080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05D526B0007; Sat, 15 Jun 2019 10:14:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F29428E0002; Sat, 15 Jun 2019 10:14:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7B908E0001; Sat, 15 Jun 2019 10:14:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3DC46B0007
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:14:58 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f9so3766816pfn.6
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:14:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=tZ6ZSN9wjiMtw9Gs9V+rFljPzVHOWgobV0RYqrIr6QCqIHkkMs0d9sFEszYZYci5go
         JKkjx0gcEk27lywPbUwBgA/jofGQLRexULMbIIawyk2qjSU1mTq7mToTS9IvNWQbwgZ0
         1+9lTorrn9m1hGZul59xa8ea1bnENeozEFAPqm3blSXCWbEGeiQ13mjURQsPQGnONV8r
         C8QlU8XcR9iII8kmN7w4TGTlqvEok8uxR2UUg74+6eMNMB+oyT2zVwDL/BH9kRyiko1y
         pzQceig/0+bAl/5rD3bntOPb+kK2dpkwflHCDAvYXUHTaMNIbO+XWt8U349ZOccmOuGh
         leLg==
X-Gm-Message-State: APjAAAV09KxtLj0smsHSTuxHycipDKxJ92UcKwoo6IwZV0kPCacrIKoR
	rP0z4t3RAXONJYOgGtu7u1QufJFTLiT9ugD8VBp6zUwUA7UBR/fslAE24HtYoXuUM4UEicy460+
	OVJC0vZI+KodqYX0Rzz+9lXThC/3Lsqy33Atio9ijBNfhpxtL7m9NrundQccyKJUydw==
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr29364559plb.81.1560608098329;
        Sat, 15 Jun 2019 07:14:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycmuRnNOLwubg04kWNvXnmb9qmouWREYPUiSy7dyvSHqi0N0DR5TpSfPHA7lXiJ1Dw8JDW
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr29364520plb.81.1560608097788;
        Sat, 15 Jun 2019 07:14:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560608097; cv=none;
        d=google.com; s=arc-20160816;
        b=dbU2wm8mshd8PAPQSf5d5pPZmaSp43jTWRIJWbYsktQt2+OYn2ZMNK3sa1UBF+o/rh
         3SccX4FQj60ff2Trmvd1tRou3/Wcpxc84H+kw8TSYUuyD60tgEQKm51Wt6GCBt5EyM9D
         1GOhtEqHOQb6NzJGSXL31yqsawWA9e6j8wr7cxhcWRh5P0PTG/KA99juuWcVUOG7g2RD
         FMLabXpxhKeNY+Nj6tBxLf00bqHUN8LW12ecnPyiUMFMzcpYLdYen/7Ol/SB1J+44bev
         OX1A4U2Q7u9pj+uuDafqR4tW0VHx59dtY5QwqGh0loXUl89WvCun42EkpEqiND1xx9Z8
         2jpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=slLUJBZYRPrDLFA4vnta2DeCbnFpgZwMe/TitdvnOrWjRm1XnxZTJJemRyLFYT2sy4
         o3r9cjAb9+FGE8uePdMVxa0xEVwA8d0GSxxu11wkt0L9m43/LWBAiLKxHjSOvSnetXFX
         gEi/lgerf93SuMKGkoTWvgulf+4ExPSvrHuRvaSpi7OlnsSEAkkrFHhcoiB/8iOH0Kvj
         hS+q56VI8EzfE3MzeY4r/nA1XPrYKX1ntKVs7yXW52MD7KSNJeXvks0tPMeo65c2xerd
         BYDiJfZwqMMjF3tac48o+2vnbnxyEu46okR+ulFLB2dl4KLIJT0ZIozQAIJIb3bratvx
         AEhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sb30mItZ;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l89si5055306pje.59.2019.06.15.07.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:14:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sb30mItZ;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=; b=sb30mItZOVUBrRnrwlLggLPvO
	yv3+kcRWWkpSXz0B4iGM4M+9PmizIBYpj904vK+dT9gYty86Mi4GvsXsgNbcgr853HWcDDsn+vTHj
	tf60AqYXTG4YC2ogZL5AnwfyxVwe9oRpYht249L0S84oTvzXu2dWMsBjxi1UmjOC4gF4pE4WRPS4p
	DI/pTzlnBsKUFxoHm8RDXk+n/ifI6K0QmwQDW1h5R79pw/xK5DIlSkWps32Qu0wWUSou4qYn/pQYY
	B3YB/iLrQWTpy3nkNxZup8yTD+nDMBZJ9m+hCxvTwLwgiM3uOnJug3YHlAwPyTAZASU9Y1wMOrml4
	RlgZzkwnQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9SJ-0002SZ-40; Sat, 15 Jun 2019 14:14:55 +0000
Date: Sat, 15 Jun 2019 07:14:55 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 07/12] mm/hmm: Use lockdep instead of comments
Message-ID: <20190615141455.GG17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-8-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-8-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

