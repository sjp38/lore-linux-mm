Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 680D4828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:24:07 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id bc4so102821733lbc.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:24:07 -0800 (PST)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id m187si16020169lfm.223.2016.02.23.07.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:24:06 -0800 (PST)
Received: by mail-lf0-x22c.google.com with SMTP id j78so117383728lfb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:24:05 -0800 (PST)
Date: Tue, 23 Feb 2016 16:23:53 +0100
From: Rabin Vincent <rabin@rab.in>
Subject: Re: [PATCH 2/2] ARM: dma-mapping: fix alloc/free for coherent + CMA
 + gfp=0
Message-ID: <20160223152353.GA22447@lnxrabinv.se.axis.com>
References: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
 <1455869524-13874-2-git-send-email-rabin.vincent@axis.com>
 <20160219140600.GW19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160219140600.GW19428@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Rabin Vincent <rabin.vincent@axis.com>, mina86@mina86.com, akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

On Fri, Feb 19, 2016 at 02:06:00PM +0000, Russell King - ARM Linux wrote:
> On Fri, Feb 19, 2016 at 09:12:04AM +0100, Rabin Vincent wrote:
> > Given a device which uses arm_coherent_dma_ops and on which
> > dev_get_cma_area(dev) returns non-NULL, the following usage of the DMA
> > API with gfp=0 results in a memory leak and memory corruption.
> > 
> >  p = dma_alloc_coherent(dev, sz, &dma, 0);
> >  if (p)
> >  	dma_free_coherent(dev, sz, p, dma);
> > 
> > The memory leak is because the alloc allocates using
> > __alloc_simple_buffer() but the free attempts
> > dma_release_from_contiguous(), which does not do free anything since the
> > page is not in the CMA area.
> 
> I'd really like to see a better solution to this problem: over the course
> of the years, I've seen a number of patches that rearrange the test order
> at allocation time because of some problem or the other.
> 
> What we need is a better way to ensure that we use the correct release
> functionality - having two independent set of tests where the order
> matters is really not very good.

I've sent a v2 of this series which refactors the code so that we no
longer have two independent sets of tests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
