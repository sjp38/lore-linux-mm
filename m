Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF2AE6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 10:15:01 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id p65so227248713wmp.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 07:15:01 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id h133si12652445wmf.124.2016.03.31.07.15.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 07:15:00 -0700 (PDT)
Date: Thu, 31 Mar 2016 15:14:13 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 2/4] scatterlist: add sg_alloc_table_from_buf() helper
Message-ID: <20160331141412.GK19428@n2100.arm.linux.org.uk>
References: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
 <1459427384-21374-3-git-send-email-boris.brezillon@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459427384-21374-3-git-send-email-boris.brezillon@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>, linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Vinod Koul <vinod.koul@intel.com>, Richard Weinberger <richard@nod.at>, Joerg Roedel <joro@8bytes.org>, linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org, Vignesh R <vigneshr@ti.com>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Mark Brown <broonie@kernel.org>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, dmaengine@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, linux-media@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org, Mauro Carvalho Chehab <m.chehab@samsung.com>

On Thu, Mar 31, 2016 at 02:29:42PM +0200, Boris Brezillon wrote:
> sg_alloc_table_from_buf() provides an easy solution to create an sg_table
> from a virtual address pointer. This function takes care of dealing with
> vmallocated buffers, buffer alignment, or DMA engine limitations (maximum
> DMA transfer size).

Please note that the DMA API does not take account of coherency of memory
regions other than non-high/lowmem - there are specific extensions to
deal with this.

What this means is that having an API that takes any virtual address
pointer, converts it to a scatterlist which is then DMA mapped, is
unsafe.

It'll be okay for PIPT and non-aliasing VIPT cache architectures, but
for other cache architectures this will hide this problem and make
review harder.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
