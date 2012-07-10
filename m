Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 94E7E6B0073
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 22:21:43 -0400 (EDT)
Message-ID: <4FFB91B8.5070009@kernel.org>
Date: Tue, 10 Jul 2012 11:21:44 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] zsmalloc: remove x86 dependency
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1341263752-10210-2-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/03/2012 06:15 AM, Seth Jennings wrote:
> This patch replaces the page table assisted object mapping
> method, which has x86 dependencies, with a arch-independent
> method that does a simple copy into a temporary per-cpu
> buffer.
> 
> While a copy seems like it would be worse than mapping the pages,
> tests demonstrate the copying is always faster and, in the case of
> running inside a KVM guest, roughly 4x faster.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zsmalloc/Kconfig         |    4 --
>  drivers/staging/zsmalloc/zsmalloc-main.c |   99 +++++++++++++++++++++---------
>  drivers/staging/zsmalloc/zsmalloc_int.h  |    5 +-
>  3 files changed, 72 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
> index a5ab720..9084565 100644
> --- a/drivers/staging/zsmalloc/Kconfig
> +++ b/drivers/staging/zsmalloc/Kconfig
> @@ -1,9 +1,5 @@
>  config ZSMALLOC
>  	tristate "Memory allocator for compressed pages"
> -	# X86 dependency is because of the use of __flush_tlb_one and set_pte
> -	# in zsmalloc-main.c.
> -	# TODO: convert these to portable functions
> -	depends on X86
>  	default n
>  	help
>  	  zsmalloc is a slab-based memory allocator designed to store
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 10b0d60..a7a6f22 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -470,6 +470,57 @@ static struct page *find_get_zspage(struct size_class *class)
>  	return page;
>  }
>  
> +static void zs_copy_map_object(char *buf, struct page *firstpage,
> +				int off, int size)

firstpage is rather misleading.
As you know, we use firstpage term for real firstpage of zspage but
in case of zs_copy_map_object, it could be a middle page of zspage.
So I would like to use "page" instead of firstpage.

> +{
> +	struct page *pages[2];
> +	int sizes[2];
> +	void *addr;
> +
> +	pages[0] = firstpage;
> +	pages[1] = get_next_page(firstpage);
> +	BUG_ON(!pages[1]);
> +
> +	sizes[0] = PAGE_SIZE - off;
> +	sizes[1] = size - sizes[0];
> +
> +	/* disable page faults to match kmap_atomic() return conditions */
> +	pagefault_disable();

If I understand your intention correctly, you want to prevent calling
this function on non-atomic context. Right?
Please write down description more clearly as point of view what's happen
if we didn't.

> +
> +	/* copy object to per-cpu buffer */
> +	addr = kmap_atomic(pages[0]);
> +	memcpy(buf, addr + off, sizes[0]);
> +	kunmap_atomic(addr);
> +	addr = kmap_atomic(pages[1]);
> +	memcpy(buf + sizes[0], addr, sizes[1]);
> +	kunmap_atomic(addr);
> +}
> +
> +static void zs_copy_unmap_object(char *buf, struct page *firstpage,
> +				int off, int size)

Ditto firstpage.

Otherwise, Looks good to me.

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
