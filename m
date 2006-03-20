From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH][1/3] mm: swsusp shrink_all_memory tweaks
Date: Mon, 20 Mar 2006 19:46:31 +0100
References: <200603200231.50666.kernel@kolivas.org> <441E94FA.8070408@yahoo.com.au> <200603202250.14843.kernel@kolivas.org>
In-Reply-To: <200603202250.14843.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603201946.32681.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 20 March 2006 12:50, Con Kolivas wrote:
> On Monday 20 March 2006 22:41, Nick Piggin wrote:
> > I still don't like this change.
> 
> Fine.
> 
> Respin.
}-- snip --{
> Index: linux-2.6.16-rc6-mm2/kernel/power/swsusp.c
> ===================================================================
> --- linux-2.6.16-rc6-mm2.orig/kernel/power/swsusp.c	2006-03-20 22:44:10.000000000 +1100
> +++ linux-2.6.16-rc6-mm2/kernel/power/swsusp.c	2006-03-20 22:46:12.000000000 +1100
> @@ -173,9 +173,6 @@ void free_all_swap_pages(int swap, struc
>   *	Notice: all userland should be stopped before it is called, or
>   *	livelock is possible.
>   */
> -
> -#define SHRINK_BITE	10000
> -
>  int swsusp_shrink_memory(void)
>  {
>  	long size, tmp;
> @@ -194,14 +191,13 @@ int swsusp_shrink_memory(void)
>  		for_each_zone (zone)
>  			if (!is_highmem(zone))
>  				tmp -= zone->free_pages;
> +		if (tmp <= 0)
> +			tmp = size - image_size / PAGE_SIZE;
>  		if (tmp > 0) {
> -			tmp = shrink_all_memory(SHRINK_BITE);
> +			tmp = shrink_all_memory(tmp);
>  			if (!tmp)
>  				return -ENOMEM;
>  			pages += tmp;
> -		} else if (size > image_size / PAGE_SIZE) {
> -			tmp = shrink_all_memory(SHRINK_BITE);
> -			pages += tmp;
>  		}
>  		printk("\b%c", p[i++%4]);
>  	} while (tmp > 0);
> 

swsusp_shrink_memory() is still wrong, because it will always fail for
image_size = 0.  My bad, sorry.

The appended patch (on top of yours) should fix that (hope I did it right
this time).

 kernel/power/swsusp.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

Index: linux-2.6.16-rc6-mm2/kernel/power/swsusp.c
===================================================================
--- linux-2.6.16-rc6-mm2.orig/kernel/power/swsusp.c
+++ linux-2.6.16-rc6-mm2/kernel/power/swsusp.c
@@ -192,13 +192,17 @@ int swsusp_shrink_memory(void)
 		for_each_zone (zone)
 			if (!is_highmem(zone))
 				tmp -= zone->free_pages;
-		if (tmp <= 0)
-			tmp = size - image_size / PAGE_SIZE;
 		if (tmp > 0) {
 			tmp = shrink_all_memory(tmp);
 			if (!tmp)
 				return -ENOMEM;
 			pages += tmp;
+		} else {
+			size -= image_size / PAGE_SIZE;
+			if (size > 0) {
+				tmp = shrink_all_memory(size);
+				pages += tmp;
+			}
 		}
 		printk("\b%c", p[i++%4]);
 	} while (tmp > 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
