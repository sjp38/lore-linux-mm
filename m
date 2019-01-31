Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED1EDC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:35:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A92E620B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:35:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A92E620B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57A028E0004; Thu, 31 Jan 2019 14:35:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 529EF8E0001; Thu, 31 Jan 2019 14:35:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F16A8E0004; Thu, 31 Jan 2019 14:35:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1588A8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:35:21 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s70so4425947qks.4
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:35:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=IvEHaX1TTEPsSbzpNtfcjRxaBewFmkv06Tjpa5Xa3BU=;
        b=PAzRAY5z5Uq0orm2xYBRh+Ck1Z+4+7yEkeVeqPdx28DtMmUHtlyWRJqG9faCfuW1f/
         J3m5fpCDaeVPNVdRzsOXDooaHwvL449VxJ5Xa70qyxzF5FHx0DCzqQEMIgENVOzbpOom
         ULRM45awt+esuJEn4s7JdyTb9jFk6ARbNh33IS75pKpwGvc7PZESurd8t67U92zYke3h
         sPYfy0OZu7YdYp8BE/V0YDy6B719Y96+h93nT66zEIvhU8J5yVIGJJEveTNfuXGopgLJ
         T6HIL51FicmdqP+qW/VJDF6XV87VqCUcyLs4p5z/uHG6rIld2d5DdNwAn/BRZb3u5dFo
         t0Zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfCWvS1j5KZyqsFqhQ+tFBQDhnvT1Iy9Kw9V7ZU5od0YDYoLxmp
	B4tMH0R+qKfCQwNb82/oSpZD+AbBakTecGyIDgIYzwIj1VAESXwvk19iDp7R7MfaZGf+CRY6vLh
	hGLbbaWjTqJIGgwBLMcAPPaclWxmwMSgmWXbEDtNry1Rzusd+tpZGECwEc2zRCXdk2w==
X-Received: by 2002:a37:8c04:: with SMTP id o4mr31570834qkd.165.1548963320799;
        Thu, 31 Jan 2019 11:35:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6dZDLhETJ7SLKXICYVyYqXpLwNCTTvnCZkUgCBj739O6Ll3x8dvI+w/zfwJDS4kXzqtPB/
X-Received: by 2002:a37:8c04:: with SMTP id o4mr31570786qkd.165.1548963319839;
        Thu, 31 Jan 2019 11:35:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548963319; cv=none;
        d=google.com; s=arc-20160816;
        b=Apv2YyvTyBkkHxxORLH5yMX0cU2sh1CKKqqKXYqZYJ6oKAuCQf8ySsZbfMhFmwdfnU
         eM1UzJ8ruccP3bbwKvY01P71k1YPjMYNfTYUD0ckNceAWUSWHsaJl+h/Ve20Jq9nzVfO
         vnrEg/jCiQ1sr+nuRk+ymbNmSK7duk7v504RZ795IPuY5kVs4Dx2yjz8XDzWAdiWAEp9
         dymPSg4yirzdXFQoeMDdYM768QFYWG5rgFdpNUhbrHkhrRw1hQkOr2BLLjDnliq/zWeS
         POtRcWM6fdYVqVRQq9YV8Tfv/Gng+Ef94zNAv0mO+JY+KcvCegreE5QzMHMVwJjyxk+w
         5NKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=IvEHaX1TTEPsSbzpNtfcjRxaBewFmkv06Tjpa5Xa3BU=;
        b=noCibDv8PEBE24MkOlxRHB4+zFRRIoaPJk68wEIgu0VfLay08HwUj2wUj3YqQvgdk3
         Ks7f4HE2moZ30CAr3+OCFlHCFaFn+jovcDNAqdm4vCEhb6cWJn3B2jcV12dLWOiLOk9L
         uQsyq0zaAztjw2OzFkf8ywvDWgcFtI13ecSYOlVUdSs4N8nId/8z5mAD3mHAT7b2SzUx
         xNiXfGRi2q39GvjMy3gUpFnhBFYnuWG/EPsuYzfpsYSTTo2uRF0TQOH0pOYuRTSI5MfD
         Q+1N4D7TaEdr7xb6Cy/L3z73fPnRaKeFzjRPuCRdZ3bDbF4QI3Lr22ejmb7XOZKtzDzy
         gHOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h24si585044qve.162.2019.01.31.11.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 11:35:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6D224A4035;
	Thu, 31 Jan 2019 19:35:18 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F08F460C45;
	Thu, 31 Jan 2019 19:35:15 +0000 (UTC)
Date: Thu, 31 Jan 2019 14:35:14 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>,
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
Message-ID: <20190131193513.GC16593@redhat.com>
References: <20190130041841.GB30598@mellanox.com>
 <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
 <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
 <20190131081355.GC26495@lst.de>
 <20190131190202.GC7548@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190131190202.GC7548@mellanox.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 31 Jan 2019 19:35:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 07:02:15PM +0000, Jason Gunthorpe wrote:
