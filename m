Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id B1E1C6B0254
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 15:33:53 -0400 (EDT)
Received: by qkap81 with SMTP id p81so10105214qka.2
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 12:33:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 203si35488308qhu.22.2015.10.07.12.33.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 12:33:52 -0700 (PDT)
Date: Wed, 7 Oct 2015 12:33:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] dma-debug: Allow poisoning nonzero allocations
Message-Id: <20151007123351.763b98a8fe82a86ce7fdaf0c@linux-foundation.org>
In-Reply-To: <56156FAF.9020002@arm.com>
References: <cover.1443178314.git.robin.murphy@arm.com>
	<0405c6131def5aa179ff4ba5d4201ebde89cede3.1443178314.git.robin.murphy@arm.com>
	<20150925124447.GO21513@n2100.arm.linux.org.uk>
	<560585EB.3060908@arm.com>
	<20150929142727.e95a2d2ebff65dda86315248@linux-foundation.org>
	<56156FAF.9020002@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sakari.ailus@iki.fi" <sakari.ailus@iki.fi>, "sumit.semwal@linaro.org" <sumit.semwal@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>

On Wed, 7 Oct 2015 20:17:03 +0100 Robin Murphy <robin.murphy@arm.com> wrote:

> > It might be helpful to provide a runtime knob as well - having to
> > rebuild&reinstall just to enable/disable this feature is a bit painful.
> 
> Good point - there's always the global DMA debug disable knob, but this 
> particular feature probably does warrant finer-grained control to be 
> really practical. Having thought about it some more, it's also probably 
> wrong that this doesn't respect the dma_debug_driver filter, given that 
> it is actually invasive; in fixing that, how about if it also *only* 
> applied when a specific driver is filtered? Then there would be no 
> problematic "break anything and everything" mode, and the existing 
> debugfs controls should suffice.

Yes, this should respect the driver filtering.

On reflection...

The patch poisons dma buffers if CONFIG_DMA_API_DEBUG and if __GFP_ZERO
wasn't explicitly used.  I'm rather surprised that the dma-debug code
didn't do this from day one.

I'd be inclined to enable this buffer-poisoning by default.  Do you
have a feeling for how much overhead that will add?  Presumably not
much, if __GFP_ZERO is acceptable.

Also, how about we remove CONFIG_DMA_API_DEBUG_POISON and switch to a
debugfs knob?


btw, the documentation could do with a bit of a tune-up.  The comments
in dma-debug.c regarding driver filtering are non-existent. 
Documentation/kernel-parameters.txt says "The filter can be disabled or
changed to another driver later using sysfs" but
Documentation/DMA-API.txt talks about debugfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
