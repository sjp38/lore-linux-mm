Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0995F6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 13:55:18 -0500 (EST)
Received: by wgha1 with SMTP id a1so4678303wgh.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 10:55:17 -0800 (PST)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id w15si14333526wju.120.2015.03.05.10.55.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 10:55:16 -0800 (PST)
Received: by wiwl15 with SMTP id l15so5386329wiw.4
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 10:55:16 -0800 (PST)
From: "Grygorii.Strashko@linaro.org" <grygorii.strashko@linaro.org>
Message-ID: <54F8A68B.3080709@linaro.org>
Date: Thu, 05 Mar 2015 20:55:07 +0200
MIME-Version: 1.0
Subject: ARM: OMPA4+: is it expected dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
 to fail?
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, linux@arm.linux.org.uk, Tejun Heo <tj@kernel.org>
Cc: Tony Lindgren <tony@atomide.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arm <linux-arm-kernel@lists.infradead.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, Laura Abbott <lauraa@codeaurora.org>, open list <linux-kernel@vger.kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

Hi All,

Now I can see very interesting behavior related to dma_coerce_mask_and_coherent()
and friends which I'd like to explain and clarify.

Below is set of questions I have (why - I explained below):
- Is expected dma_coerce_mask_and_coherent(DMA_BIT_MASK(64)) and friends to fail on 32 bits HW?

- What is expected value for max_pfn: max_phys_pfn or max_phys_pfn + 1?

- What is expected value for struct memblock_region->size: mem_range_size or mem_range_size - 1?

- What is expected value to be returned by memblock_end_of_DRAM():
  @base + @size(max_phys_addr + 1) or @base + @size - 1(max_phys_addr)?


I'm working with BeaglBoard-X15 (AM572x/DRA7xx) board and have following code in OMAP ASOC driver
which is failed SOMETIMES during the boot with error -EIO.
=== to omap-pcm.c:
omap_pcm_new() {
...
	ret = dma_coerce_mask_and_coherent(card->dev, DMA_BIT_MASK(64));
^^ failed sometimes
	if (ret)
		return ret;
}

What I can see is that dma_coerce_mask_and_coherent() and etc may fail or succeed 
depending on - max_pfn value. 
-> max_pfn value depends on memblock configuration
max_pfn = max_high = PFN_DOWN(memblock_end_of_DRAM());
           |- PFN_DOWN(memblock.memory.regions[last_idx].base + memblock.memory.regions[last_idx].size)

-> memblock configuration depends on
a) CONFIG_ARM_LPAE=y|n (my system really works with 32 bit address space)
b) RAM configuration

Example 1 CONFIG_ARM_LPAE=n:
	memory {
		device_type = "memory";
		reg = <0x80000000 0x60000000>; /* 1536 MB */
	};

  memblock will be configured as:
	memory.cnt  = 0x1
	memory[0x0]     [0x00000080000000-0x000000dfffffff], 0x60000000 bytes flags: 0x0
							     ^^^^^^^^^^
  max_pfn = 0x000E0000

Example 2 CONFIG_ARM_LPAE=n:
	memory {
		device_type = "memory";
		reg = <0x80000000 0x80000000>;
	};

  memblock will be configured as:
	memory.cnt  = 0x1
	memory[0x0]     [0x00000080000000-0x000000fffffffe], 0x7fffffff bytes flags: 0x0
							     ^^^^^^^^^^
  max_pfn = 0x000FFFFF

Example 3 CONFIG_ARM_LPAE=y (but system really works with 32 bit address space):
	memory {
		device_type = "memory";
		reg = <0x80000000 0x80000000>;
	};

  memblock will be configured as:
	memory.cnt  = 0x1
	memory[0x0]     [0x00000080000000-0x000000ffffffff], 0x80000000 bytes flags: 0x0
							     ^^^^^^^^^^
  max_pfn = 0x00100000

The dma_coerce_mask_and_coherent() will fail in case 'Example 3' and succeed in cases 1,2.
dma-mapping.c --> __dma_supported()
	if (sizeof(mask) != sizeof(dma_addr_t) && <== true for all OMAP4+
	    mask > (dma_addr_t)~0 &&		<== true for DMA_BIT_MASK(64)
	    dma_to_pfn(dev, ~0) < max_pfn) {  <== true only for Example 3

I've tracked down patch which changes memblock behavior to:
commit eb18f1b5bfb99b1d7d2f5d792e6ee5c9b7d89330
Author: Tejun Heo <tj@kernel.org>
Date:   Thu Dec 8 10:22:07 2011 -0800

    memblock: Make memblock functions handle overflowing range @size

This commit is pretty old :( and it doesn't takes into account LPAE mode
where phys_addr_t is 64 bit, but physically accessible addresses <= 40 bit
(memblock_cap_size()).

The issue with omap-pcm was simply fixed by using DMA_BIT_MASK(32), but It seems problem is
wider and above behavior of dma_set_maskX() and memblock confused me a bit.

I'd be very appreciated for any comments/clarification on questions I've listed at the
beginning of my e-mail - there are no patches from my side as I'd like to understand 
expected behavior of the kernel first (especially taking into account that any
memblock changes might affect on at least half of arches). 

Thanks.


Additional info:
memblock: Make memblock functions handle overflowing range @size
https://lkml.org/lkml/2011/7/26/235
[alsa-devel] [PATCH] ASoC: omap-pcm: Lower the dma coherent mask to 32bits
http://mailman.alsa-project.org/pipermail/alsa-devel/2013-December/069817.html

-- 
regards,
-grygorii

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
