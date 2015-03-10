Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 253C76B009A
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 12:37:55 -0400 (EDT)
Received: by labmn12 with SMTP id mn12so3055062lab.0
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 09:37:54 -0700 (PDT)
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com. [209.85.217.170])
        by mx.google.com with ESMTPS id v7si611286lbw.153.2015.03.10.09.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 09:37:53 -0700 (PDT)
Received: by lbdu14 with SMTP id u14so3093196lbd.0
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 09:37:52 -0700 (PDT)
From: "Grygorii.Strashko@linaro.org" <grygorii.strashko@linaro.org>
Message-ID: <54FF1DDD.6060707@linaro.org>
Date: Tue, 10 Mar 2015 18:37:49 +0200
MIME-Version: 1.0
Subject: Re: ARM: OMPA4+: is it expected dma_coerce_mask_and_coherent(dev,
 DMA_BIT_MASK(64)); to fail?
References: <54F8A68B.3080709@linaro.org> <20150305201753.GG29584@n2100.arm.linux.org.uk> <54FA2084.8050803@linaro.org> <20150310110538.GK29584@n2100.arm.linux.org.uk>
In-Reply-To: <20150310110538.GK29584@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>, "Grygorii.Strashko@linaro.org" <grygorii.strashko@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Tejun Heo <tj@kernel.org>, Tony Lindgren <tony@atomide.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arm <linux-arm-kernel@lists.infradead.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, Laura Abbott <lauraa@codeaurora.org>, open list <linux-kernel@vger.kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

Hi Russell,

On 03/10/2015 01:05 PM, Russell King - ARM Linux wrote:
> On Fri, Mar 06, 2015 at 11:47:48PM +0200, Grygorii.Strashko@linaro.org wrote:
>> On 03/05/2015 10:17 PM, Russell King - ARM Linux wrote:
>>> On Thu, Mar 05, 2015 at 08:55:07PM +0200, Grygorii.Strashko@linaro.org wrote:
>>>> The dma_coerce_mask_and_coherent() will fail in case 'Example 3' and succeed in cases 1,2.
>>>> dma-mapping.c --> __dma_supported()
>>>> 	if (sizeof(mask) != sizeof(dma_addr_t) && <== true for all OMAP4+
>>>> 	    mask > (dma_addr_t)~0 &&		<== true for DMA_BIT_MASK(64)
>>>> 	    dma_to_pfn(dev, ~0) < max_pfn) {  <== true only for Example 3
>>>
>>> Hmm, I think this may make more sense to be "< max_pfn - 1" here, as
>>> that would be better suited to our intention.
>>>
>>> The result of dma_to_pfn(dev, ~0) is the maximum PFN which we could
>>> address via DMA, but we're comparing it with the maximum PFN in the
>>> system plus 1 - so we need to subtract one from it.
>>
>> Ok. I'll try it.
> 
> Any news on this - I think it is a real off-by-one bug which we should
> fix in any case.

Sorry for delay, there was a day-off on my side.

As per my test results - with above change 
 dma_coerce_mask_and_coherent(DMA_BIT_MASK(64)) and friends will succeed always.


=========== Test results:

==== Test case 1:
Input data:
- RAM: start = 0x80000000 size = 0x80000000
- CONFIG_ARM_LPAE=n and sizeof(phys_addr_t) = 4

a) NO changes:
 memory registered within memblock as:
   memory.cnt  = 0x1
   memory[0x0]     [0x00000080000000-0x000000fffffffe], 0x7fffffff bytes flags: 0x0

 max_pfn   = 0xFFFFF
 max_mapnr = 0x7FFFF

 dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)); -- succeeded

b) with change in __dma_supported():
        if (sizeof(mask) != sizeof(dma_addr_t) &&
            mask > (dma_addr_t)~0 &&
-           dma_to_pfn(dev, ~0) < max_pfn) {
+           dma_to_pfn(dev, ~0) < (max_pfn - 1)) {
                if (warn) {

 memory registered within memblock as:
   memory.cnt  = 0x1
   memory[0x0]     [0x00000080000000-0x000000fffffffe], 0x7fffffff bytes flags: 0x0

 max_pfn   = 0xFFFFF
 max_mapnr = 0x7FFFF

 dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)); -- succeeded


==== Test case 2:
Input data:
- RAM: start = 0x80000000 size = 0x80000000
- CONFIG_ARM_LPAE=y and sizeof(phys_addr_t) = 8

a) NO changes:
 memory registered within memblock as:
   memory.cnt  = 0x1
   memory[0x0]     [0x00000080000000-0x000000ffffffff], 0x80000000 bytes flags: 0x0

 max_pfn   = 0x100000
 max_mapnr = 0x80000

 dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)); -- failed
[    5.468470] asoc-simple-card sound@0: Coherent DMA mask 0xffffffffffffffff is larger than dma_addr_t allows
[    5.478706] asoc-simple-card sound@0: Driver did not use or check the return value from dma_set_coherent_mask()?
[    5.496620] davinci-mcasp 48468000.mcasp: ASoC: pcm constructor failed: -5
[    5.503844] asoc-simple-card sound@0: ASoC: can't create pcm davinci-mcasp.0-tlv320aic3x-hifi :-5


b) with change in __dma_supported():
        if (sizeof(mask) != sizeof(dma_addr_t) &&
            mask > (dma_addr_t)~0 &&
-           dma_to_pfn(dev, ~0) < max_pfn) {
+           dma_to_pfn(dev, ~0) < (max_pfn - 1)) {
                if (warn) {

 memory registered within memblock as:
   memory.cnt  = 0x1
   memory[0x0]     [0x00000080000000-0x000000ffffffff], 0x80000000 bytes flags: 0x0

 max_pfn   = 0x100000
 max_mapnr = 0x80000

 dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)); -- succeeded

regards,
-grygorii

-- 
regards,
-grygorii

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
