Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 411056B0170
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 13:05:33 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7NGVfAm001748
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 12:31:41 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7NH5UsS201192
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 13:05:31 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7NB5Ekc026359
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:05:15 -0600
Message-ID: <4E53DDC7.3040702@linux.vnet.ibm.com>
Date: Tue, 23 Aug 2011 12:05:11 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zcache: fix highmem crash on 32-bit
References: <1314115590-20942-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1314115590-20942-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: cascardo@holoscopio.com, dan.magenheimer@oracle.com, rdunlap@xenotime.net, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Please disregard, I sent this one out before on 8/10 :-/

Sorry for the noise.

I couldn't find the original post in the LKML archives, 
so I thought I had never sent it.  Turns out that I only 
sent it to the driver project list.

On 08/23/2011 11:06 AM, Seth Jennings wrote:
> After commit 966b9016a1, zcache_put_page() was modified to pass
> page_address(page) instead of the actual page pointer. In
> combination with the function signature changes to tmem_put()
> and zcache_pampd_create(), zcache_pampd_create() tries to (re)derive
> the page structure from the virtual address.  However, if the
> original page is a high memory page (or any unmapped page),
> this virt_to_page() fails because the page_address() in
> zcache_put_page() returned NULL.
> 
> This patch changes zcache_put_page() and zcache_get_page() to pass
> the page structure instead of the page's virtual address, which
> may or may not exist.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 855a5bb..a3f5162 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1158,7 +1158,7 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
>  	size_t clen;
>  	int ret;
>  	unsigned long count;
> -	struct page *page = virt_to_page(data);
> +	struct page *page = (struct page *)(data);
>  	struct zcache_client *cli = pool->client;
>  	uint16_t client_id = get_client_id_from_client(cli);
>  	unsigned long zv_mean_zsize;
> @@ -1227,7 +1227,7 @@ static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
>  	int ret = 0;
> 
>  	BUG_ON(is_ephemeral(pool));
> -	zv_decompress(virt_to_page(data), pampd);
> +	zv_decompress((struct page *)(data), pampd);
>  	return ret;
>  }
> 
> @@ -1539,7 +1539,7 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>  		goto out;
>  	if (!zcache_freeze && zcache_do_preload(pool) == 0) {
>  		/* preload does preempt_disable on success */
> -		ret = tmem_put(pool, oidp, index, page_address(page),
> +		ret = tmem_put(pool, oidp, index, (char *)(page),
>  				PAGE_SIZE, 0, is_ephemeral(pool));
>  		if (ret < 0) {
>  			if (is_ephemeral(pool))
> @@ -1572,7 +1572,7 @@ static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>  	pool = zcache_get_pool_by_id(cli_id, pool_id);
>  	if (likely(pool != NULL)) {
>  		if (atomic_read(&pool->obj_count) > 0)
> -			ret = tmem_get(pool, oidp, index, page_address(page),
> +			ret = tmem_get(pool, oidp, index, (char *)(page),
>  					&size, 0, is_ephemeral(pool));
>  		zcache_put_pool(pool);
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
