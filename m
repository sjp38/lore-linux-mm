Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A83D16B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 05:42:57 -0500 (EST)
Received: by bkty12 with SMTP id y12so5173624bkt.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 02:42:55 -0800 (PST)
Message-ID: <4F38E8E1.3070004@mvista.com>
Date: Mon, 13 Feb 2012 14:41:37 +0400
From: Sergei Shtylyov <sshtylyov@mvista.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/14 v2] MIPS: adapt for dma_map_ops changes
References: <1324643253-3024-4-git-send-email-m.szyprowski@samsung.com> <1329129329-25205-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1329129329-25205-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Hello.

On 13-02-2012 14:35, Marek Szyprowski wrote:

> From: Andrzej Pietrasiewicz<andrzej.p@samsung.com>

> Adapt core MIPS architecture code for dma_map_ops changes: replace
> alloc/free_coherent with generic alloc/free methods.

> Signed-off-by: Andrzej Pietrasiewicz<andrzej.p@samsung.com>
> [added missing changes to arch/mips/cavium-octeon/dma-octeon.c]
> Signed-off-by: Marek Szyprowski<m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
[...]

> diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
> index 7aa37dd..cbd41f5 100644
> --- a/arch/mips/include/asm/dma-mapping.h
> +++ b/arch/mips/include/asm/dma-mapping.h
> @@ -57,25 +57,31 @@ dma_set_mask(struct device *dev, u64 mask)
>   extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
>   	       enum dma_data_direction direction);
>
> -static inline void *dma_alloc_coherent(struct device *dev, size_t size,
> -				       dma_addr_t *dma_handle, gfp_t gfp)
> +#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
> +
> +static inline void *dma_alloc_attrs(struct device *dev, size_t size,
> +				    dma_addr_t *dma_handle, gfp_t gfp,
> +				    struct dma_attrs *attrs)
>   {
>   	void *ret;
>   	struct dma_map_ops *ops = get_dma_ops(dev);
>
> -	ret = ops->alloc_coherent(dev, size, dma_handle, gfp);
> +	ret = ops->alloc(dev, size, dma_handle, gfp, NULL);

    Not 'attrs' instead of NULL?

>
>   	debug_dma_alloc_coherent(dev, size, *dma_handle, ret);
>
>   	return ret;
>   }
>
> -static inline void dma_free_coherent(struct device *dev, size_t size,
> -				     void *vaddr, dma_addr_t dma_handle)
> +#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
> +
> +static inline void dma_free_attrs(struct device *dev, size_t size,
> +				  void *vaddr, dma_addr_t dma_handle,
> +				  struct dma_attrs *attrs)
>   {
>   	struct dma_map_ops *ops = get_dma_ops(dev);
>
> -	ops->free_coherent(dev, size, vaddr, dma_handle);
> +	ops->free(dev, size, vaddr, dma_handle, NULL);

    Same here...

WBR, Sergei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
