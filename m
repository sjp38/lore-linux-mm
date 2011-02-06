Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 637D28D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 12:47:11 -0500 (EST)
Message-ID: <4D4EDE69.9060200@kernel.org>
Date: Sun, 06 Feb 2011 09:46:17 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] memblock: Fix error path in memblock_add_region()
References: <1296999075-8022-1-git-send-email-namhyung@gmail.com>
In-Reply-To: <1296999075-8022-1-git-send-email-namhyung@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 02/06/2011 05:31 AM, Namhyung Kim wrote:
> @type->regions should be restored if memblock_double_array() fails.
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Yinghai Lu <yinghai@kernel.org>
> ---
>  mm/memblock.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index bdba245d8afd..49284f9f99a6 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -379,6 +379,10 @@ static long __init_memblock memblock_add_region(struct memblock_type *type, phys
>  	 */
>  	if (type->cnt == type->max && memblock_double_array(type)) {
>  		type->cnt--;
> +		for (++i; i < type->cnt; i++) {
> +			type->regions[i].base = type->regions[i+1].base;
> +			type->regions[i].size = type->regions[i+1].size;
> +		}
>  		return -1;
>  	}
>  

we can skip the restoring.

Thanks

Yinghai

diff --git a/mm/memblock.c b/mm/memblock.c
index bdba245..3231657 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -374,13 +374,9 @@ static long __init_memblock memblock_add_region(struct memblock_type *type, phys
 	}
 	type->cnt++;
 
-	/* The array is full ? Try to resize it. If that fails, we undo
-	 * our allocation and return an error
-	 */
-	if (type->cnt == type->max && memblock_double_array(type)) {
-		type->cnt--;
+	/* The array is full ? Try to resize it  */
+	if (type->cnt == type->max && memblock_double_array(type))
 		return -1;
-	}
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
