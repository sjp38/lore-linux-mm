Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E36056B0009
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 09:06:18 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so77873387wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 06:06:18 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id c1si12936272wmh.112.2016.02.19.06.06.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 06:06:18 -0800 (PST)
Date: Fri, 19 Feb 2016 14:06:00 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 2/2] ARM: dma-mapping: fix alloc/free for coherent + CMA
 + gfp=0
Message-ID: <20160219140600.GW19428@n2100.arm.linux.org.uk>
References: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
 <1455869524-13874-2-git-send-email-rabin.vincent@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455869524-13874-2-git-send-email-rabin.vincent@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin.vincent@axis.com>
Cc: mina86@mina86.com, akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

On Fri, Feb 19, 2016 at 09:12:04AM +0100, Rabin Vincent wrote:
> Given a device which uses arm_coherent_dma_ops and on which
> dev_get_cma_area(dev) returns non-NULL, the following usage of the DMA
> API with gfp=0 results in a memory leak and memory corruption.
> 
>  p = dma_alloc_coherent(dev, sz, &dma, 0);
>  if (p)
>  	dma_free_coherent(dev, sz, p, dma);
> 
> The memory leak is because the alloc allocates using
> __alloc_simple_buffer() but the free attempts
> dma_release_from_contiguous(), which does not do free anything since the
> page is not in the CMA area.

I'd really like to see a better solution to this problem: over the course
of the years, I've seen a number of patches that rearrange the test order
at allocation time because of some problem or the other.

What we need is a better way to ensure that we use the correct release
functionality - having two independent set of tests where the order
matters is really not very good.

Maybe someone can put some thought into this...

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
