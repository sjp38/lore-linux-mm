Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CB68C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFFAC21473
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:56:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ia+hyCah"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFFAC21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E6066B0006; Sat, 15 Jun 2019 09:56:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7702D8E0002; Sat, 15 Jun 2019 09:56:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 637EB8E0001; Sat, 15 Jun 2019 09:56:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED2A6B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:56:25 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f2so3260247plr.0
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 06:56:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=UdmETwcAelQ7hjLWjwZGjYFubn43a4ZHWln9s3M6Efe0ZbbqBwnY8bEFDoraNQA7RY
         dN0XwxfrbQrI9yJhVAMev/m/TyaMItV4D5SVIXF4rdE9mibf1DOEa8dD5CAi0BviB+Ll
         QekydmhOMTxKSBRTqOSDSeCChKy3lHo2DB9gRAvZWCCPvUgD3rcHp49d5ck8TeyNw7rN
         PR5rzT1Rlq+ev48cf/G6alqREb5qzSjJ/MauISlflDD/v60i4xQiTaCj7c1rQxbN6pVq
         dQjMO6zANZsfPv3vp8G8RvBhk3HTiXQk8FXWKXK+hoqsSh+1DwTKOdMjRkoYmQBOCBrm
         2bVQ==
X-Gm-Message-State: APjAAAUPiJMKNK0ZU9Qb5n1pvS5Cl+tWzxvJFhez+sF7D2R6PpVTkmQw
	PIAx5uN+M9rprVEOISHw2xqB4IYO0I6KR64zp4j7P4HE7Mk/pFvyD4NAwvWyQOWk3tt02HYElTk
	8Ewigp52q2qhNY/V5n/Ue6Q5t2kHSCtWIYRVCneo82YrU5mLUMU/makFGmGVtiYxNfA==
X-Received: by 2002:a17:902:e2:: with SMTP id a89mr99382997pla.210.1560606984704;
        Sat, 15 Jun 2019 06:56:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQQNrUpdvtbUXJ4984IQwZHn4lPawpI+pJUsvOIgmuBybpNONRcoKVOUZdc743da8jI0Xc
X-Received: by 2002:a17:902:e2:: with SMTP id a89mr99382945pla.210.1560606984024;
        Sat, 15 Jun 2019 06:56:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560606984; cv=none;
        d=google.com; s=arc-20160816;
        b=p39G2WomwZ6p/+rTxOQz1ayvs2dp0mSyPEdnVXuLjXXGhldPKk9Eh9y6wS8YlTz2Qs
         5RBpZQP5S6258wNP0rUaoGb9hjnC12jhsTI9rrNRzGrxrm7eiJlwowV/OHMSssYwjKnq
         GI28u92Y5nE1UUzLqDXkNeg5O8hBtd32/7elgOwj8Ra33nDIBLt3nf8/yROt8b0JrgrC
         z/d2V2rTIDLQbxK+CpIGnjZrm6wRQ+i1lYgKUiOwrn2LSY9FXGNgCC2Rz1E6JJJxQaDD
         jyrIZ9dcqlPSzPv5Ud/6Q5XBmckxTvBPfWCPz0qbfuKOvxXt2Z+y08S5hIzamxKwboqI
         JE9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=wibcWumQt4KLafmZ6C66YyD6OoK94TLri75sx1iXcehS5S0bzXQRijsTaKj9wse35+
         UI6TXn+iQmjvJpC/3qvZ14hcPYwgpvSRY1/PLxSXbSqhrzcNfOouNcpDS1ey2b0Jmvqm
         XxAl8+Vt6Pi1WW8Jsj6ftZqPfMU7AUAk7lbEAFYkSepMKauie8YddkhhkVUSHUysaV4R
         ao9P91pddxOGfZtsmbCzrzsPp1qONGDssDt+u1/Xwq/+7pWyPvlix7MRgtgQTw1cey5T
         guwbYWiuWDN1wyFKXah8jHPhHHc4rP5T2kYdlJBI/iq9Im/lScivmFZRVpPyDJXeUmt/
         t9hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ia+hyCah;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z7si5431731pgi.365.2019.06.15.06.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 06:56:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ia+hyCah;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=; b=Ia+hyCahPnNLptIjBBSg6A2hc
	3+pHYzGW8QE1nudlqziktCysGBrD5LCbnHD6XsFPe129roV5tszslEX53KqQRdLeAOeI2QAsbgvcv
	zTo8/kA1ky178p2tiA4dmMgFWGtKrOOLD4fC7dDUlZNreK84hPZljynr089JvGm6eiWIyV1lv9zG4
	lm5ATf0B3UO1styuf8Ov3NsugTbtTjrVhmF8RSwnOXHEs7D1jiDr1diNyD2BmWpiWZx/tx9W9moZv
	KooABuT/yj9iE1lodXt5dYfQTgIY9O51yKs8YWR680rfo/5c+PKLS7UtAYHcIiBts+6BDJGzijbMX
	/u3JhMsWg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9AH-0004pF-EK; Sat, 15 Jun 2019 13:56:17 +0000
Date: Sat, 15 Jun 2019 06:56:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 01/12] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
Message-ID: <20190615135617.GA17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-2-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-2-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

