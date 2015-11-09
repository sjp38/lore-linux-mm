Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D72F26B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 11:13:05 -0500 (EST)
Received: by wmww144 with SMTP id w144so38971956wmw.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 08:13:05 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id 8si18912113wjy.211.2015.11.09.08.07.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Nov 2015 08:07:45 -0800 (PST)
Date: Mon, 9 Nov 2015 16:07:26 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
Message-ID: <20151109160726.GB8644@n2100.arm.linux.org.uk>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, codalist@coda.cs.cmu.edu, linux-mtd@lists.infradead.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org

On Mon, Nov 09, 2015 at 08:56:10PM +0900, Tetsuo Handa wrote:
> There are many locations that do
> 
>   if (memory_was_allocated_by_vmalloc)
>     vfree(ptr);
>   else
>     kfree(ptr);
> 
> but kvfree() can handle both kmalloc()ed memory and vmalloc()ed memory
> using is_vmalloc_addr(). Unless callers have special reasons, we can
> replace this branch with kvfree(). Please check and reply if you found
> problems.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Russell King <linux@arm.linux.org.uk> # arm

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

In so far as this ARM specific change looks reasonable.  Thanks.

> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index e62400e..492bf3e 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1200,10 +1200,7 @@ error:
>  	while (i--)
>  		if (pages[i])
>  			__free_pages(pages[i], 0);
> -	if (array_size <= PAGE_SIZE)
> -		kfree(pages);
> -	else
> -		vfree(pages);
> +	kvfree(pages);
>  	return NULL;
>  }
>  
> @@ -1211,7 +1208,6 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages,
>  			       size_t size, struct dma_attrs *attrs)
>  {
>  	int count = size >> PAGE_SHIFT;
> -	int array_size = count * sizeof(struct page *);
>  	int i;
>  
>  	if (dma_get_attr(DMA_ATTR_FORCE_CONTIGUOUS, attrs)) {
> @@ -1222,10 +1218,7 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages,
>  				__free_pages(pages[i], 0);
>  	}
>  
> -	if (array_size <= PAGE_SIZE)
> -		kfree(pages);
> -	else
> -		vfree(pages);
> +	kvfree(pages);
>  	return 0;
>  }
>  

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
