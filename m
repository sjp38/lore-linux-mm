Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 33F826B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 02:06:21 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so2784912pab.1
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 23:06:20 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id yp8si10915570pac.193.2014.07.14.23.06.19
        for <linux-mm@kvack.org>;
        Mon, 14 Jul 2014 23:06:20 -0700 (PDT)
Date: Tue, 15 Jul 2014 15:12:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC/PATCH RESEND -next 20/21] fs: dcache: manually unpoison
 dname after allocation to shut up kasan's reports
Message-ID: <20140715061219.GK11317@js1304-P5Q-DELUXE>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-21-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404905415-9046-21-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, Jul 09, 2014 at 03:30:14PM +0400, Andrey Ryabinin wrote:
> We need to manually unpoison rounded up allocation size for dname
> to avoid kasan's reports in __d_lookup_rcu.
> __d_lookup_rcu may validly read a little beyound allocated size.

If it read a little beyond allocated size, IMHO, it is better to
allocate correct size.

kmalloc(name->len + 1, GFP_KERNEL); -->
kmalloc(roundup(name->len + 1, sizeof(unsigned long ), GFP_KERNEL);

Isn't it?

Thanks.

> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  fs/dcache.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index b7e8b20..dff64f2 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -38,6 +38,7 @@
>  #include <linux/prefetch.h>
>  #include <linux/ratelimit.h>
>  #include <linux/list_lru.h>
> +#include <linux/kasan.h>
>  #include "internal.h"
>  #include "mount.h"
>  
> @@ -1412,6 +1413,8 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
>  			kmem_cache_free(dentry_cache, dentry); 
>  			return NULL;
>  		}
> +		unpoison_shadow(dname,
> +				roundup(name->len + 1, sizeof(unsigned long)));
>  	} else  {
>  		dname = dentry->d_iname;
>  	}	
> -- 
> 1.8.5.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
