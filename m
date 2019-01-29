Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ED28C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:51:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A8F02080F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:51:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A8F02080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF1DE8E0001; Tue, 29 Jan 2019 14:51:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCA1A8E0002; Tue, 29 Jan 2019 14:51:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA1248E0001; Tue, 29 Jan 2019 14:51:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 900BE8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:51:02 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id r145so23092155qke.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:51:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=d8daq5x8Q/FOO0VpmXfcs4RHoiPtUhcFgcdzyiY7Oe0=;
        b=BayxRygw3wGW2RG08KnTXXsP+7ocHMdGYLr54+AlS9U2qBbAKfrRX42dEJx1FKGOot
         Jx6xXv+hzcy0FCFkgA+e/KB6JfNq1/elA1lNUxrtKLCrWR5gUXI69esZSWYR/d0eo3Ku
         hPghD1fb5R6fXJhA0vvG+jy1nE0vYaPxMjqGWOB3xgteXP7UU7nwkeByNzQ4jJ8fiNJ3
         u1b5xc+qi1ZHOKTe/qn6/F93U02jZ8Y6vTgujgIzp7EdPd5rQYAZBvdexA89Po/NM2DH
         pOyL4T+4YCqgQksHNhvx2tFptYsExMjKRkJOaxV/Ii/otA/DBy/oIfB+/VylGnlI3N4l
         R7Bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukezQZFb+wc0YAOX2cD28Xat8589INLFSCMUKloqr753ZwDBq9ev
	lEdUA7EGZx7h0PVUVLRVFEj4rCDNog13hK/oRdjI2MOpOovkkK9UVJ6kZmgRVinhkB/rZe+20WU
	e0F9Z4Db4ZZP6BXGRYEtkbHjZdxZDZqd/zK+Uys51AVjrmJluBRJogLtjJjR936jjUQ==
X-Received: by 2002:aed:3084:: with SMTP id 4mr26838390qtf.30.1548791462330;
        Tue, 29 Jan 2019 11:51:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6aBs3cnRQ365qdlEGS+gkUzgV1IjGqjL05Mk2d6wXLWoYVINQlmbXVdokuwZbABIBpeHFA
