Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B06838E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:10:33 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y74so320002wmc.0
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:10:33 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::7])
        by mx.google.com with ESMTPS id a124si26702005wmf.38.2019.01.18.03.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 03:10:32 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <3504ee70-02de-049e-6402-2d530bf55a84@xenosoft.de>
 <23284859-bf0a-9cd5-a480-2a7fd7802056@xenosoft.de>
 <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de>
 <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de>
 <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de>
 <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de>
 <20190115133558.GA29225@lst.de>
 <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de>
 <20190115151732.GA2325@lst.de>
 <e9345547-4dc6-747a-29ec-6375dc8bfe83@xenosoft.de>
 <20190118083539.GA30479@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <871403f2-fa7d-de15-89eb-070432e15c69@xenosoft.de>
Date: Fri, 18 Jan 2019 12:10:26 +0100
MIME-Version: 1.0
In-Reply-To: <20190118083539.GA30479@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

For which commit?

-- Christian

On 18 January 2019 at 09:35AM, Christoph Hellwig wrote:
> Hi Christian,
>
> can you check if the debug printks in this patch trigger?
>
> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 355d16acee6d..e46c9b64ec0d 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -118,8 +118,11 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
>   			page = NULL;
>   		}
>   	}
> -	if (!page)
> +	if (!page) {
>   		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
> +		if (!page)
> +			pr_warn("failed to allocate memory with gfp 0x%x\n", gfp);
> +	}
>   
>   	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
>   		__free_pages(page, page_order);
> @@ -139,6 +142,10 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
>   		}
>   	}
>   
> +	if (!page) {
> +		pr_warn("failed to allocate DMA memory!\n");
> +		dump_stack();
> +	}
>   	return page;
>   }
>   
>
