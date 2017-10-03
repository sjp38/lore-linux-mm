Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17E2F6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 03:07:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 54so7688071wrz.3
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 00:07:55 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c6si2136695wmd.12.2017.10.03.00.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 00:07:53 -0700 (PDT)
Date: Tue, 3 Oct 2017 09:07:52 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3] dma-debug: fix incorrect pfn calculation
Message-ID: <20171003070752.GA18928@lst.de>
References: <1506484087-1177-1-git-send-email-miles.chen@mediatek.com> <273077fd-c5ad-82c8-60aa-cde89355e5e8@arm.com> <20171001080449.GB11843@lst.de> <1506940241.28397.36.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506940241.28397.36.camel@mtkswgap22>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Christoph Hellwig <hch@lst.de>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, wsd_upstream@mediatek.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-mediatek@lists.infradead.org

On Mon, Oct 02, 2017 at 06:30:41PM +0800, Miles Chen wrote:
> ARCHs like metag and xtensa define their mappings (non-vmalloc and
> non-linear) for dma allocation.

metag basically is a reimplementation of the vmalloc map mechanism
that should be easy to consolidate into the common one :(  xtensa
has a weird remapping into a different segment, something that I
vaguely remember mips used to support as well.

> These mapping types are architecture-dependent and should not be used
> outside arch folders. So it is hard to check the mappings and convert
> a virtual address to a correct pfn in lib/dam-debug.c
> 
> How about recording only vmalloc (by is_vmalloc_addr()) and linear
> address (by virt_addr_valid()) in lib/dma-debug? Since current 
> implementation is not correct for those ARCHs.
> 
> if (!is_vmalloc_addr(addr) && !virt_addr_valid(addr))
>     return;
> 
> or

This looks like a good start, although I'm not sure I'd trust
virt_addr_valid on every little arch.  In the worse case we'll
have to exclude offenders from supporting dma debug, so let's go
with that version.

> > > > +	entry->pfn	 = is_vmalloc_addr(virt) ? vmalloc_to_pfn(virt) :
> > > > +						page_to_pfn(virt_to_page(virt));
> > 
> > Please use normal if/else conditionsals:
> 
> Is this for better readability? I'll send another patch for this.

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