X-Received: by 2002:aed:3084:: with SMTP id 4mr26838349qtf.30.1548791461599;
        Tue, 29 Jan 2019 11:51:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791461; cv=none;
        d=google.com; s=arc-20160816;
        b=G7EWC8TrXYoCLuFFtbqpGvj6HjuGKvx51SVrv3MOJFbFgtWmUnIznENvScCIfoVJWu
         XreOF0TebX/bivxyulUvZUnTnMjTHLBq3iQoBeULcTNIychFVMfn7GNnCBAm/CCwILhW
         pZqnwudxro0qRWQ6FKi8UFoi344jN2E4aqG/ZrWRRz8L/3VSfmEbMUGNFpM+8aJtCxTl
         f838g+cqohQuL6VEs9wNFySJrcnW+nrPXL74rugQKD1OI5S0wYUC4WCk6Kay+l6Fagiz
         VxMtDsIjBazvQk259TV9YKjzCAi3/v5HN91dwqFLFua3ufMLuxZoCf9rMqluNclxSxSP
         cVmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=d8daq5x8Q/FOO0VpmXfcs4RHoiPtUhcFgcdzyiY7Oe0=;
        b=xm1+/v7GboIqlCoCMNoSnuGd1Bx0n1MGh1TpfvoN9JAmNaDhilPWNGxxuJegySlvLC
         eVrpOoiNiMYiNzCq7KIartZIVx51jgMw9C3I6+j39Y+E7HNCTecc6anhKxDYNvvVWCrR
         TIoqYLqEueOEKXSs7wpiQmEuNY8otCz1K5lYSY1okFWWEgo2u5sQFAt0d7iZCurQg/yL
         DJ4YK+HwiW31Hjv3sX597JZTF6IpRQ5+JaDZiagizpOW3/OcUm2VZgHUO493LwG7iQ9Y
         KrJIzQoHLA0l+WZYwgx2NdK7gNvk4xbYwMrMzkLYIG5V5gjwHL1XDpHeOU1bo/5VT7S2
         HIzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j6si4356419qkk.237.2019.01.29.11.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:51:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5104490901;
	Tue, 29 Jan 2019 19:51:00 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A659053;
	Tue, 29 Jan 2019 19:50:57 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:50:55 -0500
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
Message-ID: <20190129195055.GH3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190129193250.GK10108@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 29 Jan 2019 19:51:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 07:32:57PM +0000, Jason Gunthorpe wrote:
> On Tue, Jan 29, 2019 at 02:11:23PM -0500, Jerome Glisse wrote:
> > On Tue, Jan 29, 2019 at 11:36:29AM -0700, Logan Gunthorpe wrote:
> > > 
> > > 
> > > On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> > > 
> > > > +	/*
> > > > +	 * Optional for device driver that want to allow peer to peer (p2p)
> > > > +	 * mapping of their vma (which can be back by some device memory) to
> > > > +	 * another device.
> > > > +	 *
> > > > +	 * Note that the exporting device driver might not have map anything
> > > > +	 * inside the vma for the CPU but might still want to allow a peer
> > > > +	 * device to access the range of memory corresponding to a range in
> > > > +	 * that vma.
> > > > +	 *
> > > > +	 * FOR PREDICTABILITY IF DRIVER SUCCESSFULY MAP A RANGE ONCE FOR A
> > > > +	 * DEVICE THEN FURTHER MAPPING OF THE SAME IF THE VMA IS STILL VALID
> > > > +	 * SHOULD ALSO BE SUCCESSFUL. Following this rule allow the importing
> > > > +	 * device to map once during setup and report any failure at that time
> > > > +	 * to the userspace. Further mapping of the same range might happen
> > > > +	 * after mmu notifier invalidation over the range. The exporting device
> > > > +	 * can use this to move things around (defrag BAR space for instance)
> > > > +	 * or do other similar task.
> > > > +	 *
> > > > +	 * IMPORTER MUST OBEY mmu_notifier NOTIFICATION AND CALL p2p_unmap()
> > > > +	 * WHEN A NOTIFIER IS CALL FOR THE RANGE ! THIS CAN HAPPEN AT ANY
> > > > +	 * POINT IN TIME WITH NO LOCK HELD.
> > > > +	 *
> > > > +	 * In below function, the device argument is the importing device,
> > > > +	 * the exporting device is the device to which the vma belongs.
> > > > +	 */
> > > > +	long (*p2p_map)(struct vm_area_struct *vma,
> > > > +			struct device *device,
> > > > +			unsigned long start,
> > > > +			unsigned long end,
> > > > +			dma_addr_t *pa,
> > > > +			bool write);
> > > > +	long (*p2p_unmap)(struct vm_area_struct *vma,
> > > > +			  struct device *device,
> > > > +			  unsigned long start,
> > > > +			  unsigned long end,
> > > > +			  dma_addr_t *pa);
> > > 
> > > I don't understand why we need new p2p_[un]map function pointers for
> > > this. In subsequent patches, they never appear to be set anywhere and
> > > are only called by the HMM code. I'd have expected it to be called by
> > > some core VMA code and set by HMM as that's what vm_operations_struct is
> > > for.
> > > 
> > > But the code as all very confusing, hard to follow and seems to be
> > > missing significant chunks. So I'm not really sure what is going on.
> > 
> > It is set by device driver when userspace do mmap(fd) where fd comes
> > from open("/dev/somedevicefile"). So it is set by device driver. HMM
> > has nothing to do with this. It must be set by device driver mmap
> > call back (mmap callback of struct file_operations). For this patch
> > you can completely ignore all the HMM patches. Maybe posting this as
> > 2 separate patchset would make it clearer.
> > 
> > For instance see [1] for how a non HMM driver can export its memory
> > by just setting those callback. Note that a proper implementation of
> > this should also include some kind of driver policy on what to allow
> > to map and what to not allow ... All this is driver specific in any
> > way.
> 
> I'm imagining that the RDMA drivers would use this interface on their
> per-process 'doorbell' BAR pages - we also wish to have P2P DMA to
> this memory. Also the entire VFIO PCI BAR mmap would be good to cover
> with this too.

Correct, you would set those callback on the mmap of your doorbell.

> 
> Jerome, I think it would be nice to have a helper scheme - I think the
> simple case would be simple remapping of PCI BAR memory, so if we
> could have, say something like:
> 
> static const struct vm_operations_struct my_ops {
>   .p2p_map = p2p_ioremap_map_op,
>   .p2p_unmap = p2p_ioremap_unmap_op,
> }
> 
> struct ioremap_data {
>   [..]
> }
> 
> fops_mmap() {
>    vma->private_data = &driver_priv->ioremap_data;
>    return p2p_ioremap_device_memory(vma, exporting_device, [..]);
> }
> 
> Which closely matches at least what the RDMA drivers do. Where
> p2p_ioremap_device_memory populates p2p_map and p2p_unmap pointers
> with sensible functions, etc.
> 
> It looks like vfio would be able to use this as well (though I am
> unsure why vfio uses remap_pfn_range instead of io_remap_pfn range for
> BAR memory..)

Yes simple helper that implement a sane default implementation is
definitly a good idea. As i was working with GPU it was not something
that immediatly poped to mind (see below). But i can certainly do
a sane set of default helper that simple device driver can use right
away without too much thinking on there part. I will add this for
next posting.

> Do any drivers need more control than this?

GPU driver do want more control :) GPU driver are moving things around
all the time and they have more memory than bar space (on newer platform
AMD GPU do resize the bar but it is not the rule for all GPUs). So
GPU driver do actualy manage their BAR address space and they map and
unmap thing there. They can not allow someone to just pin stuff there
randomly or this would disrupt their regular work flow. Hence they need
control and they might implement threshold for instance if they have
more than N pages of bar space map for peer to peer then they can decide
to fall back to main memory for any new peer mapping.

Cheers,
Jérôme

