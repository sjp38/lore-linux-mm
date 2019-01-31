Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F345AC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:11:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C14AD218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:11:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C14AD218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4907C8E0003; Thu, 31 Jan 2019 10:11:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43EC28E0001; Thu, 31 Jan 2019 10:11:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32CEE8E0003; Thu, 31 Jan 2019 10:11:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 085B68E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:11:52 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so3482493qka.7
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:11:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=v1MB0ckzpQvR/8C4mV91Di5lPryfud4kqcp7DSn5uAE=;
        b=bIhGw0vh7trYwUM4WM/DkrIa7TGg4Iz2/DL3VU9R63OGyZP7+zqndzVMxjbxM1CL+L
         wR5Sn6UUc7wvrAJcYJFmrD51TNtrzYF3FUDxroamBNvvSywYMGu3mWUYKLSKLaW30TJh
         6otrdkUyWbTFXcHJuTMSpjBvAaExSdjT0+9RoeVv04ulqrtGFF8DxeD7DYEYhWKlwgkj
         /HeVzsjqFw0c8JJOZK01lqwpbo8mYOG2GJEoW0v/wM601o7Aii643TcSrsJwPuwpe9U6
         wKAOSdECxHSet9YGS/8WioaZpMDbqGf92CBmb/oP7hUSfGtkI2Lqfd2lFbekLImc9IHp
         +2cA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdFmWWdHb8RIcDuVHIDbcnwIWA8t3NOXzSSRkGrdQ5j0wLBG1xl
	g/a2mK1w3Fo/B0FGB3bvx8TvDjxGwC+vsukKWQaJuOVMw13DdORxuomIBEjf0lrlHtrKI1YYXCJ
	KE3lrLsHAzRkE7Xs93zblIGAQRB11UFUkk1BAsfmNmiliX/EFf9yTtgtsyPGHKjactg==
X-Received: by 2002:aed:242e:: with SMTP id r43mr35240281qtc.128.1548947511703;
        Thu, 31 Jan 2019 07:11:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Ue47oQO81gbABy3nTbdy6grJtv1PL2kZngW3V/UhuuZ3J0gTDB0sJDatH/mit3LUiDcOv
X-Received: by 2002:aed:242e:: with SMTP id r43mr35240210qtc.128.1548947510885;
        Thu, 31 Jan 2019 07:11:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548947510; cv=none;
        d=google.com; s=arc-20160816;
        b=AnNKohlsMSnl79Q8yPNguACdbzdgxbtG/IdhNU9JzMP/JoKtW+DbfgMPYFfH2HU9Ta
         1pAObi4VOCjnKvLhyvW5FzBhC6xPRtrX5t7JLvCZQf+/qwq5qjqEu/Kt8Mty9keEtFIn
         X98BY+SW4+/sBv3q4/dMwLMWbCGEuNaEBbcIBAd1s62EINWD29NVKxQhiCHia6LS2X9c
         rTjMeB0dkyj1wL4mNg0ZvXMyBfe5j2NsLAMP2vOaubvxUW2cfAkqjGDrB/ZHVx50NZrK
         LIavNBKXJ+AzzQGR4/TYvz0Ep1U80wg85OHWCzf0YHMlaIt6bFKXmolBKjDTESjMliYH
         qtCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=v1MB0ckzpQvR/8C4mV91Di5lPryfud4kqcp7DSn5uAE=;
        b=ezlgWN2wmMzeClyMA5ZAtcdti0uECgnEi0o/V/y+EMsqQ8WpVjpDOwG3wcyc52OuXv
         PUCkTcxHN70LfWsPmL+gOwyIiUvG1ac2nfyV39cGL4wjpasK3k3CGqnT39HeL+lg5FgD
         6J6b/yCJFEYf7jiUn+UkE0HRMSU5JobRh4KFgrEq8ETztQ/Bvm8TBl6Nrfi7sZ/XrsTN
         kRA+XDTisRl1yo2mfuzzUu20/be40m5Lmocqu2ifl7L86wGqWrlVD+/4UQ3i75WOcNFS
         rDz0PXTkDGmuC4YzgbHR7zC4ShSdSfePOYAIAPraZyLLXPVnG85vj+UBsYyQXOChlKOF
         aO4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x32si3327130qvf.31.2019.01.31.07.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 07:11:50 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B4551A08F0;
	Thu, 31 Jan 2019 15:11:49 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 38D0660152;
	Thu, 31 Jan 2019 15:11:47 +0000 (UTC)
Date: Thu, 31 Jan 2019 10:11:45 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	Logan Gunthorpe <logang@deltatee.com>,
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
Message-ID: <20190131151145.GC4619@redhat.com>
References: <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com>
 <20190130080208.GC29665@lst.de>
 <20190130174424.GA17080@mellanox.com>
 <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com>
 <20190130191946.GD17080@mellanox.com>
 <3793c115-2451-1479-29a9-04bed2831e4b@deltatee.com>
 <20190130204414.GH17080@mellanox.com>
 <20190131080501.GB26495@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190131080501.GB26495@lst.de>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 31 Jan 2019 15:11:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 09:05:01AM +0100, Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 08:44:20PM +0000, Jason Gunthorpe wrote:
> > Not really, for MRs most drivers care about DMA addresses only. The
> > only reason struct page ever gets involved is because it is part of
> > the GUP, SGL and dma_map family of APIs.
> 
> And the only way you get the DMA address is through the dma mapping
> APIs.  Which except for the little oddball dma_map_resource expect
> a struct page in some form.  And dma_map_resource isn't really up
> to speed for full blown P2P.
> 
> Now we could and maybe eventually should change all this.  But that
> is a pre-requisitive for doing anything more fancy, and not something
> to be hacked around.
> 
> > O_DIRECT seems to be the justification for struct page, but nobody is
> > signing up to make O_DIRECT have the required special GUP/SGL/P2P flow
> > that would be needed to *actually* make that work - so it really isn't
> > a justification today.
> 
> O_DIRECT is just the messenger.  Anything using GUP will need a struct
> page, which is all our interfaces that do I/O directly to user pages.

I do not want to allow GUP to pin I/O space this would open a pandora
box that we do not want to open at all. Many driver manage their IO
space and if they get random pinning because some other kernel bits
they never heard of starts to do GUP on their stuff it is gonna cause
havoc.

So far mmap of device file have always been special and it has been
reflected to userspace in all the instance i know of (media and GPU).
Pretending we can handle them like any other vma is a lie because
they were never designed that way in the first place and it would be
disruptive to all those driver.

Minimum disruption with minimun changes is what we should aim for and
is what i am trying to do with this patchset. Using struct page and
allowing GUP would mean rewritting huge chunk of GPU drivers (pretty
much rewritting their whole memory management) with no benefit at the
end.

When something is special it is better to leave it that way.

Cheers,
Jérôme

