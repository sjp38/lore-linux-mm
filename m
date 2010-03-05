Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D2DAA6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 05:26:00 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so136116fgg.8
        for <linux-mm@kvack.org>; Fri, 05 Mar 2010 02:26:06 -0800 (PST)
Message-ID: <4B90DC3C.1060000@gmail.com>
Date: Fri, 05 Mar 2010 11:26:04 +0100
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> <20100305032106.GA12065@cmpxchg.org> <4B90C921.6060908@kernel.org>
In-Reply-To: <4B90C921.6060908@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yinghai@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 03/05/2010 10:04 AM, Yinghai Lu wrote:
> according to context
> http://patchwork.kernel.org/patch/73893/
> 
> Jiri, 
> please check current linus tree still have problem about mem_map is using that much low mem?

Hi!

Sorry, I don't have direct access to the machine. I might try to ask the
owners to do so.

> on my 1024g system first node has 128G ram, [2g, 4g) are mmio range.

So where gets your mem_map allocated (I suppose you're running flat model)?

Note that the failure we were seeing was with different amount of memory
on different machines. Obviously because of different e820 reservations
and driver requirements at boot time. So the required memory to trigger
the error oscillated around 128G, sometimes being 130G.

It triggered when mem_map fit exactly into 0-2G (and 2-4G was reserved)
and no more space was there. If RAM was more than 130G, mem_map was
above 4G boundary implicitly, so that there was enough space in the
first 4G of memory for others with specific bootmem limitations.

> with NO_BOOTMEM
> [    0.000000]  a - 11
> [    0.000000]  19 40 - 80 95
> [    0.000000]  702 740 - 1000 1000
> [    0.000000]  331f 3340 - 3400 3400
> [    0.000000]  35dd - 3600
> [    0.000000]  37dd - 3800
> [    0.000000]  39dd - 3a00
> [    0.000000]  3bdd - 3c00
> [    0.000000]  3ddd - 3e00
> [    0.000000]  3fdd - 4000
> [    0.000000]  41dd - 4200
> [    0.000000]  43dd - 4400
> [    0.000000]  45dd - 4600
> [    0.000000]  47dd - 4800
> [    0.000000]  49dd - 4a00
> [    0.000000]  4bdd - 4c00
> [    0.000000]  4ddd - 4e00
> [    0.000000]  4fdd - 5000
> [    0.000000]  51dd - 5200
> [    0.000000]  93dd 9400 - 7d500 7d53b
> [    0.000000]  7f730 - 7f750
> [    0.000000]  100012 100040 - 100200 100200
> [    0.000000]  170200 170200 - 2080000 2080000
> [    0.000000]  2080065 2080080 - 2080200 2080200
> 
> so PFN: 9400 - 7d500 are free.

Could you explain more the dmesg output?

> without NO_BOOTMEM
> [    0.000000] nid=0 start=0x0000000000 end=0x0002080000 aligned=1
> [    0.000000]   free [0x000000000a - 0x0000000095]
> [    0.000000]   free [0x0000000702 - 0x0000001000]
> [    0.000000]   free [0x00000032c4 - 0x0000003400]
> [    0.000000]   free [0x00000035de - 0x0000003600]
> [    0.000000]   free [0x00000037dd - 0x0000003800]
> [    0.000000]   free [0x00000039dd - 0x0000003a00]
> [    0.000000]   free [0x0000003bdd - 0x0000003c00]
> [    0.000000]   free [0x0000003ddd - 0x0000003e00]
> [    0.000000]   free [0x0000003fdd - 0x0000004000]
> [    0.000000]   free [0x00000041dd - 0x0000004200]
> [    0.000000]   free [0x00000043dd - 0x0000004400]
> [    0.000000]   free [0x00000045dd - 0x0000004600]
> [    0.000000]   free [0x00000047dd - 0x0000004800]
> [    0.000000]   free [0x00000049dd - 0x0000004a00]
> [    0.000000]   free [0x0000004bdd - 0x0000004c00]
> [    0.000000]   free [0x0000004ddd - 0x0000004e00]
> [    0.000000]   free [0x0000004fdd - 0x0000005000]
> [    0.000000]   free [0x00000051dd - 0x0000005200]
> [    0.000000]   free [0x00000053dd - 0x000007d53b]
> [    0.000000]   free [0x000007f730 - 0x000007f750]
> [    0.000000]   free [0x000010041f - 0x0000100a00]
> [    0.000000]   free [0x0000170a00 - 0x0000180a00]
> [    0.000000]   free [0x0000180a03 - 0x0002080000]
> so pfn: 53dd 7d53b are free
> 
> looks like we don't need to change the default goal in alloc_bootmem_node.

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
