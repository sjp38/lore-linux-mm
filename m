Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id B6F196B0036
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:55:29 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so8826133pbc.2
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 15:55:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id f1si9643272pbn.188.2014.04.14.15.55.28
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 15:55:28 -0700 (PDT)
Date: Mon, 14 Apr 2014 15:55:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: convert some level-less printks to pr_*
Message-Id: <20140414155526.96b0832bf4660c026bc3a1d9@linux-foundation.org>
In-Reply-To: <1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
References: <1395942859-11611-1-git-send-email-mitchelh@codeaurora.org>
	<1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 27 Mar 2014 10:54:19 -0700 Mitchel Humpherys <mitchelh@codeaurora.org> wrote:

> printk is meant to be used with an associated log level. There are some
> instances of printk scattered around the mm code where the log level is
> missing. Add a log level and adhere to suggestions by
> scripts/checkpatch.pl by moving to the pr_* macros.
> 

hm, this is a functional change.

> --- a/mm/bounce.c
> +++ b/mm/bounce.c
> @@ -3,6 +3,8 @@
>   * - Split from highmem.c
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

Because of this.

>  #include <linux/mm.h>
>  #include <linux/export.h>
>  #include <linux/swap.h>
> @@ -15,6 +17,7 @@
>  #include <linux/hash.h>
>  #include <linux/highmem.h>
>  #include <linux/bootmem.h>
> +#include <linux/printk.h>
>  #include <asm/tlbflush.h>
>  
>  #include <trace/events/block.h>
> @@ -34,7 +37,7 @@ static __init int init_emergency_pool(void)
>  
>  	page_pool = mempool_create_page_pool(POOL_SIZE, 0);
>  	BUG_ON(!page_pool);
> -	printk("bounce pool size: %d pages\n", POOL_SIZE);
> +	pr_info("bounce pool size: %d pages\n", POOL_SIZE);

This used to print "bounce pool size: N pages" but will now print
"bounce: bounce pool size: N pages".

It isn't necessarily a *bad* change but perhaps a little more thought
could be put into it.  In this example it would be better remove the
redundancy by using 

	pr_info("pool size: %d pages\n"...);

And all of this should be described and justified in the changelog,
please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
