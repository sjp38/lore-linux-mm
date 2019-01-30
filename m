Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F64FC282D0
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 02:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF69221873
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 02:48:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF69221873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CA1F8E0004; Tue, 29 Jan 2019 21:48:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37A698E0001; Tue, 29 Jan 2019 21:48:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26A5C8E0004; Tue, 29 Jan 2019 21:48:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFFD58E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 21:48:58 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w19so27291411qto.13
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:48:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=VNLB9n0ApiJu82gkCjuCwQtMkl/Gta4BlPMuP0fYWxE=;
        b=j+Bp0co02XW6r47aMQYzThKnmd2YeLZaTAmx3sdm+93p6SI9JcwbYmq98ASCkewwMS
         KC0NSSz5bESqmGnP+qCT1M+vsXEwHXb4CS2dbY374teK5jSGTxPc+O98RIRB1mLDqjMb
         8CRUgE/zOnkvxhcu+9hYB3qRdcIvhk/zne9RKXUxZR1IH2NRaXf7KoFBfv2q1tHuPast
         tw6a/IcaVsMPlrBj6rWe4Yt685kXvOuGl5tc37EDN8ZC7EqL4aAsVzprm1MZDpKv0RfI
         +wxYquXHmbsiuzPoipyEpgOTiiONfYADSM53zBWBTQiXpGz8/bGEfihOH1zYJ0MmyyxC
         LOMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfo7Hp1BsGV6RzF3+uca9ae3UpT/PBy7hpoIWfejY7781tXRxmu
	oXdO7Lx9THYHNgk36U8Tk922F9HO4ZrsEw3dxre/GNAU7qjLotgqA1Al8cvSvBMcU1PEy221g9Y
	u6/7P7DXGL/sYftwWHn1ZtdZpaqd5QLuz1UcKgR8OQv6dBGbBXa54cAFOaAQwcNI8Ww==
X-Received: by 2002:a0c:9dc6:: with SMTP id p6mr27487313qvf.217.1548816538654;
        Tue, 29 Jan 2019 18:48:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN60/vMJdXrV9vNHVD7uRlg3u2EwvUGksnLn9XWLDqRV0gwj5KBiml4KWNtQBFQg05zxIzJk
X-Received: by 2002:a0c:9dc6:: with SMTP id p6mr27487270qvf.217.1548816537708;
        Tue, 29 Jan 2019 18:48:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548816537; cv=none;
        d=google.com; s=arc-20160816;
        b=RSE+RHmY0bxRTNHlFyA2nADzLx+BUD3zr+B5ZgLlLT5V23+vBEahfZ2Z1RKvdpwY5u
         rvi+Uy4Kmp+LBVysDCjccve3ToszZ4thAavMFBTC5u5SB5P/Mop26Hd3qlNFiRR+InGY
         oWHM5l/aD9HqtFnjqbDKeD07MXS/6BRObtUxakk5jw2MhuPK+VkovXVJX2k8fFuc3Ko3
         5QxdKpsBLzvPzHXNVPc2ITn9ENQvmhFuPAw0o4Deoh1LaXEkZa3q7T58X2THxtFcSN60
         Hc+5Kx9sJ1N6IB2EOo+A6m/ddM/AZcPpKy9/SpzBbiCj0yzYPifgsqhPEPW4HWPrgA78
         JhqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=VNLB9n0ApiJu82gkCjuCwQtMkl/Gta4BlPMuP0fYWxE=;
        b=ANVSlkn6N8AEOqGClmMU7sKMWNQgRQhd3hFVCjxxe6CGJEcdHjrPxoUZs1bnBNzoRw
         CPmH0Eopq48ThDlmWi9DVjl2h3MrD5b0DM+xN2noLUgWjtNmuAzUAEFs9aRQz5fxu//r
         +zJMguBEnxqNrnNElOV3d/6CfGyVk53ncO4N6iX/HdizmtLd+SwlGOVYHlLqCJOfPIoi
         rAzDsLPGfx0h5g04JZX3kPEJ3AbDliVGfqq6sNXJx9kis9gMhXQhB8qBUflqELWOjH1t
         FiFUFtvOXd0R6T/ImEhmNca16iTDZ1lJV0Vpe/PHhvFFlndqLuzEcKzvlqzkYSG5DhvL
         vtLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u48si155609qte.81.2019.01.29.18.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 18:48:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6B06989AD4;
	Wed, 30 Jan 2019 02:48:56 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0DF4F19C65;
	Wed, 30 Jan 2019 02:48:53 +0000 (UTC)
