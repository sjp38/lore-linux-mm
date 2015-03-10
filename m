Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 77B5E6B008A
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 07:05:58 -0400 (EDT)
Received: by wiwl15 with SMTP id l15so27556146wiw.1
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 04:05:58 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id cm9si24564729wib.29.2015.03.10.04.05.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 04:05:57 -0700 (PDT)
Date: Tue, 10 Mar 2015 11:05:38 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: ARM: OMPA4+: is it expected dma_coerce_mask_and_coherent(dev,
 DMA_BIT_MASK(64)); to fail?
Message-ID: <20150310110538.GK29584@n2100.arm.linux.org.uk>
References: <54F8A68B.3080709@linaro.org>
 <20150305201753.GG29584@n2100.arm.linux.org.uk>
 <54FA2084.8050803@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54FA2084.8050803@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Grygorii.Strashko@linaro.org" <grygorii.strashko@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Tejun Heo <tj@kernel.org>, Tony Lindgren <tony@atomide.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arm <linux-arm-kernel@lists.infradead.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, Laura Abbott <lauraa@codeaurora.org>, open list <linux-kernel@vger.kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

On Fri, Mar 06, 2015 at 11:47:48PM +0200, Grygorii.Strashko@linaro.org wrote:
> Hi Russell,
> 
> On 03/05/2015 10:17 PM, Russell King - ARM Linux wrote:
> > On Thu, Mar 05, 2015 at 08:55:07PM +0200, Grygorii.Strashko@linaro.org wrote:
> >> The dma_coerce_mask_and_coherent() will fail in case 'Example 3' and succeed in cases 1,2.
> >> dma-mapping.c --> __dma_supported()
> >> 	if (sizeof(mask) != sizeof(dma_addr_t) && <== true for all OMAP4+
> >> 	    mask > (dma_addr_t)~0 &&		<== true for DMA_BIT_MASK(64)
> >> 	    dma_to_pfn(dev, ~0) < max_pfn) {  <== true only for Example 3
> > 
> > Hmm, I think this may make more sense to be "< max_pfn - 1" here, as
> > that would be better suited to our intention.
> > 
> > The result of dma_to_pfn(dev, ~0) is the maximum PFN which we could
> > address via DMA, but we're comparing it with the maximum PFN in the
> > system plus 1 - so we need to subtract one from it.
> 
> Ok. I'll try it.

Any news on this - I think it is a real off-by-one bug which we should
fix in any case.

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
