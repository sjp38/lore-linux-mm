Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF5A7C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:35:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51522218D2
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:35:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51522218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC8F88E0002; Wed, 30 Jan 2019 15:35:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D788C8E0001; Wed, 30 Jan 2019 15:35:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C411B8E0002; Wed, 30 Jan 2019 15:35:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96CFD8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:35:27 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f2so977532qtg.14
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:35:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=MJjQyI0EDrzCa8Ru/4rVMYX1f3MyDJs9cj5VJ5RIhJI=;
        b=IV2CIEICNn23OlvgOjd3jsRCiw3nNr346ETNVTswfhfjwrt5rPhKlHpitejuSU7PbE
         tBWdbMttSeQaxKdxI414XiqJjBcd4XlJCyQMIXu05fcuzP4lo7SGXRays0et+8s64qkM
         mYSoQmIFcZN8+70qrvjZm6pp3paCF8Cl7iTCxMawOMYEVmy4NlGIblr4331FqnqWu2hW
         FdrukA43BUtRp2adOQYYTHLHp0FR4S2gZD7vTGBMS1YG/wSBXOmth5k4ewop8rWo4HB4
         UhHQpJWSSoYoF3AH24pbsTWxSsihj8JuWrEfJ6hCWANnlwMQ33D4RoOS0JO7jzASsVoi
         h/lQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeBIS9ACz7AWM2lpbiECXYPEMoVBzabMTXhldyncOpgbkhltpwv
	3JTTj5I+BuTLnnYzKAYs3wjI10/IHHTQzBwye2GwV4X5RS+VsjxJrfEMtJID2Or61TDa+NcK4Cx
	zZcmn7thrXYsc/Imq8PK8W9X4doB/TEPKKv7cEQ15iBQWaFgGol9Cvvzbh7qIsAjlug==
X-Received: by 2002:ac8:468f:: with SMTP id g15mr31301682qto.363.1548880527347;
        Wed, 30 Jan 2019 12:35:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4enkwvvnQg4E3svEQ/gE1y7QevlQqQtJpePWL1Kb9L8aCYbb6iu+Wc4KAiMUuKAeLK5Rib
X-Received: by 2002:ac8:468f:: with SMTP id g15mr31301633qto.363.1548880526620;
        Wed, 30 Jan 2019 12:35:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548880526; cv=none;
        d=google.com; s=arc-20160816;
        b=s0uu89H3LtfksPQ/1/Xyb7tVueTFGFJMRGPgMMqbQTc5qc4hzsd0mAx5Qd8c4iibmG
         HdlTQD7U+JVDSg7oNEoXHnMi5d78lYaMlWCtdjChPGXqsJaeAW8MElxae0uYzcdQ5v8o
         a38ANCWvuwOnYjdPL2zYzYsGnm4juqdZv430ljuN0my4gg3mG9JT7nsP3LdUlQPvd7J+
         KolGiHkBY1MP1eoBtWUk9fuIVrUgLR59jWhSG+/iDe52PX+VSHvHn56THrqWMtZ/VKVd
         okcxUWct2f2UO0Acq+Y/rtyqmW4opuOT5wE3LW4w3dASHfQxZgy1wWA4YknAuWs3tv4O
         +qtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=MJjQyI0EDrzCa8Ru/4rVMYX1f3MyDJs9cj5VJ5RIhJI=;
        b=lQ3RczYq8ChVZQlASvLQVLyFSDTm25R3o3JWwgib0DmNF54s+MbNuam8J5GTMZNY5A
         dniOAyTerFsVo3/4dhx2IM/rNScvjsGULqlATMfVlebZwXbb1SdzTB5q2V4k69oRR65w
         dEEDGk1FjRwXwEQp8N50CNF9teltjYDlhJkF4djhNQE578GPUyolrkMUyaKWxnMJT0rS
         69walvh/4JaKh/hI/ryR1n3oIIM5v69VHV31tn99scQfx8wJ3/K69JS427b8EvEbzlJP
         mb3VzrLPZ215RwRwJ7nFlyccUozCEb3BQ+AbqP2/J6T3+MKgyuDvl6JEN0XNOfi95zbr
         vKfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w27si222625qvc.39.2019.01.30.12.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 12:35:26 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 63599461CF;
	Wed, 30 Jan 2019 20:35:24 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 712C460462;
	Wed, 30 Jan 2019 20:35:21 +0000 (UTC)
