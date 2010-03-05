Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B69F6B004D
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 04:05:41 -0500 (EST)
Message-ID: <4B90C921.6060908@kernel.org>
Date: Fri, 05 Mar 2010 01:04:33 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> <20100305032106.GA12065@cmpxchg.org>
In-Reply-To: <20100305032106.GA12065@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>, Jiri Slaby <jirislaby@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 03/04/2010 07:21 PM, Johannes Weiner wrote:
> Hello Greg,
> 
> On Thu, Mar 04, 2010 at 01:21:41PM -0800, Greg Thelen wrote:
>> On several systems I am seeing a boot panic if I use mmotm
>> (stamp-2010-03-02-18-38).  If I remove
>> bootmem-avoid-dma32-zone-by-default.patch then no panic is seen.  I
>> find that:
>> * 2.6.33 boots fine.
>> * 2.6.33 + mmotm w/o bootmem-avoid-dma32-zone-by-default.patch: boots fine.
>> * 2.6.33 + mmotm (including
>> bootmem-avoid-dma32-zone-by-default.patch): panics.
>> Note: I had to enable earlyprintk to see the panic.  Without
>> earlyprintk no console output was seen.  The system appeared to hang
>> after the loader.
> 
> where sparse_index_init(), in the SPARSEMEM_EXTREME case, will allocate
> the mem_section descriptor with bootmem.  If this would fail, the box
> would panic immediately earlier, but NO_BOOTMEM does not seem to get it
> right.
> 
> Greg, could you retry _with_ my bootmem patch applied, but with setting
> CONFIG_NO_BOOTMEM=n up front?
> 
> I think NO_BOOTMEM has several problems.  Yinghai, can you verify them?
...
> 
> 1. It does not seem to handle goal appropriately: bootmem would try
> without the goal if it does not make sense.  And in this case, the
> goal is 4G (above DMA32) and the amount of memory is 256M.
> 
> And if I did not miss something, this is the difference with my patch:
> without it, the default goal is 16M, which is no problem as it is well
> within your available memory.  But the change of the default goal moved
> it outside it which the bootmem replacement can not handle.
> 
> 2. The early reservation stuff seems to return NULL but callsites assume
> that the bootmem interface never does that.  Okay, the result is the same,
> we crash.  But it still moves error reporting to a possibly much later
> point where somebody actually dereferences the returned pointer.

under CONFIG_NO_BOOTMEM
for alloc_bootmem_node it will honor goal, if someone input big goal it will not
fallback to get a small one below that goal.

return NULL, could make caller have more choice and more control.

anyway we should honor the goal, otherwise should use _nopanic instead.

according to context
http://patchwork.kernel.org/patch/73893/

Jiri, 
please check current linus tree still have problem about mem_map is using that much low mem?

on my 1024g system first node has 128G ram, [2g, 4g) are mmio range.
with NO_BOOTMEM

[    0.000000]  a - 11
[    0.000000]  19 40 - 80 95
[    0.000000]  702 740 - 1000 1000
[    0.000000]  331f 3340 - 3400 3400
[    0.000000]  35dd - 3600
[    0.000000]  37dd - 3800
[    0.000000]  39dd - 3a00
[    0.000000]  3bdd - 3c00
[    0.000000]  3ddd - 3e00
[    0.000000]  3fdd - 4000
[    0.000000]  41dd - 4200
[    0.000000]  43dd - 4400
[    0.000000]  45dd - 4600
[    0.000000]  47dd - 4800
[    0.000000]  49dd - 4a00
[    0.000000]  4bdd - 4c00
[    0.000000]  4ddd - 4e00
[    0.000000]  4fdd - 5000
[    0.000000]  51dd - 5200
[    0.000000]  93dd 9400 - 7d500 7d53b
[    0.000000]  7f730 - 7f750
[    0.000000]  100012 100040 - 100200 100200
[    0.000000]  170200 170200 - 2080000 2080000
[    0.000000]  2080065 2080080 - 2080200 2080200

so PFN: 9400 - 7d500 are free.

without NO_BOOTMEM
[    0.000000] nid=0 start=0x0000000000 end=0x0002080000 aligned=1
[    0.000000]   free [0x000000000a - 0x0000000095]
[    0.000000]   free [0x0000000702 - 0x0000001000]
[    0.000000]   free [0x00000032c4 - 0x0000003400]
[    0.000000]   free [0x00000035de - 0x0000003600]
[    0.000000]   free [0x00000037dd - 0x0000003800]
[    0.000000]   free [0x00000039dd - 0x0000003a00]
[    0.000000]   free [0x0000003bdd - 0x0000003c00]
[    0.000000]   free [0x0000003ddd - 0x0000003e00]
[    0.000000]   free [0x0000003fdd - 0x0000004000]
[    0.000000]   free [0x00000041dd - 0x0000004200]
[    0.000000]   free [0x00000043dd - 0x0000004400]
[    0.000000]   free [0x00000045dd - 0x0000004600]
[    0.000000]   free [0x00000047dd - 0x0000004800]
[    0.000000]   free [0x00000049dd - 0x0000004a00]
[    0.000000]   free [0x0000004bdd - 0x0000004c00]
[    0.000000]   free [0x0000004ddd - 0x0000004e00]
[    0.000000]   free [0x0000004fdd - 0x0000005000]
[    0.000000]   free [0x00000051dd - 0x0000005200]
[    0.000000]   free [0x00000053dd - 0x000007d53b]
[    0.000000]   free [0x000007f730 - 0x000007f750]
[    0.000000]   free [0x000010041f - 0x0000100a00]
[    0.000000]   free [0x0000170a00 - 0x0000180a00]
[    0.000000]   free [0x0000180a03 - 0x0002080000]
so pfn: 53dd 7d53b are free

looks like we don't need to change the default goal in alloc_bootmem_node.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
