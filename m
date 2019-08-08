Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BE18C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:28:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19BAB2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:28:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19BAB2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB94E6B0007; Thu,  8 Aug 2019 06:28:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B66D76B0008; Thu,  8 Aug 2019 06:28:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A30196B000A; Thu,  8 Aug 2019 06:28:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B66D6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 06:28:17 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t62so1593216wmt.1
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:28:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=UjxmpJ/6XTkMxCNu+3UxLVnUFUdJ4yoeYHnIhqty3z696AZKrLLtsw4vCuKNibNh1A
         qeCqt1aGfSfg7sIpJJQT7qvVA0YJhod316G5J03FbyRZH8abThAUZ8Ums1mA+LRU7N+k
         Kdya8To9OuDUgENfrdZ0Pae+X/pTVXi/M/AeVHD2KBtrFjLQgYzQndf0RZNkjpLHRgjQ
         jd3mOKjfvkxE+IoQ/rT0lVIGaghLRuVs1GCSaGe+wnL8Qw6Z4FL9ifUITtWqNIBXXN+u
         7FXurs4KDoXaS6VW0lyiFzUAoDOMX4vR/R0dGikaoQVRyVZ/WasslISADbZ/PyxpYf6H
         kYLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVDpO/fPDhbMO3VjIZrVYWe1qcUkxTGAtDx1E8FjuNhYYJwz04m
	w44U5R5xYqh9wILr+X+c/L1qB7DL264+9Of4F5oWJcJ2JbhbOCIFgBWox/63sAj7ZKZrDayW6Nd
	52Z7Mv5VWqjY5WgH/IHpnsjg+wd+WPdF7dW/jcqB81UPXCcSnThrMs0lVNBlQTewdHw==
X-Received: by 2002:adf:80e1:: with SMTP id 88mr15685740wrl.127.1565260097051;
        Thu, 08 Aug 2019 03:28:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGA1lZVUsqC4JhSsllcsoiZLKtjCtoFMEKdHIx1035RRNofk0175ztmiR1vY9DR7+csEla
X-Received: by 2002:adf:80e1:: with SMTP id 88mr15685671wrl.127.1565260096428;
        Thu, 08 Aug 2019 03:28:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565260096; cv=none;
        d=google.com; s=arc-20160816;
        b=WqTtruFXrfQpULQMlZ0i6PRTzK1z8BrwO7pXeVb3+u+6o/95HK1fd8DQuHA7/d2VJH
         V375e7Nt6zlkVpjQZqV6CtXZV0rAuNt0wAdqZHa24embFP1WwuW65FfypyS8hnILLPg2
         XK61s0KD8zOYAGK1Apmg8BNfj9PVFTzU7oGB9Xrmppmv1Z/Ytp0YUOX5tB6pwUXE5pJF
         6gVSLWrJMW6iPi6nbQPTJle2k3hHe9e4VKjfpF3NnLVejdCWxdMLejhkXny8bWCd6ptm
         jo53kww/IY1+rVmiRt/m64wGT9M2GFT9NKQwezQX+k50kfajKPv4EeO3MR+2vvEX6yjh
         kw0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=r9qdXEK1cDQpPfTlQY5nuAZW/8x2L41tVblIp778MAdLq0LtP3oHVttOe47Z12EqfM
         6skVaZxu9pj2MT9U1VDJOxK50OQiyHsq4CFBkWoXY8+IPNG7B5rUSZlzZDs7XIt6/x+Y
         idca+7uW1A8Gt2khIoFReuCWeoqlHwC9hCQFQ3RWVHidbesDuKeqTA0B1OH2rnbOAZjE
         YZNDS7azvZGDNpwoXk5Z/4brSY/fLq0jYGBcR+ph90NvbDbokCjcWoHTKGbtrpc36rCV
         +VGpg+iOoY6H59ZeKCvHtoB15s54+1Afu85O1iRWC5dVp1hWyfZhRuXI8u7I2GiMgsvO
         ZDZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m3si1380264wmg.28.2019.08.08.03.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 03:28:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 211AB227A81; Thu,  8 Aug 2019 12:28:14 +0200 (CEST)
Date: Thu, 8 Aug 2019 12:28:13 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>, John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v3 hmm 05/11] hmm: use mmu_notifier_get/put for 'struct
 hmm'
Message-ID: <20190808102813.GD648@lst.de>
References: <20190806231548.25242-1-jgg@ziepe.ca> <20190806231548.25242-6-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-6-jgg@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

