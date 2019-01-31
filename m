Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D70DC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:05:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55B73218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:05:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55B73218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD60B8E0003; Thu, 31 Jan 2019 03:05:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C830C8E0001; Thu, 31 Jan 2019 03:05:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA4378E0003; Thu, 31 Jan 2019 03:05:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64EC78E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:05:03 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id t21so421840wmt.3
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:05:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VCHtCXBojE7lCsT4d2adOXyAe7hDTGfR8lkJrTLhB7w=;
        b=ogcAxs/9283p9NWLhupmV/5zvz8MCY21uuqfyyGyQ8pNq0JX35mf3VeuvzgMFL5JYg
         xwa8UXpwcP8dCvUqBzlWglCBy4+HovrAtCrxdrmC5tITtnDCpU++QARByKdDEHEQEXaM
         dh33D+LN/LTAxDoltnr/rSKvYULxEgXnILlU6z4GDggNwY0Z3Ccp64cVImiroO7riP+W
         bFhcAoex6/aVM60EhqllvRX62TDzGXa+K3hja2fTQ5obQBR6qYkGONfuLbRQLA/7lmYO
         dyHor/Y0rtY6wdg8xr2n+Ucwzz1YnxDy7457aefp0l/5BETbJx0xnFu72uaP52XCH9cl
         L5/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukf084qJV3Y5t908MOemea+glx8RHUeqNI3tASR07J/pcbAJ7jr2
	b223x/oaQMS4rYlUaaRbCDobyoIyKsYDEMNrYGvcJw9wOBmoohKNIzkk4aFbg5uYq+b79Hz1EQd
	+LzMm4M7gCe7QIwDL0IFYDCg4RcKPhNNVCObG0j7SKg20Ol26kkdcJbQ3RJc2/KGkKw==
X-Received: by 2002:a5d:5182:: with SMTP id k2mr33339100wrv.121.1548921902970;
        Thu, 31 Jan 2019 00:05:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4qpnQcNwcH/SsQ5ePnR9MGCqBQMVmtmeG3aEtTSGd4m29leGObOUveWhZy81TTmqxpGu86
X-Received: by 2002:a5d:5182:: with SMTP id k2mr33339049wrv.121.1548921902230;
        Thu, 31 Jan 2019 00:05:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548921902; cv=none;
        d=google.com; s=arc-20160816;
        b=JEwcq/0w1ICEsQ2Wukg7snFOwYHPh1uR6K9PYlXyFjkSVOYf1lUgKkrNKRSMufho2Z
         I3htJ/j5/AMmABqcOsGZwCULTsc3h1DLQTmC403RaG+iPicf67V1tbxF4osROpYullZE
         oiLHazZ30piYgnIrTRDmdzHGzMDK12zTybldlr1rBKwmN0KP1zg5A0dQ/7vt7EnC2IXW
         eHyYlicj9+7tWN1TlBx9EL5mnrM5dA8u0DDfBhMHjvudy+fqwYw8JZx9Lqxgy04ZpP6E
         KCXKuUx1AMFMqE2qH4rfAvTQNOJyAgJZw8kSxN0SJtxXUFa58b7WufWIouEV4UmcAJ54
         o78w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VCHtCXBojE7lCsT4d2adOXyAe7hDTGfR8lkJrTLhB7w=;
        b=jNGRLqb7DQiyfWvw4TIPnskXjRSc5vO5GoN1Gw6YiuL6IBZyEjz98eZmEA809H09PJ
         3S6son6UUHL80jAYE64aYpGKmVosmlQS6Q2R55X1At6K/Q2oB6GK+pTdSHilIK2m56XA
         KrAWZBYDcJtQ/U95B307CN4zokh4GltJo5zLBFCVHjyDKR0A9JcdAjjTRwGwGoIT7QBZ
         Dh3ULjpnroyI/GYwXKJlPb+mekCL1n0Gx6YihLoTQ1+S0ddBCsO6CJfJ1ItcYrDQvuqD
         cNoDO4tswFDKYBxnRi54ogATQGtGe2bQ3x3Ic3zy+e6FuU2Q/vkpdx7vF2fkCS1yvQPe
         nazQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j9si2928407wro.332.2019.01.31.00.05.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 00:05:02 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 9019B68CEB; Thu, 31 Jan 2019 09:05:01 +0100 (CET)
Date: Thu, 31 Jan 2019 09:05:01 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>,
	Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190131080501.GB26495@lst.de>
References: <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com> <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com> <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de> <20190130174424.GA17080@mellanox.com> <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com> <20190130191946.GD17080@mellanox.com> <3793c115-2451-1479-29a9-04bed2831e4b@deltatee.com> <20190130204414.GH17080@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130204414.GH17080@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 08:44:20PM +0000, Jason Gunthorpe wrote:
> Not really, for MRs most drivers care about DMA addresses only. The
> only reason struct page ever gets involved is because it is part of
> the GUP, SGL and dma_map family of APIs.

And the only way you get the DMA address is through the dma mapping
APIs.  Which except for the little oddball dma_map_resource expect
a struct page in some form.  And dma_map_resource isn't really up
to speed for full blown P2P.

Now we could and maybe eventually should change all this.  But that
is a pre-requisitive for doing anything more fancy, and not something
to be hacked around.

> O_DIRECT seems to be the justification for struct page, but nobody is
> signing up to make O_DIRECT have the required special GUP/SGL/P2P flow
> that would be needed to *actually* make that work - so it really isn't
> a justification today.

O_DIRECT is just the messenger.  Anything using GUP will need a struct
page, which is all our interfaces that do I/O directly to user pages.

