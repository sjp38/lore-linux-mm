Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F6D2C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:37:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AD64218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:37:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AD64218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE5068E0003; Thu, 31 Jan 2019 10:37:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A94568E0001; Thu, 31 Jan 2019 10:37:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9836C8E0003; Thu, 31 Jan 2019 10:37:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9A78E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:37:44 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n45so4042558qta.5
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:37:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=EbWsIHwQoJ8StzhsW+ZAmsox8ZyuC/z5UiQyJukDsL8=;
        b=SmVbBZA2lKrgutSXLJxbx3J7dsP9xdw7WLGQe6VZsAyz54CDtGi8hKH2oJUd7TSE2I
         ZjHhWlw9Py5MDDilln97ylWXiSa/kacod7pN/u35lH5Lrp55fIShpL7rbrhbtmZf9ANC
         aipgGzoBIdZa7reybPtdpmPwJqT+iFAoZaZKzWL/3SUQpY3Fx1h+A2OxWWLc4mpK10QI
         998h855VqFNUNujiA1KJFqgs9dERuRSEYsglZRZA/BHp3wsCRbBfFaklSvLn4RgBIA6i
         2g6CAeLLDq2AJlAx48pK1MFDceUYKn+BnyjI6Gty9aauyd59z69frdQSXoc9tFI6qVUm
         6Olw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcYaTr5xh4gwcep4PjhRE0czMiLmxmi0j88IOghsAjNyfzsQ017
	0HTzApcCERDSHqVYx8Uni2aVQ4FB1DBwGo1iIbOqdGv2H3DXZtaw115sYxnDwVaVfEmc8GisFJR
	K0jaSJX5QsuG3hAkgr7wJVpfEOn9TWS4bNriKxJsmFNqq+OSUs0Z6uwZ4VSjPEjQo6Q==
X-Received: by 2002:aed:3f22:: with SMTP id p31mr35207166qtf.185.1548949064157;
        Thu, 31 Jan 2019 07:37:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4y1JJ4pjCybfgwj/VTqAaL6eP4GR017JpJkurnV/1iTJ8P9U1KT5XmFFA4dbbxMn1Ku+WQ
X-Received: by 2002:aed:3f22:: with SMTP id p31mr35207119qtf.185.1548949063404;
        Thu, 31 Jan 2019 07:37:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548949063; cv=none;
        d=google.com; s=arc-20160816;
        b=HgrIC/adf3T/MbRB0LKh61PdSjwsMh5qig9KEbHeXhwcpxockTsJ3gDsUGBRf0o5pj
         TO2xanvfcZAiuVbhAbjCV3j/HcDy0KSrciJ7DiE7tQKhf1C5lgETX0wukpPS1rnrIeTN
         SpxgN/KZ/MbdM2qbVLvtMbyyZpLk9WUF4WpNehsMXc4UqtQI+M1lwFvqbHaGZHBGDYHc
         hNR7k8zTVALqgZswqB8zgw6A+g+QSnxU29FIC5sI+pyS/8Av0NxAW6d2wXGkgs5bZliT
         MCOUt284MSEm6oFCugU5PqrpfujX5vN/U0lNI/oVTktzxIZQ4YC8OzScSQ5QdjZTffEv
         yH3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=EbWsIHwQoJ8StzhsW+ZAmsox8ZyuC/z5UiQyJukDsL8=;
        b=f/ap4NXV8mizRgAqHG9dHH3/D4+qXVnSGhbpfBLmcRhUZGjQiDHxg+IBI3aZDMVidp
         Bf4gEv0ZvLkzY5mkP5Ko5EvjmWxH9Crjwkchad4NnU4oRmOv7CyCmr/BHAU8A1O2ky5x
         KZicphKlm/C/l7NcXf3i0m+ISYlf1z5FNyxnO3u8I6X0nrpt4Iq/xpownvjEG6McvB63
         4o3Uqi2M3ZZ3aKwBXDYbwHKSKMsMtiih5dTZzgqi4UqIrsna2gso0uXhSWTiXKrY95Tu
         MBbSRr3Cp2losha6hfbNWx3Se99Fb/BJpmUBJRvkoOsb1hRtusl9k33Mtslo6fVfvu3+
         LXNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r68si2351066qke.14.2019.01.31.07.37.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 07:37:43 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0167786671;
	Thu, 31 Jan 2019 15:37:42 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C38DD5C5DE;
	Thu, 31 Jan 2019 15:37:39 +0000 (UTC)
