Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 15D896B008A
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 04:54:40 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so10893217wes.25
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 01:54:40 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id be6si3412581wib.13.2014.03.12.01.54.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 01:54:38 -0700 (PDT)
Date: Wed, 12 Mar 2014 08:54:01 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv4 2/2] arm: Get rid of meminfo
Message-ID: <20140312085401.GB21483@n2100.arm.linux.org.uk>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

On Tue, Feb 18, 2014 at 02:15:33PM -0800, Laura Abbott wrote:
> memblock is now fully integrated into the kernel and is the prefered
> method for tracking memory. Rather than reinvent the wheel with
> meminfo, migrate to using memblock directly instead of meminfo as
> an intermediate.
> 
> Acked-by: Jason Cooper <jason@lakedaemon.net>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Acked-by: Kukjin Kim <kgene.kim@samsung.com>
> Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Laura,

This patch causes a bunch of platforms to no longer boot - imx6solo with
1GB of RAM boots, imx6q with 2GB of RAM doesn't.  Versatile Express doesn't.

The early printk messages don't reveal anything too interesting:

Booting Linux on physical CPU 0x0
Linux version 3.14.0-rc6+ (rmk@rmk-PC.arm.linux.org.uk) (gcc version 4.6.4 (GCC) ) #630 SMP Wed Mar 12 01:13:36 GMT 2014
CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c53c7d
CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
Machine model: SolidRun Cubox-i Dual/Quad
cma: CMA: reserved 64 MiB at 8c000000
Memory policy: Data cache writealloc
<hang>

vs.

Booting Linux on physical CPU 0x0
Linux version 3.14.0-rc6+ (rmk@rmk-PC.arm.linux.org.uk) (gcc version 4.6.4 (GCC) ) #631 SMP Wed Mar 12 01:15:37 GMT 2014
CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c53c7d
CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
Machine model: SolidRun Cubox-i Dual/Quad
cma: CMA: reserved 64 MiB at 3b800000
Memory policy: Data cache writealloc
On node 0 totalpages: 524288
free_area_init_node: node 0, pgdat c09d0240, node_mem_map ea7d8000
  Normal zone: 1520 pages used for memmap
  Normal zone: 0 pages reserved
  Normal zone: 194560 pages, LIFO batch:31
  HighMem zone: 2576 pages used for memmap
  HighMem zone: 329728 pages, LIFO batch:31
...

The only obvious difference is the address of that CMA reservation,
CMA shouldn't make a difference here - but I suspect that other
allocations which need to be in lowmem probably aren't.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
