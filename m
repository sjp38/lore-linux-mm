Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C78156B5328
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:30:30 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id 132so1838968wms.3
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 07:30:30 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::2])
        by mx.google.com with ESMTPS id p15si1805212wrr.113.2018.11.29.07.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 07:30:29 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <20181114082314.8965-1-hch@lst.de> <20181127074253.GB30186@lst.de>
 <87zhttfonk.fsf@concordia.ellerman.id.au>
 <4d4e3cdd-d1a9-affe-0f63-45b8c342bbd6@xenosoft.de>
Message-ID: <35b94e7c-89ca-9e11-e79a-048c5c8c5f03@xenosoft.de>
Date: Thu, 29 Nov 2018 16:30:06 +0100
MIME-Version: 1.0
In-Reply-To: <4d4e3cdd-d1a9-affe-0f63-45b8c342bbd6@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On 29 November 2018 at 1:05PM, Christian Zigotzky wrote:
> On 28 November 2018 at 12:05PM, Michael Ellerman wrote:
>> Christoph Hellwig <hch@lst.de> writes:
>>
>>> Any comments?  I'd like to at least get the ball moving on the easy
>>> bits.
>> Nothing specific yet.
>>
>> I'm a bit worried it might break one of the many old obscure platforms
>> we have that aren't well tested.
>>
>> There's not much we can do about that, but I'll just try and test it on
>> everything I can find.
>>
>> Is the plan that you take these via the dma-mapping tree or that they go
>> via powerpc?
>>
>> cheers
>>
> Hi All,
>
> I compiled a test kernel from the following Git today.
>
> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.4 
>
>
> Command: git clone git://git.infradead.org/users/hch/misc.git -b 
> powerpc-dma.4 a
>
> Unfortunately I get some DMA error messages and the PASEMI ethernet 
> doesn't work anymore.
>
> [  367.627623] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.627631] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.627639] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.627647] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.627655] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.627686] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.628418] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.628505] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.628592] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.629324] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.629417] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.629495] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
> [  367.629589] pci 0000:00:1a.0: dma_direct_map_page: overflow 
> 0x000000026bcb5002+110 of device mask ffffffff bus mask 0
>
> [  430.424732]pasemi_mac: rcmdsta error: 0x04ef3001
>
> I tested this kernel with the Nemo board (CPU: PWRficient PA6T-1682M). 
> The PASEMI ethernet works with the RC4 of kernel 4.20.
>
> Cheers,
> Christian
>
Hi All,

I tested this kernel on my NXP QorIQ P5020 board. U-Boot loads the dtb 
file and the kernel and after that the booting stops. This board works 
with the RC4 of kernel 4.20. Please test this kernel on your NXP and 
PASEMI boards.

Thanks,
Christian
