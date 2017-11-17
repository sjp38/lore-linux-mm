Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 968846B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 21:45:06 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f9so643144wra.2
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 18:45:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a14si2109898wrf.227.2017.11.16.18.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 18:45:05 -0800 (PST)
Date: Thu, 16 Nov 2017 18:45:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] dma-debug: fix incorrect pfn calculation
Message-Id: <20171116184501.8c83e100fa14721e459907e0@linux-foundation.org>
In-Reply-To: <1510881798.3024.43.camel@mtkswgap22>
References: <1510872972-23919-1-git-send-email-miles.chen@mediatek.com>
	<20171116161350.3b8bd1fbcaae8e032441d3e7@linux-foundation.org>
	<1510881798.3024.43.camel@mtkswgap22>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Christoph Hellwig <hch@lst.de>, Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@infradead.org>

On Fri, 17 Nov 2017 09:23:18 +0800 Miles Chen <miles.chen@mediatek.com> wrote:

> On Thu, 2017-11-16 at 16:13 -0800, Andrew Morton wrote:
> > On Fri, 17 Nov 2017 06:56:12 +0800 <miles.chen@mediatek.com> wrote:
> > 
> > > From: Miles Chen <miles.chen@mediatek.com>
> > > 
> > > dma-debug reports the following warning:
> > > 
> > > [name:panic&]WARNING: CPU: 3 PID: 298 at kernel-4.4/lib/dma-debug.c:604
> > > debug _dma_assert_idle+0x1a8/0x230()
> > > DMA-API: cpu touching an active dma mapped cacheline [cln=0x00000882300]
> > > CPU: 3 PID: 298 Comm: vold Tainted: G        W  O    4.4.22+ #1
> > > Hardware name: MT6739 (DT)
> > > Call trace:
> > > [<ffffff800808acd0>] dump_backtrace+0x0/0x1d4
> > > [<ffffff800808affc>] show_stack+0x14/0x1c
> > > [<ffffff800838019c>] dump_stack+0xa8/0xe0
> > > [<ffffff80080a0594>] warn_slowpath_common+0xf4/0x11c
> > > [<ffffff80080a061c>] warn_slowpath_fmt+0x60/0x80
> > > [<ffffff80083afe24>] debug_dma_assert_idle+0x1a8/0x230
> > > [<ffffff80081dca9c>] wp_page_copy.isra.96+0x118/0x520
> > > [<ffffff80081de114>] do_wp_page+0x4fc/0x534
> > > [<ffffff80081e0a14>] handle_mm_fault+0xd4c/0x1310
> > > [<ffffff8008098798>] do_page_fault+0x1c8/0x394
> > > [<ffffff800808231c>] do_mem_abort+0x50/0xec
> > > 
> > > I found that debug_dma_alloc_coherent() and debug_dma_free_coherent()
> > > assume that dma_alloc_coherent() always returns a linear address.  However
> > > it's possible that dma_alloc_coherent() returns a non-linear address.  In
> > > this case, page_to_pfn(virt_to_page(virt)) will return an incorrect pfn.
> > > If the pfn is valid and mapped as a COW page, we will hit the warning when
> > > doing wp_page_copy().
> > > 
> > > Fix this by calculating pfn for linear and non-linear addresses.
> > > 
> > 
> > It's a shame you didn't Cc Christoph, who was the sole reviewer of the
> > earlier version.
> > 
> > And it's a shame you didn't capture the result of that review
> > discussion in the v3 changelog.
> > 
> > And it's a shame that you didn't describe how this patch differs from
> > earlier versions.
> 
> 
> I am truly sorry about this. I was not sure if I can submit a patch
> based on a linux-next patch, so I submit a new patch based on the latest
> mainline kernel again.
> 
> I know how to do this now. I will do it correctly next time.
> 
> Is there anyway to fix this? (send another patch with v3 discussion and
> the difference from earlier versions to the commit message).

A complete resend is perfectly OK - I will handle the changelog
modifications, etc.

My point is that the Cc: line was incomplete and that the changelog is
missing information, as described above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
