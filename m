Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1D38C6B0038
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:27:11 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id la4so9159273vcb.13
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:27:10 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ko6si6601141pbc.98.2014.05.12.09.27.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 May 2014 09:27:10 -0700 (PDT)
Message-ID: <5370F66F.7060204@codeaurora.org>
Date: Mon, 12 May 2014 09:27:27 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: Questions regarding DMA buffer sharing using IOMMU
References: <BAY169-W12541AD089785F8BFBD4E26EF350@phx.gbl>,<5218408.5YRJXjS4BX@wuerfel> <BAY169-W1156E6803829CAB545274BCEF350@phx.gbl>
In-Reply-To: <BAY169-W1156E6803829CAB545274BCEF350@phx.gbl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@outlook.com>, Arnd Bergmann <arnd@arndb.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>

On 5/12/2014 7:37 AM, Pintu Kumar wrote:
> Hi,
> Thanks for the reply.
> 
> ----------------------------------------
>> From: arnd@arndb.de
>> To: linux-arm-kernel@lists.infradead.org
>> CC: pintu.k@outlook.com; linux-mm@kvack.org; linux-kernel@vger.kernel.org; linaro-mm-sig@lists.linaro.org
>> Subject: Re: Questions regarding DMA buffer sharing using IOMMU
>> Date: Mon, 12 May 2014 14:00:57 +0200
>>
>> On Monday 12 May 2014 15:12:41 Pintu Kumar wrote:
>>> Hi,
>>> I have some queries regarding IOMMU and CMA buffer sharing.
>>> We have an embedded linux device (kernel 3.10, RAM: 256Mb) in
>>> which camera and codec supports IOMMU but the display does not support IOMMU.
>>> Thus for camera capture we are using iommu buffers using
>>> ION/DMABUF. But for all display rendering we are using CMA buffers.
>>> So, the question is how to achieve buffer sharing (zero-copy)
>>> between Camera and Display using only IOMMU?
>>> Currently we are achieving zero-copy using CMA. And we are
>>> exploring options to use IOMMU.
>>> Now we wanted to know which option is better? To use IOMMU or CMA?
>>> If anybody have come across these design please share your thoughts and results.
>>
>> There is a slight performance overhead in using the IOMMU in general,
>> because the IOMMU has to fetch the page table entries from memory
>> at least some of the time.
> 
> Ok, we need to check performance later
> 
>>
>> If that overhead is within the constraints you have for transfers between
>> camera and codec, you are always better off using IOMMU since that
>> means you don't have to do memory migration.
> 
> Transfer between camera is codec is fine. But our major concern is single buffer 
> sharing between camera & display. Here camera supports iommu but display does not support iommu.
> Is it possible to render camera preview (iommu buffers) on display (not iommu and required physical contiguous overlay memory)?
> 

I'm pretty sure the answer is no for zero copy IOMMU buffers if one of your
devices does not support IOMMU. If the data is coming in as individual pages
and the hardware does not support scattered pages there isn't much you can
do except copy to a contiguous buffer. At least with Ion, the heap types can
be set up in a particular way such that the client need never know about the
existence of an IOMMU or not. 

> Also is it possible to buffer sharing between 2 iommu supported devices?
> 

I don't see why not but there isn't a lot of information to go on here.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
