Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0564CC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:26:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C311920869
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:26:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C311920869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61BA08E0004; Wed, 30 Jan 2019 12:26:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A4558E0001; Wed, 30 Jan 2019 12:26:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 471CE8E0004; Wed, 30 Jan 2019 12:26:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E328C8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:26:55 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id q18so107030wrx.0
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:26:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GVhgu25msCq7s4/zPu4AurVArGf7VhGY30MRUFDioto=;
        b=kN52k6bBLzPh2VRnteI8P9h5ErPlC26zKzHJc3NNEx06o8ACnIaMFSBCDbzAt+b2ic
         1YWcZ7b1eu9WtM988xGNJFaD5xb0V/klOENOeEXaJRu1gyWgoXpK9ry/TgfP8k/9NHVf
         yutNo37QESiSw4Ynebu7xJpbnMt3Cy/aCi8nsJPM/McS2Z4YvvwfsRcfGZG/DKFLywr5
         SOIsmyWdow0+MdDU+1UC3xQnb/ismJwYycnA3uABByneywPNQtE53OQBPYd9FyM6Al9m
         gZOUwHAIGGqCGP3EIyT41kBk299FTIiupPEQiP1tqsnoBXqy85D8tDDuV7kC/bkOVJBi
         VACA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukfU/fdqHUFle0h5WXqUfURuub3TM9nciS5p4vGZz0JLfNhJ+gU6
	mIgifj7bazWSpl0KF5PWr6gdPupyBGkPUniv/LwFuG7hSwcsLpF7eOHREsrPaItdYJOQZ4JGWUU
	XJExkB9gk0KwbHVHo0etvQSGSL2Kov0PUboLj9a4s4pWeteyqspxpuRzLlzwqeboAkQ==
X-Received: by 2002:adf:8421:: with SMTP id 30mr31929777wrf.153.1548869215386;
        Wed, 30 Jan 2019 09:26:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7pQKSOP1lFdz4L99aUhQJ0kEVa/pzNV1kGAwwKfsEQ2PIz+q9KBI9INxua5a6RFVdQZy7E
X-Received: by 2002:adf:8421:: with SMTP id 30mr31929728wrf.153.1548869214329;
        Wed, 30 Jan 2019 09:26:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548869214; cv=none;
        d=google.com; s=arc-20160816;
        b=DXuW5gvVr5Lf5wCF+7DTBeojbRYvsF3LYVf//aDHqlcWbfTTZrJ6DZ5PWKK7T9Nwgb
         ARV8O4uEinWLG0UWtv8mkmANBa4WicaDAdLsbBpjZ3gTI5K1sK//GzOX6g4wwATL3/Nr
         2b9GD9SgSDXE4RfOIkl2N1ULZLS6uYWiLlb3SDTdclq6imd1C9CRmsSrJb1Upuu4ixGS
         ZkCozBgRt+T42yOIXSeqJ0sVIvMwaQ0eZ+8k11z21ygT65T46vCsRTsSA95rFfXXHQFK
         3ScC+Hh5LfXsMgzHqzWJPyeCSpCqr/8IZ2WjM46Ew6UITbEAnwvc2kheWhCxOspRZUp3
         YSbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GVhgu25msCq7s4/zPu4AurVArGf7VhGY30MRUFDioto=;
        b=hnQSF573znYzArvlj8VPH5qZo7/Fd6Qwz3TUjFeCDGjsjZIgcjJYXN9wxgEN2Dfs+P
         QRGUKEuBB0Lx5Gx1tFK/BYx9G5j0CQ3kvgi8kqHGon1ZO8ysdm9zD34TtaMDG1B3u33s
         N2pSjgT/vi3VeYM/8u628F3cZ1kTdBScPzc7cfqmJ5PWekke3m1ZSCAKGokkYvbhH4jY
         VhQ1B8jImKTKdkfW4FGpYpyG956Hv5TLNgh/CcFLU8NfpKJobRPflYyLzbAB7vwsFb98
         /W+Ap/jEyMDh3PKlrxm26nAp88YcQRAXzFnl0kl0vSRdKC4G3Sy5BuM+c1bV1UTBDdwc
         eBBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p1si1459449wra.274.2019.01.30.09.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:26:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id A292768CEC; Wed, 30 Jan 2019 18:26:53 +0100 (CET)
Date: Wed, 30 Jan 2019 18:26:53 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Koenig, Christian" <Christian.Koenig@amd.com>,
	Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190130172653.GA6707@lst.de>
References: <20190129174728.6430-1-jglisse@redhat.com> <20190129174728.6430-4-jglisse@redhat.com> <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com> <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com> <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com> <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de> <4e0637ba-0d7c-66a5-d3de-bc1e7dc7c0ef@amd.com> <20190130155543.GC3177@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130155543.GC3177@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:55:43AM -0500, Jerome Glisse wrote:
> Even outside GPU driver, device driver like RDMA just want to share their
> doorbell to other device and they do not want to see those doorbell page
> use in direct I/O or anything similar AFAICT.

At least Mellanox HCA support and inline data feature where you
can copy data directly into the BAR.  For something like a usrspace
NVMe target it might be very useful to do direct I/O straight into
the BAR for that.

