Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3945482F86
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 06:15:06 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 78so48715609pfw.2
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 03:15:06 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id rl12si392784pab.225.2015.12.23.03.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 03:15:05 -0800 (PST)
Subject: Re: ARC AXS101 problems with linux next-20151221
References: <56784531.1000007@synopsys.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <567A8226.80308@synopsys.com>
Date: Wed, 23 Dec 2015 16:44:46 +0530
MIME-Version: 1.0
In-Reply-To: <56784531.1000007@synopsys.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Carlos Palminha <CARLOS.PALMINHA@synopsys.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexey Brodkin <Alexey.Brodkin@synopsys.com>, lkml <linux-kernel@vger.kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>

Hi Christoph, Andrew

> On Tuesday 22 December 2015 12:00 AM, Carlos Palminha wrote:
> Hi guys,
> 
> I just compiled the kernel for axs101_defconfig based on linux next tag 'next-20151221'.
> I can't boot it due to the following errors causing strange stack traces after freeing unused kernel memory (check log below).
> 
> Any clue?
> Do you more info to understand the issue?

....[snip]

> dw_mmc e0015000.mmc: IDMAC supports 32-bit address mode.
> dw_mmc e0015000.mmc: Using internal DMA controller.
> dw_mmc e0015000.mmc: Version ID is 270a
> dw_mmc e0015000.mmc: DW MMC controller at irq 34,32 bit host data width,16 deep fifo
> dw_mmc e0015000.mmc: 1 slots initialized
> sdhci-pltfm: SDHCI platform and OF driver helper
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> ttyS3 - failed to request DMA
> Freeing unused kernel memory: 928K (80002000 - 800ea000)
> INFO: rcu_preempt self-detected stall on CPU
>         0-...: (2100 ticks this GP) idle=011/140000000000001/0 softirq=92/92 fqs=0
>          (t=2100 jiffies g=-261 c=-262 q=60)
> rcu_preempt kthread starved for 2100 jiffies! g4294967035 c4294967034 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
> rcu_preempt     S 8053879e     0     7      2 0x00000000
> 
> Stack Trace:
>   __switch_to+0x0/0x94
>   __schedule+0x1c2/0x724
>   schedule+0x2a/0x74
>   schedule_timeout+0x126/0x198
>   rcu_gp_kthread+0x5fa/0xee8
>   kthread+0xe2/0xf4
>   ret_from_fork+0x18/0x1c
> Task dump for CPU 0:
> kworker/0:1     R running      0    19      2 0x00000008
> Workqueue: events_freezable mmc_rescan

[snip]

It seems the dma ops rework for ARC makes kernel belly up.

Patch below fixes it.

------------->
