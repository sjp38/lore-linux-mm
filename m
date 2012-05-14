Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 5AE846B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 22:25:55 -0400 (EDT)
Message-ID: <4FB06D4C.1050209@kernel.org>
Date: Mon, 14 May 2012 11:26:20 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <4FABD503.4030808@vflare.org> <4FABDA9F.1000105@linux.vnet.ibm.com> <20120510151941.GA18302@kroah.com> <4FABECF5.8040602@vflare.org> <20120510164418.GC13964@kroah.com> <4FABF9D4.8080303@vflare.org> <20120510173322.GA30481@phenom.dumpdata.com> <4FAC4E3B.3030909@kernel.org> <8473859b-42f3-4354-b5ba-fd5b8cbac22f@default> <4FAC59F6.4080503@kernel.org> <20120511192915.GD3785@phenom.dumpdata.com> <4FAD8984.2050201@linux.vnet.ibm.com>
In-Reply-To: <4FAD8984.2050201@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/12/2012 06:49 AM, Seth Jennings wrote:

> On 05/11/2012 02:29 PM, Konrad Rzeszutek Wilk wrote:
> 
>>> At least, zram is also primary user and it also has such mess
>>> although it's not severe than zcache. zram->table[index].handle
>>> sometime has real (void*) handle, sometime (struct page*).
>>
>> Yikes. Yeah that needs to be fixed.
>>
> 
> 
> How about this (untested)?  Changes to zram_bvec_write() are a little
> hard to make out in this format.  There are a couple of checkpatch fixes
> (two split line strings) and an unused variable store_offset removal mixed
> in too. If this patch is good, I'll break them up for official submission
> after I test.
> 
> diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
> index fbe8ac9..10dcd99 100644
> --- a/drivers/staging/zram/zram_drv.h
> +++ b/drivers/staging/zram/zram_drv.h
> @@ -81,7 +81,10 @@ enum zram_pageflags {
>  
>  /* Allocated for each disk page */
>  struct table {
> -	void *handle;
> +	union {
> +		void *handle; /* compressible */
> +		struct page *page; /* incompressible */


You read my mind. That's exactly same idea with my patch which queued up to my tree.
But there is still problem.

zram has like this code

void *handle = zram->table[index].handle;
if (!handle) {

}

zram->table[index].handle = NULL;

It assume handle's size is greater than or equal to sizeof(struct page*)) for union working.
But we can't make sure handle's size.
If Nitin confirm this, too, the problem would be easy to fix.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
