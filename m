Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D46B6B0270
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 18:01:05 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xx10so16896642pac.2
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 15:01:05 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id b7si19061314pas.289.2016.10.25.15.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 15:01:04 -0700 (PDT)
Subject: Re: [net-next PATCH 04/27] arch/arc: Add option to skip sync on DMA
 mapping
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
 <20161025153709.4815.82720.stgit@ahduyck-blue-test.jf.intel.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <64b46a7b-7ad4-5d09-5a0b-22dfaed8855e@synopsys.com>
Date: Tue, 25 Oct 2016 15:00:55 -0700
MIME-Version: 1.0
In-Reply-To: <20161025153709.4815.82720.stgit@ahduyck-blue-test.jf.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "davem@davemloft.net" <davem@davemloft.net>, "brouer@redhat.com" <brouer@redhat.com>

On 10/25/2016 02:38 PM, Alexander Duyck wrote:
> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> later via a sync_for_cpu or sync_for_device call.
>
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: linux-snps-arc@lists.infradead.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  arch/arc/mm/dma.c |    5 ++++-

Acked-by: Vineet Gupta <vgupta@synopsys.com>

>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c
> index 20afc65..6303c34 100644
> --- a/arch/arc/mm/dma.c
> +++ b/arch/arc/mm/dma.c
> @@ -133,7 +133,10 @@ static dma_addr_t arc_dma_map_page(struct device *dev, struct page *page,
>  		unsigned long attrs)
>  {
>  	phys_addr_t paddr = page_to_phys(page) + offset;
> -	_dma_cache_sync(paddr, size, dir);
> +
> +	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +		_dma_cache_sync(paddr, size, dir);
> +
>  	return plat_phys_to_dma(dev, paddr);
>  }
>  
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
