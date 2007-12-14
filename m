Date: Thu, 13 Dec 2007 17:03:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix page_alloc for larger I/O segments
Message-Id: <20071213170308.d4ce5889.akpm@linux-foundation.org>
In-Reply-To: <4761D0E9.4010701@rtr.ca>
References: <20071213185326.GQ26334@parisc-linux.org>
	<4761821F.3050602@rtr.ca>
	<20071213192633.GD10104@kernel.dk>
	<4761883A.7050908@rtr.ca>
	<476188C4.9030802@rtr.ca>
	<20071213193937.GG10104@kernel.dk>
	<47618B0B.8020203@rtr.ca>
	<20071213195350.GH10104@kernel.dk>
	<20071213200219.GI10104@kernel.dk>
	<476190BE.9010405@rtr.ca>
	<20071213200958.GK10104@kernel.dk>
	<20071213140207.111f94e2.akpm@linux-foundation.org>
	<1197584106.3154.55.camel@localhost.localdomain>
	<20071213142935.47ff19d9.akpm@linux-foundation.org>
	<4761B32A.3070201@rtr.ca>
	<4761BCB4.1060601@rtr.ca>
	<4761C8E4.2010900@rtr.ca>
	<4761CE88.9070406@rtr.ca>
	<4761D0E9.4010701@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Lord <liml@rtr.ca>
Cc: James.Bottomley@HansenPartnership.com, jens.axboe@oracle.com, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 13 Dec 2007 19:40:09 -0500
Mark Lord <liml@rtr.ca> wrote:

> And here is a patch that seems to fix it for me here:
> 
> * * * *
> 
> Fix page allocator to give better change of larger contiguous segments (again).
> 
> Signed-off-by: Mark Lord <mlord@pobox.com
> ---
> 
> 
> --- old/mm/page_alloc.c.orig	2007-12-13 19:25:15.000000000 -0500
> +++ linux-2.6/mm/page_alloc.c	2007-12-13 19:35:50.000000000 -0500
> @@ -954,7 +954,7 @@
>  				goto failed;
>  		}
>  		/* Find a page of the appropriate migrate type */
> -		list_for_each_entry(page, &pcp->list, lru) {
> +		list_for_each_entry_reverse(page, &pcp->list, lru) {
>  			if (page_private(page) == migratetype) {
>  				list_del(&page->lru);
>  				pcp->count--;

- needs help to make it apply to mainline

- needs a comment, methinks...


--- a/mm/page_alloc.c~fix-page-allocator-to-give-better-chance-of-larger-contiguous-segments-again
+++ a/mm/page_alloc.c
@@ -1060,8 +1060,12 @@ again:
 				goto failed;
 		}
 
-		/* Find a page of the appropriate migrate type */
-		list_for_each_entry(page, &pcp->list, lru)
+		/*
+		 * Find a page of the appropriate migrate type.  Doing a
+		 * reverse-order search here helps us to hand out pages in
+		 * ascending physical-address order.
+		 */
+		list_for_each_entry_reverse(page, &pcp->list, lru)
 			if (page_private(page) == migratetype)
 				break;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
