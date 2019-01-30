Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B70F1C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 855E62086C
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:22:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 855E62086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26C958E0011; Wed, 30 Jan 2019 14:22:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2190A8E0001; Wed, 30 Jan 2019 14:22:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F03E8E0011; Wed, 30 Jan 2019 14:22:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3B778E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:22:40 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q3so726137qtq.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:22:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=zT8e5huoZbXjddEuC956GQ6+r8DBmDIOfeKc8YBpZW8=;
        b=DzPqb0KT1E/FVEF/3rOXnSeZ4732l0+LDHQHZmrrcopJ58miuUn5VU2oinXh7YEC8y
         fEODCuFfP5G7ekhsGy6SwLsc5oJrMzI+0xMkdJqIkOS/s9QCC9rlZ78RK/wcunYgSCsZ
         n2uJvBAbpW7k9Aa/hI3SllB1lW9znqkvrdXYtgsycLd4Tt2a839Ohq4frg+baVxEa4cV
         5IL35lfJI+m0U3tv2gn+v7nUzXD4sBAZOBjO8j7wWrjntaO2VKe27rTIpK46I1YZeFt7
         o1dTyNw4H4N71P6BSK10ORKi/tdxn2hChrpqzcuoTcSwBx+KkRLHKeV8CaYH4uDPTH6A
         IVtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukf5l7LSa1SYbbzHpsZ8/17pnX4s+iTdMGbcRViX+9cfjQFXT9pB
	kilOdWBIebHRLUifLEWWxcx2kwNdbjH+nxi3EIYelV0T9FelRnQSvMxzGaPEkgwXRx1fntJkoDD
	oHUSsMeSBCRdFbkE04F2Jslo/f3NPIVQNKGvVeoDWgwlA4MD7laNVQ+ghM5DC6Rm9cw==
X-Received: by 2002:a37:dd43:: with SMTP id n64mr29729727qki.7.1548876160614;
        Wed, 30 Jan 2019 11:22:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5nE0S5mXsjIYGMx78LctrmQ9mm/7BjAQGg8w4lcSmcdn7gsaCgOcQNRDpb5gym8MkoFHjU
X-Received: by 2002:a37:dd43:: with SMTP id n64mr29729694qki.7.1548876160001;
        Wed, 30 Jan 2019 11:22:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548876159; cv=none;
        d=google.com; s=arc-20160816;
        b=PKEcbGSJdblT4YA6fbY+7WnLsVtUvMJ0qczHIcMpAwhJsieNRMt5mF7qpEqukH4O3S
         qd9gShQ2iVKg04wy7NwrpLFD8pdF1xS6U2ByxnS0KMguNiWB+YJklNnF53y9UhFqodDn
         VaxZgS2pEZTlszM6JFgz8ATNtzX9sNAD0USoRWrrUW/QKSZYbBnwqY7mEQtWFOsLVj6J
         IEO97ZHd1QE6l1yazpvqa3tIfjR5qTWexc97LIO8mXh9VEc5UdkutijMDqscKj2cZjjk
         WtBy/hjS4cOepmM+7EK58CgSaMd+81/1rYgZxXKmlKiMkBfJK71Xjpr5FMsQHTmUPINx
         mdnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=zT8e5huoZbXjddEuC956GQ6+r8DBmDIOfeKc8YBpZW8=;
        b=fH5tI4fF3jkQNqsYJQeYNXjRtomc1MtpHQV4hyW8yDzCP1U5w69YS2YbjxTeTyjcZa
         igW85uLFYUzPkTvFK8285jgfz5RQ4VmjcbNv//7M7s0c+0hAQr7ubKUkh8Jq82sMEb8Z
         mrxI0sPCUPHsKKn2NBdU1oLjFhfI86FSSm6ub47JDbkrGbCFDnOFnJfx4vTY5kjMRwIW
         QDeWtzQQnpu4PRx5eCTK69T4gHTFRUZ8bmoLHDXuT1t2uYU5KjscWms9A+YAOTlWDJrR
         VPMVrApB8QaHQGTyI/az3aEnxf78TLLksQexD+dR8hMbaelvJgZLfzD9dbOD+W6ytJWQ
         Yt0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m123si1560390qkc.180.2019.01.30.11.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 11:22:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9CA64C04959F;
	Wed, 30 Jan 2019 19:22:38 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A81C45D96F;
	Wed, 30 Jan 2019 19:22:36 +0000 (UTC)
Date: Wed, 30 Jan 2019 14:22:34 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190130192234.GD5061@redhat.com>
References: <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130185652.GB17080@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 30 Jan 2019 19:22:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 06:56:59PM +0000, Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 10:17:27AM -0700, Logan Gunthorpe wrote:
> > 
> > 
> > On 2019-01-29 9:18 p.m., Jason Gunthorpe wrote:
> > > Every attempt to give BAR memory to struct page has run into major
> > > trouble, IMHO, so I like that this approach avoids that.
> > > 
> > > And if you don't have struct page then the only kernel object left to
> > > hang meta data off is the VMA itself.
> > > 
> > > It seems very similar to the existing P2P work between in-kernel
> > > consumers, just that VMA is now mediating a general user space driven
> > > discovery process instead of being hard wired into a driver.
> > 
> > But the kernel now has P2P bars backed by struct pages and it works
> > well. 
> 
> I don't think it works that well..
> 
> We ended up with a 'sgl' that is not really a sgl, and doesn't work
> with many of the common SGL patterns. sg_copy_buffer doesn't work,
> dma_map, doesn't work, sg_page doesn't work quite right, etc.
> 
> Only nvme and rdma got the special hacks to make them understand these
> p2p-sgls, and I'm still not convinced some of the RDMA drivers that
> want access to CPU addresses from the SGL (rxe, usnic, hfi, qib) don't
> break in this scenario.
> 
> Since the SGLs become broken, it pretty much means there is no path to
> make GUP work generically, we have to go through and make everything
> safe to use with p2p-sgls before allowing GUP. Which, frankly, sounds
> impossible with all the competing objections.
> 
> But GPU seems to have a problem unrelated to this - what Jerome wants
> is to have two faulting domains for VMA's - visible-to-cpu and
> visible-to-dma. The new op is essentially faulting the pages into the
> visible-to-dma category and leaving them invisible-to-cpu.
> 
> So that duality would still have to exists, and I think p2p_map/unmap
> is a much simpler implementation than trying to create some kind of
> special PTE in the VMA..
> 
> At least for RDMA, struct page or not doesn't really matter. 
> 
> We can make struct pages for the BAR the same way NVMe does.  GPU is
> probably the same, just with more mememory at stake?  
> 
> And maybe this should be the first implementation. The p2p_map VMA
> operation should return a SGL and the caller should do the existing
> pci_p2pdma_map_sg() flow.. 

For GPU it would not work, GPU might want to use main memory (because
it is running out of BAR space) it is a lot easier if the p2p_map
callback calls the right dma map function (for page or io) rather than
having to define some format that would pass down the information.

> 
> Worry about optimizing away the struct page overhead later?

Struct page do not fit well for GPU as the BAR address can be reprogram
to point to any page inside the device memory (think 256M BAR versus
16GB device memory). Forcing struct page on GPU driver would require
major surgery to the GPU driver inner working and there is no benefit
to have from the struct page. So it is hard to justify this.

Cheers,
Jérôme

