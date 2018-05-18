Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8246B064B
	for <linux-mm@kvack.org>; Fri, 18 May 2018 13:28:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z1-v6so5121944pfh.3
        for <linux-mm@kvack.org>; Fri, 18 May 2018 10:28:25 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id i15-v6si8185036pfk.146.2018.05.18.10.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 10:28:24 -0700 (PDT)
Subject: Re: [PATCH 02/20] dma-mapping: provide a generic dma-noncoherent
 implementation
References: <20180511075945.16548-1-hch@lst.de>
 <20180511075945.16548-3-hch@lst.de>
 <bad125dff49f6e49c895e818c9d1abb346a46e8e.camel@synopsys.com>
 <20180518132731.GA31125@lst.de>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <482e343c-bc87-9c0e-b6a8-bb69bcbeecda@synopsys.com>
Date: Fri, 18 May 2018 10:28:09 -0700
MIME-Version: 1.0
In-Reply-To: <20180518132731.GA31125@lst.de>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>, Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>, "deanbo422@gmail.com" <deanbo422@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 05/18/2018 06:23 AM, hch@lst.de wrote:
>   Fri, May 18, 2018 at 01:03:46PM +0000, Alexey Brodkin wrote:
>> Note mmc_get_dma_dir() is just "data->flags & MMC_DATA_WRITE ? DMA_TO_DEVICE : DMA_FROM_DEVICE".
>> I.e. if we're preparing for sending data dma_noncoherent_map_sg() will have DMA_TO_DEVICE which
>> is quite OK for passing to dma_noncoherent_sync_sg_for_device() but in case of reading we'll have
>> DMA_FROM_DEVICE which we'll pass to dma_noncoherent_sync_sg_for_device() in dma_noncoherent_map_sg().
>>
>> I'd say this is not entirely correct because IMHO arch_sync_dma_for_cpu() is supposed to only be used
>> in case of DMA_FROM_DEVICE and arch_sync_dma_for_device() only in case of DMA_TO_DEVICE.
> arc overrides the dir paramter of the dma_sync_single_for_device/
> dma_sync_single_for_cpu calls.  My patches dropped that, and I have
> restored that, and audit for the other architectures is pending.

Right, for now lets retain that and do a sweeping audit of @direction - to me it 
seems extraneous (as it did 10 years ago), but I'm not an expert in this are so 
perhaps it is needed for some device / arches and it would be good to understand 
that finally.

> That being said the existing arc code still looks rather odd as it
> didn't do the same thing for the scatterlist versions of the calls.
> I've thrown in a few patches into my new tree to make the sg versions
> make the normal calls, and to clean up the area a bit.

Not calling names or anything here, but it doesn't exist for sg variants, because 
I didn't write that code :-)
It was introduced by your commi:

2016-01-20 052c96dbe33b arc: convert to dma_map_ops
