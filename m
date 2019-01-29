Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1CF5C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65E3920882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65E3920882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08E6B8E0002; Tue, 29 Jan 2019 16:50:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03B2A8E0001; Tue, 29 Jan 2019 16:50:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6C3B8E0002; Tue, 29 Jan 2019 16:50:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA1B08E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:50:35 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k66so23533739qkf.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ZXI404T+03D//jv2LYIaMJeFBX5P/4NoutNcTZvFGm0=;
        b=kRviiAkJ1hv69Sv0QlA8at1Xy0/0NPDGWv7lTYbLWy+/tXqI6xDujzzu2OtEBOLJck
         ZO9m+HgyDhPSGj3hmtTiw/5vVPX5LKhPO206/dKtBpMEGRgMkMLItF65HD+9wHweV9Ul
         DriewLWMIIXhF5fIXrACAXsoxFvOZTdxkY/smli977rmQjmWdW4vOAQ0HqgPa8LzkMLd
         D+V0Oy1CBfgM6McbEEdsBlY4kyYjXJGfWuTMJ64j7jfNg3n8ziTIcqfdQoVRBIaqUx+0
         slkRGv7U3XNOIfTkDul8Z8W8Po0MMUmTAAbRHuRV5ti4o2fjsVmT0zVrDqdFd+6yrl3z
         2E1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcs12nXoGXTeHFX6CbCvDYjkKt532B8DbEBu+syNePcsfhz8XAM
	+ydlRkAN1ObJ+NXjj6xGptyDg6SCL6oFFakNAF/rJTL4sCqoY5VWXSaUBl6Cdcst3NAtUVtD3Ed
	47r5hIWmNEYdsFU3PcHy6zP6JQYN+wPkDRPKT8O9Nl8iq81H+iy0FpQZlPVWuAKguZw==
X-Received: by 2002:a0c:884d:: with SMTP id 13mr26274128qvm.170.1548798635450;
        Tue, 29 Jan 2019 13:50:35 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Z8goW/VBNpa2akVaBacvtu8OVfIviLretQevoPkasXFXf4i3wI0X2CI5gClEbCFofT+WV
X-Received: by 2002:a0c:884d:: with SMTP id 13mr26274096qvm.170.1548798634699;
        Tue, 29 Jan 2019 13:50:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548798634; cv=none;
        d=google.com; s=arc-20160816;
        b=p0FbQUc6e1IsBnozZTQ6UZq+uPb4CzsF+kugasyaCWDL63uoZxaLQj3HEsrjWVPHb7
         i8IWz0nikFqEHRz9m5Fw5es6cxjEN78SF+5jOFPWUQ8aCiydZuF0sTAhNNpbk6Td0TeK
         UZ+rywupXw06aoZw3ySFuCQXcUE4Roqtf1c/S2X68b9EbIXEZVRWvFsSoC7f28q9K1jF
         2GfErLF8Fn4rP5zFqtVHVubhfC5FW6d5RxJaEBPL101IrU9Qgs9QnYSyiCi73/WyhxrO
         VXDBtHNVh4SsWrCUf2/0KdveSfSIXrc+q3957pmgrk5LGW+ADWMyDimY2TAkfVcMJV47
         ECHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ZXI404T+03D//jv2LYIaMJeFBX5P/4NoutNcTZvFGm0=;
        b=O1B1oCFboVESv2+yVi5zobLM1iSI64alrQRl8WNFGWC21Xy17y+OK6ydV/HNv2GRVG
         0MwP50mTU/jtvsLlq7kY7wQ5tYrDd7tBiCP1NNxKSw1Goi6DC5xhysJNob74U0DUIfJ/
         Hz+Z0Al1MrFzeBFTU177kUZ+6mKx3wkX1zGfHKDsDCuyqMA7lOnFKUc8eEI3+nkCYsjT
         IxSzSYCT2OhMI7ORqZ95C6huQaqvPykDxxhLWlcCauf2/g3WDxDarVAvVmCrldX7+zmr
         0Usogzlu9AzophLltyE1XuGFc5FezlbMzx01h36HBu66q8+hLCqc90v1B/Sjlucklq95
         BgiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j13si188718qtj.296.2019.01.29.13.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 13:50:34 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 43ADD89AE0;
	Tue, 29 Jan 2019 21:50:33 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DF41384E2;
	Tue, 29 Jan 2019 21:50:30 +0000 (UTC)
