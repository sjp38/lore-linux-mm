Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA981C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:45:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49F1C20881
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:45:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49F1C20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 134B58E0002; Wed, 30 Jan 2019 16:45:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5338E0001; Wed, 30 Jan 2019 16:45:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F16318E0002; Wed, 30 Jan 2019 16:45:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C796E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:45:33 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y83so1086723qka.7
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:45:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=uQOLvgOGS38oDc/+HAlE5dqtS5KNJ8lj0KQVNGrXSZQ=;
        b=jqiPnsc/Rr8h1t1beLjgJM2Fwsb0IVTfu4DM799DR+iDOXuzC9TtusHVn72N04DItI
         cYF1FpmVFkI6sX46n9aRXhl8VwpFWj4hiFkj/lE5RsQSvhsnwcb2tRzJ+aifu9yo9D4U
         2zucEzcJEFUoJomMmTgf56m5kgooKMiWL1H3U09/Hg7SfgGCQyJwwZBbnokuW5Lj1ElB
         dz8CBDBYf7PYs0J4heAWZQgfAL7f+3fRb7gCRR4kxPLSCcSE7v2iw98kYSAqHVhYFsCp
         KBl2zCllCGuDmdYxppleVcUh1/mFUUKNvmXQmEntM99wGDobvqsXXHKHHNJ2wvRjjXaK
         VttA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfZPdYe4zWCc1eCRny0KOBxE+Kx49a2GO5IsCex8ZrluQMz9Ubx
	3eHIUftZjJ05rQT/8LKCWo95+gM66bOn/IQCK5VH4vWlNpoCd5jZm5OdjWMwfVTEUgfpgr4YXNN
	t4JZDov2J7GaMkV2eI0fgkE2r7DF9VNPuOO8vqfPOVEVyi/u9032Q3HGKFaun1wqfcw==
X-Received: by 2002:a37:7206:: with SMTP id n6mr28812827qkc.64.1548884733494;
        Wed, 30 Jan 2019 13:45:33 -0800 (PST)
X-Google-Smtp-Source: ALg8bN79Zpjm0H67a5Kd68BGgp9wYt/o+fXRA97CR4Brq3fIFcKhOZ6oBz1mjO7pzAUsf0WA0eTm
X-Received: by 2002:a37:7206:: with SMTP id n6mr28812791qkc.64.1548884732793;
        Wed, 30 Jan 2019 13:45:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548884732; cv=none;
        d=google.com; s=arc-20160816;
        b=pKyZpaTVHgPGXBzPplR2z5iMsg46s1SZ0fdFxEPh+fojA41zL4bh0AnFJOZ1UF88Mt
         4iy/dXLcLy72eEozJ78BfSaaQ22Fb+Teb+ZJ2d+4WWURpq1QPBZPDVeEIpPgaJsrJMVT
         2ZQtgaiMB5ZhqryHixA4bDw1JDcX3CEpc3FJtyEA+FP17h9GscYXHqaQh2rgT6J5asCM
         Wsuuy/VtdQQkJPy7TXm/UUpl+qStnyh6Q84covph+hjDcB2XpjFePif+KwWRJ4/XFuvj
         1eFIxsyRN11uSoaTBFfadyb46+tXyUxhyHbO9qbRyuNSy3pxq3yg68UiDtH98S9SmjWz
         e8IQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=uQOLvgOGS38oDc/+HAlE5dqtS5KNJ8lj0KQVNGrXSZQ=;
        b=NmYWZ93vnVvF4SBRewwkQ+sNgpFwgcUNzJMAwFCwUxA9JDhDZkVJWgR32wUOZRxk0s
         FntbQp7pUkCQbG3oS+GScgBZjDOI1X46nnJGy0bs3xGbzsYPrL0JtX7p0FX3hi6o3gBM
         F5Q1/7jkRPAHOcciEcnwbXRbFyQNTu7jNyQI4qm7GvCvP8szXvTBETSofgzwPwMRupNh
         BYZeTQarIR7CQi42jmvwj6Dqqru9xZ9XHKWWDZV7Mmpq+Pp+7m2Z9vd/1oozpdV3z7WM
         LWzGAF+zcoGVjQwoEnSi1OwfOimJQtB3/HUIlOjFNloTDT0/EiguocJ48pYFpJ29Wkby
         W/iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f57si2080001qtf.362.2019.01.30.13.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 13:45:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ECD93C0586AE;
	Wed, 30 Jan 2019 21:45:30 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 90D7B608E5;
	Wed, 30 Jan 2019 21:45:27 +0000 (UTC)
Date: Wed, 30 Jan 2019 16:45:25 -0500
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
Message-ID: <20190130214525.GG5061@redhat.com>
References: <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com>
 <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com>
 <20190130204332.GF5061@redhat.com>
 <20190130204954.GI17080@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130204954.GI17080@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 30 Jan 2019 21:45:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 08:50:00PM +0000, Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 03:43:32PM -0500, Jerome Glisse wrote:
> > On Wed, Jan 30, 2019 at 08:11:19PM +0000, Jason Gunthorpe wrote:
> > > On Wed, Jan 30, 2019 at 01:00:02PM -0700, Logan Gunthorpe wrote:
> > > 
> > > > We never changed SGLs. We still use them to pass p2pdma pages, only we
> > > > need to be a bit careful where we send the entire SGL. I see no reason
> > > > why we can't continue to be careful once their in userspace if there's
> > > > something in GUP to deny them.
> > > > 
> > > > It would be nice to have heterogeneous SGLs and it is something we
> > > > should work toward but in practice they aren't really necessary at the
> > > > moment.
> > > 
> > > RDMA generally cannot cope well with an API that requires homogeneous
> > > SGLs.. User space can construct complex MRs (particularly with the
> > > proposed SGL MR flow) and we must marshal that into a single SGL or
> > > the drivers fall apart.
> > > 
> > > Jerome explained that GPU is worse, a single VMA may have a random mix
> > > of CPU or device pages..
> > > 
> > > This is a pretty big blocker that would have to somehow be fixed.
> > 
> > Note that HMM takes care of that RDMA ODP with my ODP to HMM patch,
> > so what you get for an ODP umem is just a list of dma address you
> > can program your device to. The aim is to avoid the driver to care
> > about that. The access policy when the UMEM object is created by
> > userspace through verbs API should however ascertain that for mmap
> > of device file it is only creating a UMEM that is fully covered by
> > one and only one vma. GPU device driver will have one vma per logical
> > GPU object. I expect other kind of device do that same so that they
> > can match a vma to a unique object in their driver.
> 
> A one VMA rule is not really workable.
> 
> With ODP VMA boundaries can move around across the lifetime of the MR
> and we have no obvious way to fail anything if userpace puts a VMA
> boundary in the middle of an existing ODP MR address range.

This is true only for vma that are not mmap of a device file. This is
what i was trying to get accross. An mmap of a file is never merge
so it can only get split/butcher by munmap/mremap but when that happen
you also need to reflect the virtual address space change to the
device ie any access to a now invalid range must trigger error.

> 
> I think the HMM mirror API really needs to deal with this for the
> driver somehow.

Yes the HMM does deal with this for you, you do not have to worry about
it. Sorry if that was not clear. I just wanted to stress that vma that
are mmap of a file do not behave like other vma hence when you create
the UMEM you can check for those if you feel the need.

Cheers,
Jérôme