Date: Tue, 29 Jan 2019 21:48:52 -0500
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
Message-ID: <20190130024851.GB10462@redhat.com>
References: <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 30 Jan 2019 02:48:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:17:43PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 4:47 p.m., Jerome Glisse wrote:
> > The whole point is to allow to use device memory for range of virtual
> > address of a process when it does make sense to use device memory for
> > that range. So they are multiple cases where it does make sense:
> > [1] - Only the device is accessing the range and they are no CPU access
> >       For instance the program is executing/running a big function on
> >       the GPU and they are not concurrent CPU access, this is very
> >       common in all the existing GPGPU code. In fact AFAICT It is the
> >       most common pattern. So here you can use HMM private or public
> >       memory.
> > [2] - Both device and CPU access a common range of virtul address
> >       concurrently. In that case if you are on a platform with cache
> >       coherent inter-connect like OpenCAPI or CCIX then you can use
> >       HMM public device memory and have both access the same memory.
> >       You can not use HMM private memory.
> > 
> > So far on x86 we only have PCIE and thus so far on x86 we only have
> > private HMM device memory that is not accessible by the CPU in any
> > way.
> 
> I feel like you're just moving the rug out from under us... Before you
> said ignore HMM and I was asking about the use case that wasn't using
> HMM and how it works without HMM. In response, you just give me *way*
> too much information describing HMM. And still, as best as I can see,
> managing DMA mappings (which is different from the userspace mappings)
> for GPU P2P should be handled by HMM and the userspace mappings should
> *just* link VMAs to HMM pages using the standard infrastructure we
> already have.

For HMM P2P mapping we need to call into the driver to know if driver
wants to fallback to main memory (running out of BAR addresses) or if
it can allow a peer device to directly access its memory. We also need
the call to exporting device driver as only the exporting device driver
can map the HMM page pfn to some physical BAR address (which would be
allocated by driver for GPU).

I wanted to make sure the HMM case was understood too, sorry if it
caused confusion with the non HMM case which i describe below.


> >> And what struct pages are actually going to be backing these VMAs if
> >> it's not using HMM?
> > 
> > When you have some range of virtual address migrated to HMM private
> > memory then the CPU pte are special swap entry and they behave just
> > as if the memory was swapped to disk. So CPU access to those will
> > fault and trigger a migration back to main memory.
> 
> This isn't answering my question at all... I specifically asked what is
> backing the VMA when we are *not* using HMM.

So when you are not using HMM ie existing GPU object without HMM then
like i said you do not have any valid pte most of the time inside the
CPU page table ie the GPU driver only populate the pte with valid
entry when they are CPU page fault and it clear those as soon as the
corresponding object is use by the GPU. In fact some driver also unmap
it agressively from the BAR making the memory totaly un-accessible to
anything but the GPU.

GPU driver do not like CPU mapping, they are quite aggressive about
clearing them. Then everything i said about having userspace deciding
which object can be share, and, with who, do apply here. So for GPU you
do want to give control to GPU driver and you do not want to require valid
CPU pte for the vma so that the exporting driver can return valid
address to the importing peer device only.

Also exporting device driver might decide to fallback to main memory
(running out of BAR addresses for instance). So again here we want to
go through the exporting device driver so that it can take the right
action.

So the expected pattern (for GPU driver) is:
    - no valid pte for the special vma (mmap of device file)
    - importing device call p2p_map() for the vma if it succeed the
      first time then we expect it will succeed for the same vma and
      range next time we call it.
    - exporting driver can either return physical address to page
      into its BAR space that point to the correct device memory or
      fallback to main memory

Then at any point in time:
    - if GPU driver want to move the object around (for whatever
      reasons) it calls zap_vma_ptes() the fact that there is no
      valid CPU pte does not matter it will call mmu notifier and thus
      any importing device driver will invalidate its mapping
    - importing device driver that lost the mapping due to mmu
      notification can re-map by re-calling p2p_map() (it should
      check that the vma is still valid ...) and guideline is for
      the exporting device driver to succeed and return valid
      address to the new memory use for the object

This allow device driver like GPU to keep control. The expected
pattern is still the p2p mapping to stay undisrupted for their
whole lifetime. Invalidation should only be triggered if GPU driver
do need to move things around.

All the above is for the no HMM case ie mmap of a device file so
for any existing open source GPU device driver that do not support
HMM.

Cheers,
Jérôme

