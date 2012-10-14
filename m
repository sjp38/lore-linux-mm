Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id F23E36B002B
	for <linux-mm@kvack.org>; Sun, 14 Oct 2012 16:34:51 -0400 (EDT)
Message-ID: <1350246895.11504.6.camel@gitbox>
Subject: Re: dma_alloc_coherent fails in framebuffer
From: Tony Prisk <linux@prisktech.co.nz>
Date: Mon, 15 Oct 2012 09:34:55 +1300
In-Reply-To: <1350192523.10946.4.camel@gitbox>
References: <1350192523.10946.4.camel@gitbox>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Rob Herring <robherring2@gmail.com>, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>, mgorman@suse.de, linux-mm@kvack.org

On Sun, 2012-10-14 at 18:28 +1300, Tony Prisk wrote:
> Up until 07 Oct, drivers/video/wm8505-fb.c was working fine, but on the
> 11 Oct when I did another pull from linus all of a sudden
> dma_alloc_coherent is failing to allocate the framebuffer any longer.
> 
> I did a quick look back and found this:
> 
> ARM: add coherent dma ops
> 
> arch_is_coherent is problematic as it is a global symbol. This
> doesn't work for multi-platform kernels or platforms which can support
> per device coherent DMA.
> 
> This adds arm_coherent_dma_ops to be used for devices which connected
> coherently (i.e. to the ACP port on Cortex-A9 or A15). The arm_dma_ops
> are modified at boot when arch_is_coherent is true.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> 
> 
> This is the only patch lately that I could find (not that I would claim
> to be any good at finding things) that is related to the problem. Could
> it have caused the allocations to fail?
> 
> Regards
> Tony P

Have done a bit more digging and found the cause - not Rob's patch so
apologies.

The cause of the regression is this patch:
