Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA8E3C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AED9F20869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:58:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AED9F20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56DF48E0002; Tue, 29 Jan 2019 15:58:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51D168E0001; Tue, 29 Jan 2019 15:58:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6AE8E0002; Tue, 29 Jan 2019 15:58:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 103E98E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:58:00 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d35so26310508qtd.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:58:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=MNCvqzS1AdnHITVzgsI2Q0u25f/OXmifvxfJdUAqf7I=;
        b=pAe/u9UIEigtPCodWPz1n/cQXMXmuvPO7TbGuVqFObH1THn3Jvh+Sf1YxPDqtPj/wv
         zjqFAge2e/K15ZTP37qWey02z9NOi/nPFSgT+u0k/3F4Imor7Luw4IhnJBMmZdeVOjI0
         REwgUWEwXOjmg3Mo6qV05xzR3iuyQdXKoDGlu74RMkmM9gAin86MMfwbsn+4hwo7Zd//
         AMf75mkVgO0wDxFOaw+pBZaWIuWFliDtNv9JKOp5y4hyXvX2O6KOQ4RS0Fn24ovSx8CY
         WaNXwUtoeB3omFWsZ19JOKlQkNR4vZUDS3gje/0U6kqRAM0zU3NhCqXpmAVep8Xc6woi
         4gbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukc7kqzlD40zFbP8myf/6YRgtQMRyMIOwMOn+mnu9bNR2Tlbd5K3
	P48D7F6jOroSptvGVxJV+C0915yTjXl3d2J5AEWVu28f40kYrqkXywmU/N2qT0DvpX+IpXb0JOD
	PF4P2LNu1Z7BiimFGNvn7s93kpF0UC2Q7GUz8QMHf9s8w50PG+qhcO1B2ssRNVaQRFw==
X-Received: by 2002:ac8:7950:: with SMTP id r16mr27546401qtt.12.1548795479828;
        Tue, 29 Jan 2019 12:57:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5ZBaJJKFGjWVjZQJK/C3F9CKwhiLNFk+nv/D9Nyq8YEWlj+pJCGrLVfQqhW+fuEDh141Ib
X-Received: by 2002:ac8:7950:: with SMTP id r16mr27546371qtt.12.1548795479155;
        Tue, 29 Jan 2019 12:57:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548795479; cv=none;
        d=google.com; s=arc-20160816;
        b=a/CCUvbK6olgP7mRAQbJbjm2MDt3GJb26ZFL+U1xXrZKut735jrOaAgY2JVhV1BWY0
         alJ5wl0bZWBz6ZDDJSucacVKp+2BRbrF3IkPyzVulRYNC0Y0JwyLdqOxiah+/vT5XqLu
         Shp3QtQPYUpqxGNuuyHJpousligWHPvpCpdZ0zCnGB6txpSb8/+DmYmDFehnqEW/O9Is
         HB1S7Qy/C+82GKLjwB7i08GNr98sYyosPjInPzUo6JE20T4aG0mUq6EkWbdnTfilyR40
         /YukTDu5cFQzJTgv2MYkxYbB6+n4hEi3ESALh3rJSeI7Ca0s0WFNQc43jVuADVZGLqUr
         KIwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=MNCvqzS1AdnHITVzgsI2Q0u25f/OXmifvxfJdUAqf7I=;
        b=gZSP5y94cVuX7ffQZqHLCiHxydjoo2h+f4E31m8n5NNfqdQ7TMygIRytEcmuCVNnrD
         FFcBRmPOTNwCOJgpQpyKFSW5q43GGW1LxJCbGlgE0hlDuCIgXsOJnjkVJJzHRDdNcf7D
         pW74IO0ql8nTMco8ZhoO1KLiC7PYNLBXHn1uHzlybuNdl6612GBNQdCx522Gn96rAK1F
         HN0GzBAG0UZjbdTax//o4jUg7jA37X0GYjXOsTbbbfVdg+5/f6rzfBB7I6E0/ufStfBW
         GbB7bt2DkBLxYHgCPvw3Mwr7RPCaw5gXbNT05lvXw/XpOupEpTMXGspK/O+ChZsMJ2aW
         cLBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u11si4298299qvl.90.2019.01.29.12.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 12:57:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 256123DE03;
	Tue, 29 Jan 2019 20:57:58 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A46D119745;
	Tue, 29 Jan 2019 20:57:54 +0000 (UTC)
Date: Tue, 29 Jan 2019 15:57:50 -0500
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
Message-ID: <20190129205749.GN3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 29 Jan 2019 20:57:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 01:39:49PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 12:32 p.m., Jason Gunthorpe wrote:
> > Jerome, I think it would be nice to have a helper scheme - I think the
> > simple case would be simple remapping of PCI BAR memory, so if we
> > could have, say something like:
> > 
> > static const struct vm_operations_struct my_ops {
> >   .p2p_map = p2p_ioremap_map_op,
> >   .p2p_unmap = p2p_ioremap_unmap_op,
> > }
> > 
> > struct ioremap_data {
> >   [..]
> > }
> > 
> > fops_mmap() {
> >    vma->private_data = &driver_priv->ioremap_data;
> >    return p2p_ioremap_device_memory(vma, exporting_device, [..]);
> > }
> 
> This is roughly what I was expecting, except I don't see exactly what
> the p2p_map and p2p_unmap callbacks are for. The importing driver should
> see p2pdma/hmm struct pages and use the appropriate function to map
> them. It shouldn't be the responsibility of the exporting driver to
> implement the mapping. And I don't think we should have 'special' vma's
> for this (though we may need something to ensure we don't get mapping
> requests mixed with different types of pages...).

GPU driver must be in control and must be call to. Here there is 2 cases
in this patchset and i should have instead posted 2 separate patchset as
it seems that it is confusing things.

For the HMM page, the physical address of the page ie the pfn does not
correspond to anything ie there is nothing behind it. So the importing
device has no idea how to get a valid physical address from an HMM page
only the device driver exporting its memory with HMM device memory knows
that.


For the special vma ie mmap of a device file. GPU driver do manage their
BAR ie the GPU have a page table that map BAR page to GPU memory and the
driver _constantly_ update this page table, it is reflected by invalidating
the CPU mapping. In fact most of the time the CPU mapping of GPU object are
invalid they are valid only a small fraction of their lifetime. So you
_must_ have some call to inform the exporting device driver that another
device would like to map one of its vma. The exporting device can then
try to avoid as much churn as possible for the importing device. But this
has consequence and the exporting device driver must be allow to apply
policy and make decission on wether or not it authorize the other device
to peer map its memory. For GPU the userspace application have to call
specific API that translate into specific ioctl which themself set flags
on object (in the kernel struct tracking the user space object). The only
way to allow program predictability is if the application can ask and know
if it can peer export an object (ie is there enough BAR space left).

Moreover i would like to be able to use this API between GPUs that are
inter-connected between each other and for those the CPU page table are
just invalid and the physical address to use are only meaning full to the
exporting and importing device. So again here core kernel has no idea of
what the physical address would be.


So in both cases, at very least for GPU, we do want total control to be
given to the exporter.

> 
> I also figured there'd be a fault version of p2p_ioremap_device_memory()
> for when you are mapping P2P memory and you want to assign the pages
> lazily. Though, this can come later when someone wants to implement that.

For GPU the BAR address space is manage page by page and thus you do not
want to map a range of BAR addresses but you want to allow mapping of
multiple page of BAR address that are not adjacent to each other nor
ordered in anyway. But providing helper for simpler device does make sense.

Cheers,
Jérôme