Date: Wed, 30 Jan 2019 15:35:16 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
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
Message-ID: <20190130203516.GE5061@redhat.com>
References: <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com>
 <20190130192234.GD5061@redhat.com>
 <5a60507e-e781-d0a4-353e-32105ca7ace3@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5a60507e-e781-d0a4-353e-32105ca7ace3@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 30 Jan 2019 20:35:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 12:52:44PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-30 12:22 p.m., Jerome Glisse wrote:
> > On Wed, Jan 30, 2019 at 06:56:59PM +0000, Jason Gunthorpe wrote:
> >> On Wed, Jan 30, 2019 at 10:17:27AM -0700, Logan Gunthorpe wrote:
> >>>
> >>>
> >>> On 2019-01-29 9:18 p.m., Jason Gunthorpe wrote:
> >>>> Every attempt to give BAR memory to struct page has run into major
> >>>> trouble, IMHO, so I like that this approach avoids that.
> >>>>
> >>>> And if you don't have struct page then the only kernel object left to
> >>>> hang meta data off is the VMA itself.
> >>>>
> >>>> It seems very similar to the existing P2P work between in-kernel
> >>>> consumers, just that VMA is now mediating a general user space driven
> >>>> discovery process instead of being hard wired into a driver.
> >>>
> >>> But the kernel now has P2P bars backed by struct pages and it works
> >>> well. 
> >>
> >> I don't think it works that well..
> >>
> >> We ended up with a 'sgl' that is not really a sgl, and doesn't work
> >> with many of the common SGL patterns. sg_copy_buffer doesn't work,
> >> dma_map, doesn't work, sg_page doesn't work quite right, etc.
> >>
> >> Only nvme and rdma got the special hacks to make them understand these
> >> p2p-sgls, and I'm still not convinced some of the RDMA drivers that
> >> want access to CPU addresses from the SGL (rxe, usnic, hfi, qib) don't
> >> break in this scenario.
> >>
> >> Since the SGLs become broken, it pretty much means there is no path to
> >> make GUP work generically, we have to go through and make everything
> >> safe to use with p2p-sgls before allowing GUP. Which, frankly, sounds
> >> impossible with all the competing objections.
> >>
> >> But GPU seems to have a problem unrelated to this - what Jerome wants
> >> is to have two faulting domains for VMA's - visible-to-cpu and
> >> visible-to-dma. The new op is essentially faulting the pages into the
> >> visible-to-dma category and leaving them invisible-to-cpu.
> >>
> >> So that duality would still have to exists, and I think p2p_map/unmap
> >> is a much simpler implementation than trying to create some kind of
> >> special PTE in the VMA..
> >>
> >> At least for RDMA, struct page or not doesn't really matter. 
> >>
> >> We can make struct pages for the BAR the same way NVMe does.  GPU is
> >> probably the same, just with more mememory at stake?  
> >>
> >> And maybe this should be the first implementation. The p2p_map VMA
> >> operation should return a SGL and the caller should do the existing
> >> pci_p2pdma_map_sg() flow.. 
> > 
> > For GPU it would not work, GPU might want to use main memory (because
> > it is running out of BAR space) it is a lot easier if the p2p_map
> > callback calls the right dma map function (for page or io) rather than
> > having to define some format that would pass down the information.
> 
> >>
> >> Worry about optimizing away the struct page overhead later?
> > 
> > Struct page do not fit well for GPU as the BAR address can be reprogram
> > to point to any page inside the device memory (think 256M BAR versus
> > 16GB device memory). Forcing struct page on GPU driver would require
> > major surgery to the GPU driver inner working and there is no benefit
> > to have from the struct page. So it is hard to justify this.
> 
> I think we have to consider the struct pages to track the address space,
> not what backs it (essentially what HMM is doing). If we need to add
> operations for the driver to map the address space/struct pages back to
> physical memory then do that. Creating a whole new idea that's tied to
> userspace VMAs still seems wrong to me.

VMA is the object RDMA works on, GPU driver have been working with
VMA too, where VMA is tie to only one specific GPU object. So the most
disrupting approach here is using struct page. It was never use and
will not be use in many driver. Updating those to struct page is too
risky and too much changes. The vma call back is something you can
remove at any time if you have something better that do not need major
surgery to GPU driver.

Cheers,
Jérôme

