Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 112256B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:46:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q87so169969220pfk.15
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:46:35 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id d126si267547pfa.234.2017.07.17.09.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jul 2017 09:46:33 -0700 (PDT)
Message-ID: <1500309990.3244.2.camel@HansenPartnership.com>
Subject: Re: semantics of dma_map_single()
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 17 Jul 2017 09:46:30 -0700
In-Reply-To: <23203d16-da54-99c7-0eba-c082eba120d7@synopsys.com>
References: <dc128260-6641-828a-3bb6-c2f0b4f09f78@synopsys.com>
	 <20170717064220.GA15807@lst.de>
	 <23203d16-da54-99c7-0eba-c082eba120d7@synopsys.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Christoph Hellwig <hch@lst.de>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, bart.vanassche@sandisk.com, Alexander Duyck <alexander.h.duyck@intel.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>

On Mon, 2017-07-17 at 09:06 -0700, Vineet Gupta wrote:
> Hi Christoph,
> 
> On 07/16/2017 11:42 PM, Christoph Hellwig wrote:
> > 
> > I would expect that it would support any contiguous range in
> > the kernel mapping (e.g. no vmalloc and friends).A A But it's not
> > documented anywhere, and if no in kernel users makes use of that
> > fact at the moment it might be better to document a page size
> > limitation and add asserts to enforce it.
> 
> My first thought was indeed to add a BUG_ON for @size > PAGE_SIZE
> (also accounting for offset etc), but I have a feeling this will
> cause too many breakages. So perhaps it would be better to add the
> fact to Documentation that it can handle any physically contiguous
> range.

Actually, that's not historically right. A dma_map_single() was
originally designed to be called on any region that was kmalloc'd
meaning it was capable of mapping physically contiguous > PAGE_SIZE
regions.

For years (decades?) we've been eliminating the specialised
dma_map_single() calls in favour of dma_map_sg, so it's possible there
may not be any large region consumers anymore, so it *may* be safe to
enforce a PAGE_SIZE limit, but not without auditing the remaining
callers.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
