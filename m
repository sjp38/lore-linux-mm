Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A82336B0069
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 22:35:42 -0400 (EDT)
Message-ID: <4FFB94FF.8030401@kernel.org>
Date: Tue, 10 Jul 2012 11:35:43 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc: add details to zs_map_object boiler plate
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1341263752-10210-4-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/03/2012 06:15 AM, Seth Jennings wrote:
> Add information on the usage limits of zs_map_object()
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 4942d41..abf7c13 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -747,7 +747,12 @@ EXPORT_SYMBOL_GPL(zs_free);
>   *
>   * Before using an object allocated from zs_malloc, it must be mapped using
>   * this function. When done with the object, it must be unmapped using
> - * zs_unmap_object
> + * zs_unmap_object.
> + *
> + * Only one object can be mapped per cpu at a time. There is no protection
> + * against nested mappings.
> + *
> + * This function returns with preemption and page faults disabled.
>  */
>  void *zs_map_object(struct zs_pool *pool, unsigned long handle)
>  {
> 

The comment is good but I hope we can detect it automatically with DEBUG
option. It wouldn't be hard but it's a debug patch so not critical
until we receive some report about the bug.

The possibility for nesting is that it is used by irq context.

A uses the mapping
.
.
.
IRQ happen
	B uses the mapping in IRQ context
	.
	.
	.

Maybe we need local_irq_save/restore in zs_[un]map_object path.

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
