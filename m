Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 4729C6B0037
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 09:03:10 -0400 (EDT)
Received: by mail-ve0-f178.google.com with SMTP id db10so3318886veb.9
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 06:03:09 -0700 (PDT)
Date: Sat, 16 Mar 2013 09:03:04 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH v2 1/4] introduce zero filled pages handler
Message-ID: <20130316130302.GA5987@konrad-lan.dumpdata.com>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363255697-19674-2-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363255697-19674-2-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 14, 2013 at 06:08:14PM +0800, Wanpeng Li wrote:
> Introduce zero-filled pages handler to capture and handle zero pages.
> 
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c |   26 ++++++++++++++++++++++++++
>  1 files changed, 26 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 328898e..b71e033 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -460,6 +460,32 @@ static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
>  	kmem_cache_free(zcache_obj_cache, obj);
>  }
>  
> +static bool page_zero_filled(void *ptr)

Shouldn't this be 'struct page *p' ?
> +{
> +	unsigned int pos;
> +	unsigned long *page;
> +
> +	page = (unsigned long *)ptr;

That way you can avoid this casting.
> +
> +	for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++) {
> +		if (page[pos])
> +			return false;

Perhaps allocate a static page filled with zeros and just do memcmp?
> +	}
> +
> +	return true;
> +}
> +
> +static void handle_zero_page(void *page)
> +{
> +	void *user_mem;
> +
> +	user_mem = kmap_atomic(page);
> +	memset(user_mem, 0, PAGE_SIZE);
> +	kunmap_atomic(user_mem);
> +
> +	flush_dcache_page(page);

This is new. Could you kindly explain why it is needed? Thanks.
> +}
> +
>  static struct tmem_hostops zcache_hostops = {
>  	.obj_alloc = zcache_obj_alloc,
>  	.obj_free = zcache_obj_free,
> -- 
> 1.7.7.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