Date: Thu, 31 Jan 2019 10:37:38 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
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
Message-ID: <20190131153737.GD4619@redhat.com>
References: <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
 <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
 <20190131081355.GC26495@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190131081355.GC26495@lst.de>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 31 Jan 2019 15:37:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 09:13:55AM +0100, Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 03:52:13PM -0700, Logan Gunthorpe wrote:
> > > *shrug* so what if the special GUP called a VMA op instead of
> > > traversing the VMA PTEs today? Why does it really matter? It could
> > > easily change to a struct page flow tomorrow..
> > 
> > Well it's so that it's composable. We want the SGL->DMA side to work for
> > APIs from kernel space and not have to run a completely different flow
> > for kernel drivers than from userspace memory.
> 
> Yes, I think that is the important point.
> 
> All the other struct page discussion is not about anyone of us wanting
> struct page - heck it is a pain to deal with, but then again it is
> there for a reason.
> 
> In the typical GUP flows we have three uses of a struct page:

We do not want GUP. Yes some RDMA driver and other use GUP but they
should only use GUP on regular vma not on special vma (ie mmap of a
device file). Allowing GUP on those is insane. It is better to special
case the peer to peer mapping because _it is_ special, nothing inside
those are manage by core mm and driver can deal with them in weird
way (GPU certainly do and for very good reasons without which they
would perform badly).

> 
>  (1) to carry a physical address.  This is mostly through
>      struct scatterlist and struct bio_vec.  We could just store
>      a magic PFN-like value that encodes the physical address
>      and allow looking up a page if it exists, and we had at least
>      two attempts at it.  In some way I think that would actually
>      make the interfaces cleaner, but Linus has NACKed it in the
>      past, so we'll have to convince him first that this is the
>      way forward

Wasting 64bytes just to carry address is a waste for everyone.

>  (2) to keep a reference to the memory so that it doesn't go away
>      under us due to swapping, process exit, unmapping, etc.
>      No idea how we want to solve this, but I guess you have
>      some smart ideas?

The DMA API has _never_ dealt with page refcount and it have always
been up to the user of the DMA API to ascertain that it is safe for
them to map/unmap page/resource they are providing to the DMA API.

The lifetime management of page or resource provided to the DMA API
should remain the problem of the caller and not be something the DMA
API cares one bit about.

>  (3) to make the PTEs dirty after writing to them.  Again no sure
>      what our preferred interface here would be

Again the DMA API has never dealt with that nor should he. What does
dirty pte means for a special mapping (mmap of device file) ? There is
no single common definition for that, most driver do not care about it
and it get fully ignore.

> 
> If we solve all of the above problems I'd be more than happy to
> go with a non-struct page based interface for BAR P2P.  But we'll
> have to solve these issues in a generic way first.

None of the above are problems the DMA API need to solve. The DMA API
is about mapping some memory resource to a device. For regular main
memory it is easy on most architecture (anything with a sane IOMMU).
For IO resources it is not as straight forward as it was often left
undefined in the architecture platform documentation or the inter-
connect standard. AFAIK mapping BAR from one PCIE device to another
through IOMMU works well on recent Intel and AMD platform. We will
probably need to use some whitelist at i am not sure this is something
Intel or AMD guarantee, i believe they want to start guaranteeing it.

So having one DMA API for regular memory and one for IO memory aka
resource (dma_map_resource()) sounds like the only sane approach here.
It is fundamentally different memory and we should not try to muddle
the water by having it go through a single common API. There is no
benefit to that beside saving couple hundred of lines of code to some
driver and this couple hundred lines of code can be move to a common
helpers.

So to me it is lot sane to provide an helper that would deal with
the different vma type on behalf of device than forcing down struct
page. Something like:

vma_dma_map_range(vma, device, start, end, flags, pa[])
vma_dma_unmap_range(vma, device, start, end, flags, pa[])

VMA_DMA_MAP_FLAG_WRITE
VMA_DMA_MAP_FLAG_PIN

Which would use GUP or special vma handling on behalf of the calling
device or use a special p2p code path for special vma. Device that
need pinning set the flag and it is up to the exporting device to
accept or not. Pinning when using GUP is obvious.

When the vma goes away the importing device must update its device
page table to some dummy page or do something sane, because keeping
things map after that point does not make sense anymore. Device is
no longer operating on a range of virtual address that make sense.

So instead of pushing p2p handling within GUP to not disrupt existing
driver workflow. It is better to provide an helper that handle all
the gory details for the device driver. It does not change things for
the driver and allows proper special casing.

Cheers,
Jérôme