Date: Tue, 29 Jan 2019 16:50:28 -0500
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
Message-ID: <20190129215028.GQ3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 29 Jan 2019 21:50:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 02:30:49PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 1:57 p.m., Jerome Glisse wrote:
> > GPU driver must be in control and must be call to. Here there is 2 cases
> > in this patchset and i should have instead posted 2 separate patchset as
> > it seems that it is confusing things.
> > 
> > For the HMM page, the physical address of the page ie the pfn does not
> > correspond to anything ie there is nothing behind it. So the importing
> > device has no idea how to get a valid physical address from an HMM page
> > only the device driver exporting its memory with HMM device memory knows
> > that.
> > 
> > 
> > For the special vma ie mmap of a device file. GPU driver do manage their
> > BAR ie the GPU have a page table that map BAR page to GPU memory and the
> > driver _constantly_ update this page table, it is reflected by invalidating
> > the CPU mapping. In fact most of the time the CPU mapping of GPU object are
> > invalid they are valid only a small fraction of their lifetime. So you
> > _must_ have some call to inform the exporting device driver that another
> > device would like to map one of its vma. The exporting device can then
> > try to avoid as much churn as possible for the importing device. But this
> > has consequence and the exporting device driver must be allow to apply
> > policy and make decission on wether or not it authorize the other device
> > to peer map its memory. For GPU the userspace application have to call
> > specific API that translate into specific ioctl which themself set flags
> > on object (in the kernel struct tracking the user space object). The only
> > way to allow program predictability is if the application can ask and know
> > if it can peer export an object (ie is there enough BAR space left).
> 
> This all seems like it's an HMM problem and not related to mapping
> BARs/"potential BARs" to userspace. If some code wants to DMA map HMM
> pages, it calls an HMM function to map them. If HMM needs to consult
> with the driver on aspects of how that's mapped, then that's between HMM
> and the driver and not something I really care about. But making the
> entire mapping stuff tied to userspace VMAs does not make sense to me.
> What if somebody wants to map some HMM pages in the same way but from
> kernel space and they therefore don't have a VMA?

No this is the non HMM case i am talking about here. Fully ignore HMM
in this frame. A GPU driver that do not support or use HMM in anyway
has all the properties and requirement i do list above. So all the points
i was making are without HMM in the picture whatsoever. I should have
posted this a separate patches to avoid this confusion.

Regarding your HMM question. You can not map HMM pages, all code path
that would try that would trigger a migration back to regular memory
and will use the regular memory for CPU access.


> >> I also figured there'd be a fault version of p2p_ioremap_device_memory()
> >> for when you are mapping P2P memory and you want to assign the pages
> >> lazily. Though, this can come later when someone wants to implement that.
> > 
> > For GPU the BAR address space is manage page by page and thus you do not
> > want to map a range of BAR addresses but you want to allow mapping of
> > multiple page of BAR address that are not adjacent to each other nor
> > ordered in anyway. But providing helper for simpler device does make sense.
> 
> Well, this has little do with the backing device but how the memory is
> mapped into userspace. With p2p_ioremap_device_memory() the entire range
> is mapped into the userspace VMA immediately during the call to mmap().
> With p2p_fault_device_memory(), mmap() would not actually map anything
> and a page in the VMA would be mapped only when userspace accesses it
> (using fault()). It seems to me like GPUs would prefer the latter but if
> HMM takes care of the mapping from userspace potential pages to actual
> GPU pages through the BAR then that may not be true.

Again HMM has nothing to do here, ignore HMM it does not play any role
and it is not involve in anyway here. GPU want to control what object
they allow other device to access and object they do not allow. GPU driver
_constantly_ invalidate the CPU page table and in fact the CPU page table
do not have any valid pte for a vma that is an mmap of GPU device file
for most of the vma lifetime. Changing that would highly disrupt and
break GPU drivers. They need to control that, they need to control what
to do if another device tries to peer map some of their memory. Hence
why they need to implement the callback and decide on wether or not they
allow the peer mapping or use device memory for it (they can decide to
fallback to main memory).

If the exporter can not control than this is useless to GPU driver. I
would rather not exclude GPU driver from this.

Cheers,
Jérôme

