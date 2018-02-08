Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEAC6B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 18:20:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w19so2501858pgv.4
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 15:20:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l7-v6si643946pls.728.2018.02.08.15.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 15:20:09 -0800 (PST)
Date: Thu, 8 Feb 2018 15:20:04 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180208232004.GA21027@bombadil.infradead.org>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180208130649.GA15846@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kai Heng Feng <kai.heng.feng@canonical.com>
Cc: Michal Hocko <mhocko@suse.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 08, 2018 at 05:06:49AM -0800, Matthew Wilcox wrote:
> On Thu, Feb 08, 2018 at 02:29:57PM +0800, Kai Heng Feng wrote:
> > A user with i386 instead of AMD64 machine reports [1] that commit 19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM implicitlya??) causes a regression.
> > BUG_ON(PageHighMem(pg)) in drivers/media/common/saa7146/saa7146_core.c always gets triggered after that commit.
> 
> Well, the BUG_ON is wrong.  You can absolutely have pages which are both
> HighMem and under the 4GB boundary.  Only the first 896MB (iirc) are LowMem,
> and the next 3GB of pages are available to vmalloc_32().

... nevertheless, 19809c2da28a does in fact break vmalloc_32 on 32-bit.  Look:

#if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
#define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
#elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
#define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
#else
#define GFP_VMALLOC32 GFP_KERNEL
#endif

So we pass in GFP_KERNEL to __vmalloc_node, which calls __vmalloc_node_range
which calls __vmalloc_area_node, which ORs in __GFP_HIGHMEM.

So ... we could enable ZONE_DMA32 on 32-bit architectures.  I don't know
what side-effects that might have; it's clearly only been tested on 64-bit
architectures so far.

It might be best to just revert 19809c2da28a and the follow-on 704b862f9efd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