> On Thu, Jan 31, 2019 at 09:13:55AM +0100, Christoph Hellwig wrote:
> > On Wed, Jan 30, 2019 at 03:52:13PM -0700, Logan Gunthorpe wrote:
> > > > *shrug* so what if the special GUP called a VMA op instead of
> > > > traversing the VMA PTEs today? Why does it really matter? It could
> > > > easily change to a struct page flow tomorrow..
> > > 
> > > Well it's so that it's composable. We want the SGL->DMA side to work for
> > > APIs from kernel space and not have to run a completely different flow
> > > for kernel drivers than from userspace memory.
> > 
> > Yes, I think that is the important point.
> > 
> > All the other struct page discussion is not about anyone of us wanting
> > struct page - heck it is a pain to deal with, but then again it is
> > there for a reason.
> > 
> > In the typical GUP flows we have three uses of a struct page:
> > 
> >  (1) to carry a physical address.  This is mostly through
> >      struct scatterlist and struct bio_vec.  We could just store
> >      a magic PFN-like value that encodes the physical address
> >      and allow looking up a page if it exists, and we had at least
> >      two attempts at it.  In some way I think that would actually
> >      make the interfaces cleaner, but Linus has NACKed it in the
> >      past, so we'll have to convince him first that this is the
> >      way forward
> 
> Something like this (and more) has always been the roadblock with
> trying to mix BAR memory into SGL. I think it is such a big problem as
> to be unsolvable in one step.. 
> 
> Struct page doesn't even really help anything beyond dma_map as we
> still can't pretend that __iomem is normal memory for general SGL
> users.
> 
> >  (2) to keep a reference to the memory so that it doesn't go away
> >      under us due to swapping, process exit, unmapping, etc.
> >      No idea how we want to solve this, but I guess you have
> >      some smart ideas?
> 
> Jerome, how does this work anyhow? Did you do something to make the
> VMA lifetime match the p2p_map/unmap? Or can we get into a situation
> were the VMA is destroyed and the importing driver can't call the
> unmap anymore?
> 
> I know in the case of notifiers the VMA liftime should be strictly
> longer than the map/unmap - but does this mean we can never support
> non-notifier users via this scheme?

So in this version the requirement is that the importer also have a mmu
notifier registered and that's what all GPU driver do already. Any
driver that map some range of vma to a device should register itself as
a mmu notifier listener to do something when vma goes away. I posted a
patchset a while ago to allow listener to differentiate when the vma is
going away from other type of invalidation [1]

With that in place you can easily handle the pin case. Driver really
need to do something when the vma goes away with GUP or not. As the
device is then writing/reading to/from something that does not match
anything in the process address space.

So user that want pin would register notifier, call p2p_map with pin
flag and ignore all notifier callback except the unmap one when the
unmap one happens they have the vma and they should call p2p_unmap
from their invalidate callback and update their device to either some
dummy memory or program it in a way that the userspace application
will notice.

This can all be handled by some helper so that driver do not have to
write more than 5 lines of code and function to update their device
mapping to something of their choosing.


> 
> >  (3) to make the PTEs dirty after writing to them.  Again no sure
> >      what our preferred interface here would be
> 
> This need doesn't really apply to BAR memory..
> 
> > If we solve all of the above problems I'd be more than happy to
> > go with a non-struct page based interface for BAR P2P.  But we'll
> > have to solve these issues in a generic way first.
> 
> I still think the right direction is to build on what Logan has done -
> realize that he created a DMA-only SGL - make that a formal type of
> the kernel and provide the right set of APIs to work with this type,
> without being forced to expose struct page.
> 
> Basically invert the API flow - the DMA map would be done close to
> GUP, not buried in the driver. This absolutely doesn't work for every
> flow we have, but it does enable the ones that people seem to care
> about when talking about P2P.

This does not work for GPU really i do not want to have to rewrite GPU
driver for this. Struct page is a burden and it does not bring anything
to the table. I rather provide an all in one stop for driver to use
this without having to worry between regular vma and special vma.

Note that in this patchset i reuse chunk of Logan works and intention is
to also allow PCI struct page to work too. But they should not be the
only mechanisms.

> 
> To get to where we are today we'd need a few new IB APIs, and some
> nvme change to work with DMA-only SGL's and so forth, but that doesn't
> seem so bad. The API also seems much more safe and understandable than
> todays version that is trying to hope that the SGL is never touched by
> the CPU.
> 
> It also does present a path to solve some cases of the O_DIRECT
> problems if the block stack can develop some way to know if an IO will
> go down a DMA-only IO path or not... This seems less challenging that
> auditing every SGL user for iomem safety??

So what is this O_DIRECT thing that keep coming again and again here :)
What is the use case ? Note that bio will always have valid struct page
of regular memory as using PCIE BAR for filesystem is crazy (you do not
have atomic or cache coherence and many CPU instruction have _undefined_
effect so what ever the userspace would do might do nothing.

Now if you want to use BAR address as destination or source of directIO
then let just update the directIO code to handle this. There is no need
to go hack every single place in the kernel that might deal with struct
page or sgl. Just update the place that need to understand this. We can
even update directIO to work on weird platform. The change to directIO
will be small, couple hundred line of code at best.

Cheers,
Jérôme

[1] https://lore.kernel.org/linux-fsdevel/20190123222315.1122-1-jglisse@redhat.com/T/#m69e8f589240e18acbf196a1c8aa1d6fc97bd3565

