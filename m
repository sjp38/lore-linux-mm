Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31C83440844
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:24:25 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 125so134387446pgi.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 18:24:25 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id b5si8242898ple.587.2017.07.15.18.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 18:24:24 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: semantics of dma_map_single()
Message-ID: <dc128260-6641-828a-3bb6-c2f0b4f09f78@synopsys.com>
Date: Sat, 15 Jul 2017 18:24:03 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>, bart.vanassche@sandisk.com, Alexander Duyck <alexander.h.duyck@intel.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
Cc: lkml <linux-kernel@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>

P.S. Apologies in advance for the explicit TO list, it seemed adding people who've 
touched the dma mapping code (for ARC atleast), would respond sooner ;-)

The question is does dma_map_single() imply a single region (possibly > PAGE_SIZE) 
or does it imply PAGE_SIZE. Documentation/DMA-API* is not explicit about one or 
the other and the code below seems to point to "a" struct page, although it could 
also mean multiple pages, specially if the pages are contiguous, say as those 
returned by alloc_pages(with order > 0)


	static inline dma_addr_t dma_map_single_attrs(dev, size, dir, attrs)
	{
		addr = ops->map_page(dev,
			virt_to_page(ptr), <--- this is one struct page
			offset_in_page(ptr), size, dir, attrs);
	}

ARC dma_map_single() currently only handles cache coherency for only one struct 
page or PAGE_SIZE worth of memory, and we have a customer who seem to assume that 
it handles a region.

Looking at other arches dma mapping backend, it is not clear either what the 
semantics are.

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
